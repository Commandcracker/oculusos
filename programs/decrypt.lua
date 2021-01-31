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

local function decrypt_file(file, key)
    print(file)

    if not string.find(file, ".crypt") then
        print("is already decrypted")
        if not question("Continue") then
            return
        end
    end

    local in_file = io.open( file, "r" )
    local sLine = in_file:read()
    local out_file = fs.open( string.gsub(file, ".crypt", ''), "w" )

    while sLine do
        out_file.flush()
        in_file:flush()

        if sLine == nil or sLine:match("%S") == nil then
            out_file.writeLine()
        else
            local decrypt = aes.decrypt(key, base64.decode(sLine), aes.AES256, aes.CBCMODE)
            if decrypt then
                out_file.writeLine(decrypt)
            else
                print("faild")
            end
        end

        sLine = in_file:read()
    end
    out_file.close()
    in_file:close()
    fs.delete(file)
end

local function loop(path, key)
    if fs.isDir( path ) then
        for k, v in pairs( fs.list( path ) ) do
            local v_path = path..'/'..v
            if fs.isDir( v_path ) then
                loop(v_path, key)
            else
                decrypt_file(v_path, key)
            end
        end
    else
        decrypt_file(path, key)
    end
end

local tArgs = { ... }
if #tArgs < 2 then
	print( "Usage: decrypt <path> <passwd>" )
	return
end

loop(shell.resolve(tArgs[1]), tArgs[2])
