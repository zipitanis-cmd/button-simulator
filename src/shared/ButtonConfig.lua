-- ButtonConfig.lua
-- Config-driven definitions for every button in Button Simulator.
-- Adding a new button = adding a new entry here. No other scripts needed.

--[[
Button entry fields:
  id              string   -- unique identifier
  displayName     string   -- shown on the button's SurfaceGui label
  description     string   -- tooltip text
  cost            number   -- base cost
  costType        string   -- currency spent ("Cash", "Multiplier", "Rebirths")
  rewards         table    -- list of reward tables:
                              { rewardType, rewardOperation, rewardValue }
                              rewardType: "Multiplier", "CashPerSec", "RebirthBoost", "AscensionBoost"
                              rewardOperation: "add" | "multiply"
                              rewardValue: number
  repeatable      boolean  -- can be bought multiple times?
  costScaling     number   -- if repeatable, cost *= costScaling^timesBought
  layer           number   -- 1=multiplier, 2=rebirth, 3=ascension, 4=special
  unlockCondition table?   -- optional: { stat="Rebirths", minimum=1 }
--]]

local ButtonConfig = {}

ButtonConfig.Buttons = {

	-- =========================================================
	-- LAYER 1: Multiplier Buttons (bought with Cash)
	-- =========================================================

	{
		id             = "mult_1",
		displayName    = "+1 Multiplier",
		description    = "Adds 1 to your Multiplier.",
		cost           = 10,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add", rewardValue = 1 },
		},
		repeatable     = true,
		costScaling    = 1.35,
		layer          = 1,
		unlockCondition = nil,
	},

	{
		id             = "mult_2",
		displayName    = "+2 Multiplier",
		description    = "Adds 2 to your Multiplier.",
		cost           = 25,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add", rewardValue = 2 },
		},
		repeatable     = true,
		costScaling    = 1.35,
		layer          = 1,
		unlockCondition = nil,
	},

	{
		id             = "mult_5",
		displayName    = "+5 Multiplier",
		description    = "Adds 5 to your Multiplier.",
		cost           = 75,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add", rewardValue = 5 },
		},
		repeatable     = true,
		costScaling    = 1.35,
		layer          = 1,
		unlockCondition = nil,
	},

	{
		id             = "mult_10",
		displayName    = "+10 Multiplier",
		description    = "Adds 10 to your Multiplier.",
		cost           = 200,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add", rewardValue = 10 },
		},
		repeatable     = true,
		costScaling    = 1.35,
		layer          = 1,
		unlockCondition = nil,
	},

	{
		id             = "mult_25",
		displayName    = "+25 Multiplier",
		description    = "Adds 25 to your Multiplier.",
		cost           = 500,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add", rewardValue = 25 },
		},
		repeatable     = true,
		costScaling    = 1.35,
		layer          = 1,
		unlockCondition = nil,
	},

	{
		id             = "mult_x1_5",
		displayName    = "x1.5 Multiplier",
		description    = "Multiplies your Multiplier by 1.5.",
		cost           = 1000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "multiply", rewardValue = 1.5 },
		},
		repeatable     = false,
		costScaling    = 1,
		layer          = 1,
		unlockCondition = nil,
	},

	{
		id             = "mult_50",
		displayName    = "+50 Multiplier",
		description    = "Adds 50 to your Multiplier.",
		cost           = 2500,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add", rewardValue = 50 },
		},
		repeatable     = true,
		costScaling    = 1.35,
		layer          = 1,
		unlockCondition = nil,
	},

	{
		id             = "mult_100",
		displayName    = "+100 Multiplier",
		description    = "Adds 100 to your Multiplier.",
		cost           = 5000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add", rewardValue = 100 },
		},
		repeatable     = true,
		costScaling    = 1.35,
		layer          = 1,
		unlockCondition = nil,
	},

	{
		id             = "mult_cash_double",
		displayName    = "x2 Cash + 50 Mult",
		description    = "Doubles your Cash gain and adds 50 Multiplier.",
		cost           = 10000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "CashPerSec",  rewardOperation = "multiply", rewardValue = 2   },
			{ rewardType = "Multiplier",  rewardOperation = "add",      rewardValue = 50  },
		},
		repeatable     = false,
		costScaling    = 1,
		layer          = 1,
		unlockCondition = nil,
	},

	{
		id             = "mult_250",
		displayName    = "+250 Multiplier",
		description    = "Adds 250 to your Multiplier.",
		cost           = 25000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add", rewardValue = 250 },
		},
		repeatable     = true,
		costScaling    = 1.35,
		layer          = 1,
		unlockCondition = nil,
	},

	-- =========================================================
	-- LAYER 2: Post-Rebirth Buttons (require rebirths, buy with Cash)
	-- =========================================================

	{
		id             = "reb_mult_500",
		displayName    = "+500 Multiplier",
		description    = "Adds 500 to your Multiplier. Requires 1 Rebirth.",
		cost           = 50000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add", rewardValue = 500 },
		},
		repeatable     = true,
		costScaling    = 1.35,
		layer          = 2,
		unlockCondition = { stat = "Rebirths", minimum = 1 },
	},

	{
		id             = "reb_mult_x2",
		displayName    = "x2 Multiplier",
		description    = "Doubles your Multiplier. Requires 1 Rebirth.",
		cost           = 100000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "multiply", rewardValue = 2 },
		},
		repeatable     = false,
		costScaling    = 1,
		layer          = 2,
		unlockCondition = { stat = "Rebirths", minimum = 1 },
	},

	{
		id             = "reb_cash10_mult1000",
		displayName    = "+10% Cash + 1K Mult",
		description    = "+10% Cash Gain and +1000 Multiplier. Requires 2 Rebirths.",
		cost           = 500000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "CashPerSec",  rewardOperation = "multiply", rewardValue = 1.1    },
			{ rewardType = "Multiplier",  rewardOperation = "add",      rewardValue = 1000   },
		},
		repeatable     = false,
		costScaling    = 1,
		layer          = 2,
		unlockCondition = { stat = "Rebirths", minimum = 2 },
	},

	{
		id             = "reb_mult_x3",
		displayName    = "x3 Multiplier",
		description    = "Triples your Multiplier. Requires 3 Rebirths.",
		cost           = 1000000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "multiply", rewardValue = 3 },
		},
		repeatable     = false,
		costScaling    = 1,
		layer          = 2,
		unlockCondition = { stat = "Rebirths", minimum = 3 },
	},

	{
		id             = "reb_mult5000_cash_x1_5",
		displayName    = "+5K Mult + x1.5 Cash",
		description    = "+5000 Multiplier and x1.5 Cash Gain. Requires 5 Rebirths.",
		cost           = 5000000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add",      rewardValue = 5000 },
			{ rewardType = "CashPerSec", rewardOperation = "multiply", rewardValue = 1.5  },
		},
		repeatable     = false,
		costScaling    = 1,
		layer          = 2,
		unlockCondition = { stat = "Rebirths", minimum = 5 },
	},

	-- =========================================================
	-- LAYER 3: Post-Ascension Buttons (require ascensions, buy with Cash)
	-- =========================================================

	{
		id             = "asc_mult25k_cash_x2",
		displayName    = "+25K Mult + x2 Cash",
		description    = "+25,000 Multiplier and x2 Cash Gain. Requires 1 Ascension.",
		cost           = 50000000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier", rewardOperation = "add",      rewardValue = 25000 },
			{ rewardType = "CashPerSec", rewardOperation = "multiply", rewardValue = 2     },
		},
		repeatable     = false,
		costScaling    = 1,
		layer          = 3,
		unlockCondition = { stat = "Ascensions", minimum = 1 },
	},

	{
		id             = "asc_mult_x5_rebirth50",
		displayName    = "x5 Mult + +50% Reb Boost",
		description    = "x5 Multiplier and +50% Rebirth Boost. Requires 1 Ascension.",
		cost           = 500000000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier",    rewardOperation = "multiply", rewardValue = 5    },
			{ rewardType = "RebirthBoost",  rewardOperation = "add",      rewardValue = 0.5  },
		},
		repeatable     = false,
		costScaling    = 1,
		layer          = 3,
		unlockCondition = { stat = "Ascensions", minimum = 1 },
	},

	{
		id             = "asc_mult_x10_cash_x2_reb100",
		displayName    = "x10 Mult + x2 Cash + +100% Reb",
		description    = "x10 Multiplier, x2 Cash Gain, +100% Rebirth Boost. Requires 2 Ascensions.",
		cost           = 5000000000,
		costType       = "Cash",
		rewards        = {
			{ rewardType = "Multiplier",    rewardOperation = "multiply", rewardValue = 10   },
			{ rewardType = "CashPerSec",    rewardOperation = "multiply", rewardValue = 2    },
			{ rewardType = "RebirthBoost",  rewardOperation = "add",      rewardValue = 1.0  },
		},
		repeatable     = false,
		costScaling    = 1,
		layer          = 3,
		unlockCondition = { stat = "Ascensions", minimum = 2 },
	},

	-- =========================================================
	-- SPECIAL: Rebirth Button
	-- =========================================================

	{
		id             = "rebirth_trigger",
		displayName    = "REBIRTH",
		description    = "Reset Cash & Multiplier. Gain +1 Rebirth and a permanent Rebirth Boost! Requires 1,000 Multiplier.",
		cost           = 0,
		costType       = "None",
		rewards        = {
			{ rewardType = "Rebirths", rewardOperation = "add", rewardValue = 1 },
		},
		repeatable     = true,
		costScaling    = 1,
		layer          = 4,
		unlockCondition = { stat = "Multiplier", minimum = 1000 },
	},

	-- =========================================================
	-- SPECIAL: Ascension Button
	-- =========================================================

	{
		id             = "ascension_trigger",
		displayName    = "ASCEND",
		description    = "Reset Cash, Multiplier & Rebirths. Gain +1 Ascension and a permanent Ascension Boost! Requires 10 Rebirths.",
		cost           = 0,
		costType       = "None",
		rewards        = {
			{ rewardType = "Ascensions", rewardOperation = "add", rewardValue = 1 },
		},
		repeatable     = true,
		costScaling    = 1,
		layer          = 4,
		unlockCondition = { stat = "Rebirths", minimum = 10 },
	},
}

-- Build a lookup table by id for fast access
ButtonConfig.ById = {}
for _, btn in ipairs(ButtonConfig.Buttons) do
	ButtonConfig.ById[btn.id] = btn
end

return ButtonConfig
