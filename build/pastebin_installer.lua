if not http then printError("oculusos requires the http API")printError("Set http_enable to true in ComputerCraft.cfg")return end;local function a(b)local c=http.get(b)if c then local d=c.readAll()c.close()return d else print("Failed.")end end;local b="https://raw.githubusercontent.com/Commandcracker/oculusos/master/build/installer.lua"local e={...}local f=a(b)if f then local g,h=load(f,b,"t",_ENV)if not g then printError(h)return end;local i,j=pcall(g,table.unpack(e,1))if not i then printError(j)end end