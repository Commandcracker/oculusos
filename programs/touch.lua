-- Get file to touch
local tArgs = { ... }
if #tArgs == 0 then
	print( "Usage: touch <path>" )
	return
end

-- Error checking
local sPath = shell.resolve( tArgs[1] )
if not fs.isReadOnly( sPath ) then
    file = fs.open(sPath, 'a')
    file.writeLine('')
    file:close()
    return
else
    if fs.isDir( sPath ) then
        printError("folder is read only")
    else
        printError("file is read only")
    end
end
