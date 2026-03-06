-- RebirthHandler.lua (ServerScriptService)
-- Handles Rebirth and Ascension logic.

local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared              = ReplicatedStorage:WaitForChild("Shared")
local StatFormulas        = require(Shared:WaitForChild("StatFormulas"))
local RemoteEvents        = require(Shared:WaitForChild("RemoteEvents"))

local DataManager = require(ServerScriptService:WaitForChild("DataManager"))

local RebirthHandler = {}

-- Determines which button IDs belong to a given layer
local function getLayerButtonIds(layer: number): { string }
	local ButtonConfig = require(Shared:WaitForChild("ButtonConfig"))
	local ids = {}
	for _, btn in ipairs(ButtonConfig.Buttons) do
		if btn.layer == layer then
			table.insert(ids, btn.id)
		end
	end
	return ids
end

-- Reset one-time purchases and repeatable counts for buttons of the given layers
local function resetButtonLayers(data: table, layers: { number })
	local ButtonConfig = require(Shared:WaitForChild("ButtonConfig"))
	for _, btn in ipairs(ButtonConfig.Buttons) do
		for _, layer in ipairs(layers) do
			if btn.layer == layer then
				data.PurchasedOneTime[btn.id] = nil
				data.RepeatableCounts[btn.id]  = nil
			end
		end
	end
end

-- Attempt a Rebirth for the given player
function RebirthHandler.tryRebirth(player: Player)
	local data = DataManager.getData(player)
	if not data then return end

	-- Requirement: Multiplier >= 1000
	if (data.Multiplier or 0) < StatFormulas.REBIRTH_MULTIPLIER_REQUIREMENT then
		RemoteEvents.get(RemoteEvents.Names.PurchaseFeedback):FireClient(
			player,
			false,
			"Need " .. StatFormulas.REBIRTH_MULTIPLIER_REQUIREMENT .. " Multiplier to Rebirth!",
			"rebirth_trigger"
		)
		return
	end

	-- Grant +1 Rebirth
	data.Rebirths = (data.Rebirths or 0) + 1

	-- Reset Cash, Multiplier, CashPerSecMultiplier
	data.Cash                = 0
	data.Multiplier          = 1
	data.CashPerSecMultiplier = 1

	-- Reset layer 1 button purchases
	resetButtonLayers(data, { 1 })

	-- Sync to client
	DataManager.syncStats(player)
	DataManager.syncButtonStates(player)

	RemoteEvents.get(RemoteEvents.Names.PurchaseFeedback):FireClient(
		player,
		true,
		"REBIRTH! You now have " .. data.Rebirths .. " Rebirths.",
		"rebirth_trigger"
	)
end

-- Attempt an Ascension for the given player
function RebirthHandler.tryAscension(player: Player)
	local data = DataManager.getData(player)
	if not data then return end

	-- Requirement: Rebirths >= 10
	if (data.Rebirths or 0) < StatFormulas.ASCENSION_REBIRTH_REQUIREMENT then
		RemoteEvents.get(RemoteEvents.Names.PurchaseFeedback):FireClient(
			player,
			false,
			"Need " .. StatFormulas.ASCENSION_REBIRTH_REQUIREMENT .. " Rebirths to Ascend!",
			"ascension_trigger"
		)
		return
	end

	-- Grant +1 Ascension
	data.Ascensions = (data.Ascensions or 0) + 1

	-- Reset Cash, Multiplier, Rebirths, CashPerSecMultiplier, ExtraRebirthBoost
	data.Cash                = 0
	data.Multiplier          = 1
	data.Rebirths            = 0
	data.CashPerSecMultiplier = 1
	data.ExtraRebirthBoost   = 0

	-- Reset layer 1 and layer 2 button purchases
	resetButtonLayers(data, { 1, 2 })

	-- Sync to client
	DataManager.syncStats(player)
	DataManager.syncButtonStates(player)

	RemoteEvents.get(RemoteEvents.Names.PurchaseFeedback):FireClient(
		player,
		true,
		"ASCENSION! You now have " .. data.Ascensions .. " Ascensions.",
		"ascension_trigger"
	)
end

-- Wire RemoteEvent listeners for client-initiated rebirth/ascension
-- (alternative to button touch — e.g., a GUI button)
RemoteEvents.get(RemoteEvents.Names.RequestRebirth):Connect(function(player)
	RebirthHandler.tryRebirth(player)
end)

RemoteEvents.get(RemoteEvents.Names.RequestAscension):Connect(function(player)
	RebirthHandler.tryAscension(player)
end)

return RebirthHandler
