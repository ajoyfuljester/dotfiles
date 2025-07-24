local App = require("astal.gtk3.app")

local Bar = require("widget.Bar")
local MyBar = require("widget.MyBar")
local astal = require("astal")
local src = require("lib").src
local prepareColors = require("colors").prepareColors
local Utils = require("utils")

local scss = src("mystyle.scss")
local css = "/tmp/style.css"

astal.exec("sass " .. scss .. " " .. css)

local colors = prepareColors()

App:start({
	instance_name = "lua",
	css = css,
	request_handler = function(msg, res)
		print(msg)
		res("why are you telling me this?")
	end,
	main = function()
		for _, mon in pairs(App.monitors) do
			local c = Utils.tableDeepCopy(colors)

			MyBar(mon, c)
		end
	end,
})
