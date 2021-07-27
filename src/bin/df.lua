local function size(nSpace)
	if nSpace >= 1000 * 1000 then
		return (math.floor( nSpace / (100 * 1000) ) / 10) .. "MB"
	elseif nSpace >= 1000 then
		return (math.floor( nSpace / 100 ) / 10) .. "KB" 
	else
		return nSpace .. "B"
	end
end

data = {
	{"Filesystem", "FreeSpace"}
}

local function add(path)
	table.insert(data, {path, size(fs.getFreeSpace(path))})
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

Filesystem_space = 0
for k, v in pairs(data) do
	if v[1]:len() > Filesystem_space then
		Filesystem_space = v[1]:len()
	end
end

for k, v in pairs(data) do
	for i = Filesystem_space - v[1]:len(), 0, -1 do
		v[1] = v[1].." "
	end
end

for k, v in pairs(data) do
	print(v[1]..v[2])
end
