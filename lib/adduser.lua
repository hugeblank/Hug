if not ... then 
	write("Username: ")
	local name = read()
else
	name = ...
end
if name then
	local users = fs.open("var/.userlist", "a")
	users.writeLine(name)
	users.close()
	fs.makeDir("/home/"..name)
	print("User Added")
end