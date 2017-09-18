if not ... then 
	write("Username: ")
	local name = read()
else
	name = ...
end
os.loadAPI("/lib/API/user")
if user.name() == "root" then
	printError("cannot delete root user")
	name = nil
elseif user.name() == name then
	printError("cannot delete yourself... use root account.")
	name = nil
end
if name then
	local users = fs.open("var/.userlist", "r")
	local ulist = users.readAll()
	ulist = string.gsub(ulist, name.."\n", "")
	users.close()
	local reusers = fs.open("/var/.userlist", "w")
	reusers.write(ulist)
	reusers.close()
	fs.delete("/home/"..name)
	fs.delete("/var/pass/."..name.."_password")
	fs.delete("/var/pass/."..name.."_salt")
	print("User Deleted")
end