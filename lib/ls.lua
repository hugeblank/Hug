args = {...}
if not args[1] == nil and (not fs.exists(args[1]) or not args[2]) then
  printError("No directory named "..args[1]..".")
else
  local list
  local listarg
  local blist = fs.open("var/blacklist.txt", "r")
  local blacklist = {}
  repeat
    local line = blist.readLine()
    blacklist[#blacklist+1] = line
  until line == nil
  blist.close()
  if args[1] == nil or (args[1] == "-h" and not args[2]) then
    list = fs.list(shell.dir())
    listarg = shell.dir()
  elseif args[1] == "-h" and args[2] then
    list = fs.list(args[2])
    listarg = args[2]
  else
    list = fs.list(args[1])
    listarg = args[1]
  end
  local dirs = {}
  local files = {}
  for i = 1, #list do
    if fs.isDir(listarg.."/"..list[i]) then
      dirs[#dirs+1] = list[i]
    else
      local output = true
      for j = 1, #blacklist do
        if list[i] == blacklist[j] then
          output = false
        end
      end
      if string.find(list[i], "[.]") == 1 then
        output = false
      end
      if args[1] == "-h" then
        output = true
      end
      if output then
        files[#files+1] = list[i]
      end
    end
  end
  textutils.pagedTabulate(colors.lime, dirs, colors.lightGray, files)
end