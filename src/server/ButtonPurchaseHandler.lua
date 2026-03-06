-- ButtonPurchaseHandler.lua (ServerScriptService)
-- Handles Touched events on all button parts in Workspace.
-- Button parts must be tagged with a "ButtonId" attribute matching a config id.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared            = ReplicatedStorage:WaitForChild("Shared")
local ButtonConfig      = require(Shared:WaitForChild("ButtonConfig"))
local StatFormulas      = require(Shared:WaitForChild("StatFormulas"))
local RemoteEvents      = require(Shared:WaitForChild("RemoteEvents"))

local DataManager = require(ServerScriptService:WaitForChild("DataManager"))
local RebirthHandler  -- required lazily to avoid circular deps

-- Cooldown per player per button (seconds) to prevent spam from Touched
local TOUCH_COOLDOWN = 0.5
local touchCooldowns = {} -- [userId][buttonId] = tick()

local function canTouch(userId: number, buttonId: string): boolean
	local userCooldowns = touchCooldowns[userId]
	if not userCooldowns then return true end
	local last = userCooldowns[buttonId]
	if not last then return true end
	return (tick() - last) >= TOUCH_COOLDOWN
end

local function setTouchCooldown(userId: number, buttonId: string)
	if not touchCooldowns[userId] then
		touchCooldowns[userId] = {}
	end
	touchCooldowns[userId][buttonId] = tick()
end

-- Get the player's current value for a given stat name
local function getStat(data: table, stat: string): number
	if stat == "Cash"           then return data.Cash           or 0 end
	if stat == "Multiplier"     then return data.Multiplier     or 0 end
	if stat == "Rebirths"       then return data.Rebirths       or 0 end
	if stat == "Ascensions"     then return data.Ascensions     or 0 end
	return 0
end

-- Check whether a player meets the unlock condition for a button
local function meetsUnlockCondition(data: table, btn: table): boolean
	if not btn.unlockCondition then return true end
	local cond = btn.unlockCondition
	return getStat(data, cond.stat) >= cond.minimum
end

-- Check whether a player can afford the button cost
local function canAfford(data: table, btn: table, timesBought: number): boolean
	if btn.costType == "None" then return true end
	local currentCost = StatFormulas.getScaledCost(btn.cost, btn.costScaling or 1, timesBought)
	local playerAmount = getStat(data, btn.costType)
	return playerAmount >= currentCost
end

-- Deduct the cost from the player's data
local function deductCost(data: table, btn: table, timesBought: number)
	if btn.costType == "None" then return end
	local currentCost = StatFormulas.getScaledCost(btn.cost, btn.costScaling or 1, timesBought)
	if btn.costType == "Cash" then
		data.Cash = math.max(0, data.Cash - currentCost)
	elseif btn.costType == "Multiplier" then
		data.Multiplier = math.max(0, data.Multiplier - currentCost)
	elseif btn.costType == "Rebirths" then
		data.Rebirths = math.max(0, data.Rebirths - currentCost)
	end
end

-- Apply a single reward to the player's data
local function applyReward(data: table, reward: table)
	local t   = reward.rewardType
	local op  = reward.rewardOperation
	local val = reward.rewardValue

	if t == "Multiplier" then
		if op == "add" then
			data.Multiplier = (data.Multiplier or 0) + val
		elseif op == "multiply" then
			data.Multiplier = (data.Multiplier or 1) * val
		end

	elseif t == "CashPerSec" then
		-- CashPerSec rewards compound into the CashPerSecMultiplier
		if op == "multiply" then
			data.CashPerSecMultiplier = (data.CashPerSecMultiplier or 1) * val
		elseif op == "add" then
			-- "add" means add as a flat multiplier (e.g., +0.1 means +10%)
			data.CashPerSecMultiplier = (data.CashPerSecMultiplier or 1) + val
		end

	elseif t == "RebirthBoost" then
		if op == "add" then
			data.ExtraRebirthBoost = (data.ExtraRebirthBoost or 0) + val
		elseif op == "multiply" then
			data.ExtraRebirthBoost = (data.ExtraRebirthBoost or 1) * val
		end

	elseif t == "AscensionBoost" then
		if op == "add" then
			data.ExtraAscensionBoost = (data.ExtraAscensionBoost or 0) + val
		elseif op == "multiply" then
			data.ExtraAscensionBoost = (data.ExtraAscensionBoost or 1) * val
		end

	elseif t == "Rebirths" then
		-- Handled by RebirthHandler; skip here
	elseif t == "Ascensions" then
		-- Handled by RebirthHandler; skip here
	end
end

-- Process a button purchase attempt
local function processPurchase(player: Player, buttonId: string)
	local btn = ButtonConfig.ById[buttonId]
	if not btn then
		warn("[ButtonPurchaseHandler] Unknown button id: " .. tostring(buttonId))
		return
	end

	local data = DataManager.getData(player)
	if not data then return end

	-- Special trigger buttons are routed to RebirthHandler
	if btn.id == "rebirth_trigger" then
		if not RebirthHandler then
			RebirthHandler = require(ServerScriptService:WaitForChild("RebirthHandler"))
		end
		RebirthHandler.tryRebirth(player)
		return
	end
	if btn.id == "ascension_trigger" then
		if not RebirthHandler then
			RebirthHandler = require(ServerScriptService:WaitForChild("RebirthHandler"))
		end
		RebirthHandler.tryAscension(player)
		return
	end

	-- Unlock condition check
	if not meetsUnlockCondition(data, btn) then
		RemoteEvents.get(RemoteEvents.Names.PurchaseFeedback):FireClient(
			player,
			false,
			"Requires " .. tostring(btn.unlockCondition.minimum) .. " " .. btn.unlockCondition.stat .. "!",
			buttonId
		)
		return
	end

	-- One-time check
	if not btn.repeatable and data.PurchasedOneTime[btn.id] then
		RemoteEvents.get(RemoteEvents.Names.PurchaseFeedback):FireClient(
			player,
			false,
			"Already purchased!",
			buttonId
		)
		return
	end

	local timesBought = data.RepeatableCounts[btn.id] or 0

	-- Afford check
	if not canAfford(data, btn, timesBought) then
		RemoteEvents.get(RemoteEvents.Names.PurchaseFeedback):FireClient(
			player,
			false,
			"Not enough " .. btn.costType .. "!",
			buttonId
		)
		return
	end

	-- Deduct cost
	deductCost(data, btn, timesBought)

	-- Apply all rewards
	for _, reward in ipairs(btn.rewards) do
		applyReward(data, reward)
	end

	-- Track purchase
	if btn.repeatable then
		data.RepeatableCounts[btn.id] = timesBought + 1
	else
		data.PurchasedOneTime[btn.id] = true
	end

	-- Sync to client
	DataManager.syncStats(player)
	DataManager.syncButtonStates(player)

	-- Success feedback
	RemoteEvents.get(RemoteEvents.Names.PurchaseFeedback):FireClient(
		player,
		true,
		btn.displayName,
		buttonId
	)
end

-- Wire up Touched events for all button parts in Workspace
-- Parts tagged with attribute ButtonId will be detected.
local function connectButton(part: BasePart)
	local buttonId = part:GetAttribute("ButtonId")
	if not buttonId then return end

	part.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then return end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		if not canTouch(player.UserId, buttonId) then return end
		setTouchCooldown(player.UserId, buttonId)

		processPurchase(player, buttonId)
	end)
end

-- Connect existing parts and watch for new ones
local function scanWorkspace()
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant:GetAttribute("ButtonId") then
			connectButton(descendant)
		end
	end
end

-- Run initial scan and listen for new button parts added at runtime
task.spawn(scanWorkspace)

workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("BasePart") and descendant:GetAttribute("ButtonId") then
		connectButton(descendant)
	end
end)

-- Clean up cooldowns when players leave
Players.PlayerRemoving:Connect(function(player)
	touchCooldowns[player.UserId] = nil
end)
