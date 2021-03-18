# OculusOS
OculusOS is a Linux like OS's for the minecraft mod ComputerCraft and ComputerCraft Tweaked
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
- [AES Lua](https://github.com/SquidDev-CC/aeslua) by [SquidDev](https://github.com/SquidDev)
- [Base64](https://pastebin.com/QYvNKrXE)
- [Big Font](https://pastebin.com/3LfWxRWh) by [Wojbie](https://pastebin.com/u/Wojbie)
- [cPrint](https://pastebin.com/2sxYu2Mq) by [Jesusthekiller](https://pastebin.com/u/jesusthekiller)
- Modified [CryptoNet](https://github.com/SiliconSloth/CryptoNet) by [SiliconSloth](https://github.com/SiliconSloth)
- [Frame Buffer](https://github.com/lyqyd/framebuffer) by [lyqyd](https://github.com/lyqyd)
- [Json](https://pastebin.com/4nRg9CHU) by [ElvishJerricco](https://pastebin.com/u/ElvishJerricco)
- [SHA-256](https://pastebin.com/gsFrNjbt) by [GravityScore](https://pastebin.com/u/GravityScore)
- Parts from [metis](https://github.com/SquidDev-CC/metis) by [SquidDev](https://github.com/SquidDev)

**Programms**
- [Matrix](https://pastebin.com/KQjmtASU) by [Felix Maxwell](https://pastebin.com/u/felixmaxwell)
- [Mirror](http://pastebin.com/DW3LCC3L) by [Wojbie](https://pastebin.com/u/Wojbie)
- Modified [Net Shell/NSH](https://pastebin.com/X5Fysdi4) by [lyqyd](https://github.com/lyqyd)
- Modified [mbs/Mildly better shell](https://github.com/SquidDev-CC/mbs) by [SquidDev](https://github.com/SquidDev)
