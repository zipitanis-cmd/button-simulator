-- PinPanel.lua (StarterPlayerScripts)
-- Builds a pin/unpin panel so the player can choose which stats appear
-- on their BillboardGui above their head.

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local Shared             = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents       = require(Shared:WaitForChild("RemoteEvents"))

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- All stats that can be pinned
local ALL_STATS = {
	{ key = "Cash",           label = "💰 Cash"          },
	{ key = "CashPerSec",     label = "⚡ Cash/sec"       },
	{ key = "Multiplier",     label = "✖️ Multiplier"     },
	{ key = "Rebirths",       label = "🔁 Rebirths"       },
	{ key = "RebirthBoost",   label = "🌀 Rebirth Boost"  },
	{ key = "Ascensions",     label = "🚀 Ascensions"     },
	{ key = "AscensionBoost", label = "🌟 Ascension Boost"},
}

-- Track which stats are currently pinned (updated by server)
local pinnedSet = { Cash = true, Multiplier = true }

-- ============================================================
-- Build the ScreenGui
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name         = "PinPanelGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 2
screenGui.Parent       = playerGui

-- Toggle button (bottom-left corner)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name              = "ToggleBtn"
toggleBtn.Size              = UDim2.new(0, 130, 0, 36)
toggleBtn.Position          = UDim2.new(0, 10, 1, -50)
toggleBtn.BackgroundColor3  = Color3.fromRGB(45, 45, 80)
toggleBtn.BorderSizePixel   = 0
toggleBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
toggleBtn.Text              = "📌 Pin Stats"
toggleBtn.Font              = Enum.Font.GothamBold
toggleBtn.TextScaled        = true
toggleBtn.Parent            = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius   = UDim.new(0, 8)
toggleCorner.Parent         = toggleBtn

-- Panel (sits above the toggle button)
local panel = Instance.new("Frame")
panel.Name              = "PinPanel"
panel.Size              = UDim2.new(0, 240, 0, 30 + #ALL_STATS * 38)
panel.Position          = UDim2.new(0, 10, 1, -(56 + 30 + #ALL_STATS * 38))
panel.BackgroundColor3  = Color3.fromRGB(20, 20, 30)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel   = 0
panel.Visible           = false
panel.Parent            = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent       = panel

local panelPadding = Instance.new("UIPadding")
panelPadding.PaddingTop    = UDim.new(0, 8)
panelPadding.PaddingBottom = UDim.new(0, 8)
panelPadding.PaddingLeft   = UDim.new(0, 10)
panelPadding.PaddingRight  = UDim.new(0, 10)
panelPadding.Parent        = panel

local panelList = Instance.new("UIListLayout")
panelList.SortOrder = Enum.SortOrder.LayoutOrder
panelList.Padding   = UDim.new(0, 4)
panelList.Parent    = panel

-- Panel title
local panelTitle = Instance.new("TextLabel")
panelTitle.LayoutOrder      = 0
panelTitle.Size             = UDim2.new(1, 0, 0, 22)
panelTitle.BackgroundTransparency = 1
panelTitle.TextColor3       = Color3.fromRGB(255, 215, 0)
panelTitle.TextScaled       = true
panelTitle.Font             = Enum.Font.GothamBold
panelTitle.Text             = "📌 Pin Billboard Stats"
panelTitle.TextXAlignment   = Enum.TextXAlignment.Center
panelTitle.Parent           = panel

-- Track row buttons for updating pin state visuals
local pinButtons = {}

local function buildRow(i, statInfo)
	local row = Instance.new("Frame")
	row.Name              = "Row_" .. statInfo.key
	row.LayoutOrder       = i
	row.Size              = UDim2.new(1, 0, 0, 32)
	row.BackgroundTransparency = 1
	row.Parent            = panel

	local statLabel = Instance.new("TextLabel")
	statLabel.Size          = UDim2.new(0.65, 0, 1, 0)
	statLabel.Position      = UDim2.new(0, 0, 0, 0)
	statLabel.BackgroundTransparency = 1
	statLabel.TextColor3    = Color3.fromRGB(220, 220, 220)
	statLabel.Text          = statInfo.label
	statLabel.Font          = Enum.Font.Gotham
	statLabel.TextScaled    = true
	statLabel.TextXAlignment = Enum.TextXAlignment.Left
	statLabel.Parent        = row

	local pinBtn = Instance.new("TextButton")
	pinBtn.Size             = UDim2.new(0, 70, 0, 26)
	pinBtn.Position         = UDim2.new(1, -70, 0.5, -13)
	pinBtn.BorderSizePixel  = 0
	pinBtn.Font             = Enum.Font.GothamBold
	pinBtn.TextScaled       = true
	pinBtn.Parent           = row

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius  = UDim.new(0, 6)
	btnCorner.Parent        = pinBtn

	pinButtons[statInfo.key] = pinBtn

	pinBtn.MouseButton1Click:Connect(function()
		RemoteEvents.get(RemoteEvents.Names.TogglePinnedStat):FireServer(statInfo.key)
	end)

	return row
end

for i, statInfo in ipairs(ALL_STATS) do
	buildRow(i, statInfo)
end

-- Update pin button visuals based on current pinned set
local function refreshPinVisuals()
	for _, statInfo in ipairs(ALL_STATS) do
		local btn = pinButtons[statInfo.key]
		if btn then
			if pinnedSet[statInfo.key] then
				btn.Text             = "📌 Pinned"
				btn.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
				btn.TextColor3       = Color3.fromRGB(255, 255, 255)
			else
				btn.Text             = "Pin"
				btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
				btn.TextColor3       = Color3.fromRGB(200, 200, 200)
			end
		end
	end
end

-- Toggle panel visibility
toggleBtn.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

-- Receive pinned stat list from server
RemoteEvents.get(RemoteEvents.Names.UpdatePinnedStats):OnClientEvent:Connect(function(pinnedList)
	pinnedSet = {}
	for _, stat in ipairs(pinnedList) do
		pinnedSet[stat] = true
	end
	refreshPinVisuals()
end)

-- Initial render
refreshPinVisuals()
