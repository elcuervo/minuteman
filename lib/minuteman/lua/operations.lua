---
local prefix = cmsgpack.unpack(ARGV[1])
local action = cmsgpack.unpack(ARGV[2])
local keys = cmsgpack.unpack(ARGV[3])

local function operate(prefix, action, keys)
  if type(keys) == "string" then keys = { keys } end

  local keys_names = table.concat(keys, "_")
  local dest_key = prefix .. ":" .. action .. ":" .. keys_names

  redis.call("BITOP", action, dest_key, unpack(keys) )

  return dest_key
end

local function AND(prefix, keys) return operate(prefix, "AND", keys) end
local function OR(prefix, keys)  return operate(prefix, "OR", keys)  end
local function XOR(prefix, keys) return operate(prefix, "XOR", keys) end
local function NOT(prefix, keys) return operate(prefix, "NOT", keys) end

local function MINUS(prefix, keys)
  local items = keys
  local dest = table.remove(items, 1)

  while table.getn(items) > 0 do
    local other = table.remove(items, 1)
    local and_op = AND(dest, other)

    dest = XOR(dest, and_op)
  end

  return dest
end

local function operation(prefix, action, keys)
  if action == "MINUS" then
    return MINUS(prefix, keys)
  else
    return operate(prefix, action, keys)
  end
end

return operation(prefix, action, keys)
