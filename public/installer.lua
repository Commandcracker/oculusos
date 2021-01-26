-- Variables
local url = "https://commandcracker.gitlab.io/oculusos/"
local installation_path = "/oculusos"

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

if question("Install OculusOS") then else
    if term.isColor() then
        term.setTextColour(colors.red)
    end
    print("Abort.")
    return
end

-- Hardware not supported Check
if pocket then
    if term.isColor() then
        term.setTextColour(colors.red)
    end

    print("Hardware not supported!")

    term.setTextColour(colors.white)

    if question("Continue") then else
        if term.isColor() then
            term.setTextColour(colors.red)
        end
        print("Abort.")
        return
    end
end

-- Download
print()
print("Downloading")
print()

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

download(url..bootscreen, installation_path.."/bootscreen")

-- Startup
for item in get(url.."startup/index"):gmatch("([^\n]*)\n?") do
    download(url .. "startup/"..item..".lua", installation_path.."/startup/"..item)
end
download(url.."register_programs.lua", "/register_programs")

-- APIS
for item in get(url.."apis/index"):gmatch("([^\n]*)\n?") do
    download(url .. "apis/"..item..".lua", installation_path.."/apis/"..item)
end

-- Programs
for item in get(url.."programs/index"):gmatch("([^\n]*)\n?") do
    download(url .. "programs/"..item..".lua", installation_path.."/programs/"..item)
end

for item in get(url.."programs/http/index"):gmatch("([^\n]*)\n?") do
    download(url .. "programs/http/"..item..".lua", installation_path.."/programs/http/"..item)
end

-- Finished
print()

if question("Reboot now") then
    print()
    if term.isColor() then
        term.setTextColor(colors.yellow)
    end
    print("Rebooting computer")
    sleep(3)
    os.reboot()
end
