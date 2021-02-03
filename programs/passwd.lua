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

local password_path = shell.resolve("/oculusos/.passwd")

if fs.exists( password_path ) then
    term.write("Current Password: ")
    local passwd = read('*')
    if not sha256.sha256(passwd) == read_file(password_path) then
        printError("Incorrect password!")
        return
    end
end

term.write("New Password: ")
local new_passwd = read('*')
if string.len(new_passwd) < 4 then
    printError("Password must be 4 characters or more")
    return
end

term.write("Repet Password: ")
local repet_passwd = read('*')
if new_passwd == repet_passwd then
    write_file(password_path, sha256.sha256(repet_passwd))
    printError("Password Changed")
else
    printError("Password does not match")
end
