-- https://docs.konghq.com/1.3.x/plugin-development/plugin-configuration/
local typedefs = require "kong.db.schema.typedefs"

local array_of_field_names = {
    type = "array",
    default = {},
    elements = { type = "string" },
}

return {
    name = "stdout-log",
    fields = {
        { consumer = typedefs.no_consumer, },
        { config = {
            type = "record",
            fields = {
                { allowed_fields = array_of_field_names, },
                { allowed_request_fields = array_of_field_names, },
                { allowed_request_headers = array_of_field_names, },
                { allowed_request_querystring_fields = array_of_field_names, },
                { allowed_response_fields = array_of_field_names, },
                { allowed_response_headers = array_of_field_names, },
                { allowed_latencies_fields = array_of_field_names, },
            },
        }, },
    },
}
