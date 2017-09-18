--A basic greeter for HUG Advanced CLI.
--I beg, make a better one...
os.pullEvent = os.pullEventRaw
term.setTextColor(colors.white)
local x, y = term.getSize()
s1 = "HUG Base Greeter"
term.setCursorPos(x/2-string.len(s1)/2, 1)
term.write(s1)
term.setCursorPos(1, 2)
local flag
repeat
write("Username: ")
local name = read()
local nameList = fs.open("/var/.userlist", "r")
local verif
local nameFromList
repeat
	nameFromList = nameList.readLine()
	if nameFromList == name then
		verif = true
	end
until nameFromList == nil
local nameFile = fs.open("/tmp/.uname", "w")
nameFile.write(name)
nameFile.close()
os.loadAPI("lib/API/user")
if verif then
	os.loadAPI("lib/API/sha")
	if fs.exists("/var/pass/."..user.name().."_password") then
		write("Password: ")
		local pass = read("*")
		local saltFile = fs.open("/var/pass/."..user.name().."_salt", "r")
		local passFile = fs.open("/var/pass/."..user.name().."_password", "r")
		local salt = saltFile.readLine()
		local realPass = passFile.readLine()
		local checkPass = sha.sha256(pass..salt)
		saltFile.close()
		passFile.close()
		if checkPass == realPass then
			flag = true
		else
			print("Invalid Password, try again.")
		end
	else
		flag = true
	end
else
	print("Invalid Username, try again.")
end
until flag == true