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
        term.write(question.."? [Y/n] ")
    end
    local input = string.lower(string.sub(read(),1,1))
    if input == "y" or input == "j" or input == "" then
        return true
    else 
        return false
    end
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
    return
end

-- Download
print()
print("Downloading")
print()

local to_download = {}

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
    download(url..bootscreen, installation_path.."/bootscreen")
end)

parallel.waitForAll(table.unpack({
    -- Startup
    function()
        for item in get(url.."startup/index"):gmatch("([^\n]*)\n?") do
            table.insert(to_download,function()
                download(url .. "startup/"..item..".lua", "/startup/"..item)
            end)
        end
    end,
    -- APIS
    function()
        for item in get(url.."apis/index"):gmatch("([^\n]*)\n?") do
            table.insert(to_download,function()
                download(url .. "apis/"..item..".lua", installation_path.."/apis/"..item)
            end)
        end
    end,
    -- Programs
    function()
        for item in get(url.."programs/index"):gmatch("([^\n]*)\n?") do
            table.insert(to_download,function()
                download(url .. "programs/"..item..".lua", installation_path.."/programs/"..item)
            end)
        end
    end,
    -- Programs - http
    function()
        for item in get(url.."programs/http/index"):gmatch("([^\n]*)\n?") do
            table.insert(to_download,function()
                download(url .. "programs/http/"..item..".lua", installation_path.."/programs/http/"..item)
            end)
        end
    end,
    -- Programs - not_pocket
    function()
        if not pocket then
            for item in get(url.."programs/not_pocket/index"):gmatch("([^\n]*)\n?") do
                table.insert(to_download,function()
                    download(url .. "programs/not_pocket/"..item..".lua", installation_path.."/programs/not_pocket/"..item)
                end)
            end
        end
    end
}))

-- version
table.insert(to_download,function()
    download(url.."version", installation_path.."/version")
end)

parallel.waitForAll(table.unpack(to_download))

-- Finished
print()
if not tArgs[1] and settings and not pocket then
    settings.set("shell.allow_disk_startup", false)
    settings.save()
end

if question("Reboot now") then
    print()
    if term.isColor() then
        term.setTextColor(colors.yellow)
    end
    print("Rebooting computer")
    sleep(3)
    os.reboot()
end
