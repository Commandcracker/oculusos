local tArgs = { ... }
if #tArgs == 0 then
	print( "Usage: display <file>" )
	return
end

local sPath = shell.resolve( tArgs[1] )
if fs.exists( sPath ) and fs.isDir( sPath ) then
	printError( "Cannot display a directory." )
	return
end

if fs.exists( sPath ) then
    paintutils.drawImage(paintutils.loadImage(sPath), 1, 1)
else
    printError( "file not found" )
    return
end

while true do 
    local event = os.pullEvent()
    if event == "mouse_click" or event == "key" or event == "paste" or event == "char" then
        term.clear()
        term.setCursorPos(1,1)
        return
    end
end
