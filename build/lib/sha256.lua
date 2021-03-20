local a=2^32;local b=a-1;local function c(d)local e={}local f=setmetatable({},e)function e:__index(g)local h=d(g)f[g]=h;return h end;return f end;local function i(f,j)local function k(l,m)local n,o=0,1;while l~=0 and m~=0 do local p,q=l%j,m%j;n=n+f[p][q]*o;l=(l-p)/j;m=(m-q)/j;o=o*j end;n=n+(l+m)*o;return n end;return k end;local function r(f)local s=i(f,2^1)local t=c(function(l)return c(function(m)return s(l,m)end)end)return i(t,2^(f.n or 1))end;local u=r({[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0},n=4})local function v(l,m,w,...)local x=nil;if m then l=l%a;m=m%a;x=u(l,m)if w then x=v(x,w,...)end;return x elseif l then return l%a else return 0 end end;local function y(l,m,w,...)local x;if m then l=l%a;m=m%a;x=(l+m-u(l,m))/2;if w then x=bit32_band(x,w,...)end;return x elseif l then return l%a else return b end end;local function z(A)return(-1-A)%a end;local function B(l,C)if C<0 then return lshift(l,-C)end;return math.floor(l%2^32/2^C)end;local function D(A,C)if C>31 or C<-31 then return 0 end;return B(A%a,C)end;local function lshift(l,C)if C<0 then return D(l,-C)end;return l*2^C%2^32 end;local function E(A,C)A=A%a;C=C%32;local F=y(A,2^C-1)return D(A,C)+lshift(F,32-C)end;local g={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function G(H)return string.gsub(H,".",function(w)return string.format("%02x",string.byte(w))end)end;local function I(J,K)local H=""for L=1,K do local M=J%256;H=string.char(M)..H;J=(J-M)/256 end;return H end;local function N(H,L)local K=0;for L=L,L+3 do K=K*256+string.byte(H,L)end;return K end;local function O(P,Q)local R=64-(Q+9)%64;Q=I(8*Q,8)P=P.."\128"..string.rep("\0",R)..Q;assert(#P%64==0)return P end;local function S(T)T[1]=0x6a09e667;T[2]=0xbb67ae85;T[3]=0x3c6ef372;T[4]=0xa54ff53a;T[5]=0x510e527f;T[6]=0x9b05688c;T[7]=0x1f83d9ab;T[8]=0x5be0cd19;return T end;local function U(P,L,T)local V={}for W=1,16 do V[W]=N(P,L+(W-1)*4)end;for W=17,64 do local h=V[W-15]local X=v(E(h,7),E(h,18),D(h,3))h=V[W-2]V[W]=V[W-16]+X+V[W-7]+v(E(h,17),E(h,19),D(h,10))end;local l,m,w,Y,Z,d,_,a0=T[1],T[2],T[3],T[4],T[5],T[6],T[7],T[8]for L=1,64 do local X=v(E(l,2),E(l,13),E(l,22))local a1=v(y(l,m),y(l,w),y(m,w))local a2=X+a1;local a3=v(E(Z,6),E(Z,11),E(Z,25))local a4=v(y(Z,d),y(z(Z),_))local a5=a0+a3+a4+g[L]+V[L]a0,_,d,Z,Y,w,m,l=_,d,Z,Y+a5,w,m,l,a5+a2 end;T[1]=y(T[1]+l)T[2]=y(T[2]+m)T[3]=y(T[3]+w)T[4]=y(T[4]+Y)T[5]=y(T[5]+Z)T[6]=y(T[6]+d)T[7]=y(T[7]+_)T[8]=y(T[8]+a0)end;function sha256(P)P=O(P,#P)local T=S({})for L=1,#P,64 do U(P,L,T)end;return G(I(T[1],4)..I(T[2],4)..I(T[3],4)..I(T[4],4)..I(T[5],4)..I(T[6],4)..I(T[7],4)..I(T[8],4))end