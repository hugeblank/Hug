os.loadAPI("lib/API/sha")
os.loadAPI("lib/API/user")
local flag

for i = 1, 3 do
	if fs.exists("/var/pass/."..user.name().."_password") then 
		write("Current Password: ")
		local oldPass = read("*")
		local oldSaltFile = fs.open("/var/pass/."..user.name().."_salt", "r")
		local oldPassFile = fs.open("/var/pass/."..user.name().."_password", "r")
		local realOldPass = oldPassFile.readLine()
		local oldSalt = oldSaltFile.readLine()
		local checkPass = sha.sha256(oldPass..oldSalt)
		if checkPass == realOldPass then
			flag = true
		end
		oldSaltFile.close()
		oldPassFile.close()
	else
		flag = true
	end
	if flag then
		write("New Password: ")
		local pass = read("*")
		write("Confirm: ")
		local chk = read("*")
		if pass == chk then
			local salt = sha.salt()
			local pwd = sha.sha256(pass..salt)
			local passFile = fs.open("/var/pass/."..user.name().."_password", "w")
			local saltFile = fs.open("/var/pass/."..user.name().."_salt", "w")
			passFile.writeLine(pwd)
			saltFile.writeLine(salt)
			passFile.close()
			saltFile.close()
			break
		elseif i > 3 then
			print("Passwords did not match, try again.")
		end
	elseif i > 3 then
		print("Current password incorrect, try again.")
	elseif i == 3 then
		print("Failed 3 attempts, now exiting")
	end
end