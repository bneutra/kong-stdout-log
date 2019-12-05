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

function filterSerializedFields(serialized, conf)
  local filtered_fields = {}

  for field, value in pairs(serialized) do
    for _, allowed_field in pairs(conf.allowed_fields) do
      if field == allowed_field then
        if field == "request" then
          filtered_fields["request"] = {}
          for request_field, request_value in pairs(value) do
            for _, allowed_request_field in pairs(conf.allowed_request_fields) do
              if allowed_request_field == request_field then
                if request_field == "headers" then
                  filtered_fields["request"]["headers"] = {}
                  for header, header_value in pairs(request_value) do
                    for _, allowed_header in pairs(conf.allowed_request_headers) do
                      if header == allowed_header then
                        filtered_fields[field][request_field][header] = header_value
                      end
                    end
                  end
                elseif request_field == "querystring" then
                  filtered_fields["request"]["querystring"] = {}
                  for querystring_field, querystring_value in pairs(request_value) do
                    for _, allowed_querystring_field in pairs(conf.allowed_request_querystring_fields) do
                      if querystring_field == allowed_querystring_field then
                        filtered_fields[field][request_field][querystring_field] = querystring_value
                      end
                    end
                  end
                else
                  filtered_fields["request"][request_field] = request_value
                end
              end
            end
          end

        elseif field == "response" then
          filtered_fields["response"] = {}
          for response_field, response_value in pairs(value) do
            for _, allowed_response_field in pairs(conf.allowed_response_fields) do
              if allowed_response_field == response_field then
                if response_field == "headers" then
                  filtered_fields["response"]["headers"] = {}
                  for header, header_value in pairs(response_value) do
                    for _, allowed_header in pairs(conf.allowed_response_headers) do
                      if header == allowed_header then
                        filtered_fields[field][response_field][header] = header_value
                      end
                    end
                  end
                else
                  filtered_fields["response"][response_field] = response_value
                end
              end
            end
          end
        elseif field == "latencies" then
          filtered_fields["latencies"] = {}
          for latencies_field, latencies_value in pairs(value) do
            for _, allowed_latencies_field in pairs(conf.allowed_latencies_fields) do
              if allowed_latencies_field == latencies_field then
                filtered_fields["latencies"][latencies_field] = latencies_value
              end
            end
          end
        else
          filtered_fields[field] = value
        end
      end
    end
  end

  return filtered_fields
end

function StdoutLogHandler:log(conf)
  StdoutLogHandler.super.log(self)
  local message = filterSerializedFields(basic_serializer.serialize(ngx), conf)

  io.stdout:write(cjson.encode(message) .. "\n")
end

return StdoutLogHandler
