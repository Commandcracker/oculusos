local args = {...}

if not args[1] then
    print("Usage: which <program>")
    return
end

local path = shell.resolveProgram(args[1])

if path then
    print("/"..path)
else
    printError(args[1].." not found")
end
