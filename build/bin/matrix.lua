--[[
--(c) 2013 Felix Maxwell
--License: CC BY-SA 3.0
https://creativecommons.org/licenses/by-sa/3.0
]]
local a=8;local b=40;local c=8;local d=5;local e=0;local f=8;local g=2;function getMonitors()local h={}if checkMonitorSide("top")then table.insert(h,"top")end;if checkMonitorSide("bottom")then table.insert(h,"bottom")end;if checkMonitorSide("left")then table.insert(h,"left")end;if checkMonitorSide("right")then table.insert(h,"right")end;if checkMonitorSide("front")then table.insert(h,"front")end;if checkMonitorSide("back")then table.insert(h,"back")end;return h end;function checkMonitorSide(i)if peripheral.isPresent(i)then if peripheral.getType(i)=="monitor"then return true end end;return false end;function printMonitorStats(i)local j,k=peripheral.call(i,"getSize")local l="No"if peripheral.call(i,"isColor")then l="Yes"end;print("Side:"..i.." Size:("..j..", "..k..") Color?"..l)end;function askMonitor()local h=getMonitors()if#h==0 then print("No monitors found, add more!")return nill elseif#h==1 then return h[1]else while true do print("Multiple monitors found, please pick one.")for m,n in ipairs(h)do write("["..m.."] ")printMonitorStats(n)end;write("Selection: ")local o=tonumber(io.read())if o<1 or o>#h then print("")print("Invalid number.")else return h[o]end end end end;function printCharAt(p,j,k,q)p.setCursorPos(j,k)p.write(q)end;function printGrid(p,r,l)for m=1,#r do for s=1,#r[m]do if l then p.setTextColor(r[m][s]["color"])end;printCharAt(p,m,s,r[m][s]["char"])end end end;function colorLifetime(t,u)local v=u/10;if t<g*v then return colors.gray elseif t<f*v then return colors.green else return colors.lime end end;function getRandomChar()local w={"1","2","3","4","5","6","7","8","9","0","!","@","#","$","%","^","&","*","(",")","_","-","+","=","~","`",",","<",">",".","/","?",":","{","}","[","]","\\","\"","\'"}return w[math.random(1,#w)]end;function tick(x)for j=1,#x do for k=1,#x[j]do x[j][k]["curLife"]=x[j][k]["curLife"]-1 end end;for j=1,#x do for k=1,#x[j]do if x[j][k]["type"]=="source"and x[j][k]["curLife"]==0 then x[j][k]["type"]="char"x[j][k]["lifetime"]=math.random(c,b)x[j][k]["curLife"]=x[j][k]["lifetime"]x[j][k]["color"]=colors.lime;if k<#x[j]then x[j][k+1]["char"]=getRandomChar()x[j][k+1]["lifetime"]=1;x[j][k+1]["curLife"]=1;x[j][k+1]["type"]="source"x[j][k+1]["color"]=colors.white end elseif x[j][k]["curLife"]<0 then x[j][k]["char"]=" "x[j][k]["lifetime"]=0;x[j][k]["curLife"]=0;x[j][k]["type"]="blank"x[j][k]["color"]=colors.black elseif x[j][k]["type"]=="char"then x[j][k]["color"]=colorLifetime(x[j][k]["curLife"],x[j][k]["lifetime"])end end end;local y=math.random(0-e,d)for m=1,y do local z=math.random(1,#x)x[z][1]["char"]=getRandomChar()x[z][1]["lifetime"]=1;x[z][1]["curLife"]=1;x[z][1]["type"]="source"x[z][1]["color"]=colors.white end;return x end;function setup(A,B)local C={}for j=1,A do C[j]={}for k=1,B do C[j][k]={}C[j][k]["char"]=" "C[j][k]["lifetime"]=0;C[j][k]["curLife"]=0;C[j][k]["type"]="blank"C[j][k]["color"]=colors.black end end;return C end;function run()local l=term.isColor()local A,B=term.getSize()local x=setup(A,B)while true do x=tick(x)printGrid(term,x,l)os.sleep(1/a)end end;run()