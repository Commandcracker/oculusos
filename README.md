# OculusOS
OculusOS is a lua os for the minecraft mod ComputerCraft and ComputerCraft Tweaked
# Installation
**ComputerCraft 1.78+ and ComputerCraft Tweaked**
```
pastebin run cCENE9mc
```
**ComputerCraft 1.77**
```
wget https://raw.githubusercontent.com/Commandcracker/oculusos/master/installer.lua installer
installer
```
**ComputerCraft 1.76-**
```lua
lua
local r = http.get("https://raw.githubusercontent.com/Commandcracker/oculusos/master/installer.lua"); local f = fs.open( shell.resolve( "installer" ), "w" ); f.write( r.readAll() ); f.close(); r.close(); exit()
installer
```