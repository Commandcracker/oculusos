local function a(b)if b>=1000*1000 then return math.floor(b/(100*1000))/10 .."MB"elseif b>=1000 then return math.floor(b/100)/10 .."KB"else return b.."B"end end;local c={{"Filesystem","FreeSpace"}}local function d(e)table.insert(c,{e,a(fs.getFreeSpace(e))})end;d("/")for f,g in ipairs(peripheral.getNames())do if peripheral.getType(g)=="drive"then mount=disk.getMountPath(g)if mount then d('/'..mount)end end end;local h=0;for i,j in pairs(c)do if j[1]:len()>h then h=j[1]:len()end end;for i,j in pairs(c)do for k=h-j[1]:len(),0,-1 do j[1]=j[1].." "end end;for i,j in pairs(c)do print(j[1]..j[2])end