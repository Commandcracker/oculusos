# OculusOS
OculusOS is a lua os for the minecraft mod ComputerCraft and ComputerCraft Tweaked
# Fix for ComputerCraft
## **ComputerCraft 1.77**
Pastebin
```
wget https://pastebin.com/raw/KVPtqp0H pastebin
```
Gitlab
```
wget https://raw.githubusercontent.com/Commandcracker/oculusos/master/fix/pastebin.lua pastebin
```
## **ComputerCraft 1.76-**
Pastebin
```lua
lua
local r = http.get("https://pastebin.com/raw/ipMnQCQs"); local f = fs.open( shell.resolve( "wget" ), "w" ); f.write( r.readAll() ); f.close(); r.close()
exit()
wget https://pastebin.com/raw/KVPtqp0H pastebin
```
Gitlab
```lua
lua
local r = http.get("https://raw.githubusercontent.com/Commandcracker/oculusos/master/fix/wget.lua"); local f = fs.open( shell.resolve( "wget" ), "w" ); f.write( r.readAll() ); f.close(); r.close()
exit()
wget https://raw.githubusercontent.com/Commandcracker/oculusos/master/fix/pastebin.lua pastebin
```
# Installation
Pastebin
```
pastebin run cCENE9mc
```
Gitlab
```
wget https://raw.githubusercontent.com/Commandcracker/oculusos/master/installer.lua installer
installer
```
