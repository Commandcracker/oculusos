-- https://gitlab.com/Commandcracker/oculusos
if not http then
    printError("oculusos requires the http API")
    printError("Set http_enable to true in ComputerCraft.cfg")
    return
end

local function get(url)
    local response = http.get(url)
    
    if response then
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        print( "Failed." )
    end
end

url = "https://commandcracker.gitlab.io/oculusos/installer.lua"

local res = get(url)
if res then
    local func, err = load(res, url, "t", _ENV)
    if not func then
        printError( err )
        return
    end
    local success, msg = pcall(func, table.unpack(tArgs, 3))
    if not success then
        printError( msg )
    end
end
