local tArgs = { ... }
if #tArgs == 0 then
	print( "Usage: display <file>" )
	return
end

local sPath = shell.resolve( tArgs[1] )
if fs.exists( sPath ) and fs.isDir( sPath ) then
	print( "Cannot display a directory." )
	return
end

if fs.exists( sPath ) then
    paintutils.drawImage(paintutils.loadImage(sPath), 1, 1)
else
    print( "file not found" )
    return
end

while true do 
    local event, key = os.pullEvent()
    if event == "key" then
        term.clear()
        term.setCursorPos(1,1)
        return
    end
end
