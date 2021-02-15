
local multishell = multishell
local parentShell = shell
local parentTerm = term.current()

if multishell then
    multishell.setTitle( multishell.getCurrent(), "shell" )
end

local bExit = false
local sDir = (parentShell and parentShell.dir()) or ""
local sPath = (parentShell and parentShell.path()) or ".:/rom/programs"
local tAliases = (parentShell and parentShell.aliases()) or {}
local tCompletionInfo = (parentShell and parentShell.getCompletionInfo()) or {}
local tProgramStack = {}

-- Custom Functions
local function read_file(path)
    if fs.exists( path ) then
        local file = io.open( path, "r" )
        local sLine = file:read()
        file:close()
        return sLine
    end
end

-- Colours
local promptColour, textColour, bgColour
if term.isColour() then
	promptColour = colours.orange
	textColour = colours.white
	bgColour = colours.black
else
	promptColour = colours.white
	textColour = colours.white
	bgColour = colours.black
end

function shell.exit()
    bExit = true
end

local tArgs = { ... }
if #tArgs > 0 then
    -- "shell x y z"
    -- Run the program specified on the commandline
    shell.run( ... )

else
    -- "shell"
    -- Print the header
    term.setBackgroundColor( bgColour )
    term.setTextColour( promptColour )
    print( "OculusOS "..read_file("/.version"))
    term.setTextColour( textColour )

    -- Run the startup program
    if parentShell == nil then
        shell.run( "/rom/startup" )
    end

    -- Read commands and execute them
    local tCommandHistory = {}
    while not bExit do
        term.redirect( parentTerm )
        term.setBackgroundColor( bgColour )

        local sLabel = os.getComputerLabel()
        if not sLabel then
            sLabel = "oculusos"
        end

        if PS1 then
            local ps1 = PS1:gsub("\w", '/'..shell.dir())
            cprint.cwrite(ps1:gsub("\h", sLabel))
        end

        term.setTextColour( textColour )

        local sLine

		if settings then
			if settings.get( "shell.autocomplete" ) then
				sLine = read( nil, tCommandHistory, shell.complete )
			else
				sLine = read( nil, tCommandHistory )
			end
		else
			sLine = read( nil, tCommandHistory, shell.complete )
		end

        if string.find(sLine, "!!") then
            if #tCommandHistory == 0 then
                printError("No Command History!")
            else
                print(tCommandHistory[#tCommandHistory])
                sLine = sLine:gsub("!!", tCommandHistory[#tCommandHistory])
            end
        end

        if #tCommandHistory == 0 and  string.find(sLine, "!!") then else
            
            table.insert( tCommandHistory, sLine )

            for _, command in ipairs(oculusos.split(sLine, ';')) do
                shell.run( command )
            end

        end

    end
end
