for _, sFile in ipairs(fs.list("/oculusos/init")) do
    if string.sub(sFile, 1, 1) ~= "." then
        local sPath = "/oculusos/init/" .. sFile
        if not fs.isDir(sPath) then
            shell.run(sPath)
        end
    end
end