local cjson = require "cjson"
local basic_serializer = require "kong.plugins.log-serializers.basic"
local ffi = require("ffi")
local BasePlugin = require "kong.plugins.base_plugin"
local StdoutLogHandler = BasePlugin:extend()
-- https://docs.konghq.com/1.3.x/plugin-development/custom-logic/

ffi.cdef[[
   int printf(const char *fmt, ...);
]]
-- lower is later, < 10 for logging
StdoutLogHandler.PRIORITY = 9
StdoutLogHandler.VERSION = "0.0.1"

function StdoutLogHandler:new()
  StdoutLogHandler.super.new(self, "stdout-log")
end

function StdoutLogHandler:log(conf)
  StdoutLogHandler.super.log(self)
  local message = basic_serializer.serialize(ngx)
  local headers = {}
  message['service'] = nil
  message['route'] = nil
  message['route'] = nil
  -- Let's only log headers that are safe, e.g. in particular 'authorization'
  if message['request'] ~= nil then
    headers['user-agent'] = message['request']['headers']['user-agent']
    headers['accept'] = message['request']['headers']['accept']
    message['request']['headers'] = headers
    message['request']['querystring'] = nil
  end
  if message['response'] ~= nil then
    message['response']['headers'] = nil
  end
  ffi.C.printf(cjson.encode(message) .. "\n")
end

return StdoutLogHandler
