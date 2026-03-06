-- ButtonFeedback.lua (StarterPlayerScripts)
-- Shows purchase feedback popups and notifications when a player
-- steps on a button (success, failure, or locked messages).

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local TweenService       = game:GetService("TweenService")

local Shared             = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents       = require(Shared:WaitForChild("RemoteEvents"))

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- Notification ScreenGui
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name         = "ButtonFeedbackGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10
screenGui.Parent       = playerGui

-- Container for stacked notifications (bottom-center)
local container = Instance.new("Frame")
container.Name              = "NotifContainer"
container.Size              = UDim2.new(0, 300, 0, 300)
container.Position          = UDim2.new(0.5, -150, 1, -320)
container.BackgroundTransparency = 1
container.ClipsDescendants  = false
container.Parent            = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder        = Enum.SortOrder.LayoutOrder
listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
listLayout.Padding          = UDim.new(0, 5)
listLayout.Parent           = container

-- ============================================================
-- Show a single notification popup
-- ============================================================

local notifCounter = 0

local function showNotification(success: boolean, message: string)
	notifCounter = notifCounter + 1

	local notif = Instance.new("Frame")
	notif.Name              = "Notif_" .. notifCounter
	notif.LayoutOrder       = notifCounter
	notif.Size              = UDim2.new(1, 0, 0, 44)
	notif.BackgroundTransparency = 1
	notif.Parent            = container

	local bg = Instance.new("Frame")
	bg.Size                 = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3     = success
		and Color3.fromRGB(30, 140, 60)
		or  Color3.fromRGB(160, 40, 40)
	bg.BackgroundTransparency = 0.2
	bg.BorderSizePixel      = 0
	bg.Parent               = notif

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius   = UDim.new(0, 8)
	bgCorner.Parent         = bg

	local icon = Instance.new("TextLabel")
	icon.Size               = UDim2.new(0, 36, 1, 0)
	icon.BackgroundTransparency = 1
	icon.TextColor3         = Color3.fromRGB(255, 255, 255)
	icon.Text               = success and "✅" or "❌"
	icon.Font               = Enum.Font.GothamBold
	icon.TextScaled         = true
	icon.Parent             = bg

	local label = Instance.new("TextLabel")
	label.Size              = UDim2.new(1, -44, 1, 0)
	label.Position          = UDim2.new(0, 40, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3        = Color3.fromRGB(255, 255, 255)
	label.Text              = message
	label.Font              = Enum.Font.GothamBold
	label.TextScaled        = true
	label.TextXAlignment    = Enum.TextXAlignment.Left
	label.TextTruncate      = Enum.TextTruncate.AtEnd
	label.Parent            = bg

	-- Fade in
	bg.BackgroundTransparency = 1
	icon.TextTransparency   = 1
	label.TextTransparency  = 1

	local fadeIn = TweenService:Create(bg, TweenInfo.new(0.2), { BackgroundTransparency = 0.2 })
	local fadeInText = TweenService:Create(label, TweenInfo.new(0.2), { TextTransparency = 0 })
	local fadeInIcon = TweenService:Create(icon, TweenInfo.new(0.2), { TextTransparency = 0 })
	fadeIn:Play()
	fadeInText:Play()
	fadeInIcon:Play()

	-- Hold, then fade out and destroy
	task.delay(2.5, function()
		local fadeOut = TweenService:Create(bg, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
		local fadeOutText = TweenService:Create(label, TweenInfo.new(0.4), { TextTransparency = 1 })
		local fadeOutIcon = TweenService:Create(icon, TweenInfo.new(0.4), { TextTransparency = 1 })
		fadeOut:Play()
		fadeOutText:Play()
		fadeOutIcon:Play()
		fadeOut.Completed:Connect(function()
			notif:Destroy()
		end)
	end)
end

-- ============================================================
-- Listen for purchase feedback from server
-- ============================================================

RemoteEvents.get(RemoteEvents.Names.PurchaseFeedback):OnClientEvent:Connect(
	function(success: boolean, message: string, _buttonId: string)
		showNotification(success, message)
	end
)
