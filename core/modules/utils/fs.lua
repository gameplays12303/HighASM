local expect = require("core.modules.expect2")
---@diagnostic disable-next-line: cast-local-type
expect = expect.expect
local String = require("core.modules.utils.string")
local lfs = require("lfs")
local fs = {}
local _islinux = package.config:sub(1,1) == "/"

-- fs addons

---checks to see if it exists

---@param sPath any
---@return boolean
function fs.exists(sPath)
    expect(false,1,sPath,"string")
    local atr = lfs.attributes(sPath)
    return atr ~= nil
end
---test to see if path is Directory
---@param sDir any
---@return boolean
---@return string|nil
function fs.isDir(sDir)
    expect(false,1,sDir,"string")
    local atr = lfs.attributes(sDir)
    if not atr
    then
          return false,"does not exists"
    end
    return atr and atr.mode == "Directory"
end
--- gets the direory of the path
---@param sPath any
---@return string
function fs.getDir(sPath)
    expect(false,1,sPath,"string")
    if _islinux
    then
        local tbl = String.split(sPath,"/")
        return table.concat(tbl,"/",1,#tbl-1)
    else
        local tbl = String.split(sPath,"\\")
        return table.concat(tbl,"\\",1,#tbl-1)
    end
end

---gets the rxtension type (.lua)
---@param _sfile string
---@return string
function fs.getExtension(_sfile)
    expect(false,1,_sfile,"string")
    local Table = String.split(_sfile,"%.")
    return Table[2]
end
---gets the root (C:/, Root)
---@param _sPath string
---@return string
function fs.getRoot(sPath)
    expect(false,1,sPath,"string")
    if _islinux
    then
        return String.split(sPath,"/")[1]
    else
        return String.split(sPath,"\\")[1]
    end
end
---gets the name but leaves out the type
---@param _sfile string
---@return string
function fs.withoutExtension(sfile)
    expect(false,1,sfile,"string")
    local Table = String.split(sfile,".")
    return Table[1]
end
---comment
---@param _sfile string
---@return string
function fs.getName(sfile)
    expect(false,1,sfile,"string")
    local tbl
    if _islinux
    then
        tbl = String.split(sfile,"/")
    else
        tbl = String.split(sfile,"\\")
    end
    return tbl[#tbl]
end
fs.makeDir = lfs.mkdir


return fs