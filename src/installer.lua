local json = {}
--[[
       ___                  
      |_  |                 
        | | ___  ___  _ __  
        | |/ __|/ _ \| '_ \ 
    /\__/ /\__ \ (_) | | | |
    \____/ |___/\___/|_| |_|
]]
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
function json.removeWhite(str)
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

function json.encode(val)
	return encodeCommon(val, false, 0, {})
end

function json.encodePretty(val)
	return encodeCommon(val, true, 0, {})
end

------------------------------------------------------------------ decoding

local decodeControls = {}
for k,v in pairs(controls) do
	decodeControls[v] = k
end

function json.parseBoolean(str)
	if str:sub(1, 4) == "true" then
		return true, json.removeWhite(str:sub(5))
	else
		return false, json.removeWhite(str:sub(6))
	end
end

function json.parseNull(str)
	return nil, json.removeWhite(str:sub(5))
end

local numChars = {['e']=true; ['E']=true; ['+']=true; ['-']=true; ['.']=true}
function json.parseNumber(str)
	local i = 1
	while numChars[str:sub(i, i)] or tonumber(str:sub(i, i)) do
		i = i + 1
	end
	local val = tonumber(str:sub(1, i - 1))
	str = json.removeWhite(str:sub(i))
	return val, str
end

function json.parseString(str)
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
	return s, json.removeWhite(str:sub(2))
end

function json.parseArray(str)
	str = json.removeWhite(str:sub(2))

	local val = {}
	local i = 1
	while str:sub(1, 1) ~= "]" do
		local v = nil
		v, str = json.parseValue(str)
		val[i] = v
		i = i + 1
		str = json.removeWhite(str)
	end
	str = json.removeWhite(str:sub(2))
	return val, str
end

function json.parseObject(str)
	str = json.removeWhite(str:sub(2))

	local val = {}
	while str:sub(1, 1) ~= "}" do
		local k, v = nil, nil
		k, v, str = json.parseMember(str)
		val[k] = v
		str = json.removeWhite(str)
	end
	str = json.removeWhite(str:sub(2))
	return val, str
end

function json.parseMember(str)
	local k = nil
	k, str = json.parseValue(str)
	local val = nil
	val, str = json.parseValue(str)
	return k, val, str
end

function json.parseValue(str)
	local fchar = str:sub(1, 1)
	if fchar == "{" then
		return json.parseObject(str)
	elseif fchar == "[" then
		return json.parseArray(str)
	elseif tonumber(fchar) ~= nil or numChars[fchar] then
		return json.parseNumber(str)
	elseif str:sub(1, 4) == "true" or str:sub(1, 5) == "false" then
		return json.parseBoolean(str)
	elseif fchar == "\"" then
		return json.parseString(str)
	elseif str:sub(1, 4) == "null" then
		return json.parseNull(str)
	end
	return nil
end

function json.decode(str)
	str = json.removeWhite(str)
	t = json.parseValue(str)
	return t
end

function json.decodeFromFile(path)
	local file = assert(fs.open(path, "r"))
	local decoded = json.decode(file.readAll())
	file.close()
	return decoded
end

--[[
      __                  _   _                 
     / _|                | | (_)                
    | |_ _   _ _ __   ___| |_ _  ___  _ __  ___ 
    |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
    | | | |_| | | | | (__| |_| | (_) | | | \__ \
    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
]]

local function get(url)
    local response = http.get( url )
    if not response then
        return nil
    end

    local sResponse = response.readAll()
    response.close()
    return sResponse
end

local function question(_question)
    if _question == nil then else
        if term.isColor() then
            term.setTextColour(colors.orange)
        end
        term.write(_question.."? [")
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

local function save(data,path, dontPrint)
    local file = fs.open(path,"w")
    file.write(data)
    file.close()
	if not dontPrint then
		print(path)
	end
end

local function download(url, path, dontPrint)
    local request, err = http.get(url)
    if request then
		save(request.readAll(), path, dontPrint)
        request.close()
    else
        printError("Faild to download: "..url)
        printError(err)
    end
end

local function loadAPIFromURL(url, name)
    local api_path = "/tmp/"..name
    download(url, api_path, true)
    local api = dofile(api_path)
    fs.delete(api_path)
    return api
end

local function setTextColour(color)
	if term.isColor() then
    	term.setTextColour(color)
	end
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
local args = { ... }
local minimized = true
local to_download = {}
local update = false

-- Run
if args[1] then
	update = true
end

if fs.exists("/.system_info") then
	update = true
	local file = fs.open("/.system_info", "r")
	local system_info = json.decode(file.readLine())
	if system_info.minimized ~= nil then
		minimized = system_info.minimized
	end
	if system_info.git.branch ~= nil then
		git.branch = system_info.git.branch
	end
	file.close()
end

if update then
    _question = "Update OculusOS"
else
    _question = "Install OculusOS"
end

if question(_question) then else
	printError("Abort.")
    return
end

if not update then
	minimized = question("Minimize OculusOS")
end

if minimized ~= true then
	url_build = url.."src/"
end

-- install pack
if not update then

	local pack_lib_url, pack_package_name

	if minimized then
		pack_lib_url = "https://raw.githubusercontent.com/Commandcracker/CC-pack/master/build/lib/pack.lua"
		pack_package_name = "pack"
	else
		pack_lib_url = "https://raw.githubusercontent.com/Commandcracker/CC-pack/master/src/lib/pack.lua"
		pack_package_name = "pack-src"
	end

	term.setTextColour(colors.white)
	print("Installing Pack")

	local function installPack()
		local pack = loadAPIFromURL(pack_lib_url, "pack")

		if not fs.exists("/etc/pack/sources.list") then
			local sources_list = fs.open("/etc/pack/sources.list", "w")
			sources_list.writeLine("pack https://raw.githubusercontent.com/Commandcracker/CC-pack/master/packages.json")
			sources_list.writeLine("commandcracker https://raw.githubusercontent.com/Commandcracker/CC-packages/master/packages.json")
			sources_list.close()
			pack.fetchSources(true)
		end

		for source,Package in pairs(pack.getPackages()) do
			for name,p in pairs(Package) do
				if name == pack_package_name then
					if pack.isPackageInstalled(source.."/"..name) then
						printError("Pack is already installed")
						return true
					end
					pack.installPackage(source.."/"..name, p, shell)
					return true
				end
			end
		end
		return false
	end

	if not installPack() then printError("Faild to install pack")end
end

if not update then
	term.setTextColour(colors.white)
	print("Installing OculusOS")
end

-- Download
setTextColour(colors.lime)
print("Downloading")
setTextColour(colors.blue)

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
    save(json.encode(
        {
			git = {
				owner = git.owner,
				repo = git.repo,
				branch = git.branch,
				commit = json.decode(get("https://api.github.com/repos/"..git.owner..'/'..git.repo.."/git/refs/heads/"..git.branch)).object.sha
			},
            colord = term.isColor(),
			minimized = minimized
        }
    ), "/.system_info")
end)

parallel.waitForAll(table.unpack(to_download))

-- Finished
if not update and settings and not pocket then
    settings.set("shell.allow_disk_startup", false)
    settings.save()
end

term.setTextColour(colors.white)
if question("Reboot now") then
    setTextColour(colors.orange)
    print("Rebooting computer")
    sleep(1)
    os.reboot()
end
