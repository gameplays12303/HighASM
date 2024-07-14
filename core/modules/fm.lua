-- this is just a module to lower the ammount of code to be written
-- if you need specific handling or are going to be writing to the file
-- multipule times this is not the handle you want to use
local fs = require("core.modules.utils.fs")
local String = require("core.modules.utils.string")
local expect = require("core.modules.expect2")
local blacklist = expect.blacklist
---@diagnostic disable-next-line: cast-local-type
expect = expect.expect
local fm = {}
---wrapped file writer
---@param sPath string
---@param data any
---@param mode string|nil
---@return boolean|string
---@return string|nil
function fm.OverWrite(sPath,data,mode)
    expect(false,1,sPath,"string")
    blacklist(false,2,data,"thread","userdata")
    mode = mode or "S"
    if mode ~= "S" and mode ~= "R"
    then
        error("Invalid mode",2)
    end
    do
        local Dir = fs.getDir(sPath)
        if not fs.exists(Dir)
        then
            fs.makeDir(Dir)
        end
    end
    local file,mess = io.open(sPath,"w")
    if file == nil then
        return false,mess
    end
    if mode == "R"
    then
        file:write(data)
    else
        file:write(String.Serialise(data))
    end
    file:close()
    return true
end
---wrapped file reader
---@param sPath string
---@param mode string|nil
---@return any
---@return string|nil
function fm.readFile(sPath,mode)
    expect(false,1,sPath,"string")
    expect(false,3,mode,"string","nil")
    mode = mode or "S"
    if mode ~= "S" and mode ~= "R"
    then
        error("Invalid mode",2)
    end
    local file,mess = io.open(sPath,"r")
    if file == nil then
        return false,mess
    end
    local data
    if mode == "R"
    then
        data = file:read("*a")
    else
        data = String.Unserialise(file:read("*a"))
    end
    file:close()
    return data
end

return fm
