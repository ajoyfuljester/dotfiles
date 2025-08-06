local App = require("astal.gtk3.app")

local MyBar = require("widget.MyBar")
local astal = require("astal")
local src = require("lib").src
local prepareColors = require("colors").prepareColors
local NotificationPopups = require("widget.NotificationPopups")
local AudioMixer = require("widget.AudioMixer")
local Utils = require("utils")

local scss = src("mystyle.scss")
local css = "/tmp/style.css"

astal.exec("sass " .. scss .. " " .. css)





-- local colors = prepareColors()

App:start({
	instance_name = "lua",
	css = css,
	request_handler = function(msg, res)
		print(msg)
		res("why are you telling me this?")
	end,
	main = function()
		for _, mon in pairs(App.monitors) do
			local c = prepareColors()
			-- local c = Utils.tableDeepCopy(colors)
			local audioMixer = AudioMixer(mon, c)

			-- NOTE: AudioMixer before Bar, because then volume button is not working
			MyBar(mon, c, audioMixer)
			NotificationPopups(mon)
		end
	end,
})

