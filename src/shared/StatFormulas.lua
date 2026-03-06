-- StatFormulas.lua
-- Core formulas for stat calculations in Button Simulator

local StatFormulas = {}

-- Base income per second (before multipliers)
StatFormulas.BASE_INCOME = 1

-- Rebirth requirement: player needs this much Multiplier to rebirth
StatFormulas.REBIRTH_MULTIPLIER_REQUIREMENT = 1000

-- Ascension requirement: player needs this many Rebirths to ascend
StatFormulas.ASCENSION_REBIRTH_REQUIREMENT = 10

-- Rebirth Boost = 1 + (Rebirths * 0.25)
function StatFormulas.getRebirthBoost(rebirths: number): number
	return 1 + (rebirths * 0.25)
end

-- Ascension Boost = 1 + (Ascensions * 0.5)
function StatFormulas.getAscensionBoost(ascensions: number): number
	return 1 + (ascensions * 0.5)
end

-- Cash Gain Per Second = Base Income * Multiplier * Rebirth Boost * Ascension Boost
function StatFormulas.getCashPerSecond(
	multiplier: number,
	rebirths: number,
	ascensions: number
): number
	local rebirthBoost = StatFormulas.getRebirthBoost(rebirths)
	local ascensionBoost = StatFormulas.getAscensionBoost(ascensions)
	return StatFormulas.BASE_INCOME * multiplier * rebirthBoost * ascensionBoost
end

-- Get scaled cost for a repeatable button
-- baseCost * scalingFactor ^ timesBought
function StatFormulas.getScaledCost(baseCost: number, scalingFactor: number, timesBought: number): number
	return baseCost * (scalingFactor ^ timesBought)
end

return StatFormulas
