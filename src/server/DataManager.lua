-- DataManager.lua (ServerScriptService)
-- Handles DataStore saving and loading for all player data.

local Players            = game:GetService("Players")
local DataStoreService   = game:GetService("DataStoreService")
local RunService         = game:GetService("RunService")

local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Shared             = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents       = require(Shared:WaitForChild("RemoteEvents"))

-- Set up remote events first (DataManager runs first)
RemoteEvents.setupServer()

local DataStore = DataStoreService:GetDataStore("ButtonSimulator_v1")

-- Auto-save interval in seconds
local AUTO_SAVE_INTERVAL = 60

-- Default data for a brand new player
local function getDefaultData()
	return {
		Cash            = 0,
		Multiplier      = 1,
		Rebirths        = 0,
		Ascensions      = 0,
		-- Extra permanent flat bonuses from button purchases
		-- (applied on top of formula boosts)
		ExtraRebirthBoost   = 0,
		ExtraAscensionBoost = 0,
		-- CashPerSecMultiplier: product of all "CashPerSec multiply" rewards
		CashPerSecMultiplier = 1,
		-- Which one-time buttons have been purchased this run
		-- Key: button id, Value: true
		PurchasedOneTime = {},
		-- How many times each repeatable button has been bought (for cost scaling)
		RepeatableCounts = {},
		-- Pinned stats for billboard (list of stat names)
		PinnedStats = { "Cash", "Multiplier" },
	}
end

-- Per-player in-memory data cache
local playerData = {}

-- Load a player's data from DataStore (or default)
local function loadPlayer(player: Player)
	local key = "player_" .. player.UserId
	local success, data = pcall(function()
		return DataStore:GetAsync(key)
	end)

	if success and data then
		-- Merge with defaults to handle new keys added in updates
		local defaults = getDefaultData()
		for k, v in pairs(defaults) do
			if data[k] == nil then
				data[k] = v
			end
		end
		playerData[player.UserId] = data
	else
		playerData[player.UserId] = getDefaultData()
	end

	-- Fire initial stat update to the client
	RemoteEvents.get(RemoteEvents.Names.UpdateStats):FireClient(
		player,
		playerData[player.UserId]
	)
	RemoteEvents.get(RemoteEvents.Names.UpdatePinnedStats):FireClient(
		player,
		playerData[player.UserId].PinnedStats
	)
	RemoteEvents.get(RemoteEvents.Names.UpdateButtonStates):FireClient(
		player,
		playerData[player.UserId].PurchasedOneTime,
		playerData[player.UserId].RepeatableCounts
	)
end

-- Save a player's data to DataStore
local function savePlayer(player: Player)
	local data = playerData[player.UserId]
	if not data then return end

	local key = "player_" .. player.UserId
	local success, err = pcall(function()
		DataStore:SetAsync(key, data)
	end)
	if not success then
		warn("[DataManager] Failed to save data for " .. player.Name .. ": " .. tostring(err))
	end
end

-- Public API ------------------------------------------------------------------

local DataManager = {}

-- Returns live data table for the player (modify in-place)
function DataManager.getData(player: Player): table
	return playerData[player.UserId]
end

-- Fires UpdateStats to the given player based on current server data
function DataManager.syncStats(player: Player)
	local data = playerData[player.UserId]
	if not data then return end
	RemoteEvents.get(RemoteEvents.Names.UpdateStats):FireClient(player, data)
end

-- Fires UpdateButtonStates to the given player
function DataManager.syncButtonStates(player: Player)
	local data = playerData[player.UserId]
	if not data then return end
	RemoteEvents.get(RemoteEvents.Names.UpdateButtonStates):FireClient(
		player,
		data.PurchasedOneTime,
		data.RepeatableCounts
	)
end

-- Fires UpdatePinnedStats to the given player
function DataManager.syncPinnedStats(player: Player)
	local data = playerData[player.UserId]
	if not data then return end
	RemoteEvents.get(RemoteEvents.Names.UpdatePinnedStats):FireClient(
		player,
		data.PinnedStats
	)
end

-- Hook events -----------------------------------------------------------------

Players.PlayerAdded:Connect(loadPlayer)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	playerData[player.UserId] = nil
end)

-- Auto-save loop
task.spawn(function()
	while true do
		task.wait(AUTO_SAVE_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayer(player)
		end
	end
end)

-- Save all on server shutdown
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayer(player)
	end
end)

-- Handle players already in game (Studio play-test)
for _, player in ipairs(Players:GetPlayers()) do
	loadPlayer(player)
end

return DataManager
