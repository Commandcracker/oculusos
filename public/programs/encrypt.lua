print("This Program is not completed!")
return

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

local in_file = {}
local out_file = {}
local encrypt = {}
local sLine = {}

local function encrypt_file(file, key)
    print(file)

    if string.find(file, ".crypt") then
        print(file)
        print("is already encrypted")
        if not question("Continue") then
            return
        end
    end

    local in_file = io.open( file, "r" )
    
    sLine = in_file:read()
    i = 0
    while sLine do
        
        encrypt = aes.encrypt(key, sLine, aes.AES256, aes.CBCMODE)
        if encrypt then
            out_file = io.open( file..".crypt", "w+" )
            out_file:write(base64.encode(encrypt), "\n")
            out_file:close()
            out_file = nil
        else
            print("faild")
        end
        sLine = in_file:read()
        print(i)
        i = i+ 1
    end
    in_file:close()
end

local function loop(path, key)
    for k, v in pairs( fs.list( path ) ) do
        local v_path = path..'/'..v
        if fs.isDir( v_path ) then
            loop(v_path, key)
        else
            encrypt_file(v_path, key)
        end
    end
end

local tArgs = { ... }
if #tArgs < 2 then
	print( "Usage: encrypt <path> <passwd>" )
	return
end

loop(shell.resolve(tArgs[1]), tArgs[2])
