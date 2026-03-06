-- PassiveIncomeHandler.lua (ServerScriptService)
-- Ticks up Cash for every player every second based on their stats.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared            = ReplicatedStorage:WaitForChild("Shared")
local StatFormulas      = require(Shared:WaitForChild("StatFormulas"))

-- Wait for DataManager to be available in the same service
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService:WaitForChild("DataManager"))

local TICK_INTERVAL = 1 -- seconds

task.spawn(function()
	while true do
		task.wait(TICK_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			local data = DataManager.getData(player)
			if data then
				local cps = StatFormulas.getCashPerSecond(
					data.Multiplier,
					data.Rebirths,
					data.Ascensions
				)
				-- Apply the extra CashPerSec multiplier from button purchases
				cps = cps * (data.CashPerSecMultiplier or 1)

				data.Cash = data.Cash + cps * TICK_INTERVAL
				DataManager.syncStats(player)
			end
		end
	end
end)
