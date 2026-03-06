-- StatsGui.lua (StarterPlayerScripts)
-- Builds and updates the main HUD stats display for the local player.

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local Shared             = ReplicatedStorage:WaitForChild("Shared")
local NumberFormatter    = require(Shared:WaitForChild("NumberFormatter"))
local StatFormulas       = require(Shared:WaitForChild("StatFormulas"))
local RemoteEvents       = require(Shared:WaitForChild("RemoteEvents"))

local player     = Players.LocalPlayer
local playerGui  = player:WaitForChild("PlayerGui")

-- ============================================================
-- Build the ScreenGui
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "MainStatsGui"
screenGui.ResetOnSpawn    = false
screenGui.DisplayOrder    = 1
screenGui.Parent          = playerGui

-- Background frame (top-right corner)
local frame = Instance.new("Frame")
frame.Name                = "StatsFrame"
frame.Size                = UDim2.new(0, 220, 0, 210)
frame.Position            = UDim2.new(1, -230, 0, 10)
frame.BackgroundColor3    = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel     = 0
frame.Parent              = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius       = UDim.new(0, 8)
corner.Parent             = frame

local padding = Instance.new("UIPadding")
padding.PaddingTop        = UDim.new(0, 8)
padding.PaddingBottom     = UDim.new(0, 8)
padding.PaddingLeft       = UDim.new(0, 10)
padding.PaddingRight      = UDim.new(0, 10)
padding.Parent            = frame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder      = Enum.SortOrder.LayoutOrder
listLayout.Padding        = UDim.new(0, 3)
listLayout.Parent         = frame

-- Title
local title = Instance.new("TextLabel")
title.Name             = "Title"
title.LayoutOrder      = 0
title.Size             = UDim2.new(1, 0, 0, 20)
title.BackgroundTransparency = 1
title.TextColor3       = Color3.fromRGB(255, 215, 0)
title.TextScaled       = true
title.Font             = Enum.Font.GothamBold
title.Text             = "📊 Stats"
title.TextXAlignment   = Enum.TextXAlignment.Center
title.Parent           = frame

-- Stat row definitions: { key, label, layoutOrder }
local statRows = {
	{ key = "Cash",           label = "💰 Cash",          order = 1 },
	{ key = "CashPerSec",     label = "⚡ Cash/sec",       order = 2 },
	{ key = "Multiplier",     label = "✖️ Multiplier",     order = 3 },
	{ key = "RebirthBoost",   label = "🌀 Reb Boost",      order = 4 },
	{ key = "Rebirths",       label = "🔁 Rebirths",       order = 5 },
	{ key = "AscensionBoost", label = "🌟 Asc Boost",      order = 6 },
	{ key = "Ascensions",     label = "🚀 Ascensions",     order = 7 },
}

local statLabels = {} -- statKey -> TextLabel

for _, row in ipairs(statRows) do
	local label = Instance.new("TextLabel")
	label.Name             = "Stat_" .. row.key
	label.LayoutOrder      = row.order
	label.Size             = UDim2.new(1, 0, 0, 22)
	label.BackgroundTransparency = 1
	label.TextColor3       = Color3.fromRGB(220, 220, 220)
	label.TextScaled       = true
	label.Font             = Enum.Font.Gotham
	label.Text             = row.label .. ": —"
	label.TextXAlignment   = Enum.TextXAlignment.Left
	label.Parent           = frame
	statLabels[row.key]    = label
end

-- Resize frame to fit content
local function resizeFrame()
	local totalHeight = 8 + 8 + 20 + (#statRows * (22 + 3))
	frame.Size = UDim2.new(0, 220, 0, totalHeight)
end
resizeFrame()

-- ============================================================
-- Stat value computation (mirrors server formulas)
-- ============================================================

local function getStatValue(data: table, key: string): number
	if key == "Cash"           then return data.Cash or 0 end
	if key == "Multiplier"     then return data.Multiplier or 0 end
	if key == "Rebirths"       then return data.Rebirths or 0 end
	if key == "Ascensions"     then return data.Ascensions or 0 end
	if key == "RebirthBoost"   then
		return StatFormulas.getRebirthBoost(data.Rebirths or 0) + (data.ExtraRebirthBoost or 0)
	end
	if key == "AscensionBoost" then
		return StatFormulas.getAscensionBoost(data.Ascensions or 0) + (data.ExtraAscensionBoost or 0)
	end
	if key == "CashPerSec" then
		local cps = StatFormulas.getCashPerSecond(
			data.Multiplier or 1,
			data.Rebirths   or 0,
			data.Ascensions or 0
		)
		return cps * (data.CashPerSecMultiplier or 1)
	end
	return 0
end

-- ============================================================
-- Update function — called whenever UpdateStats fires
-- ============================================================

local function updateStats(data: table)
	for _, row in ipairs(statRows) do
		local label = statLabels[row.key]
		if label then
			local value = getStatValue(data, row.key)
			label.Text = row.label .. ": " .. NumberFormatter.format(value)
		end
	end
end

-- ============================================================
-- Listen for server stat updates
-- ============================================================

RemoteEvents.get(RemoteEvents.Names.UpdateStats):OnClientEvent:Connect(updateStats)
