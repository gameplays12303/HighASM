---@diagnostic disable: deprecated
local expect = require("core.modules.expect2")
local blacklist = expect.blacklist
---@diagnostic disable-next-line: cast-local-type
expect = expect.expect
local string,table = string,table
local Table = require("core.modules.utils.tables")
local String = {}

---splits a string
---@param inputstr string
---@param sep string|nil
---@param _bkeepdelimiters boolean|nil
---@return table
function String.split(inputstr, sep,_bkeepdelimiters)
    expect(false,1,inputstr,"string")
    expect(false,2,sep,"string","nil")
    expect(false,3,_bkeepdelimiters,"boolean","nil")
    local t={}
    if not sep
    then
          for char in inputstr:gmatch(".") do
                table.insert(t, char) end
          return t
    end
    if not _bkeepdelimiters
    then
          for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
          end
          return t
    end
    for str in string.gmatch(inputstr,"[^"..sep.."]*["..sep.."]?") do
          table.insert(t, str)
    end
    t[#t] = nil
    return t
end
---preps a string for the window
---@param termnial_size number
---@param _sMessage string
---@param CursorPosX number|nil
function String.wrap(termnial_size,_sMessage,CursorPosX)
    expect(false,1,termnial_size,"number")
    expect(false,2,_sMessage,"string")
    CursorPosX = expect(false,3,CursorPosX,"number","nil") or 0
    local word = {}
    for i,v in pairs(String.split(_sMessage," ",true)) do
          word[i] = String.split(v)
    end
    local results = ""
    local Sy = 1
    local index = 1
    local function next()
          index = index + 1
    end
    local function AddAndReset()
          CursorPosX = 0
          Sy = Sy + 1
          results = results.."\n"
    end
    while index <= #word do
          local Char_list = word[index]
          if #Char_list > termnial_size
          then
                for _,s in pairs(Char_list) do
                      CursorPosX = CursorPosX + 1
                      if CursorPosX > termnial_size
                      then
                            AddAndReset()
                      end
                      results = results..s
                end
                next()
          elseif #Char_list+CursorPosX > termnial_size
          then
                AddAndReset()
          else
                results = results..table.concat(Char_list,"")
                CursorPosX = CursorPosX + #Char_list
                next()
          end
    end
    return results,Sy
end
---custom built Serialiser design to handle
---@param _data any
---@param _Index any
---@return string|unknown
function String.Serialise(_data,_Index)
    blacklist(false,1,_data,"thread","function","userdata")
    _Index =  expect(false,2,_Index,"number","nil") or 0
    local indexGag = ("\t"):rep(_Index)
    local handle = {
        ["boolean"] = function ()
            return tostring(_data)
        end,
        ["string"] = function ()
            return "\"".._data.."\""
        end,
        ["table"] = function ()
            local result = "{\n"
            for i,v in pairs(_data) do
                if type(v) ~= "table" or not Table.selfReferencing(v)
                then
                    if type(i) == "string"
                    then
                        if string.find(i,"%p") ~= nil
                        then
                            result = result.."\t"..indexGag..("[\"%s\"] = "):format(i)..String.Serialise(v,_Index+1)..",\n"
                        else
                            result = result.."\t"..indexGag..("%s = "):format(i)..String.Serialise(v,_Index+1)..",\n"
                        end
                    else
                        result = result.."\t"..indexGag..String.Serialise(v,_Index+1)..",\n"
                    end
                end
            end
            return result..indexGag.."}"
        end,
    }
    handle["number"] = handle["boolean"]
    return handle[type(_data)]()
end
---custom text loader 
---@param _sData string
---@return unknown
function String.Unserialise(_sData)
expect(false,1, _sData, "string")
local func,err = loadstring("return " .. _sData, "unserialize")
if func then
    local ok, result = pcall(func)
    if ok then
          return result
    end
end
return error(err,2)
end

return String