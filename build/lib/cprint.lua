--[[
cPrint API by Jesusthekiller
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
More info: http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US
]]
function sc(a,b)term.setCursorPos(a,b)end;function clear(c)sb(colors.black)term.clear()if c~=false then sc(1,1)end end;function sb(d)term.setBackgroundColor(d)end;function st(d)term.setTextColor(d)end;function cCode(e)if term.isColor()and term.isColor then return 2^(tonumber(e,16)or 0)else if e=="f"then return colors.black else return colors.white end end end;function toCode(f)return string.format('%x',f)end;function cwrite(g)g=tostring(g)local h=0;while true do h=h+1;if h>#g then break end;local i=g:sub(h,h)if i=="\\"then if g:sub(h+1,h+1)=="&"then write("&")h=h+1 elseif g:sub(h+1,h+1)=="$"then write("$")h=h+1 else write(i)end elseif i=="&"then st(cCode(g:sub(h+1,h+1)))h=h+1 elseif i=="$"then sb(cCode(g:sub(h+1,h+1)))h=h+1 else write(i)end end;return end;function cprint(g)return cwrite(tostring(g).."\n")end