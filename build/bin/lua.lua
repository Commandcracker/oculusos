local a,b,c,d,e,f=colours.green,colours.cyan,term.getTextColour(),colours.yellow,colours.grey,colours.red;local g,h,i=colours.magenta,colours.grey,colours.lightGrey;local j={["and"]=d,["break"]=d,["do"]=d,["else"]=d,["elseif"]=d,["end"]=d,["false"]=i,["for"]=d,["function"]=d,["if"]=d,["in"]=d,["local"]=d,["nil"]=i,["not"]=d,["or"]=d,["repeat"]=d,["return"]=d,["then"]=d,["true"]=i,["until"]=d,["while"]=d}local k={{"^%s+",c},{"^[%a_][%w_]*",function(l)return j[l]or c end},{"^%-%-%[%[.-%]%]",e},{"^%-%-.*",e},{[[^".-[^\]"]],f},{[[^"[^"]*"?]],f},{[[^'.-[^\]']],f},{[[^'[^"]*'?]],f},{"^%[%[.-%]%]",f},{"^0x[a-fA-F0-9]*",g},{"^%d+%.%d*e[-+]?%d*",g},{"^%d+%.%d*",g},{"^%d+e[-+]?%d*",g},{"^%d+",g},{"^%.%d*e[-+]?%d*",g},{"^%.%d*",g},{"^[^%w_]",c}}local function m(n,o)local p,type=string.find,type;for q=1,#k do local r=k[q]local s,t=p(n,r[1],o)if t then if type(r[2])=="function"then return t,r[2](n:sub(s,t))else return t,r[2]end end end;return#n,c end;local function u(v,w)term.setTextColour(v)write(w)end;local function x(y,z)local A,B=type(y),type(z)if A=="string"then return B~="string"or y<z elseif B=="string"then return false end;if A=="number"then return B~="number"or y<z end;return false end;local C=type(debug)=="table"and type(debug.getinfo)=="function"and debug.getinfo;local D=type(debug)=="table"and type(debug.getlocal)=="function"and debug.getlocal;local function E(F)local G=C and C(F,"Su")local H;if G and G.short_src and G.linedefined and G.linedefined>=1 then H="function<"..G.short_src..":"..G.linedefined..">"else H=tostring(F)end;if G and G.what=="Lua"and G.nparams and D then local I={}for q=1,G.nparams do I[q]=D(F,q)or"?"end;if G.isvararg then I[#I+1]="..."end;H=H.."("..table.concat(I,", ")..")"end;return H end;local function J(K,L,M)local N=type(K)if N=="string"then return#string.format("%q",K):gsub("\\\n","\\n")elseif N=="function"then return#E(K)elseif N~="table"or L[K]then return#tostring(K)end;local O=2;L[K]=true;for P,Q in pairs(K)do O=O+J(P,L,M)+J(Q,L,M)if O>=M then break end end;L[K]=nil;return O end;local function R(K,L,S,T,U,V)local N=type(K)if N=="string"then local W=string.format("%q",K):gsub("\\\n","\\n")local M=math.max(8,math.floor(S*T*0.8))if#W>M then u(f,W:sub(1,M-3))u(h,"...")else u(f,W)end;return elseif N=="number"then return u(g,tostring(K))elseif N=="function"then return u(i,E(K))elseif N~="table"or L[K]then return u(i,tostring(K))elseif(getmetatable(K)or{}).__tostring then return u(c,tostring(K))end;local X,Y="{","}"if V then X,Y="(",")"end;if(V==nil or V==0)and next(K)==nil then return u(c,X..Y)elseif S<=7 then u(c,X)u(h," ... ")u(c,Y)return end;local Z=false;local _=V or#K;local a0,a1,a2,a3=2,0,{},0;for P,Q in pairs(K)do if type(P)=="number"and P>=1 and P<=_ and P%1==0 then local a4=J(Q,L,S)a0=a0+a4+2;a1=a1+1 else a3=a3+1;a2[a3]=P;local a4,a5=J(Q,L,S),J(P,L,S)a0=a0+a4+a5+2;a1=a1+2 end;if a0>=S*0.6 then Z=true end end;if Z and T<=1 then u(c,X)u(h," ... ")u(c,Y)return end;table.sort(a2,x)local a6,a7,a8,a9;if Z then a6,a7=",\n",U.." "T=T-2;a8,a9=S-2,math.ceil(T/a1)if a1>T then a1=T-2 end else a6,a7=", ",""S=S-2;a8,a9=math.ceil(S/a1),1 end;u(c,X..(Z and"\n"or" "))L[K]=true;local aa={}local ab=true;for P=1,_ do if not ab then u(c,a6)else ab=false end;u(c,a7)aa[P]=true;R(K[P],L,a8,a9,a7)a1=a1-1;if a1<0 then if not ab then u(c,a6)else ab=false end;u(h,a7 .."...")break end end;for q=1,a3 do local P,Q=a2[q],K[a2[q]]if not aa[P]then if not ab then u(c,a6)else ab=false end;u(c,a7)if type(P)=="string"and not j[P]and string.match(P,"^[%a_][%a%d_]*$")then u(c,P.." = ")R(Q,L,a8,a9,a7)else u(c,"[")R(P,L,a8,a9,a7)u(c,"] = ")R(Q,L,a8,a9,a7)end;a1=a1-1;if a1<0 then if not ab then u(c,a6)else ab=false end;u(h,a7 .."...")break end end end;L[K]=nil;u(c,(Z and"\n"..U or" ")..(V and")"or"}"))end;local function ac(ad,ae)local S,T=term.getSize()local af=true;if type(af)=="number"then T=af elseif af==false then T=1/0 end;return R(ad,{},S,T-2,"",ae)end;local ag=true;local ah={}local ai=1;local aj={}local ak=setmetatable({exit=setmetatable({},{__tostring=function()ag=false;return"nil"end,__call=function()ag=false end}),_noTail=function(...)return...end,out=aj},{__index=_ENV})local function al(am,an)if string.sub(an,1,1)=="."then return end;local ao=fs.combine(am,an)if fs.isDir(ao)then return end;local ap,aq=loadfile(ao,nil,_ENV)if not ap then printError(aq)return end;local ar,as;if true then ar,as=stack_trace.xpcall_with(ap)else ar,as=pcall(ap)end;if not ar then printError(as)end end;local function at(am)if fs.exists(am)and fs.isDir(am)then local au=fs.list(am)for av,an in ipairs(au)do al(am,an)end end end;at("/rom/lua_autorun")at("/lua_autorun")local aw=nil;if not settings or settings.get("lua.autocomplete")then aw=function(n)local o=n:find("[a-zA-Z0-9_%.:]+$")if o then n=n:sub(o)end;if#n>0 then return textutils.complete(n,ak)end end end;local ax=".lua_history"if ax and fs.exists(ax)then local ay=fs.open(ax,"r")if ay then for n in ay.readLine do ah[#ah+1]=n end;ay.close()end end;local function az(aA,_)ak._=aA;ak["_"..ai]=aA;aj[ai]=aA;term.setTextColour(b)write("out["..ai.."]: ")term.setTextColour(c)if type(aA)=="table"then print(ac(aA,_))else print(ac(aA))end end;local function ay(aB,aC,...)if aC then local aD=select("#",...)if aD==0 then if aB then az(nil)end elseif aD==1 then az(...)else az({...},aD)end else printError(...)end end;if type(package)=="table"and type(package.path)=="string"then local aE=shell.dir()if aE:sub(1,1)~="/"then aE="/"..aE end;if aE:sub(#aE,#aE)~="/"then aE=aE.."/"end;local aF="?;?.lua;?/init.lua;"local ao=package.path;if ao:sub(1,#aF)==aF then ao=ao:sub(#aF+1)end;package.path=aE.."?;"..aE.."?.lua;"..aE.."?/init.lua;"..ao end;while ag do term.setTextColour(a)term.write("in ["..ai.."]: ")term.setTextColour(c)local n;if readline and readline.read then n=readline.read{history=ah,complete=aw,highlight=m}else n=read(nil,ah,aw)end;if not n then break end;if n:find("%S")then if n~=ah[#ah]then ah[#ah+1]=n;local aG=1e4;while#ah>aG do table.remove(ah,1)end;local ax=".lua_history"if ax then local ay=fs.open(ax,"w")if ay then for q=1,#ah do ay.writeLine(ah[q])end;ay.close()end end end;local aB=true;local ap,aH=load("return "..n,"=lua","t",ak)if not ap then ap,aH=load(n,"=lua","t",ak)aB=false else local aI=load("return _noTail("..n..")","=lua","t",ak)if aI then ap=aI end end;if ap then if true then ay(aB,stack_trace.xpcall_with(ap))else ay(aB,pcall(ap))end else printError(aH)end;ai=ai+1 end end