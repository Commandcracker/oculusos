if not http then
    printError("curl requires the http API")
    printError("Set http_enable to true in ComputerCraft.cfg")
    return
end

local function printUsage()
    print( "Usage:" )
    print( "curl <url>" )
end

local tArgs = { ... }
if #tArgs < 1 then
    printUsage()
    return
end

local function get(url)
    local response = http.get(url)
    if response then
        local sResponse = response.readAll()
        print(sResponse)
    else
        printError( "Failed." )
    end
end

get(tArgs[1])