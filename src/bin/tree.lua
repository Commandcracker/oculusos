local currentPath = shell.resolve(".")
local tArgs = { ... }

local function listDir( path, prefix )
    if path == "" then path = "\\" end
    
    for k, v in pairs( fs.list( path ) ) do
        local current = path.."\\"..v

        term.write(prefix.."-- ")

        if term.isColor() and fs.isDir( current ) then
            term.setTextColour(colors.blue)
        end

        print(v)
        term.setTextColour(colors.white)

        if fs.isDir( current ) then 
            listDir( current, prefix.."   |" )
        end

    end
end

if #tArgs > 0 then
    currentPath = shell.resolve(tArgs[1])
end

if term.isColor() then
    term.setTextColour(colors.blue)
else
    term.setTextColour(colors.white)
end
print( '/'..currentPath )
term.setTextColour(colors.white)
listDir( currentPath, "|" )
