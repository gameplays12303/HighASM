--- complies the files to a BIR
local expect = require("core.modules.expect2").expect
local String = require("core.modules.utils.string")
local Tab = require("core.modules.utils.tables")
local fm = require("core.modules.fm")
local fs = require("core.modules.utils.fs")
local utf8 = require("utf8")

local file_path, architecture
do
    local args = {...}
    if #args < 1 then
        io.write("Need file to compile\nParameters should be separated by spaces.\n>")
        local input = io.read()
        local split = String.split(input, " ")
        args = split
    end
    file_path = args[1]
    if not fs.exists(file_path)
    then
        error(("%s:not found"):format(file_path),0)
    end
end

local keywords = {
    "local",
    "global",
    "ret", -- return
    "goto",
    "do",
    "end",
    "#" -- uses to communacaite   
}

local ranges = {
    {start = 0x100000, stop = 0x10FFFD},
    {start = 0xF0000, stop = 0xFFFFD},
    {start = 0xE000, stop = 0xF8FF},
}
ranges.current = {range = ranges[1], count = ranges[1].start, index = 1}


local function generateHex()
    local hex_count = ranges.current.count + 1
    
    if hex_count > ranges.current.range.stop then
        if ranges.current.index == #ranges then
            error("Out of usable reference codes", 0)
        end
        local nextRange = ranges[ranges.current.index + 1]
        ranges.current = {range = nextRange, count = nextRange.start, index = ranges.current.index + 1}
        hex_count = nextRange.start
    else
        ranges.current.count = hex_count
    end
    return hex_count
end

-- time to fix the keywords
local count = 0
while true do
    local value = keywords[1]
    if value == nil
    then
        break
    end
    table.remove(keywords,1)
    count = count + 1
    keywords[value] = utf8.char(generateHex())
end

local value_IDs = {} -- stores variable references for compiling 
local class_references = fm.readFile("core/core_classes.dat","S")

-- Assign unique hexadecimal codes to each action/method
for _, class in pairs(class_references) do
    for _, action in pairs(class) do
        action.binary = utf8.char(generateHex())
    end
end

local file,err = io.open(file_path,"r")
if not file
then
    error(err,0)
end
local quoteMode = false
local BIR = {header = {classes = class_references,value_IDs = value_IDs,keywords = keywords},code = ""}
--- time to complie
local word,char = "",""
while char ~= nil do
    char = file:read(1)
    if char == nil
    then
        break
    end
    if char == "\'" or char == "\""
    then
        quoteMode = not quoteMode
    elseif string.match(char,"%p") and not quoteMode
    then
    elseif string.match(char,"%s") and not quoteMode
    then
        local matched_key = false
        --- time to process the word 
        for i,v in pairs(keywords) do -- checks to see if it's a key word 
            if word:gmatch(i)
            then
                ---@diagnostic disable-next-line: param-type-mismatch
                word  = utf8.char(v)
                matched_key = true
            end
        end
        if not matched_key
        then
            
        end
        BIR.code = BIR.code..word
    else
        word = word..char
    end
end

fm.OverWrite("results.txt",BIR,"S")