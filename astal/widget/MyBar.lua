local astal = require("astal")
local Variable = astal.Variable
local GLib = astal.require("GLib")
local Widget = require("astal.gtk3.widget")
local Hyprland = astal.require("AstalHyprland")
local Tray = astal.require("AstalTray")
local Wp = astal.require("AstalWp")
local bind = astal.bind
local map = require("lib").map


local boldColors = {1, 3, 5, 7, 9, 11}
local paleColors = {2, 4, 6, 8, 10, 12}
local shuffledBoldColors = {}
local shuffledPaleColors = {}

if #boldColors ~= #paleColors then
	error("number of boldColors and paleColors does not match")
end

local numberOfColors = #boldColors
for _ = 1, numberOfColors do
	local i = math.random(1, #boldColors)
	local bc = table.remove(boldColors, i)
	table.insert(shuffledBoldColors, bc)
	local pc = table.remove(paleColors, i)
	table.insert(shuffledPaleColors, pc)
end



local function ElementWorkspaces()
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
									return string.format("focused bg-%s", shuffledBoldColors[i % numberOfColors])
								end
								return string.format("fg-%s", shuffledPaleColors[i % numberOfColors])
							end
						),
						on_clicked = function() ws:focus() end,
						label = bind(ws, "id"):as(
							function(v)
								return type(v) == "number"
										and string.format("%.0f", v)
									or v
							end
						),
					})
			end)
		end),
	})
end

local function ElementTime(format)
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
		class_name = "SysTray",
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

local function ElementRadio()
	local speaker = Wp.get_default().audio.default_speaker


	return Widget.Box({
		-- css = "min-width: 200px;",
		class_name = "audio",
		-- Widget.Slider({
		-- 	hexpand = true,
		-- 	on_dragged = function(self) speaker.volume = self.value end,
		-- 	value = bind(speaker, "volume"),
		-- }),
		Widget.Label({
			class_name = bind(speaker, "mute"):as(function(m)
				return m and "muted" or ""
			end),
			label = bind(speaker, "mute"):as(function(m)
				return m and "X: " or "V: "
			end),
		}),
		Widget.Label({
			label = bind(speaker, "volume"):as(function(v)
				return toDozenalString(v * 100, 3)
			end),
		}),
	})
end

return function(gdkmonitor)
	local Anchor = astal.require("Astal").WindowAnchor

	return Widget.Window({
		class_name = "bar",
		gdkmonitor = gdkmonitor,
		anchor = Anchor.TOP + Anchor.LEFT + Anchor.RIGHT,
		exclusivity = "EXCLUSIVE",
		Widget.CenterBox({
			Widget.Box({
				halign = "START",
				ElementWorkspaces(),
			}),
			Widget.Box({
				halign = "CENTER",
				ElementTime("%H:%M:%S"),
			}),
			Widget.Box({
				halign = "END",
				ElementRadio(),
				ElementSystray(),
			}),
		}),
	})
end
