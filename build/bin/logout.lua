local a=os.pullEvent;os.pullEvent=os.pullEventRaw;local function b(c)if fs.exists(c)then local d=io.open(c,"r")local e=d:read()d:close()return e end end;if fs.exists("/.passwd")then term.setBackgroundColor(colors.black)term.clear()term.setCursorPos(1,1)while true do term.write("Password: ")input=read('*')if sha256.sha256(input)==b("/.passwd")then break else printError("Incorrect password!")end end else printError("No password has been set")end;os.pullEvent=a