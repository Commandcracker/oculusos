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

while true do
    event, side, frequency, replyFrequency, message, distance = os.pullEvent("modem_message")
    print("Side: "..side)
    print("Frequency: "..frequency)
    print("Reply frequency: "..replyFrequency)
    print("Distance: "..distance)
    print("Message: "..textutils.serialize(message))
end
