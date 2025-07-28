local Utils = require('utils')

local M = {}

-- TODO: luadoc or whatever

function M.prepareColors()
	local Colors = {}

	local boldColors = {1, 3, 5, 7, 9, 11}
	local paleColors = {2, 4, 6, 8, 10, 12}
	Colors.shuffledBoldColors = {}
	Colors.shuffledPaleColors = {}
if #boldColors ~= #paleColors then error("number of boldColors and paleColors does not match")
	end

	local numberOfColors = #boldColors
	for _ = 1, numberOfColors do
		local i = math.random(1, #boldColors)
		local bc = table.remove(boldColors, i)
		table.insert(Colors.shuffledBoldColors, bc)
		local pc = table.remove(paleColors, i)
		table.insert(Colors.shuffledPaleColors, pc)
	end


	-- TODO: rewrite this in a loop

	local lastBoldColor = Utils.getValueFromTable(Colors.shuffledBoldColors, numberOfColors)

	if (lastBoldColor == 3) or (lastBoldColor == 1) then
		local bc = table.remove(Colors.shuffledBoldColors, numberOfColors - 1)
		table.insert(Colors.shuffledBoldColors, bc)
		local pc = table.remove(Colors.shuffledPaleColors, numberOfColors - 1)
		table.insert(Colors.shuffledPaleColors, pc)

	end

	lastBoldColor = Utils.getValueFromTable(Colors.shuffledBoldColors, numberOfColors)

	if (lastBoldColor == 3) or (lastBoldColor == 1) then
		local bc = table.remove(Colors.shuffledBoldColors, numberOfColors - 2)
		table.insert(Colors.shuffledBoldColors, bc)
		local pc = table.remove(Colors.shuffledPaleColors, numberOfColors - 2)
		table.insert(Colors.shuffledPaleColors, pc)
	end

	Colors.lastColor = 0
	function Colors:getPrevPaleColor()
		self.lastColor = self.lastColor - 1
		return self.shuffledPaleColors[(self.lastColor % numberOfColors) + 1]
	end
	function Colors:getPrevBoldColor()
		self.lastColor = self.lastColor - 1
		return self.shuffledPaleColors[(self.lastColor % numberOfColors) + 1]
	end

	function Colors.colorString(t, index, prefix)
		return string.format("%s%s", prefix, Utils.getValueFromTable(t, index))
	end

	function Colors:colorPaleString(index, prefix)
		return string.format("%s%s", prefix, Utils.getValueFromTable(self.shuffledPaleColors, index))
	end

	function Colors:colorBoldString(index, prefix)
		return string.format("%s%s", prefix, Utils.getValueFromTable(self.shuffledBoldColors, index))
	end

	function Colors:getPrevPaleString(prefix)
		return prefix .. tostring(self:getPrevPaleColor())
	end

	function Colors:getPrevBoldString(prefix)
		return prefix .. tostring(self:getPrevBoldColor())
	end




	return Colors
end




return M


