-- Global Variables
oldOsPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

-- Variables
os.startTimer(1)
local timer = 3
local TermW,TermH = term.getSize()
local CraftOS = false

--Functions--
local function printCentred( yc, stg )
	local xc = math.floor((TermW - string.len(stg)) / 2) + 1
	term.setCursorPos(xc,yc)
	term.write( stg )
end

local function disk (disk,disk_name)
	selected = 0
	if not fs.exists("/"..disk) then
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1,1)
		if term.isColor() then
			term.setTextColor(colors.red)
		end
		term.write(disk_name.." not found starting: OculusOS")
		sleep(2)
	else
		if not fs.exists("/"..disk.."/boot") then
			term.setBackgroundColor(colors.black)
			term.clear()
			term.setCursorPos(1,1)
			if term.isColor() then
				term.setTextColor(colors.red)
			end
			term.write("Boot on "..disk_name.." not found starting: OculusOS")
			sleep(2)
		else
			term.setBackgroundColor(colors.black)
			term.clear()
			term.setCursorPos(1,1)
			shell.run("/"..disk.."/boot")
			term.clear()
			term.setCursorPos(1,1)
			if term.isColor() then
				term.setTextColor(colors.yellow)
			end
			sleep(2)
			term.write("Boot on "..disk_name.." done ore crashed starting: OculusOS")
			sleep(2)
		end
	end
end

local function register_programs()
    -- Setup paths
    local sPath = ".:/oculusos/programs:/rom/programs"
    if term.isColor() then
        sPath = sPath..":/rom/programs/advanced"
    end
    if turtle then
        sPath = sPath..":/rom/programs/turtle"
    else
        sPath = sPath..":/rom/programs/rednet:/rom/programs/fun"
        if term.isColor() then
            sPath = sPath..":/rom/programs/fun/advanced"
        end
    end
    if pocket then
        sPath = sPath..":/rom/programs/pocket"
    end
    if commands then
        sPath = sPath..":/rom/programs/command"
    end
    if http then
        sPath = sPath..":/oculusos/programs/http:/rom/programs/http"
    end
    if not pocket then
        sPath = sPath..":/oculusos/programs/not_pocket"
    end
    shell.setPath( sPath )
    -- Setup aliases
    shell.setAlias("cls", "clear")
    -- Setup completion functions
    local completion = require "cc.shell.completion"
    shell.setCompletionFunction("oculusos/programs/cat", completion.build(completion.file))
    shell.setCompletionFunction("oculusos/programs/display", completion.build(completion.file))
    shell.setCompletionFunction("oculusos/programs/touch", completion.build(completion.file))
    shell.setCompletionFunction("oculusos/programs/tree", completion.build(completion.dir))
    shell.setCompletionFunction("oculusos/programs/decrypt", completion.build(completion.dirOrFile))
    shell.setCompletionFunction("oculusos/programs/encrypt", completion.build(completion.dirOrFile))

    local tPath = "/oculusos/apis/"
    local tAll = fs.list("/oculusos/apis/")

    for item in pairs(tAll) do
        os.loadAPI(tPath..tAll[item])
    end

end

local function get(url)
    local response = http.get(url)
    
    if response then
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        print( "Failed." )
    end
end

local function read_file(path)
    if fs.exists( path ) then
        local file = io.open( path, "r" )
        local sLine = file:read()
        file:close()
        return sLine
    end
end

local function update()
    if http then
        local url = "https://commandcracker.gitlab.io/oculusos/"
        if read_file("/oculusos/version") == get(url.."version") then else
            local url_full = url.."installer.lua"
            local tArgs = {
                "Update"
            }
            local res = get(url_full)
            
            if res then
                local func, err = load(res, url_full, "t", _ENV)
                if not func then
                    printError( err )
                    return
                end
                local success, msg = pcall(func, table.unpack(tArgs, 1))
                if not success then
                    printError( msg )
                end
            end
        end
    end
end

local function usage_small(y)
    printCentred(y, 'Use the keys "UP" and')
    printCentred(y+1, '"DOWN" to mark an entry,')
    printCentred(y+2 , '"ENTER" to boot of the')
    printCentred(y+3 , "marked operating system.")
end

local function usage_long(y)
    printCentred(y, 'Use the keys "UP" and "DOWN" to mark an entry,')
    printCentred(y+1, '"ENTER" to boot of the marked operating system.')
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
    
        if turtle and moved == false then else
            for i in ipairs(options) do
                term.setCursorPos(4,5 + i)
                term.write(" "..options[i])
                if not turtle and not pocket and moved == false and i == 5 then
                    break
                end
            end
        end

        if not turtle or moved == true then
            term.setCursorPos(4,selected+5)
            term.write("*")
        end
        
        if pocket then
            usage_small(12)
            if not moved then
                printCentred(18, "automatically")
                printCentred(19, "executing in "..timer.."s.")
            end
        else
            if turtle then
                if moved then
                    printCentred(12, 'Use "UP" and "DOWN" to mark an entry,')
                    printCentred(13, 'Press "ENTER" to boot from the entry')
                else
                    usage_small(5)
                    printCentred(11, "The highlighted entry is")
                    printCentred(12 , "automatically executed in "..timer.."s.")
                end
            else
                if moved then
                    usage_long(17)
                else
                    usage_long(14)
                    printCentred(17, "The highlighted entry is automatically")
                    printCentred(18, "executed in "..timer.."s.")
                end
            end
        end
        
        if not turtle and not pocket and not moved then
            paintutils.drawBox(2,4,TermW -1,12,colors.white)
        else
            if turtle and not moved then else
                paintutils.drawBox(2,4,TermW -1,7 + #options,colors.white)
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
        
            if key == 200 then
                moved = true
                selected = selected -1
                if selected == 0 then
                    selected = #options
                end
            elseif key == 208 then
                moved = true
                selected = selected +1
                if #options < selected then
                    selected = 1
                end
            elseif key == 28 then
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
	term.setCursorPos(1,1)
	if term.isColor() then
		term.setTextColor(colors.yellow)
	end
	term.write(os.version())
	term.setCursorPos(1,2)
	CraftOS = true
-- Boot
elseif selected == 3 then
	if not fs.exists("boot") then
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1,1)
		if term.isColor() then
			term.setTextColor(colors.red)
		end
		term.write("Boot not found starting: "..os.version())
		sleep(2)
	else
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1,1)
		shell.run("boot")
		sleep(2)
		term.clear()
		term.setCursorPos(1,1)
		if term.isColor() then
			term.setTextColor(colors.yellow)
		end
		sleep(2)
		term.write("Boot done ore crashed: "..os.version())
		sleep(2)
	end
-- disks
elseif selected == 4 then
	disk("disk","Disk1")
elseif selected == 5 then
	disk("disk2","Disk2")
elseif selected == 6 then
	disk("disk3","Disk3")
elseif selected == 7 then
	disk("disk4","Disk4")
elseif selected == 8 then
	disk("disk5","Disk5")
end

-- OculusOS

if not CraftOS then
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1,1)
    register_programs()
    update()

    if not fs.exists( "/oculusos/.passwd" ) then
        print("No Password has been set. This is a security risk - please type 'passwd' to set a password.")
    end

	shell.run("shell")
	if term.isColour() then
		term.setTextColour( colours.yellow )
	end
	print( "Goodbye" )
    term.setTextColour( colours.white )
	sleep(1)
	os.shutdown()
end
