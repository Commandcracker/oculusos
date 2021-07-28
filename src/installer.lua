-- Json
------------------------------------------------------------------ utils
local controls = {["\n"]="\\n", ["\r"]="\\r", ["\t"]="\\t", ["\b"]="\\b", ["\f"]="\\f", ["\""]="\\\"", ["\\"]="\\\\"}

local function isArray(t)
	local max = 0
	for k,v in pairs(t) do
		if type(k) ~= "number" then
			return false
		elseif k > max then
			max = k
		end
	end
	return max == #t
end

local whites = {['\n']=true; ['\r']=true; ['\t']=true; [' ']=true; [',']=true; [':']=true}
local function removeWhite(str)
	while whites[str:sub(1, 1)] do
		str = str:sub(2)
	end
	return str
end

------------------------------------------------------------------ encoding

local function encodeCommon(val, pretty, tabLevel, tTracking)
	local str = ""

	-- Tabbing util
	local function tab(s)
		str = str .. ("\t"):rep(tabLevel) .. s
	end

	local function arrEncoding(val, bracket, closeBracket, iterator, loopFunc)
		str = str .. bracket
		if pretty then
			str = str .. "\n"
			tabLevel = tabLevel + 1
		end
		for k,v in iterator(val) do
			tab("")
			loopFunc(k,v)
			str = str .. ","
			if pretty then str = str .. "\n" end
		end
		if pretty then
			tabLevel = tabLevel - 1
		end
		if str:sub(-2) == ",\n" then
			str = str:sub(1, -3) .. "\n"
		elseif str:sub(-1) == "," then
			str = str:sub(1, -2)
		end
		tab(closeBracket)
	end

	-- Table encoding
	if type(val) == "table" then
		assert(not tTracking[val], "Cannot encode a table holding itself recursively")
		tTracking[val] = true
		if isArray(val) then
			arrEncoding(val, "[", "]", ipairs, function(k,v)
				str = str .. encodeCommon(v, pretty, tabLevel, tTracking)
			end)
		else
			arrEncoding(val, "{", "}", pairs, function(k,v)
				assert(type(k) == "string", "JSON object keys must be strings", 2)
				str = str .. encodeCommon(k, pretty, tabLevel, tTracking)
				str = str .. (pretty and ": " or ":") .. encodeCommon(v, pretty, tabLevel, tTracking)
			end)
		end
	-- String encoding
	elseif type(val) == "string" then
		str = '"' .. val:gsub("[%c\"\\]", controls) .. '"'
	-- Number encoding
	elseif type(val) == "number" or type(val) == "boolean" then
		str = tostring(val)
	else
		error("JSON only supports arrays, objects, numbers, booleans, and strings", 2)
	end
	return str
end

local function encode(val)
	return encodeCommon(val, false, 0, {})
end

local function encodePretty(val)
	return encodeCommon(val, true, 0, {})
end

------------------------------------------------------------------ decoding

local decodeControls = {}
for k,v in pairs(controls) do
	decodeControls[v] = k
end

local function parseBoolean(str)
	if str:sub(1, 4) == "true" then
		return true, removeWhite(str:sub(5))
	else
		return false, removeWhite(str:sub(6))
	end
end

local function parseNull(str)
	return nil, removeWhite(str:sub(5))
end

local numChars = {['e']=true; ['E']=true; ['+']=true; ['-']=true; ['.']=true}
local function parseNumber(str)
	local i = 1
	while numChars[str:sub(i, i)] or tonumber(str:sub(i, i)) do
		i = i + 1
	end
	local val = tonumber(str:sub(1, i - 1))
	str = removeWhite(str:sub(i))
	return val, str
end

local function parseString(str)
	str = str:sub(2)
	local s = ""
	while str:sub(1,1) ~= "\"" do
		local next = str:sub(1,1)
		str = str:sub(2)
		assert(next ~= "\n", "Unclosed string")

		if next == "\\" then
			local escape = str:sub(1,1)
			str = str:sub(2)

			next = assert(decodeControls[next..escape], "Invalid escape character")
		end

		s = s .. next
	end
	return s, removeWhite(str:sub(2))
end

local function parseArray(str)
	str = removeWhite(str:sub(2))

	local val = {}
	local i = 1
	while str:sub(1, 1) ~= "]" do
		local v = nil
		v, str = parseValue(str)
		val[i] = v
		i = i + 1
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

local function parseObject(str)
	str = removeWhite(str:sub(2))

	local val = {}
	while str:sub(1, 1) ~= "}" do
		local k, v = nil, nil
		k, v, str = parseMember(str)
		val[k] = v
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

function parseMember(str)
	local k = nil
	k, str = parseValue(str)
	local val = nil
	val, str = parseValue(str)
	return k, val, str
end

function parseValue(str)
	local fchar = str:sub(1, 1)
	if fchar == "{" then
		return parseObject(str)
	elseif fchar == "[" then
		return parseArray(str)
	elseif tonumber(fchar) ~= nil or numChars[fchar] then
		return parseNumber(str)
	elseif str:sub(1, 4) == "true" or str:sub(1, 5) == "false" then
		return parseBoolean(str)
	elseif fchar == "\"" then
		return parseString(str)
	elseif str:sub(1, 4) == "null" then
		return parseNull(str)
	end
	return nil
end

local function decode(str)
	str = removeWhite(str)
	t = parseValue(str)
	return t
end

local function decodeFromFile(path)
	local file = assert(fs.open(path, "r"))
	local decoded = decode(file.readAll())
	file.close()
	return decoded
end

-- Functions
local function save(data,path)
    local file = fs.open(path,"w")
    file.write(data)
    file.close()
    print(path)
end

local function get(url)
    local response = http.get( url )
    if not response then
        return nil
    end

    local sResponse = response.readAll()
    response.close()
    return sResponse
end

local function download(url, path)
    save(get(url),path)
end

local function question(question)
    if question == nil then else
        if term.isColor() then
            term.setTextColour(colors.orange)
        end
        term.write(question.."? [")
        if term.isColor() then
            term.setTextColour(colors.lime)
        end
        term.write('Y')
        if term.isColor() then
            term.setTextColour(colors.orange)
        end
        term.write('/')
        if term.isColor() then
            term.setTextColour(colors.red)
        end
        term.write('n')
        if term.isColor() then
            term.setTextColour(colors.orange)
        end
        term.write("] ")
        term.setTextColour(colors.white)
    end
    local input = string.lower(string.sub(read(),1,1))
    if input == 'y' or input == 'j' or input == '' then
        return true
    else 
        return false
    end
end

local function split(string, delimiter)
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

-- Variables

local git = {
    owner = "Commandcracker",
    repo = "oculusos",
    branch = "master"
}

local url = "https://raw.githubusercontent.com/"..git.owner..'/'..git.repo..'/'..git.branch..'/'
local url_build = url.."build/"
local url_src = url.."src/"

local tArgs = { ... }

local minimized = true

-- Run
term.clear()
term.setCursorPos(1,1)

if tArgs[1] then
    _question = "Update OculusOS"
	f = fs.open("/.system_info", "r")
	if f then
		system_info = decode(f.readLine())
		if system_info.minimized ~= nil then
			minimized = system_info.minimized
		end
		if system_info.git.branch ~= nil then
			git.branch = system_info.git.branch
		end
	end
else
    _question = "Install OculusOS"
end

if question(_question) then else
	printError("Abort.")
    return
end

if not tArgs[1] then
	minimized = question("Minimize OculusOS")
end

if minimized ~= true then
	url_build = url.."src/"
end

-- Download
print()
if term.isColor() then
    term.setTextColour(colors.lime)
end
print("Downloading")
if term.isColor() then
    term.setTextColour(colors.blue)
end
print()

local to_download = {}

-- .shellrc

if not fs.exists( ".shellrc" ) then
    table.insert(to_download,function()
        download(url..".shellrc.lua", "/.shellrc")
    end)
end

-- Bootscreen
local bootscreen = "bootscreen/"

if turtle then
    bootscreen = bootscreen.."turtle/"
else
    if pocket then
        bootscreen = bootscreen.."pocket/"
    else
        bootscreen = bootscreen.."computer/"
    end
end

if term.isColor() then
    bootscreen = bootscreen.."colord.nfp"
else
    bootscreen = bootscreen.."default.nfp"
end

table.insert(to_download,function()
    download(url..bootscreen, "/.bootscreen")
end)

-- Startup
table.insert(to_download,function()
    download(url_build.."startup.lua", "/startup")
end)

-- Programs - fix
if shell.resolveProgram("/rom/programs/http/wget") == nil then
    table.insert(to_download,function()
        download(url_build .. "fix/wget.lua", "/bin/wget")
    end)
end

if tonumber(split(os.version(), ' ')[2]) <= 1.7 then
    table.insert(to_download,function()
        download(url_build .. "fix/pastebin.lua", "/bin/pastebin")
    end)
	table.insert(to_download,function()
        download(url_build .. "fix/00_fix.lua", "/lib/00_fix")
    end)
end

parallel.waitForAll(
    -- Startup
    function()
        for item in get(url_src.."boot/index"):gmatch("([^\n]*)\n?") do
			if item ~= "" then
				table.insert(to_download,function()
					download(url_build .. "boot/"..item..".lua", "/boot/"..item)
				end)
			end
        end
    end,
    -- APIS
    function()
        for item in get(url_src.."lib/index"):gmatch("([^\n]*)\n?") do
			if item ~= "" then
				table.insert(to_download,function()
					download(url_build .. "lib/"..item..".lua", "/lib/"..item)
				end)
			end
        end
    end,
    -- bin
    function()
        for item in get(url_src.."bin/index"):gmatch("([^\n]*)\n?") do
			if item ~= "" then
				table.insert(to_download,function()
					download(url_build .. "bin/"..item..".lua", "/bin/"..item)
				end)
			end
        end
    end,
    -- bin - not_pocket
    function()
        if not pocket then
            for item in get(url_src.."bin/not_pocket/index"):gmatch("([^\n]*)\n?") do
				if item ~= "" then
					table.insert(to_download,function()
						download(url_build .. "bin/not_pocket/"..item..".lua", "/bin/"..item)
					end)
				end
            end
        end
    end
)

-- version
table.insert(to_download,function()
    save(encode(
        {
			git = {
				owner = git.owner,
				repo = git.repo,
				branch = git.branch,
				commit = decode(get("https://api.github.com/repos/"..git.owner..'/'..git.repo.."/git/refs/heads/"..git.branch)).object.sha
			},
            colord = term.isColor(),
			minimized = minimized
        }
    ), "/.system_info")
end)

parallel.waitForAll(table.unpack(to_download))

-- Finished
print()
if not tArgs[1] and settings and not pocket then
    settings.set("shell.allow_disk_startup", false)
    settings.save()
end

term.setTextColour(colors.white)
if question("Reboot now") then
    print()
    if term.isColor() then
        term.setTextColor(colors.orange)
    end
    print("Rebooting computer")
    sleep(3)
    os.reboot()
end
