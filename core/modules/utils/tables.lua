local expect = require("core.modules.expect2")

local blacklist = expect.blacklist
---@diagnostic disable-next-line: cast-local-type
expect = expect.expect
local string,table = string,table
local setmetatable = setmetatable
local getmetatable = getmetatable
local Table = {}


-- table addons


---looks in the table for a values (dose not check subtables and the index table)
---@param base table
---@param ID string|number
---@return string|number|boolean
function Table.find(base,ID)
    expect(false,1,base,"table")
    for i,v in pairs(base) do
          if type(v) == "string" and type(ID) == "string"
          then
                if string.find(v,ID)
                then
                      return i
                end
          elseif v == ID
          then
                return i
          end
    end
    return false
end
---checks to see if a table is selfReferencing
---@param base table
---@return boolean
function Table.selfReferencing(base)
    expect(false, 1, base, "table")
    local stack = {{base, select(2, pcall(getmetatable, base))}}
    local seen = {}
    local firstLoop = true
    while true do
        local current = table.remove(stack)
        if not current then
            break
        end
        local tbl, mt = current[1], current[2]
        if tbl == base and not firstLoop then
            return true
        end
        seen[tbl] = true
        -- Iterate through the current table's values
        for _, v in pairs(tbl) do
            if v == base then
                return true
            end
            if type(v) == "table" and not seen[v] then
                table.insert(stack, {v, select(2, pcall(getmetatable, v))})
            end
        end
        -- Check the metatable's __index field if it's a table
        if type(mt) == "table" and mt.__index then
            local meta_index = mt.__index
            if type(meta_index) == "function" then
                meta_index = meta_index(tbl)
            end
            if type(meta_index) == "table" and not seen[meta_index] then
                table.insert(stack, {meta_index, select(2, pcall(getmetatable, meta_index))})
            end
        end
        firstLoop = false
    end
    return false
end
---creates a true copy (with the option to include the meta table)
---@param Copy_Tbl table
---@param copymetatable boolean|nil
---@return table
function Table.copy(Copy_Tbl,copymetatable)
    expect(false,1,Copy_Tbl,"table")
    expect(false,2,copymetatable,"boolean","nil")
    local proxy = {}
    for index,v in pairs(Copy_Tbl) do
          if type(v) == "table" and not Table.selfReferencing(v)
          then
                proxy[index] = Table.copy(v,copymetatable)
          else
                proxy[index] = v
          end
    end
    local bool,reuslt = pcall(getmetatable,Copy_Tbl)
    if bool and copymetatable
    then
          setmetatable(proxy,reuslt)
    end
    return proxy
end

---transfers a number of items indexes into a new table
---@param base table
---@param _nTransfer number
---@return table
function Table.transfer(base,_nTransfer)
    expect(false,1,base,"table")
    expect(false,2,_nTransfer,"number")
    local CIndex = 1
    local result = {}
    while CIndex <= _nTransfer do
          result[CIndex] = base[CIndex]
          CIndex = CIndex + 1
    end
    return result
end

---replaces the type with the class type
---@param self table
---@return string
function Table.tostring(self)
    local bool,meta = pcall(getmetatable,self)
    if not bool or not meta
    then
          return ("%s: (%s)"):format(Table.getType(self),Table.get_hash(self))
    end
    if not meta.hash
    then
          return meta._name or meta.type
    end
    return ("%s: (%s)"):format(meta._name,meta.hash)
end
---sets the class type
---@param Tbl table
---@param Type string
---@param keepHash boolean|nil
---@return table
function Table.setType(Tbl,Type,keepHash)
    expect(false,1,Tbl,"table")
    expect(false,2,Type,"string")
    local bool,meta = pcall(getmetatable,Tbl)
    if not bool or not meta
    then
          meta = {}
    end
    meta._name = Type
    if keepHash or keepHash == nil
    then
          meta.hash = Table.get_hash(Tbl)
    end
    meta.__tostring = Table.tostring
    return setmetatable(Tbl,meta)
end
---returns the class type
---@param Tbl table
---@return string
function Table.getType(Tbl)
    expect(false,1,Tbl,"table")
    local meta = getmetatable(Tbl) or {}
    return meta._name or "table"
end
---returns the hash
---@param Tbl table
---@return string
function Table.get_hash(Tbl)
    expect(false,1,Tbl,"table")
    local meta = getmetatable(Tbl) or {}
    return meta.hash or tostring(Tbl):match("table: (%x+)")
end
return Table