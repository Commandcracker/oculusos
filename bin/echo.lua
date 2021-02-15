local tArgs = { ... }

for index,value in ipairs(tArgs) do
    term.write(value)
    if index == #tArgs - 0 then else
        term.write(' ')
    end
end
print()
