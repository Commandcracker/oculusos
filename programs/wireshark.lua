local tArgs = { ... }

local function openModems(_channel)
	for _, side in ipairs(rs.getSides()) do
        if peripheral.getType(side) == "modem" then
            local modem = peripheral.wrap(side)
            modem.closeAll()
			modem.open(_channel)
		end
	end
end

local channel

if #tArgs > 0 then
    channel = tonumber(tArgs[1])
else
    channel = 65533
end

openModems(channel)
term.clear()
term.setCursorPos(1,1)

while true do
    event, side, frequency, replyFrequency, message, distance = os.pullEvent("modem_message")
    term.clear()
    term.setCursorPos(1,1)
    if term.isColor() then
        term.setTextColour(colors.red)
    end
    print("Side: "..side)
    if term.isColor() then
        term.setTextColour(colors.blue)
    end
    print("Frequency: "..frequency)
    print("Reply frequency: "..replyFrequency)
    print("Distance: "..distance)
    if term.isColor() then
        term.setTextColour(colors.orange)
    end
    print("Message: "..textutils.serialize(message))
    textutils.tabulate() 
end
