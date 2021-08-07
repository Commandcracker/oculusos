-- Global Variables
local oldOsPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local function read_file(path)
    if fs.exists( path ) then
        local file = io.open( path, "r" )
        local sLine = file:read()
        file:close()
        return sLine
    end
end

-- Main
if fs.exists( "/.passwd" ) then
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1,1)
	while true do
		term.write("Password: ")
		input = read('*')
		if sha256.sha256(input) == read_file("/.passwd") then
			break
		else
			printError("Incorrect password!")
		end
	end
else
	printError("No password has been set")
end

os.pullEvent = oldOsPullEvent