local version = "0"
local run
--Settings management functions derived from Wojbie's "Shell Utility Extended": http://pastebin.com/f8zycUS6
local defaultSettings = {
["hug.use_bootLoader"] = false,
["hug.use_greeter"] = true,
["hug.greeterLocation"] = "/lib/greeter.lua",
["hug.use_init"] = true,
["hug.defaultEditor"] = "/rom/programs/edit.lua",
["hug.boot"] = "/lib/hug.lua"
}

--Restore cleared settings
for i,k in pairs(defaultSettings) do
  if settings.get(i) == nil then
    settings.set(i,k)
  end
end

local validSettingsTypes = {
["hug.use_bootLoader"] = {["boolean"]=true},
["hug.use_greeter"] = {["boolean"]=true},
["hug.greeterLocation"] = {["string"]=true},
["hug.use_init"] = {["boolean"]=true},
["hug.defaultEditor"] = {["string"]=true},
["hug.boot"] = {["string"]=true}
}

local validSettingsTest = {
}

local getSetting = function(A)
  local data = settings.get(A)
  if  (not validSettingsTypes[A] or validSettingsTypes[A][type(data)]) and --See if setting type matches (when defined).
    (not validSettingsTest[A] or validSettingsTest[A](data)) --See if testing function agrees (when defined).
  then --All tests OK
    return data
  else --Any of test Failed. Reset to default setting.
    data = defaultSettings[A]
    settings.set(A,data)
    return data
  end
end
-- End of settings management, onto the fun stuff :P

-- Boot loader!
if not ... then
  --clear screen for boot load
  term.clear()
  term.setCursorPos(1, 1)
  --Boot load if there is a boot loader & it's enabled
  if getSetting("hug.use_bootLoader") then
    if fs.exists("/boot/loader.lua") then
      shell.run("/boot/loader.lua")
    else
      term.setTextColor(colors.red)
      print("Boot loader does not exist under '/boot/loader.lua'. Please disable hug.use_bootLoader, or add a boot loader to '/boot/loader.lua'.")
      term.setTextColor(colors.white)
      write("Press any key to continue...")
      os.pullEvent("key")
      os.queueEvent("key", keys.backspace)
    end
  end
end

if getSetting("hug.boot") == "/lib/hug.lua" then
--wipe fs, and rebuild to use the permission system. COMING SOON
--[[local env = _ENV
local function shellrun(...)
  os.run(env, ...)
end
env.shell.run = shellrun
print(env.shell.run)
print(shellrun)
function run(untrusted_code)
  local untrusted_file, message = load(untrusted_code, nil, 't', env)
  if not untrusted_file then return nil, message end
  return pcall(untrusted_file)
end
]]
  --disable multishell... Yeah this one's a kick in the ass, but It's coming back soon(tm)!
    shell.openTab = function()return "Coming Soon"..string.char(169) end
  --set os.version
    os.version = function() return "HUG Extended Shell V:"..version end
  --alias setting
  local etcList = fs.list("/etc")
  for i = 1, #etcList do
    if not fs.isDir(etcList[i]) then
      shell.setAlias(string.gsub(etcList[i], ".lua", ""), "/etc/"..etcList[i])
    end
  end
  local libList = fs.list("/lib")
  for i = 1, #libList do
    if not fs.isDir(libList[i]) then
      shell.setAlias(string.gsub(libList[i], ".lua", ""), "/lib/"..libList[i])
    end
  end
  shell.clearAlias("exit")
  shell.clearAlias("shell")
  shell.clearAlias("sh")
  shell.clearAlias("ls")
  shell.clearAlias("dir")
  shell.clearAlias("edit")
  shell.setAlias("exit", "/lib/exit.lua")
  shell.setAlias("shell", "/lib/hug.lua")
  shell.setAlias("sh", "/lib/hug.lua")
  shell.setAlias("edit", getSetting("hug.defaultEditor"))
  shell.setAlias("nano", getSetting("hug.defaultEditor"))
  shell.setAlias("ls", "/lib/ls.lua")  
  shell.setAlias("l", "/lib/ls.lua")
  shell.setAlias("dir", "/lib/ls.lua")
  local blist = {}
  local blacklist = fs.open("/var/blacklist.txt", "r")
  repeat
    local line = blacklist.readLine()
    blist[#blist+1] = line
  until line == nil

  shell.run("/etc/extend.lua")

  --clear screen for greeter load
  term.clear()
  term.setCursorPos(1, 1)


  --boot greeter if setting is set
  if getSetting("hug.use_greeter") then
    if fs.exists(getSetting("hug.greeterLocation")) then
      shell.run(getSetting("hug.greeterLocation"))
    else
      term.setTextColor(colors.red)
      print("Greeter does not exist under '"..getSetting("hug.greeterLocation").."'. Please consider either disabling 'hug.use_greeter', or changing 'hug.greeterLocation' to where your greeter is.")
      term.setTextColor(colors.white)
      write("Press any key to continue...")
      os.pullEvent("key")
      os.queueEvent("key", keys.backspace)
    end
  end

  --Completion functions
  os.loadAPI("/lib/API/user")
  local name = user.name()
  local function completeFile( shell, nIndex, sText, tPreviousText )
    if nIndex == 1 then
      local fileList = fs.complete( sText, shell.dir(), true, false )
      --[[for i = 1, #fileList do
        for j = 1, #blist do
          if fileList[i] == blist[j] then
            fileList[i] = nil
          end
        end
      end]]
      return fileList
    end
  end
  local function completeParam(sText)
    local cmds = {"-h"}
    local check = {}
    local vals = {}
    for i = 1, #cmds do
      check[i] = string.gsub(cmds[i], sText, "")
      if check[i] ~= cmds[i] then
        vals[i] = check[i].." "
      end
    end
    return vals
  end
  local function completeDir( shell, nIndex, sText, tPreviousText )
    local fileList, cmdList
      sText = string.gsub(sText, "~", "/home/"..name)
      if nIndex == 1 or nIndex == 2 then
      fileList = fs.complete( sText, shell.dir(), false, true )
      cmdList = completeParam(sText)
        if nIndex == 1 then
          for i = 1, #fileList do
            fileList[i+#cmdList] = fileList[i]
          end
          for i = 1, #cmdList do
            fileList[i] = cmdList[i]
          end
        end
      end
      return fileList
  end
  local function completeChgDir( shell, nIndex, sText, tPreviousText )
    local fileList
    sText = string.gsub(sText, "~", "/home/"..name)
    if nIndex == 1 then
      fileList = fs.complete( sText, shell.dir(), false, true )
    end
      return fileList
  end
  local function completeProgram( shell, nIndex, sText, tPreviousText )
    sText = string.gsub(sText, "~", "/home/"..name)
    if nIndex == 1 then
        return shell.completeProgram( sText )
    end
  end
  local function completeBag(shell, nIndex, sText, tPreviousText )
    local cmds = {"grab", "update", "remove", "addbase"}
    local check = {}
    local vals = {}
    if index == 1 then
      for i = 1, #cmds do
        check[i] = string.gsub(cmds[i], sText, "")
        if check[i] ~= cmds[i] then
          vals[i] = check[i].." "
        end
      end
      return vals
    end
  end
  --And setting them to programs
  shell.setCompletionFunction("lib/hug.lua", completeProgram)
  shell.setCompletionFunction("lib/ls.lua", completeDir)
  shell.setCompletionFunction(string.sub(getSetting("hug.defaultEditor"), 2, string.len(getSetting("hug.defaultEditor"))), completeFile)
  shell.setCompletionFunction("rom/programs/cd.lua", completeChgDir)
  shell.setCompletionFunction("lib/bag.lua", completeBag)

  --clear screen for HUG load
  term.clear()
  term.setCursorPos(1, 1)
  --init custom startup
  if getSetting("hug.use_init") and fs.exists("/boot/init.lua") then
    shell.run("/boot/init.lua")
  end
end
--init shell
--run([[shell.run(settings.get("hug.boot"))]])
shell.run(getSetting("hug.boot"))
shell.exit()