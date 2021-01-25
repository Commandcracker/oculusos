--Start timer and set timer
os.startTimer(1)
local t = 1
local w,h = term.getSize()
if w == 51 and h == 19 then
	pc = true
else
	pc = false
end

--Display
term.setBackgroundColor(colors.black)
term.clear()
paintutils.drawImage(paintutils.loadImage("/oculusos/bootscreen"), 1, 1)

if pc == true then
	term.setCursorPos(8,17)
	print("F12:BIOS SETUP")

	term.setCursorPos(27,17)
	print("DEL:Q-FLASH")
else
	term.setCursorPos(4,11)
	print("F12:BIOS SETUP")

	term.setCursorPos(19,11)
	print("DEL:Q-FLASH")
end

--Loop
while true do
	
	--Event
	local event, key = os.pullEvent()
	
	--Timer
	if event == "timer" then
		
		t = t - 1
		os.startTimer(1)
		
		if t < 0 then
			break
		end
	
	--Keys
	elseif event == "key" then
	
		if key == 211 then
			term.clear()
			term.setCursorPos(1,1)
			print("DEL:Q-FLASH")
			sleep(1)
			os.reboot()
		elseif key == 88 then
			term.clear()
			term.setCursorPos(1,1)
			print("F12:BIOS SETUP")
			sleep(1)
			os.reboot()
		end
		
	end
	
end

term.clear()
paintutils.drawImage(paintutils.loadImage("/oculusos/bootscreen"), 1, 1)
sleep(1)

--Boot loader
os.startTimer(1)
local t = 5

moved = false
selected = 1
if pc == true then
	options = 8
else
	options = 3
end

while true do

	--Menu
	if term.isColor() then
		term.setBackgroundColor(colors.blue)
	else
		term.setBackgroundColor(colors.gray)
	end
	
	term.clear()
	
	if pc == true then
		term.setCursorPos(17,2)
		term.write("Oculus bootloader")
	else
		term.setCursorPos(11,2)
		term.write("Oculus bootloader")
	end
	
	if pc == true then
	
		term.setCursorPos(4,6)
		term.write(" ".."OculusOS")
		
		term.setCursorPos(4,7)
		term.write(" "..os.version())
		
		term.setCursorPos(4,8)
		term.write(" ".."Startup")
		
	end
	
	if moved == true and pc == false then
	
		term.setCursorPos(4,6)
		term.write(" ".."OculusOS")
		
		term.setCursorPos(4,7)
		term.write(" "..os.version())
		
		term.setCursorPos(4,8)
		term.write(" ".."Startup")
		
	end
	
	if pc == true then
	
		term.setCursorPos(4,9)
		term.write(" ".."Disk1")
		
		term.setCursorPos(4,10)
		term.write(" ".."Disk2")
		
		if moved == true then
			term.setCursorPos(4,11)
			term.write(" ".."Disk3")
			term.setCursorPos(4,12)
			term.write(" ".."Disk4")
			term.setCursorPos(4,13)
			term.write(" ".."Disk5")
		end
	
	end
	
	if pc == true then
		term.setCursorPos(4,selected+5)
		term.write("*")
	end
	
	if pc == false and moved == true then
		term.setCursorPos(4,selected+5)
		term.write("*")
	end
	
	if moved == true then
		term.setCursorPos(3,17)
		term.write('Use the keys "UP" and "DOWN" to mark an entry,')
		term.setCursorPos(3,18)
		term.write('"ENTER" to boot of the marked operating system.')
	end
	
	if moved == false then
		term.setCursorPos(3,14)
		term.write('Use the keys "UP" and "DOWN" to mark an entry,')
		term.setCursorPos(3,15)
		term.write('"ENTER" to boot of the marked operating system.')
	end
	
	if moved == false and pc == false then
		term.setCursorPos(9,5)
		term.write('Use the keys "UP" and')
		term.setCursorPos(7,6)
		term.write('"DOWN" to mark an entry,')
		term.setCursorPos(8,7)
		term.write('"ENTER" to boot of the')
		term.setCursorPos(7,8)
		term.write('marked operating system.')
	end
	
	if moved == false then
		if pc == true then
			term.setCursorPos(6,17)
			term.write("The highlighted entry is automatically")
			term.setCursorPos(18,18)
			term.write("executed in "..t.."s.")
		else
			term.setCursorPos(7,11)
			term.write("The highlighted entry is")
			term.setCursorPos(5,12)
			term.write("automatically executed in "..t.."s.")
		end
	end
	
	if moved == false then
		if pc == true then
			paintutils.drawBox(2,4,50,12,colors.white)
		end
	else
		if pc == true then
			paintutils.drawBox(2,4,50,15,colors.white)
		else
			paintutils.drawBox(2,4,38,10,colors.white)
		end
	end
	
	--Event
	local event, key = os.pullEvent()
	
	--Timer
	if event == "timer" and moved == false then
		
		t = t - 1
		os.startTimer(2)
		
		if t < 0 then
			break
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
			break
		end
	end
	
end

function disk (disk,disk_name)
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

CraftOS = false

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
