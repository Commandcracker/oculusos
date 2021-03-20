local a={["\n"]="\\n",["\r"]="\\r",["\t"]="\\t",["\b"]="\\b",["\f"]="\\f",["\""]="\\\"",["\\"]="\\\\"}local function b(t)local c=0;for d,e in pairs(t)do if type(d)~="number"then return false elseif d>c then c=d end end;return c==#t end;local f={['\n']=true,['\r']=true,['\t']=true,[' ']=true,[',']=true,[':']=true}function removeWhite(g)while f[g:sub(1,1)]do g=g:sub(2)end;return g end;local function h(i,j,k,l)local g=""local function m(n)g=g..("\t"):rep(k)..n end;local function o(i,p,q,r,s)g=g..p;if j then g=g.."\n"k=k+1 end;for d,e in r(i)do m("")s(d,e)g=g..","if j then g=g.."\n"end end;if j then k=k-1 end;if g:sub(-2)==",\n"then g=g:sub(1,-3).."\n"elseif g:sub(-1)==","then g=g:sub(1,-2)end;m(q)end;if type(i)=="table"then assert(not l[i],"Cannot encode a table holding itself recursively")l[i]=true;if b(i)then o(i,"[","]",ipairs,function(d,e)g=g..h(e,j,k,l)end)else o(i,"{","}",pairs,function(d,e)assert(type(d)=="string","JSON object keys must be strings",2)g=g..h(d,j,k,l)g=g..(j and": "or":")..h(e,j,k,l)end)end elseif type(i)=="string"then g='"'..i:gsub("[%c\"\\]",a)..'"'elseif type(i)=="number"or type(i)=="boolean"then g=tostring(i)else error("JSON only supports arrays, objects, numbers, booleans, and strings",2)end;return g end;function encode(i)return h(i,false,0,{})end;function encodePretty(i)return h(i,true,0,{})end;local u={}for d,e in pairs(a)do u[e]=d end;function parseBoolean(g)if g:sub(1,4)=="true"then return true,removeWhite(g:sub(5))else return false,removeWhite(g:sub(6))end end;function parseNull(g)return nil,removeWhite(g:sub(5))end;local v={['e']=true,['E']=true,['+']=true,['-']=true,['.']=true}function parseNumber(g)local w=1;while v[g:sub(w,w)]or tonumber(g:sub(w,w))do w=w+1 end;local i=tonumber(g:sub(1,w-1))g=removeWhite(g:sub(w))return i,g end;function parseString(g)g=g:sub(2)local n=""while g:sub(1,1)~="\""do local x=g:sub(1,1)g=g:sub(2)assert(x~="\n","Unclosed string")if x=="\\"then local y=g:sub(1,1)g=g:sub(2)x=assert(u[x..y],"Invalid escape character")end;n=n..x end;return n,removeWhite(g:sub(2))end;function parseArray(g)g=removeWhite(g:sub(2))local i={}local w=1;while g:sub(1,1)~="]"do local e=nil;e,g=parseValue(g)i[w]=e;w=w+1;g=removeWhite(g)end;g=removeWhite(g:sub(2))return i,g end;function parseObject(g)g=removeWhite(g:sub(2))local i={}while g:sub(1,1)~="}"do local d,e=nil,nil;d,e,g=parseMember(g)i[d]=e;g=removeWhite(g)end;g=removeWhite(g:sub(2))return i,g end;function parseMember(g)local d=nil;d,g=parseValue(g)local i=nil;i,g=parseValue(g)return d,i,g end;function parseValue(g)local z=g:sub(1,1)if z=="{"then return parseObject(g)elseif z=="["then return parseArray(g)elseif tonumber(z)~=nil or v[z]then return parseNumber(g)elseif g:sub(1,4)=="true"or g:sub(1,5)=="false"then return parseBoolean(g)elseif z=="\""then return parseString(g)elseif g:sub(1,4)=="null"then return parseNull(g)end;return nil end;function decode(g)g=removeWhite(g)t=parseValue(g)return t end;function decodeFromFile(A)local B=assert(fs.open(A,"r"))local C=decode(B.readAll())B.close()return C end;local function D(E,A)local B=fs.open(A,"w")B.write(E)B.close()print(A)end;local function F(G)local H=http.get(G)if not H then return nil end;local I=H.readAll()H.close()return I end;local function J(G,A)D(F(G),A)end;local function K(K)if K==nil then else if term.isColor()then term.setTextColour(colors.orange)end;term.write(K.."? [")if term.isColor()then term.setTextColour(colors.lime)end;term.write('Y')if term.isColor()then term.setTextColour(colors.orange)end;term.write('/')if term.isColor()then term.setTextColour(colors.red)end;term.write('n')if term.isColor()then term.setTextColour(colors.orange)end;term.write("] ")term.setTextColour(colors.white)end;local L=string.lower(string.sub(read(),1,1))if L=='y'or L=='j'or L==''then return true else return false end end;local function M(string,N)local O={}local P=1;local Q,R=string.find(string,N,P)while Q do table.insert(O,string.sub(string,P,Q-1))P=R+1;Q,R=string.find(string,N,P)end;table.insert(O,string.sub(string,P))return O end;local S={owner="Commandcracker",repo="oculusos",branch="master"}local G="https://raw.githubusercontent.com/"..S.owner..'/'..S.repo..'/'..S.branch..'/'local T=G.."build/"local U=G.."src/"local V={...}term.clear()term.setCursorPos(1,1)if V[1]then _question="Update OculusOS"else _question="Install OculusOS"end;if K(_question)then else if term.isColor()then term.setTextColour(colors.red)end;print("Abort.")term.setTextColour(colors.white)return end;print()if term.isColor()then term.setTextColour(colors.lime)end;print("Downloading")if term.isColor()then term.setTextColour(colors.blue)end;print()local W={}if not fs.exists(".shellrc")then table.insert(W,function()J(G..".shellrc.lua","/.shellrc")end)end;local X="bootscreen/"if turtle then X=X.."turtle/"else if pocket then X=X.."pocket/"else X=X.."computer/"end end;if term.isColor()then X=X.."colord.nfp"else X=X.."default.nfp"end;table.insert(W,function()J(G..X,"/.bootscreen")end)table.insert(W,function()J(T.."startup.lua","/startup")end)if shell.resolveProgram("/rom/programs/http/wget")==nil then table.insert(W,function()J(T.."fix/wget.lua","/bin/wget")end)end;if tonumber(M(os.version(),' ')[2])<=1.7 then table.insert(W,function()J(T.."fix/pastebin.lua","/bin/pastebin")end)end;parallel.waitForAll(function()for Y in F(U.."boot/index"):gmatch("([^\n]*)\n?")do table.insert(W,function()J(T.."boot/"..Y..".lua","/boot/"..Y)end)end end,function()for Y in F(U.."lib/index"):gmatch("([^\n]*)\n?")do table.insert(W,function()J(T.."lib/"..Y..".lua","/lib/"..Y)end)end end,function()for Y in F(U.."bin/index"):gmatch("([^\n]*)\n?")do table.insert(W,function()J(T.."bin/"..Y..".lua","/bin/"..Y)end)end end,function()if not pocket then for Y in F(U.."bin/not_pocket/index"):gmatch("([^\n]*)\n?")do table.insert(W,function()J(T.."bin/not_pocket/"..Y..".lua","/bin/"..Y)end)end end end)table.insert(W,function()D(encode({git={owner=S.owner,repo=S.repo,branch=S.branch,commit=decode(F("https://api.github.com/repos/"..S.owner..'/'..S.repo.."/git/refs/heads/"..S.branch)).object.sha},colord=term.isColor()}),"/.system_info")end)parallel.waitForAll(table.unpack(W))print()if not V[1]and settings and not pocket then settings.set("shell.allow_disk_startup",false)settings.save()end;term.setTextColour(colors.white)if K("Reboot now")then print()if term.isColor()then term.setTextColor(colors.orange)end;print("Rebooting computer")sleep(3)os.reboot()end