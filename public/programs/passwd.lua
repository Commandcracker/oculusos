-- Functions
local passwd_path = "/oculusos/passwd"

if not fs.exists( passwd_path ) then
    file = fs.open(passwd_path, 'a')
    file.writeLine('')
    file:close()
end

local function read_file(path)
    if fs.exists( path ) then
        local file = io.open( path, "r" )
        local sLine = file:read()
        file:close()
        return sLine
    end
end

local function write_file(path, line)
    if fs.exists( path ) then
        file = fs.open(path, 'w')
        file.writeLine(line)
        file:close()
    end
end

local passwd = read_file(passwd_path)

print("Changing password for root.")
term.write("Current Password: ")
input = read('*')

if input == passwd then
    term.write("New Password: ")
    input = read('*')
    write_file(passwd_path, input)
    print("Password Changed")
else
    print("Incorrect password!")
end
