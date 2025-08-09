local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local WirePlumber = astal.require("AstalWp")
local bind = astal.bind
local timeout = require("astal").timeout
local Utils = require("utils")








return function(gdkmonitor, colors)
	local audio = WirePlumber.get_default().audio
	local Anchor = astal.require("Astal").WindowAnchor

	local box = Widget.Box({
		class_name = "streams",
		bind(audio, "streams"):as(function(streams)
			if #streams == 0 then
				return Widget.Label({
					class_name = "message",
					justify = 2,
					wrap = true,
					label = "No streams found",
				})
			end

			local t = {}
			for _, stream in ipairs(streams) do
				table.insert(t,
					Widget.Box({
						class_name = "stream",
						vertical = true,
						Utils.ElementAudio(colors, stream),
						Widget.Label({
							label = stream.description,
							justify = 2,
							wrap = true,
						}),
						Widget.Label({
							label = stream.name,
							justify = 2,
							wrap = true,
						}),
						Widget.Label({
							label = stream.path,
							justify = 2,
							wrap = true,
						}),
						-- Widget.Icon({
						-- 	icon = stream.icon,
						-- }),
					})
				)
			end


			return t

		end)
	})

	local wrapper = Widget.EventBox({
		class_name = "not-button",
		box,
	})

	local window = Widget.Window({
		setup = function (self)
			wrapper.on_click = function (_, event)
				if event.button ~= "SECONDARY" then
					return
				end
				self.visible = false
			end

			-- timeout(100, function ()
				-- box.height = -1
			-- end)
		end,
		class_name = "audio-mixer",
		gdkmonitor = gdkmonitor,
		anchor = Anchor.BOTTOM + Anchor.RIGHT,
		visible = false,


		-- Widget.Scrollable({
			wrapper,
		-- }),

	})



	return window


end

