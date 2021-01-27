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

local passwd = "toor"
local password_path = "/oculusos/passwd"

if fs.exists( password_path ) then
    passwd = read_file(password_path)
end

-- Main
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
while true do
	term.write("oculusos login: ")
	input = read()
	if input == "root" then
		term.write("Password: ")
		input = read('*')
		if input == passwd then
			os.pullEvent = oldOsPullEvent
			return
		else
			print("Incorrect password!")
		end
	else
		print("User Not Found!")
	end
end

