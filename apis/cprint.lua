--[[
    cPrint API by Jesusthekiller
    This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
	More info: http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US
]]--

function sc(x, y)
    term.setCursorPos(x, y)
end

function clear(move)
    sb(colors.black)
    term.clear()
    if move ~= false then sc(1,1) end
end

function sb(color)
    term.setBackgroundColor(color) 
end

function st(color)
    term.setTextColor(color)
end

function cCode(h)
	if term.isColor() and term.isColor then
		return 2 ^ (tonumber(h, 16) or 0)
	else
		if h == "f" then
			return colors.black
		else
			return colors.white
		end
	end
end

function toCode(n)
	return string.format('%x', n)
end

function cwrite(text)
	text = tostring(text)
	
	local i = 0
    while true  do
		i = i + 1
		if i > #text then break end
		
        local c = text:sub(i, i)

		if c == "\\" then
            if text:sub(i+1, i+1) == "&" then
                write("&")
                i = i + 1
            elseif text:sub(i+1, i+1) == "$" then
                write("$")
                i = i + 1
			else
				write(c)
            end
        elseif c == "&" then
            st(cCode(text:sub(i+1, i+1)))
            i = i + 1
        elseif c == "$" then
            sb(cCode(text:sub(i+1, i+1)))
            i = i + 1
        else
            write(c)
        end
    end
	
	return
end

function cprint(text)
	return cwrite(tostring(text).."\n")
end
