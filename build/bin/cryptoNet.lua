--[[
MIT License

Copyright (c) 2019 SiliconSloth

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
local function a()print("Usage: cryptoNet signCert <file>")print("       cryptoNet demo <server/client>")end;cryptoNet.setLoggingEnabled(true)local b={...}if b[1]=="signCert"then local c=b[2]if c==nil then a()return end;c=workingDir==""and c or shell.dir().."/"..c;local d=b[3]local e,f=pcall(cryptoNet.signCertificate,c,d)if not e then cryptoNet.log("Error: "..f:sub(8))end elseif b[1]=="initCertAuth"then local e,f=pcall(cryptoNet.initCertificateAuthority,b[2],b[3])if not e then cryptoNet.log("Error: "..f:sub(8))end elseif b[1]=="demo"then local g=b[2]if g==nil then a()return end;if g=="server"then function onStart()cryptoNet.host("DemoServer")end;function onEvent(h)if h[1]=="connection_opened"then local i=h[2]cryptoNet.send(i,"Welcome to the server!")cryptoNet.send(i,"Please wait while I show off CryptoNet...")os.sleep(5)cryptoNet.send(i,"Done!")elseif h[1]=="encrypted_message"then if term.isColor()then term.write('[')term.setTextColour(colors.lime)term.write('Client')term.setTextColour(colors.white)print('] '..h[2])else print("[Client] "..h[2])end end end;cryptoNet.startEventLoop(onStart,onEvent)elseif g=="client"then function onStart()local i=cryptoNet.connect("DemoServer")cryptoNet.send(i,"Hello server!")end;function onEvent(h)if h[1]=="encrypted_message"then if term.isColor()then term.write('[')term.setTextColour(colors.red)term.write('Server')term.setTextColour(colors.white)print('] '..h[2])else print("[Server] "..h[2])end end end;cryptoNet.startEventLoop(onStart,onEvent)else a()end else a()end