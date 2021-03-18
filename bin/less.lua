local tArgs = {...}
if #tArgs ~= 1 then
  print("Usage: less <path>")
  error("",0)
end
if not fs.exists(shell.resolve(tArgs[1])) then error("File not found",0) end
term.clear()
term.setCursorPos(1,1)
local lineNum = -2
local lines = {}
local w,h = term.getSize()
h = h - 2 -- Weird hack to make long file handling work
local function getFile(n)
  local ret = {}
  local h = fs.open(shell.resolve(n),"r")
  local nextLine = h.readLine()
  while nextLine do
    table.insert(ret,nextLine)
    nextLine = h.readLine()
  end
  return ret
end

lines = getFile(tArgs[1])

local function showLines(l,n)
  local atbottom = (n>(#l-h))
  local bottom = #l-h
  for i=(atbottom and bottom or n),(atbottom and #l or n+h) do
    if l[i] then print(l[i]) else print() end
  end
end

local first = true

while true do
  showLines(lines,lineNum)
  local _,k = os.pullEvent("key")
  if k == keys.down then lineNum = lineNum + 1 end
  if k == keys.up then lineNum = lineNum - 1 end
  if lineNum > #lines then lineNum = #lines end
  if lineNum < -2 then lineNum = -2 end
  if k == keys.q then
    os.pullEvent("char")
    error("",0)
  end
  term.clear()
  term.setCursorPos(1,1)
end
