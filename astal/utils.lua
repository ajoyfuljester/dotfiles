
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

return M
