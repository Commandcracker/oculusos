local TermW,TermH = term.getSize()

function split(string, delimiter)
    local result = { }
    local from = 1
    local delim_from, delim_to = string.find( string, delimiter, from )
    while delim_from do
        table.insert( result, string.sub( string, from , delim_from-1 ) )
        from = delim_to + 1
        delim_from, delim_to = string.find( string, delimiter, from )
    end
    table.insert( result, string.sub( string, from ) )
    return result
end

function printCentred( yc, stg )
	local xc = math.floor((TermW - string.len(stg)) / 2) + 1
	term.setCursorPos(xc,yc)
	term.write( stg )
end