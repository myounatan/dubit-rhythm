--[[-
  @module enum

  @author Stefano Mazzucco
  @copyright 2017 Stefano Mazzucco

  @usage
  enum = require("enum")

  sizes = {"SMALL", "MEDIUM", "BIG"}
  Size = enum.new("Size", sizes)
  print(Size) -- "<enum 'Size'>"
  print(Size.SMALL) -- "<Size.SMALL: 1>"
  print(Size.SMALL.Name) -- "SMALL"
  print(Size.SMALL.Value) -- 1
  assert(Size.SMALL ~= Size.BIG) -- true
  assert(Size.SMALL < Size.BIG) -- error "Unsupported operation"
  assert(Size[1] == Size.SMALL) -- true
  Size[5] -- error "Invalid enum member: 5"

  -- Enums cannot be modified
  Size.MINI -- error "Invalid enum: MINI"
  assert(Size.BIG.something == nil) -- true
  Size.MEDIUM.other = 1 -- error "Cannot set fields in enum value"

  -- Keys cannot be reused
  Color = enum.new("Color", {"RED", "RED"}) -- error "Attempted to reuse key: 'RED'"
]]
local format = string.format

local function make_meta(idx, name, value, _type)
  return {
        __index = { Value = idx, Name = value, _type = _type },
        __newindex = function ()
          error("Cannot set fields in enum value", 2)
        end,
        __tostring = function ()
          return format('<%s.%s: %d>', name, value, idx)
        end,
        __le = function ()
          error("Unsupported operation")
        end,
        __lt = function ()
          error("Unsupported operation")
        end,
        __eq = function (this, other)
          return this._type == other._type and this.Value == other.Value
        end,
    }
end

local function check(values)
  local found = {}

  for _, v in ipairs(values) do
    if type(v) ~= "string" then
      error("Can create enum only from strings")
    end

    if found[v] == nil then
      found[v] = 1
    else
      found[v] = found[v] + 1
    end
  end

  local msg = "Attempted to reuse key: '%s'"
  for k, v in pairs(found) do
    if v > 1 then
      error(msg:format(k))
    end
  end

end

--- Make a new enum from all the string values passed in.
-- @string name the name of the enum
-- @tparam {string} values array of string values
-- @treturn table a read-only Enum table
return function(name, values)

  local _Private = {}
  local _Type = {}

  setmetatable(
    _Private,
    {
      __index = function (t, k)
        local v = rawget(t, k)
        if v == nil then
          error("Invalid enum member: " .. k, 2)
        end
        return v
      end
    }
  )

  check(values)

  for i, v in ipairs(values) do
    local o = {}
    setmetatable(o, make_meta(i, name, v, _Type))
    _Private[v] = o
    _Private[i] = o
  end

  -- public readonly table
  local enum = {}
  setmetatable(
    enum,
    {
      __index = _Private,
      __newindex = function ()
        error("Cannot set enum value")
      end,
      __tostring = function ()
        return format("<enum '%s'>", name)
      end,
	  __call = function() -- return values on enum() call
		return values
	  end
    }
  )

  return enum
end