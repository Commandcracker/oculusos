--Check
local w,h = term.getSize()
if w == 51 and h == 19 then
	pc = true
else
	pc = false
end

--other suff idk
term.write("Reading package lists")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(" Done")
print()
sleep(0.1)
print("Building dependency tree")
sleep(0.1)
term.write("Reading state information")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(".")
sleep(0.1)
term.write(" Done")
print()
sleep(0.1)

term.write("Do you want to continue? [Y/n] ")
local input = string.lower(string.sub(read(),1,1))

if input == "y" or input == "j" or input == "" then
else
	error("Abort.")
end

local function get(file, code)
	if fs.exists(file) then
		fs.delete(file)
	end
	shell.run("pastebin get " .. code .. " " .. file)
end

if term.isColor() then
	if pc == true then
		get("bootscreen", "P7jxqFAf")
	else
		get("bootscreen", "p0rQKh7u")
	end
else
	if pc == true then
		get("bootscreen", "cZxC8AD7")
	else
		get("bootscreen", "PzjiH1ie")
	end
end

get("startup ","M8ubuj5a")
get("version", "KhvY4fvE")

print()

if term.isColor() then
	term.setTextColor(colors.yellow)
end

print("Rebooting computer")

sleep(3)

os.reboot()