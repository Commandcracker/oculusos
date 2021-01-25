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
if pocket then
    term.setTextColour(colors.red)
    print("Hardware not supported!")
    return
end

term.clear()
term.setCursorPos(1,1)

if question("Install OculusOS") then else
    term.setTextColour(colors.red)
    print("Abort.")
    return
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
    bootscreen = bootscreen.."computer/"
end

if term.isColor() then
    bootscreen = bootscreen.."colord.nfp"
else
    bootscreen = bootscreen.."default.nfp"
end

download(url..bootscreen, installation_path.."/bootscreen")

-- Startup
download(url.."startup.lua", "/startup")
download(url.."register_programs.lua", "/register_programs")

-- Programs
for item in get(url.."programs/index"):gmatch("([^\n]*)\n?") do
    download(url .. "programs/"..item..".lua", installation_path.."/programs/"..item)
end

download(url.."programs/http/curl.lua", installation_path .."/programs/http/curl")

-- Finished
print()

if question("Reboot now") then
    print()
    term.setTextColor(colors.yellow)
    print("Rebooting computer")
    sleep(3)
    os.reboot()
end
