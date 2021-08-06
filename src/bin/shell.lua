local multishell = multishell
local parentShell = shell
local parent = term.current()

if multishell then
    multishell.setTitle(multishell.getCurrent(), "shell")
end

local Dir = (parentShell and parentShell.dir()) or ""
local Path = (parentShell and parentShell.path()) or ".:/rom/programs"
local Aliases = (parentShell and parentShell.aliases()) or {}
local CompletionInfo = (parentShell and parentShell.getCompletionInfo()) or {}

local running = true
local ProgramStack = {}

local shell = {}

local make_package
if fs.exists("rom/modules/main/cc/require.lua") then
    make_package = dofile("rom/modules/main/cc/require.lua").make
end

local function createShellEnv(dir)
    local env = {
        shell = shell,
        multishell = multishell,
        supports_scroll = _ENV.supports_scroll
    }
    if make_package then
        env.require, env.package = make_package(env, dir)
    end
    return env
end

-- Colours
local promptColour, textColour, bgColour
if term.isColour() then
    promptColour = colours.orange
    textColour = colours.white
    bgColour = colours.black
else
    promptColour = colours.white
    textColour = colours.white
    bgColour = colours.black
end

local supports_scroll = term.isColour()

if _ENV.supports_scroll ~= nil then
    supports_scroll = _ENV.supports_scroll
end

if supports_scroll then
    redirect = scroll_window.create(parent)
end

local function run(_sCommand, ...)
    local sPath = shell.resolveProgram(_sCommand)
    if sPath ~= nil then
        ProgramStack[#ProgramStack + 1] = sPath
        if multishell then
            local sTitle = fs.getName(sPath)
            if sTitle:sub(-4) == ".lua" then
                sTitle = sTitle:sub(1, -5)
            end
            multishell.setTitle(multishell.getCurrent(), sTitle)
        end
        local sDir = fs.getDir(sPath)
        local env = createShellEnv(sDir)
        env.arg = { [0] = _sCommand, ... }
        local result = os.run(env, sPath, ...)
        ProgramStack[#ProgramStack] = nil
        if multishell then
            if #ProgramStack > 0 then
                local sTitle = fs.getName(ProgramStack[#ProgramStack])
                if sTitle:sub(-4) == ".lua" then
                    sTitle = sTitle:sub(1, -5)
                end
                multishell.setTitle(multishell.getCurrent(), sTitle)
            else
                multishell.setTitle(multishell.getCurrent(), "shell")
            end
        end
        return result
    else
        printError("No such program")
        return false
    end
end

local function tokenise(...)
    local sLine = table.concat({...}, " ")
    local tWords = {}
    local bQuoted = false
    for match in string.gmatch(sLine .. '"', '(.-)"') do
        if bQuoted then
            table.insert(tWords, match)
        else
            for m in string.gmatch(match, "[^ \t]+") do
                table.insert(tWords, m)
            end
        end
        bQuoted = not bQuoted
    end

    return tWords
end

-- Install shell API
function shell.run(...)
    local tWords = tokenise(...)
    local sCommand = tWords[1]
    if sCommand then
        return run(sCommand, table.unpack(tWords, 2))
    end
    return false
end
function shell.exit()
    running = false
end
function shell.dir()
    return Dir
end
function shell.setDir(d)
    d = fs.combine(d, "")
    if not fs.isDir(d) then
        error("Not a directory", 2)
    end
    Dir = d
end
function shell.path()
    return Path
end
function shell.setPath(p)
    Path = p
end
function shell.resolve(_sPath)
    local sStartChar = string.sub(_sPath, 1, 1)

    if sStartChar == "~" then
        return fs.combine("/root", string.sub(_sPath, 2))
    end

    if sStartChar == "/" or sStartChar == "\\" then
        return fs.combine("", _sPath)
    else
        return fs.combine(Dir, _sPath)
    end
end
local function pathWithExtension(_sPath, _sExt)
    local nLen = #Path
    local sEndChar = string.sub(_sPath, nLen, nLen)
    -- Remove any trailing slashes so we can add an extension to the path safely
    if sEndChar == "/" or sEndChar == "\\" then
        _sPath = string.sub(_sPath, 1, nLen - 1)
    end
    return _sPath .. "." .. _sExt
end
function shell.resolveProgram(command)
    --expect(1, command, "string")
    -- Substitute aliases firsts
    if Aliases[command] ~= nil then
        command = Aliases[command]
    end

    -- If the path is a global path, use it directly
    if command:find("/") or command:find("\\") then
        local sPath = shell.resolve(command)
        if fs.exists(sPath) and not fs.isDir(sPath) then
            return sPath
        else
            local sPathLua = pathWithExtension(sPath, "lua")
            if fs.exists(sPathLua) and not fs.isDir(sPathLua) then
                return sPathLua
            end
        end
        return nil
    end

    -- Otherwise, look on the path variable
    for sPath in string.gmatch(Path, "[^:]+") do
        sPath = fs.combine(shell.resolve(sPath), command)
        if fs.exists(sPath) and not fs.isDir(sPath) then
            return sPath
        else
            local sPathLua = pathWithExtension(sPath, "lua")
            if fs.exists(sPathLua) and not fs.isDir(sPathLua) then
                return sPathLua
            end
        end
    end

    -- Not found
    return nil
end
function shell.programs(include_hidden)
    --expect(1, include_hidden, "boolean", "nil")

    local tItems = {}

    -- Add programs from the path
    for sPath in string.gmatch(Path, "[^:]+") do
        sPath = shell.resolve(sPath)
        if fs.isDir(sPath) then
            local tList = fs.list(sPath)
            for n = 1, #tList do
                local sFile = tList[n]
                if not fs.isDir(fs.combine(sPath, sFile)) and (include_hidden or string.sub(sFile, 1, 1) ~= ".") then
                    if #sFile > 4 and sFile:sub(-4) == ".lua" then
                        sFile = sFile:sub(1, -5)
                    end
                    tItems[sFile] = true
                end
            end
        end
    end

    -- Sort and return
    local tItemList = {}
    for sItem in pairs(tItems) do
        table.insert(tItemList, sItem)
    end
    table.sort(tItemList)
    return tItemList
end
local function completeProgram(sLine)
    if #sLine > 0 and string.sub(sLine, 1, 1) == "/" then
        -- Add programs from the root
        return fs.complete(sLine, "", true, false)
    else
        local tResults = {}
        local tSeen = {}

        -- Add aliases
        for sAlias, sCommand in pairs(Aliases) do
            if #sAlias > #sLine and string.sub(sAlias, 1, #sLine) == sLine then
                local sResult = string.sub(sAlias, #sLine + 1)
                if not tSeen[sResult] then
                    table.insert(tResults, sResult)
                    tSeen[sResult] = true
                end
            end
        end

        -- Add programs from the path
        local tPrograms = shell.programs()
        for n = 1, #tPrograms do
            local sProgram = tPrograms[n]
            if #sProgram > #sLine and string.sub(sProgram, 1, #sLine) == sLine then
                local sResult = string.sub(sProgram, #sLine + 1)
                if not tSeen[sResult] then
                    table.insert(tResults, sResult)
                    tSeen[sResult] = true
                end
            end
        end

        -- Sort and return
        table.sort(tResults)
        return tResults
    end
end
local function completeProgramArgument(sProgram, nArgument, sPart, tPreviousParts)
    local tInfo = CompletionInfo[sProgram]
    if tInfo then
        return tInfo.fnComplete(shell, nArgument, sPart, tPreviousParts)
    end
    return nil
end
function shell.complete(sLine)
    if #sLine > 0 then
        local tWords = tokenise(sLine)
        local nIndex = #tWords
        if string.sub(sLine, #sLine, #sLine) == " " then
            nIndex = nIndex + 1
        end
        if nIndex == 1 then
            local sBit = tWords[1] or ""
            local sPath = shell.resolveProgram(sBit)
            if CompletionInfo[sPath] then
                return {" "}
            else
                local tResults = completeProgram(sBit)
                for n = 1, #tResults do
                    local sResult = tResults[n]
                    local sPath = shell.resolveProgram(sBit .. sResult)
                    if CompletionInfo[sPath] then
                        tResults[n] = sResult .. " "
                    end
                end
                return tResults
            end
        elseif nIndex > 1 then
            local sPath = shell.resolveProgram(tWords[1])
            local sPart = tWords[nIndex] or ""
            local tPreviousParts = tWords
            tPreviousParts[nIndex] = nil
            return completeProgramArgument(sPath, nIndex - 1, sPart, tPreviousParts)
        end
    end
    return nil
end
function shell.completeProgram(sProgram)
    return completeProgram(sProgram)
end
function shell.setCompletionFunction(sProgram, fnComplete)
    CompletionInfo[sProgram] = {
        fnComplete = fnComplete
    }
end
function shell.getCompletionInfo()
    return CompletionInfo
end
function shell.getRunningProgram()
    if #ProgramStack > 0 then
        return ProgramStack[#ProgramStack]
    end
    return nil
end
function shell.setAlias(_sCommand, _sProgram)
    Aliases[_sCommand] = _sProgram
end
function shell.clearAlias(_sCommand)
    Aliases[_sCommand] = nil
end
function shell.aliases()
    -- Copy aliases
    local tCopy = {}
    for sAlias, sCommand in pairs(Aliases) do
        tCopy[sAlias] = sCommand
    end
    return tCopy
end
if multishell then
    function shell.openTab(...)
        local tWords = tokenise(...)
        local sCommand = tWords[1]
        if sCommand then
            local sPath = shell.resolveProgram(sCommand)
            if sPath == "rom/programs/shell" or sPath == "bin/shell" then
                return multishell.launch(createShellEnv("rom/programs"), "bin/shell", table.unpack(tWords, 2))
            elseif sPath ~= nil then
                return multishell.launch(createShellEnv("rom/programs"), "bin/shell", sCommand, table.unpack(tWords, 2))
            else
                printError("No such program")
            end
        end
    end

    function shell.switchTab(nID)
        multishell.setFocus(nID)
    end
end

local args = {...}
if #args > 0 then
    -- "shell x y z"
    -- Run the program specified on the commandline
    shell.run(...)
    return
end

local history = {}
do
    local history_file = ".shell_history" --settings.get("mbs.shell.history_file", ".shell_history")
    if history_file and fs.exists(history_file) then
        local handle = fs.open(history_file, "r")
        if handle then
            for line in handle.readLine do
                history[#history + 1] = line
            end
            handle.close()
        end
    end

    local max = 1e4 --tonumber(settings.get("mbs.shell.history_max", 1e4)) or 1e4
    if #history > max then
        while #history > max do
            table.remove(history, 1)
        end

        local history_file = ".shell_history" --settings.get("mbs.shell.history_file", ".shell_history")
        if history_file then
            local handle = fs.open(history_file, "w")
            if handle then
                for i = 1, #history do
                    handle.writeLine(history[i])
                end
                handle.close()
            end
        end
    end
end

local function get_first_startup()
    if fs.exists("startup.lua") and not fs.isDir("startup.lua") then
        return "startup.lua"
    end
    if fs.isDir("startup") then
        local first = fs.list("startup")[1]
        if first then
            return fs.combine("startup", first)
        end
    end

    return nil
end

local scroll_offset = 0

local function get(url)
    local response = http.get(url)

    if response then
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        return nil
    end
end

local function read_file(path)
    if fs.exists(path) then
        local file = io.open(path, "r")
        local sLine = file:read()
        file:close()
        return sLine
    end
end

--update check
local function update()
    if http then
        local system_info = json.decode(read_file("/.system_info"))
        local data =
            get(
            "https://api.github.com/repos/" ..
                system_info.git.owner .. "/" .. system_info.git.repo .. "/git/refs/heads/" .. system_info.git.branch
        )
        if data == nil then
        else
            local latest = json.decode(data).object.sha
            local current = system_info.git.commit

            if current == latest then
            else
                term.write("Your OculusOS is outdated by ")
                data =
                    get(
                    "https://api.github.com/repos/" ..
                        system_info.git.owner ..
                            "/" .. system_info.git.repo .. "/compare/" .. latest .. "..." .. current
                )
                if data == nil then
                    term.write("?")
                else
                    term.write(json.decode(data).behind_by)
                end
                print(" commits! Get the latest release bye typing 'do-release-upgrade'.")
            end
        end
    end
end

local default_shellrc = {
    PS1 = "&b(&e\\h&b)-[&0\\w&b]\n&e# "
}

local shellrc

if fs.exists("/.shellrc") then
    shellrc = dofile("/.shellrc")
end

local running_command = false

local worker =
    coroutine.create(
    function()
        -- Print the header
        if supports_scroll then
            term.redirect(redirect)
            term.setCursorPos(1, 1)
        else
            term.redirect(parent)
        end

        term.setBackgroundColor(bgColour)

        update()
        if not fs.exists("/.passwd") then
            print("No Password has been set. This is a security risk - please type 'passwd' to set a password.")
        end

        term.setTextColour(promptColour)
        write("OculusOS")
        term.setTextColour(textColour)

        --[[
        if shell.getRunningProgram() == get_first_startup() then
            -- If we're currently in the first startup file, then run all the others.
            local current = shell.getRunningProgram()

            if settings and settings.get("motd.enable") then
                shell.run("motd")
            end

            -- Run /startup or /startup.lua
            local root_startup = shell.resolveProgram("startup")
            if root_startup and root_startup ~= current then
                --shell.run("/" .. root_startup)
            end

            -- Run startup/*
            if fs.isDir("startup") then
                for _, file in ipairs(fs.list("startup")) do
                    local sub_startup = fs.combine("startup", file)
                    if sub_startup ~= current and not fs.isDir(sub_startup) then
                        --shell.run("/" .. sub_startup)
                    end
                end
            end
        end]]
        -- The main interaction loop
        while running do
            if supports_scroll then
                local scrollback = 1e3 --tonumber(settings.get("mbs.shell.scroll_max", 1e3))
                if scrollback then
                    redirect.setMaxScrollback(scrollback)
                end
            end

            term.setBackgroundColor(bgColour)
            term.setTextColour(promptColour)
            if term.getCursorPos() ~= 1 then
                print()
            end

            local sLabel = os.getComputerLabel()
            if not sLabel then
                sLabel = "oculusos"
            end

            local ps1
            if shellrc and shellrc.PS1 then
                ps1 = shellrc.PS1
            else
                ps1 = default_shellrc.PS1
            end

            local dir = shell.dir()

            if string.sub(dir, 1, 4) == "root" then
                dir = "~"..string.sub(dir, 5)
            else
                dir = "/"..dir
            end

            ps1 = ps1:gsub("\\w", dir)
            if os.date then
                ps1 = ps1:gsub("\\t", os.date("%H:%M:%S"))
                ps1 = ps1:gsub("\\T", os.date("%I:%M:%S"))
                ps1 = ps1:gsub("\\d", os.date("%a %b %y"))
                ps1 = ps1:gsub("\\@", os.date("%I:%M %p"))
                ps1 = ps1:gsub("\\A", os.date("%H:%M"))
            end
            cprint.cwrite(ps1:gsub("\\h", sLabel))

            if supports_scroll then
                redirect.setCursorPos(term.getCursorPos())
            end

            term.setTextColour(textColour)

            local line
            if settings then
                if settings.get("shell.autocomplete") then
                    line = read(nil, history, shell.complete)
                else
                    line = read(nil, history)
                end
            else
                line = read(nil, history, shell.complete)
            end

            if not line then
                break
            end

            if supports_scroll then
                local _, y = term.getCursorPos()
                redirect.setCursorThreshold(y)
            end

            -- run the command

            local ok = true

            if string.find(line, "!!") then
                if #history == 0 then
                    printError("No Command History!")
                else
                    print(history[#history])
                    line = line:gsub("!!", history[#history])
                end
            end

            if #history == 0 and string.find(line, "!!") then
            else
                if line:match("%S") and history[#history] ~= line then
                    -- Add item to history
                    history[#history + 1] = line

                    -- Write history file
                    local history_file = ".shell_history" --settings.get("mbs.shell.history_file", ".shell_history")
                    if history_file then
                        local handle = fs.open(history_file, "a")
                        handle.writeLine(line)
                        handle.close()
                    end
                end

                for _, command in ipairs(oculusos.split(line, ";")) do
                    running_command = true
                    ok = shell.run(command)
                    running_command = false
                end
            end

            if supports_scroll then
                term.redirect(redirect)
                redirect.endPrivateMode(not ok)
                redirect.draw(0)
            end
        end
        if supports_scroll then
            term.redirect(parent)
        end
    end
)

local ok, filter = coroutine.resume(worker)

if supports_scroll then
    -- We run the main worker inside a coroutine, catching any potential scroll
    -- events.
    while coroutine.status(worker) ~= "dead" do
        local event = table.pack(coroutine.yield())
        local e = event[1]

        -- Run the main REPL worker
        if filter == nil or e == filter or e == "terminate" then
            ok, filter = coroutine.resume(worker, table.unpack(event, 1))
        end

        -- Resize the terminal if required
        if e == "term_resize" then
            redirect.updateSize()
            redirect.draw(scroll_offset or 0, true)
        end

        -- If we're in some interactive function, allow scrolling the input
        if not running_command or (redirect.getCursorBlink and redirect.getCursorBlink()) then
            local change = 0
            if e == "mouse_scroll" then
                change = event[2]
            elseif e == "key" and event[2] == keys.pageDown then
                change = 10
            elseif e == "key" and event[2] == keys.pageUp then
                change = -10
            elseif e == "key" or e == "paste" then
                -- Reset offset if another key is pressed
                change = -scroll_offset
            end

            if change ~= 0 and term.current() == redirect and not redirect.isPrivateMode() then
                scroll_offset = scroll_offset + change
                if scroll_offset > 0 then
                    scroll_offset = 0
                end
                if scroll_offset < -redirect.getTotalHeight() then
                    scroll_offset = -redirect.getTotalHeight()
                end
                redirect.draw(scroll_offset)
            end
        end
    end
else
    while coroutine.status(worker) ~= "dead" do
        local event = table.pack(coroutine.yield())
        local e = event[1]

        -- Run the main REPL worker
        if filter == nil or e == filter or e == "terminate" then
            ok, filter = coroutine.resume(worker, table.unpack(event, 1))
        end
    end
end

if not ok then
    error(filter, 0)
end
