local function size(nSpace)
	if nSpace >= 1000 * 1000 then
		return (math.floor( nSpace / (100 * 1000) ) / 10) .. "MB"
	elseif nSpace >= 1000 then
		return (math.floor( nSpace / 100 ) / 10) .. "KB" 
	else
		return nSpace .. "B"
	end
end

local data = {
	{"Drive", "Size", "Used", "Avail"}
}

local function add(p)
	--local files, dirs, total = 0, 0, 0
	local total = 0

	--p = fs.combine(p, '')
	local drive = fs.getDrive(p)

	local function recurse(path)
		if fs.getDrive(path) == drive then
			if fs.isDir(path) then
				if path ~= p then
					total = total + 500
					--dirs = dirs + 1
				end
				for _, v in pairs(fs.list(path)) do
					recurse(fs.combine(path, v))
				end
			else
				local sz = fs.getSize(path)
				--files = files + 1
				if drive == 'rom' then
					total = total + sz
				else
					total = total + math.max(500, sz)
				end
			end
		end
	end

	recurse(p)

	table.insert(
		data,
		{
			p,
			size(total + fs.getFreeSpace(p)),
			size(total),
			size(fs.getFreeSpace(p))
		}
	)
end

add("/")

for _, side in ipairs(peripheral.getNames()) do
    if peripheral.getType(side) == "drive" then
		mount = disk.getMountPath(side)
		if mount then
        	add('/'..mount)
		end
	end
end

local spacing = {}

for key, val in pairs(data) do
	for k, v in pairs(val) do
		if not spacing[k] then
			spacing[k] = 0
		end
		if tostring(v):len() > spacing[k] then
			spacing[k] = tostring(v):len()
		end
	end
end

for key, val in pairs(data) do
	for k, v in pairs(val) do
		for i = spacing[k] - tostring(v):len(), 0, -1 do
			data[key][k] = data[key][k].." "
		end
	end

	for k, v in pairs(val) do
		write(v)
	end

	print()
end