-- Global Variables
oldOsPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local function read_file(path)
    if fs.exists( path ) then
        local file = io.open( path, "r" )
        local sLine = file:read()
        file:close()
        return sLine
    end
end

os.loadAPI("/oculusos/apis/sha256")

-- Main
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)

if fs.exists( "/oculusos/.passwd" ) then
	while true do
		term.write("Password: ")
		input = read('*')
		if sha256.sha256(input) == read_file("/oculusos/.passwd") then
			break
		else
			print("Incorrect password!")
		end
	end
end

os.unloadAPI("sha256")
os.pullEvent = oldOsPullEvent