-- Pc Check
local w,h = term.getSize()
if w == 51 and h == 19 then
	pc = true
else
	pc = false
end

local function get(url)

    local ok, err = http.checkURL( url )
    if not ok then
        if err then
            printError( err )
        end
        return nil
    end

    local response = http.get( url )
    if not response then
        return nil
    end

    local sResponse = response.readAll()
    response.close()
    return sResponse
end

local function download(url, path)
    local res = get( url )
    if res then
        local file = fs.open( path, "w" )
        file.write( res )
        file.close()

        print( "Downloaded " .. path )
    end
end

local url = "https://commandcracker.gitlab.io/oculusos/"

--other suff idk
term.clear()
term.setCursorPos(1,1)

term.write("Reading package lists")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(" Done")
print()
sleep(0.1)
print("Building dependency tree")
sleep(0.1)
term.write("Reading state information")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(" Done")
print()
sleep(0.1)

term.write("Do you want to continue? [Y/n] ")
local input = string.lower(string.sub(read(),1,1))


if input == "y" or input == "j" or input == "" then
else
	print("Abort.")
end

local oculusos = shell.resolve( "/oculusos" )
fs.makeDir( oculusos )

local file = oculusos .. "/bootscreen.nfp"

if term.isColor() then
	if pc == true then
		download(url .. "bootscreen/bootscreen_Color.nfp", file)
	else
		download(url .. "bootscreen/bootscreen_Turtle_Color.nfp", file)
	end
else
	if pc == true then
		download(url .. "bootscreen/bootscreen_Turtle.nfp", file)
	else
		download(url .. "bootscreen/bootscreen.nfp", file)
	end
end

download(url .. "startup.lua", "startup")
download(url .. "register_programs.lua", "register_programs")

local programs = shell.resolve( oculusos .. "/programs" )
fs.makeDir( programs )

download(url .. "programs/matrix.lua", programs .. "/matrix.lua")
download(url .. "programs/cat.lua", programs .. "/cat.lua")
download(url .. "programs/touch.lua", programs .. "/touch.lua")
download(url .. "programs/pwd.lua", programs .. "/pwd.lua")
download(url .. "programs/shell.lua", programs .. "/shell.lua")
download(url .. "programs/tree.lua", programs .. "/tree.lua")
download(url .. "programs/echo.lua", programs .. "/echo.lua")

local http_path = shell.resolve( programs .. "/http" )
fs.makeDir( http_path )

download(url .. "programs/http/curl.lua", http_path .. "/curl.lua")

print()

if term.isColor() then
	term.setTextColor(colors.yellow)
end

print("Rebooting computer")

sleep(3)

os.reboot()