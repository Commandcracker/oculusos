-- Get file to cat
local tArgs = { ... }
if #tArgs == 0 then
	print( "Usage: cat <path>" )
	return
end

-- Error checking
local sPath = shell.resolve( tArgs[1] )
local bReadOnly = fs.isReadOnly( sPath )
if fs.exists( sPath ) and fs.isDir( sPath ) then
	printError( "Cannot cat a directory." )
	return
end

if fs.exists( sPath ) then
    local file = io.open( sPath, "r" )
    local sLine = file:read()
    print(sLine)
    while sLine do
        sLine = file:read()
        if sLine then
            print(sLine)
        end
    end
    file:close()
else
    printError( "file not found" )
    return
end
