-- Variables
os.startTimer(1)
local timer = 5
local TermW,TermH = term.getSize()
local CraftOS = false

if turtle then
    options = 3
else
	options = 8
end

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
        
        local _foptions = {
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
                table.insert(_foptions, disks[disk])
            end
        end
    
        if turtle and moved == false then else
            for i in ipairs(_foptions) do
                term.setCursorPos(4,5 + i)
                term.write(" ".._foptions[i])
                if not turtle and not pocket and moved == false and i == 5 then
                    break
                end
            end
        end

        if not turtle or moved == true then
            term.setCursorPos(4,selected+5)
            term.write("*")
        end
        
        if moved then
            printCentred(17, 'Use the keys "UP" and "DOWN" to mark an entry,')
            printCentred(18, '"ENTER" to boot of the marked operating system.')
        else
            printCentred(14, 'Use the keys "UP" and "DOWN" to mark an entry,')
            printCentred(15, '"ENTER" to boot of the marked operating system.')
        end
        
        if moved == false and turtle then
            printCentred(5, 'Use the keys "UP" and')
            printCentred(6, '"DOWN" to mark an entry,')
            printCentred(7 , '"ENTER" to boot of the')
            printCentred(8 , "marked operating system.")
        end
        
        if moved == false then
            if turtle then
                printCentred(11, "The highlighted entry is")
                printCentred(12 , "automatically executed in "..timer.."s.")
            else
                printCentred(17, "The highlighted entry is automatically")
                printCentred(18, "executed in "..timer.."s.")
            end
        end
        
        if moved == false then
            if turtle then else
                paintutils.drawBox(2,4,50,12,colors.white)
            end
        else
            if turtle then
                paintutils.drawBox(2,4,38,10,colors.white)
            else
                paintutils.drawBox(2,4,50,15,colors.white)
            end
        end
        
        --Event
        local event, key = os.pullEvent()
        
        --Timer
        if event == "timer" and moved == false then
            
            print("TIMER")
            timer = timer - 1
            os.startTimer(2)
            
            if timer < 0 then
                return selected
            end
        
        --Keys
        elseif event == "key" then
        
            if key == 200 then
                moved = true
                selected = selected -1
                if selected == 0 then
                    selected = options
                end
            elseif key == 208 then
                moved = true
                selected = selected +1
                if options < selected then
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
	shell.run("register_programs")
	shell.run("shell")
	if term.isColour() then
		term.setTextColour( colours.yellow )
	end
	print( "Goodbye" )
    term.setTextColour( colours.white )
	sleep(1)
	os.shutdown()
end
