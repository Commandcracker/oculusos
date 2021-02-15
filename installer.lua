-- Variables
local url = "https://raw.githubusercontent.com/Commandcracker/oculusos/master/"
local installation_path = "/oculusos"
local tArgs = { ... }

-- Functions
local function get(url)
    local response = http.get( url )
    if not response then
        return nil
    end

    local sResponse = response.readAll()
    response.close()
    return sResponse
end

local function download(url, path)
    local res = get(url)
    if res then
        local file = fs.open(path, "w" )
        file.write(res)
        file.close()
        print(path)
    end
end

local function question(question)
    if question == nil then else
        if term.isColor() then
            term.setTextColour(colors.orange)
        end
        term.write(question.."? [")
        if term.isColor() then
            term.setTextColour(colors.lime)
        end
        term.write('Y')
        if term.isColor() then
            term.setTextColour(colors.orange)
        end
        term.write('/')
        if term.isColor() then
            term.setTextColour(colors.red)
        end
        term.write('n')
        if term.isColor() then
            term.setTextColour(colors.orange)
        end
        term.write("] ")
        term.setTextColour(colors.white)
    end
    local input = string.lower(string.sub(read(),1,1))
    if input == 'y' or input == 'j' or input == '' then
        return true
    else 
        return false
    end
end

function split(string, delimiter)
    local result = { }
    local from = 1
    local delim_from, delim_to = string.find( string, delimiter, from )
    while delim_from do
        table.insert( result, string.sub( string, from , delim_from-1 ) )
        from = delim_to + 1
        delim_from, delim_to = string.find( string, delimiter, from )
    end
    table.insert( result, string.sub( string, from ) )
    return result
end

-- Run
term.clear()
term.setCursorPos(1,1)

if tArgs[1] then
    _question = "Update OculusOS"
else
    _question = "Install OculusOS"
end

if question(_question) then else
    if term.isColor() then
        term.setTextColour(colors.red)
    end
    print("Abort.")
    term.setTextColour(colors.white)
    return
end

-- Download
print()
if term.isColor() then
    term.setTextColour(colors.lime)
end
print("Downloading")
if term.isColor() then
    term.setTextColour(colors.blue)
end
print()

local to_download = {}

-- .shellrc

if not fs.exists( ".shellrc" ) then
    table.insert(to_download,function()
        download(url..".shellrc.lua", "/.shellrc")
    end)
end

-- Bootscreen
local bootscreen = "bootscreen/"

if turtle then
    bootscreen = bootscreen.."turtle/"
else
    if pocket then
        bootscreen = bootscreen.."pocket/"
    else
        bootscreen = bootscreen.."computer/"
    end
end

if term.isColor() then
    bootscreen = bootscreen.."colord.nfp"
else
    bootscreen = bootscreen.."default.nfp"
end

table.insert(to_download,function()
    download(url..bootscreen, "/.bootscreen")
end)

-- Startup
table.insert(to_download,function()
    download(url.."startup.lua", "/startup")
end)

-- Programs - fix
if not fs.exists("/rom/programs/http/wget") then
    table.insert(to_download,function()
        download(url .. "fix/wget.lua", "/bin/wget")
    end)
end

if tonumber(split(os.version(), ' ')[2]) <= 1.7 then
    table.insert(to_download,function()
        download(url .. "fix/pastebin.lua", "/bin/pastebin")
    end)
end

parallel.waitForAll(
    -- Startup
    function()
        for item in get(url.."boot/index"):gmatch("([^\n]*)\n?") do
            table.insert(to_download,function()
                download(url .. "boot/"..item..".lua", "/boot/"..item)
            end)
        end
    end,
    -- APIS
    function()
        for item in get(url.."lib/index"):gmatch("([^\n]*)\n?") do
            table.insert(to_download,function()
                download(url .. "lib/"..item..".lua", "/lib/"..item)
            end)
        end
    end,
    -- bin
    function()
        for item in get(url.."bin/index"):gmatch("([^\n]*)\n?") do
            table.insert(to_download,function()
                download(url .. "bin/"..item..".lua", "/bin/"..item)
            end)
        end
    end,
    -- bin - not_pocket
    function()
        if not pocket then
            for item in get(url.."bin/not_pocket/index"):gmatch("([^\n]*)\n?") do
                table.insert(to_download,function()
                    download(url .. "bin/not_pocket/"..item..".lua", "/bin/not_pocket/"..item)
                end)
            end
        end
    end
)

-- version
table.insert(to_download,function()
    download(url..".version", "/.version")
end)

parallel.waitForAll(table.unpack(to_download))

-- Finished
print()
if not tArgs[1] and settings and not pocket then
    settings.set("shell.allow_disk_startup", false)
    settings.save()
end

term.setTextColour(colors.white)
if question("Reboot now") then
    print()
    if term.isColor() then
        term.setTextColor(colors.orange)
    end
    print("Rebooting computer")
    sleep(3)
    os.reboot()
end
