local a={["\n"]="\\n",["\r"]="\\r",["\t"]="\\t",["\b"]="\\b",["\f"]="\\f",["\""]="\\\"",["\\"]="\\\\"}local function b(t)local c=0;for d,e in pairs(t)do if type(d)~="number"then return false elseif d>c then c=d end end;return c==#t end;local g={['\n']=true,['\r']=true,['\t']=true,[' ']=true,[',']=true,[':']=true}local function h(i)while g[i:sub(1,1)]do i=i:sub(2)end;return i end;local function j(k,l,m,n)local i=""local function o(p)i=i..("\t"):rep(m)..p end;local function q(k,r,s,u,v)i=i..r;if l then i=i.."\n"m=m+1 end;for d,e in u(k)do o("")v(d,e)i=i..","if l then i=i.."\n"end end;if l then m=m-1 end;if i:sub(-2)==",\n"then i=i:sub(1,-3).."\n"elseif i:sub(-1)==","then i=i:sub(1,-2)end;o(s)end;if type(k)=="table"then assert(not n[k],"Cannot encode a table holding itself recursively")n[k]=true;if b(k)then q(k,"[","]",ipairs,function(d,e)i=i..j(e,l,m,n)end)else q(k,"{","}",pairs,function(d,e)assert(type(d)=="string","JSON object keys must be strings",2)i=i..j(d,l,m,n)i=i..(l and": "or":")..j(e,l,m,n)end)end elseif type(k)=="string"then i='"'..k:gsub("[%c\"\\]",a)..'"'elseif type(k)=="number"or type(k)=="boolean"then i=tostring(k)else error("JSON only supports arrays, objects, numbers, booleans, and strings",2)end;return i end;local function w(k)return j(k,false,0,{})end;local function x(k)return j(k,true,0,{})end;local y={}for d,e in pairs(a)do y[e]=d end;local function z(i)if i:sub(1,4)=="true"then return true,h(i:sub(5))else return false,h(i:sub(6))end end;local function A(i)return nil,h(i:sub(5))end;local B={['e']=true,['E']=true,['+']=true,['-']=true,['.']=true}local function C(i)local D=1;while B[i:sub(D,D)]or tonumber(i:sub(D,D))do D=D+1 end;local k=tonumber(i:sub(1,D-1))i=h(i:sub(D))return k,i end;local function E(i)i=i:sub(2)local p=""while i:sub(1,1)~="\""do local F=i:sub(1,1)i=i:sub(2)assert(F~="\n","Unclosed string")if F=="\\"then local G=i:sub(1,1)i=i:sub(2)F=assert(y[F..G],"Invalid escape character")end;p=p..F end;return p,h(i:sub(2))end;local function H(i)i=h(i:sub(2))local k={}local D=1;while i:sub(1,1)~="]"do local e=nil;e,i=parseValue(i)k[D]=e;D=D+1;i=h(i)end;i=h(i:sub(2))return k,i end;local function I(i)i=h(i:sub(2))local k={}while i:sub(1,1)~="}"do local d,e=nil,nil;d,e,i=parseMember(i)k[d]=e;i=h(i)end;i=h(i:sub(2))return k,i end;function parseMember(i)local d=nil;d,i=parseValue(i)local k=nil;k,i=parseValue(i)return d,k,i end;function parseValue(i)local J=i:sub(1,1)if J=="{"then return I(i)elseif J=="["then return H(i)elseif tonumber(J)~=nil or B[J]then return C(i)elseif i:sub(1,4)=="true"or i:sub(1,5)=="false"then return z(i)elseif J=="\""then return E(i)elseif i:sub(1,4)=="null"then return A(i)end;return nil end;local function K(i)i=h(i)t=parseValue(i)return t end;local function L(M)local N=assert(fs.open(M,"r"))local O=K(N.readAll())N.close()return O end;local function P(Q,M)local N=fs.open(M,"w")N.write(Q)N.close()print(M)end;local function R(S)local T=http.get(S)if not T then return nil end;local U=T.readAll()T.close()return U end;local function V(S,M)P(R(S),M)end;local function W(W)if W==nil then else if term.isColor()then term.setTextColour(colors.orange)end;term.write(W.."? [")if term.isColor()then term.setTextColour(colors.lime)end;term.write('Y')if term.isColor()then term.setTextColour(colors.orange)end;term.write('/')if term.isColor()then term.setTextColour(colors.red)end;term.write('n')if term.isColor()then term.setTextColour(colors.orange)end;term.write("] ")term.setTextColour(colors.white)end;local X=string.lower(string.sub(read(),1,1))if X=='y'or X=='j'or X==''then return true else return false end end;local function Y(string,Z)local _={}local a0=1;local a1,a2=string.find(string,Z,a0)while a1 do table.insert(_,string.sub(string,a0,a1-1))a0=a2+1;a1,a2=string.find(string,Z,a0)end;table.insert(_,string.sub(string,a0))return _ end;local a3={owner="Commandcracker",repo="oculusos",branch="master"}local S="https://raw.githubusercontent.com/"..a3.owner..'/'..a3.repo..'/'..a3.branch..'/'local a4=S.."build/"local a5=S.."src/"local a6={...}local a7=true;term.clear()term.setCursorPos(1,1)if a6[1]then _question="Update OculusOS"f=fs.open("/.system_info","r")if f then system_info=K(f.readLine())if system_info.minimized~=nil then a7=system_info.minimized end;if system_info.git.branch~=nil then a3.branch=system_info.git.branch end end else _question="Install OculusOS"end;if W(_question)then else printError("Abort.")return end;if not a6[1]then a7=W("Minimize OculusOS")end;if a7~=true then a4=S.."src/"end;print()if term.isColor()then term.setTextColour(colors.lime)end;print("Downloading")if term.isColor()then term.setTextColour(colors.blue)end;print()local a8={}if not fs.exists(".shellrc")then table.insert(a8,function()V(S..".shellrc.lua","/.shellrc")end)end;local a9="bootscreen/"if turtle then a9=a9 .."turtle/"else if pocket then a9=a9 .."pocket/"else a9=a9 .."computer/"end end;if term.isColor()then a9=a9 .."colord.nfp"else a9=a9 .."default.nfp"end;table.insert(a8,function()V(S..a9,"/.bootscreen")end)table.insert(a8,function()V(a4 .."startup.lua","/startup")end)if shell.resolveProgram("/rom/programs/http/wget")==nil then table.insert(a8,function()V(a4 .."fix/wget.lua","/bin/wget")end)end;if tonumber(Y(os.version(),' ')[2])<=1.7 then table.insert(a8,function()V(a4 .."fix/pastebin.lua","/bin/pastebin")end)table.insert(a8,function()V(a4 .."fix/00_fix.lua","/bin/00_fix")end)end;parallel.waitForAll(function()for aa in R(a5 .."boot/index"):gmatch("([^\n]*)\n?")do if aa~=""then table.insert(a8,function()V(a4 .."boot/"..aa..".lua","/boot/"..aa)end)end end end,function()for aa in R(a5 .."lib/index"):gmatch("([^\n]*)\n?")do if aa~=""then table.insert(a8,function()V(a4 .."lib/"..aa..".lua","/lib/"..aa)end)end end end,function()for aa in R(a5 .."bin/index"):gmatch("([^\n]*)\n?")do if aa~=""then table.insert(a8,function()V(a4 .."bin/"..aa..".lua","/bin/"..aa)end)end end end,function()if not pocket then for aa in R(a5 .."bin/not_pocket/index"):gmatch("([^\n]*)\n?")do if aa~=""then table.insert(a8,function()V(a4 .."bin/not_pocket/"..aa..".lua","/bin/"..aa)end)end end end end)table.insert(a8,function()P(w({git={owner=a3.owner,repo=a3.repo,branch=a3.branch,commit=K(R("https://api.github.com/repos/"..a3.owner..'/'..a3.repo.."/git/refs/heads/"..a3.branch)).object.sha},colord=term.isColor(),minimized=a7}),"/.system_info")end)parallel.waitForAll(table.unpack(a8))print()if not a6[1]and settings and not pocket then settings.set("shell.allow_disk_startup",false)settings.save()end;term.setTextColour(colors.white)if W("Reboot now")then print()if term.isColor()then term.setTextColor(colors.orange)end;print("Rebooting computer")sleep(3)os.reboot()end