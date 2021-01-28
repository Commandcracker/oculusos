print("This Program is not completed!")
return

local function read_file(path)
    if fs.exists( path ) then
        local file = fs.open( path, "r" )
        local sLine = file.readAll()
        file.close()
        return sLine
    end
end

local function write_file(path, line)
    file = fs.open(path, 'w')
    file.write(line)
    file:close()
end

local function question(question)
    if question == nil then else
        term.write(question.."? [Y/n] ")
    end
    local input = string.lower(string.sub(read(),1,1))
    if input == "y" or input == "j" or input == "" then
        return true
    else 
        return false
    end
end

local function decrypt_file(key, file)
    if not string.find(file, ".crypt") then
        print(file)
        print("is already decrypted")
        if not question("Continue") then
            return
        end
    end

    local decrypt = aes.decrypt(key, read_file(file), aes.AES256, aes.CBCMODE)
    if decrypt then
        write_file(string.gsub(file, ".crypt", ''), decrypt)
        fs.delete(file)
        print("decrypted: " .. file)
    else
        print("decryption Faild: " .. file)
    end
end

local function do_4files(path, key)
    for k, v in pairs( fs.list( path ) ) do
        local v_path = path..'/'..v
        if fs.isDir( v_path ) then
            do_4files(v_path, key)
        else
            decrypt_file(key, v_path)
        end
    end
end

local tArgs = { ... }
if #tArgs < 2 then
	print( "Usage: decrypt <path> <passwd>" )
	return
end

do_4files(shell.resolve(tArgs[1]), tArgs[2])
