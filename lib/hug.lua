--The pwetty UI that you're greeted with.
os.loadAPI("lib/API/user")
uname, domain = user.info()
term.setTextColor(colors.lime)
print(os.version())
print("Welcome, "..uname)
local function getDir()
  local dir = shell.dir()
  if dir ~= string.gsub(dir, "home/"..uname, "") then
    return "~"..string.gsub(dir, "home/"..uname, "")
  elseif shell.dir() == "" then
  	return "/"
  else
    return "/"..shell.dir()
  end
end
local tHistory = {}
shell.setDir("home/"..uname)
repeat
	local dx, dy = term.getSize()
  local x, y = term.getCursorPos()
  if y >= dy then
  	term.scroll(1)
  	term.setCursorPos(1, y-1)
  	x, y = term.getCursorPos()
  else
  	term.setCursorPos(1, y)
  end
  term.setTextColor(colors.yellow)
  term.write(uname.."@"..domain.." ")
  term.setTextColor(colors.green)
  term.write("HUG16 ")
  term.setTextColor(colors.orange)
  term.write(getDir())
  term.setCursorPos(1, y+1)
  term.setTextColor(colors.lightGray)
  term.write("$ ")
  term.setTextColor(colors.white)
  local out
  if settings.get( "shell.autocomplete" ) then
    out = read( nil, tHistory, shell.complete )
  else
    out = read( nil, tHistory )
  end
  out = string.gsub(out, "~", "/home/"..uname)
  tHistory[#tHistory+1] = out
  --[[local env = {print = print, os = os, shell = shell}
  local function run(untrusted_code)
    local untrusted_file, message = load(loadstring(shell.run(untrusted_code)), nil, 't', env)
    if not untrusted_file then return nil, message end
      return pcall(untrusted_file)
    end
  end]]
  shell.run(out)
until true == false