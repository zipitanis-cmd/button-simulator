-- BillboardHandler.lua (ServerScriptService)
-- Creates and updates BillboardGui above each player's head showing pinned stats.

local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared              = ReplicatedStorage:WaitForChild("Shared")
local NumberFormatter     = require(Shared:WaitForChild("NumberFormatter"))
local RemoteEvents        = require(Shared:WaitForChild("RemoteEvents"))

local DataManager = require(ServerScriptService:WaitForChild("DataManager"))

-- Stat display labels
local STAT_LABELS = {
	Cash             = "Cash",
	CashPerSec       = "Cash/sec",
	Multiplier       = "Multiplier",
	Rebirths         = "Rebirths",
	RebirthBoost     = "Reb Boost",
	Ascensions       = "Ascensions",
	AscensionBoost   = "Asc Boost",
}

-- Build a BillboardGui on the player's Head
local function createBillboard(character: Model): BillboardGui
	local head = character:WaitForChild("Head", 5)
	if not head then return end

	-- Remove any existing billboard
	local existing = head:FindFirstChild("StatsBillboard")
	if existing then existing:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name            = "StatsBillboard"
	billboard.Size            = UDim2.new(0, 200, 0, 120)
	billboard.StudsOffset     = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop     = false
	billboard.MaxDistance     = 60
	billboard.Adornee         = head
	billboard.Parent          = head

	local frame = Instance.new("Frame")
	frame.Name                = "Content"
	frame.Size                = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3    = Color3.fromRGB(15, 15, 15)
	frame.BackgroundTransparency = 0.35
	frame.BorderSizePixel     = 0
	frame.Parent              = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius       = UDim.new(0, 6)
	corner.Parent             = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop        = UDim.new(0, 4)
	padding.PaddingBottom     = UDim.new(0, 4)
	padding.PaddingLeft       = UDim.new(0, 6)
	padding.PaddingRight      = UDim.new(0, 6)
	padding.Parent            = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder      = Enum.SortOrder.LayoutOrder
	listLayout.Padding        = UDim.new(0, 2)
	listLayout.Parent         = frame

	return billboard
end

-- Get a computed stat value for display
local function getStatValue(data: table, stat: string): number
	local StatFormulas = require(Shared:WaitForChild("StatFormulas"))
	if stat == "Cash"           then return data.Cash or 0 end
	if stat == "Multiplier"     then return data.Multiplier or 0 end
	if stat == "Rebirths"       then return data.Rebirths or 0 end
	if stat == "Ascensions"     then return data.Ascensions or 0 end
	if stat == "RebirthBoost"   then
		return StatFormulas.getRebirthBoost(data.Rebirths or 0) + (data.ExtraRebirthBoost or 0)
	end
	if stat == "AscensionBoost" then
		return StatFormulas.getAscensionBoost(data.Ascensions or 0) + (data.ExtraAscensionBoost or 0)
	end
	if stat == "CashPerSec" then
		local cps = StatFormulas.getCashPerSecond(
			data.Multiplier or 1,
			data.Rebirths   or 0,
			data.Ascensions or 0
		)
		return cps * (data.CashPerSecMultiplier or 1)
	end
	return 0
end

-- Update the billboard to show the player's current pinned stats
local function updateBillboard(player: Player)
	local character = player.Character
	if not character then return end
	local head = character:FindFirstChild("Head")
	if not head then return end
	local billboard = head:FindFirstChild("StatsBillboard")
	if not billboard then return end

	local frame = billboard:FindFirstChild("Content")
	if not frame then return end

	local data = DataManager.getData(player)
	if not data then return end

	-- Remove old stat labels
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local pinnedStats = data.PinnedStats or { "Cash", "Multiplier" }
	for i, stat in ipairs(pinnedStats) do
		local label = Instance.new("TextLabel")
		label.Name              = "Stat_" .. stat
		label.LayoutOrder       = i
		label.Size              = UDim2.new(1, 0, 0, 18)
		label.BackgroundTransparency = 1
		label.TextColor3        = Color3.fromRGB(255, 255, 255)
		label.TextScaled        = true
		label.Font              = Enum.Font.GothamBold
		label.TextXAlignment    = Enum.TextXAlignment.Left

		local displayLabel = STAT_LABELS[stat] or stat
		local value = getStatValue(data, stat)
		label.Text = displayLabel .. ": " .. NumberFormatter.format(value)
		label.Parent = frame
	end

	-- Resize billboard based on number of pinned stats
	local count = #pinnedStats
	billboard.Size = UDim2.new(0, 200, 0, math.max(30, count * 22 + 12))
end

-- When a player's character spawns, create their billboard
local function onCharacterAdded(player: Player, character: Model)
	task.wait(0.1) -- wait for character to fully load
	createBillboard(character)
	updateBillboard(player)
end

-- Listen for stat updates and push to billboard
RemoteEvents.get(RemoteEvents.Names.UpdateStats):Connect(function(...)
	-- This fires Server->Client, so on the server we listen to an internal signal instead.
	-- We'll hook into DataManager.syncStats by overriding it after the fact below.
end)

-- Patch DataManager.syncStats to also update billboard
local _originalSyncStats = DataManager.syncStats
DataManager.syncStats = function(player: Player)
	_originalSyncStats(player)
	task.defer(updateBillboard, player)
end

-- Handle pinned stat toggle from client
RemoteEvents.get(RemoteEvents.Names.TogglePinnedStat):Connect(function(player, statName)
	local data = DataManager.getData(player)
	if not data then return end

	local pinned = data.PinnedStats
	local found = false
	for i, s in ipairs(pinned) do
		if s == statName then
			table.remove(pinned, i)
			found = true
			break
		end
	end
	if not found then
		table.insert(pinned, statName)
	end

	DataManager.syncPinnedStats(player)
	updateBillboard(player)
end)

-- Connect existing players
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end
