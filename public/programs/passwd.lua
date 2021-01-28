-- Functions
local function read_file(path)
    if fs.exists( path ) then
        local file = io.open( path, "r" )
        local sLine = file:read()
        file:close()
        return sLine
    end
end

local function write_file(path, line)
    file = fs.open(path, 'w')
    file.writeLine(line)
    file:close()
end

local passwd = "toor"
local password_path = shell.resolve("/oculusos/.passwd")

print("Changing password for root.")
term.write("Current Password: ")
input = read('*')

if fs.exists( password_path ) then
    passwd = read_file(password_path)
    input = sha256.sha256(input)
end

if input == passwd then
    term.write("New Password: ")
    input = read('*')
    if input == "" or string.len(input) < 4 then
        print("Password must be 4 characters or more")
    else
        write_file(password_path, sha256.sha256(input))
        print("Password Changed")
    end
else
    print("Incorrect password!")
end
