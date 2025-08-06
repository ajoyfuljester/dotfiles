local astal = require("astal")
local Variable = astal.Variable
local GLib = astal.require("GLib")
local Widget = require("astal.gtk3.widget")
local Hyprland = astal.require("AstalHyprland")
local Tray = astal.require("AstalTray")
local Wp = astal.require("AstalWp")
local bind = astal.bind
local map = require("lib").map
local Utils = require("utils")


local ErrorString = "RIP"



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


local function ElementDateTime(_, format)
	local time = Variable({}):poll(
		125,
		function() return {value = GLib.DateTime.new_now_local():format(format)} end
	)

	return Widget.Label({
		on_destroy = function() time:drop() end,
		label = bind(time):as(function(t)
			if t == nil then
				return ErrorString
			end
			return t.value
		end),
	})
end


local function ElementTime(colors)
	local element = ElementDateTime(colors, "%H:%M:%S")
	element.class_name = "fg-13 bg-16"

	return element
end

local function ElementDate(colors)
	local element = ElementDateTime(colors, "%Y-%m-%d")
	element.class_name = colors:getPrevPaleString("fg-")

	return element
end

local function ElementWeekday(colors)

	local time = Variable({}):poll(
		125,
		function()

			local day = GLib.DateTime.new_now_local():format("%A")

			-- makes sure label is as long as the date string, so the clock is properly centered
			for _ = #day + 1, 10 do
				day = day .. " "
			end


			return {value = day}

		end
	)

	return Widget.Label({
		class_name = colors:getPrevPaleString("fg-"),
		on_destroy = function() time:drop() end,
		label = bind(time):as(function(t)
			if t == nil then
				return ErrorString
			end
			return t.value
		end),
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


local function ElementMemory(colors)
	local availableMemory = Variable({}):poll(
		3000,
		[[bash -c -- "free -h | sed -nE 's/Mem:(\s+\S+){5}\s+([0-9\.]+\w+).*/\2/p'"]],
		function(out)
			return {value = out .. "B"}
		end
	)


	return Widget.Label({
		class_name = "memory " .. colors:getPrevPaleString("bg-"),
		label = bind(availableMemory):as(function(t)
			if t == nil then
				return ErrorString
			end
			return t.value
		end),
		on_destroy = function()
			availableMemory:drop()
		end
	})
end


return function(gdkmonitor, colors, audioMixer)
	local Anchor = astal.require("Astal").WindowAnchor


	local elMemory = ElementMemory(colors)
	local elAudio = Utils.ElementAudio(colors, Wp.get_default().audio.default_speaker, audioMixer)


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
				class_name = "datetime",
				ElementDate(colors),
				ElementTime(colors),
				ElementWeekday(colors),
			}),
			Widget.Box({
				halign = "END",
				class_name = "info",
				ElementSystray(),
				elMemory,
				elAudio,
			}),
		}),
	})
end
