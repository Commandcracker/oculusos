# OculusOS

OculusOS is a unix like OS for the minecraft mod ComputerCraft and ComputerCraft Tweaked

## Installation

### ComputerCraft 1.78+ and ComputerCraft Tweaked

```bash
pastebin run cCENE9mc
```

### ComputerCraft 1.77

```bash
wget https://raw.githubusercontent.com/Commandcracker/oculusos/master/build/installer.lua installer
installer
```

### ComputerCraft 1.76-

```lua
lua
local a=http.get("https://raw.githubusercontent.com/Commandcracker/oculusos/master/build/installer.lua")local b=fs.open(shell.resolve("installer"),"w")b.write(a.readAll())b.close()a.close()exit()
installer
```

## Third Party

### Libraries

| Modified | Parts | Library                                                | Maintainer                                              |
|----------|-------|--------------------------------------------------------|---------------------------------------------------------|
|          |       | [AES Lua](https://github.com/SquidDev-CC/aeslua)       | [SquidDev](https://github.com/SquidDev)                 |
|          |       | [Base64](https://pastebin.com/QYvNKrXE)                |                                                         |
|          |       | [Big Font](https://pastebin.com/3LfWxRWh)              | [Wojbie](https://pastebin.com/u/Wojbie)                 |
|          |       | [cPrint](https://pastebin.com/2sxYu2Mq)                | [Jesusthekiller](https://pastebin.com/u/jesusthekiller) |
| X        |       | [CryptoNet](https://github.com/SiliconSloth/CryptoNet) | [SiliconSloth](https://github.com/SiliconSloth)         |
|          |       | [Frame Buffer](https://github.com/lyqyd/framebuffer)   | [lyqyd](https://github.com/lyqyd)                       |
|          |       | [Json](https://pastebin.com/4nRg9CHU)                  | [ElvishJerricco](https://pastebin.com/u/ElvishJerricco) |
|          |       | [SHA-256](https://pastebin.com/gsFrNjbt)               | [GravityScore](https://pastebin.com/u/GravityScore)     |
|          | X     | [metis](https://github.com/SquidDev-CC/metis)          | [SquidDev](https://github.com/SquidDev)                 |

### Programms

| Modified | Program                                                       | Maintainer                                           |
|----------|---------------------------------------------------------------|------------------------------------------------------|
|          | [Matrix](https://pastebin.com/KQjmtASU)                       | [Felix Maxwell](https://pastebin.com/u/felixmaxwell) |
| X        | [Net Shell/NSH](https://pastebin.com/X5Fysdi4)                | [lyqyd](https://github.com/lyqyd)                    |
| X        | [mbs/Mildly better shell](https://github.com/SquidDev-CC/mbs) | [SquidDev](https://github.com/SquidDev)              |

## Building

### Requirements

You need to have [Node.js](https://nodejs.org) Installed. \
Then run this command to install [luamin](https://github.com/mathiasbynens/luamin).

```bash
npm install luamin
```

### Running the build process

```bash
node build
```
