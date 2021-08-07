local function read_file(path)
    if fs.exists( path ) then
        local file = io.open( path, "r" )
        local sLine = file:read()
        file:close()
        return sLine
    end
end

local function get(url)
    local request, err = http.get(url)
    if request then
		local response = request.readAll()
        request.close()
		return response
    else
        printError("Faild to get: "..url)
        printError(err)
		error()
    end
end

if not http then
    printError("do-release-upgrade requires the http API")
    printError("Set http_enable to true in ComputerCraft.cfg")
    error()
end

print("Checking for a new OculusOS release")

local system_info = json.decode(read_file("/.system_info"))
local data = json.decode(get("https://api.github.com/repos/"..system_info.git.owner..'/'..system_info.git.repo.."/git/refs/heads/"..system_info.git.branch))

if data.message then
	printError("GitHub returned the error: "..data.message)
	error()
end

if system_info.git.commit == data.object.sha then
    printError("There is no new OculusOS release")
else
    print("New OculusOS release Found")

    local url_full = "https://raw.githubusercontent.com/"..system_info.git.owner..'/'..system_info.git.repo..'/'..system_info.git.branch.."/build/installer.lua"
    local tArgs = {"Update"}
    local func, err = load(get(url_full), url_full, "t", _ENV)

    if not func then
        printError( err )
        return
    end

    local success, msg = pcall(func, table.unpack(tArgs, 1))

    if not success then
        printError( msg )
    end
end
