local astal = require("astal")
local Variable = astal.Variable
local GLib = astal.require("GLib")
local Widget = require("astal.gtk3.widget")
local Hyprland = astal.require("AstalHyprland")
local Tray = astal.require("AstalTray")
local Wp = astal.require("AstalWp")
local bind = astal.bind
local map = require("lib").map



local function ElementWorkspaces(colors)
	local hypr = Hyprland.get_default()

	return Widget.Box({
		class_name = "workspaces",
		bind(hypr, "workspaces"):as(function(wss)
			table.sort(wss, function(a, b) return a.id < b.id end)

			return map(wss, function(ws, i)
				return Widget.Button({
					class_name = bind(hypr, "focused-workspace"):as(
						function(fw)
							if fw == ws then
								return "focused " .. colors.colorString(colors.shuffledBoldColors, i, "bg-")
							end
							return colors.colorString(colors.shuffledPaleColors, i, "fg-")
						end
					),
					on_clicked = function() ws:focus() end,
					label = bind(ws, "id"):as(
						function(v)
							return type(v) == "number" and string.format("%.0f", v) or v
						end
					),
				})
			end)
		end),
	})
end


local function ElementTime(_, format)
	local time = Variable(""):poll(
		125,
		function() return GLib.DateTime.new_now_local():format(format) end
	)

	return Widget.Label({
		class_name = "time",
		on_destroy = function() time:drop() end,
		label = time(),
	})
end

local function ElementSystray()
	local tray = Tray.get_default()

	return Widget.Box({
		class_name = "systray " .. "bg-14",
		bind(tray, "items"):as(function(items)
			return map(items, function(item)
				return Widget.MenuButton({
					tooltip_markup = bind(item, "tooltip_markup"),
					use_popover = false,
					menu_model = bind(item, "menu-model"),
					action_group = bind(item, "action-group"):as(
						function(ag) return { "dbusmenu", ag } end
					),
					Widget.Icon({
						gicon = bind(item, "gicon"),
					}),
				})
			end)
		end),
	})
end

local dozenalAlphabet = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b"}
local function toDozenalString(n, pad)
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

local function ElementAudio()
	local speaker = Wp.get_default().audio.default_speaker


	return Widget.Button({
		class_name = bind(speaker, "mute"):as(function(m)
			local classes = "audio "
			return classes .. (m and "muted" or "")
		end),
		on_scroll = function(_, event)
			-- print('scrollSensitivity', direction.delta_y) -- prints 1.5
			-- scrolling down is a positive delta_y
			speaker.volume = speaker.volume - (event.delta_y / 1.5 / 100)
		end,
		on_clicked = function()
			speaker.mute = not speaker.mute
		end,
		Widget.Box({
			Widget.Label({
				label = bind(speaker, "mute"):as(function(m)
					return m and "m: " or "v: "
				end),
			}),
			Widget.Label({
				label = bind(speaker, "volume"):as(function(v)
					return toDozenalString(v * 100, 3)
				end),
			}),
		})
	})
end

local function ElementMemory(colors)
	local availableMemory = Variable(""):poll(
		3000,
		[[bash -c -- "free -h | sed -nE 's/Mem:(\s+\S+){5}\s+([0-9\.]+\w+).*/\2/p'"]],
		function(out)
			return out
		end
	)


	return Widget.Label({
		class_name = "memory " .. colors:getPrevPaleString("bg-"),
		label = bind(availableMemory):as(function(s)
			return s or "RIP"
		end),
		on_destroy = function()
			availableMemory:drop()
		end
	})
end


return function(gdkmonitor, colors)
	local Anchor = astal.require("Astal").WindowAnchor

	return Widget.Window({
		class_name = "bar",
		gdkmonitor = gdkmonitor,
		anchor = Anchor.BOTTOM + Anchor.LEFT + Anchor.RIGHT,
		exclusivity = "EXCLUSIVE",
		Widget.CenterBox({
			Widget.Box({
				halign = "START",
				ElementWorkspaces(colors),
			}),
			Widget.Box({
				halign = "CENTER",
				ElementTime(colors, "%Y-%m-%d %A %H:%M:%S"),
			}),
			Widget.Box({
				halign = "END",
				class_name = "info",
				ElementSystray(colors),
				ElementMemory(colors),
				ElementAudio(colors),
			}),
		}),
	})
end
