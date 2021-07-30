local a={}local b={["\n"]="\\n",["\r"]="\\r",["\t"]="\\t",["\b"]="\\b",["\f"]="\\f",["\""]="\\\"",["\\"]="\\\\"}local function c(t)local d=0;for e,f in pairs(t)do if type(e)~="number"then return false elseif e>d then d=e end end;return d==#t end;local g={['\n']=true,['\r']=true,['\t']=true,[' ']=true,[',']=true,[':']=true}function a.removeWhite(h)while g[h:sub(1,1)]do h=h:sub(2)end;return h end;local function i(j,k,l,m)local h=""local function n(o)h=h..("\t"):rep(l)..o end;local function p(j,q,r,s,u)h=h..q;if k then h=h.."\n"l=l+1 end;for e,f in s(j)do n("")u(e,f)h=h..","if k then h=h.."\n"end end;if k then l=l-1 end;if h:sub(-2)==",\n"then h=h:sub(1,-3).."\n"elseif h:sub(-1)==","then h=h:sub(1,-2)end;n(r)end;if type(j)=="table"then assert(not m[j],"Cannot encode a table holding itself recursively")m[j]=true;if c(j)then p(j,"[","]",ipairs,function(e,f)h=h..i(f,k,l,m)end)else p(j,"{","}",pairs,function(e,f)assert(type(e)=="string","JSON object keys must be strings",2)h=h..i(e,k,l,m)h=h..(k and": "or":")..i(f,k,l,m)end)end elseif type(j)=="string"then h='"'..j:gsub("[%c\"\\]",b)..'"'elseif type(j)=="number"or type(j)=="boolean"then h=tostring(j)else error("JSON only supports arrays, objects, numbers, booleans, and strings",2)end;return h end;function a.encode(j)return i(j,false,0,{})end;function a.encodePretty(j)return i(j,true,0,{})end;local v={}for e,f in pairs(b)do v[f]=e end;function a.parseBoolean(h)if h:sub(1,4)=="true"then return true,a.removeWhite(h:sub(5))else return false,a.removeWhite(h:sub(6))end end;function a.parseNull(h)return nil,a.removeWhite(h:sub(5))end;local w={['e']=true,['E']=true,['+']=true,['-']=true,['.']=true}function a.parseNumber(h)local x=1;while w[h:sub(x,x)]or tonumber(h:sub(x,x))do x=x+1 end;local j=tonumber(h:sub(1,x-1))h=a.removeWhite(h:sub(x))return j,h end;function a.parseString(h)h=h:sub(2)local o=""while h:sub(1,1)~="\""do local y=h:sub(1,1)h=h:sub(2)assert(y~="\n","Unclosed string")if y=="\\"then local z=h:sub(1,1)h=h:sub(2)y=assert(v[y..z],"Invalid escape character")end;o=o..y end;return o,a.removeWhite(h:sub(2))end;function a.parseArray(h)h=a.removeWhite(h:sub(2))local j={}local x=1;while h:sub(1,1)~="]"do local f=nil;f,h=a.parseValue(h)j[x]=f;x=x+1;h=a.removeWhite(h)end;h=a.removeWhite(h:sub(2))return j,h end;function a.parseObject(h)h=a.removeWhite(h:sub(2))local j={}while h:sub(1,1)~="}"do local e,f=nil,nil;e,f,h=a.parseMember(h)j[e]=f;h=a.removeWhite(h)end;h=a.removeWhite(h:sub(2))return j,h end;function a.parseMember(h)local e=nil;e,h=a.parseValue(h)local j=nil;j,h=a.parseValue(h)return e,j,h end;function a.parseValue(h)local A=h:sub(1,1)if A=="{"then return a.parseObject(h)elseif A=="["then return a.parseArray(h)elseif tonumber(A)~=nil or w[A]then return a.parseNumber(h)elseif h:sub(1,4)=="true"or h:sub(1,5)=="false"then return a.parseBoolean(h)elseif A=="\""then return a.parseString(h)elseif h:sub(1,4)=="null"then return a.parseNull(h)end;return nil end;function a.decode(h)h=a.removeWhite(h)t=a.parseValue(h)return t end;function a.decodeFromFile(B)local C=assert(fs.open(B,"r"))local D=a.decode(C.readAll())C.close()return D end;local function E(F)local G=http.get(F)if not G then return nil end;local H=G.readAll()G.close()return H end;local function I(_question)if _question==nil then else if term.isColor()then term.setTextColour(colors.orange)end;term.write(_question.."? [")if term.isColor()then term.setTextColour(colors.lime)end;term.write('Y')if term.isColor()then term.setTextColour(colors.orange)end;term.write('/')if term.isColor()then term.setTextColour(colors.red)end;term.write('n')if term.isColor()then term.setTextColour(colors.orange)end;term.write("] ")term.setTextColour(colors.white)end;local J=string.lower(string.sub(read(),1,1))if J=='y'or J=='j'or J==''then return true else return false end end;local function K(string,L)local M={}local N=1;local O,P=string.find(string,L,N)while O do table.insert(M,string.sub(string,N,O-1))N=P+1;O,P=string.find(string,L,N)end;table.insert(M,string.sub(string,N))return M end;local function Q(R,B,S)local C=fs.open(B,"w")C.write(R)C.close()if not S then print(B)end end;local function T(F,B,S)local U,V=http.get(F)if U then Q(U.readAll(),B,S)U.close()else printError("Faild to download: "..F)printError(V)end end;local function W(F,X)local Y="/tmp/"..X;T(F,Y,true)local Z=dofile(Y)fs.delete(Y)return Z end;local function _(a0)if term.isColor()then term.setTextColour(a0)end end;local a1={owner="Commandcracker",repo="oculusos",branch="master"}local F="https://raw.githubusercontent.com/"..a1.owner..'/'..a1.repo..'/'..a1.branch..'/'local a2=F.."build/"local a3=F.."src/"local a4={...}local a5=true;local a6={}local a7=false;if a4[1]then a7=true end;if fs.exists("/.system_info")then a7=true;local C=fs.open("/.system_info","r")local a8=a.decode(C.readLine())if a8.minimized~=nil then a5=a8.minimized end;if a8.git.branch~=nil then a1.branch=a8.git.branch end;C.close()end;if a7 then _question="Update OculusOS"else _question="Install OculusOS"end;if I(_question)then else printError("Abort.")return end;if not a7 then a5=I("Minimize OculusOS")end;if a5~=true then a2=F.."src/"end;if not a7 then local a9,aa;if a5 then a9="https://raw.githubusercontent.com/Commandcracker/CC-pack/master/build/lib/pack.lua"aa="pack"else a9="https://raw.githubusercontent.com/Commandcracker/CC-pack/master/src/lib/pack.lua"aa="pack-src"end;term.setTextColour(colors.white)print("Installing Pack")local function ab()local ac=W(a9,"pack")if not fs.exists("/etc/pack/sources.list")then local ad=fs.open("/etc/pack/sources.list","w")ad.writeLine("pack https://raw.githubusercontent.com/Commandcracker/CC-pack/master/packages.json")ad.writeLine("commandcracker https://raw.githubusercontent.com/Commandcracker/CC-packages/master/packages.json")ad.close()ac.fetchSources(true)end;for ae,af in pairs(ac.getPackages())do for X,ag in pairs(af)do if X==aa then if ac.isPackageInstalled(ae.."/"..X)then printError("Pack is already installed")return true end;ac.installPackage(ae.."/"..X,ag,shell)return true end end end;return false end;if not ab()then printError("Faild to install pack")end end;if not a7 then term.setTextColour(colors.white)print("Installing OculusOS")end;_(colors.lime)print("Downloading")_(colors.blue)if not fs.exists(".shellrc")then table.insert(a6,function()T(F..".shellrc.lua","/.shellrc")end)end;local ah="bootscreen/"if turtle then ah=ah.."turtle/"else if pocket then ah=ah.."pocket/"else ah=ah.."computer/"end end;if term.isColor()then ah=ah.."colord.nfp"else ah=ah.."default.nfp"end;table.insert(a6,function()T(F..ah,"/.bootscreen")end)table.insert(a6,function()T(a2 .."startup.lua","/startup")end)if shell.resolveProgram("/rom/programs/http/wget")==nil then table.insert(a6,function()T(a2 .."fix/wget.lua","/bin/wget")end)end;if tonumber(K(os.version(),' ')[2])<=1.7 then table.insert(a6,function()T(a2 .."fix/pastebin.lua","/bin/pastebin")end)table.insert(a6,function()T(a2 .."fix/00_fix.lua","/lib/00_fix")end)end;parallel.waitForAll(function()for ai in E(a3 .."boot/index"):gmatch("([^\n]*)\n?")do if ai~=""then table.insert(a6,function()T(a2 .."boot/"..ai..".lua","/boot/"..ai)end)end end end,function()for ai in E(a3 .."lib/index"):gmatch("([^\n]*)\n?")do if ai~=""then table.insert(a6,function()T(a2 .."lib/"..ai..".lua","/lib/"..ai)end)end end end,function()for ai in E(a3 .."bin/index"):gmatch("([^\n]*)\n?")do if ai~=""then table.insert(a6,function()T(a2 .."bin/"..ai..".lua","/bin/"..ai)end)end end end,function()if not pocket then for ai in E(a3 .."bin/not_pocket/index"):gmatch("([^\n]*)\n?")do if ai~=""then table.insert(a6,function()T(a2 .."bin/not_pocket/"..ai..".lua","/bin/"..ai)end)end end end end)table.insert(a6,function()Q(a.encode({git={owner=a1.owner,repo=a1.repo,branch=a1.branch,commit=a.decode(E("https://api.github.com/repos/"..a1.owner..'/'..a1.repo.."/git/refs/heads/"..a1.branch)).object.sha},colord=term.isColor(),minimized=a5}),"/.system_info")end)parallel.waitForAll(table.unpack(a6))if not a7 and settings and not pocket then settings.set("shell.allow_disk_startup",false)settings.save()end;term.setTextColour(colors.white)if I("Reboot now")then _(colors.orange)print("Rebooting computer")sleep(1)os.reboot()end