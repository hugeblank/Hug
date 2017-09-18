local x, y = term.getSize()
local option = 2
local time = 5
function input()
	repeat
		paintutils.drawLine(1, 3, 1, 4, colors.black)
		if option == 1 then
			term.setCursorPos(1, 3)
		elseif option == 2 then
			term.setCursorPos(1, 4)
		end
		term.setTextColor(colors.yellow)
		term.write(">")
		term.setTextColor(colors.white)
		local event, key = os.pullEvent()
		if (key == keys.down and event == "key") or (key == keys.up and event == "key") then
			if option == 1 then
				option = 2
			elseif option == 2 then
				option = 1
			end
		elseif key == keys.right or key == keys.enter then
			break
		end
	until key == keys.right or key == keys.enter
end
function output()
	for i = time, 1, -1 do
		local cx, cy = term.getCursorPos()
		local s2 = "The selected entry will be booted in "..i.." seconds."
		term.setCursorPos((x/2)-(string.len(s2)/2), 6)
		term.write(s2)
		term.setCursorPos(cx, cy)
		sleep(1)
	end
end
term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.white)
s1 = "HUG Base BootLoader"
term.setCursorPos(x/2-string.len(s1)/2, 1)
term.write(s1)
term.setCursorPos(3, 4)
term.write("HUG Advanced Shell")
term.setCursorPos(3, 3)
term.write("CraftOS Shell")
term.setCursorPos(1, 3)
parallel.waitForAny(input, output)
term.clear()
term.setCursorPos(1, 1)
if option == 1 then
	settings.set("hug.boot", "/rom/programs/shell")
elseif option == 2 then
	settings.set("hug.boot", "/lib/hug.lua")
end