--# Monitor Mirror v2.1 - Program to mirror terminal contents onto monitor.
--# Made By Wojbie
--# http://pastebin.com/DW3LCC3L

--   Copyright (c) 2015-2021 Wojbie (wojbie@wojbie.net)
--   Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
--   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
--   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
--   4. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--   5. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--   NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function printUsage()
	print( "Usage: mirror <name> <program> <arguments>" )
	return
end

local tArgs = { ... }
if #tArgs < 2 then
	printUsage()
	return
end

local sName = tArgs[1]
if peripheral.getType( sName ) ~= "monitor" then
	printError( "No monitor named ".. sName )
	return
end

local sProgram = tArgs[2]
local sPath = shell.resolveProgram( sProgram )
if sPath == nil then
	printError( "No such program: "..sProgram )
	return
end

local fMain = function()
    shell.run( sPath, table.unpack( tArgs, 3 ) )
end 

--Spacial table that will transferr all functions call to each and every sub table. Static tables version
function createMultitable(...)

	local tab = {...}
	if #tab==1 and tab[1] and type(tab[1])=="table" then tab = tab[1] end
	if #tab==0 then error("Expected table of tables or any tables to table. I know it makes no sense.", 2) end

	local manymeta={ --Anytime index is requested fist table is used as refference. 
	["__index"]=function (parent , key)
		if tab and tab[1] and tab[1][key] then --If it has value it tested then
			if type(tab[1][key]) =="function" then --If its function then a function that calls all tables in row is made
				return function(...)
					local ret={}
					local tArgs={...}
					for i,k in ipairs(tab) do
						if k[key] then
							if #ret==0 then ret={k[key](unpack(tArgs))} --ret contains returns from first table that returned anything.
							else k[key](unpack(tArgs)) end
						end
					end
					return unpack(ret) 
				end
			else
				return tab[1][key]  --If its not a function then its just given out.
			end
		else
			return nil --Of it not exist in first table give nothing
		end
	end,
	["__newindex"]=function (parent, key, value) --If someone wants to add anything to the table
		--do nothing.
	end,
	["__call"]=function (parent, key) --If someone calls table like function give him direct acces to table list.
		--if key then tab = key end changing of content disalowed in static mode
		return tab
	end,
	["__len"]=function (parent, key) --Not sure if it works but this is giving the leanght of first table or 0 if there is no first table.
		return (tab[1] and #tab[1]) or 0
	end,
	["__metatable"]=false,--No touching the metatable.
	--["__type"]="WojbieManyMeta",--Custom type? Not in current version and not sure if wise. Commented out for now.
	}

	local out = {}
	for key,fun in pairs(tab[1]) do --create static table of multitable functions using first one as template
		out[key] = function(...)
			local ret={}
			local tArgs={...}
			for i,k in ipairs(tab) do
				if k[key] then
					if #ret==0 then ret={k[key](unpack(tArgs))} --ret contains returns from first table that returned anything.
					else k[key](unpack(tArgs)) end
				end
			end
			return unpack(ret) 
		end
	end
	return setmetatable(out,manymeta) --create acctual manymeta table and return it
	
end

--Create Window that is inside other terminal object of selected size. If setTextScale is defined it attempts to finds largest possible size for terminal. Its auto centered and not needed part of screen is painter gray and frame is added. If sName is defined its added onto frame if possible.
local tBor={"+","-","|"}--{"#","=","H"}
local function createFramedWindow(sSide,nX,nY,sName)
	
	if (type( sSide ) ~= "table" and type( sSide ) ~= "string") or
    	type( nX ) ~= "number" or
    	type( nY ) ~= "number" or
		(sName ~= nil and type( sName ) ~= "string")then
        error( "Expected string/object, number, number, [string]", 2 )
    end
	
	local monitor
	if type( sSide ) == "table" then monitor = sSide
	else monitor = peripheral.wrap(sSide) end
	
	if not monitor then error( "No monitor detected on side "..sSide, 2 ) end
	
	local nOffTop,nOffBot,nOffLeft,nOffRight
	local nOffTopBot, nOffLeftnXRight
	local nMonX,nMonY
	local tLines
	local win = window.create( monitor, 1, 1, nX, nY, false )
	local reposition = win.reposition
	
	local function redraw()
		for i=1,nMonY,1 do
			monitor.setCursorPos(1,i)
			if i<nOffTop then monitor.blit(tLines.e,tLines.f,tLines.b) --print(i,tLines.e)
			elseif i==nOffTop then monitor.blit(tLines.n or tLines.t,tLines.f,tLines.b) --print(i,tLines.n)
			elseif i<nOffTopBot then monitor.blit(tLines.m,tLines.f,tLines.b) --print(i,tLines.m)
			elseif i==nOffTopBot then monitor.blit(tLines.t,tLines.f,tLines.b) --print(i,tLines.t)
			else monitor.blit(tLines.e,tLines.f,tLines.b) end --print(i,tLines.m)
		end
	end	
	
	local function build()
		if monitor.setTextScale then
			local nCX,nCY
			for i=5,0.5,-0.5 do
				monitor.setTextScale(i)
				nCX,nCY = monitor.getSize()
				if nCX > nX and nCY > nY then break end
			end
		end
		nMonX,nMonY = monitor.getSize()
		
		nOffLeft=math.max((nMonX-nX)/2,0)
		nOffRight=math.ceil(nOffLeft)
		nOffLeft=math.floor(nOffLeft)
		nOffTop=math.max((nMonY-nY)/2,0)
		nOffBot=math.ceil(nOffTop)
		nOffTop=math.floor(nOffTop)
		nOffTopBot=nOffTop+nY+1
		nOffLeftnXRight = nOffLeft + nX + nOffRight
				
		tLines = {}
		tLines.e = string.rep(" ",nOffLeftnXRight)
		tLines.t = string.rep(" ",math.max(0,nOffLeft-1))..(nOffLeft>0 and tBor[1] or "")..string.rep(tBor[2],nX)..(nOffRight>0 and tBor[1] or "")..string.rep(" ",math.max(0,nOffRight-1))
		tLines.m = string.rep(" ",math.max(0,nOffLeft-1))..(nOffLeft>0 and tBor[3] or "")..string.rep(" ",nX)..(nOffRight>0 and tBor[3] or "")..string.rep(" ",math.max(0,nOffRight-1))
		if sName and type(sName)=="string" and #sName<= nX then 
			local sName2=string.sub(sName, 1, nX)
			local a=(nX-string.len(sName2))/2
			local b=math.ceil(a)
			a=math.floor(a)
			tLines.n = string.rep(" ",math.max(0,nOffLeft-1))..(nOffLeft>0 and tBor[1] or "")..string.rep(tBor[2],a)..sName2..string.rep(tBor[2],b)..(nOffRight>0 and tBor[1] or "")..string.rep(" ",math.max(0,nOffRight-1))
		end
		tLines.f = string.rep("7",nOffLeftnXRight) --0
		tLines.b = string.rep("8",nOffLeftnXRight) --f
		
		redraw()
		reposition( nOffLeft+1, nOffTop+1, nX, nY ) --window.reposition localized
		win.setVisible( true )
		
	end

	build()
	win.redrawBorder = function() return redraw() end
	win.synch = function() return build() end
	win.setName = function(A) sName=(A ~= nil and type( A ) == "string") and A or nil return build() end
	win.resize = function(A,B) 
		if 	type( A ) ~= "number" or
			type( B ) ~= "number" then
			error( "Expected number, number", 2 )
		end
		nX,nY = A,B
		return build() 
	end
	win.localize = function(A,B)
		local x,y = A-nOffLeft,B-nOffTop
		if x>0 and y>0 and x<=nX and y<=nY then
			return x,y
		end
	end  --localizes coordinates for inside of the window.
	
	return win
	
	--if sSide is a monitor object (like multiMon! http://www.computercraft.info/forums2/index.php?/topic/18229-multimon-multiple-monitors-in-computercraft/) use it instead of side.
	--create window on monitor
	--sized nX nY
	--centered on monitor
	--monitor scalled to max text size possible.
	--remove reposition call and store it in local wariable.
	--add synch function that rescales monitor and redraws window. if provided with new nX,nY it will resize too.

end

local function  mirrorToMonitors(fMain,tSides,sName) --tSides is table with monitor sides to write on. If empty or not defined it will take all possible sides.
	if type( fMain ) ~= "function" or
		(tSides ~= nil and type( tSides ) ~= "table") or
		(sName ~= nil and type( sName ) ~= "string") then
		error( "Expected function, table, [string]", 2 )
    end
	
	
	local parent = term.current()
	local x,y = parent.getSize()
	local tMirrorsSides = {}
	local tMirrors = {}
	
	if not tSides or #tSides == 0 then
		peripheral.find("monitor",function(name,wrap) tMirrorsSides[name] = createFramedWindow(name,x,y,sName) table.insert(tMirrors,tMirrorsSides[name]) end)
	else
		for i,k in pairs(tSides) do
			if peripheral.isPresent(k) and peripheral.getType(k) == "monitor" then
				tMirrorsSides[k] = createFramedWindow(k,x,y,sName)
				table.insert(tMirrors,tMirrorsSides[k])
			end
		end
	end
	
	local mirr = createMultitable(tMirrors)
	local mix = createMultitable(parent,mirr)
	term.redirect(mix)

	local co = coroutine.create(fMain)

	local function resume( ... )
		local ok, param = coroutine.resume( co, ... )
		if not ok then
			printError( param )
		end
		return param
	end

	local ok, param = pcall( function()
		local sFilter = resume()
		local TResizeLoop = {}
		while coroutine.status( co ) ~= "dead" do
			local tEvent = { os.pullEventRaw() }
			if tEvent[1] == "term_resize" then
				mirr.resize(parent.getSize())
			elseif tEvent[1] == "monitor_resize" and tMirrorsSides[tEvent[2]] then
				if TResizeLoop[tEvent[2]] then
					TResizeLoop[tEvent[2]] = false
				else
					tMirrorsSides[tEvent[2]].synch()
					TResizeLoop[tEvent[2]] = true
				end
			end
			if sFilter == nil or tEvent[1] == sFilter or tEvent[1] == "terminate" then
				sFilter = resume( table.unpack( tEvent ) )
			end
			if coroutine.status( co ) ~= "dead" and (sFilter == nil or sFilter == "mouse_click") then
				if tEvent[1] == "monitor_touch" and tMirrorsSides[tEvent[2]] then
					tEvent[3],tEvent[4] = tMirrorsSides[tEvent[2]].localize(tEvent[3],tEvent[4])
					if tEvent[3] then
						sFilter = resume( "mouse_click", 1, table.unpack( tEvent, 3 ) )
						if coroutine.status( co ) ~= "dead" and (sFilter == nil or sFilter == "mouse_up") then
							sFilter = resume( "mouse_up", 1, table.unpack( tEvent, 3 ) )
						end
					end
				end
			end
		end
	end )	
	
	term.redirect(parent)
	if not ok then
		printError( param )
	end
end

mirrorToMonitors(fMain,{sName},sProgram)