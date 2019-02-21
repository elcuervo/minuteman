---
redis.log(redis.LOG_NOTICE, 'Minuteman')

local action = cjson.decode(ARGV[1])
local keys = cjson.decode(ARGV[2])
local dest = cjson.decode(ARGV[3])

local function operate(action, keys)
  if type(keys) == "string" then keys = { keys } end

  redis.call("BITOP", action, dest, unpack(keys) )

  return dest
end

local function AND(keys) return operate("AND", keys) end
local function OR(keys)  return operate("OR",  keys) end
local function XOR(keys) return operate("XOR", keys) end
local function NOT(keys) return operate("NOT", keys) end

local function MINUS(keys)
  local items = keys
  local src = table.remove(items, 1)
  local and_op = AND(keys)

  return XOR({ src, and_op })
end

local function operation(action, keys)
  if action == "MINUS" then
    return MINUS(keys)
  else
    return operate(action, keys)
  end
end

return operation(action, keys)
