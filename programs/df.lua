print("Filesystem FreeSpace")

local function size(nSpace)
	if nSpace >= 1000 * 1000 then
		return (math.floor( nSpace / (100 * 1000) ) / 10) .. "MB"
	elseif nSpace >= 1000 then
		return (math.floor( nSpace / 100 ) / 10) .. "KB" 
	else
		return nSpace .. "B"
	end
end

local function display(path)
    f = fs.getFreeSpace(path)
    print(path.." "..size(f))
end

display("/")

for _, side in ipairs(peripheral.getNames()) do
    if peripheral.getType(side) == "drive" then
		mount = disk.getMountPath(side)
		if mount then
        	display('/'..mount)
		end
	end
end
