--(c) 2013 Felix Maxwell
--License: CC BY-SA 3.0

local fps = 8 --Determines how long the system will wait between each update
local maxLifetime = 40 --Max lifetime of each char
local minLifetime = 8 --Min lifetime of each char
local maxSourcesPerTick = 5 --Maximum number of sources created each tick
local sourceWeight = 0 --Affects the chance that no sources will be generated
local greenWeight = 8 --Threshhold out of 10 that determines when characters will switch from lime to green
local grayWeight = 2 --Same as about, but from green to gray

function getMonitors()
	local monitors = {}
	if checkMonitorSide( "top" ) then table.insert( monitors, "top" ) end
	if checkMonitorSide( "bottom" ) then table.insert( monitors, "bottom" ) end
	if checkMonitorSide( "left" ) then table.insert( monitors, "left" ) end
	if checkMonitorSide( "right" ) then table.insert( monitors, "right" ) end
	if checkMonitorSide( "front" ) then table.insert( monitors, "front" ) end
	if checkMonitorSide( "back" ) then table.insert( monitors, "back" ) end
	return monitors
end
function checkMonitorSide( side )
	if peripheral.isPresent( side ) then
		if peripheral.getType(side) == "monitor" then
			return true
		end
	end
	return false
end
function printMonitorStats( side )
	local x, y = peripheral.call(side, "getSize")
	local color = "No"
	if peripheral.call(side, "isColor") then
		color = "Yes"
	end
	print("Side:"..side.." Size:("..x..", "..y..") Color?"..color)
end
function askMonitor()
	local monitors = getMonitors()
	if #monitors == 0 then
		print("No monitors found, add more!")
		return nill
	elseif #monitors == 1 then
		return monitors[1]
	else
		while true do
			print("Multiple monitors found, please pick one.")
			for i,v in ipairs(monitors) do
				write("["..(i).."] ")
				printMonitorStats( v )
			end
			write("Selection: ")
			local sel = tonumber(io.read())
			if sel < 1 or sel > #monitors then
				print("")
				print("Invalid number.")
			else
				return monitors[sel]
			end
		end
	end
end

function printCharAt( monitor, x, y, char )
	monitor.setCursorPos( x, y )
	monitor.write( char )
end
function printGrid( monitor, grid, color )
	for i=1,#grid do
		for o=1,#grid[i] do
			if color then monitor.setTextColor( grid[i][o]["color"] ) end
			printCharAt( monitor, i, o, grid[i][o]["char"] )
		end
	end
end

function colorLifetime( life, originalLifetime )
	local lifetimePart = originalLifetime/10
	if life < grayWeight*lifetimePart then
		return colors.gray
	elseif life < greenWeight*lifetimePart then
		return colors.green
	else
		return colors.lime
	end
end
function getRandomChar()
	local randTable = {"1","2","3","4","5","6","7","8","9","0","!","@","#","$","%","^","&","*","(",")","_","-","+","=","~","`",",","<",">",".","/","?",":","{","}","[","]","\\","\"","\'"}
	return randTable[math.random(1, #randTable)]
end
function tick( screen )

	--update lifetimes
	for x=1,#screen do
		for y=1,#screen[x] do
			screen[x][y]["curLife"] = screen[x][y]["curLife"] - 1
		end
	end

	--make the sources 'fall' and delete timed out chars
	for x=1,#screen do
		for y=1,#screen[x] do
			if screen[x][y]["type"] == "source" and screen[x][y]["curLife"] == 0 then
				screen[x][y]["type"] = "char"
				screen[x][y]["lifetime"] = math.random(minLifetime, maxLifetime)
				screen[x][y]["curLife"] = screen[x][y]["lifetime"]
				screen[x][y]["color"] = colors.lime
			
				if y < #screen[x] then
					screen[x][y+1]["char"] = getRandomChar()
					screen[x][y+1]["lifetime"] = 1
					screen[x][y+1]["curLife"] = 1
					screen[x][y+1]["type"] = "source"
					screen[x][y+1]["color"] = colors.white
				end
			elseif screen[x][y]["curLife"] < 0 then
				screen[x][y]["char"] = " "
				screen[x][y]["lifetime"] = 0
				screen[x][y]["curLife"] = 0
				screen[x][y]["type"] = "blank"
				screen[x][y]["color"] = colors.black
			elseif screen[x][y]["type"] == "char" then
				screen[x][y]["color"] = colorLifetime( screen[x][y]["curLife"], screen[x][y]["lifetime"] )
			end
		end
	end
		
	--create new character sources
	local newSources = math.random( 0-sourceWeight, maxSourcesPerTick )
	for i=1,newSources do
		local col = math.random(1, #screen)
		screen[col][1]["char"] = getRandomChar()
		screen[col][1]["lifetime"] = 1
		screen[col][1]["curLife"] = 1
		screen[col][1]["type"] = "source"
		screen[col][1]["color"] = colors.white
	end
	
	return screen
end

function setup( w, h )
	local retTab = {}
	for x=1,w do
		retTab[x] = {}
		for y=1,h do
			retTab[x][y] = {}
			retTab[x][y]["char"] = " "
			retTab[x][y]["lifetime"] = 0
			retTab[x][y]["curLife"] = 0
			retTab[x][y]["type"] = "blank"
			retTab[x][y]["color"] = colors.black
		end
	end
	return retTab
end
function run()
	local color = term.isColor()
	local w, h = term.getSize()
	local screen = setup( w, h )
	while true do
		screen = tick( screen )
		printGrid( term, screen, color )
		os.sleep(1/fps)
	end
end

run()