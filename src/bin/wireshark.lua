local tArgs = { ... }
local TermW,TermH = term.getSize()

--Functions--
local function openModems(_channel)
	for _, side in ipairs(rs.getSides()) do
        if peripheral.getType(side) == "modem" then
            local modem = peripheral.wrap(side)
            modem.closeAll()
			modem.open(_channel)
		end
	end
end

local function Modems_transmit(_channel, _replyChannel, _message)
    print("Transmitting Message")
	for _, side in ipairs(rs.getSides()) do
        if peripheral.getType(side) == "modem" then
            local modem = peripheral.wrap(side)
			modem.transmit(_channel, _replyChannel, _message)
		end
    end
    sleep(1)
end

local function display(_side, _frequency, _replyFrequency, _message, _distance)
    term.clear()
    term.setCursorPos(1,1)
    if term.isColor() then
        term.setTextColour(colors.red)
    end
    print("Side: ".._side)
    if term.isColor() then
        term.setTextColour(colors.blue)
    end
    print("Frequency: ".._frequency)
    print("Reply frequency: ".._replyFrequency)
    print("Distance: ".._distance)
    if term.isColor() then
        term.setTextColour(colors.orange)
    end
    print("Message: "..textutils.serialize(_message))
end

local function menu(options, title) 
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
        
        oculusos.printCentred(2, title)
        
        for i in ipairs(options) do
            term.setCursorPos(4,5 + i)
            term.write(" "..options[i])
        end

        term.setCursorPos(4,selected+5)
        term.write("*")

        paintutils.drawBox(2,4,TermW -1,7 + #options,colors.white)

        --Event
        local event, key = os.pullEvent()
        
        --Keys
        if event == "key" then
        
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

local channel

if #tArgs > 0 then
    channel = tonumber(tArgs[1])
else
    channel = 65533
end

openModems(channel)
term.clear()
term.setCursorPos(1,1)

local sniffed = {}

local function sniff()
    while true do
        local event, side, frequency, replyFrequency, message, distance = os.pullEvent()

        if event == "mouse_click" or event == "key" or event == "paste" or event == "char" then
            break

        elseif event == "modem_message" then

            display(side, frequency, replyFrequency, message, distance)

            table.insert( sniffed, {
                ["Side"] = side,
                ["Frequency"] = frequency,
                ["ReplyFrequency"] = replyFrequency,
                ["Message"] = message,
                ["Distance"] = distance
            })

        end

    end
end

sniff()

local selected = 1

local function select_sniffed()
    while true do

        display(sniffed[selected]["Side"], sniffed[selected]["Frequency"], sniffed[selected]["ReplyFrequency"], sniffed[selected]["Message"], sniffed[selected]["Distance"])

        if term.isColor() then
            term.setTextColour(colors.lime)
        end
        print(selected .."/"..#sniffed)

        local event, key = os.pullEvent( "key" )
        
        if key == keys.left then
            selected = selected -1
            if selected == 0 then
                selected = #sniffed
            end
        elseif key == keys.right then
            selected = selected +1
            if #sniffed < selected then
                selected = 1
            end
        elseif key == keys.enter then
            break
        end

    end
end

select_sniffed()

local function task_menu()
    term.setTextColour(colors.white)

    task = menu({
        "----", -- Save
        "Repet",
        "Exit",
        "Sniff",
        "Back"
    },
    "Select"
    )

    if term.isColor() then
        term.setBackgroundColor(colors.black)
    end

    term.clear()
    term.setCursorPos(1,1)

    if task == 1 then
        print(task)
    elseif task == 2 then
        term.clear()
        term.setCursorPos(1,1)
        Modems_transmit(sniffed[selected]["Frequency"], sniffed[selected]["ReplyFrequency"], sniffed[selected]["Message"])
        task_menu()
    elseif task == 3 then
        return
    elseif task == 4 then
        sniff()
        select_sniffed()
        task_menu()
    elseif task == 5 then
        select_sniffed()
        task_menu()
    end

end

task_menu()