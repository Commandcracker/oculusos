function table.pack(...)
    local t = {...}
    t.n = select('#', ...)
    return setmetatable(t, table)
end
