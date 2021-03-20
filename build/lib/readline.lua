local a={}for b,c in pairs(colours)do if type(c)=="number"then a[b]=c end end;for b,c in pairs(colors)do if type(c)=="number"then a[b]=c end end;local d="ulcdbf"local function e(f,g,h)if f<g then return g end;if f>h then return h end;return f end;local type=type;local function i(j,k,l)local m=type(j[k])if m~="nil"and m~=l then error(("bad key %s (expected %s, got %s)"):format(k,l,m),3)end end;function read(n)if n==nil then n={}elseif type(n)~="table"then error("bad argument #1 (expected table, got "..type(n)..")",2)end;i(n,"replace_char","string")i(n,"history","table")i(n,"complete","function")i(n,"default","string")i(n,"complete_fg","number")i(n,"complete_bg","number")i(n,"highlight","function")local o=term.getSize()local p=term.getCursorPos()local q=n.default or""local r,s=#q,0;local t,u={},0;local v;local w={}local x=0;local y=n.replace_char and n.replace_char:sub(1,1)local z=n.complete_fg or a["grey"]or-1;local A=n.complete_bg or a["none"]or-1;local B;local C;local function D()if n.complete and r==#q then B=n.complete(q)if B and#B>0 then C=1 else C=nil end else B=nil;C=nil end end;local function E()B=nil;C=nil end;local function F()x=0;if w[keys.leftCtrl]or w[keys.rightCtrl]then x=x+1 end;if w[keys.leftAlt]or w[keys.rightAlt]then x=x+2 end end;local function G()local H=q:find("%w%W",r+1)if H then return H else return#q end end;local function I()local H=1;while H<=#q do local J=q:find("%W%w",H)if J and J<r then H=J+1 else break end end;return H-1 end;local function K(L)local M=r-s;if p+M>=o then s=p+r-o elseif M<0 then s=r end;local N,O=term.getCursorPos()term.setCursorPos(p,O)local P=L and" "or y;if n.highlight and not L then local Q=term.getTextColor()local R,S,T=1,#q,Q;while R<=S do local U,V=n.highlight(q,R)if U<R then error("Highlighting function consumed no input")end;if U>=s+1 then if V~=T then term.setTextColor(V)T=V end;if P then term.write(string.rep(P,U-math.max(s+1,R)+1))else term.write(string.sub(q,math.max(s+1,R),U))end end;R=U+1 end;term.setTextColor(Q)else if P then term.write(string.rep(P,math.max(#q-s,0)))else term.write(string.sub(q,s+1))end end;if C then local W=B[C]local X,Y;if not L then X=term.getTextColor()Y=term.getBackgroundColor()if z>-1 then term.setTextColor(z)end;if A>-1 then term.setBackgroundColor(A)end end;if P then term.write(string.rep(P,#W))else term.write(W)end;if not L then term.setTextColor(X)term.setBackgroundColor(Y)end end;term.setCursorPos(p+r-s,O)end;local function Z(_,a0)if _<1 or a0<_ then return""end;return q:sub(_,a0)end;local function a1()K(true)end;local function a2(a3)if#a3==""then return end;u=u+1;t[u]=a3 end;local function a4()if C then a1()local W=B[C]q=q..W;r=#q;D()K()end end;term.setCursorBlink(true)D()K()while true do local a5,a6,a7,a8=os.pullEvent()if a5=="char"and(x==0 or x==3 or x==2 and not d:find(a6,1,true))then a1()q=string.sub(q,1,r)..a6 ..string.sub(q,r+1)r=r+1;D()K()elseif a5=="paste"then a1()q=string.sub(q,1,r)..a6 ..string.sub(q,r+1)r=r+#a6;D()K()elseif a5=="key"then if a6==keys.leftCtrl or a6==keys.rightCtrl or a6==keys.leftAlt or a6==keys.rightAlt then w[a6]=true;F()elseif a6==keys.enter then if C then a1()E()K()end;break elseif x==1 and a6==keys.d then if C then a1()E()K()end;q=nil;r=0;break elseif x==0 and a6==keys.left or x==1 and a6==keys.b then if r>0 then a1()r=r-1;D()K()end elseif x==0 and a6==keys.right or x==1 and a6==keys.f then if r<#q then a1()r=r+1;D()K()else a4()end elseif x==2 and a6==keys.b then local a9=I()if a9~=r then a1()r=a9;D()K()end elseif x==2 and a6==keys.f then local a9=G()if a9~=r then a1()r=a9;D()K()end elseif x==0 and(a6==keys.up or a6==keys.down)or x==1 and(a6==keys.p or a6==keys.n)then if C then a1()if a6==keys.up or a6==keys.p then C=C-1;if C<1 then C=#B end elseif a6==keys.down or a6==keys.n then C=C+1;if C>#B then C=1 end end;K()elseif n.history then a1()if a6==keys.up or a6==keys.p then if v==nil then if#n.history>0 then v=#n.history end elseif v>1 then v=v-1 end elseif a6==keys.down or a6==keys.n then if v==#n.history then v=nil elseif v~=nil then v=v+1 end end;if v then q=n.history[v]r,s=#q,0 else q=""r,s=0,0 end;E()K()end elseif x==0 and a6==keys.home or x==1 and a6==keys.a then if r>0 then a1()r=0;D()K()end elseif x==0 and a6==keys["end"]or x==1 and a6==keys.e then if r<#q then a1()r=#q;D()K()end elseif x==1 and a6==keys.t then local aa,ab;if r==#q then aa,ab=r-1,r elseif r==0 then aa,ab=1,2 else aa,ab=r,r+1 end;q=Z(1,aa-1)..Z(ab,ab)..Z(aa,aa)..Z(ab+1,#q)r=math.min(#q,ab)a1()D()K()elseif x==2 and a6==keys.u then if r<#q then local J=G()q=Z(1,r)..Z(r+1,J):upper()..Z(J+1,#q)r=J;a1()D()K()end elseif x==2 and a6==keys.l then if r<#q then local J=G()q=Z(1,r)..Z(r+1,J):lower()..Z(J+1,#q)r=J;a1()D()K()end elseif x==2 and a6==keys.c then if r<#q then local J=G()q=Z(1,r)..Z(r+1,r+1):upper()..Z(r+2,J):lower()..Z(J+1,#q)r=J;a1()D()K()end elseif x==0 and a6==keys.backspace then if r>0 then a1()q=string.sub(q,1,r-1)..string.sub(q,r+1)r=r-1;if s>0 then s=s-1 end;D()K()end elseif x==0 and a6==keys.delete then if r<#q then a1()q=string.sub(q,1,r)..string.sub(q,r+2)D()K()end elseif x==1 and a6==keys.u then if r>0 then a1()a2(q:sub(1,r))q=q:sub(r+1)r=0;D()K()end elseif x==1 and a6==keys.k then if r<#q then a1()a2(q:sub(r+1))q=q:sub(1,r)r=#q;D()K()end elseif x==2 and a6==keys.d then if r<#q then local J=G()if J~=r then a1()a2(q:sub(r+1,J))q=q:sub(1,r)..q:sub(J+1)D()K()end end elseif x==1 and a6==keys.w then if r>0 then local ac=I(r)if ac~=r then a1()a2(q:sub(ac+1,r))q=q:sub(1,ac)..q:sub(r+1)r=ac;D()K()end end elseif x==1 and a6==keys.y then local ad=t[u]if ad then a1()q=q:sub(1,r)..ad..q:sub(r+1)r=r+#ad;D()K()end elseif x==0 and a6==keys.tab then a4()end elseif a5=="key_up"then if a6==keys.leftCtrl or a6==keys.rightCtrl or a6==keys.leftAlt or a6==keys.rightAlt then w[a6]=false;F()end elseif a5=="mouse_click"or a5=="mouse_drag"and a6==1 then local N,O=term.getCursorPos()if a8==O then local ae=e(a7,p,o)r=e(s+ae-p,0,#q)K()end elseif a5=="term_resize"then o=term.getSize()K()end end;local N,O=term.getCursorPos()term.setCursorBlink(false)term.setCursorPos(o+1,O)print()return q end;_G.read=function(y,af,ag,ah)if y~=nil and type(y)~="string"then error("bad argument #1 (expected string, got "..type(y)..")",2)end;if af~=nil and type(af)~="table"then error("bad argument #2 (expected table, got "..type(af)..")",2)end;if ag~=nil and type(ag)~="function"then error("bad argument #3 (expected function, got "..type(ag)..")",2)end;if ah~=nil and type(ah)~="string"then error("bad argument #4 (expected string, got "..type(ah)..")",2)end;return readline.read{replace_char=y,history=af,complete=ag,default=ah}end