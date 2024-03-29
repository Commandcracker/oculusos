-- Global Variables
local oldOsPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

-- Functions
local function draw(x1,y1,x2,y2)
	term.setCursorPos(x1,y1)
	print("F12:BIOS SETUP")

	term.setCursorPos(x2,y2)
	print("DEL:Q-FLASH")
end

--Display
term.setBackgroundColor(colors.black)
term.clear()
paintutils.drawImage(paintutils.loadImage("/.bootscreen"), 1, 1)

if turtle then
    draw(4,11, 19,11)
else
    if pocket then
        draw(10,10, 10,12)
	else
		draw(8,17, 27,17)
    end
end

--Loop
os.startTimer(1)
while true do
	--Event
	local event, key = os.pullEvent()
	
	--Timer
	if event == "timer" then
		break
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
paintutils.drawImage(paintutils.loadImage("/.bootscreen"), 1, 1)
sleep(1)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
os.pullEvent = oldOsPullEvent