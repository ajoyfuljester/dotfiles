local Widget = require("astal.gtk3.widget")
local astal = require("astal")
local bind = astal.bind

local M = {}

function M.getValueFromTable(t, i)
	return t[((i - 1) % #t) + 1]
end

function M.tableShallowCopy(t)
	if type(t) ~= "table" then
		return t
	end

	local newT = {}
	for k, v in pairs(t) do
		newT[k] = v
	end
	return newT
end

function M.tableDeepCopy(t)
	if type(t) ~= "table" then
		return t
	end

	local newT = {}
	for k, v in pairs(t) do
		newT[k] = M.tableDeepCopy(v)
	end
	return newT
end


function M.printTable(t)
	if type(t) ~= "table" then
		print(t)
		return
	end

	for _, v in pairs(t) do
		M.printTable(v)
	end
end

local dozenalAlphabet = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b"}
function M.toDozenalString(n, pad)
	n = n // 1
	local doz = ""
	while n ~= 0 do
		doz = doz .. dozenalAlphabet[(n % 12) + 1]
		n = n // 12
	end
	doz = string.reverse(doz)
	local charsLeft = pad - #doz
	for _ = 1, charsLeft do
		doz = '0' .. doz
	end
	doz = "0z" .. doz
	return doz
end

function M.ElementAudio(colors, node, secondaryWidget)
	local speaker = node
	local prefix = "h-bg-"
	local color = colors:getPrevPaleString(prefix)
	if color == (prefix .. "2") then
		color = colors:getPrevPaleString(prefix)
	end


	return Widget.Button({
		class_name = bind(speaker, "mute"):as(function(m)
			local classes = "audio " .. color
			classes = classes .. (m and " muted" or "")
			return classes
		end),
		on_scroll = function(_, event)
			-- print('scrollSensitivity', event.delta_y) -- prints 1.5
			-- scrolling down is a positive delta_y

			-- for some reason it's possible and crashes the program
			if event == nil then
				return
			end

			speaker.volume = speaker.volume - (event.delta_y / 1.5 / 100)
		end,
		on_click = function(_, event)
			if event.button == "PRIMARY" then
				speaker.mute = not speaker.mute
			elseif event.button == "SECONDARY" then
				if secondaryWidget ~= nil then
					secondaryWidget.visible = not secondaryWidget.visible
				end
			end

		end,
		Widget.Box({
			halign = "CENTER",
			Widget.Label({
				label = bind(speaker, "mute"):as(function(m)
					return m and "m: " or "v: "
				end),
			}),
			Widget.Label({
				label = bind(speaker, "volume"):as(function(v)
					local value = math.floor((v * 100) + 0.5)
					return M.toDozenalString(value, 3)
				end),
			}),
		})
	})
end
return M
