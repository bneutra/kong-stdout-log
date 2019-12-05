local typedefs = require "kong.db.schema.typedefs"

-- TODO: could we have a config to enumerate fields we want to log?
-- https://docs.konghq.com/1.3.x/plugin-development/plugin-configuration/
return {
    name = "stdout-log",
    fields = {
        { consumer = typedefs.no_consumer, },
        { config = {
            type = "record",
            fields = {
                { allowed_fields = {
                    type = "array",
                    default = { },
                    elements = { type = "string" },
                }, },
                { allowed_request_fields = {
                    type = "array",
                    default = { },
                    elements = { type = "string" },
                }, },
                { allowed_response_fields = {
                    type = "array",
                    default = { },
                    elements = { type = "string" },
                }, },
                { allowed_latencies_fields = {
                    type = "array",
                    default = { },
                    elements = { type = "string" },
                }, },
                { allowed_request_headers = {
                    type = "array",
                    default = { },
                    elements = { type = "string" },
                }, },
                { allowed_response_headers = {
                    type = "array",
                    default = { },
                    elements = { type = "string" },
                }, },
                { allowed_request_querystring_fields = {
                    type = "array",
                    default = { },
                    elements = { type = "string" },
                }, },
            }, },
        },
    },
}
