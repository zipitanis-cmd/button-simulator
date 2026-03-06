-- RemoteEvents.lua
-- Defines and sets up all RemoteEvents and RemoteFunctions used in Button Simulator.
-- Run on server to create events; clients require this module to get references.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

-- Names of all remote events
RemoteEvents.Names = {
	-- Server -> Client: update the player's stats display
	UpdateStats          = "UpdateStats",
	-- Server -> Client: show purchase feedback (success or failure)
	PurchaseFeedback     = "PurchaseFeedback",
	-- Client -> Server: player requests a rebirth
	RequestRebirth       = "RequestRebirth",
	-- Client -> Server: player requests an ascension
	RequestAscension     = "RequestAscension",
	-- Client -> Server: player toggles a pinned stat on their billboard
	TogglePinnedStat     = "TogglePinnedStat",
	-- Server -> Client: update pinned stats list (for UI sync)
	UpdatePinnedStats    = "UpdatePinnedStats",
	-- Server -> Client: update purchased button states
	UpdateButtonStates   = "UpdateButtonStates",
}

-- Folder in ReplicatedStorage that holds all remote instances
local FOLDER_NAME = "RemoteEventFolder"

-- Returns (or creates) the RemoteEvent folder
local function getOrCreateFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = FOLDER_NAME
		folder.Parent = ReplicatedStorage
	end
	return folder
end

-- Called once on the server to create all RemoteEvents
function RemoteEvents.setupServer()
	local folder = getOrCreateFolder()
	for _, name in ipairs({
		RemoteEvents.Names.UpdateStats,
		RemoteEvents.Names.PurchaseFeedback,
		RemoteEvents.Names.RequestRebirth,
		RemoteEvents.Names.RequestAscension,
		RemoteEvents.Names.TogglePinnedStat,
		RemoteEvents.Names.UpdatePinnedStats,
		RemoteEvents.Names.UpdateButtonStates,
	}) do
		if not folder:FindFirstChild(name) then
			local event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = folder
		end
	end
end

-- Get a RemoteEvent by name (works on both client and server after setup)
function RemoteEvents.get(name: string): RemoteEvent
	local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME, 10)
	if not folder then
		error("[RemoteEvents] Folder not found: " .. FOLDER_NAME)
	end
	local event = folder:WaitForChild(name, 10)
	if not event then
		error("[RemoteEvents] Event not found: " .. name)
	end
	return event :: RemoteEvent
end

return RemoteEvents
