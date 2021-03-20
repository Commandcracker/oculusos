local a={["\n"]="\\n",["\r"]="\\r",["\t"]="\\t",["\b"]="\\b",["\f"]="\\f",["\""]="\\\"",["\\"]="\\\\"}local function b(t)local c=0;for d,e in pairs(t)do if type(d)~="number"then return false elseif d>c then c=d end end;return c==#t end;local f={['\n']=true,['\r']=true,['\t']=true,[' ']=true,[',']=true,[':']=true}function removeWhite(g)while f[g:sub(1,1)]do g=g:sub(2)end;return g end;local function h(i,j,k,l)local g=""local function m(n)g=g..("\t"):rep(k)..n end;local function o(i,p,q,r,s)g=g..p;if j then g=g.."\n"k=k+1 end;for d,e in r(i)do m("")s(d,e)g=g..","if j then g=g.."\n"end end;if j then k=k-1 end;if g:sub(-2)==",\n"then g=g:sub(1,-3).."\n"elseif g:sub(-1)==","then g=g:sub(1,-2)end;m(q)end;if type(i)=="table"then assert(not l[i],"Cannot encode a table holding itself recursively")l[i]=true;if b(i)then o(i,"[","]",ipairs,function(d,e)g=g..h(e,j,k,l)end)else o(i,"{","}",pairs,function(d,e)assert(type(d)=="string","JSON object keys must be strings",2)g=g..h(d,j,k,l)g=g..(j and": "or":")..h(e,j,k,l)end)end elseif type(i)=="string"then g='"'..i:gsub("[%c\"\\]",a)..'"'elseif type(i)=="number"or type(i)=="boolean"then g=tostring(i)else error("JSON only supports arrays, objects, numbers, booleans, and strings",2)end;return g end;function encode(i)return h(i,false,0,{})end;function encodePretty(i)return h(i,true,0,{})end;local u={}for d,e in pairs(a)do u[e]=d end;function parseBoolean(g)if g:sub(1,4)=="true"then return true,removeWhite(g:sub(5))else return false,removeWhite(g:sub(6))end end;function parseNull(g)return nil,removeWhite(g:sub(5))end;local v={['e']=true,['E']=true,['+']=true,['-']=true,['.']=true}function parseNumber(g)local w=1;while v[g:sub(w,w)]or tonumber(g:sub(w,w))do w=w+1 end;local i=tonumber(g:sub(1,w-1))g=removeWhite(g:sub(w))return i,g end;function parseString(g)g=g:sub(2)local n=""while g:sub(1,1)~="\""do local x=g:sub(1,1)g=g:sub(2)assert(x~="\n","Unclosed string")if x=="\\"then local y=g:sub(1,1)g=g:sub(2)x=assert(u[x..y],"Invalid escape character")end;n=n..x end;return n,removeWhite(g:sub(2))end;function parseArray(g)g=removeWhite(g:sub(2))local i={}local w=1;while g:sub(1,1)~="]"do local e=nil;e,g=parseValue(g)i[w]=e;w=w+1;g=removeWhite(g)end;g=removeWhite(g:sub(2))return i,g end;function parseObject(g)g=removeWhite(g:sub(2))local i={}while g:sub(1,1)~="}"do local d,e=nil,nil;d,e,g=parseMember(g)i[d]=e;g=removeWhite(g)end;g=removeWhite(g:sub(2))return i,g end;function parseMember(g)local d=nil;d,g=parseValue(g)local i=nil;i,g=parseValue(g)return d,i,g end;function parseValue(g)local z=g:sub(1,1)if z=="{"then return parseObject(g)elseif z=="["then return parseArray(g)elseif tonumber(z)~=nil or v[z]then return parseNumber(g)elseif g:sub(1,4)=="true"or g:sub(1,5)=="false"then return parseBoolean(g)elseif z=="\""then return parseString(g)elseif g:sub(1,4)=="null"then return parseNull(g)end;return nil end;function decode(g)g=removeWhite(g)t=parseValue(g)return t end;function decodeFromFile(A)local B=assert(fs.open(A,"r"))local C=decode(B.readAll())B.close()return C end