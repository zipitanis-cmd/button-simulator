-- NumberFormatter.lua
-- Converts large numbers to suffix notation (K, M, B, T, ...)

local NumberFormatter = {}

local suffixes = {
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc",
	"UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "OcDc", "NoDc", "Vg"
}

function NumberFormatter.format(n: number): string
	if n == nil then return "0" end
	if n < 0 then return "-" .. NumberFormatter.format(-n) end
	if n < 1000 then
		-- Show up to 2 decimal places for small numbers, but trim trailing zeros
		local formatted = string.format("%.2f", n)
		-- Remove trailing zeros after decimal
		formatted = formatted:gsub("%.?0+$", "")
		return formatted
	end

	local index = 1
	local value = n
	while value >= 1000 and index < #suffixes do
		value = value / 1000
		index = index + 1
	end

	local formatted
	if value >= 100 then
		formatted = string.format("%.1f", value)
	elseif value >= 10 then
		formatted = string.format("%.2f", value)
	else
		formatted = string.format("%.2f", value)
	end
	-- Remove trailing zeros after decimal point
	formatted = formatted:gsub("%.?0+$", "")

	return formatted .. suffixes[index]
end

return NumberFormatter
