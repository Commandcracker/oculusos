-- Get file to cat
local tArgs = { ... }
if #tArgs == 0 then
	print( "Usage: cat <path>" )
	return
end

-- Error checking
local sPath = shell.resolve(tArgs[1])
local bReadOnly = fs.isReadOnly(sPath)
if fs.exists(sPath) and fs.isDir(sPath) then
	printError("Cannot cat a directory.")
	return
end

if fs.exists( sPath ) then
    local file = fs.open( sPath, "rb" )
    print(file.readAll())
    file.close()
else
    printError("File not found")
    return
end
