local Widget = require("astal.gtk3").Widget
local AstalToo = require("astal.gtk3").Astal
local timeout = require("astal").timeout

local map = require("lib").map
local time = require("lib").time
local file_exists = require("lib").file_exists

local function is_icon(icon) return AstalToo.Icon.lookup_icon(icon) ~= nil end

---@param props { setup?: function, on_hover_lost?: function, notification: any }
return function(props)
	local n = props.notification

	local icon = n.app_icon
	if icon == "" then
		icon = n.desktop_entry
	end

	local header = Widget.Box({
		class_name = "header",
		((n.app_icon ~= "") or n.desktop_entry) and Widget.Icon({
			class_name = "app-icon",
			icon = icon,
		}),
		Widget.Label({
			class_name = "app-name",
			halign = "START",
			label = n.app_name or "Unknown",
		}),
		Widget.Box({
			halign = "END",
			hexpand = true,
			Widget.Label({
				class_name = "time",
				label = time(n.time),
			}),
			Widget.Button({
				on_clicked = function() n:dismiss() end,
				Widget.Label({ label = "X" }),
			}),
		}),
	})

	print(n.image)

	local body = Widget.Label({
		class_name = "body",
		wrap = true,
		use_markup = true,
		label = n.body,
		height = 100,
	})

	local content = Widget.Box({
		class_name = "content",
		(n.image and file_exists(n.image)) and Widget.Box({
			valign = "START",
			class_name = "image",
			css = string.format("background-image: url('%s')", n.image),
		}),
		n.image and is_icon(n.image) and Widget.Box({
			valign = "START",
			class_name = "icon-image",
			Widget.Icon({
				icon = n.image,
				hexpand = true,
				vexpand = true,
				halign = "CENTER",
				valign = "CENTER",
			}),
		}),
		Widget.Box({
			vertical = true,
			Widget.Label({
				class_name = "summary",
				label = n.summary,
			}),
			body,
		}),
	})


	return Widget.EventBox({
		-- setup = props.setup,
		-- NOTE: because resizing with text wrap is broken or something
		setup = function ()
			timeout(100, function ()
				body.height = -1
			end)
		end,
		on_hover_lost = props.on_hover_lost,
		Widget.Box({
			class_name = string.format("notification urgency-%s", string.lower(n.urgency)),
			vertical = true,
			header,
			content,
			#n.actions > 0 and Widget.Box({
				class_name = "actions",
				map(n.actions, function(action)
					local label, id = action.label, action.id

					return Widget.Button({
						hexpand = true,
						on_clicked = function() return n:invoke(id) end,
						Widget.Label({
							label = label,
							halign = "CENTER",
							hexpand = true,
						}),
					})
				end),
			}),
		}),
	})
end
