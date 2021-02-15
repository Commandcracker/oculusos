for _, sFile in ipairs(fs.list("/boot")) do
    if string.sub(sFile, 1, 1) ~= "." then
        local sPath = "/boot" .. sFile
        if not fs.isDir(sPath) then
            shell.run(sPath)
        end
    end
end