if fs.exists("/lib/API/user") then
	os.unloadAPI("/lib/API/user")
	os.loadAPI("/lib/API/user")
end
args = {...}

if args[1] == "addbase" then
	if type(args[2]) == "string" then
		print("Validating database...")
		if http.checkURL(args[2]) then
			print("Database validated, adding to database list...")
			local dbfile = fs.open("/var/.bag_databases", "a")
			dbfile.writeLine(args[2])
			dbfile.close()
			print("Database added.")
		else
			printError("Not a valid database")
		end
	else
		print("Usage: bag addbase <pastebin ID>")
	end
elseif args[1] == "grab" then 
	if type(args[2]) == "string" then
		local tflag
		local ver
		local formArg = tostring("("..args[2]..")")
		if fs.exists("/var/.versions") then
			local verfile = fs.open("/var/.versions", "r")
			ver = textutils.unserialize(verfile.readAll())
			verfile.close()
		end
		print("Checking Databases for "..args[2].."...")
		local dbfile = fs.open("/var/.bag_databases", "r")
		local db = 0
		while db do
			db = dbfile.readLine()
			if db then
				local dbsite = http.get(db)
				repeat sleep() until dbsite
				local rawpkg = 0
				while rawpkg do
					local pkg = {}
					rawpkg = dbsite.readLine()
					if rawpkg then
						for i in string.gmatch(rawpkg, "%S+") do
							pkg[#pkg+1] = i
						end
						if not string.find(os.version(), "CraftOS") then
							pkg[3] = string.gsub(pkg[3], "~", "/home/"..user.name())
						end
						pkg[1] = tostring("("..pkg[1]..")")
						local flag
						if ver then
							if pkg[1] == formArg and pkg[4] ~= ver[pkg[1]] then
								flag = true
							elseif pkg[1] == formArg and pkg[4] == ver[pkg[1]] then
								tflag = true
							end
						else
							if pkg[1] == formArg then
								flag = true
							end
						end
						if flag then
							print("Package found, installing...")
							local pkgfile = http.get(pkg[2])
							if pkgfile then
								local file = fs.open(pkg[3], "w")
								file.write(pkgfile.readAll())
								pkgfile.close()
								file.close()
								local vertbl
								if fs.exists("/var/.versions") then
									local verfile = fs.open("/var/.versions", "r")
									vertbl = textutils.unserialize(verfile.readAll())
									verfile.close()
									vertbl[tostring("("..args[2]..")")] = pkg[4]
									vertbl = textutils.serialize(vertbl)
								else
									vertbl = textutils.serialize({[tostring("("..args[2]..")")] = pkg[4]})
								end
								verfile = fs.open("/var/.versions", "w")
								verfile.write(vertbl)
								verfile.close()
								print("Package added to bag successfully.")
								return
							else
								print(args[2].." raw file link broken.")
							end
						end
					end
				end
				dbsite.close()
			end
		end
		dbfile.close()
		if tflag then
			print(args[2].." is already up to date.")
		else
			print(args[2].." doesn't exist.")
		end
	else
		print("Usage: bag grab <bag-package>")
	end
elseif args[1] == "update" then
	local tflag
	local ver
	if fs.exists("/var/.versions") then
		local verfile = fs.open("/var/.versions", "r")
		ver = textutils.unserialize(verfile.readAll())
		verfile.close()
	end
	print("Checking Database(s) for updates...")
	for k, v in pairs(ver) do
		local realk = string.gsub(k, "[()]+", "")
		local dbfile = fs.open("/var/.bag_databases", "r")
		local db = 0
		while db do
			db = dbfile.readLine()
			if db then
				local dbsite = http.get(db)
				repeat sleep() until dbsite
				local rawpkg = 0
				while rawpkg do
					local pkg = {}
					rawpkg = dbsite.readLine()
					if rawpkg then
						for i in string.gmatch(rawpkg, "%S+") do
							pkg[#pkg+1] = i
						end
						pkg[3] = string.gsub(pkg[3], "~", "/home/"..user.name())
						rPkg = pkg[1]
						pkg[1] = tostring("("..pkg[1]..")")
						local flag
						if ver then
							if pkg[1] == k and pkg[4] ~= ver[pkg[1]] then
								flag = true
							elseif pkg[1] == k and pkg[4] == ver[pkg[1]] then
								tflag = true
							end
						else
							if pkg[1] == k then
								flag = true
							end
						end
						if flag then
							print("Update found, installing...")
							local pkgfile = http.get(pkg[2])
							if pkgfile then
								local file = fs.open(pkg[3], "w")
								file.write(pkgfile.readAll())
								pkgfile.close()
								file.close()
								local vertbl
								if fs.exists("/var/.versions") then
									local verfile = fs.open("/var/.versions", "r")
									vertbl = textutils.unserialize(verfile.readAll())
									verfile.close()
									vertbl[pkg[1]] = pkg[4]
									vertbl = textutils.serialize(vertbl)
								else
									vertbl = textutils.serialize({[pkg[1]] = pkg[4]})
								end
								verfile = fs.open("/var/.versions", "w")
								verfile.write(vertbl)
								verfile.close()
								print("Updated "..realk.." to "..pkg[4].." from "..ver[k].." successfully.")
							else
								print(realk.." raw file link broken")
							end
						end
					end
				end
				dbsite.close()
			end
		end
		dbfile.close()
		if tflag then
			print(realk.." is already up to date. ("..string.gsub(ver[k], "[\"+]", "")..")")
		else
			print(realk.." doesn't exist.")
		end
	end
elseif args[1] == "remove" or args[1] == "rm" then
	if type(args[2]) == "string" then
		local tflag
		local ver
		local formArg = tostring("("..args[2]..")")
		if fs.exists("/var/.versions") then
			local verfile = fs.open("/var/.versions", "r")
			ver = textutils.unserialize(verfile.readAll())
			verfile.close()
		end
		local dbfile = fs.open("/var/.bag_databases", "r")
		local db = 0
		while db do
			db = dbfile.readLine()
			if db then
				local dbsite = http.get(db)
				repeat sleep() until dbsite
				local rawpkg = 0
				while rawpkg do
					local pkg = {}
					rawpkg = dbsite.readLine()
					if rawpkg then
						for i in string.gmatch(rawpkg, "%S+") do
							pkg[#pkg+1] = i
						end
						pkg[3] = string.gsub(pkg[3], "~", "/home/"..user.name())
						pkg[1] = tostring("("..pkg[1]..")")
						local flag
						if ver then
							if pkg[1] == formArg and fs.exists(pkg[3]) then
								flag = true
							end
						end
						if flag then
							fs.delete(pkg[3])
							local verfile = fs.open("/var/.versions", "r")
							vertbl = textutils.unserialize(verfile.readAll())
							verfile.close()
							vertbl[formArg] = nil
							vertbl = textutils.serialize(vertbl)
							local verfile = fs.open("/var/.versions", "w")
							verfile.write(vertbl)
							verfile.close()
							print(args[2].." removed")
							return
						end
					end
				end
				dbsite.close()
			end
		end
		dbfile.close()
		if not flag then
			print(args[2].." is not in your bag")
		end
	else
		print("Usage: bag remove <bag-package>")
	end
elseif args[1] == "info" then 
	if type(args[2]) == "string" then
		local tflag
		local dbfile = fs.open("/var/.bag_databases", "r")
		local db = 0
		while db do
			db = dbfile.readLine()
			if db then
				local dbsite = http.get(db)
				repeat sleep() until dbsite
				local rawpkg = 0
				while rawpkg do
					local pkg = {}
					rawpkg = dbsite.readLine()
					if rawpkg then
						for i in string.gmatch(rawpkg, "%S+") do
							pkg[#pkg+1] = i
						end
						local info = pkg[5].." "
						if pkg[5] then
							for j = 6, #pkg do
								info = info..pkg[j].." "
							end
						end
						if pkg[1] == args[2] and pkg[5] then
							print("Information about "..args[2]..":\n"..info)
							return
						elseif pkg[1] == args[2] and not pkg[5] then
							tflag = true
						end
					end
				end
				dbsite.close()
			end
		end
		dbfile.close()
		if tflag then 
			print("No information found on "..args[2])
		else
			print(args[2].." doesn't exist.")
		end
	else
		print("Usage: bag info <bag-package>")
	end
elseif args[1] == "list" then 
	local pkgList = {}
	local dbfile = fs.open("/var/.bag_databases", "r")
	local db = 0
	while db do
		db = dbfile.readLine()
		if db then
			local dbsite = http.get(db)
			repeat sleep() until dbsite
			local rawpkg = 0
			while rawpkg do
				local pkg = {}
				rawpkg = dbsite.readLine()
				if rawpkg then
					for i in string.gmatch(rawpkg, "%S+") do
						pkg[#pkg+1] = i
					end
					pkgList[#pkgList+1] = pkg[1]
				end
			end
			dbsite.close()
		end
	end
	dbfile.close()
	textutils.pagedTabulate(pkgList)
else
	print("Usage: ")
	print("bag addbase <pastebin-ID>")
	print("bag grab <bag-package>")
	print("bag update")
	print("bag remove <bag-package>")
end
