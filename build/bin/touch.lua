local a={...}if#a==0 then print("Usage: touch <path>")return end;local b=shell.resolve(a[1])if not fs.isReadOnly(b)then file=fs.open(b,'a')file.writeLine('')file:close()return else if fs.isDir(b)then printError("folder is read only")else printError("file is read only")end end