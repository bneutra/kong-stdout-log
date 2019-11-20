# stdout-log kong plugin

## Background
Customized kong container (see Dockerfile for how we install the plugin). Oddly, Kong has no such plugin. file-log plugin (https://docs.konghq.com/hub/kong-inc/file-log/) warns of being blocking. Right now we just use the nginx access logs (set KONG_PROXY_ACCESS_LOG=/dev/stdout) but that doesn't have detailed info that the kong object has.

I started with https://github.com/edenlabllc/kong-plugin-stdout-log/blob/master/kong/plugins/stdout-log/handler.lua
which uses a builtin "print" which basically goes to the nginx logger. This seems like the "right" thing to do (in terms of using a known good method call for logging in nginx) but it does stuff we don't want: logs to the nginx error log, and logs a bunch of non-json cruft around the json string.

So, I landed on using a method of making a C lib funtion from within lua (printf) and it does the right thing.

TODO:
- does this approach block?  (lua making a system call within the context of nginx)
- will log events be output "atomicly" i.e. make sure events get mixed together on the same line
- rather than hard coding the "masking" of PII or extraneous info, could it be a plugin configration (see std-out/schema.lua)
- turn the plugin itself into its own repo (that can be used by anyone)


## Testing it
```
docker build -t kong:latest .

docker run -e "KONG_LUA_PACKAGE_PATH=/plugins/?.lua" -e KONG_PLUGINS=bundled,stdout-log  -e KONG_PROXY_ERROR_LOG=/dev/stderr -e KONG_PROXY_ACCESS_LOG=/dev/null -e KONG_DATABASE=off -e KONG_DECLARATIVE_CONFIG=/etc/kong/kong_declarative.yml -p 8000:8000 -it kong:latest 
```

Then you can make a request and see it logged:
```
curl localhost:8000/health -H "Authorization: Bearer 123"
```
