-- TODO: could we have a config to enumerate fields we want to log?
-- https://docs.konghq.com/1.3.x/plugin-development/plugin-configuration/
return {
    no_consumer = true, -- this plugin will only be API-wide,
    fields = {
        -- Describe your plugin's configuration's schema here.
    },
    self_check = function(schema, plugin_t, dao, is_updating)
        -- perform any custom verification
         return true
    end
}
