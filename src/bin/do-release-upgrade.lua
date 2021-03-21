local function read_file(path)
    if fs.exists( path ) then
        local file = io.open( path, "r" )
        local sLine = file:read()
        file:close()
        return sLine
    end
end

local function get(url)
    local response = http.get( url )
    if not response then
        return nil
    end

    local sResponse = response.readAll()
    response.close()
    return sResponse
end

if http then
    print("Checking for a new OculusOS release")

    local system_info = json.decode(read_file("/.system_info"))
    local latest = json.decode(get("https://api.github.com/repos/"..system_info.git.owner..'/'..system_info.git.repo.."/git/refs/heads/"..system_info.git.branch)).object.sha
    local current = system_info.git.commit

    if current == latest then
        printError("There is no new OculusOS release")
    else
        print("new OculusOS release Found")

        local url_full = "https://raw.githubusercontent.com/"..system_info.git.owner..'/'..system_info.git.repo..'/'..system_info.git.branch.."/build/installer.lua"
        local tArgs = {
            "Update"
        }
        local res = get(url_full)
        
        if res then
            local func, err = load(res, url_full, "t", _ENV)
            if not func then
                printError( err )
                return
            end
            local success, msg = pcall(func, table.unpack(tArgs, 1))
            if not success then
                printError( msg )
            end
        end
    end
else
    printError("do-release-upgrade requires the http API")
    printError("Set http_enable to true in ComputerCraft.cfg")
    return
end
