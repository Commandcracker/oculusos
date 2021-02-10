
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
    print( "OculusOS "..read_file("/oculusos/version"))
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

		if settings then
			local sLine
			if settings.get( "shell.autocomplete" ) then
				sLine = read( nil, tCommandHistory, shell.complete )
			else
				sLine = read( nil, tCommandHistory )
			end
			table.insert( tCommandHistory, sLine )
			shell.run( sLine )
		else
			local sLine = read( nil, tCommandHistory, shell.complete )
			table.insert( tCommandHistory, sLine )
			shell.run( sLine )
		end
    end
end
