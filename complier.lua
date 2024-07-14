local expect = require("core.modules.expect2").expect
local String = require("core.modules.utils.string")
local Tab = require("core.modules.utils.tables")
local fm = require("core.modules.fm")



local args = {...}
if #args == 0
then
    io.write("type prompts use \" \" to separate ")
    local input = io.read()
    local split = String.split(input," ")
    args = split
end
local file,err = fm.readFile(args[1],"R")
if not file
then
    error(err,0)
end
file = String.split(file,";")
local results = {}

local function removeEmptyTables(tbl)
    for i = #tbl, 1, -1 do
        local v = tbl[i]
        if type(v) == "table" and not Tab.selfReferencing(v) then
            removeEmptyTables(v)
            if #v == 0 then
                table.remove(tbl, i)
            end
        end
    end
end

-- Iterate through each line in 'file'
for _, v in ipairs(file) do
    local newStri = v:gsub("local", string.char(0x1))  -- Replace 'local' with special character
    newStri = newStri:gsub("global", string.char(0x2)) -- Replace 'global' with special character
    newStri = newStri:gsub("class", string.char(0x3)) -- Replace 'class' with special character
    local parts = String.split(newStri, "%s+")  -- Split the line by whitespace

    local parsedParts = {}  -- Initialize the table to hold parsed parts
    local currentTable = parsedParts  -- Start with the outermost table

    for _, part in ipairs(parts) do
        local nestedSegments = String.split(part, "()")  -- Split by '(' and ')'
        
        for _, segment in ipairs(nestedSegments) do
            if segment ~= "" then
                if segment == "1" then
                    table.insert(currentTable, segment)
                else
                    local nextTable = {}
                    table.insert(currentTable, segment)
                    table.insert(currentTable, nextTable)
                    currentTable = nextTable
                end
            end
        end
    end
    removeEmptyTables(parsedParts)
    table.insert(results, parsedParts)
end



local hex_count = 0
local function generateHex()
    hex_count = hex_count + 1
    return string.format("%02X", hex_count)
end

local BIR = "" -- final result 
local value_references = {} -- stores varaible references for compling 
local class_references = { -- [type] = {[actions]...} stores classes 
    ["nil"] = {  -- defualt
        ["set"] = {
            binary = 0x01,-- hex Code of class
            num_args = 1,
        },
    },
    ["number"] = {},
    ["string"] = {},
    ["boolean"] = {},
    ["function"] = {},
} -- stores classes

local function complie(strut)
    for i,v in pairs(strut) do
        local declareMode = false
        if type(v) == "table" and not Tab.selfReferencing(v)
        then
            complie(v)
        else
            local stri = String.split(v,":")
            if stri[1] == string.char(0x3)
            then
                class_references[stri[2]] = {binary = generateHex()}
            else
                if declareMode
                then
                    value_references[stri[1]] = {binary = generateHex(),class = "nil"}
                    declareMode = false
                end
                if v == string.char(0x1) or v == string.char(0x2)
                then
                    declareMode = true
                end
                local info = value_references[stri[1]]
                local action_info = class_references[info.class][stri[2]]
            end
        end
    end
end

fm.OverWrite("results.txt",results)
