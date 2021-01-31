local currentPath = shell.resolve(".")
local tArgs = { ... }

function listDir( path, prefix )
    if path == "" then path = "\\" end
    
    for k, v in pairs( fs.list( path ) ) do
        print( prefix.."-- "..v )

        local nextDir = path.."\\"..v
        if fs.isDir( nextDir ) then listDir( nextDir, prefix.."   |" ) end
    end
end

if #tArgs > 0 then
    currentPath = shell.resolve(tArgs[1])
end

print( "Listing Directory: /"..currentPath )
listDir( currentPath, "|" )
