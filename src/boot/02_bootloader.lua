-- Global Variables
local oldOsPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

-- Variables
os.startTimer(1)
local timer = 3
local TermW, TermH = term.getSize()
local CraftOS = false

--Functions--
local function printCentred(yc, stg)
    local xc = math.floor((TermW - string.len(stg)) / 2) + 1
    term.setCursorPos(xc, yc)
    term.write(stg)
end

local function disk(disk, disk_name)
    selected = 0
    if not fs.exists("/" .. disk) then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1, 1)
        if term.isColor() then
            term.setTextColor(colors.red)
        end
        term.write(disk_name .. " not found starting: OculusOS")
        sleep(2)
    else
        if not fs.exists("/" .. disk .. "/boot") then
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1, 1)
            if term.isColor() then
                term.setTextColor(colors.red)
            end
            term.write("Boot on " .. disk_name .. " not found starting: OculusOS")
            sleep(2)
        else
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1, 1)
            shell.run("/" .. disk .. "/boot")
            term.clear()
            term.setCursorPos(1, 1)
            if term.isColor() then
                term.setTextColor(colors.yellow)
            end
            sleep(2)
            term.write("Boot on " .. disk_name .. " done ore crashed starting: OculusOS")
            sleep(2)
        end
    end
end

local function register_programs()
    -- Setup paths
    local sPath = ".:/bin:/rom/programs"
    if term.isColor() then
        sPath = sPath .. ":/rom/programs/advanced"
    end
    if turtle then
        sPath = sPath .. ":/rom/programs/turtle"
    else
        sPath = sPath .. ":/rom/programs/rednet:/rom/programs/fun"
        if term.isColor() then
            sPath = sPath .. ":/rom/programs/fun/advanced"
        end
    end
    if pocket then
        sPath = sPath .. ":/rom/programs/pocket"
    end
    if commands then
        sPath = sPath .. ":/rom/programs/command"
    end
    if http then
        sPath = sPath .. ":/rom/programs/http"
    end
    shell.setPath(sPath)
    -- Setup aliases
    shell.setAlias("cls", "clear")
    -- Setup completion functions
    local completion = {}

    function completion.build(...)
        local arguments = table.pack(...)
        for i = 1, 1 do
            local arg = arguments[i]
            if arg ~= nil then
                if type(arg) == "function" then
                    arg = { arg }
                    arguments[i] = arg
                end
            end
        end

        return function(shell, index, text, previous)
            local arg = arguments[index]
            if not arg then
                if index <= arguments.n then return end

                arg = arguments[arguments.n]
                if not arg or not arg.many then return end
            end

            return arg[1](shell, text, previous, table.unpack(arg, 2))
        end
    end

    function completion.dir(shell, text)
        return fs.complete(text, shell.dir(), false, true)
    end

    function completion.file(shell, text)
        return fs.complete(text, shell.dir(), true, false)
    end

    function completion.dirOrFile(shell, text, previous, add_space)
        local results = fs.complete(text, shell.dir(), true, true)
        if add_space then
            for n = 1, #results do
                local result = results[n]
                if result:sub(-1) ~= "/" then
                    results[n] = result .. " "
                end
            end
        end
        return results
    end

    function completion.programWithArgs(shell, text, previous, starting)
        if #previous + 1 == starting then
            local tCompletionInfo = shell.getCompletionInfo()
            if text:sub(-1) ~= "/" and tCompletionInfo[shell.resolveProgram(text)] then
                return { " " }
            else
                local results = shell.completeProgram(text)
                for n = 1, #results do
                    local sResult = results[n]
                    if sResult:sub(-1) ~= "/" and tCompletionInfo[shell.resolveProgram(text .. sResult)] then
                        results[n] = sResult .. " "
                    end
                end
                return results
            end
        else
            local program = previous[starting]
            local resolved = shell.resolveProgram(program)
            if not resolved then return end
            local tCompletion = shell.getCompletionInfo()[resolved]
            if not tCompletion then return end
            return tCompletion.fnComplete(shell, #previous - starting + 1, text,
                { program, table.unpack(previous, starting + 1, #previous) })
        end
    end

    function completion.completeProgram(shell, nIndex, sText, tPreviousText)
        if nIndex == 1 then
            return shell.completeProgram(sText)
        end
    end

    shell.setCompletionFunction("bin/cat", completion.build(completion.file))
    shell.setCompletionFunction("bin/display", completion.build(completion.file))
    shell.setCompletionFunction("bin/less", completion.build(completion.file))
    shell.setCompletionFunction("bin/touch", completion.build(completion.file))
    shell.setCompletionFunction("bin/tree", completion.build(completion.dir))
    shell.setCompletionFunction("bin/decrypt", completion.build(completion.dirOrFile))
    shell.setCompletionFunction("bin/encrypt", completion.build(completion.dirOrFile))

    shell.setCompletionFunction("bin/shell", completion.build({ completion.programWithArgs, 2, many = true }))
    shell.setCompletionFunction("bin/list", completion.build(completion.dir))
    shell.setCompletionFunction("bin/which", completion.completeProgram)

    -- load libs
    local tPath = "/lib/"
    local tAll = fs.list(tPath)

    print("Booting OculusOS...")
    print("Initalizing lib...")

    for item in pairs(tAll) do
        os.loadAPI(tPath .. tAll[item])
        print("> " .. tPath .. tAll[item])
        --sleep(math.random())
    end

    -- load pack
    local pack_path = "/etc/pack/packages/pack/"
    local pack_src_path = pack_path .. "pack-src/lib/pack"
    local pack_min_path = pack_path .. "pack/lib/pack"

    if fs.exists(pack_src_path) then
        dofile(pack_src_path).loadPackages(shell)
    elseif fs.exists(pack_min_path) then
        dofile(pack_min_path).loadPackages(shell)
    end

    sleep(1)
end

local function usage_small(y)
    printCentred(y, 'Use the keys "UP" and')
    printCentred(y + 1, '"DOWN" to mark an entry,')
    printCentred(y + 2, '"ENTER" to boot of the')
    printCentred(y + 3, "marked operating system.")
end

local function usage_long(y)
    printCentred(y, 'Use the keys "UP" and "DOWN" to mark an entry,')
    printCentred(y + 1, '"ENTER" to boot of the marked operating system.')
end

local function menu()
    local selected = 1
    local moved = false

    while true do

        --Menu
        if term.isColor() then
            term.setBackgroundColor(colors.blue)
        else
            term.setBackgroundColor(colors.gray)
        end

        term.clear()

        printCentred(2, "Oculus bootloader")

        local options = {
            "OculusOS",
            os.version(),
            "Startup"
        }

        if not turtle and not pocket then
            local disks = {
                "Disk1",
                "Disk2",
                "Disk3",
                "Disk4",
                "Disk5"
            }
            for disk in ipairs(disks) do
                table.insert(options, disks[disk])
            end
        end

        if turtle and moved == false then
        else
            for i in ipairs(options) do
                term.setCursorPos(4, 5 + i)
                term.write(" " .. options[i])
                if not turtle and not pocket and moved == false and i == 5 then
                    break
                end
            end
        end

        if not turtle or moved == true then
            term.setCursorPos(4, selected + 5)
            term.write("*")
        end

        if pocket then
            usage_small(12)
            if not moved then
                printCentred(18, "automatically")
                printCentred(19, "executing in " .. timer .. "s.")
            end
        else
            if turtle then
                if moved then
                    printCentred(12, 'Use "UP" and "DOWN" to mark an entry,')
                    printCentred(13, 'Press "ENTER" to boot from the entry')
                else
                    usage_small(5)
                    printCentred(11, "The highlighted entry is")
                    printCentred(12, "automatically executed in " .. timer .. "s.")
                end
            else
                if moved then
                    usage_long(17)
                else
                    usage_long(14)
                    printCentred(17, "The highlighted entry is automatically")
                    printCentred(18, "executed in " .. timer .. "s.")
                end
            end
        end

        if not turtle and not pocket and not moved then
            paintutils.drawBox(2, 4, TermW - 1, 12, colors.white)
        else
            if turtle and not moved then
            else
                paintutils.drawBox(2, 4, TermW - 1, 7 + #options, colors.white)
            end
        end

        --Event
        local event, key = os.pullEvent()

        --Timer
        if event == "timer" and moved == false then

            timer = timer - 1
            os.startTimer(1)

            if timer < 0 then
                return selected
            end

            --Keys
        elseif event == "key" then

            if key == keys.up then
                moved = true
                selected = selected - 1
                if selected == 0 then
                    selected = #options
                end
            elseif key == keys.down then
                moved = true
                selected = selected + 1
                if #options < selected then
                    selected = 1
                end
            elseif key == keys.enter then
                return selected
            end
        end

    end
end

-- Run
term.clear()
selected = menu()
os.pullEvent = oldOsPullEvent

-- CraftOS
if selected == 2 then
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    if term.isColor() then
        term.setTextColor(colors.yellow)
    end
    term.write(os.version())
    term.setCursorPos(1, 2)
    CraftOS = true
    -- Boot
elseif selected == 3 then
    if not fs.exists("boot") then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1, 1)
        if term.isColor() then
            term.setTextColor(colors.red)
        end
        term.write("Boot not found starting: " .. os.version())
        sleep(2)
    else
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1, 1)
        shell.run("boot")
        sleep(2)
        term.clear()
        term.setCursorPos(1, 1)
        if term.isColor() then
            term.setTextColor(colors.yellow)
        end
        sleep(2)
        term.write("Boot done ore crashed: " .. os.version())
        sleep(2)
    end
    -- disks
elseif selected == 4 then
    disk("disk", "Disk1")
elseif selected == 5 then
    disk("disk2", "Disk2")
elseif selected == 6 then
    disk("disk3", "Disk3")
elseif selected == 7 then
    disk("disk4", "Disk4")
elseif selected == 8 then
    disk("disk5", "Disk5")
end

-- OculusOS

if not CraftOS then
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColour(colors.white)
    register_programs()
    term.clear()
    term.setCursorPos(1, 1)

    if not fs.exists("/root") then
        fs.makeDir("/root")
    end

    shell.setDir("/root")
    shell.run("/bin/shell")
    if term.isColour() then
        term.setTextColour(colours.orange)
    end
    print("Goodbye")
    term.setTextColour(colours.white)
    sleep(1)
    os.shutdown()
end
