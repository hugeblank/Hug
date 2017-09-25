local tArgs = {...}
local tArg = {}
local tFiles = {}
local tResults = {}
function find()
	local file = fs.open(tArg.file, "r")
	local tOverwrite = {}
	for k = 1, #tResults do
		local kres = tResults[k]
		for l = 1, #tFiles do 
			if string.find(kres, tFiles[l]) and not string.find(tArg.option, "Z") then
				string.sub(kres, 0, string.len(tFiles[l]))
			end
		end
			local i, j = string.find(kres, tArg.find)
		if i and not tArg.option and string.find(tArg.option, "v") then
			tOverwrite[#tOverwrite+1] = tResults[k]
		elseif not i and tArg.option and string.find(tArg.option, "v") then
			tOverwrite[#tOverwrite+1] = tResults[k]
		end
	end
	tResults = tOverwrite
	if #tResults == 0 then
		local line
		repeat
			line = file.readLine()
			if line then
				local i, j = string.find(line, tArg.find)
				if i and not string.find(tArg.option, "v") then
					tResults[#tResults+1] = line
				elseif not i and string.find(tArg.option, "v") then
					tResults[#tResults+1] = line
				end
			end
		until line == nil
	end
end
function usage()
	if tArg.option and not string.find(tArg.option, "s") then
		print("Usage: ")
		print("gllp -ivcsqlL <string> <file>")
	end
end
function setFind(arg)
	tArg.findLen = string.len(arg)
	tArg.find = ""
	for i = 1, string.len(arg) do
		tArg.find = tArg.find.."["..string.sub(arg, i , i).."]"
	end
end
--Cheeky way of handling various arguments
if tArgs[1] then
	local i, j = string.find(tArgs[1], "-")
	if i == 1 and j == 1 then
		tArg.option = tArgs[1]
	else
		setFind(tArgs[1])
	end
else
	usage()
end
if tArgs[2] then
	if type(tArgs[2]) == "string" then
		if not tArg.find then
			setFind(tArgs[2])
		else
			if fs.exists(shell.dir().."/"..tArgs[2]) then
				tArg.file = shell.dir().."/"..tArgs[2]
			else
				usage()
			end
		end
	else
		usage()
	end
else
	usage()
end
for i = 3, #tArgs do 
	if not fs.exists(tArgs[i]) then
		if fs.exists(shell.dir().."/"..tArgs[i]) then
			tArgs[i] = shell.dir().."/"..tArgs[i]
	end
end

local tOpts = {"[s]", "[c]", "[q]", "[l]", "[L]"}
local ores
for i = 1, #tOpts do
	if tArg.option and string.find(tArg.option, tOpts[i]) then
		ores = true
	end
end
if tArg.option and not ores then
	tArg.file = tArgs[3]
	if string.find(tArg.option, "i") then
		local pattern = ""
		for i in string.gmatch(tArg.find, "%b\[\]") do
			i = string.gsub(string.gsub(i, "[\]]", ""), "[\[]", "") --let's ignore the complexity of this simplicity.
			pattern = pattern.."["..i..string.upper(i).."]"
		end
		local realtArg = tArg.find
		tArg.find = pattern
		find()
		tArg.find = realtArg
	end
	if string.find(tArg.option, "v") then
		find()
	end
elseif tArg.option and string.find(tArg.option, "l") then
	for i = 3, #tArgs do
		tArg.file = tArgs[i]
		find()
		if #tResults ~= 0 then
			tResults = {}
			tFiles[#tFiles+1] = tArgs[i]
		end
	end
elseif tArg.option and string.find(tArg.option, "L") then
	for i = 3, #tArgs do
		tArg.file = tArgs[i]
		find()
		if #tResults == 0 then
			tResults = {}
			tFiles[#tFiles+1] = tArgs[i]
		end
	end
else
	if not tArg.option then 
		tArg.option = "-"
	end
	for i = 3, #tArgs do
		tArg.file = tArgs[i]
		find()
		if #tResults ~= 0 then
			tResults = {}
			tFiles[#tFiles+1] = tArgs[i]
		end
	end
end
if tResults[1] and not ores then
	for i = 1, #tResults do 
		textutils.pagedPrint(tResults[i])
	end
end
if string.find(tArg.option, "c") then
	print(#tResults)
end
if string.find(tArg.option, "l") or string.find(tArg.option, "L") then
	for i = 1, #tFiles do 
		textutils.pagedPrint(tFiles[i])
	end
end