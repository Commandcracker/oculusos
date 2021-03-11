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
# Third Party
**Libraries**
- [AES Lua](https://github.com/SquidDev-CC/aeslua)
- [Base64](https://pastebin.com/QYvNKrXE)
- [Big Font](https://pastebin.com/3LfWxRWh)
- [cPrint](https://pastebin.com/2sxYu2Mq)
- [CryptoNet](https://github.com/SiliconSloth/CryptoNet)
- [Frame Buffer](https://github.com/lyqyd/framebuffer)
- [Json](https://pastebin.com/4nRg9CHU)
- [SHA-256](https://pastebin.com/gsFrNjbt)

**Programms**
- [Matrix](https://pastebin.com/KQjmtASU)
- [Mirror](http://pastebin.com/DW3LCC3L)
- [Net Shell/NSH/SSH](https://pastebin.com/X5Fysdi4)
