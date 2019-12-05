local cjson = require "cjson"
local basic_serializer = require "kong.plugins.log-serializers.basic"
local BasePlugin = require "kong.plugins.base_plugin"
local StdoutLogHandler = BasePlugin:extend()
-- https://docs.konghq.com/1.3.x/plugin-development/custom-logic/

-- lower is later, < 10 for logging
StdoutLogHandler.PRIORITY = 9
StdoutLogHandler.VERSION = "0.0.1"

function StdoutLogHandler:new()
  StdoutLogHandler.super.new(self, "stdout-log")
end

-- Returns a copy of the input table filtered to only those keys present
-- in allowed_keys. The corresponding values will either be:
--     * the same as in the input
--     * the result of calling the function value from special_cases
--       corresponding to the same key (letting us do further filtering
--       of nested tables)
function filterTable(table, allowed_keys, special_cases)
  local filteredTable = {}

  for key, value in pairs(table) do
    for _, allowed_key in pairs(allowed_keys) do
      if key == allowed_key then
        local special_cased = false

        for special_case_key, special_case_handler in pairs(special_cases) do
          if key == special_case_key then
            filteredTable[key] = special_case_handler(value)
            special_cased = true
            break
          end
        end

        if not special_cased then
          filteredTable[key] = value
        end
        break
      end
    end
  end

  return filteredTable
end

function filterSerializedFields(serialized, conf)
  return filterTable(serialized, conf.allowed_fields, {
    request=function(x) return filterTable(x, conf.allowed_request_fields, {
      headers=function(y) return filterTable(y, conf.allowed_request_headers, {}) end,
      querystring=function(y) return filterTable(y, conf.allowed_request_querystring_fields, {}) end,
    }) end,
    response=function(x) return filterTable(x, conf.allowed_response_fields, {
      headers=function(y) return filterTable(y, conf.allowed_response_headers, {}) end,
    }) end,
    latencies=function(x) return filterTable(x, conf.allowed_latencies_fields, {}) end,
  })
end

function StdoutLogHandler:log(conf)
  StdoutLogHandler.super.log(self)
  local message = filterSerializedFields(basic_serializer.serialize(ngx), conf)
  io.stdout:write(cjson.encode(message) .. "\n")
end

return StdoutLogHandler
