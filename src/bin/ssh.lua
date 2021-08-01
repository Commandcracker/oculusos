local args = { ... }

local connections = {}

local sshAPI = {
	connList = connections
}

local bufferDirs = {"/lib/","/","/usr/apis/","/disk/"}

if not framebuffer then
	for i = 1, #bufferDirs do
		if fs.exists(bufferDirs[i].."framebuffer") and os.loadAPI(bufferDirs[i].."framebuffer") then
			break
		end
	end
end
if not framebuffer then
	print("Couldn't find framebuffer API, using fallback")
end

local function rawSend(id, msg)
	if term.current then
		return rednet.send(id, msg, "tror")
	else
		return rednet.send(id, msg)
	end
end

local function rawRecv(id, timeout)
	if type(timeout) == "number" then timeout = os.startTimer(timeout) end
	while true do
		event = {os.pullEvent()}
		if event[1] == "rednet_message" and (id == nil and true or event[2] == id) and (not term.current and true or event[4] == "tror") then
			return event[3]
		elseif event[1] == "timer" and event[2] == timeout then
			return nil
		end
	end
end


sshAPI.getRemoteID = function()
	--check for connected clients with matching threads.
	for cNum, cInfo in pairs(sshAPI.connList) do
		if cInfo and type(cInfo) == "table" and cInfo.thread == coroutine.running() then
			if cNum == "localShell" then
				--if we are a client running on the server, return the remote server ID.
				if sshAPI.serverNum then
					return sshAPI.serverNum
				else
					return nil
				end
			end
			return cNum
		end
	end
	--client running without local server, return remote server ID.
	if sshAPI.serverNum then return sshAPI.serverNum end
	return nil
end

sshAPI.send = function(msg)
	local id = sshAPI.getRemoteID()
	if id then
		return rawSend(id, msg)
	end
	return nil
end

sshAPI.receive = function(timeout)
	return rawRecv(sshAPI.getRemoteID(), timeout)
end

sshAPI.getClientCapabilities = function()
	if sshAPI.clientCapabilities then return sshAPI.clientCapabilities end
	sshAPI.send("SP:;clientCapabilities")
	return sshAPI.receive(1)
end

sshAPI.getRemoteConnections = function()
	local remotes = {}
	for cNum, cInfo in pairs(sshAPI.connList) do
		table.insert(remotes, cNum)
		if cInfo.outbound then
			table.insert(remotes, cInfo.outbound)
		end
	end
	return remotes
end

sshAPI.packFile = function(path)
	local data = {}
	local count = 0
	local handle = io.open(path, "rb")
	if handle then
		local byte = handle:read()
		repeat
			data[#data + 1] = byte
			count = count + 1
			if count % 1000 == 0 then
				os.queueEvent("yield")
				os.pullEvent("yield")
			end
			byte = handle:read()
		until not byte
		handle:close()
	else
		return false
	end
	local outputTable = {}
	for i = 1, #data, 3 do
		local num1, num2, num3 = data[i], data[i + 1] or 0, data[i + 2] or 0
		table.insert(outputTable, string.char(bit.band(bit.brshift(num1, 2), 63)))
		table.insert(outputTable, string.char(bit.bor(bit.band(bit.blshift(num1, 4), 48), bit.band(bit.brshift(num2, 4), 15))))
		table.insert(outputTable, string.char(bit.bor(bit.band(bit.blshift(num2, 2), 60), bit.band(bit.brshift(num3, 6), 3))))
		table.insert(outputTable, string.char(bit.band(num3, 63)))
	end
	--mark non-data (invalid) bytes
	if #data % 3 == 1 then
		outputTable[#outputTable] = "="
		outputTable[#outputTable - 1] = "="
	elseif #data % 3 == 2 then
		outputTable[#outputTable] = "="
	end
	return table.concat(outputTable, "")
end

sshAPI.unpackAndSaveFile = function(path, data)
	local outputTable = {}
	for i=1, #data, 4 do
		local char1, char2, char3, char4 = string.byte(string.sub(data, i, i)), string.byte(string.sub(data, i + 1, i + 1)), string.byte(string.sub(data, i + 2, i + 2)), string.byte(string.sub(data, i + 3, i + 3))
		table.insert(outputTable, bit.band(bit.bor(bit.blshift(char1, 2), bit.brshift(char2, 4)), 255))
		table.insert(outputTable, bit.band(bit.bor(bit.blshift(char2, 4), bit.brshift(char3, 2)), 255))
		table.insert(outputTable, bit.band(bit.bor(bit.blshift(char3, 6), char4), 255))
	end
	--clean invalid bytes if marked
	if string.sub(data, #data, #data) == "=" then
		table.remove(outputTable)
		if string.sub(data, #data - 1, #data - 1) == "=" then
			table.remove(outputTable)
		end
	end
	local handle = io.open(path, "wb")
	if handle then
		for i = 1, #outputTable do
			handle:write(outputTable[i])
			if i % 10 == 0 then
				os.startTimer(0.1)
				os.pullEvent("timer")
			end
		end
		handle:close()
	end
end

local packetConversion = {
	query = "SQ",
	response = "SR",
	data = "SP",
	close = "SC",
	fileQuery = "FQ",
	fileSend = "FS",
	fileResponse = "FR",
	fileHeader = "FH",
	fileData = "FD",
	fileEnd = "FE",
	textWrite = "TW",
	textCursorPos = "TC",
	textGetCursorPos = "TG",
	textGetSize = "TD",
	textInfo = "TI",
	textClear = "TE",
	textClearLine = "TL",
	textScroll = "TS",
	textBlink = "TB",
	textColor = "TF",
	textBackground = "TK",
	textIsColor = "TA",
	textTable = "TT",
	event = "EV",
	SQ = "query",
	SR = "response",
	SP = "data",
	SC = "close",
	FQ = "fileQuery",
	FS = "fileSend",
	FR = "fileResponse",
	FH = "fileHeader",
	FD = "fileData",
	FE = "fileEnd",
	TW = "textWrite",
	TC = "textCursorPos",
	TG = "textGetCursorPos",
	TD = "textGetSize",
	TI = "textInfo",
	TE = "textClear",
	TL = "textClearLine",
	TS = "textScroll",
	TB = "textBlink",
	TF = "textColor",
	TK = "textBackground",
	TA = "textIsColor",
	TT = "textTable",
	EV = "event",
}

local function openModem()
	local modemFound = false
	for _, side in ipairs(rs.getSides()) do
		if peripheral.getType(side) == "modem" then
			if not rednet.isOpen(side) then rednet.open(side) end
			modemFound = true
			break
		end
	end
	return modemFound
end

local function send(id, pType, message)
	if pType and message then
		return rawSend(id, packetConversion[pType]..":;"..message)
	end
end

local function awaitResponse(id, time)
	id = tonumber(id)
	local listenTimeOut = nil
	local messRecv = false
	if time then listenTimeOut = os.startTimer(time) end
	while not messRecv do
		local event, p1, p2 = os.pullEvent()
		if event == "timer" and p1 == listenTimeOut then
			return false
		elseif event == "rednet_message" then
			sender, message = p1, p2
			if id == sender and message then
				if packetConversion[string.sub(message, 1, 2)] then packetType = packetConversion[string.sub(message, 1, 2)] end
				message = string.match(message, ";(.*)")
				messRecv = true
			end
		end
	end
	return packetType, message
end

local function processText(conn, pType, value)
	if not pType then return false end
	if pType == "textWrite" and value then
		term.write(value)
	elseif pType == "textClear" then
		term.clear()
	elseif pType == "textClearLine" then
		term.clearLine()
	elseif pType == "textGetCursorPos" then
		local x, y = term.getCursorPos()
		send(conn, "textInfo", math.floor(x)..","..math.floor(y))
	elseif pType == "textCursorPos" then
		local x, y = string.match(value, "(%-?%d+),(%-?%d+)")
		term.setCursorPos(tonumber(x), tonumber(y))
	elseif pType == "textBlink" then
		if value == "true" then
			term.setCursorBlink(true)
		else
			term.setCursorBlink(false)
		end
	elseif pType == "textGetSize" then
		x, y = term.getSize()
		send(conn, "textInfo", x..","..y)
	elseif pType == "textScroll" and value then
		term.scroll(tonumber(value))
	elseif pType == "textIsColor" then
		send(conn, "textInfo", tostring(term.isColor()))
	elseif pType == "textColor" and value then
		value = tonumber(value)
		if (value == 1 or value == 32768) or term.isColor() then
			term.setTextColor(value)
		end
	elseif pType == "textBackground" and value then
		value = tonumber(value)
		if (value == 1 or value == 32768) or term.isColor() then
			term.setBackgroundColor(value)
		end
	elseif pType == "textTable" then
		local linesTable = textutils.unserialize(value)
		for i=1, linesTable.sizeY do
			term.setCursorPos(1,i)
			local lineEnd = false
			local offset = 1
			while not lineEnd do
				local textColorString = string.match(string.sub(linesTable.textColor[i], offset), string.sub(linesTable.textColor[i], offset, offset).."*")
				local backColorString = string.match(string.sub(linesTable.backColor[i], offset), string.sub(linesTable.backColor[i], offset, offset).."*")
				term.setTextColor(2 ^ tonumber(string.sub(textColorString, 1, 1), 16))
				term.setBackgroundColor(2 ^ tonumber(string.sub(backColorString, 1, 1), 16))
				term.write(string.sub(linesTable.text[i], offset, offset + math.min(#textColorString, #backColorString) - 1))
				offset = offset + math.min(#textColorString, #backColorString)
				if offset > linesTable.sizeX then lineEnd = true end
			end
		end
		term.setCursorPos(linesTable.cursorX, linesTable.cursorY)
		term.setCursorBlink(linesTable.cursorBlink)
	end
	return
end

local function textRedirect(id)
	local textTable = {}
	textTable.id = id
	textTable.write = function(text)
		return send(textTable.id, "textWrite", text)
	end
	textTable.clear = function()
		return send(textTable.id, "textClear", "nil")
	end
	textTable.clearLine = function()
		return send(textTable.id, "textClearLine", "nil")
	end
	textTable.getCursorPos = function()
		send(textTable.id, "textGetCursorPos", "nil")
		local pType, message = awaitResponse(textTable.id, 2)
		if pType and pType == "textInfo" then
			local x, y = string.match(message, "(%-?%d+),(%-?%d+)")
			return tonumber(x), tonumber(y)
		end
	end
	textTable.setCursorPos = function(x, y)
		return send(textTable.id, "textCursorPos", math.floor(x)..","..math.floor(y))
	end
	textTable.setCursorBlink = function(b)
		if b then
			return send(textTable.id, "textBlink", "true")
		else
			return send(textTable.id, "textBlink", "false")
		end
	end
	textTable.getSize = function()
		send(textTable.id, "textGetSize", "nil")
		local pType, message = awaitResponse(textTable.id, 2)
		if pType and pType == "textInfo" then
			local x, y = string.match(message, "(%d+),(%d+)")
			return tonumber(x), tonumber(y)
		end
	end
	textTable.scroll = function(lines)
		return send(textTable.id, "textScroll", lines)
	end
	textTable.isColor = function()
		send(textTable.id, "textIsColor", "nil")
		local pType, message = awaitResponse(textTable.id, 2)
		if pType and pType == "textInfo" then
			if message == "true" then
				return true
			end
		end
		return false
	end
	textTable.isColour = textTable.isColor
	textTable.setTextColor = function(color)
		return send(textTable.id, "textColor", tostring(color))
	end
	textTable.setTextColour = textTable.setTextColor
	textTable.setBackgroundColor = function(color)
		return send(textTable.id, "textBackground", tostring(color))
	end
	textTable.setBackgroundColour = textTable.setBackgroundColor
	return textTable
end

local function getServerID(server)
	if tonumber(server) then
		return tonumber(server)
	elseif term.current then
		return rednet.lookup("tror", args[1])
	end
end

local function resumeThread(conn, event)
	local cInfo = connections[conn]
	if connections[conn] and (not connections[conn].filter or event[1] == connections[conn].filter) then
		connections[conn].filter = nil
		local _oldTerm = term.redirect(connections[conn].target)
		local passback = {coroutine.resume(connections[conn].thread, unpack(event))}
		if passback[1] and passback[2] then
			connections[conn].filter = passback[2]
		end
		if coroutine.status(connections[conn].thread) == "dead" and conn ~= "localShell" then
			send(conn, "close", "disconnect")
			connections[conn] = false
		end
		if _oldTerm then
			term.redirect(_oldTerm)
		else
			term.restore()
		end
		if connections[conn] and conn ~= "localShell" and framebuffer and connections[conn].target.changed then
			send(conn, "textTable", textutils.serialize(connections[conn].target.buffer))
			connections[conn].target.changed = false
		end
	end
end

local eventFilter = {
	key = true,
	char = true,
	mouse_click = true,
	mouse_drag = true,
	mouse_scroll = true,
}

local function newSession(conn, x, y, color)
	local session = {}
	local path = "shell"
	if #args >= 2 and shell.resolveProgram(args[2]) then path = shell.resolveProgram(args[2]) end
	session.thread = coroutine.create(
		function()
			local function read_file(path)
				if fs.exists( path ) then
					local file = io.open( path, "r" )
					local sLine = file:read()
					file:close()
					return sLine
				end
			end			

			if fs.exists( "/.passwd" ) then
				while true do
					term.write("Password: ")
					input = read('*')
					if sha256.sha256(input) == read_file("/.passwd") then
						break
					else
						printError("Incorrect password!")
					end
				end
			end

			os.run({supports_scroll=false, shell=shell, multishell=multishell}, shell.resolveProgram(path))
		end
	)
	if framebuffer then
		local target = {}
		local _target = framebuffer.new(x, y, color)
		for k, v in pairs(_target) do
			if type(k) == "string" and type(v) == "function" then
				target[k] = function(...)
					target.changed = true
					return _target[k](...)
				end
			else
				target[k] = _target[k]
			end
		end
		session.target = target
	else
		session.target = textRedirect(conn)
	end
	session.status = "open"
	_oldTerm = term.redirect(session.target)
	coroutine.resume(session.thread)
	if _oldTerm then
		term.redirect(_oldTerm)
	else
		term.restore()
	end
	if framebuffer then
		send(conn, "textTable", textutils.serialize(session.target.buffer))
		session.target.changed = false
	end
	return session
end

if #args >= 1 and args[1] == "host" then
	_G.ssh = sshAPI
	if not openModem() then
		print("No modems found. 1 required.")
		return 
	end
	if term.current then
		if args[2] then
			rednet.host("tror", args[2])
		elseif os.getComputerLabel() then
			rednet.host("tror", os.getComputerLabel())
		else
			print("No label or hostname provided!")
			return
		end
	end
	local connInfo = {}
	connInfo.target = term.current and term.current() or term.native
	local path = "shell"
	if #args >= 3 and shell.resolveProgram(args[3]) then path = shell.resolveProgram(args[3]) end
	connInfo.thread = coroutine.create(function() shell.run(path) end)
	connections.localShell = connInfo
	term.clear()
	term.setCursorPos(1,1)
	coroutine.resume(connections.localShell.thread)

	while true do
		event = {os.pullEventRaw()}
		if event[1] == "rednet_message" then
			if type(event[3]) == "string" and packetConversion[string.sub(event[3], 1, 2)] then
				--this is a packet meant for us.
				conn = event[2]
				packetType = packetConversion[string.sub(event[3], 1, 2)]
				message = string.match(event[3], ";(.*)")
				if connections[conn] and connections[conn].status == "open" then
					if packetType == "event" or string.sub(packetType, 1, 4) == "text" then
						local eventTable = {}
						if packetType == "event" then
							eventTable = textutils.unserialize(message)
						else
							--we can pass the packet in raw, since this is not an event packet.
							eventTable = event
						end
						resumeThread(conn, eventTable)
					elseif packetType == "query" then
						local connType, color, x, y = string.match(message, "(%a+):(%a+);(%d+),(%d+)")
						if connType == "connect" or (connType == "resume" and (not framebuffer)) then
							--reset connection
							send(conn, "response", "OK")
							connections[conn] = newSession(conn, tonumber(x), tonumber(y), color == "true")
						elseif connType == "resume" and connections[conn] and tonumber(x) == connections[conn].target.buffer.sizeX and tonumber(y) == connections[conn].target.buffer.sizeY then
							--restore connection
							send(conn, "response", "OK")
							send(conn, "textTable", textutils.serialize(connections[conn].target.buffer))
						end
					elseif packetType == "close" then
						connections[conn] = nil
						send(conn, "close", "disconnect")
						--close connection
					else
						--we got a packet, have an open connection, but despite it being in the conversion table, don't handle it ourselves. Send it onward.
						resumeThread(conn, event)
					end
				elseif packetType ~= "query" then
					--usually, we would send a disconnect here, but this prevents one from hosting ssh and connecting to other computers.  Pass these to all shells as well.
					for cNum, cInfo in pairs(connections) do
						resumeThread(cNum, event)
					end
				else
					--open new connection
					send(conn, "response", "OK")
					local color, x, y = string.match(message, "connect:(%a+);(%d+),(%d+)")
					local connInfo = newSession(conn, tonumber(x), tonumber(y), color == "true")
					connections[conn] = connInfo
				end
			else
				--rednet message, but not in the correct format, so pass to all shells.
				for cNum, cInfo in pairs(connections) do
					resumeThread(cNum, event)
				end
			end
		elseif eventFilter[event[1]] then
			--user interaction.
			coroutine.resume(connections.localShell.thread, unpack(event))
			if coroutine.status(connections.localShell.thread) == "dead" then
				for cNum, cInfo in pairs(connections) do
					if cNum ~= "localShell" then
						send(cNum, "close", "disconnect")
					end
				end
				return
			end
		else
			--dispatch all other events to all shells
			for cNum, cInfo in pairs(connections) do
				resumeThread(cNum, event)
			end
		end
	end

elseif #args <= 2 and ssh and ssh.getRemoteID() then
	print(ssh.getRemoteID())
	--forwarding mode
	local conns = ssh.getRemoteConnections()
	for i = 1, #conns do
		if conns[i] == serverNum then
			print("Cyclic connection refused.")
			return
		end
	end
	local fileTransferState = nil
	local fileData = nil
	local serverNum = getServerID(args[1])
	if not serverNum then
		print("Server Not Found")
		return
	end
	send(serverNum, "query", "connect")
	local pType, message = awaitResponse(serverNum, 2)
	if pType ~= "response" then
		print("Connection Failed")
		return
	else
		ssh.connList[ssh.getRemoteID()].outbound = serverNum
		term.clear()
		term.setCursorPos(1,1)
	end
	local clientID = ssh.getRemoteID()
	local serverID = tonumber(args[1])
	while true do
		event = {os.pullEvent()}
		if event[1] == "rednet_message" then
			if event[2] == clientID or event[2] == serverID then
				if event[2] == serverID and string.sub(event[3], 1, 2) == "SC" then break end
				rednet.send((event[2] == clientID and serverID or clientID), event[3])
			end
		elseif eventFilter[event[1]] then
			rednet.send(serverID, "EV:;"..textutils.serialize(event))
		end
	end
	ssh.connList[ssh.getRemoteID()].outbound = nil
	term.clear()
	term.setCursorPos(1, 1)
	print("Connection closed by server")

elseif #args >= 1 then --either no server running or we are the local shell on the server.
	if not openModem() then
		print("No modems found. 1 required.")
		return 
	end
	local serverNum = getServerID(args[1])
	if not serverNum then
		print("Server Not Found")
		return
	end
	if ssh then
		local conns = ssh.getRemoteConnections()
		for i = 1, #conns do
			if conns[i] == serverNum then
				print("Connection refused.")
				return
			end
		end
	end
	local fileTransferState = nil
	local fileData = nil
	local fileBinaryData = nil
	local unpackCo = {}
	local color = term.isColor()
	local x, y = term.getSize()
	if args[2] == "resume" then
		send(serverNum, "query", "resume:"..tostring(color)..";"..tostring(x)..","..tostring(y))
	else
		send(serverNum, "query", "connect:"..tostring(color)..";"..tostring(x)..","..tostring(y))
	end
	local timeout = os.startTimer(2)
	while true do
		local event = {os.pullEvent()}
		if event[1] == "timer" and event[2] == timeout then
			print("Connection failed.")
			return
		elseif event[1] == "rednet_message" and event[2] == serverNum and type(event[3]) == "string" and string.sub(event[3], 1, 2) == "SR" then
			if ssh then sshAPI = ssh end
			if sshAPI.connList and sshAPI.connList.localShell then sshAPI.connList.localShell.outbound = serverNum end
			sshAPI.serverNum = serverNum
			sshAPI.clientCapabilities = "-fileTransfer-extensions-"
			term.clear()
			term.setCursorPos(1,1)
			break
		end
	end

	while true do
		event = {os.pullEventRaw()}
		if #unpackCo > 0 then
			for i = #unpackCo, 1, -1 do
				if coroutine.status(unpackCo[i]) ~= "dead" then
					coroutine.resume(unpackCo[i], unpack(event))
				else
					table.remove(unpackCo, i)
				end
			end
		end
		if event[1] == "rednet_message" and event[2] == serverNum and type(event[3]) == "string" then
			if packetConversion[string.sub(event[3], 1, 2)] then
				packetType = packetConversion[string.sub(event[3], 1, 2)]
				message = string.match(event[3], ";(.*)")
				if string.sub(packetType, 1, 4) == "text" then
					processText(serverNum, packetType, message)
				elseif packetType == "data" then
					if message == "clientCapabilities" then
						rednet.send(serverNum, sshAPI.clientCapabilities)
					end
				elseif packetType == "fileQuery" then
					--send a file to the server
					local mode, file = string.match(message, "^(%a)=(.*)")
					if fs.exists(file) then
						send(serverNum, "fileHeader", file)
						if mode == "b" then
							local fileString = sshAPI.packFile(file)
							send(serverNum, "fileData", "b="..fileString)
						else
							local handle = io.open(file, "r")
							if handle then
								send(serverNum, "fileData", "t="..handle:read("*a"))
								handle:close()
							end
						end
					else
						send(serverNum, "fileHeader", "fileNotFound")
					end
					send(serverNum, "fileEnd", "end")
				elseif packetType == "fileSend" then
					--receive a file from the server, but don't overwrite existing files.
					local mode, file = string.match(message, "^(%a)=(.*)")
					if not fs.exists(file) then
						fileTransferState = "receive_wait:"..file
						send(serverNum, "fileResponse", "ok")
						if mode == "b" then
							fileBinaryData = ""
							fileData = nil
						else
							fileData = ""
							fileBinaryData = nil
						end
					else
						send(serverNum, "fileResponse", "reject")
					end
				elseif packetType == "fileHeader" then
					if message == "fileNotFound" then
						fileTransferState = nil
					end
				elseif packetType == "fileData" then
					if fileTransferState and string.match(fileTransferState, "(.-):") == "receive_wait" then
						if string.match(message, "^(%a)=") == "b" then
							fileBinaryData = fileBinaryData..string.match(message, "^b=(.*)")
						else
							fileData = fileData..string.match(message, "^t=(.*)")
						end
					end
				elseif packetType == "fileEnd" then
					if fileTransferState and string.match(fileTransferState, "(.-):") == "receive_wait" then
						if fileBinaryData then
							local co = coroutine.create(sshAPI.unpackAndSaveFile)
							coroutine.resume(co, string.match(fileTransferState, ":(.*)"), fileBinaryData)
							if coroutine.status(co) ~= "dead" then
								table.insert(unpackCo, co)
							end
						elseif fileData then
							local handle = io.open(string.match(fileTransferState, ":(.*)"), "w")
							if handle then
								handle:write(fileData)
								handle:close()
							end
						end
						fileTransferState = nil
					end
				elseif packetType == "close" then
					if term.isColor() then
						term.setBackgroundColor(colors.black)
						term.setTextColor(colors.white)
					end
					term.clear()
					term.setCursorPos(1, 1)
					print("Connection closed by server.")
					sshAPI.serverNum = nil
					if sshAPI.connList and sshAPI.connList.localShell then sshAPI.connList.localShell.outbound = nil end
					return
				end
			end
		elseif event[1] == "mouse_click" or event[1] == "mouse_drag" or event[1] == "mouse_scroll" or event[1] == "key" or event[1] == "char" then
			--pack up event
			send(serverNum, "event", textutils.serialize(event))
		elseif event[1] == "terminate" then
			sshAPI.serverNum = nil
			if sshAPI.localShell then sshAPI.localShell.outbound = nil end
			term.clear()
			term.setCursorPos(1, 1)
			print("Connection closed locally.")
			return
		end
	end
else
	print("Usage: ssh <serverID> [resume]")
	print("       ssh host [remote [local [name]]]")
end