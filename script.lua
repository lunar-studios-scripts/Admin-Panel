-- Join my Discord :3 https://discord.gg/5GeQAXYYcW
-- Created by @LunarRbxZ
-- Fixed and Enhanced Admin Script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local client = Players.LocalPlayer
local Mouse = client:GetMouse()
local prefix = "!"
local waypoints = {}
local tracerLines = {}

-- Wait for character to load
local char = client.Character or client.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart", 10)
local hum = char:WaitForChild("Humanoid", 10)

if not hrp or not hum then
	StarterGui:SetCore("SendNotification", {Title = "Lunar Error", Text = "Character not loaded. Re-execute after spawn.", Duration = 10})
	return
end

client.Chatted:Connect(processCmd)
-- =============================================================
-- MOBILE UI AUTO-RESIZE - STRICT VERSION
-- =============================================================

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local client = Players.LocalPlayer

-- CONFIG: Adjust this if mobile UI is still too big/small
local MOBILE_SCALE = 0.55

-- EXACT list of your admin UI names - add more if you create new ones
local LUNAR_UI_NAMES = {
    ["LunarGui"] = true,
    ["LunarNotifs"] = true,
    ["LunarWatermark"] = true,
    ["LunarSplash"] = true,
    ["LunarHubGUI"] = true,
    ["AimbotPanel"] = true,
    ["FlySystemPanel"] = true,
    ["SpeedPanel"] = true,
    ["JoinLogsPanel"] = true,
    ["logsPanel"] = true,
    ["stopwatchPanel"] = true,
    ["CmdBarGui"] = true,
    ["SpeedPanel"] = true,
    ["LunarTouchFling"] = true,
    ["LunarCrosshairCMD"] = true,
    ["SunGlare"] = true,
    ["SpectateGui"] = true,
}

-- Detect mobile device
local function isMobile()
    local touchEnabled = UserInputService.TouchEnabled
    local keyboardEnabled = UserInputService.KeyboardEnabled
    local mouseEnabled = UserInputService.MouseEnabled
    
    if touchEnabled and (not keyboardEnabled or not mouseEnabled) then
        return true
    end
    
    local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
    if screenSize then
        if math.min(screenSize.X, screenSize.Y) < 600 then
            return true
        end
    end
    
    return false
end

-- Apply UIScale only to whitelisted Lunar UIs
local function applyMobileScale(screenGui)
    if not screenGui or not screenGui:IsA("ScreenGui") then return end
    if not LUNAR_UI_NAMES[screenGui.Name] then return end
    if screenGui:FindFirstChild("MobileUIScale") then return end
    
    local scale = Instance.new("UIScale")
    scale.Name = "MobileUIScale"
    scale.Scale = MOBILE_SCALE
    scale.Parent = screenGui
end

-- Main setup
local function setupMobileResize()
    if not isMobile() then return end -- PC stays untouched completely
    
    local playerGui = client:WaitForChild("PlayerGui")
    
    -- Scale existing Lunar UIs only
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            applyMobileScale(gui)
        end
    end
    
    -- Auto-scale new Lunar UIs as they're created
    playerGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            task.wait()
            applyMobileScale(child)
        end
    end)
end

-- Run immediately
setupMobileResize()

-- Re-run on respawn (some executors reload)
client.CharacterAdded:Connect(function()
    task.wait(1)
    setupMobileResize()
end)

-- Export for manual use if needed
_G.ApplyMobileUIScale = applyMobileScale
--------------------------------------------------------------
---------- loading screen ------------------------------------
--------------------------------------------------------------
local function createInstantSplash(imageId)
	imageId = imageId or "rbxassetid://115041688502921"

	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local ContentProvider = game:GetService("ContentProvider")
	local Lighting = game:GetService("Lighting")
	local RunService = game:GetService("RunService")

	local player = Players.LocalPlayer
	if not player then
		return
	end

	-- PRELOAD IMAGE
	local preload = Instance.new("ImageLabel")
	preload.Image = imageId
	ContentProvider:PreloadAsync({ preload })
	preload:Destroy()

	-- REMOVE OLD
	local old = player.PlayerGui:FindFirstChild("LunarSplash")
	if old then
		old:Destroy()
	end

	-- GUI
	local gui = Instance.new("ScreenGui")
	gui.Name = "LunarSplash"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 999999
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	---------------------------------------------------
	-- BACKGROUND
	---------------------------------------------------

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
	bg.BackgroundTransparency = 1
	bg.BorderSizePixel = 0
	bg.Parent = gui

	-- animated gradient
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 5)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 5))
	})
	gradient.Rotation = 25
	gradient.Parent = bg

	---------------------------------------------------
	-- CINEMATIC BLUR
	---------------------------------------------------

	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Parent = Lighting

	---------------------------------------------------
	-- VIGNETTE
	---------------------------------------------------

	local vignette = Instance.new("ImageLabel")
	vignette.Size = UDim2.fromScale(1.2, 1.2)
	vignette.Position = UDim2.fromScale(-0.1, -0.1)
	vignette.BackgroundTransparency = 1
	vignette.Image = "rbxassetid://4576475446"
	vignette.ImageTransparency = 1
	vignette.ScaleType = Enum.ScaleType.Stretch
	vignette.ZIndex = 2
	vignette.Parent = gui

	---------------------------------------------------
	-- MAIN FRAME
	---------------------------------------------------

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromOffset(420, 420)
	frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 28)
	corner.Parent = frame

	-- glass stroke
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Transparency = 0.4
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Parent = frame

	-- glow
	local glow = Instance.new("ImageLabel")
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.fromScale(0.5, 0.5)
	glow.Size = UDim2.fromScale(1.8, 1.8)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://5028857084"
	glow.ImageColor3 = Color3.fromRGB(255, 255, 255)
	glow.ImageTransparency = 1
	glow.ZIndex = 0
	glow.Parent = frame

	---------------------------------------------------
	-- IMAGE
	---------------------------------------------------

	local image = Instance.new("ImageLabel")
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.fromScale(0.78, 0.78)
	image.BackgroundTransparency = 1
	image.Image = imageId
	image.ImageTransparency = 1
	image.ScaleType = Enum.ScaleType.Fit
	image.ZIndex = 3
	image.Parent = frame

	---------------------------------------------------
-- CINEMATIC LIGHT SWEEP
---------------------------------------------------

local shineHolder = Instance.new("Frame")
shineHolder.Size = UDim2.fromScale(1, 1)
shineHolder.BackgroundTransparency = 1
shineHolder.ClipsDescendants = true
shineHolder.ZIndex = 4
shineHolder.Parent = frame

local shine = Instance.new("ImageLabel")
shine.AnchorPoint = Vector2.new(0.5, 0.5)
shine.Position = UDim2.fromScale(-0.6, 0.5)
shine.Size = UDim2.fromScale(0.45, 1.8)
shine.BackgroundTransparency = 1
shine.Image = "rbxassetid://8992230677"
shine.ImageTransparency = 0.92
shine.ImageColor3 = Color3.fromRGB(255,255,255)
shine.Rotation = 18
shine.ScaleType = Enum.ScaleType.Stretch
shine.ZIndex = 4
shine.Parent = shineHolder

	---------------------------------------------------
	-- SCALE
	---------------------------------------------------

	local scale = Instance.new("UIScale")
	scale.Scale = 0.45
	scale.Parent = frame

	---------------------------------------------------
	-- LOADING TEXT
	---------------------------------------------------

	local text = Instance.new("TextLabel")
	text.AnchorPoint = Vector2.new(0.5, 0)
	text.Position = UDim2.fromScale(0.5, 0.87)
	text.Size = UDim2.fromOffset(300, 40)
	text.BackgroundTransparency = 1
	text.Text = "LOADING"
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextTransparency = 1
	text.Font = Enum.Font.GothamBlack
	text.TextScaled = true
	text.ZIndex = 5
	text.Parent = frame

	---------------------------------------------------
	-- PARTICLES
	---------------------------------------------------

	local attachment = Instance.new("Attachment")
	attachment.Parent = frame

	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxassetid://243660364"
	particles.Rate = 0
	particles.Lifetime = NumberRange.new(1, 1.5)
	particles.Speed = NumberRange.new(18, 26)
	particles.SpreadAngle = Vector2.new(360, 360)
	particles.LightEmission = 1
	particles.Drag = 2
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0)
	})
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particles.Parent = attachment

	---------------------------------------------------
	-- INTRO ANIMATION
	---------------------------------------------------

	TweenService:Create(bg, TweenInfo.new(0.4), {
		BackgroundTransparency = 0.15
	}):Play()

	TweenService:Create(blur, TweenInfo.new(0.45), {
		Size = 36
	}):Play()

	TweenService:Create(vignette, TweenInfo.new(0.5), {
		ImageTransparency = 0.35
	}):Play()

	TweenService:Create(scale, TweenInfo.new(
		0.7,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	), {
		Scale = 1
	}):Play()

	TweenService:Create(image, TweenInfo.new(0.45), {
		ImageTransparency = 0
	}):Play()

	TweenService:Create(text, TweenInfo.new(0.45), {
		TextTransparency = 0
	}):Play()

	TweenService:Create(glow, TweenInfo.new(0.5), {
		ImageTransparency = 0.45
	}):Play()

	task.wait(0.2)

	particles:Emit(40)

	---------------------------------------------------
-- LIGHT SWEEP ANIMATION
---------------------------------------------------

task.spawn(function()
	while gui.Parent do
		shine.Position = UDim2.fromScale(-0.6, 0.5)

		local tween = TweenService:Create(
			shine,
			TweenInfo.new(
				1.8,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			),
			{
				Position = UDim2.fromScale(1.6, 0.5)
			}
		)

		tween:Play()

		task.wait(3.5)
	end
end)

	---------------------------------------------------
	-- FLOATING MOTION
	---------------------------------------------------

	local connection
	local start = tick()

	connection = RunService.RenderStepped:Connect(function()
		if not frame.Parent then
			connection:Disconnect()
			return
		end

		local t = tick() - start

		frame.Position = UDim2.fromScale(
			0.5,
			0.5 + math.sin(t * 1.5) * 0.008
		)

		glow.Rotation += 0.08
	end)

	---------------------------------------------------
	-- HOLD
	---------------------------------------------------

	task.wait(3)

	---------------------------------------------------
	-- OUTRO
	---------------------------------------------------

	local outro = TweenInfo.new(
		0.45,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.In
	)

	TweenService:Create(bg, outro, {
		BackgroundTransparency = 1
	}):Play()

	TweenService:Create(blur, outro, {
		Size = 0
	}):Play()

	TweenService:Create(vignette, outro, {
		ImageTransparency = 1
	}):Play()

	TweenService:Create(frame, outro, {
		BackgroundTransparency = 1
	}):Play()

	TweenService:Create(stroke, outro, {
		Transparency = 1
	}):Play()

	TweenService:Create(image, outro, {
		ImageTransparency = 1
	}):Play()

	TweenService:Create(text, outro, {
		TextTransparency = 1
	}):Play()

	TweenService:Create(glow, outro, {
		ImageTransparency = 1
	}):Play()

	TweenService:Create(scale, outro, {
		Scale = 1.25
	}):Play()

	task.wait(0.5)

	if connection then
		connection:Disconnect()
	end

	gui:Destroy()
	blur:Destroy()
end

createInstantSplash("rbxassetid://115041688502921")
-- =============================================================
-- GLOBAL CONFIGURATION
-- =============================================================
local globalConfig = {
	textColor = Color3.new(1, 1, 1),
	uiTransparency = 0.1,
	strokeTransparency = 0.5
}

-- Store main UI references for transparency control
local lunarGui = nil
local mainFrame = nil

-- =============================================================
-- GLASS EFFECT UTILITY
-- =============================================================
local function applyGlassEffect(frame, transparency, strokeTransparency)
	transparency = transparency or globalConfig.uiTransparency
	strokeTransparency = strokeTransparency or globalConfig.strokeTransparency
	frame.BackgroundTransparency = transparency

	local stroke = frame:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 2
	stroke.Transparency = strokeTransparency
	stroke.Parent = frame

	local corner = frame:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local gradient = frame:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 240))
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 0.9)
	})
	gradient.Rotation = 45
	gradient.Parent = frame
end

-- =============================================================
-- THEMES
-- =============================================================
local themes = {
	Default = {
		main = Color3.fromRGB(25, 25, 35),
		grad1 = Color3.fromRGB(40, 40, 55),
		grad2 = Color3.fromRGB(25, 25, 35),
		accent = Color3.fromRGB(0, 180, 255),
		text = Color3.new(1,1,1),
		btn = Color3.fromRGB(55, 55, 75),
		list = Color3.fromRGB(45, 45, 60),
		glass = Color3.fromRGB(35, 35, 50)
	},
	Pink = {
		main = Color3.fromRGB(255, 192, 203),
		grad1 = Color3.fromRGB(255, 182, 193),
		grad2 = Color3.fromRGB(255, 105, 180),
		accent = Color3.fromRGB(255, 20, 147),
		text = Color3.new(0.1,0.1,0.1),
		btn = Color3.fromRGB(255, 105, 180),
		list = Color3.fromRGB(255, 160, 180),
		glass = Color3.fromRGB(255, 200, 210)
	},
	Blue = {
		main = Color3.fromRGB(30, 40, 70),
		grad1 = Color3.fromRGB(50, 80, 140),
		grad2 = Color3.fromRGB(25, 45, 90),
		accent = Color3.fromRGB(100, 230, 255),
		text = Color3.new(1,1,1),
		btn = Color3.fromRGB(60, 100, 170),
		list = Color3.fromRGB(45, 65, 110),
		glass = Color3.fromRGB(40, 55, 100)
	},
	Red = {
		main = Color3.fromRGB(50, 20, 20),
		grad1 = Color3.fromRGB(126, 35, 35),
		grad2 = Color3.fromRGB(97, 24, 24),
		accent = Color3.fromRGB(255, 100, 100),
		text = Color3.new(1,1,1),
		btn = Color3.fromRGB(190, 50, 50),
		list = Color3.fromRGB(80, 25, 25),
		glass = Color3.fromRGB(70, 25, 25)
	},
	Dark = {
		main = Color3.fromRGB(15, 15, 20),
		grad1 = Color3.fromRGB(30, 30, 40),
		grad2 = Color3.fromRGB(15, 15, 20),
		accent = Color3.fromRGB(0, 200, 255),
		text = Color3.new(1,1,1),
		btn = Color3.fromRGB(40, 40, 55),
		list = Color3.fromRGB(35, 35, 45),
		glass = Color3.fromRGB(25, 25, 35)
	}
}
local currentTheme = themes.Default
-- =============================================================
-- SOUND EFFECTS
-- =============================================================
local currentHoverSound = nil

local function playOpen()
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://126864503471832"
	s.Volume = 0.45
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 3)
end

local function playClose()
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://4566"
	s.Volume = 0.4
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 3)
end

local function playHover()
	-- Stop any previous hover sound to prevent overlap
	if currentHoverSound and currentHoverSound.IsPlaying then
		currentHoverSound:Stop()
	end

	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://107677435338382"
	s.Volume = 1
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 2)

	currentHoverSound = s
end

local function playClick()
	-- Stop hover sound immediately when clicking
	if currentHoverSound and currentHoverSound.IsPlaying then
		currentHoverSound:Stop()
	end

	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://109439703653606"
	s.Volume = 5
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 2)
end

-- =============================================================
-- apply sounds to all buttons NOW
-- =============================================================
local function applySoundsToAllButtons(parent)
	for _, obj in ipairs(parent:GetDescendants()) do
		if obj:IsA("TextButton") or obj:IsA("ImageButton") then

			-- Hover sound
			obj.MouseEnter:Connect(function()
				playHover()
			end)

			-- Click sound + cancel hover
			obj.MouseButton1Click:Connect(function()
				playClick()
			end)
		end
	end
end

-- Setup sounds for main GUI and future panels
local function setupButtonSounds()
	if lunarGui then
		task.wait(0.5)
		applySoundsToAllButtons(lunarGui)
	end

	-- Auto-apply to any new panels
	client.PlayerGui.ChildAdded:Connect(function(child)
		if child:IsA("ScreenGui") then
			task.wait(0.3)
			applySoundsToAllButtons(child)
		end
	end)
end

-- =============================================================
-- better notis
-- =============================================================
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "LunarNotifs"
notifGui.ResetOnSpawn = false
notifGui.DisplayOrder = 2147483647
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
notifGui.ScreenInsets = Enum.ScreenInsets.None
notifGui.IgnoreGuiInset = true
notifGui.Parent = game:GetService("CoreGui")

local activeNotifications = {}
local notifHeight = 76
local notifSpacing = 12
local startY = 20 -- top padding
local notifDuration = 5

local currentNotifSound = nil

local function playNotifSound()
	if currentNotifSound and currentNotifSound.IsPlaying then
		currentNotifSound:Stop()
	end

	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://97643101798871"
	s.Volume = 0.55
	s.Parent = SoundService
	s:Play()

	currentNotifSound = s
	Debris:AddItem(s, 4)
end

local function repositionAll()
	for i, notif in ipairs(activeNotifications) do
		if notif and notif.Parent then
			local targetY = startY + ((i - 1) * (notifHeight + notifSpacing))
			TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.new(1, -360, 0, targetY)
			}):Play()
		end
	end
end

local function notify(text, col)
	col = col or currentTheme.accent or Color3.fromRGB(147, 112, 219)

	-- Main container
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0, 340, 0, notifHeight)
	f.Position = UDim2.new(1, 120, 0, -200) -- start off-screen top-right
	f.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	f.BorderSizePixel = 0
	f.BackgroundTransparency = 1
	f.Parent = notifGui
	f.ZIndex = 2147483647

	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

	-- Subtle border glow
	local stroke = Instance.new("UIStroke")
	stroke.Color = col
	stroke.Transparency = 1
	stroke.Thickness = 1.5
	stroke.ZIndex = 2147483647
	stroke.Parent = f

	-- Moon emoji
	local moonIcon = Instance.new("TextLabel")
	moonIcon.Size = UDim2.new(0, 28, 0, 28)
	moonIcon.Position = UDim2.new(0, 12, 0, 8)
	moonIcon.BackgroundTransparency = 1
	moonIcon.Text = "🌙"
	moonIcon.TextSize = 22
	moonIcon.Font = Enum.Font.GothamBold
	moonIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	moonIcon.TextTransparency = 1
	moonIcon.ZIndex = 2147483647
	moonIcon.Parent = f

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -52, 0, 28)
	titleLabel.Position = UDim2.new(0, 44, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Lunar"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 2147483647
	titleLabel.Parent = f

	-- Message
	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -24, 0, 32)
	msgLabel.Position = UDim2.new(0, 12, 0, 38)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = text
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.TextSize = 14
	msgLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	msgLabel.TextTransparency = 1
	msgLabel.TextWrapped = true
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.TextYAlignment = Enum.TextYAlignment.Top
	msgLabel.ZIndex = 2147483647
	msgLabel.Parent = f

	-- Timer progress bar at bottom
	local timerBar = Instance.new("Frame")
	timerBar.Size = UDim2.new(1, 0, 0, 3)
	timerBar.Position = UDim2.new(0, 0, 1, -3)
	timerBar.BackgroundColor3 = col
	timerBar.BorderSizePixel = 0
	timerBar.BackgroundTransparency = 1
	timerBar.ZIndex = 2147483647
	timerBar.Parent = f

	Instance.new("UICorner", timerBar).CornerRadius = UDim.new(0, 2)

	-- Play sound
	playNotifSound()

	-- Add to stack (append to end = bottom of list)
	table.insert(activeNotifications, f)

	-- Calculate target Y for this notification
	local targetY = startY + ((#activeNotifications - 1) * (notifHeight + notifSpacing))

	-- Entrance Animation
	TweenService:Create(f, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -360, 0, targetY),
		BackgroundTransparency = 0.05
	}):Play()

	TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0.7
	}):Play()

	TweenService:Create(moonIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()

	TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()

	TweenService:Create(msgLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()

	TweenService:Create(timerBar, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	}):Play()

	-- Timer animation — bar shrinks over duration
	TweenService:Create(timerBar, TweenInfo.new(notifDuration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 3)
	}):Play()

	-- Auto remove after duration
	task.delay(notifDuration, function()
		if not f.Parent then return end

		-- Remove from stack
		for i, notif in ipairs(activeNotifications) do
			if notif == f then
				table.remove(activeNotifications, i)
				break
			end
		end

		-- Exit animation (slide right and fade)
		TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 120, 0, f.Position.Y.Offset),
			BackgroundTransparency = 1
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()

		TweenService:Create(moonIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			TextTransparency = 1
		}):Play()

		TweenService:Create(titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			TextTransparency = 1
		}):Play()

		TweenService:Create(msgLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			TextTransparency = 1
		}):Play()

		TweenService:Create(timerBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()

		-- Slide remaining notifications UP to fill gap
		task.delay(0.2, function()
			repositionAll()
		end)

		task.delay(0.6, function()
			if f.Parent then f:Destroy() end
		end)
	end)

	-- Limit to 6 notifications (remove oldest from top)
	if #activeNotifications > 6 then
		local old = table.remove(activeNotifications, 1) -- remove first (oldest)
		if old and old.Parent then
			TweenService:Create(old, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Position = UDim2.new(1, 120, 0, old.Position.Y.Offset),
				BackgroundTransparency = 1
			}):Play()
			task.delay(0.4, function()
				if old.Parent then old:Destroy() end
			end)
			-- Reposition rest after removing top one
			task.delay(0.2, repositionAll)
		end
	end
end
-- =============================================================
-- Lunar Hub watermakr yea
-- =============================================================
task.spawn(function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local Stats = game:GetService("Stats")
	local CoreGui = game:GetService("CoreGui")

	local client = Players.LocalPlayer

	-- Clean up old from CoreGui
	if CoreGui:FindFirstChild("LunarWatermark") then
		CoreGui.LunarWatermark:Destroy()
	end

	-- ================= GUI (CoreGui — highest possible layer) =================
	local sg = Instance.new("ScreenGui")
	sg.Name = "LunarWatermark"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.DisplayOrder = 2147483647 -- MAX display order
	sg.ScreenInsets = Enum.ScreenInsets.None
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
	sg.Parent = CoreGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 380, 0, 34)
	frame.Position = UDim2.new(1, -3220, 0, 15) -- YOUR ORIGINAL POSITION, UNCHANGED
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	frame.BackgroundTransparency = 0.15
	frame.ZIndex = 2147483647
	frame.Parent = sg

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

	local dragTab = Instance.new("Frame")
	dragTab.Size = UDim2.new(0, 30, 1, 0)
	dragTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	dragTab.BackgroundTransparency = 0.2
	dragTab.ZIndex = 2147483647
	dragTab.Parent = frame

	Instance.new("UICorner", dragTab).CornerRadius = UDim.new(0, 16)

	local tabLabel = Instance.new("TextLabel")
	tabLabel.Size = UDim2.fromScale(1, 1)
	tabLabel.BackgroundTransparency = 1
	tabLabel.Text = "≡"
	tabLabel.TextSize = 18
	tabLabel.Font = Enum.Font.GothamBold
	tabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabLabel.ZIndex = 2147483647
	tabLabel.Parent = dragTab

	local moon = Instance.new("TextLabel", frame)
	moon.Size = UDim2.new(0, 32, 1, 0)
	moon.Position = UDim2.new(0, 42, 0, 0)
	moon.BackgroundTransparency = 1
	moon.Text = "🌙"
	moon.TextColor3 = Color3.fromRGB(255, 215, 0)
	moon.TextSize = 22
	moon.Font = Enum.Font.GothamBold
	moon.ZIndex = 2147483647

	local label = Instance.new("TextLabel", frame)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -90, 1, 0)
	label.Position = UDim2.new(0, 80, 0, 0)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "Lunar Hub | Loading..."
	label.ZIndex = 2147483647

	-- TOGGLE SYSTEM
	local visible = true

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.P then
			visible = not visible
			frame.Visible = visible
		end
	end)

	-- dragging
	local dragging = false
	local dragStart
	local startPos
	local targetPos = frame.Position

	dragTab.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	dragTab.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local delta = input.Position - dragStart
			targetPos = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	RunService.RenderStepped:Connect(function()
		frame.Position = frame.Position:Lerp(targetPos, 0.25)
	end)

	-- ================= MORE ACCURATE FPS =================
	local fps = 60
	local frameCount = 0
	local fpsTimer = 0
	local fpsUpdateInterval = 0.5

	RunService.RenderStepped:Connect(function(dt)
		frameCount += 1
		fpsTimer += dt

		if fpsTimer >= fpsUpdateInterval then
			local measuredFPS = frameCount / fpsTimer
			fps = fps + (measuredFPS - fps) * 0.3
			frameCount = 0
			fpsTimer = 0
		end
	end)

	-- ================= MORE ACCURATE PING =================
	local ping = 0

	task.spawn(function()
		while sg.Parent do
			local rawPing = 0

			-- Try Stats.PerformanceStats.Ping first (most accurate)
			pcall(function()
				local perfStats = Stats.PerformanceStats
				if perfStats then
					local pingStat = perfStats:FindFirstChild("Ping")
					if pingStat then
						rawPing = pingStat:GetValue()
					end
				end
			end)

			-- Fallback to GetNetworkPing if Stats ping unavailable
			if rawPing <= 0 then
				pcall(function()
					rawPing = client:GetNetworkPing() * 1000
				end)
			end

			-- Smooth the ping value
			ping = ping + (rawPing - ping) * 0.2

			label.Text = string.format(
				"Lunar Hub | %d FPS | %d ms",
				math.floor(fps + 0.5),
				math.floor(ping + 0.5)
			)

			task.wait(0.25)
		end
	end)
end)
-- ============================================
-- AUTOEXEC COMMANDS
-- ============================================
-- work in process or smt :3
-- ============================================
-- Volume changer 
-- ============================================
local function Volume(plr, args)
	local vol = tonumber(args[1])
	if not vol then
		notify("Usage: !volume <0-10>", Color3.fromRGB(255, 100, 100))
		return
	end
	
	vol = math.clamp(vol, 0, 10)
	local scale = vol / 10
	
	-- Set all currently playing sounds in workspace
	for _, sound in ipairs(workspace:GetDescendants()) do
		if sound:IsA("Sound") then
			sound.Volume = scale
		end
	end
	
	-- Set all sounds in SoundService
	for _, sound in ipairs(game:GetService("SoundService"):GetDescendants()) do
		if sound:IsA("Sound") then
			sound.Volume = scale
		end
	end
	
	-- Set all sounds in ReplicatedStorage
	for _, sound in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
		if sound:IsA("Sound") then
			sound.Volume = scale
		end
	end
	
	-- Hook new sounds so they also get scaled
	if not _G.volumeScale then
		_G.volumeScale = scale
		
		workspace.DescendantAdded:Connect(function(desc)
			if desc:IsA("Sound") then
				task.wait()
				desc.Volume = _G.volumeScale
			end
		end)
		
		game:GetService("SoundService").DescendantAdded:Connect(function(desc)
			if desc:IsA("Sound") then
				task.wait()
				desc.Volume = _G.volumeScale
			end
		end)
	else
		_G.volumeScale = scale
	end
	
	notify("Volume: " .. vol .. "/10", currentTheme.accent)
end
-- ============================================
-- Crosshair tingy
-- ============================================
_G.LunarCrosshairData = {
	enabled = false,
	gui = nil,
	connection = nil
}

function LoadLunarCrosshair()
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local StarterGui = game:GetService("StarterGui")
	local CoreGui = game:GetService("CoreGui")

	local client = Players.LocalPlayer
	local mouse = client:GetMouse()

	local data = _G.LunarCrosshairData

	if data.enabled and data.gui then
		StarterGui:SetCore("SendNotification", {
			Title = "Crosshair",
			Text = "Already enabled! Press [RightShift] for settings",
			Duration = 3
		})
		return
	end

	if data.gui then
		data.gui:Destroy()
	end
	if data.connection then
		data.connection:Disconnect()
	end

	data.enabled = true

	-- ================= GUI (CoreGui — highest possible layer) =================
	local gui = Instance.new("ScreenGui")
	gui.Name = "LunarCrosshairCMD"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.DisplayOrder = 2147483647 -- MAX display order, above everything
	gui.ScreenInsets = Enum.ScreenInsets.None -- full screen, no safe area padding
	gui.Parent = CoreGui -- PARENT TO COREGUI so it's above all player UI + CoreGui elements
	data.gui = gui

	-- Settings
	local settings = {
		VertLength = 40,
		HorzLength = 40,
		Width = 1,
		RotationSpeed = 120,
		RainbowSpeed = 1.5,
		YOffset = 0,
		TextGap = 8,
		Text = "Lunar.gg",
		Symbol = "",
		SpinEnabled = true,
		VFXEnabled = false
	}

	-- Store settings in data
	data.settings = settings

	-- ================= CROSSHAIR =================
	local center = Instance.new("Frame")
	center.BackgroundTransparency = 1
	center.Size = UDim2.fromOffset(1, 1)
	center.AnchorPoint = Vector2.new(0.5, 0.5)
	center.ZIndex = 2147483647 -- max ZIndex
	center.Parent = gui

	-- Vertical line
	local vertical = Instance.new("Frame")
	vertical.BorderSizePixel = 0
	vertical.ZIndex = 2147483647
	vertical.Parent = center

	-- Horizontal line
	local horizontal = Instance.new("Frame")
	horizontal.BorderSizePixel = 0
	horizontal.ZIndex = 2147483647
	horizontal.Parent = center

	-- Symbol
	local symbol = Instance.new("TextLabel")
	symbol.BackgroundTransparency = 1
	symbol.Size = UDim2.fromScale(1, 1)
	symbol.AnchorPoint = Vector2.new(0.5, 0.5)
	symbol.Position = UDim2.fromScale(0.5, 0.5)
	symbol.Font = Enum.Font.GothamBold
	symbol.TextStrokeTransparency = 0.5
	symbol.TextStrokeColor3 = Color3.new(0, 0, 0)
	symbol.ZIndex = 2147483647
	symbol.Parent = center
	symbol.Visible = false

	-- Text under crosshair
	local text = Instance.new("TextLabel")
	text.Text = settings.Text
	text.Font = Enum.Font.GothamBold
	text.TextSize = 18
	text.BackgroundTransparency = 1
	text.AnchorPoint = Vector2.new(0.5, 0)
	text.ZIndex = 2147483647
	text.TextStrokeTransparency = 0.5
	text.TextStrokeColor3 = Color3.new(0, 0, 0)
	text.TextXAlignment = Enum.TextXAlignment.Center
	text.Parent = gui

	-- ================= SETTINGS PANEL =================
	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromOffset(240, 540)
	panel.Position = UDim2.fromOffset(30, 200)
	panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	panel.BorderSizePixel = 0
	panel.Visible = true
	panel.ZIndex = 2147483646 -- just below crosshair elements
	panel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = panel

	local title = Instance.new("TextLabel")
	title.Text = "Lunar Crosshair (Right Shift: Toggle)"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextColor3 = Color3.new(1, 1, 1)
	title.ZIndex = 2147483646
	title.Parent = panel

	-- Dragging
	local dragging, dragStart, startPos
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = panel.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			panel.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- ================= INPUT MAKER FUNCTIONS =================
	local function makeInput(name, yOffset, key, minVal, maxVal)
		local label = Instance.new("TextLabel")
		label.Text = name
		label.Position = UDim2.fromOffset(10, yOffset)
		label.Size = UDim2.fromOffset(130, 20)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 2147483646
		label.Parent = panel

		local box = Instance.new("TextBox")
		box.Text = tostring(settings[key])
		box.Position = UDim2.fromOffset(150, yOffset)
		box.Size = UDim2.fromOffset(75, 20)
		box.ClearTextOnFocus = false
		box.Font = Enum.Font.Gotham
		box.TextSize = 12
		box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		box.TextColor3 = Color3.new(1, 1, 1)
		box.BorderSizePixel = 0
		box.ZIndex = 2147483646
		box.Parent = panel

		local boxCorner = Instance.new("UICorner")
		boxCorner.CornerRadius = UDim.new(0, 6)
		boxCorner.Parent = box

		box:GetPropertyChangedSignal("Text"):Connect(function()
			local num = tonumber(box.Text)
			if num and num >= minVal and num <= maxVal then
				settings[key] = num
			end
		end)

		box.FocusLost:Connect(function()
			local num = tonumber(box.Text)
			if num then
				settings[key] = math.clamp(num, minVal, maxVal)
				box.Text = tostring(settings[key])
			else
				box.Text = tostring(settings[key])
			end
		end)
	end

	local function makeTextInput(name, yOffset, key)
		local label = Instance.new("TextLabel")
		label.Text = name
		label.Position = UDim2.fromOffset(10, yOffset)
		label.Size = UDim2.fromOffset(80, 20)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 2147483646
		label.Parent = panel

		local box = Instance.new("TextBox")
		box.Text = settings[key]
		box.Position = UDim2.fromOffset(95, yOffset)
		box.Size = UDim2.fromOffset(140, 20)
		box.ClearTextOnFocus = false
		box.Font = Enum.Font.GothamBold
		box.TextSize = 13
		box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		box.TextColor3 = Color3.new(1, 1, 1)
		box.BorderSizePixel = 0
		box.ZIndex = 2147483646
		box.Parent = panel

		local boxCorner = Instance.new("UICorner")
		boxCorner.CornerRadius = UDim.new(0, 6)
		boxCorner.Parent = box

		box:GetPropertyChangedSignal("Text"):Connect(function()
			settings[key] = box.Text
		end)

		return box
	end

	local function makeToggle(name, yOffset, key)
		local label = Instance.new("TextLabel")
		label.Text = name
		label.Position = UDim2.fromOffset(10, yOffset)
		label.Size = UDim2.fromOffset(130, 20)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 2147483646
		label.Parent = panel

		local button = Instance.new("TextButton")
		button.Text = settings[key] and "On" or "Off"
		button.Position = UDim2.fromOffset(150, yOffset)
		button.Size = UDim2.fromOffset(75, 20)
		button.Font = Enum.Font.Gotham
		button.TextSize = 12
		button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.BorderSizePixel = 0
		button.ZIndex = 2147483646
		button.Parent = panel

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = button

		button.MouseButton1Click:Connect(function()
			settings[key] = not settings[key]
			button.Text = settings[key] and "On" or "Off"
		end)
	end

	-- Create all inputs
	makeInput("Vert Length", 40, "VertLength", 1, 10000)
	makeInput("Horz Length", 70, "HorzLength", 1, 10000)
	makeInput("Width", 100, "Width", 1, 10000)
	makeInput("Rotation", 130, "RotationSpeed", 0, 10000)
	makeInput("Rainbow", 160, "RainbowSpeed", 0, 10000)
	makeInput("Y Offset", 190, "YOffset", -50, 50)
	makeInput("Text Gap", 220, "TextGap", 0, 10000)

	makeTextInput("Text", 255, "Text")
	local symbolBox = makeTextInput("Symbol", 290, "Symbol")

	-- Symbol list
	local listLabel = Instance.new("TextLabel")
	listLabel.Text = "Select Symbol:"
	listLabel.Position = UDim2.fromOffset(10, 320)
	listLabel.Size = UDim2.fromOffset(220, 20)
	listLabel.BackgroundTransparency = 1
	listLabel.Font = Enum.Font.Gotham
	listLabel.TextSize = 12
	listLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	listLabel.TextXAlignment = Enum.TextXAlignment.Left
	listLabel.ZIndex = 2147483646
	listLabel.Parent = panel

	local symbolList = Instance.new("ScrollingFrame")
	symbolList.Position = UDim2.fromOffset(10, 340)
	symbolList.Size = UDim2.fromOffset(220, 100)
	symbolList.BackgroundTransparency = 1
	symbolList.CanvasSize = UDim2.new(0, 0, 0, 0)
	symbolList.ScrollBarThickness = 4
	symbolList.ZIndex = 2147483646
	symbolList.Parent = panel

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(30, 30)
	grid.CellPadding = UDim2.fromOffset(5, 5)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = symbolList

	local symbols = {"卐","+","-","×","÷","*","•","○","□","△","▽","♡","♥","★","☆","!","@","#","$","%","^","&","(",")","[","]","{","}","<<",">","/","\\","|","~"}
	for _, sym in ipairs(symbols) do
		local btn = Instance.new("TextButton")
		btn.Text = sym
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 20
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.BorderSizePixel = 0
		btn.ZIndex = 2147483646

		local symCorner = Instance.new("UICorner")
		symCorner.CornerRadius = UDim.new(0, 6)
		symCorner.Parent = btn

		btn.Parent = symbolList
		btn.MouseButton1Click:Connect(function()
			settings.Symbol = sym
			symbolBox.Text = sym
		end)
	end

	symbolList.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y)

	-- Toggles
	makeToggle("Spin", 450, "SpinEnabled")
	makeToggle("VFX", 480, "VFXEnabled")

	-- Discord button
	local discordButton = Instance.new("TextButton")
	discordButton.Text = "Join Discord!"
	discordButton.Position = UDim2.fromOffset(10, 510)
	discordButton.Size = UDim2.fromOffset(220, 30)
	discordButton.Font = Enum.Font.GothamBold
	discordButton.TextSize = 16
	discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	discordButton.TextColor3 = Color3.new(1, 1, 1)
	discordButton.BorderSizePixel = 0
	discordButton.ZIndex = 2147483646
	discordButton.Parent = panel

	local dbCorner = Instance.new("UICorner")
	dbCorner.CornerRadius = UDim.new(0, 8)
	dbCorner.Parent = discordButton

	discordButton.MouseButton1Click:Connect(function()
		local link = "https://discord.gg/5GeQAXYYcW"
		if setclipboard then
			setclipboard(link)
			StarterGui:SetCore("SendNotification", {
				Title = "Discord",
				Text = "Link copied!",
				Duration = 3
			})
		else
			StarterGui:SetCore("SendNotification", {
				Title = "Discord",
				Text = link,
				Duration = 5
			})
		end
	end)

	-- Toggle panel with RightShift
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			panel.Visible = not panel.Visible
		end
	end)

	-- ================= PARTICLE SPAWN =================
	local function spawnParticle(color)
		local p = Instance.new("Frame")
		p.Size = UDim2.fromOffset(settings.Width * 2, settings.Width * 2)
		p.BackgroundColor3 = color
		p.BackgroundTransparency = 0
		p.AnchorPoint = Vector2.new(0.5, 0.5)
		p.Position = UDim2.fromOffset(0, 0)
		p.BorderSizePixel = 0
		p.ZIndex = 2147483645
		p.Parent = center

		local pCorner = Instance.new("UICorner")
		pCorner.CornerRadius = UDim.new(1, 0)
		pCorner.Parent = p

		local direction = math.random() * math.pi * 2
		local distance = 50 + math.random() * 100

		TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(math.cos(direction) * distance, math.sin(direction) * distance),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(settings.Width * 3, settings.Width * 3)
		}):Play()

		task.delay(0.3, function()
			p:Destroy()
		end)
	end

	-- ================= MAIN LOOP =================
	local hue = 0
	local rotation = 0

	data.connection = RunService.RenderStepped:Connect(function(dt)
		if not data.enabled then return end

		-- FORCE HIDE MOUSE EVERY FRAME (overrides shiftlock cursor)
		if UserInputService.MouseIconEnabled then
			UserInputService.MouseIconEnabled = false
		end
		if mouse.Icon ~= "" then
			mouse.Icon = ""
		end

		local mousePos = UserInputService:GetMouseLocation()
		local baseY = mousePos.Y + settings.YOffset

		center.Position = UDim2.fromOffset(mousePos.X, baseY)

		local crossBottomY

		if settings.Symbol ~= "" then
			vertical.Visible = false
			horizontal.Visible = false
			symbol.Visible = true

			symbol.Text = settings.Symbol
			symbol.TextColor3 = Color3.fromHSV(hue, 1, 1)
			symbol.TextSize = settings.VertLength

			crossBottomY = baseY + (settings.VertLength / 2)
		else
			vertical.Visible = true
			horizontal.Visible = true
			symbol.Visible = false

			vertical.Size = UDim2.fromOffset(settings.Width, settings.VertLength)
			horizontal.Size = UDim2.fromOffset(settings.HorzLength, settings.Width)

			crossBottomY = baseY + (settings.VertLength / 2)
		end

		-- Text under crosshair
		text.Position = UDim2.fromOffset(mousePos.X, crossBottomY + settings.TextGap)
		text.Text = settings.Text
		text.TextColor3 = Color3.fromHSV(hue, 1, 1)

		-- Center lines
		vertical.AnchorPoint = Vector2.new(0.5, 0.5)
		horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
		vertical.Position = UDim2.fromScale(0.5, 0.5)
		horizontal.Position = UDim2.fromScale(0.5, 0.5)

		-- Rotation
		if settings.SpinEnabled then
			rotation = rotation + settings.RotationSpeed * dt
			center.Rotation = rotation % 360
		else
			center.Rotation = 0
		end

		-- Rainbow color
		hue = (hue + settings.RainbowSpeed * dt) % 1
		local color = Color3.fromHSV(hue, 1, 1)

		vertical.BackgroundColor3 = color
		horizontal.BackgroundColor3 = color
		title.TextColor3 = color
		panel.BackgroundColor3 = Color3.fromHSV(hue, 0.7, 0.18)

		-- VFX
		if settings.VFXEnabled and math.random() < 0.3 then
			spawnParticle(color)
		end
	end)

	StarterGui:SetCore("SendNotification", {
		Title = "Crosshair",
		Text = "Enabled! Press [RightShift] for settings",
		Duration = 3
	})

	print("Lunar Crosshair Loaded | CoreGui overlay | Shiftlock cursor override")
end

-- =============================================================
--  sun glare
-- =============================================================
local sunGlareData = {
	enabled = false,
	gui = nil,
	renderConnection = nil,
	blur = nil
}

local function enableSunGlare()
	if sunGlareData.enabled then
		notify("⚠️ Sun glare already enabled", Color3.fromRGB(255, 200, 100))
		return
	end
	
	sunGlareData.enabled = true
	
	if sunGlareData.gui then
		sunGlareData.gui:Destroy()
	end
	if sunGlareData.renderConnection then
		sunGlareData.renderConnection:Disconnect()
	end
	if sunGlareData.blur then
		sunGlareData.blur:Destroy()
	end
	
	local Lighting = game:GetService("Lighting")

	-- 🎥 Blur effect (depth simulation)
	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Parent = Lighting
	sunGlareData.blur = blur
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SunGlare"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.DisplayOrder = 10
	screenGui.Parent = client.PlayerGui
	sunGlareData.gui = screenGui

	local host = Instance.new("Frame")
	host.Size = UDim2.new(1,0,1,0)
	host.BackgroundTransparency = 1
	host.Parent = screenGui

	local ShineOverlay = Instance.new("Frame")
	ShineOverlay.Size = UDim2.new(2,0,2,0)
	ShineOverlay.Position = UDim2.new(-0.5,0,-0.5,0)
	ShineOverlay.BackgroundColor3 = Color3.new(1,1,1)
	ShineOverlay.BackgroundTransparency = 1
	ShineOverlay.ZIndex = 6
	ShineOverlay.Parent = host

	local Haze = Instance.new("Frame")
	Haze.Size = UDim2.new(2,0,2,0)
	Haze.Position = UDim2.new(-0.5,0,-0.5,0)
	Haze.BackgroundColor3 = Color3.new(1,1,1)
	Haze.BackgroundTransparency = 1
	Haze.ZIndex = 5
	Haze.Parent = host

	local flareData = {
		{id="109801097", size=320},
		{id="109801061", size=180},
		{id="109801105", size=160},
		{id="109801051", size=200},
		{id="109801097", size=180},
		{id="109801105", size=90}
	}

	local lFlares = {}

	for i,data in ipairs(flareData) do
		local img = Instance.new("ImageLabel")
		img.Image = "http://www.roblox.com/asset/?id="..data.id
		img.Size = UDim2.new(0,data.size,0,data.size)
		img.BackgroundTransparency = 1
		img.ImageTransparency = 1
		img.ScaleType = Enum.ScaleType.Stretch
		img.Parent = host
		lFlares[img] = i
	end

	local function findFlareCoord(cf, sunPos)
		local v = cf:PointToObjectSpace(sunPos)
		local z = -v.Z
		if z > 0 then
			return v.X/45, -v.Y/45, true
		end
		return 0,0,false
	end

	local function isSunBlocked(origin, dir)
		local ignore = {client.Character}
		for i=1,10 do
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Blacklist
			params.FilterDescendantsInstances = ignore
			
			local r = workspace:Raycast(origin, dir*1000, params)
			if not r then return false end
			
			local h = r.Instance
			if h.Transparency > 0.05 or h.Material == Enum.Material.Glass then
				table.insert(ignore,h)
				origin = r.Position + dir*0.01
			else
				return true
			end
		end
		return false
	end

	local exposure = 0

	sunGlareData.renderConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
		if not sunGlareData.enabled then return end
		
		local cam = workspace.CurrentCamera
		local Lighting = game:GetService("Lighting")
		
		local x,y,z = findFlareCoord(cam.CFrame, cam.CFrame.Position + Lighting:GetSunDirection()*8)
		local blocked = isSunBlocked(cam.CFrame.Position, Lighting:GetSunDirection())
		local minutes = Lighting:GetMinutesAfterMidnight()

		if z and not blocked and minutes > 335 and minutes < 1105 then
			local dot = cam.CFrame.LookVector:Dot(Lighting:GetSunDirection())
			local target = math.clamp((dot - 0.65) * 2.8, 0, 1)
			target = target * target

			exposure = exposure + (target - exposure) * math.clamp(dt * 2, 0, 1)

			for flare,pos in pairs(lFlares) do
				local spread = pos*(1.4 + exposure*1.2)

				flare.Position = UDim2.new(
					0.5 + x*spread,
					-flare.AbsoluteSize.X/2,
					0.5 + y*spread,
					-flare.AbsoluteSize.Y/2
				)

				flare.Visible = true
				flare.ImageColor3 = Color3.new(1,1,1)
				flare.ImageTransparency = 1-(0.6*exposure)
			end

			local centerDist = math.clamp(math.abs(x)+math.abs(y),0,2)
			local hazeStrength = (1-centerDist) * exposure

			Haze.BackgroundTransparency = 1 - (hazeStrength * 0.25)
			ShineOverlay.BackgroundTransparency = 1 - (exposure * 0.18)

			-- 🎥 DEPTH-BASED BLUR (cinematic)
			local blurTarget = exposure * 18
			blur.Size = blur.Size + (blurTarget - blur.Size) * math.clamp(dt * 3, 0, 1)

		else
			exposure = exposure + (0 - exposure) * math.clamp(dt * 2, 0, 1)

			for flare in pairs(lFlares) do
				flare.Visible = false
			end

			Haze.BackgroundTransparency = 1
			ShineOverlay.BackgroundTransparency = 1

			blur.Size = blur.Size + (0 - blur.Size) * math.clamp(dt * 3, 0, 1)
		end
	end)

	notify("Sun glare enabled", Color3.fromRGB(255,220,100))
end

local function disableSunGlare()
	if not sunGlareData.enabled then
		notify("⚠️ Sun glare not enabled", Color3.fromRGB(255,200,100))
		return
	end
	
	sunGlareData.enabled = false
	
	if sunGlareData.renderConnection then
		sunGlareData.renderConnection:Disconnect()
	end
	
	if sunGlareData.gui then
		sunGlareData.gui:Destroy()
	end

	if sunGlareData.blur then
		sunGlareData.blur:Destroy()
	end
	
	notify("Sun glare disabled", Color3.fromRGB(255,100,100))
end
-- =============================================================
--  speed system
-- =============================================================
local speedPanelData = {
	panel = nil,
	enabled = false,
	bypassEnabled = false,
	speedValue = 100,
	mainConnection = nil,
	directionConnection = nil,
	charConnection = nil
}

local function createSpeedPanel()
	if speedPanelData.panel then
		speedPanelData.panel:Destroy()
		speedPanelData.panel = nil
		if speedPanelData.mainConnection then speedPanelData.mainConnection:Disconnect() speedPanelData.mainConnection = nil end
		if speedPanelData.directionConnection then speedPanelData.directionConnection:Disconnect() speedPanelData.directionConnection = nil end
		return
	end

	local panel = Instance.new("ScreenGui")
	panel.Name = "SpeedPanel"
	panel.ResetOnSpawn = false
	panel.DisplayOrder = 999999
	panel.IgnoreGuiInset = true
	panel.ZIndexBehavior = Enum.ZIndexBehavior.Global
	panel.Parent = client.PlayerGui

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 350, 0, 290)
	main.Position = UDim2.new(0.5, -175, 0.5, -145)
	main.BackgroundColor3 = currentTheme.glass
	main.Active = true
	main.Draggable = true
	main.Parent = panel
	applyGlassEffect(main, globalConfig.uiTransparency, 0.4)

	local title = Instance.new("TextLabel", main)
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "SPEED CONTROL"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 26
	title.TextColor3 = currentTheme.accent
	title.TextTransparency = 0
	title.TextStrokeTransparency = 0.5
	title.TextStrokeColor3 = Color3.new(0,0,0)

	local speedDisplay = Instance.new("TextLabel", main)
	speedDisplay.Size = UDim2.new(1, 0, 0, 40)
	speedDisplay.Position = UDim2.new(0, 0, 0, 50)
	speedDisplay.BackgroundTransparency = 1
	speedDisplay.Text = "Speed: " .. speedPanelData.speedValue
	speedDisplay.Font = Enum.Font.GothamBold
	speedDisplay.TextSize = 24
	speedDisplay.TextColor3 = globalConfig.textColor
	speedDisplay.TextTransparency = 0
	speedDisplay.TextStrokeTransparency = 0.5
	speedDisplay.TextStrokeColor3 = Color3.new(0,0,0)

	-- TextBox (clean input)
	local speedBox = Instance.new("TextBox", main)
	speedBox.Size = UDim2.new(0.8, 0, 0, 50)
	speedBox.Position = UDim2.new(0.1, 0, 0, 100)
	speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	speedBox.Text = tostring(speedPanelData.speedValue)
	speedBox.Font = Enum.Font.GothamBold
	speedBox.TextSize = 28
	speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedBox.PlaceholderText = "Enter speed (1-10000)"
	speedBox.ClearTextOnFocus = false
	applyGlassEffect(speedBox, 0.3, 0.6)
	Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

	local toggle1Btn = Instance.new("TextButton", main)
	toggle1Btn.Size = UDim2.new(0.9, 0, 0, 45)
	toggle1Btn.Position = UDim2.new(0.05, 0, 0, 165)
	toggle1Btn.BackgroundColor3 = speedPanelData.enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
	toggle1Btn.Text = "Walkspeed: " .. (speedPanelData.enabled and "ON" or "OFF")
	toggle1Btn.Font = Enum.Font.GothamBold
	toggle1Btn.TextSize = 18
	toggle1Btn.TextColor3 = Color3.new(0,0,0)
	applyGlassEffect(toggle1Btn, 0.2, 0.5)

	local toggle2Btn = Instance.new("TextButton", main)
	toggle2Btn.Size = UDim2.new(0.9, 0, 0, 45)
	toggle2Btn.Position = UDim2.new(0.05, 0, 0, 220)
	toggle2Btn.BackgroundColor3 = speedPanelData.bypassEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
	toggle2Btn.Text = "Loop + No Slide: " .. (speedPanelData.bypassEnabled and "ON" or "OFF")
	toggle2Btn.Font = Enum.Font.GothamBold
	toggle2Btn.TextSize = 18
	toggle2Btn.TextColor3 = Color3.new(0,0,0)
	applyGlassEffect(toggle2Btn, 0.2, 0.5)

	local closeBtn = Instance.new("TextButton", main)
	closeBtn.Size = UDim2.new(0, 35, 0, 35)
	closeBtn.Position = UDim2.new(1, -45, 0, 8)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBlack
	closeBtn.TextSize = 20
	closeBtn.TextColor3 = Color3.new(1,1,1)
	applyGlassEffect(closeBtn, 0.2, 0.4)

	local function applySpeed()
		if not speedPanelData.enabled or not hum then return end
		if hum then
			hum.WalkSpeed = speedPanelData.speedValue
		end
	end

	-- TextBox logic
	speedBox.FocusLost:Connect(function()
		local num = tonumber(speedBox.Text)
		if num then
			speedPanelData.speedValue = math.clamp(math.floor(num), 1, 10000)
			speedDisplay.Text = "Speed: " .. speedPanelData.speedValue
			speedBox.Text = tostring(speedPanelData.speedValue)
			applySpeed()
		else
			speedBox.Text = tostring(speedPanelData.speedValue)
		end
	end)

	-- Simple Walkspeed Toggle (like 'speed' command)
	toggle1Btn.MouseButton1Click:Connect(function()
		speedPanelData.enabled = not speedPanelData.enabled
		toggle1Btn.Text = "Walkspeed: " .. (speedPanelData.enabled and "ON" or "OFF")
		toggle1Btn.BackgroundColor3 = speedPanelData.enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)

		if speedPanelData.enabled then
			applySpeed()
		elseif hum then
			hum.WalkSpeed = 16
		end
	end)

	-- Loop + No Slide (like 'loopspeed' + your anti-slide request)
	toggle2Btn.MouseButton1Click:Connect(function()
		speedPanelData.bypassEnabled = not speedPanelData.bypassEnabled
		toggle2Btn.Text = "Loop + No Slide: " .. (speedPanelData.bypassEnabled and "ON" or "OFF")
		toggle2Btn.BackgroundColor3 = speedPanelData.bypassEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)

		if speedPanelData.bypassEnabled then
			-- Main loop (like loopspeed)
			if speedPanelData.mainConnection then speedPanelData.mainConnection:Disconnect() end
			speedPanelData.mainConnection = RunService.Heartbeat:Connect(applySpeed)

			-- Instant direction change (no sliding when turning)
			if speedPanelData.directionConnection then speedPanelData.directionConnection:Disconnect() end
			local lastDir = Vector3.new()
			speedPanelData.directionConnection = RunService.Heartbeat:Connect(function()
				if not hum or not speedPanelData.enabled then return end

				local moveDir = hum.MoveDirection
				if moveDir.Magnitude > 0.1 then
					if lastDir:Dot(moveDir) < 0.65 then -- Sharp direction change
						local root = hum.RootPart
						if root then
							local vel = root.AssemblyLinearVelocity
							root.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0) -- Clear sideways momentum
						end
					end
					lastDir = moveDir
				end
			end)
		else
			if speedPanelData.mainConnection then
				speedPanelData.mainConnection:Disconnect()
				speedPanelData.mainConnection = nil
			end
			if speedPanelData.directionConnection then
				speedPanelData.directionConnection:Disconnect()
				speedPanelData.directionConnection = nil
			end
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		panel:Destroy()
		speedPanelData.panel = nil
		if speedPanelData.mainConnection then speedPanelData.mainConnection:Disconnect() speedPanelData.mainConnection = nil end
		if speedPanelData.directionConnection then speedPanelData.directionConnection:Disconnect() speedPanelData.directionConnection = nil end
	end)

	speedPanelData.panel = panel

	-- Persist after death (like loopspeed CharacterAdded)
	if speedPanelData.charConnection then speedPanelData.charConnection:Disconnect() end
	speedPanelData.charConnection = client.CharacterAdded:Connect(function(newChar)
		task.wait(0.4)
		char = newChar
		hum = newChar:WaitForChild("Humanoid", 5)
		if speedPanelData.enabled and hum then
			hum.WalkSpeed = speedPanelData.speedValue
		end
	end)
end
-- =============================================================
-- FLY SYSTEM
-- =============================================================
local FlySystem = {
	enabled = false,
	uiSpeed = 1,
	actualSpeed = 50,
	speedMultiplier = 50,
	gui = nil,
	mainFrame = nil,
	flyBtn = nil,
	speedBox = nil,
	bodyGyro = nil,
	bodyVelocity = nil,
	connection = nil,
	currentVelocity = Vector3.new(0, 0, 0),
	lerpFactor = 0.25
}

function FlySystem:CreatePanel()
	if self.gui then return end

	local playerGui = client:WaitForChild("PlayerGui")

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "FlySystemPanel"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.DisplayOrder = 999999
	ScreenGui.Parent = playerGui
	self.gui = ScreenGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "Main"
	MainFrame.Size = UDim2.new(0, 320, 0, 220)
	MainFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	MainFrame.BorderSizePixel = 0
	MainFrame.Active = true
	MainFrame.Draggable = true
	MainFrame.Parent = ScreenGui
	self.mainFrame = MainFrame

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 12)
	Corner.Parent = MainFrame

	local Gradient = Instance.new("UIGradient")
	Gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 55)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
	}
	Gradient.Rotation = 90
	Gradient.Parent = MainFrame

	-- Top Bar
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 45)
	TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame

	local TopCorner = Instance.new("UICorner")
	TopCorner.CornerRadius = UDim.new(0, 12)
	TopCorner.Parent = TopBar

	-- Title
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(0.6, 0, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "FLY SYSTEM"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 20
	Title.TextColor3 = Color3.fromRGB(100, 200, 255)
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar

	-- Minimize Button
	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.new(0, 32, 0, 32)
	MinBtn.Position = UDim2.new(1, -75, 0.5, -16)
	MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	MinBtn.Text = "−"
	MinBtn.Font = Enum.Font.GothamBold
	MinBtn.TextSize = 24
	MinBtn.TextColor3 = Color3.new(1, 1, 1)
	MinBtn.Parent = TopBar

	local MinCorner = Instance.new("UICorner")
	MinCorner.CornerRadius = UDim.new(0, 8)
	MinCorner.Parent = MinBtn

	-- Close Button
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 32, 0, 32)
	CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
	CloseBtn.Text = "×"
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 22
	CloseBtn.TextColor3 = Color3.new(1, 1, 1)
	CloseBtn.Parent = TopBar

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 8)
	CloseCorner.Parent = CloseBtn

	-- Speed Label
	local SpeedLabel = Instance.new("TextLabel")
	SpeedLabel.Size = UDim2.new(1, 0, 0, 25)
	SpeedLabel.Position = UDim2.new(0, 0, 0, 55)
	SpeedLabel.BackgroundTransparency = 1
	SpeedLabel.Text = "SPEED (1-10000)"
	SpeedLabel.Font = Enum.Font.GothamSemibold
	SpeedLabel.TextSize = 14
	SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
	SpeedLabel.Parent = MainFrame

	-- Speed Input Box
	local SpeedInput = Instance.new("TextBox")
	SpeedInput.Size = UDim2.new(0, 180, 0, 45)
	SpeedInput.Position = UDim2.new(0.5, -90, 0, 85)
	SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	SpeedInput.Text = tostring(self.uiSpeed)
	SpeedInput.Font = Enum.Font.GothamBold
	SpeedInput.TextSize = 22
	SpeedInput.TextColor3 = Color3.fromRGB(100, 255, 150)
	SpeedInput.ClearTextOnFocus = false
	SpeedInput.Parent = MainFrame

	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 10)
	InputCorner.Parent = SpeedInput

	self.speedBox = SpeedInput

	-- Stats Label
	local StatsLabel = Instance.new("TextLabel")
	StatsLabel.Size = UDim2.new(1, 0, 0, 20)
	StatsLabel.Position = UDim2.new(0, 0, 0, 135)
	StatsLabel.BackgroundTransparency = 1
	StatsLabel.Text = "Actual: 50 studs/sec"
	StatsLabel.Font = Enum.Font.Gotham
	StatsLabel.TextSize = 12
	StatsLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
	StatsLabel.Parent = MainFrame

	-- Fly Toggle Button
	local FlyBtn = Instance.new("TextButton")
	FlyBtn.Size = UDim2.new(0, 200, 0, 50)
	FlyBtn.Position = UDim2.new(0.5, -100, 0, 160)
	FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
	FlyBtn.Text = "▶ START FLY"
	FlyBtn.Font = Enum.Font.GothamBlack
	FlyBtn.TextSize = 20
	FlyBtn.TextColor3 = Color3.new(1, 1, 1)
	FlyBtn.Parent = MainFrame

	local FlyCorner = Instance.new("UICorner")
	FlyCorner.CornerRadius = UDim.new(0, 12)
	FlyCorner.Parent = FlyBtn

	self.flyBtn = FlyBtn

	-- Controls Help
	local HelpLabel = Instance.new("TextLabel")
	HelpLabel.Size = UDim2.new(1, 0, 0, 20)
	HelpLabel.Position = UDim2.new(0, 0, 1, -25)
	HelpLabel.BackgroundTransparency = 1
	HelpLabel.Text = "WASD | Space ↑ | Shift ↓"
	HelpLabel.Font = Enum.Font.Gotham
	HelpLabel.TextSize = 11
	HelpLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
	HelpLabel.Parent = MainFrame

	-- Speed Input Handler
	SpeedInput.FocusLost:Connect(function()
		local newVal = tonumber(SpeedInput.Text)
		if newVal then
			newVal = math.clamp(math.floor(newVal), 1, 10000)
			self.uiSpeed = newVal
			self.actualSpeed = newVal * self.speedMultiplier
			SpeedInput.Text = tostring(newVal)
			StatsLabel.Text = "Actual: " .. self.actualSpeed .. " studs/sec"
			if self.enabled then
				notify("Fly speed: " .. newVal, Color3.fromRGB(100, 255, 100))
			end
		else
			SpeedInput.Text = tostring(self.uiSpeed)
		end
	end)

	-- Fly Button Handler
	FlyBtn.MouseButton1Click:Connect(function()
		self:ToggleFly()
	end)

	-- Minimize Handler
	local minimized = false
	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		if minimized then
			TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 320, 0, 45)}):Play()
			MinBtn.Text = "+"
			for _, obj in pairs(MainFrame:GetDescendants()) do
				if obj:IsA("GuiObject") and obj ~= TopBar and obj ~= MinBtn and obj ~= CloseBtn and obj.Parent ~= TopBar then
					obj.Visible = false
				end
			end
		else
			TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 320, 0, 220)}):Play()
			MinBtn.Text = "−"
			for _, obj in pairs(MainFrame:GetDescendants()) do
				if obj:IsA("GuiObject") then
					obj.Visible = true
				end
			end
		end
	end)

	-- Close Handler - just hides panel, doesn't stop fly
	CloseBtn.MouseButton1Click:Connect(function()
		ScreenGui.Enabled = false
	end)
end

function FlySystem:StartFly()
	local char = client.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	hum.PlatformStand = true
	hum.AutoRotate = false

	self.bodyGyro = Instance.new("BodyGyro")
	self.bodyGyro.P = 90000
	self.bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	self.bodyGyro.CFrame = hrp.CFrame
	self.bodyGyro.Parent = hrp

	self.bodyVelocity = Instance.new("BodyVelocity")
	self.bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	self.bodyVelocity.Parent = hrp

	self.enabled = true
	self.currentVelocity = Vector3.new(0, 0, 0)

	if self.flyBtn then
		self.flyBtn.Text = "STOP FLY"
		self.flyBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
	end

	self.connection = RunService.RenderStepped:Connect(function()
		if not self.enabled then return end
		if not client.Character or not client.Character:FindFirstChild("HumanoidRootPart") then
			self:StopFly()
			return
		end

		local currentHrp = client.Character.HumanoidRootPart
		local cam = workspace.CurrentCamera

		if UserInputService:GetFocusedTextBox() then
			self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
			return
		end

		self.bodyGyro.CFrame = cam.CFrame

		local moveDir = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

		local targetVel = Vector3.new(0, 0, 0)
		if moveDir.Magnitude > 0 then
			targetVel = moveDir.Unit * self.actualSpeed
		end

		self.currentVelocity = self.currentVelocity:Lerp(targetVel, self.lerpFactor)
		self.bodyVelocity.Velocity = self.currentVelocity
	end)

	notify("Flying at speed " .. self.uiSpeed .. "!", Color3.fromRGB(0, 255, 150))
end

function FlySystem:StopFly()
	if not self.enabled then return end
	self.enabled = false

	if self.connection then self.connection:Disconnect() self.connection = nil end
	if self.bodyGyro then self.bodyGyro:Destroy() self.bodyGyro = nil end
	if self.bodyVelocity then self.bodyVelocity:Destroy() self.bodyVelocity = nil end

	local char = client.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false hum.AutoRotate = true end

	self.currentVelocity = Vector3.new(0, 0, 0)

	if self.flyBtn then
		self.flyBtn.Text = "▶ START FLY"
		self.flyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
	end

	notify("Fly stopped", Color3.fromRGB(255, 160, 60))
end

function FlySystem:ToggleFly()
	if self.enabled then self:StopFly() else self:StartFly() end
	return self.enabled
end

-- Death handler
client.CharacterAdded:Connect(function()
	task.wait(0.1)
	if FlySystem.enabled then
		FlySystem:StopFly()
		if FlySystem.gui and FlySystem.flyBtn then
			FlySystem.flyBtn.Text = "▶ START FLY"
			FlySystem.flyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
		end
	end
end)

local function fly(plr, spd)
	if plr ~= client then
		notify("Fly only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end

	-- Create panel if not exists
	FlySystem:CreatePanel()

	-- Update speed if provided
	if spd then
		local newSpeed = tonumber(spd)
		if newSpeed then
			FlySystem.uiSpeed = math.clamp(math.floor(newSpeed), 1, 10000)
			FlySystem.actualSpeed = FlySystem.uiSpeed * FlySystem.speedMultiplier
			if FlySystem.speedBox then
				FlySystem.speedBox.Text = tostring(FlySystem.uiSpeed)
			end
		end
	end

	-- Start flying immediately
	FlySystem:StartFly()

	-- Update button state
	if FlySystem.flyBtn then
		FlySystem.flyBtn.Text = "STOP FLY"
		FlySystem.flyBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
	end
end

local function unfly(plr)
	if plr ~= client then
		notify("Unfly only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end

	FlySystem:StopFly()

	-- Update button state
	if FlySystem.flyBtn then
		FlySystem.flyBtn.Text = "▶ START FLY"
		FlySystem.flyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
	end
end
-- =============================================================
-- VIEW SYSTEM
-- =============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local viewData = {
	enabled = false,
	target = nil,
	originalCameraSubject = nil,
	originalCameraType = nil,
	originalWalkSpeed = 16,
	originalJumpPower = 50,
	originalPlatformStand = false,
	viewGui = nil,
}

local function freezeLocalCharacter(freeze)
	local char = LocalPlayer.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if freeze then
		viewData.originalWalkSpeed     = hum.WalkSpeed
		viewData.originalJumpPower     = hum.JumpPower
		viewData.originalPlatformStand = hum.PlatformStand

		hum.WalkSpeed     = 0
		hum.JumpPower     = 0
		hum.PlatformStand = true  -- Prevents falling/sliding while frozen
	else
		hum.WalkSpeed     = viewData.originalWalkSpeed
		hum.JumpPower     = viewData.originalJumpPower
		hum.PlatformStand = viewData.originalPlatformStand


		task.delay(0.03, function()
			if hum and hum.Parent then
				hum:ChangeState(Enum.HumanoidStateType.Running)

			end
		end)
	end
end

local function view(targetPlayer)
	if viewData.enabled then
		notify("⚠️ Already viewing someone! Use !unview first", Color3.fromRGB(255, 100, 100))
		return
	end

	if not targetPlayer or not targetPlayer.Character then
		notify("❌ Player not found or has no character", Color3.fromRGB(255, 100, 100))
		return
	end

	local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not targetHum or targetHum.Health <= 0 then
		notify("❌ Target is dead or has no Humanoid", Color3.fromRGB(255, 100, 100))
		return
	end

	-- Store originals
	viewData.enabled          = true
	viewData.target           = targetPlayer
	viewData.originalCameraSubject = Camera.CameraSubject
	viewData.originalCameraType    = Camera.CameraType

	-- Freeze your own character
	freezeLocalCharacter(true)

	Camera.CameraSubject = targetHum
	Camera.CameraType    = Enum.CameraType.Custom   

	-- Top label
	local viewGui = Instance.new("ScreenGui")
	viewGui.Name = "SpectateGui"
	viewGui.ResetOnSpawn = false
	viewGui.DisplayOrder = 999999
	viewGui.Parent = client.PlayerGui 

	local label = Instance.new("TextLabel")
	label.Size           = UDim2.new(0, 360, 0, 40)
	label.Position       = UDim2.new(0.5, -180, 0, 10)
	label.BackgroundTransparency = globalConfig.uiTransparency or 0.45
	label.BackgroundColor3 = currentTheme.glass or Color3.fromRGB(20, 20, 40)
	label.Text           = "👁️  Spectating: " .. targetPlayer.Name .. "  (@" .. targetPlayer.DisplayName .. ")  — Use mouse to look around"
	label.Font           = Enum.Font.GothamBold
	label.TextSize       = 18
	label.TextColor3     = globalConfig.textColor or Color3.fromRGB(230, 230, 255)
	label.TextStrokeTransparency = 0.7
	label.TextStrokeColor3 = Color3.new(0,0,0)
	label.BorderSizePixel = 0
	label.Parent = viewGui

	if applyGlassEffect then
		applyGlassEffect(label, globalConfig.uiTransparency or 0.45, 0.35)
	end

	viewData.viewGui = viewGui

	notify("👁️ Now viewing " .. targetPlayer.Name .. " — full free look like you're them", Color3.fromRGB(100, 255, 100))
end

local function unview()
	if not viewData.enabled then
		notify("⚠️ Not viewing anyone", Color3.fromRGB(255, 100, 100))
		return
	end

	viewData.enabled = false

	-- Restore camera **before** unfreezing (prevents glitches)
	Camera.CameraSubject = viewData.originalCameraSubject or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
	Camera.CameraType    = viewData.originalCameraType or Enum.CameraType.Custom

	-- Unfreeze
	freezeLocalCharacter(false)

	-- Clean up GUI
	if viewData.viewGui then
		viewData.viewGui:Destroy()
		viewData.viewGui = nil
	end

	viewData.target = nil
	viewData.originalCameraSubject = nil
	viewData.originalCameraType = nil

	notify("Stopped spectating — back to normal", Color3.fromRGB(255, 160, 60))
end

-- Auto-stop if target disappears/dies/leaves
Players.PlayerRemoving:Connect(function(plr)
	if viewData.target == plr and viewData.enabled then
		unview()
	end
end)

LocalPlayer.CharacterRemoving:Connect(function()
	if viewData.enabled then
		unview()
	end
end)

print("Spectate system ready: full free camera control like playing as them + glitch fix")

-- =============================================================
-- JOIN LOGS PANEL
-- =============================================================
local joinLogsData = {
	panel = nil,
	entries = {},
	connections = {}
}

local function createJoinLogsPanel()
	if joinLogsData.panel then
		joinLogsData.panel:Destroy()
		joinLogsData.panel = nil
		for _, conn in ipairs(joinLogsData.connections) do
			conn:Disconnect()
		end
		joinLogsData.connections = {}
		return
	end

	local panel = Instance.new("ScreenGui")
	panel.Name = "JoinLogsPanel"
	panel.ResetOnSpawn = false
	panel.DisplayOrder = 999999
	panel.Parent = client.PlayerGui

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 500, 0, 400)
	main.Position = UDim2.new(0.5, -250, 0.5, -200)
	main.BackgroundColor3 = currentTheme.glass
	main.Active = true
	main.Draggable = true
	main.Parent = panel
	applyGlassEffect(main, globalConfig.uiTransparency, 0.4)

	local title = Instance.new("TextLabel", main)
	title.Size = UDim2.new(1, -50, 0, 45)
	title.Position = UDim2.new(0, 15, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "JOIN/LEAVE LOGS"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 22
	title.TextColor3 = currentTheme.accent
	title.TextTransparency = 0 -- SOLID
	title.TextStrokeTransparency = 0.5
	title.TextStrokeColor3 = Color3.new(0,0,0)
	title.TextXAlignment = Enum.TextXAlignment.Left

	local closeBtn = Instance.new("TextButton", main)
	closeBtn.Size = UDim2.new(0, 35, 0, 35)
	closeBtn.Position = UDim2.new(1, -45, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBlack
	closeBtn.TextSize = 20
	closeBtn.TextColor3 = Color3.new(1,1,1)
	closeBtn.TextTransparency = 0 -- SOLID
	applyGlassEffect(closeBtn, 0.2, 0.4)

	local headers = Instance.new("Frame", main)
	headers.Size = UDim2.new(1, -20, 0, 30)
	headers.Position = UDim2.new(0, 10, 0, 55)
	headers.BackgroundColor3 = currentTheme.btn
	applyGlassEffect(headers, 0.3, 0.6)

	local timeHeader = Instance.new("TextLabel", headers)
	timeHeader.Size = UDim2.new(0.2, 0, 1, 0)
	timeHeader.BackgroundTransparency = 1
	timeHeader.Text = "Time"
	timeHeader.Font = Enum.Font.GothamBold
	timeHeader.TextSize = 14
	timeHeader.TextColor3 = globalConfig.textColor
	timeHeader.TextTransparency = 0 -- SOLID
	timeHeader.TextStrokeTransparency = 0.5
	timeHeader.TextStrokeColor3 = Color3.new(0,0,0)

	local userHeader = Instance.new("TextLabel", headers)
	userHeader.Size = UDim2.new(0.4, 0, 1, 0)
	userHeader.Position = UDim2.new(0.2, 0, 0, 0)
	userHeader.BackgroundTransparency = 1
	userHeader.Text = "Username"
	userHeader.Font = Enum.Font.GothamBold
	userHeader.TextSize = 14
	userHeader.TextColor3 = globalConfig.textColor
	userHeader.TextTransparency = 0 -- SOLID
	userHeader.TextStrokeTransparency = 0.5
	userHeader.TextStrokeColor3 = Color3.new(0,0,0)

	local distHeader = Instance.new("TextLabel", headers)
	distHeader.Size = UDim2.new(0.2, 0, 1, 0)
	distHeader.Position = UDim2.new(0.6, 0, 0, 0)
	distHeader.BackgroundTransparency = 1
	distHeader.Text = "Distance"
	distHeader.Font = Enum.Font.GothamBold
	distHeader.TextSize = 14
	distHeader.TextColor3 = globalConfig.textColor
	distHeader.TextTransparency = 0 -- SOLID
	distHeader.TextStrokeTransparency = 0.5
	distHeader.TextStrokeColor3 = Color3.new(0,0,0)

	local actionHeader = Instance.new("TextLabel", headers)
	actionHeader.Size = UDim2.new(0.2, 0, 1, 0)
	actionHeader.Position = UDim2.new(0.8, 0, 0, 0)
	actionHeader.BackgroundTransparency = 1
	actionHeader.Text = "Action"
	actionHeader.Font = Enum.Font.GothamBold
	actionHeader.TextSize = 14
	actionHeader.TextColor3 = globalConfig.textColor
	actionHeader.TextTransparency = 0 -- SOLID
	actionHeader.TextStrokeTransparency = 0.5
	actionHeader.TextStrokeColor3 = Color3.new(0,0,0)

	local scroll = Instance.new("ScrollingFrame", main)
	scroll.Size = UDim2.new(1, -20, 1, -100)
	scroll.Position = UDim2.new(0, 10, 0, 90)
	scroll.BackgroundTransparency = 0.4
	scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	scroll.ScrollBarThickness = 8
	scroll.ScrollBarImageColor3 = currentTheme.accent
	applyGlassEffect(scroll, 0.5, 0.7)

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 5)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local function addLogEntry(plr, action)
		local entry = Instance.new("Frame")
		entry.Size = UDim2.new(1, -10, 0, 35)
		entry.BackgroundColor3 = action == "JOINED" and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
		entry.BackgroundTransparency = 0.8
		entry.BorderSizePixel = 0

		local timeLabel = Instance.new("TextLabel", entry)
		timeLabel.Size = UDim2.new(0.2, 0, 1, 0)
		timeLabel.BackgroundTransparency = 1
		timeLabel.Text = os.date("%H:%M:%S")
		timeLabel.Font = Enum.Font.Gotham
		timeLabel.TextSize = 12
		timeLabel.TextColor3 = globalConfig.textColor
		timeLabel.TextTransparency = 0 -- SOLID
		timeLabel.TextStrokeTransparency = 0.5
		timeLabel.TextStrokeColor3 = Color3.new(0,0,0)

		local userLabel = Instance.new("TextLabel", entry)
		userLabel.Size = UDim2.new(0.4, 0, 1, 0)
		userLabel.Position = UDim2.new(0.2, 0, 0, 0)
		userLabel.BackgroundTransparency = 1
		userLabel.Text = plr.Name
		userLabel.Font = Enum.Font.GothamBold
		userLabel.TextSize = 14
		userLabel.TextColor3 = globalConfig.textColor
		userLabel.TextTransparency = 0 -- SOLID
		userLabel.TextStrokeTransparency = 0.5
		userLabel.TextStrokeColor3 = Color3.new(0,0,0)

		local dist = "N/A"
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and hrp then
			dist = math.floor((plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) .. " studs"
		end

		local distLabel = Instance.new("TextLabel", entry)
		distLabel.Size = UDim2.new(0.2, 0, 1, 0)
		distLabel.Position = UDim2.new(0.6, 0, 0, 0)
		distLabel.BackgroundTransparency = 1
		distLabel.Text = dist
		distLabel.Font = Enum.Font.Gotham
		distLabel.TextSize = 12
		distLabel.TextColor3 = globalConfig.textColor
		distLabel.TextTransparency = 0 -- SOLID
		distLabel.TextStrokeTransparency = 0.5
		distLabel.TextStrokeColor3 = Color3.new(0,0,0)

		local actionLabel = Instance.new("TextLabel", entry)
		actionLabel.Size = UDim2.new(0.2, 0, 1, 0)
		actionLabel.Position = UDim2.new(0.8, 0, 0, 0)
		actionLabel.BackgroundTransparency = 1
		actionLabel.Text = action
		actionLabel.Font = Enum.Font.GothamBold
		actionLabel.TextSize = 14
		actionLabel.TextColor3 = action == "JOINED" and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
		actionLabel.TextTransparency = 0 -- SOLID
		actionLabel.TextStrokeTransparency = 0.5
		actionLabel.TextStrokeColor3 = Color3.new(0,0,0)

		entry.Parent = scroll
		table.insert(joinLogsData.entries, entry)

		if #joinLogsData.entries > 50 then
			joinLogsData.entries[1]:Destroy()
			table.remove(joinLogsData.entries, 1)
		end

		scroll.CanvasSize = UDim2.new(0, 0, 0, #joinLogsData.entries * 40)
		scroll.CanvasPosition = Vector2.new(0, #joinLogsData.entries * 40)
	end

	local joinConn = Players.PlayerAdded:Connect(function(plr)
		addLogEntry(plr, "JOINED")
	end)

	local leaveConn = Players.PlayerRemoving:Connect(function(plr)
		addLogEntry(plr, "LEFT")
	end)

	table.insert(joinLogsData.connections, joinConn)
	table.insert(joinLogsData.connections, leaveConn)

	closeBtn.MouseButton1Click:Connect(function()
		panel:Destroy()
		joinLogsData.panel = nil
		for _, conn in ipairs(joinLogsData.connections) do
			conn:Disconnect()
		end
		joinLogsData.connections = {}
	end)

	joinLogsData.panel = panel
	notify("Join logs panel opened", Color3.fromRGB(100, 255, 100))
end

-- =============================================================
-- ENHANCED ESP 
-- =============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local client = Players.LocalPlayer

-- ============================================
-- ESP DATA - PERSISTENT TRACKING
-- ============================================
local espData = {
	enabled = false,
	playerESP = {},
	globalConnections = {},
	distanceConn = nil,
	myCharConn = nil,
	globalEnabled = false,
	-- NEW: Track players by UserId so ESP persists through rejoins
	trackedUserIds = {},
	-- NEW: Track individual player ESP targets (for !esp playername)
	individualTargets = {}
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function getMyHRP()
	local char = client.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

local function clearPlayerESP(plr)
	local data = espData.playerESP[plr]
	if not data then return end

	for _, conn in ipairs(data.connections or {}) do
		if conn then conn:Disconnect() end
	end
	data.connections = {}

	for _, obj in ipairs(data.objects or {}) do
		if obj and obj.Parent then
			pcall(function() obj:Destroy() end)
		end
	end
	data.objects = {}
	data.distLabel = nil

	espData.playerESP[plr] = nil
end

local function clearAllESP()
	for plr, _ in pairs(espData.playerESP) do
		clearPlayerESP(plr)
	end
	espData.playerESP = {}
end

-- ============================================
-- CORE ESP ATTACHMENT
-- ============================================
local function attachESP(plr, char)
	if plr == client then return end
	if not char then return end

	-- Always clear old first to prevent duplicates
	clearPlayerESP(plr)

	local data = {
		connections = {},
		objects = {},
		distLabel = nil,
		lastChar = char
	}

	espData.playerESP[plr] = data

	-- Wait for parts with timeout
	local head = char:WaitForChild("Head", 5)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	if not head or not hrp then 
		-- Retry once after short delay
		task.delay(1, function()
			if plr.Character and plr.Character ~= char then
				attachESP(plr, plr.Character)
			end
		end)
		return 
	end

	local teamColor = plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255, 80, 80)

	-- HIGHLIGHT (Chams)
	local highlight = Instance.new("Highlight")
	highlight.Name = "LunarESP_" .. plr.Name
	highlight.Adornee = char
	highlight.FillTransparency = 0.85
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillColor = teamColor
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = workspace
	table.insert(data.objects, highlight)

	-- BILLBOARD GUI
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LunarESP_Billboard_" .. plr.Name
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.8, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 10000
	billboard.Parent = client.PlayerGui

	-- Name Label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.Text = plr.DisplayName ~= plr.Name and "@" .. plr.Name .. " (" .. plr.DisplayName .. ")" or "@" .. plr.Name
	nameLabel.TextColor3 = teamColor
	nameLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	nameLabel.Parent = billboard

	-- Distance Label
	local distLabel = Instance.new("TextLabel")
	distLabel.Name = "Distance"
	distLabel.BackgroundTransparency = 1
	distLabel.Position = UDim2.new(0, 0, 0.55, 0)
	distLabel.Size = UDim2.new(1, 0, 0.45, 0)
	distLabel.Font = Enum.Font.Gotham
	distLabel.TextSize = 12
	distLabel.TextStrokeTransparency = 0.4
	distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	distLabel.Text = "0 studs"
	distLabel.TextYAlignment = Enum.TextYAlignment.Top
	distLabel.Parent = billboard

	table.insert(data.objects, billboard)
	data.distLabel = distLabel

	-- Health tracking
	if humanoid then
		local healthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			local healthPercent = humanoid.Health / humanoid.MaxHealth
			if healthPercent <= 0 then
				for _, obj in ipairs(data.objects) do
					if obj:IsA("Highlight") then
						obj.FillTransparency = 1
						obj.OutlineTransparency = 0.8
					end
				end
				if nameLabel then
					nameLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
				end
			else
				for _, obj in ipairs(data.objects) do
					if obj:IsA("Highlight") then
						obj.FillTransparency = 0.85
						obj.OutlineTransparency = 0
					end
				end
				if nameLabel then
					nameLabel.TextColor3 = teamColor
				end
			end
		end)
		table.insert(data.connections, healthConn)

		-- Death handler - IMMEDIATELY reattach on respawn (NO DELAY)
		local diedConn = humanoid.Died:Connect(function()
			-- Clear current ESP immediately
			clearPlayerESP(plr)

			-- Wait for new character and reattach if ESP is still enabled for this player
			local newCharConn
			newCharConn = plr.CharacterAdded:Connect(function(newChar)
				if newCharConn then
					newCharConn:Disconnect()
				end
				-- Check if this player should still have ESP (global or individual)
				local shouldTrack = espData.globalEnabled or espData.trackedUserIds[plr.UserId] or espData.individualTargets[plr.UserId]
				if shouldTrack then
					task.wait(0.3)
					attachESP(plr, newChar)
				end
			end)
		end)
		table.insert(data.connections, diedConn)
	end

	-- Team change handler
	local teamConn = plr:GetPropertyChangedSignal("Team"):Connect(function()
		local newColor = plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255, 80, 80)
		for _, obj in ipairs(data.objects) do
			if obj:IsA("Highlight") then
				obj.FillColor = newColor
			end
		end
		if nameLabel then
			nameLabel.TextColor3 = newColor
		end
	end)
	table.insert(data.connections, teamConn)

	-- Character removing handler (for when they reset without dying)
	local charRemovingConn = char.AncestryChanged:Connect(function()
		if not char.Parent then
			-- Character was destroyed, clear ESP
			task.delay(0.1, function()
				if not plr.Character or plr.Character ~= char then
					clearPlayerESP(plr)
				end
			end)
		end
	end)
	table.insert(data.connections, charRemovingConn)
end

-- ============================================
-- SETUP ESP FOR SINGLE PLAYER
-- ============================================
local function createPlayerESP(plr)
	if plr == client then return end

	-- Apply immediately if they have character
	if plr.Character then
		task.spawn(function()
			attachESP(plr, plr.Character)
		end)
	end

	-- Handle their respawns
	local charConn = plr.CharacterAdded:Connect(function(char)
		-- Check if this player should still have ESP
		local shouldTrack = espData.globalEnabled or espData.trackedUserIds[plr.UserId] or espData.individualTargets[plr.UserId]
		if shouldTrack then
			task.wait(0.3)
			clearPlayerESP(plr)
			attachESP(plr, char)
		end
	end)

	if not espData.playerESP[plr] then
		espData.playerESP[plr] = { connections = { charConn }, objects = {}, distLabel = nil }
	else
		table.insert(espData.playerESP[plr].connections, charConn)
	end
end

-- ============================================
-- DISTANCE UPDATER (ROBUST)
-- ============================================
local function startDistanceUpdater()
	if espData.distanceConn then return end

	espData.distanceConn = RunService.RenderStepped:Connect(function()
		local myHRP = getMyHRP()

		for plr, data in pairs(espData.playerESP) do
			-- Skip if player left
			if not plr or not plr.Parent then
				clearPlayerESP(plr)
			else
				-- Update distance if possible
				if data.distLabel and data.distLabel.Parent then
					if myHRP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
						local targetHRP = plr.Character.HumanoidRootPart
						local dist = (targetHRP.Position - myHRP.Position).Magnitude
						data.distLabel.Text = math.floor(dist) .. " studs"
					else
						data.distLabel.Text = "..."
					end
				end
			end
		end
	end)
end

-- ============================================
-- ENABLE ESP FOR SPECIFIC PLAYER
-- ============================================
function enableESPPlayer(targetPlr)
	if not targetPlr then
		notify("Player not found", Color3.fromRGB(255, 100, 100))
		return
	end

	if targetPlr == client then
		notify("Can't ESP yourself", Color3.fromRGB(255, 200, 100))
		return
	end

	-- NEW: Add to persistent tracking
	espData.individualTargets[targetPlr.UserId] = true
	-- Also track by UserId for rejoin persistence
	espData.trackedUserIds[targetPlr.UserId] = true

	startDistanceUpdater()
	createPlayerESP(targetPlr)
	notify("ESP enabled for " .. targetPlr.Name, Color3.fromRGB(0, 255, 100))
end

-- ============================================
-- DISABLE ESP FOR SPECIFIC PLAYER
-- ============================================
function disableESPPlayer(targetPlr)
	if not targetPlr then
		notify("Player not found", Color3.fromRGB(255, 100, 100))
		return
	end

	-- NEW: Remove from persistent tracking
	espData.individualTargets[targetPlr.UserId] = nil
	espData.trackedUserIds[targetPlr.UserId] = nil

	clearPlayerESP(targetPlr)
	notify("ESP disabled for " .. targetPlr.Name, Color3.fromRGB(255, 180, 0))
end

-- ============================================
-- ENABLE ESP FOR ALL (GLOBAL)
-- ============================================
function enableESPAll()
	if espData.globalEnabled then return end
	espData.globalEnabled = true
	espData.enabled = true

	-- NEW: Track all current players by UserId
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= client then
			espData.trackedUserIds[plr.UserId] = true
		end
	end

	-- Apply to ALL current players
	for _, plr in ipairs(Players:GetPlayers()) do
		createPlayerESP(plr)
	end

	-- Auto-apply to NEW players joining
	local newPlayerConn = Players.PlayerAdded:Connect(function(plr)
		if espData.globalEnabled then
			-- NEW: Automatically track new players
			espData.trackedUserIds[plr.UserId] = true
			task.wait(0.5)
			createPlayerESP(plr)
		end
	end)
	table.insert(espData.globalConnections, newPlayerConn)

	-- Handle players LEAVING
	local playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
		clearPlayerESP(plr)
		-- NEW: Keep them tracked so ESP reapplies if they rejoin
		-- (don't remove from trackedUserIds - they stay tracked)
	end)
	table.insert(espData.globalConnections, playerRemovingConn)

	-- Handle MY respawn - reapply all ESP
	if espData.myCharConn then
		espData.myCharConn:Disconnect()
	end

	espData.myCharConn = client.CharacterAdded:Connect(function()
		task.wait(0.8)
		if not espData.globalEnabled then return end

		-- Clear and reapply all
		for plr, _ in pairs(espData.playerESP) do
			clearPlayerESP(plr)
		end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= client then
				createPlayerESP(plr)
			end
		end
	end)

	-- NEW: Handle rejoins - when a tracked player rejoins, reapply ESP
	local rejoinConn = Players.PlayerAdded:Connect(function(plr)
		if espData.trackedUserIds[plr.UserId] then
			-- This player was previously tracked, reapply ESP
			task.wait(0.5)
			if plr.Character then
				attachESP(plr, plr.Character)
			end
			createPlayerESP(plr)
		end
	end)
	table.insert(espData.globalConnections, rejoinConn)

	startDistanceUpdater()
	notify("ESP enabled for all players", Color3.fromRGB(0, 255, 100))
end

-- ============================================
-- DISABLE ESP FOR ALL (GLOBAL)
-- ============================================
function disableESPAll()
	if not espData.globalEnabled and not next(espData.playerESP) then
		notify("ESP not active", Color3.fromRGB(255, 200, 100))
		return
	end

	espData.globalEnabled = false
	espData.enabled = false

	-- NEW: Clear ALL tracking
	espData.trackedUserIds = {}
	espData.individualTargets = {}

	-- Disconnect global connections
	if espData.myCharConn then
		espData.myCharConn:Disconnect()
		espData.myCharConn = nil
	end

	for _, conn in ipairs(espData.globalConnections) do
		if conn then conn:Disconnect() end
	end
	espData.globalConnections = {}

	-- Clear all player ESP
	clearAllESP()

	-- Clean up distance conn
	if espData.distanceConn then
		espData.distanceConn:Disconnect()
		espData.distanceConn = nil
	end

	notify("ESP disabled for ALL", Color3.fromRGB(255, 180, 0))
end
-- =============================================================
-- SPIN SYSTEM
-- =============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local spinData = {}

function spin(plr, speed)

	speed = tonumber(speed) or 20
	speed = math.clamp(speed, 1, 10000)

	local char = plr.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	-- Stop old spin
	if spinData[plr] then
		unspin(plr)
	end

	hum.AutoRotate = false

	-- Attachment (YOU ALREADY HAD THIS)
	local attachment = Instance.new("Attachment")
	attachment.Name = "SpinAttachment"
	attachment.Parent = hrp

	-- REAL SPIN MOTOR (replaces AlignOrientation only)
	local angular = Instance.new("AngularVelocity")
	angular.Name = "SpinVelocity"
	angular.Attachment0 = attachment
	angular.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	angular.MaxTorque = math.huge

	-- the actual speed you type
	angular.AngularVelocity = Vector3.new(0, speed, 0)

	angular.Parent = hrp

	spinData[plr] = {
		attachment = attachment,
		angular = angular,
		connection = nil
	}

	-- keep server ownership so Roblox doesn't override it
	spinData[plr].connection = RunService.Stepped:Connect(function()
		if hrp and hrp.Parent then
			pcall(function()
				hrp:SetNetworkOwner(nil)
			end)
		end
	end)
end


function unspin(plr)

	local data = spinData[plr]
	if not data then return end

	if data.connection then
		data.connection:Disconnect()
	end

	if data.angular then
		data.angular:Destroy()
	end

	if data.attachment then
		data.attachment:Destroy()
	end

	local char = plr.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.AutoRotate = true
		end
	end

	spinData[plr] = nil
end


Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		unspin(plr)
	end)
end)

-- =============================================================
-- LEAVE COMMAND
-- =============================================================
local function leaveGame()
	game:Shutdown()
	notify("👋 Leaving game...", Color3.fromRGB(255, 100, 100))
end

-- =============================================================
-- DESTROY SCRIPT COMMAND
-- =============================================================
local function destroyScript()
	local CoreGui = game:GetService("CoreGui")

	-- Destroy from both PlayerGui and CoreGui
	local function destroyMatchingGuis(parent)
		for _, gui in ipairs(parent:GetChildren()) do
			if gui:IsA("ScreenGui") and (
				gui.Name == "LunarGui" or 
				gui.Name == "LunarNotifs" or 
				gui.Name == "LunarWatermark" or
				gui.Name == "LunarCrosshair" or
				gui.Name == "LunarCrosshairCMD" or
				gui.Name == "AimbotPanel" or 
				gui.Name == "logsPanel" or 
				gui.Name == "stopwatchPanel" or
				gui.Name == "SpeedPanel" or 
				gui.Name == "JoinLogsPanel" or 
				gui.Name == "ViewGui" or
				gui.Name == "CmdBarGui" or 
				gui.Name:find("^Lunar") or 
				gui.Name:find("Panel")
			) then
				gui:Destroy()
			end
		end
	end

	destroyMatchingGuis(client.PlayerGui)
	destroyMatchingGuis(CoreGui)

	-- === CRITICAL: Stop crosshair/watermark via _G data ===
	if _G.LunarCrosshairData then
		_G.LunarCrosshairData.enabled = false
		if _G.LunarCrosshairData.connection then
			_G.LunarCrosshairData.connection:Disconnect()
			_G.LunarCrosshairData.connection = nil
		end
		if _G.LunarCrosshairData.gui then
			_G.LunarCrosshairData.gui:Destroy()
			_G.LunarCrosshairData.gui = nil
		end
	end

	-- Clean up other data tables
	local dataTables = {speedPanelData, viewData, spinData}
	for _, data in ipairs(dataTables) do
		if data then
			for k, v in pairs(data) do
				if typeof(v) == "RBXScriptConnection" then
					v:Disconnect()
				end
			end
			if data.enabled ~= nil then data.enabled = false end
			if data.gui and typeof(data.gui) == "Instance" then
				pcall(function() data.gui:Destroy() end)
			end
		end
	end

	-- Disable features
	pcall(disableESPAll)
	pcall(disableFreecam)

	-- Restore chat
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end)

	-- Nuke commands
	processCmd = function() end
	_G.processCmd = function() end

	if addcmd then addcmd = function() end end
	if notify then notify = function() end end

	pcall(function()
		notify("💥 Script fully destroyed", Color3.fromRGB(255, 80, 80))
	end)
end
-- =============================================================
-- COMMAND BAR - COMPLETELY FIXED
-- =============================================================
local cmdBarData = {
	gui = nil,
	visible = false,
	inputBox = nil
}

-- Global command processor reference
local commandProcessor = nil

local function toggleCmdBar()
	if cmdBarData.gui then
		cmdBarData.gui.Enabled = not cmdBarData.gui.Enabled
		cmdBarData.visible = cmdBarData.gui.Enabled

		if cmdBarData.visible and cmdBarData.inputBox then
			task.wait() -- Small delay for better UX
			cmdBarData.inputBox:CaptureFocus()
		end
		return
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "CmdBarGui"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 1000000
	gui.Parent = client.PlayerGui

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 620, 0, 55)
	main.Position = UDim2.new(0.5, -310, 0.08, 0)  -- Slightly higher and wider
	main.BackgroundColor3 = currentTheme.glass
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = true
	main.Parent = gui
	applyGlassEffect(main, globalConfig.uiTransparency, 0.4)

	-- Title hint
	local titleHint = Instance.new("TextLabel", main)
	titleHint.Size = UDim2.new(0, 120, 1, 0)
	titleHint.Position = UDim2.new(0, 10, 0, 0)
	titleHint.BackgroundTransparency = 1
	titleHint.Text = "Command Bar"
	titleHint.Font = Enum.Font.GothamBlack
	titleHint.TextSize = 18
	titleHint.TextColor3 = currentTheme.accent
	titleHint.TextXAlignment = Enum.TextXAlignment.Left

	local input = Instance.new("TextBox")
	input.Name = "Input"
	input.Size = UDim2.new(1, -140, 1, -12)
	input.Position = UDim2.new(0, 130, 0, 6)
	input.BackgroundTransparency = 1
	input.PlaceholderText = "Type command here... (e.g. !aimbot)"
	input.Font = Enum.Font.GothamBold
	input.TextSize = 20
	input.TextColor3 = globalConfig.textColor
	input.TextTransparency = 0
	input.TextStrokeTransparency = 0.6
	input.TextStrokeColor3 = Color3.new(0,0,0)
	input.ClearTextOnFocus = true
	input.Parent = main

	cmdBarData.inputBox = input

	-- Dropdown suggestions
	local dropdown = Instance.new("Frame")
	dropdown.Name = "Dropdown"
	dropdown.Size = UDim2.new(1, 0, 0, 220)
	dropdown.Position = UDim2.new(0, 0, 1, 8)
	dropdown.BackgroundColor3 = currentTheme.list
	dropdown.BorderSizePixel = 0
	dropdown.Visible = false
	dropdown.ClipsDescendants = true
	dropdown.Parent = main
	applyGlassEffect(dropdown, globalConfig.uiTransparency + 0.1, 0.5)

	local dropdownScroll = Instance.new("ScrollingFrame", dropdown)
	dropdownScroll.Size = UDim2.new(1, -12, 1, -12)
	dropdownScroll.Position = UDim2.new(0, 6, 0, 6)
	dropdownScroll.BackgroundTransparency = 1
	dropdownScroll.ScrollBarThickness = 5
	dropdownScroll.ScrollBarImageColor3 = currentTheme.accent

	local dropdownList = Instance.new("UIListLayout", dropdownScroll)
	dropdownList.Padding = UDim.new(0, 3)

	local allCommands = {
	"!aimbot", "!autoexec", "!clicktp", "!cmdbar", "!console", "!crosshair", "!dance", "!destroyscript", 
	"!disablefalldamage", "!enable inventory", "!enable playerlist", "!esp all", "!explode", "!fire", 
	"!firstp", "!fling", "!fly", "!freecam", "!freeze", "!infjump", "!joinlogs", "!jump", "!kill", 
	"!lay", "!leave", "!logs", "!noclip", "!ping", "!ragdoll", "!rainbow", "!rejoin", "!removewaypoint", 
	"!resetspeed", "!sit", "!speed", "!spin", "!stopwatch", "!thirdp", "!to", "!trip", "!tracers", 
	"!uncrosshair", "!unautoexec", "!unesp all", "!unfire", "!unfly", "!unfreecam", "!unfreeze", 
	"!sunglare", "!unsunglare", "!uninfjump", "!unnoclip", "!unragdoll", "!unrainbow", "!unspin", 
	"!untracers", "!unview", "!view", "!volume", "!waypoint", "!fov", "!kick", "!unlockmouse"
	}

	local function updateDropdown(text)
		for _, child in ipairs(dropdownScroll:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end

		if text == "" or text == "!" then
			dropdown.Visible = false
			return
		end

		local matches = {}
		for _, cmd in ipairs(allCommands) do
			if cmd:lower():find(text:lower(), 1, true) then
				table.insert(matches, cmd)
			end
		end

		if #matches > 0 then
			dropdown.Visible = true
			for _, match in ipairs(matches) do
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 32)
				btn.BackgroundColor3 = currentTheme.btn
				btn.BackgroundTransparency = 0.4
				btn.Text = "  " .. match
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 17
				btn.TextColor3 = globalConfig.textColor
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.Parent = dropdownScroll

				btn.MouseButton1Click:Connect(function()
					input.Text = match .. " "
					input.CursorPosition = #input.Text + 1
					dropdown.Visible = false
					input:CaptureFocus()
				end)

				btn.MouseEnter:Connect(function() btn.BackgroundColor3 = currentTheme.accent end)
				btn.MouseLeave:Connect(function() btn.BackgroundColor3 = currentTheme.btn end)
			end
			dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #matches * 35)
		else
			dropdown.Visible = false
		end
	end

	input:GetPropertyChangedSignal("Text"):Connect(function()
		updateDropdown(input.Text)
	end)

	local function executeCommand()
		local cmdText = input.Text:match("^%s*(.-)%s*$") -- trim whitespace
		if cmdText and cmdText ~= "" then
			notify("▶️ Executing: " .. cmdText, Color3.fromRGB(180, 220, 255))
			if processCmd then
				processCmd(cmdText)
			else
				warn("processCmd function not found!")
			end
			input.Text = ""
			dropdown.Visible = false
		end
	end

	input.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			executeCommand()
		end
	end)

	-- Enter key support even if not focused
	UserInputService.InputBegan:Connect(function(inp, gp)
		if not gp and inp.KeyCode == Enum.KeyCode.Return and cmdBarData.visible and cmdBarData.inputBox:IsFocused() then
			executeCommand()
		end
	end)

	-- Click outside to close dropdown
	UserInputService.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 and cmdBarData.gui then
			local mousePos = UserInputService:GetMouseLocation()
			local mainPos = main.AbsolutePosition
			local mainSize = main.AbsoluteSize
			local dropdownArea = dropdown.AbsoluteSize.Y + 50

			if (mousePos.X < mainPos.X or mousePos.X > mainPos.X + mainSize.X) or
				(mousePos.Y < mainPos.Y or mousePos.Y > mainPos.Y + mainSize.Y + dropdownArea) then
				dropdown.Visible = false
			end
		end
	end)

	cmdBarData.gui = gui
	cmdBarData.visible = true

	-- Auto focus
	task.spawn(function()
		task.wait(0.1)
		input:CaptureFocus()
	end)

	notify("Command Bar Auto-Opened • Press INSERT to toggle", currentTheme.accent)
end

-- ==================== AUTO SHOW + HOTKEY ====================

task.spawn(function()
	task.wait(0.6)  -- Small delay to let other UI load
	toggleCmdBar()
end)

-- Hotkey to toggle (INSERT key - very common for cheats)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		toggleCmdBar()
	end
end)
-- ============================================
-- INFINITE JUMP SYSTEM
-- ============================================
local infJumpData = {
	enabled = false,
	beganConnection = nil,
	endedConnection = nil,
	charConnection = nil,
	heartbeatConnection = nil,
	holdingJump = false,
	currentChar = nil,
	currentHRP = nil
}

-- ============================================
-- INFINITE JUMP FUNCTIONS - Hold to auto-jump (Velocity-based)
-- ============================================
local function setupInfJump()
	local char = client.Character
	if not char then return end
	
	infJumpData.currentChar = char
	
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if hrp then
		infJumpData.currentHRP = hrp
	end
end

local function enableInfJump()
	if infJumpData.enabled then
		notify("⚠️ Infinite jump already enabled", Color3.fromRGB(255, 200, 100))
		return
	end
	
	infJumpData.enabled = true
	infJumpData.holdingJump = false
	
	setupInfJump()
	
	-- Clean up any old connections first
	if infJumpData.beganConnection then
		infJumpData.beganConnection:Disconnect()
	end
	if infJumpData.endedConnection then
		infJumpData.endedConnection:Disconnect()
	end
	if infJumpData.heartbeatConnection then
		infJumpData.heartbeatConnection:Disconnect()
	end
	
	-- InputBegan - detect when space is pressed
	infJumpData.beganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not infJumpData.enabled then return end
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.Space then
			infJumpData.holdingJump = true
		end
	end)
	
	-- InputEnded - detect when space is released
	infJumpData.endedConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.Space then
			infJumpData.holdingJump = false
		end
	end)
	
	-- Heartbeat loop - apply jump velocity while holding
	infJumpData.heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not infJumpData.enabled then return end
		if not infJumpData.holdingJump then return end
		
		local hrp = infJumpData.currentHRP
		if hrp and hrp.Parent then
			local vel = hrp.AssemblyLinearVelocity
			-- Only apply if falling or on ground (not already going up fast)
			if vel.Y <= 10 then
				hrp.AssemblyLinearVelocity = Vector3.new(vel.X, math.max(vel.Y + 5, 50), vel.Z)
			end
		end
	end)
	
	-- Re-setup on respawn
	if infJumpData.charConnection then
		infJumpData.charConnection:Disconnect()
	end
	
	infJumpData.charConnection = client.CharacterAdded:Connect(function(newChar)
		if not infJumpData.enabled then return end
		task.wait(0.5)
		if infJumpData.enabled then
			setupInfJump()
		end
	end)
	
	notify("Infinite jump enabled - Hold space to fly up", Color3.fromRGB(0, 255, 100))
end

local function disableInfJump()
	if not infJumpData.enabled then
		notify("⚠️ Infinite jump not enabled", Color3.fromRGB(255, 200, 100))
		return
	end
	
	infJumpData.enabled = false
	infJumpData.holdingJump = false
	
	if infJumpData.beganConnection then
		infJumpData.beganConnection:Disconnect()
		infJumpData.beganConnection = nil
	end
	
	if infJumpData.endedConnection then
		infJumpData.endedConnection:Disconnect()
		infJumpData.endedConnection = nil
	end
	
	if infJumpData.heartbeatConnection then
		infJumpData.heartbeatConnection:Disconnect()
		infJumpData.heartbeatConnection = nil
	end
	
	if infJumpData.charConnection then
		infJumpData.charConnection:Disconnect()
		infJumpData.charConnection = nil
	end
	
	infJumpData.currentChar = nil
	infJumpData.currentHRP = nil
	
	notify("❌ Infinite jump disabled", Color3.fromRGB(255, 100, 100))
end
-- =============================================================
-- AIMBOT SYSTEM
-- =============================================================
local aimbotData = {
	enabled = false,
	smoothness = 0.5,
	smoothnessEnabled = true,
	teamCheck = true, -- ON by default so you don't lock teammates
	wallCheck = false,
	targetTeam = nil,
	aimPart = "HumanoidRootPart",
	predictionEnabled = false,
	predictionAmount = 0.15,
	
	-- Sticky target system
	currentTarget = nil,
	targetLockTime = 0,
	targetStickiness = 0.3, -- seconds to stick to target before allowing switch
	
	panel = nil,
	teamsList = nil,
	connection = nil,
	inputBeganConn = nil,
	inputEndedConn = nil,
	minimized = false,
	mainFrame = nil,
	rightClickHeld = false,
	fovCircle = nil,
	fovEnabled = false,
	fovSize = 150
}

local function createAimbotPanel()
	local CoreGui = game:GetService("CoreGui")

	-- Cleanup
	if aimbotData.panel then aimbotData.panel:Destroy() end
	if aimbotData.connection then aimbotData.connection:Disconnect() end
	if aimbotData.inputBeganConn then aimbotData.inputBeganConn:Disconnect() end
	if aimbotData.inputEndedConn then aimbotData.inputEndedConn:Disconnect() end
	if aimbotData.fovCircle then aimbotData.fovCircle:Remove() end

	aimbotData.enabled = false
	aimbotData.targetTeam = nil
	aimbotData.currentTarget = nil
	aimbotData.minimized = false
	aimbotData.rightClickHeld = false

	-- COREGUI
	local panel = Instance.new("ScreenGui")
	panel.Name = "AimbotPanel"
	panel.ResetOnSpawn = false
	panel.DisplayOrder = 2147483646
	panel.ZIndexBehavior = Enum.ZIndexBehavior.Global
	panel.ScreenInsets = Enum.ScreenInsets.None
	panel.IgnoreGuiInset = true
	panel.Parent = CoreGui

	-- MAIN FRAME
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 420, 0, 520)
	main.Position = UDim2.new(0, 430, 0.5, -260)
	main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = true
	main.ClipsDescendants = true
	main.ZIndex = 2147483646
	main.Parent = panel
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

	aimbotData.mainFrame = main

	-- TITLE BAR
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 50)
	titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	titleBar.BorderSizePixel = 0
	titleBar.ZIndex = 2147483646
	titleBar.Parent = main
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -100, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🎯 AIMBOT"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 22
	title.TextColor3 = currentTheme.accent
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextStrokeTransparency = 0.5
	title.TextStrokeColor3 = Color3.new(0,0,0)
	title.ZIndex = 2147483647
	title.Parent = titleBar

	-- Minimize
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
	minimizeBtn.Position = UDim2.new(1, -75, 0.5, -17.5)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	minimizeBtn.Text = "−"
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = 20
	minimizeBtn.TextColor3 = Color3.new(1,1,1)
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.ZIndex = 2147483647
	minimizeBtn.Parent = titleBar
	Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

	-- Close
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 35, 0, 35)
	closeBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeBtn.Text = "×"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 22
	closeBtn.TextColor3 = Color3.new(1,1,1)
	closeBtn.BorderSizePixel = 0
	closeBtn.ZIndex = 2147483647
	closeBtn.Parent = titleBar
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

	closeBtn.MouseButton1Click:Connect(function()
		aimbotData.enabled = false
		if aimbotData.connection then aimbotData.connection:Disconnect() end
		if aimbotData.inputBeganConn then aimbotData.inputBeganConn:Disconnect() end
		if aimbotData.inputEndedConn then aimbotData.inputEndedConn:Disconnect() end
		if aimbotData.fovCircle then aimbotData.fovCircle:Remove() end

		panel:Destroy()
		aimbotData.panel = nil
		aimbotData.currentTarget = nil
		notify("Aimbot closed. Use !aimbot to reopen.", Color3.fromRGB(255, 160, 60))
	end)

	minimizeBtn.MouseButton1Click:Connect(function()
		aimbotData.minimized = not aimbotData.minimized
		if aimbotData.minimized then
			main:TweenSize(UDim2.new(0, 420, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
			contentScroll.Visible = false
			minimizeBtn.Text = "+"
		else
			main:TweenSize(UDim2.new(0, 420, 0, 520), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
			contentScroll.Visible = true
			minimizeBtn.Text = "−"
		end
	end)

	-- CONTENT
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Name = "Content"
	contentScroll.Size = UDim2.new(1, -20, 1, -60)
	contentScroll.Position = UDim2.new(0, 10, 0, 55)
	contentScroll.BackgroundTransparency = 1
	contentScroll.BorderSizePixel = 0
	contentScroll.ScrollBarThickness = 6
	contentScroll.ScrollBarImageColor3 = currentTheme.accent
	contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentScroll.ZIndex = 2147483646
	contentScroll.Parent = main

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = contentScroll

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 20)
	padding.Parent = contentScroll

	-- Helpers
	local function createHeader(text)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(0.95, 0, 0, 32)
		container.BackgroundColor3 = currentTheme.accent
		container.BorderSizePixel = 0
		container.ZIndex = 2147483646
		container.Parent = contentScroll
		Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.Font = Enum.Font.GothamBlack
		label.TextSize = 14
		label.TextColor3 = Color3.new(0, 0, 0)
		label.TextStrokeTransparency = 0.8
		label.ZIndex = 2147483647
		label.Parent = container
		return container
	end

	local function createButton()
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.95, 0, 0, 40)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 15
		btn.AutoButtonColor = true
		btn.BorderSizePixel = 0
		btn.ZIndex = 2147483646
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		return btn
	end

	local function createToggle(name, key, callback)
		local btn = createButton()
		btn.Text = name .. ": " .. (aimbotData[key] and "ON ✓" or "OFF ✗")
		btn.TextColor3 = aimbotData[key] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
		btn.TextStrokeTransparency = 0.5
		btn.TextStrokeColor3 = Color3.new(0,0,0)
		btn.Parent = contentScroll

		btn.MouseButton1Click:Connect(function()
			aimbotData[key] = not aimbotData[key]
			btn.Text = name .. ": " .. (aimbotData[key] and "ON ✓" or "OFF ✗")
			btn.TextColor3 = aimbotData[key] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
			if callback then callback(aimbotData[key]) end
		end)
		return btn
	end

	-- TARGETING SECTION
	createHeader("lunar loves femboys")

	-- Team Check (auto-detects your team)
	createToggle("Team Check (Auto)", "teamCheck", function(enabled)
		if enabled then
			notify("Team Check ON — Won't lock teammates", Color3.fromRGB(100, 255, 100))
		else
			notify("Team Check OFF — Will lock anyone", Color3.fromRGB(255, 100, 100))
		end
	end)

	-- Wall Check
	createToggle("Wall Check", "wallCheck")

	-- Aim Part
	local aimPartBtn = createButton()
	aimPartBtn.Text = "Aim Part: " .. (aimbotData.aimPart == "Head" and "HEAD" or "TORSO")
	aimPartBtn.TextColor3 = currentTheme.accent
	aimPartBtn.Parent = contentScroll
	aimPartBtn.MouseButton1Click:Connect(function()
		aimbotData.aimPart = aimbotData.aimPart == "Head" and "HumanoidRootPart" or "Head"
		aimPartBtn.Text = "Aim Part: " .. (aimbotData.aimPart == "Head" and "HEAD" or "TORSO")
	end)

	-- SETTINGS SECTION
	createHeader("blah blah blah")

	createToggle("Aimbot Enabled", "enabled")
	createToggle("Smoothness", "smoothnessEnabled")

	-- FOV Circle Toggle
	createToggle("FOV Circle", "fovEnabled", function(enabled)
		if enabled then
			if not aimbotData.fovCircle then
				aimbotData.fovCircle = Drawing.new("Circle")
				aimbotData.fovCircle.Thickness = 2
				aimbotData.fovCircle.NumSides = 64
				aimbotData.fovCircle.Filled = false
				aimbotData.fovCircle.Visible = true
			end
			notify("FOV Circle ON — Only locks inside circle", Color3.fromRGB(100, 200, 255))
		else
			if aimbotData.fovCircle then
				aimbotData.fovCircle.Visible = false
			end
		end
	end)

	-- Prediction
	createToggle("Prediction", "predictionEnabled")

	-- SLIDERS
	createHeader("blah blah blah")

	local function createSlider(labelText, dataKey, minVal, maxVal, isInt)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(0.95, 0, 0, 55)
		container.BackgroundTransparency = 1
		container.ZIndex = 2147483646
		container.Parent = contentScroll

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, 22)
		label.BackgroundTransparency = 1
		label.Text = labelText .. ": " .. aimbotData[dataKey]
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextColor3 = globalConfig.textColor
		label.ZIndex = 2147483647
		label.Parent = container

		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(1, 0, 0, 10)
		sliderFrame.Position = UDim2.new(0, 0, 0, 28)
		sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		sliderFrame.BorderSizePixel = 0
		sliderFrame.ZIndex = 2147483646
		sliderFrame.Parent = container
		Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 5)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = currentTheme.accent
		fill.BorderSizePixel = 0
		fill.ZIndex = 2147483647
		fill.Parent = sliderFrame
		Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)

		local drag = Instance.new("TextButton")
		drag.Size = UDim2.new(0, 16, 0, 16)
		drag.BackgroundColor3 = Color3.new(1,1,1)
		drag.BorderSizePixel = 0
		drag.Text = ""
		drag.ZIndex = 2147483647
		drag.Parent = sliderFrame
		Instance.new("UICorner", drag).CornerRadius = UDim.new(1, 0)

		local dragging = false
		drag.InputBegan:Connect(function(i) 
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end 
		end)
		UserInputService.InputEnded:Connect(function(i) 
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
		end)

		UserInputService.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				local percent = math.clamp((i.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(percent, 0, 1, 0)
				drag.Position = UDim2.new(percent, -8, 0.5, -8)

				local value = minVal + percent * (maxVal - minVal)
				if isInt then value = math.floor(value) else value = math.round(value * 100) / 100 end
				aimbotData[dataKey] = value
				label.Text = labelText .. ": " .. value
			end
		end)

		local initP = (aimbotData[dataKey] - minVal) / (maxVal - minVal)
		fill.Size = UDim2.new(initP, 0, 1, 0)
		drag.Position = UDim2.new(initP, -8, 0.5, -8)
	end

	createSlider("Smoothness", "smoothness", 0.1, 1, false)
	createSlider("Prediction", "predictionAmount", 0, 0.5, false)
	createSlider("FOV Size", "fovSize", 50, 400, true)

	aimbotData.panel = panel

	-- ================= STICKY AIMBOT LOGIC =================
	local function isValidTarget(plr)
		if not plr or plr == client or not plr.Character then return false end
		local char = plr.Character
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return false end

		-- Team check: auto-detect your current team
		if aimbotData.teamCheck and client.Team and plr.Team and client.Team == plr.Team then
			return false
		end

		if aimbotData.wallCheck then
			local cam = workspace.CurrentCamera
			local root = char:FindFirstChild(aimbotData.aimPart) or char:FindFirstChild("HumanoidRootPart")
			if not root then return false end
			local origin = cam.CFrame.Position
			local dir = (root.Position - origin) * 0.95
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {client.Character or Instance.new("Folder"), char}
			params.FilterType = Enum.RaycastFilterType.Blacklist
			local result = workspace:Raycast(origin, dir, params)
			if result then return false end
		end
		return true
	end

	local function getTargetPosition(rootPart)
		local pos = rootPart.Position
		if aimbotData.predictionEnabled and rootPart.AssemblyLinearVelocity then
			local vel = rootPart.AssemblyLinearVelocity
			local dist = (pos - workspace.CurrentCamera.CFrame.Position).Magnitude
			pos = pos + vel * (dist / 1000) * aimbotData.predictionAmount
		end
		return pos
	end

	local function getDistanceToMouse(plr)
		local mousePos = UserInputService:GetMouseLocation()
		local cam = workspace.CurrentCamera
		local root = plr.Character:FindFirstChild(aimbotData.aimPart) or plr.Character:FindFirstChild("HumanoidRootPart")
		if not root then return math.huge end

		local pos = getTargetPosition(root)
		local screenPos, onScreen = cam:WorldToViewportPoint(pos)
		if not onScreen then return math.huge end

		-- FOV check
		if aimbotData.fovEnabled then
			local centerDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
			if centerDist > aimbotData.fovSize then return math.huge end
		end

		return (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
	end

	-- STICKY TARGET: Once locked, stay on them unless they die/go offscreen for too long
	local function updateStickyTarget()
		local now = tick()

		-- Check if current target is still valid
		if aimbotData.currentTarget then
			if not isValidTarget(aimbotData.currentTarget) then
				aimbotData.currentTarget = nil
				aimbotData.targetLockTime = 0
			else
				local dist = getDistanceToMouse(aimbotData.currentTarget)
				-- Still in FOV? Keep them
				if dist < math.huge then
					aimbotData.targetLockTime = now
					return aimbotData.currentTarget
				end
				-- Out of FOV for more than 0.3s? Allow switch
				if now - aimbotData.targetLockTime > 0.3 then
					aimbotData.currentTarget = nil
				else
					return aimbotData.currentTarget -- still sticky
				end
			end
		end

		-- Find new target
		local closest, closestDist = nil, math.huge
		for _, plr in ipairs(Players:GetPlayers()) do
			if isValidTarget(plr) then
				local dist = getDistanceToMouse(plr)
				if dist < closestDist then
					closestDist = dist
					closest = plr
				end
			end
		end

		if closest then
			aimbotData.currentTarget = closest
			aimbotData.targetLockTime = now
		end

		return closest
	end

	-- FOV Circle update
	local fovConnection = RunService.RenderStepped:Connect(function()
		if aimbotData.fovEnabled and aimbotData.fovCircle then
			local mousePos = UserInputService:GetMouseLocation()
			aimbotData.fovCircle.Position = mousePos
			aimbotData.fovCircle.Radius = aimbotData.fovSize
			aimbotData.fovCircle.Color = aimbotData.currentTarget and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(100, 200, 255)
			aimbotData.fovCircle.Visible = true
		elseif aimbotData.fovCircle then
			aimbotData.fovCircle.Visible = false
		end
	end)

	-- Main aimbot loop
	aimbotData.connection = RunService.RenderStepped:Connect(function()
		if not (aimbotData.enabled and aimbotData.rightClickHeld) then
			aimbotData.currentTarget = nil
			return
		end

		local target = updateStickyTarget()
		if not target or not target.Character then return end

		local root = target.Character:FindFirstChild(aimbotData.aimPart) or target.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local predictedPos = getTargetPosition(root)
		local screenPos = workspace.CurrentCamera:WorldToViewportPoint(predictedPos)
		local mousePos = UserInputService:GetMouseLocation()
		local targetScreen = Vector2.new(screenPos.X, screenPos.Y)

		local moveVec
		if aimbotData.smoothnessEnabled then
			moveVec = mousePos:Lerp(targetScreen, 1 - aimbotData.smoothness)
		else
			moveVec = targetScreen
		end

		if mousemoverel then
			mousemoverel(moveVec.X - mousePos.X, moveVec.Y - mousePos.Y)
		end
	end)

	aimbotData.inputBeganConn = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			aimbotData.rightClickHeld = true
		end
	end)

	aimbotData.inputEndedConn = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			aimbotData.rightClickHeld = false
			aimbotData.currentTarget = nil -- release target on right-click up
		end
	end)

	notify("Aimbot loaded! Right-click to lock. Sticky target enabled.", Color3.fromRGB(100, 200, 255))
end
-- =============================================================
-- UNLOCK MOUSE SYSTEM
-- =============================================================
local mouseUnlockData = {
	enabled = false,
	connection = nil
}

local function toggleMouseUnlock()
	mouseUnlockData.enabled = not mouseUnlockData.enabled

	if mouseUnlockData.enabled then
		notify("Mouse unlock enabled! Press F to toggle lock/unlock", Color3.fromRGB(100, 255, 100))

		mouseUnlockData.connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
				local currentState = UserInputService.MouseBehavior
				if currentState == Enum.MouseBehavior.LockCenter then
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
					UserInputService.MouseIconEnabled = true
					notify("🔓 Mouse UNLOCKED - Move freely", Color3.fromRGB(100, 255, 100))
				else
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
					UserInputService.MouseIconEnabled = false
					notify("🔒 Mouse LOCKED - FPS mode", Color3.fromRGB(255, 100, 100))
				end
			end
		end)
	else
		if mouseUnlockData.connection then
			mouseUnlockData.connection:Disconnect()
			mouseUnlockData.connection = nil
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
		notify("❌ Mouse unlock disabled", Color3.fromRGB(255, 100, 100))
	end
end

-- =============================================================
-- panel management
-- =============================================================
local subPanels = {
	logs = nil,
	stopwatch = nil
}

local function createSubPanel(name, size, titleText)
	local existing = client.PlayerGui:FindFirstChild(name .. "Panel")
	if existing then
		existing:Destroy()
		if subPanels[name] then
			subPanels[name] = nil
		end
		return nil
	end

	local panel = Instance.new("ScreenGui")
	panel.Name = name .. "Panel"
	panel.ResetOnSpawn = false
	panel.DisplayOrder = 999999
	panel.Parent = client.PlayerGui

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = size
	main.Position = UDim2.new(0, 430, 0.5, -size.Y.Offset/2)
	main.BackgroundColor3 = currentTheme.glass
	main.Active = true
	main.Draggable = true
	main.Parent = panel
	applyGlassEffect(main, globalConfig.uiTransparency, 0.4)

	local title = Instance.new("TextLabel", main)
	title.Size = UDim2.new(1, -50, 0, 45)
	title.Position = UDim2.new(0, 15, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 22
	title.TextColor3 = currentTheme.accent
	title.TextTransparency = 0 -- SOLID
	title.TextStrokeTransparency = 0.5
	title.TextStrokeColor3 = Color3.new(0,0,0)
	title.TextXAlignment = Enum.TextXAlignment.Left

	local closeBtn = Instance.new("TextButton", main)
	closeBtn.Size = UDim2.new(0, 35, 0, 35)
	closeBtn.Position = UDim2.new(1, -45, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBlack
	closeBtn.TextSize = 20
	closeBtn.TextColor3 = Color3.new(1,1,1)
	closeBtn.TextTransparency = 0 -- SOLID
	applyGlassEffect(closeBtn, 0.2, 0.4)

	closeBtn.MouseButton1Click:Connect(function()
		panel:Destroy()
		subPanels[name] = nil
	end)

	subPanels[name] = panel
	return main
end

-- =============================================================
-- Logs panel
-- =============================================================
local logsScroll, logEntries = nil, {}

local function addLog(sender, message)
	if not logsScroll or not logsScroll.Parent then return end
	if #logEntries > 70 then
		if logEntries[1] then logEntries[1]:Destroy() end
		table.remove(logEntries, 1)
	end
	local entry = Instance.new("TextLabel")
	entry.Size = UDim2.new(1, -16, 0, 32)
	entry.BackgroundTransparency = 0.8
	entry.BackgroundColor3 = currentTheme.btn
	entry.TextXAlignment = Enum.TextXAlignment.Left
	entry.RichText = true
	entry.Text = " <font color='rgb(140,180,255)'><b>" .. sender .. "</b></font>: " .. message
	entry.TextColor3 = globalConfig.textColor
	entry.TextSize = 15
	entry.Font = Enum.Font.Gotham
	entry.TextWrapped = true
	entry.TextTransparency = 0 -- SOLID
	entry.TextStrokeTransparency = 0.5
	entry.TextStrokeColor3 = Color3.new(0,0,0)
	entry.Parent = logsScroll
	applyGlassEffect(entry, 0.6, 0.8)
	table.insert(logEntries, entry)
	logsScroll.CanvasSize = UDim2.new(0,0,0, #logEntries * 36)
	logsScroll.CanvasPosition = Vector2.new(0, #logEntries * 36)
end

local function toggleLogs()
	if subPanels.logs then
		subPanels.logs:Destroy()
		subPanels.logs = nil
		logsScroll = nil
		return
	end

	local main = createSubPanel("logs", UDim2.new(0, 420, 0, 380), "CHAT LOGS")
	if not main then return end

	logsScroll = Instance.new("ScrollingFrame", main)
	logsScroll.Size = UDim2.new(1, -20, 1, -65)
	logsScroll.Position = UDim2.new(0, 10, 0, 55)
	logsScroll.BackgroundTransparency = 0.4
	logsScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	logsScroll.ScrollBarThickness = 8
	logsScroll.ScrollBarImageColor3 = currentTheme.accent
	applyGlassEffect(logsScroll, 0.5, 0.7)

	local layout = Instance.new("UIListLayout", logsScroll)
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local clearBtn = Instance.new("TextButton", main)
	clearBtn.Size = UDim2.new(0, 90, 0, 35)
	clearBtn.Position = UDim2.new(1, -140, 0, 5)
	clearBtn.BackgroundColor3 = currentTheme.btn
	clearBtn.Text = "Clear"
	clearBtn.Font = Enum.Font.GothamBold
	clearBtn.TextSize = 16
	clearBtn.TextColor3 = globalConfig.textColor
	clearBtn.TextTransparency = 0 -- SOLID
	applyGlassEffect(clearBtn, 0.25, 0.5)

	clearBtn.MouseButton1Click:Connect(function()
		for _, entry in ipairs(logEntries) do
			if entry then entry:Destroy() end
		end
		logEntries = {}
		logsScroll.CanvasSize = UDim2.new(0,0,0,0)
	end)

	notify("Logs panel opened", Color3.fromRGB(180,180,255))
end

TextChatService.MessageReceived:Connect(function(msg)
	if msg.TextSource then
		addLog(msg.TextSource.Name, msg.Text)
	end
end)

-- =============================================================
-- Stopwatch panel
-- =============================================================
local stopwatchData = {
	running = false,
	startTime = 0,
	conn = nil,
	label = nil
}

local function toggleStopwatch()
	if subPanels.stopwatch then
		subPanels.stopwatch:Destroy()
		subPanels.stopwatch = nil
		if stopwatchData.conn then
			stopwatchData.conn:Disconnect()
			stopwatchData.conn = nil
		end
		stopwatchData.running = false
		return
	end

	local main = createSubPanel("stopwatch", UDim2.new(0, 380, 0, 220), "STOPWATCH")
	if not main then return end

	local timeLabel = Instance.new("TextLabel", main)
	timeLabel.Size = UDim2.new(1, -20, 0, 90)
	timeLabel.Position = UDim2.new(0, 10, 0, 55)
	timeLabel.BackgroundTransparency = 0.3
	timeLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	timeLabel.Text = "00:00.00"
	timeLabel.Font = Enum.Font.GothamBlack
	timeLabel.TextSize = 56
	timeLabel.TextColor3 = currentTheme.accent
	timeLabel.TextTransparency = 0 -- SOLID
	timeLabel.TextStrokeTransparency = 0.5
	timeLabel.TextStrokeColor3 = Color3.new(0,0,0)
	applyGlassEffect(timeLabel, 0.4, 0.6)

	local btnFrame = Instance.new("Frame", main)
	btnFrame.Size = UDim2.new(1, -20, 0, 55)
	btnFrame.Position = UDim2.new(0, 10, 0, 155)
	btnFrame.BackgroundTransparency = 1

	local startBtn = Instance.new("TextButton", btnFrame)
	startBtn.Size = UDim2.new(0.48, 0, 1, 0)
	startBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
	startBtn.Text = "START"
	startBtn.Font = Enum.Font.GothamBlack
	startBtn.TextSize = 22
	startBtn.TextColor3 = Color3.new(0,0,0)
	startBtn.TextTransparency = 0 -- SOLID
	applyGlassEffect(startBtn, 0.15, 0.4)

	local resetBtn = Instance.new("TextButton", btnFrame)
	resetBtn.Size = UDim2.new(0.48, 0, 1, 0)
	resetBtn.Position = UDim2.new(0.52, 0, 0, 0)
	resetBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	resetBtn.Text = "RESET"
	resetBtn.Font = Enum.Font.GothamBlack
	resetBtn.TextSize = 22
	resetBtn.TextColor3 = Color3.new(0,0,0)
	resetBtn.TextTransparency = 0 -- SOLID
	applyGlassEffect(resetBtn, 0.15, 0.4)

	local function formatTime(t)
		local mins = math.floor(t / 60)
		local secs = math.floor(t % 60)
		local ms = math.floor((t % 1) * 100)
		return string.format("%02d:%02d.%02d", mins, secs, ms)
	end

	startBtn.MouseButton1Click:Connect(function()
		if stopwatchData.running then
			stopwatchData.running = false
			if stopwatchData.conn then
				stopwatchData.conn:Disconnect()
				stopwatchData.conn = nil
			end
			startBtn.Text = "RESUME"
			startBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		else
			stopwatchData.running = true
			local current = tick()
			stopwatchData.startTime = current - (stopwatchData.startTime or 0)
			stopwatchData.conn = RunService.Heartbeat:Connect(function()
				if stopwatchData.running then
					local elapsed = tick() - stopwatchData.startTime
					timeLabel.Text = formatTime(elapsed)
				end
			end)
			startBtn.Text = "PAUSE"
			startBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
		end
	end)

	resetBtn.MouseButton1Click:Connect(function()
		stopwatchData.running = false
		if stopwatchData.conn then
			stopwatchData.conn:Disconnect()
			stopwatchData.conn = nil
		end
		stopwatchData.startTime = 0
		timeLabel.Text = "00:00.00"
		startBtn.Text = "START"
		startBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
	end)

	stopwatchData.label = timeLabel
	notify("Stopwatch panel opened", Color3.fromRGB(200, 200, 255))
end

-- =============================================================
-- Remove waypoint
-- =============================================================
local function removeWaypoint()
	if #waypoints == 0 then
		notify("⚠️ No waypoints to remove", Color3.fromRGB(255, 100, 100))
		return
	end

	local last = waypoints[#waypoints]
	if last then
		if last.conn then last.conn:Disconnect() end
		if last.part then last.part:Destroy() end
		table.remove(waypoints, #waypoints)
		notify("Removed waypoint #" .. (#waypoints + 1), Color3.fromRGB(255, 160, 60))
	end
end

-- =============================================================
-- UTILITIES
-- =============================================================
local function getPlr(str)
	if not str or str:lower() == "me" then return client end
	str = str:lower()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():sub(1,#str) == str or (p.DisplayName or ""):lower():sub(1,#str) == str then
			return p
		end
	end
	return nil
end

local function getHRP(p)
	local c = p.Character
	if c then
		local part = c:FindFirstChild("HumanoidRootPart")
		if part then
			return part
		end
	end
	return nil
end

local function getHum(p)
	local c = p.Character
	if c then
		local hum = c:FindFirstChildOfClass("Humanoid")
		if hum then
			return hum
		end
	end
	return nil
end

-- =============================================================
-- ALL COMMANDS
-- =============================================================
local noclipConn
local frozen = {}
local gods = {}
local invis = {}
local rainbowData = {}
local ragdolls = {}
------------------------------------------------
--  speed
------------------------------------------------
local function setspeed(plr, num)
	if plr ~= client then
		notify("❌ Speed only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	local hum = getHum(plr)
	if hum then
		hum.WalkSpeed = tonumber(num) or 16
		notify("WalkSpeed set to " .. hum.WalkSpeed, currentTheme.accent)
	end
end
------------------------------------------------
-- noclip
------------------------------------------------
local function noclip(plr)
	if plr ~= client then
		notify("❌ Noclip only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	if noclipConn then 
		notify("⚠️ Noclip already enabled", Color3.fromRGB(255, 200, 100))
		return 
	end
	noclipConn = RunService.Stepped:Connect(function()
		if client.Character then
			for _, part in client.Character:GetDescendants() do
				if part:IsA("BasePart") then
					pcall(function() part.CanCollide = false end)
				end
			end
		end
	end)
	notify("Noclip enabled", Color3.fromRGB(100, 255, 120))
end
------------------------------------------------
-- unnoclip
------------------------------------------------
local function unnoclip(plr)
	if plr ~= client then
		notify("❌ Unnoclip only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	if noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
	end
	if client.Character then
		for _, part in client.Character:GetDescendants() do
			if part:IsA("BasePart") then
				pcall(function() part.CanCollide = true end)
			end
		end
	end
	notify("⚠️Noclip disabled", Color3.fromRGB(255, 120, 100))
end
------------------------------------------------
-- kill
------------------------------------------------
local function kill(plr)
	local char = plr and plr.Character
	if not char then 
		notify("⚠️DOES NOT WORK⚠️", Color3.fromRGB(255, 100, 100))
		return 
	end
	pcall(function()
		local hum = getHum(plr)
		if hum then hum.Health = 0 end
		char:BreakJoints()
	end)
	notify("Only works in FTAP ⚠️DOES NOT WORK⚠️" .. plr.Name, Color3.fromRGB(255, 80, 80))
end
------------------------------------------------
-- tp
------------------------------------------------
local function tp(p1, p2)
	if p1 ~= client then
		notify("❌ Teleport only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	if not p2 then
		notify("❌ No target player specified", Color3.fromRGB(255, 100, 100))
		return
	end
	local h1, h2 = getHRP(p1), getHRP(p2)
	if h1 and h2 then
		h1.CFrame = h2.CFrame * CFrame.new(0, 3, 0)
		notify("Teleported to " .. p2.Name, currentTheme.accent)
	else
		notify("❌ Teleport failed - missing character parts", Color3.fromRGB(255, 100, 100))
	end
end
------------------------------------------------
-- to
------------------------------------------------
local function gotoMe(target)
	if not target then
		notify("❌ No target specified", Color3.fromRGB(255, 100, 100))
		return
	end
	tp(client, target)
end
------------------------------------------------
-- Jumppower
------------------------------------------------
local function jump(plr, pow)
	if plr ~= client then
		notify("❌ Jump only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	local hum = getHum(plr)
	if hum then
		hum.JumpPower = tonumber(pow) or 50
		notify("Jump power set to " .. hum.JumpPower, Color3.fromRGB(200, 200, 100))
	end
end
------------------------------------------------
-- sit
------------------------------------------------
local function sit(plr)
	if plr ~= client then
		notify("❌ Sit only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	local hum = getHum(plr)
	if hum then 
		hum.Sit = true 
		notify("Sitting", Color3.fromRGB(200, 150, 255))
	end
end
------------------------------------------------
-- Lay
------------------------------------------------
local function lay(plr)
	if plr ~= client then
		notify("❌ Lay only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	local hum = getHum(plr)
	if hum then
		hum.Sit = true
		task.wait(0.1)
		local hrp = getHRP(plr)
		if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0) end
		notify("Laying down", Color3.fromRGB(200, 150, 255))
	end
end
------------------------------------------------
-- Freeze
------------------------------------------------
local function freeze(plr)
	if plr ~= client then
		notify("❌ Freeze only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	local hum = getHum(plr)
	if not hum or frozen[plr] then 
		notify("⚠️ Already frozen", Color3.fromRGB(255, 200, 100))
		return 
	end
	frozen[plr] = {ws = hum.WalkSpeed, jp = hum.JumpPower}
	hum.WalkSpeed = 0
	hum.JumpPower = 0
	notify("Frozen", Color3.fromRGB(100, 100, 255))
end
------------------------------------------------
-- Unfreeze
------------------------------------------------
local function unfreeze(plr)
	if plr ~= client then
		notify("❌ Unfreeze only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	local data = frozen[plr]
	local hum = getHum(plr)
	if data and hum then
		hum.WalkSpeed = data.ws
		hum.JumpPower = data.jp
		frozen[plr] = nil
		notify("Unfrozen", Color3.fromRGB(200, 100, 200))
	else
		notify("⚠️Not frozen", Color3.fromRGB(255, 200, 100))
	end
end
------------------------------------------------
-- Fling/clicktp
------------------------------------------------

local TouchFling = {
	enabled = false,
	flingAll = false,
	lockFling = false,
	clickTP = false,
	oneTimeTP = false,
	selectedPlayer = nil,
	movel = 0.1,
	clickTPKey = Enum.KeyCode.E, -- Default key
	isSelectingKey = false,
	gui = nil,
	mainFrame = nil,
	toggles = {},
	buttons = {}
}

function TouchFling:UpdateToggle(name, displayName)
	local state = self[name]
	local btn = self.toggles[name]
	if btn then
		btn.Text = displayName .. ": " .. (state and "ON" or "OFF")

		if name == "lockFling" then
			btn.TextColor3 = state and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(255, 80, 80)
		else
			btn.TextColor3 = state and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 80, 80)
		end
	end
end

function TouchFling:UpdateKeybindButton()
	if self.toggles.keybindBtn then
		local keyName = self.clickTPKey and self.clickTPKey.Name or "None"
		self.toggles.keybindBtn.Text = "Click TP Key: " .. keyName
		self.toggles.keybindBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
	end
end

function TouchFling:SelectPlayer(player)
	self.selectedPlayer = player
	for plr, btn in pairs(self.buttons) do
		if btn and btn.Parent then
			btn.BackgroundColor3 = (plr == player) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 50)
		end
	end
end

function TouchFling:ToggleMinimize()
	if not self.mainFrame then return end
	local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	if self.mainFrame.Size.Y.Offset > 100 then
		TweenService:Create(self.mainFrame, tweenInfo, {Size = UDim2.new(0, 300, 0, 40)}):Play()
		for _, obj in pairs(self.mainFrame:GetDescendants()) do
			if obj:IsA("TextButton") and obj.Name ~= "MinimizeBtn" and obj.Name ~= "CloseBtn" then
				TweenService:Create(obj, tweenInfo, {TextTransparency = 1}):Play()
			elseif obj:IsA("TextLabel") and obj.Name ~= "Title" then
				TweenService:Create(obj, tweenInfo, {TextTransparency = 1}):Play()
			elseif obj:IsA("ScrollingFrame") then
				TweenService:Create(obj, tweenInfo, {BackgroundTransparency = 1}):Play()
			end
		end
	else
		TweenService:Create(self.mainFrame, tweenInfo, {Size = UDim2.new(0, 300, 0, 500)}):Play()
		for _, obj in pairs(self.mainFrame:GetDescendants()) do
			if obj:IsA("TextButton") and obj.Name ~= "MinimizeBtn" and obj.Name ~= "CloseBtn" then
				TweenService:Create(obj, tweenInfo, {TextTransparency = 0}):Play()
			elseif obj:IsA("TextLabel") then
				TweenService:Create(obj, tweenInfo, {TextTransparency = obj.Name == "Watermark" and 0.5 or 0}):Play()
			elseif obj:IsA("ScrollingFrame") then
				TweenService:Create(obj, tweenInfo, {BackgroundTransparency = 0.7}):Play()
			end
		end
	end
end

function TouchFling:StartKeySelection()
	if self.isSelectingKey then return end
	self.isSelectingKey = true

	if self.toggles.keybindBtn then
		self.toggles.keybindBtn.Text = "Press any key..."
		self.toggles.keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
	end

	-- One-time connection for next input
	local connection
	connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Accept keyboard keys and mouse buttons
		if input.UserInputType == Enum.UserInputType.Keyboard then
			self.clickTPKey = input.KeyCode
			connection:Disconnect()
			self.isSelectingKey = false
			self:UpdateKeybindButton()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.clickTPKey = "MouseButton1"
			connection:Disconnect()
			self.isSelectingKey = false
			self:UpdateKeybindButton()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.clickTPKey = "MouseButton2"
			connection:Disconnect()
			self.isSelectingKey = false
			self:UpdateKeybindButton()
		end
	end)
end

function TouchFling:CreateGUI()
	if self.gui then 
		self.gui.Enabled = true
		return 
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "LunarTouchFling"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = client:WaitForChild("PlayerGui")
	self.gui = ScreenGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "Main"
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	MainFrame.BorderSizePixel = 0
	MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
	MainFrame.Size = UDim2.new(0, 300, 0, 540) -- Increased height for keybind button
	MainFrame.Active = true
	MainFrame.Draggable = true
	MainFrame.ClipsDescendants = true
	self.mainFrame = MainFrame

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = MainFrame

	local UIGradient = Instance.new("UIGradient")
	UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(30,30,50)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,20))}
	UIGradient.Rotation = 90
	UIGradient.Parent = MainFrame

	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Parent = MainFrame
	TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	TopBar.BorderSizePixel = 0
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	TopBar.Active = true

	local TopCorner = Instance.new("UICorner")
	TopCorner.CornerRadius = UDim.new(0, 12)
	TopCorner.Parent = TopBar

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Parent = TopBar
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.Size = UDim2.new(0.6, 0, 1, 0)
	Title.Font = Enum.Font.GothamBold
	Title.Text = "Touch Fling"
	Title.TextColor3 = Color3.fromRGB(180, 220, 255)
	Title.TextSize = 22
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local MinimizeBtn = Instance.new("TextButton")
	MinimizeBtn.Name = "MinimizeBtn"
	MinimizeBtn.Parent = TopBar
	MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -12)
	MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
	MinimizeBtn.Font = Enum.Font.GothamBold
	MinimizeBtn.Text = "-"
	MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
	MinimizeBtn.TextSize = 20
	local MinCorner = Instance.new("UICorner")
	MinCorner.CornerRadius = UDim.new(0, 8)
	MinCorner.Parent = MinimizeBtn

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "CloseBtn"
	CloseBtn.Parent = TopBar
	CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
	CloseBtn.Position = UDim2.new(1, -36, 0.5, -12)
	CloseBtn.Size = UDim2.new(0, 28, 0, 28)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = Color3.new(1, 1, 1)
	CloseBtn.TextSize = 18
	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 8)
	CloseCorner.Parent = CloseBtn

	CloseBtn.MouseButton1Click:Connect(function()
		self.gui:Destroy()
		self.gui = nil
		self.mainFrame = nil
		self.toggles = {}
		self.buttons = {}
		self.enabled = false
		self.flingAll = false
		self.lockFling = false
		self.clickTP = false
		self.oneTimeTP = false
		self.selectedPlayer = nil
	end)

	MinimizeBtn.MouseButton1Click:Connect(function()
		self:ToggleMinimize()
	end)

	local function makeToggle(y, text, name)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Parent = MainFrame
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		btn.Position = UDim2.new(0.1, 0, y, 0)
		btn.Size = UDim2.new(0.8, 0, 0, 38)
		btn.Font = Enum.Font.GothamSemibold
		btn.Text = text .. ": OFF"
		btn.TextColor3 = Color3.fromRGB(255, 80, 80)
		btn.TextSize = 13
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 10)
		c.Parent = btn
		return btn
	end

	self.toggles.enabled = makeToggle(0.09, "Touch Fling", "TouchFling")
	self.toggles.flingAll = makeToggle(0.18, "Fling All (wip)", "FlingAll")
	self.toggles.lockFling = makeToggle(0.27, "Lock Fling", "LockFling")
	self.toggles.clickTP = makeToggle(0.36, "Click TP", "ClickTP")
	self.toggles.oneTimeTP = makeToggle(0.45, "One-Time TP", "OneTimeTP")

	-- Keybind Selector Button (NEW)
	self.toggles.keybindBtn = Instance.new("TextButton")
	self.toggles.keybindBtn.Name = "KeybindBtn"
	self.toggles.keybindBtn.Parent = MainFrame
	self.toggles.keybindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
	self.toggles.keybindBtn.Position = UDim2.new(0.1, 0, 0.54, 0)
	self.toggles.keybindBtn.Size = UDim2.new(0.8, 0, 0, 38)
	self.toggles.keybindBtn.Font = Enum.Font.GothamSemibold
	self.toggles.keybindBtn.Text = "Click TP Key: E"
	self.toggles.keybindBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
	self.toggles.keybindBtn.TextSize = 13
	local kbCorner = Instance.new("UICorner")
	kbCorner.CornerRadius = UDim.new(0, 10)
	kbCorner.Parent = self.toggles.keybindBtn

	-- Toggle Click Handlers
	self.toggles.enabled.MouseButton1Click:Connect(function()
		self.enabled = not self.enabled
		self:UpdateToggle("enabled", "Touch Fling")
	end)

	self.toggles.flingAll.MouseButton1Click:Connect(function()
		self.flingAll = not self.flingAll
		self:UpdateToggle("flingAll", "Fling All (wip)")
	end)

	self.toggles.lockFling.MouseButton1Click:Connect(function()
		self.lockFling = not self.lockFling
		self:UpdateToggle("lockFling", "Lock Fling")
	end)

	self.toggles.clickTP.MouseButton1Click:Connect(function()
		self.clickTP = not self.clickTP
		self:UpdateToggle("clickTP", "Click TP")
	end)

	self.toggles.oneTimeTP.MouseButton1Click:Connect(function()
		self.oneTimeTP = not self.oneTimeTP
		self:UpdateToggle("oneTimeTP", "One-Time TP")
	end)

	-- Keybind Button Handler
	self.toggles.keybindBtn.MouseButton1Click:Connect(function()
		self:StartKeySelection()
	end)

	-- Player List Label (moved down)
	local ListLabel = Instance.new("TextLabel")
	ListLabel.Name = "ListLabel"
	ListLabel.Parent = MainFrame
	ListLabel.BackgroundTransparency = 1
	ListLabel.Position = UDim2.new(0.1, 0, 0.64, 0)
	ListLabel.Size = UDim2.new(0.8, 0, 0, 20)
	ListLabel.Font = Enum.Font.GothamSemibold
	ListLabel.Text = "Select Player"
	ListLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
	ListLabel.TextSize = 14

	-- Player Scroll (moved down)
	local Scroll = Instance.new("ScrollingFrame")
	Scroll.Name = "PlayerScroll"
	Scroll.Parent = MainFrame
	Scroll.Position = UDim2.new(0.1, 0, 0.69, 0)
	Scroll.Size = UDim2.new(0.8, 0, 0, 120)
	Scroll.BackgroundTransparency = 0.7
	Scroll.ScrollBarThickness = 4
	local sc = Instance.new("UICorner")
	sc.CornerRadius = UDim.new(0, 8)
	sc.Parent = Scroll

	local UIList = Instance.new("UIListLayout")
	UIList.Parent = Scroll
	UIList.Padding = UDim.new(0, 4)

	local Watermark = Instance.new("TextLabel")
	Watermark.Name = "Watermark"
	Watermark.Parent = MainFrame
	Watermark.BackgroundTransparency = 1
	Watermark.Position = UDim2.new(0.05, 0, 0.94, 0)
	Watermark.Size = UDim2.new(0.9, 0, 0, 18)
	Watermark.Font = Enum.Font.Gotham
	Watermark.Text = "https://discord.gg/5GeQAXYYcW"
	Watermark.TextColor3 = Color3.fromRGB(120, 180, 255)
	Watermark.TextSize = 13
	Watermark.TextTransparency = 0.5

	local function refreshList()
		for plr, btn in pairs(self.buttons) do
			if not plr.Parent then 
				btn:Destroy()
				self.buttons[plr] = nil 
			end
		end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= client and not self.buttons[plr] then
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, -8, 0, 32)
				btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
				btn.Text = plr.Name
				btn.TextColor3 = Color3.new(1, 1, 1)
				btn.Font = Enum.Font.GothamSemibold
				btn.TextSize = 16
				btn.Parent = Scroll
				local c = Instance.new("UICorner")
				c.CornerRadius = UDim.new(0, 8)
				c.Parent = btn

				btn.MouseButton1Click:Connect(function()
					self:SelectPlayer(plr)
				end)

				self.buttons[plr] = btn
			end
		end

		Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
	end

	Players.PlayerAdded:Connect(refreshList)
	Players.PlayerRemoving:Connect(refreshList)
	refreshList()
end

-- Click TP with Keybind (NEW SYSTEM)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not TouchFling.clickTP then return end

	local keyMatched = false

	if TouchFling.clickTPKey == "MouseButton1" and input.UserInputType == Enum.UserInputType.MouseButton1 then
		keyMatched = true
	elseif TouchFling.clickTPKey == "MouseButton2" and input.UserInputType == Enum.UserInputType.MouseButton2 then
		keyMatched = true
	elseif input.KeyCode == TouchFling.clickTPKey then
		keyMatched = true
	end

	if keyMatched and Mouse.Target then
		local myRoot = client.Character and client.Character:FindFirstChild("HumanoidRootPart")
		if myRoot then
			myRoot.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
		end
	end
end)

-- Remove old Mouse.Button1Down connection for clickTP
-- (The new UserInputService connection above handles it)

-- Main Loop
RunService.Heartbeat:Connect(function()
	if TouchFling.enabled then
		local char = client.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local old = hrp.Velocity
				hrp.Velocity = old * 12000 + Vector3.new(0, 14000, 0)
				RunService.RenderStepped:Wait()
				if hrp.Parent then hrp.Velocity = old end
				RunService.Stepped:Wait()
				if hrp.Parent then 
					hrp.Velocity = old + Vector3.new(0, TouchFling.movel * 2, 0)
					TouchFling.movel = -TouchFling.movel 
				end
			end
		end
	end

	if TouchFling.flingAll then
		local myRoot = client.Character and client.Character:FindFirstChild("HumanoidRootPart")
		if myRoot then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= client and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local t = plr.Character.HumanoidRootPart
					if (myRoot.Position - t.Position).Magnitude < 15 then
						t.AssemblyLinearVelocity = Vector3.new(
							math.random(-6000, 6000),
							2200 + math.random(0, 800),
							math.random(-6000, 6000)
						)
					end
				end
			end
		end
	end

	if TouchFling.lockFling and TouchFling.selectedPlayer and TouchFling.selectedPlayer.Character then
		local myRoot = client.Character and client.Character:FindFirstChild("HumanoidRootPart")
		local tRoot = TouchFling.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")

		if myRoot and tRoot then
			myRoot.CFrame = tRoot.CFrame

			local oldVel = tRoot.Velocity
			tRoot.Velocity = oldVel * 12000 + Vector3.new(0, 16000, 0)
			RunService.RenderStepped:Wait()
			if tRoot.Parent then tRoot.Velocity = oldVel end
			RunService.Stepped:Wait()
			if tRoot.Parent then
				tRoot.Velocity = oldVel + Vector3.new(0, TouchFling.movel * 3, 0)
				TouchFling.movel = -TouchFling.movel
			end
		end
	end

	if TouchFling.oneTimeTP and TouchFling.selectedPlayer and TouchFling.selectedPlayer.Character then
		local myRoot = client.Character and client.Character:FindFirstChild("HumanoidRootPart")
		local tRoot = TouchFling.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if myRoot and tRoot then
			myRoot.CFrame = tRoot.CFrame
		end
	end
end)
------------------------------------------------
-- Rejoin
------------------------------------------------
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function rejoin()
	-- Optional: show a little notification (if you have a notify function already)
	notify("🔄 Rejoining same server...", Color3.fromRGB(100, 200, 255))

	-- This rejoins **exactly** the current server (using current JobId)
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end
------------------------------------------------
-- Ping
------------------------------------------------
local function ping()
	local ping = math.round(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
	local color = ping < 100 and Color3.fromRGB(100, 255, 100) or (ping < 200 and Color3.fromRGB(255, 255, 100) or Color3.fromRGB(255, 100, 100))
	notify("📶 Ping: " .. ping .. "ms", color)
end
------------------------------------------------
-- ClickTP
------------------------------------------------
local clickTPconn
local function clickTP()
	if clickTPconn then
		clickTPconn:Disconnect()
		clickTPconn = nil
		notify("⚠️Click TP disabled", Color3.fromRGB(255, 120, 100))
	else
		clickTPconn = Mouse.Button1Down:Connect(function()
			if Mouse.Target then
				local hrp = getHRP(client)
				if hrp then
					hrp.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
				end
			end
		end)
		notify("Click TP enabled - click anywhere to teleport", Color3.fromRGB(100, 255, 120))
	end
end
------------------------------------------------
-- FOV
------------------------------------------------
local function setFov(val)
	local num = tonumber(val)
	if num and num >= 1 and num <= 120 then
		workspace.CurrentCamera.FieldOfView = num
		notify("FOV set to " .. num, currentTheme.accent)
	else
		notify("❌ Invalid FOV (1-120)", Color3.fromRGB(255, 100, 100))
	end
end
------------------------------------------------
-- kick
------------------------------------------------
local function kick(plr)
	if plr == client then
		client:Kick("Kicked via Lunar Admin")
	else
		notify("⚠️ Kick only works on yourself (client-side)", Color3.fromRGB(255, 170, 0))
	end
end
------------------------------------------------
-- ragdoll
------------------------------------------------
local function ragdoll(plr)
	if plr ~= client then
		notify("❌ Ragdoll only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	local char = plr.Character
	if not char then 
		notify("❌ No character to ragdoll", Color3.fromRGB(255, 100, 100))
		return 
	end
	local hum = getHum(plr)
	hum:ChangeState(Enum.HumanoidStateType.Physics)
	hum.PlatformStand = true
	local joints = {}
	for _, v in char:GetDescendants() do
		if v:IsA("Motor6D") then
			v.Enabled = false
			table.insert(joints, v)
		end
	end
	ragdolls[plr] = joints
	notify("Ragdolled", Color3.fromRGB(200, 100, 100))
end
------------------------------------------------
-- unragdoll
------------------------------------------------
local function unragdoll(plr)
	if plr ~= client then
		notify("❌ Unragdoll only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	local joints = ragdolls[plr]
	if not joints then 
		notify("⚠️ Not ragdolled", Color3.fromRGB(255, 200, 100))
		return 
	end
	for _, v in ipairs(joints) do v.Enabled = true end
	local hum = getHum(plr)
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		hum.PlatformStand = false
	end
	ragdolls[plr] = nil
	notify("Unragdolled", Color3.fromRGB(100, 200, 100))
end
------------------------------------------------
-- console
------------------------------------------------
local function console()
	StarterGui:SetCore("DevConsoleVisible", true)
	notify("Console opened", Color3.fromRGB(180, 180, 255))
end
------------------------------------------------
-- disable fall damage
------------------------------------------------
local function disableFallDamage()
	local conn = client.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		end
	end)
	notify("⚠️THIS DOES NOT WORK⚠️", Color3.fromRGB(100, 255, 180))
end
------------------------------------------------
-- enable inventory
------------------------------------------------
local function enableCore(name)
	local enum
	if name == "inventory" then enum = Enum.CoreGuiType.Backpack
	elseif name == "playerlist" then enum = Enum.CoreGuiType.PlayerList
	else 
		notify("❌ Unknown core GUI: " .. tostring(name), Color3.fromRGB(255, 100, 100))
		return 
	end
	local current = StarterGui:GetCoreGuiEnabled(enum)
	StarterGui:SetCoreGuiEnabled(enum, not current)
	notify("✅ " .. name:gsub("^%l", string.upper) .. (not current and " enabled" or " disabled"), Color3.fromRGB(180, 180, 255))
end
------------------------------------------------
-- Dance
------------------------------------------------
local function dance(plr, number)
	if plr ~= client then
		notify("❌ Dance only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end

	local hum = getHum(plr)
	if not hum then
		notify("❌ No humanoid found", Color3.fromRGB(255, 100, 100))
		return
	end

	-- Default to random dance if no number is given
	if not number then
		number = math.random(1, 3)
	else
		number = tonumber(number) or 1
		number = math.clamp(number, 1, 3)  -- Only 1, 2, or 3 are valid
	end

	-- Roblox default dance animation IDs
	local danceIds = {
		[1] = "rbxassetid://507771019",   -- Dance 1 (the one you had)
		[2] = "rbxassetid://507776043",   -- Dance 2
		[3] = "rbxassetid://507777268"    -- Dance 3
	}

	local anim = Instance.new("Animation")
	anim.AnimationId = danceIds[number]

	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

	-- Stop any existing dance animation first (prevents stacking)
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track.Animation.AnimationId:find("50777") then  -- stops previous dances
			track:Stop()
		end
	end

	local track = animator:LoadAnimation(anim)
	track:Play()

	notify("Dancing " .. number, Color3.fromRGB(255, 100, 255))
end
------------------------------------------------
-- trip
------------------------------------------------
local function trip(plr)
	if plr ~= client then
		notify("❌ Trip only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	local hum = getHum(plr)
	if hum then
		hum.Sit = true
		hum.Jump = true
		notify("Tripped", Color3.fromRGB(255, 180, 100))
	end
end

------------------------------------
-- explode 
------------------------------------

local function explode(plr)
	local char = plr.Character
	if not char then
		notify("❌ No character found", Color3.fromRGB(255, 100, 100))
		return
	end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root or humanoid.Health <= 0 then
		notify("❌ Cannot explode - invalid or already dead", Color3.fromRGB(255, 100, 100))
		return
	end

	-- Step 1: Create a big visible explosion for everyone
	local explosion = Instance.new("Explosion")
	explosion.Position = root.Position
	explosion.BlastRadius = 12           -- decent size
	explosion.BlastPressure = 500000     -- strong visual push
	explosion.DestroyJointRadiusPercent = 0  -- don't auto-break joints (we do it manually)
	explosion.Parent = workspace

	-- Step 2: Force death + ragdoll (kills you and makes physics take over)
	humanoid.Health = 0
	humanoid:ChangeState(Enum.HumanoidStateType.Dead)

	-- Step 3: Detach limbs visibly (breaks Motor6D joints → parts fly apart)
	-- This is what makes limbs scatter like an explosion
	for _, motor in ipairs(char:GetDescendants()) do
		if motor:IsA("Motor6D") and motor.Part1 and motor.Part0 then
			-- Create a BallSocketConstraint or just break the joint
			-- Option A: Simple break (most games let this replicate)
			motor.Enabled = false

			-- Option B: Replace with BallSocket + NoCollision for flying parts (more dramatic)
			local socket = Instance.new("BallSocketConstraint")
			socket.Attachment0 = Instance.new("Attachment", motor.Part0)
			socket.Attachment1 = Instance.new("Attachment", motor.Part1)
			socket.LimitsEnabled = false
			socket.Parent = motor.Part0

			-- Optional: Give random velocity to make limbs fly farther
			if motor.Part1:IsA("BasePart") then
				motor.Part1.Velocity = Vector3.new(
					math.random(-80,80),
					math.random(60,140),
					math.random(-80,80)
				)
				motor.Part1.RotVelocity = Vector3.new(
					math.random(-10,10),
					math.random(-10,10),
					math.random(-10,10)
				)
			end
		end
	end

	-- Step 4: Extra ragdoll physics boost (makes body flop/scatter more)
	if root then
		root.Velocity = Vector3.new(0, 80, 0)  -- upward kick
		root.AssemblyLinearVelocity = Vector3.new(
			math.random(-60,60),
			math.random(40,100),
			math.random(-60,60)
		)
	end

	-- Optional: Hide head or make dramatic (some games detect head removal)
	local head = char:FindFirstChild("Head")
	if head then
		head.Transparency = 0.3  -- slight fade or leave visible
		head.Velocity = Vector3.new(math.random(-50,50), 100, math.random(-50,50))
	end

	notify("Exploded! Limbs detached & scattered", Color3.fromRGB(255, 60, 60))
end

------------------------------------------------
-- rainbow
------------------------------------------------
local function rainbow(plr)
	if plr ~= client then
		notify("❌ Rainbow only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	if rainbowData[plr] then 
		notify("⚠️ Already rainbow", Color3.fromRGB(255, 200, 100))
		return 
	end
	local char = plr.Character
	if not char then 
		notify("❌ No character for rainbow", Color3.fromRGB(255, 100, 100))
		return 
	end
	local conn = RunService.Heartbeat:Connect(function()
		local hue = tick() % 5 / 5
		local c = Color3.fromHSV(hue, 1, 1)
		for _, part in char:GetDescendants() do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Color = c
			end
		end
	end)
	rainbowData[plr] = conn
	notify("Rainbow ON", Color3.fromRGB(255, 100, 255))
end
------------------------------------------------
-- unrainbow
------------------------------------------------
local function unrainbow(plr)
	if plr ~= client then
		notify("Unrainbow only works on yourself", Color3.fromRGB(255, 100, 100))
		return
	end
	if rainbowData[plr] then
		rainbowData[plr]:Disconnect()
		rainbowData[plr] = nil
		notify("Rainbow OFF", Color3.fromRGB(200, 100, 200))
	else
		notify("⚠️ Not in rainbow mode", Color3.fromRGB(255, 200, 100))
	end
end
------------------------------------------------
-- fire
------------------------------------------------
local function fire(plr)
	local hrp = getHRP(plr)
	if hrp and not hrp:FindFirstChild("Fire") then
		local f = Instance.new("Fire", hrp)
		f.Size = 10
		f.Heat = 25
		notify("On fire", Color3.fromRGB(255, 100, 0))
	else
		notify("⚠️ Already on fire or no character", Color3.fromRGB(255, 200, 100))
	end
end
------------------------------------------------
-- unfire
------------------------------------------------
local function unfire(plr)
	local hrp = getHRP(plr)
	if hrp then
		local f = hrp:FindFirstChild("Fire")
		if f then 
			f:Destroy() 
			notify("Fire off", Color3.fromRGB(200, 100, 0))
		else
			notify("Not on fire", Color3.fromRGB(255, 200, 100))
		end
	end
end
------------------------------------------------
-- first person/thrid person
------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local client = Players.LocalPlayer  -- assuming 'client' is LocalPlayer in your script

local function thirdp()
	-- Step 1: Switch to Classic mode (allows zooming)
	client.CameraMode = Enum.CameraMode.Classic

	-- Step 2: Temporarily force a zoom-out to exit first person reliably
	-- (Roblox camera won't exit FP just by setting Classic if already zoomed in)
	local originalMinZoom = client.CameraMinZoomDistance
	client.CameraMinZoomDistance = 10  -- or higher, forces zoom out
	client.CameraMaxZoomDistance = 400

	-- Wait one frame so the camera module processes the change and zooms out
	RunService.RenderStepped:Wait()  -- or task.wait(0.03) if you prefer

	-- Step 3: Restore normal min zoom (so player can zoom in again if they want)
	client.CameraMinZoomDistance = originalMinZoom  -- or set to 0.5 if you want tight zoom allowed

	-- Step 4: Fix "invisible to self" glitch
	-- Roblox sets LocalTransparencyModifier = 1 on parts in FP; doesn't always reset
	local character = client.Character
	if character then
		for _, obj in ipairs(character:GetDescendants()) do
			if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
				obj.LocalTransparencyModifier = 0
			end
		end

		-- Optional: If head/face is still hidden, force it visible too
		local head = character:FindFirstChild("Head")
		if head then
			head.LocalTransparencyModifier = 0
		end
	end

	-- Optional: Re-focus camera on your humanoid to snap back cleanly
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
	end

	notify("Third person enabled (forced zoom out + visibility fix)", currentTheme.accent)
end

local function firstp()
	client.CameraMode = Enum.CameraMode.LockFirstPerson
	notify("First person enabled", currentTheme.accent)
end
------------------------------------------------
-- advanced Waypoint
------------------------------------------------
local function waypoint()
	local num = #waypoints + 1
	local wp = Instance.new("Part")
	wp.Size = Vector3.new(1,1,1)
	wp.Transparency = 1
	wp.Anchored = true
	wp.CanCollide = false
	wp.Position = hrp.Position + Vector3.new(0, 5, 0)
	wp.Parent = workspace
	local bb = Instance.new("BillboardGui")
	bb.Adornee = wp
	bb.Size = UDim2.new(0, 100, 0, 100)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = true
	bb.Parent = wp
	local symbol = Instance.new("TextLabel", bb)
	symbol.Size = UDim2.new(1,0,0.5,0)
	symbol.BackgroundTransparency = 1
	symbol.Text = "★"
	symbol.Font = Enum.Font.GothamBlack
	symbol.TextSize = 40
	symbol.TextColor3 = Color3.new(1,1,1)
	symbol.TextStrokeTransparency = 0
	symbol.TextStrokeColor3 = Color3.new(0,0,0)
	local distLabel = Instance.new("TextLabel", bb)
	distLabel.Size = UDim2.new(1,0,0.5,0)
	distLabel.Position = UDim2.new(0,0,0.5,0)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = "0 studs"
	distLabel.Font = Enum.Font.Gotham
	distLabel.TextSize = 18
	distLabel.TextColor3 = Color3.new(1,1,1)
	distLabel.TextStrokeTransparency = 0.5
	local conn = RunService.Heartbeat:Connect(function()
		if not wp.Parent then conn:Disconnect() return end
		local dist = (hrp.Position - wp.Position).Magnitude
		distLabel.Text = math.floor(dist) .. " studs"
	end)
	table.insert(waypoints, {part = wp, conn = conn})
	notify("Waypoint #" .. num .. " added", currentTheme.accent)
end

------------------------------------------------
-- advanced tracers
------------------------------------------------

local tracerSystem = {
	enabled = false,
	players = {},
	beams = {} -- Track all beams for cleanup
}

-- Thinner, better looking tracers
local TRACER_SETTINGS = {
	width0 = 0.05,        -- Much thinner (was 0.2)
	width1 = 0.02,        -- Taper to point
	transparency = 0.15,   -- More visible (was 0.3)
	brightness = 2,      -- Neon glow effect
	texture = "rbxassetid://7151778302", -- Optional: thin line texture
	textureLength = 1,
	textureMode = Enum.TextureMode.Stretch
}

local function getMyHRP()
	if client.Character then
		return client.Character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function getTracerColor(plr)
	if not client.Team or not plr.Team then
		return Color3.fromRGB(200, 200, 255) -- Soft white/blue if no team
	end

	if plr.Team == client.Team then
		return Color3.fromRGB(0, 255, 150)   -- Bright green for friendly
	else
		return Color3.fromRGB(255, 50, 50)   -- Bright red for enemy
	end
end

local function clearPlayer(plr)
	local data = tracerSystem.players[plr]
	if not data then return end

	if data.beam then 
		data.beam:Destroy() 
	end
	if data.att0 then 
		data.att0:Destroy() 
	end
	if data.att1 then 
		data.att1:Destroy() 
	end

	for _, conn in ipairs(data.connections or {}) do
		conn:Disconnect()
	end

	tracerSystem.players[plr] = nil
end

local function clearAllTracers()
	for plr, _ in pairs(tracerSystem.players) do
		clearPlayer(plr)
	end
	tracerSystem.players = {}
	tracerSystem.enabled = false
end

local function createBeam(att0, att1, color)
	local beam = Instance.new("Beam")
	beam.Width0 = TRACER_SETTINGS.width0
	beam.Width1 = TRACER_SETTINGS.width1
	beam.Transparency = NumberSequence.new(TRACER_SETTINGS.transparency)
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(color)
	beam.LightEmission = TRACER_SETTINGS.brightness
	beam.LightInfluence = 0
	beam.Segments = 1
	beam.ZOffset = 0

	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Parent = workspace.Terrain -- Use Terrain instead of workspace for cleaner hierarchy

	return beam
end

local function attachTracer(plr, char)
	if not tracerSystem.enabled then return end
	if plr == client then return end

	local myHRP = getMyHRP()
	if not myHRP then return end

	local enemyHRP = char:WaitForChild("HumanoidRootPart", 10)
	if not enemyHRP then return end

	-- Clear existing first
	clearPlayer(plr)

	local data = { connections = {} }
	tracerSystem.players[plr] = data

	-- Create attachments
	local att0 = Instance.new("Attachment")
	att0.Name = "TracerAtt0_" .. plr.Name
	att0.Parent = myHRP
	att0.WorldPosition = myHRP.Position

	local att1 = Instance.new("Attachment")
	att1.Name = "TracerAtt1_" .. plr.Name
	att1.Parent = enemyHRP
	att1.WorldPosition = enemyHRP.Position

	-- Create beam with improved visuals
	local beam = createBeam(att0, att1, getTracerColor(plr))

	data.beam = beam
	data.att0 = att0
	data.att1 = att1

	-- Update color if THEY change team
	table.insert(data.connections,
		plr:GetPropertyChangedSignal("Team"):Connect(function()
			if data.beam then
				data.beam.Color = ColorSequence.new(getTracerColor(plr))
			end
		end)
	)

	-- Update color if YOU change team
	table.insert(data.connections,
		client:GetPropertyChangedSignal("Team"):Connect(function()
			if data.beam then
				data.beam.Color = ColorSequence.new(getTracerColor(plr))
			end
		end)
	)

	-- Handle THEIR respawn
	table.insert(data.connections,
		plr.CharacterAdded:Connect(function(newChar)
			task.wait(0.3)
			attachTracer(plr, newChar)
		end)
	)

	-- Handle THEIR death (remove beam until respawn)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		table.insert(data.connections,
			humanoid.Died:Connect(function()
				clearPlayer(plr)
			end)
		)
	end
end

-- Main enable/disable functions
function tracerSystem:Enable()
	if self.enabled then return end
	self.enabled = true

	-- Attach to all existing players
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= client and plr.Character then
			task.spawn(function()
				attachTracer(plr, plr.Character)
			end)
		end
	end

	-- Listen for new players
	self.playerAddedConn = Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function(char)
			task.wait(0.2)
			if self.enabled then
				attachTracer(plr, char)
			end
		end)
	end)

	-- Clean up when players leave
	self.playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
		clearPlayer(plr)
	end)

	-- Update our position when we respawn
	self.charAddedConn = client.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		if not self.enabled then return end

		-- Reattach all tracers to new character
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= client and plr.Character then
				task.spawn(function()
					attachTracer(plr, plr.Character)
				end)
			end
		end
	end)

	-- Constant update loop for smooth positioning
	self.updateLoop = RunService.Heartbeat:Connect(function()
		if not self.enabled then return end

		local myHRP = getMyHRP()
		if not myHRP then return end

		for plr, data in pairs(self.players) do
			if data.att0 and data.att0.Parent then
				data.att0.WorldPosition = myHRP.Position
			end
		end
	end)
end

function tracerSystem:Disable()
	if not self.enabled then return end
	self.enabled = false

	-- Disconnect all connections
	if self.playerAddedConn then self.playerAddedConn:Disconnect() end
	if self.playerRemovingConn then self.playerRemovingConn:Disconnect() end
	if self.charAddedConn then self.charAddedConn:Disconnect() end
	if self.updateLoop then self.updateLoop:Disconnect() end

	-- Clear all tracers
	clearAllTracers()
end

function tracerSystem:Toggle()
	if self.enabled then
		self:Disable()
		return false
	else
		self:Enable()
		return true
	end
end

----------------------------------------------------
-- CREATE FOR PLAYER
----------------------------------------------------
local function createForPlayer(plr)
	if plr == client then return end
	if tracerSystem.players[plr] then return end

	if plr.Character then
		attachTracer(plr, plr.Character)
	end
end

----------------------------------------------------
-- ENABLE
----------------------------------------------------
function enableTracers()

	if tracerSystem.enabled then return end
	tracerSystem.enabled = true

	-- existing players
	for _,plr in ipairs(Players:GetPlayers()) do
		createForPlayer(plr)
	end

	-- new players
	table.insert(tracerSystem.connections,
		Players.PlayerAdded:Connect(function(plr)
			if tracerSystem.enabled then
				createForPlayer(plr)
			end
		end)
	)

	-- cleanup on leave
	table.insert(tracerSystem.connections,
		Players.PlayerRemoving:Connect(function(plr)
			clearPlayer(plr)
		end)
	)

	-- YOU respawn → rebuild all
	table.insert(tracerSystem.connections,
		client.CharacterAdded:Connect(function()
			task.wait(0.3)

			for plr,_ in pairs(tracerSystem.players) do
				clearPlayer(plr)
			end

			for _,plr in ipairs(Players:GetPlayers()) do
				createForPlayer(plr)
			end
		end)
	)

	notify("Tracers enabled", currentTheme.accent)
end

----------------------------------------------------
-- DISABLE
----------------------------------------------------
function disableTracers()

	if not tracerSystem.enabled then return end
	tracerSystem.enabled = false

	for _,conn in ipairs(tracerSystem.connections) do
		conn:Disconnect()
	end
	tracerSystem.connections = {}

	for plr,_ in pairs(tracerSystem.players) do
		clearPlayer(plr)
	end

	tracerSystem.players = {}

	notify("❌ Tracers disabled", currentTheme.accent)
end
----------------------------------------------------
-- advanced Disable tracers
------------------------------------------------
local function disableTracers()
	tracersEnabled = false
	clearTracers()
	notify("❌ Tracers disabled", currentTheme.accent)
end

-- =============================================================
-- COMMAND PROCESSOR - DEFINED BEFORE USE
-- =============================================================
function processCmd(msg)
	if not msg or msg:sub(1,1) ~= prefix then return end
	
	local args = {}
	for word in msg:sub(2):gmatch("%S+") do
		table.insert(args, word)
	end
	
	local cmd = table.remove(args, 1):lower()
	local target = getPlr(args[1] or "me")

	notify(prefix .. cmd, Color3.fromRGB(180, 180, 255))

	if cmd == "aimbot" then
		createAimbotPanel()
		
	elseif cmd == "autoexec" then
		autoexecCommand()
		
	elseif cmd == "bring" then
		bring(target)
		
	elseif cmd == "clicktp" then
		clickTP()
		
	elseif cmd == "cmdbar" then
		toggleCmdBar()
		
	elseif cmd == "console" then
		console()
		
	elseif cmd == "crosshair" then
		LoadLunarCrosshair()
		
	elseif cmd == "dance" then
		dance(target)
		
	elseif cmd == "destroyscript" then
		destroyScript()
		
	elseif cmd == "disablefalldamage" then
		disableFallDamage()
-----------------------------------------------------------------  esp	-----------------------------------------------------------------
-----------------------------------------------------------------		-----------------------------------------------------------------
	elseif cmd == "enable" then
		local what = args[1] or ""
		if what == "inventory" or what == "playerlist" then
			enableCore(what)
		end

	elseif cmd == "esp" then
		if args[1] == "all" then 
			enableESPAll()
		else
			-- ESP specific player
			local target = getPlr(args[1] or "me")
			if target and target ~= client then
				enableESPPlayer(target)
			else
				notify("Usage: !esp all or !esp [player]", Color3.fromRGB(255, 200, 100))
			end
		end
		
	elseif cmd == "unesp" then
		if args[1] == "all" then 
			disableESPAll()
		else
			-- Remove ESP from specific player
			local target = getPlr(args[1] or "me")
			if target and target ~= client then
				disableESPPlayer(target)
			else
				notify("Usage: !unesp all or !unesp [player]", Color3.fromRGB(255, 200, 100))
			end
		end
-----------------------------------------------------------------  esp	-----------------------------------------------------------------
-----------------------------------------------------------------		-----------------------------------------------------------------
	elseif cmd == "explode" then
		explode(target)
		
	elseif cmd == "fire" then
		fire(target)
		
	elseif cmd == "firstp" then
		firstp()
		
	elseif cmd == "fling" then
		TouchFling:CreateGUI()
		StarterGui:SetCore("SendNotification", {
			Title = "Touch Fling", 
			Text = "GUI Opened", 
			Duration = 3
		})
		
	elseif cmd == "fly" then
		fly(target, args[2])
		
	elseif cmd == "freecam" then
		enableFreecam()
		
	elseif cmd == "freeze" then
		freeze(target)
		
	elseif cmd == "infjump" then
		enableInfJump()
		
	elseif cmd == "joinlogs" then
		createJoinLogsPanel()
		
	elseif cmd == "jump" then
		jump(client, args[1])
		
	elseif cmd == "kill" then
		if args[1] == "all" then 
			for _, p in ipairs(Players:GetPlayers()) do kill(p) end
		elseif args[1] == "me" then 
			kill(client)
		else 
			kill(target) 
		end
		
	elseif cmd == "lay" then
		lay(client)
		
	elseif cmd == "leave" then
		leaveGame()
		
	elseif cmd == "logs" then
		toggleLogs()
		
	elseif cmd == "noclip" then
		noclip(target)
		
	elseif cmd == "ping" then
		ping()
		
	elseif cmd == "ragdoll" then
		ragdoll(client)
		
	elseif cmd == "rainbow" then
		rainbow(target)
		
	elseif cmd == "rejoin" then
		rejoin()
		
	elseif cmd == "removewaypoint" then
		removeWaypoint()
		
	elseif cmd == "resetspeed" then
		resetspeed(target)
		
	elseif cmd == "sit" then
		sit(client)
		
	elseif cmd == "speed" then
		if args[1] == "me" then
			createSpeedPanel()
		else
			setspeed(target, args[2])
		end
		
	elseif cmd == "spin" then
		spin(client, args[1])
		
	elseif cmd == "stopwatch" then
		toggleStopwatch()
		
	elseif cmd == "thirdp" then
		thirdp()
		
	elseif cmd == "to" then
		gotoMe(target)
		
	elseif cmd == "trip" then
		trip(target)
		
	elseif cmd == "tracers" then
		tracerSystem:Enable()
		StarterGui:SetCore("SendNotification", {
			Title = "Tracers", 
			Text = "Enabled - Thin neon tracers active", 
			Duration = 3
		})
		
	elseif cmd == "unautoexec" then
		unautoexecCommand()
		
	elseif cmd == "add" then
   	 if args[1] == "all" then
        addAllFriends()
   	 else
        addFriend(args[1])
    	end

	elseif cmd == "unadd" then
    if args[1] == "all" then
        unaddAllFriends()
    else
        unaddFriend(args[1])
    end

	elseif cmd == "uncrosshair" then
		DisableLunarCrosshair()
		
	elseif cmd == "unfire" then
		unfire(target)
		
	elseif cmd == "unfling" then
		if TouchFling.gui then
			TouchFling.gui:Destroy()
			TouchFling.gui = nil
			TouchFling.mainFrame = nil
			TouchFling.toggles = {}
			TouchFling.buttons = {}
			TouchFling.enabled = false
			TouchFling.flingAll = false
			TouchFling.lockFling = false
			TouchFling.clickTP = false
			TouchFling.oneTimeTP = false
			TouchFling.selectedPlayer = nil
		end
		StarterGui:SetCore("SendNotification", {
			Title = "Touch Fling", 
			Text = "GUI Closed", 
			Duration = 3
		})
		
	elseif cmd == "unfly" then
		unfly(target)
		FlySystem:StopFly()
		
	elseif cmd == "unfreecam" then
		disableFreecam()

	elseif cmd == "sunglare" then
		enableSunGlare()
		
	elseif cmd == "unsunglare" then
		disableSunGlare()
		
	elseif cmd == "unfreeze" then
		unfreeze(target)
		
	elseif cmd == "uninfjump" then
		disableInfJump()
		
	elseif cmd == "unnoclip" then
		unnoclip(target)
		
	elseif cmd == "unragdoll" then
		unragdoll(client)
		
	elseif cmd == "unrainbow" then
		unrainbow(target)
		
	elseif cmd == "unspin" then
		unspin(client)
		
	elseif cmd == "untracers" then
		tracerSystem:Disable()
		StarterGui:SetCore("SendNotification", {
			Title = "Tracers", 
			Text = "Disabled - All tracers cleared", 
			Duration = 3
		})
		
	elseif cmd == "unview" then
		unview()
		
	elseif cmd == "view" then
		view(target)

	elseif cmd == "volume" then
		Volume(client, args)
		
	elseif cmd == "waypoint" then
		waypoint()
		
	elseif cmd == "fov" then
		setFov(args[1])
		
	elseif cmd == "kick" then
		kick(target)
		
	elseif cmd == "unlockmouse" then
		toggleMouseUnlock()
		
	else
		notify("❌ Unknown command: " .. cmd, Color3.fromRGB(255, 100, 100))
	end
end
-- =============================================================
-- Main Gui :3
-- =============================================================
lunarGui = Instance.new("ScreenGui")
lunarGui.Name = "LunarGui"
lunarGui.ResetOnSpawn = false
lunarGui.Enabled = false
lunarGui.DisplayOrder = 2147483646
lunarGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
lunarGui.ScreenInsets = Enum.ScreenInsets.None
lunarGui.IgnoreGuiInset = true
lunarGui.Parent = game:GetService("CoreGui")

mainFrame = Instance.new("Frame", lunarGui)
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 420, 0, 560)
mainFrame.Position = UDim2.new(1, -440, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 2147483647
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Top Bar
topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
topBar.BorderSizePixel = 0
topBar.ZIndex = 2147483647
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

-- Title
titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Lunar Hub"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 24
titleLabel.TextColor3 = currentTheme.accent
titleLabel.TextStrokeTransparency = 0.5
titleLabel.TextStrokeColor3 = Color3.new(0,0,0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 2147483647

-- Minimize Button
minBtn = Instance.new("TextButton", topBar)
minBtn.Name = "MinimizeBtn"
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -75, 0.5, -17.5)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minBtn.Text = "−"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 2147483647
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- Close Button
closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 2147483647
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
	lunarGui.Enabled = false
end)

-- Minimize functionality
local minimized = false
local origSize = mainFrame.Size
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		mainFrame:TweenSize(UDim2.new(0, 420, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		minBtn.Text = "+"
	else
		mainFrame:TweenSize(origSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		minBtn.Text = "−"
	end
end)

-- Resize Handle
resizeHandle = Instance.new("TextButton", mainFrame)
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.new(0, 20, 0, 20)
resizeHandle.Position = UDim2.new(1, -20, 1, -20)
resizeHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
resizeHandle.Text = "◢"
resizeHandle.Font = Enum.Font.GothamBold
resizeHandle.TextSize = 10
resizeHandle.TextColor3 = Color3.fromRGB(150, 150, 150)
resizeHandle.BorderSizePixel = 0
resizeHandle.AutoButtonColor = false
resizeHandle.Active = true
resizeHandle.ZIndex = 2147483647
Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 4)

-- Resize logic
local resizing = false
local startSize, startPos

resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		startSize = mainFrame.Size
		startPos = input.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local d = input.Position - startPos
		mainFrame.Size = UDim2.new(0, math.clamp(startSize.X.Offset + d.X, 320, 800), 0, math.clamp(startSize.Y.Offset + d.Y, 300, 700))
	end
end)

-- Tabs
tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, -20, 0, 40)
tabBar.Position = UDim2.new(0, 10, 0, 60)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 2147483647

cmdTab = Instance.new("TextButton", tabBar)
cmdTab.Name = "CmdTab"
cmdTab.Size = UDim2.new(0.5, -5, 1, 0)
cmdTab.BackgroundColor3 = currentTheme.accent
cmdTab.Text = "Commands"
cmdTab.Font = Enum.Font.GothamBold
cmdTab.TextSize = 16
cmdTab.TextColor3 = Color3.new(0,0,0)
cmdTab.BorderSizePixel = 0
cmdTab.ZIndex = 2147483647
Instance.new("UICorner", cmdTab).CornerRadius = UDim.new(0, 6)

setTab = Instance.new("TextButton", tabBar)
setTab.Name = "SetTab"
setTab.Size = UDim2.new(0.5, -5, 1, 0)
setTab.Position = UDim2.new(0.5, 5, 0, 0)
setTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
setTab.Text = "Settings"
setTab.Font = Enum.Font.GothamBold
setTab.TextSize = 16
setTab.TextColor3 = globalConfig.textColor
setTab.BorderSizePixel = 0
setTab.ZIndex = 2147483647
Instance.new("UICorner", setTab).CornerRadius = UDim.new(0, 6)

-- Content Container
contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 1, -110)
contentFrame.Position = UDim2.new(0, 10, 0, 110)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.ZIndex = 2147483647

-- ========== COMMANDS TAB ==========
cmdFrame = Instance.new("Frame", contentFrame)
cmdFrame.Name = "CmdFrame"
cmdFrame.Size = UDim2.new(1, 0, 1, 0)
cmdFrame.BackgroundTransparency = 1
cmdFrame.ZIndex = 2147483647

-- Search Bar
searchBar = Instance.new("Frame", cmdFrame)
searchBar.Size = UDim2.new(1, 0, 0, 38)
searchBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
searchBar.BorderSizePixel = 0
searchBar.ZIndex = 2147483647
Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 6)

searchIcon = Instance.new("TextLabel", searchBar)
searchIcon.Size = UDim2.new(0, 30, 1, 0)
searchIcon.Position = UDim2.new(0, 8, 0, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.Font = Enum.Font.Gotham
searchIcon.TextSize = 14
searchIcon.TextColor3 = Color3.fromRGB(120, 120, 130)
searchIcon.ZIndex = 2147483647

searchBox = Instance.new("TextBox", searchBar)
searchBox.Size = UDim2.new(1, -45, 1, 0)
searchBox.Position = UDim2.new(0, 38, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Search commands..."
searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 15
searchBox.TextColor3 = globalConfig.textColor
searchBox.TextStrokeTransparency = 0.5
searchBox.TextStrokeColor3 = Color3.new(0,0,0)
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 2147483647

-- Scroll Frame
cmdScroll = Instance.new("ScrollingFrame", cmdFrame)
cmdScroll.Size = UDim2.new(1, 0, 1, -48)
cmdScroll.Position = UDim2.new(0, 0, 0, 48)
cmdScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
cmdScroll.BorderSizePixel = 0
cmdScroll.ScrollBarThickness = 6
cmdScroll.ScrollBarImageColor3 = currentTheme.accent
cmdScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
cmdScroll.ZIndex = 2147483647
Instance.new("UICorner", cmdScroll).CornerRadius = UDim.new(0, 6)

cmdList = Instance.new("UIListLayout", cmdScroll)
cmdList.Padding = UDim.new(0, 6)
cmdList.SortOrder = Enum.SortOrder.LayoutOrder

-- Command data in tables (no locals for each)
cmdDesc = {
	["!aimbot"] = "Opens aimbot control panel", ["!autoexec"] = "Enables auto-run on join",
	["!clicktp"] = "Click to teleport", ["!cmdbar"] = "Toggle command bar",
	["!console"] = "Opens dev console", ["!crosshair"] = "Loads custom crosshair",
	["!dance [plr]"] = "Makes player dance", ["!destroyscript"] = "Removes all UI/scripts",
	["!disablefalldamage"] = "WIP", ["!enable inventory"] = "Toggle backpack",
	["!enable playerlist"] = "Toggle player list", ["!esp [plr/all]"] = "Enable esp on player or all",
	["!explode [plr]"] = "Explodes player", ["!fire [plr]"] = "Sets player on fire",
	["!firstp"] = "First person mode", ["!fling"] = "Opens fling GUI",
	["!fly"] = "Opens fly panel", ["!flyspeed [num]"] = "Set fly speed",
	["!freecam"] = "Free camera mode", ["!freeze [plr]"] = "Freezes player",
	["!infjump"] = "Infinite jump toggle", ["!joinlogs"] = "Show join/leave logs",
	["!jump [power]"] = "Set jump power", ["!kill [plr/all/me]"] = "Kill player/self/all",
	["!lay"] = "Makes character lay down", ["!leave"] = "Leave game",
	["!logs"] = "Open chat logs", ["!noclip [plr]"] = "Walk through walls",
	["!ping"] = "Show ping", ["!ragdoll"] = "Ragdoll character",
	["!rainbow [plr]"] = "Rainbow color cycle", ["!rejoin"] = "Rejoin server",
	["!removewaypoint"] = "Remove last waypoint", ["!sunglare"] = "Enable sun glare effect",
	["!sit"] = "Makes character sit", ["!speed [plr] [num]"] = "Set walkspeed",
	["!spin [speed]"] = "Spin character", ["!stopwatch"] = "Open stopwatch",
	["!thirdp"] = "Third person mode", ["!to [plr]"] = "Teleport to player",
	["!trip [plr]"] = "Makes player trip", ["!tracers"] = "Show player tracers",
	["!uncrosshair"] = "Remove crosshair", ["!unautoexec"] = "Disables auto-run",
	["!unesp [plr/all]"] = "Disable esp on player or all", ["!unfire [plr]"] = "Extinguish player",
	["!unfling"] = "Close fling GUI", ["!unfly"] = "Stop flying",
	["!unfreecam"] = "Disable freecam", ["!unfreeze [plr]"] = "Unfreeze player",
	["!uninfjump"] = "Disable infinite jump", ["!unnoclip [plr]"] = "Disable noclip",
	["!unragdoll"] = "Stop ragdoll", ["!unrainbow [plr]"] = "Stop rainbow",
	["!unsunglare"] = "Disable sun glare effect", ["!unspin"] = "Stop spinning",
	["!untracers"] = "Hide tracers", ["!unview"] = "Stop spectating",
	["!view [plr]"] = "Spectate player", ["!volume"] = "Set game volume (0-10)",
	["!waypoint"] = "Create waypoint", ["!fov [1-120]"] = "Set camera FOV",
	["!kick [plr]"] = "Kick yourself", ["!unlockmouse"] = "Toggle mouse lock"
}

cmds = {
	"!aimbot", "!autoexec", "!clicktp", "!cmdbar", "!console", "!crosshair", "!dance [plr]",
	"!destroyscript", "!disablefalldamage", "!enable inventory", "!enable playerlist",
	"!esp all", "!explode [plr]", "!fire [plr]", "!firstp", "!fling", "!fly",
	"!flyspeed [num]", "!freecam", "!freeze [plr]", "!infjump", "!joinlogs", "!jump [power]",
	"!kill [plr/all/me]", "!lay", "!leave", "!logs", "!noclip [plr]", "!ping", "!ragdoll",
	"!rainbow [plr]", "!rejoin", "!removewaypoint", "!sit", "!speed [plr] [num]",
	"!spin [speed]", "!stopwatch", "!thirdp", "!to [plr]", "!trip [plr]", "!tracers",
	"!sunglare", "!unsunglare", "!uncrosshair", "!unautoexec", "!unesp all", "!unfire [plr]", "!unfling", "!unfly",
	"!unfreecam", "!unfreeze [plr]", "!uninfjump", "!unnoclip [plr]", "!unragdoll",
	"!unrainbow [plr]", "!unspin", "!untracers", "!unview", "!view [plr]", "!volume", "!waypoint",
	"!fov [1-120]", "!kick [plr]", "!unlockmouse"
}

for i, cmdStr in ipairs(cmds) do
	btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 42)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	btn.Text = "  " .. cmdStr
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 14
	btn.TextColor3 = globalConfig.textColor
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.TextStrokeTransparency = 0.5
	btn.TextStrokeColor3 = Color3.new(0,0,0)
	btn.BorderSizePixel = 0
	btn.Parent = cmdScroll
	btn.LayoutOrder = i
	btn.ZIndex = 2147483647
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	desc = cmdDesc[cmdStr]
	if desc then
		btn.MouseEnter:Connect(function()
			btn.Text = "  " .. cmdStr .. " — " .. desc
			btn.TextColor3 = currentTheme.accent
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		end)
		btn.MouseLeave:Connect(function()
			btn.Text = "  " .. cmdStr
			btn.TextColor3 = globalConfig.textColor
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		end)
	end

	btn.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(cmdStr)
			notify("Copied: " .. cmdStr, Color3.fromRGB(100, 255, 100))
		end
	end)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	filter = searchBox.Text:lower()
	for _, child in ipairs(cmdScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child.Visible = filter == "" or child.Text:lower():find(filter, 1, true)
		end
	end
end)

-- ========== SETTINGS TAB ==========
setFrame = Instance.new("Frame", contentFrame)
setFrame.Name = "SetFrame"
setFrame.Size = UDim2.new(1, 0, 1, 0)
setFrame.BackgroundTransparency = 1
setFrame.Visible = false
setFrame.ZIndex = 2147483647

setScroll = Instance.new("ScrollingFrame", setFrame)
setScroll.Size = UDim2.new(1, 0, 1, 0)
setScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
setScroll.BorderSizePixel = 0
setScroll.ScrollBarThickness = 6
setScroll.ScrollBarImageColor3 = currentTheme.accent
setScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
setScroll.ZIndex = 2147483647
Instance.new("UICorner", setScroll).CornerRadius = UDim.new(0, 6)

setList = Instance.new("UIListLayout", setScroll)
setList.Padding = UDim.new(0, 12)
setList.SortOrder = Enum.SortOrder.LayoutOrder

-- Section creator (function reuses parameter names)
function makeSection(parent, titleText, h)
	s = Instance.new("Frame", parent)
	s.Size = UDim2.new(1, -16, 0, h)
	s.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	s.BorderSizePixel = 0
	s.LayoutOrder = #parent:GetChildren()
	s.ZIndex = 2147483647
	Instance.new("UICorner", s).CornerRadius = UDim.new(0, 8)

	t = Instance.new("TextLabel", s)
	t.Size = UDim2.new(1, -20, 0, 28)
	t.Position = UDim2.new(0, 10, 0, 8)
	t.BackgroundTransparency = 1
	t.Text = titleText
	t.Font = Enum.Font.GothamBlack
	t.TextSize = 16
	t.TextColor3 = currentTheme.accent
	t.TextStrokeTransparency = 0.5
	t.TextStrokeColor3 = Color3.new(0,0,0)
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.ZIndex = 2147483647

	return s
end

-- Text Color Section
cSection = makeSection(setScroll, "TEXT COLOR", 170)

cDisplay = Instance.new("TextLabel", cSection)
cDisplay.Size = UDim2.new(0.8, 0, 0, 32)
cDisplay.Position = UDim2.new(0.1, 0, 0, 38)
cDisplay.BackgroundColor3 = globalConfig.textColor
cDisplay.Text = "Preview"
cDisplay.Font = Enum.Font.GothamBold
cDisplay.TextSize = 15
cDisplay.TextColor3 = Color3.new(0,0,0)
cDisplay.ZIndex = 2147483647
Instance.new("UICorner", cDisplay).CornerRadius = UDim.new(0, 6)

-- Slider creator (reuses all parameter names, minimal locals)
function makeSlider(parent, y, color, label, comp)
	cont = Instance.new("Frame", parent)
	cont.Size = UDim2.new(0.8, 0, 0, 24)
	cont.Position = UDim2.new(0.1, 0, 0, y)
	cont.BackgroundTransparency = 1
	cont.ZIndex = 2147483647

	lab = Instance.new("TextLabel", cont)
	lab.Size = UDim2.new(0, 30, 1, 0)
	lab.BackgroundTransparency = 1
	lab.Text = label
	lab.Font = Enum.Font.GothamBold
	lab.TextSize = 12
	lab.TextColor3 = color
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.ZIndex = 2147483647

	track = Instance.new("Frame", cont)
	track.Size = UDim2.new(1, -40, 0, 8)
	track.Position = UDim2.new(0, 35, 0.5, -4)
	track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	track.BorderSizePixel = 0
	track.ZIndex = 2147483647
	Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

	fill = Instance.new("Frame", track)
	val = comp == "R" and globalConfig.textColor.R or comp == "G" and globalConfig.textColor.G or globalConfig.textColor.B
	fill.Size = UDim2.new(val, 0, 1, 0)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.ZIndex = 2147483647
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

	knob = Instance.new("Frame", track)
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(val, -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.ZIndex = 2147483647
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	dragging = false

	function updateSlider(x)
		pos = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.new(pos, 0, 1, 0)
		knob.Position = UDim2.new(pos, -7, 0.5, -7)

		newC = Color3.new(
			comp == "R" and pos or globalConfig.textColor.R,
			comp == "G" and pos or globalConfig.textColor.G,
			comp == "B" and pos or globalConfig.textColor.B
		)
		globalConfig.textColor = newC
		cDisplay.BackgroundColor3 = newC

		if lunarGui then
			for _, obj in ipairs(lunarGui:GetDescendants()) do
				if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.TextColor3 ~= currentTheme.accent then
					obj.TextColor3 = newC
				end
			end
		end
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateSlider(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input.Position.X)
		end
	end)
end

makeSlider(cSection, 78, Color3.fromRGB(255, 80, 80), "R", "R")
makeSlider(cSection, 106, Color3.fromRGB(80, 255, 80), "G", "G")
makeSlider(cSection, 134, Color3.fromRGB(80, 140, 255), "B", "B")

-- UI Transparency Section
tSection = makeSection(setScroll, "UI TRANSPARENCY", 110)

tLabel = Instance.new("TextLabel", tSection)
tLabel.Size = UDim2.new(1, 0, 0, 22)
tLabel.Position = UDim2.new(0, 0, 0, 36)
tLabel.BackgroundTransparency = 1
tLabel.Text = "Transparency: " .. math.round(globalConfig.uiTransparency * 100) .. "%"
tLabel.Font = Enum.Font.GothamBold
tLabel.TextSize = 14
tLabel.TextColor3 = globalConfig.textColor
tLabel.ZIndex = 2147483647

tTrack = Instance.new("Frame", tSection)
tTrack.Size = UDim2.new(0.8, 0, 0, 10)
tTrack.Position = UDim2.new(0.1, 0, 0, 68)
tTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
tTrack.BorderSizePixel = 0
tTrack.ZIndex = 2147483647
Instance.new("UICorner", tTrack).CornerRadius = UDim.new(0, 5)

tFill = Instance.new("Frame", tTrack)
tFill.Size = UDim2.new(globalConfig.uiTransparency, 0, 1, 0)
tFill.BackgroundColor3 = currentTheme.accent
tFill.BorderSizePixel = 0
tFill.ZIndex = 2147483647
Instance.new("UICorner", tFill).CornerRadius = UDim.new(0, 5)

tKnob = Instance.new("Frame", tTrack)
tKnob.Size = UDim2.new(0, 16, 0, 16)
tKnob.Position = UDim2.new(globalConfig.uiTransparency, -8, 0.5, -8)
tKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tKnob.BorderSizePixel = 0
tKnob.ZIndex = 2147483647
Instance.new("UICorner", tKnob).CornerRadius = UDim.new(1, 0)

tDragging = false

function updateTrans(x)
	pos = math.clamp((x - tTrack.AbsolutePosition.X) / tTrack.AbsoluteSize.X, 0, 1)
	tFill.Size = UDim2.new(pos, 0, 1, 0)
	tKnob.Position = UDim2.new(pos, -8, 0.5, -8)
	globalConfig.uiTransparency = pos
	tLabel.Text = "Transparency: " .. math.round(pos * 100) .. "%"
	if mainFrame then
		mainFrame.BackgroundTransparency = pos
	end
end

tTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		tDragging = true
		updateTrans(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		tDragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if tDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateTrans(input.Position.X)
	end
end)

-- Theme Section
thSection = makeSection(setScroll, "THEME SELECTOR", 0)

thCont = Instance.new("Frame", thSection)
thCont.Size = UDim2.new(1, -20, 1, -40)
thCont.Position = UDim2.new(0, 10, 0, 36)
thCont.BackgroundTransparency = 1
thCont.ZIndex = 2147483647

thCount = 0
for _ in pairs(themes) do thCount = thCount + 1 end
rows = math.ceil(thCount / 2)
thSection.Size = UDim2.new(1, -16, 0, 36 + rows * 55 + 10)

thGrid = Instance.new("UIGridLayout", thCont)
thGrid.CellSize = UDim2.new(0.48, 0, 0, 45)
thGrid.CellPadding = UDim2.new(0, 10, 0, 10)
thGrid.SortOrder = Enum.SortOrder.LayoutOrder

for name, th in pairs(themes) do
	btn = Instance.new("TextButton", thCont)
	btn.BackgroundColor3 = th.accent
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = th.text
	btn.BorderSizePixel = 0
	btn.LayoutOrder = name == "Default" and 1 or 2
	btn.ZIndex = 2147483647
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		currentTheme = th
		mainFrame.BackgroundColor3 = th.glass
		titleLabel.TextColor3 = th.accent
		cmdTab.BackgroundColor3 = th.accent
		setTab.BackgroundColor3 = th.btn
		searchBar.BackgroundColor3 = th.list

		for _, obj in ipairs(lunarGui:GetDescendants()) do
			if obj:IsA("TextLabel") and obj.TextColor3 == currentTheme.accent then
				obj.TextColor3 = th.accent
			end
		end

		notify("Theme changed to " .. name, th.accent)
	end)
end

-- Discord Section
dSection = makeSection(setScroll, "COMMUNITY", 90)
dSection.BackgroundColor3 = Color3.fromRGB(88, 101, 242)

dBtn = Instance.new("TextButton", dSection)
dBtn.Size = UDim2.new(0.9, 0, 0, 40)
dBtn.Position = UDim2.new(0.05, 0, 0, 38)
dBtn.BackgroundColor3 = Color3.fromRGB(120, 130, 255)
dBtn.Text = "Join Discord Server"
dBtn.Font = Enum.Font.GothamBlack
dBtn.TextSize = 16
dBtn.TextColor3 = Color3.new(1,1,1)
dBtn.ZIndex = 2147483647
Instance.new("UICorner", dBtn).CornerRadius = UDim.new(0, 6)

dBtn.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard("https://discord.gg/5GeQAXYYcW")
		notify("Discord link copied to clipboard!", Color3.fromRGB(88,101,242))
	else
		notify("Clipboard not supported in this executor", Color3.fromRGB(255,100,100))
	end
end)

-- Tab switching
cmdTab.MouseButton1Click:Connect(function()
	cmdFrame.Visible = true
	setFrame.Visible = false
	cmdTab.BackgroundColor3 = currentTheme.accent
	cmdTab.TextColor3 = Color3.new(0,0,0)
	setTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	setTab.TextColor3 = globalConfig.textColor
end)

setTab.MouseButton1Click:Connect(function()
	cmdFrame.Visible = false
	setFrame.Visible = true
	setTab.BackgroundColor3 = currentTheme.accent
	setTab.TextColor3 = Color3.new(0,0,0)
	cmdTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	cmdTab.TextColor3 = globalConfig.textColor
end)
-- =============================================================
-- STARTUP
-- =============================================================
lunarGui.Enabled = true
playOpen()
notify("Lunar Admin loaded • Enjoy :3", Color3.fromRGB(120,220,255))

-- After lunarGui.Enabled = true and before the notify
setupButtonSounds()

task.spawn(function()
	task.wait(0.8)
	local wm = Instance.new("ScreenGui")
	wm.ResetOnSpawn = false
	wm.DisplayOrder = 999999
	wm.Parent = client.PlayerGui
	local label = Instance.new("TextLabel", wm)
	label.Size = UDim2.new(0, 320, 0, 40)
	label.Position = UDim2.new(0.5, -160, 0.94, 0)
	label.BackgroundTransparency = 1
	label.Text = "Created By @xlunarxZzrbxx • lunar_rbx discord"
	label.Font = Enum.Font.GothamBold
	label.TextSize = 24
	label.TextColor3 = globalConfig.textColor
	label.TextTransparency = 0 -- SOLID
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.new(0,0,0)
	TweenService:Create(label, TweenInfo.new(1.8, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
	task.wait(5.5)
	TweenService:Create(label, TweenInfo.new(1.6), {TextTransparency = 1}):Play()
	task.delay(2, function() wm:Destroy() end)
end)

-- Keybind handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if lunarGui then
			lunarGui.Enabled = not lunarGui.Enabled
			if lunarGui.Enabled then
				playOpen()
			else
				playClose()
			end
		end
	end
end)
--- =============================================================
-- overhead UI cuz yea 
-- =============================================================

local function createHubGUI(character)
    for _, v in ipairs(client.PlayerGui:GetChildren()) do
        if v.Name == "LunarHubGUI" then v:Destroy() end
    end

    local head = character:WaitForChild("Head")
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LunarHubGUI"
    billboard.Adornee = head
    billboard.Size = UDim2.new(4.2, 0, 1.6, 0)
    billboard.StudsOffset = Vector3.new(0, 3.1, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 300
    billboard.Parent = client.PlayerGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = Color3.fromRGB(5, 10, 8)
    main.BackgroundTransparency = 0.65
    main.BorderSizePixel = 0
    main.Parent = billboard
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 120)
    stroke.Thickness = 2.2
    stroke.Transparency = 0.2
    stroke.Parent = main

    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 255, 140)
    glow.Thickness = 8
    glow.Transparency = 0.88
    glow.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.40, 0)
    title.BackgroundTransparency = 1
    title.Text = "LUNAR HUB"
    title.TextColor3 = Color3.fromRGB(0, 255, 100)
    title.TextScaled = true
    title.Font = Enum.Font.Code
    title.TextStrokeTransparency = 0.1
    title.TextStrokeColor3 = Color3.new(0, 0, 0)
    title.Parent = main

    local greeting = Instance.new("TextLabel")
    greeting.Size = UDim2.new(0.3, 10, 1, 10)
    greeting.BackgroundTransparency = 1
    greeting.Text = "Greetings ------------"
    greeting.TextColor3 = Color3.fromRGB(0, 255, 100)
    greeting.TextScaled = true
    greeting.Font = Enum.Font.Code
    greeting.TextStrokeTransparency = 0.1
    greeting.TextStrokeColor3 = Color3.new(0, 0, 0)
    greeting.Parent = main

    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1, 0, 0.60, 0)
    bottom.Position = UDim2.new(0, 0, 0.40, 0)
    bottom.BackgroundTransparency = 1
    bottom.Parent = main

    local username = Instance.new("TextLabel")
    username.Size = UDim2.new(0.62, 0, 1.3, 0)
    username.BackgroundTransparency = 1
    username.Text = client.Name
    username.TextColor3 = Color3.fromRGB(180, 255, 200)
    username.TextScaled = true
    username.Font = Enum.Font.Code
    username.TextStrokeTransparency = 0.5
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = bottom

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.30, 10, 0.5, 1)
    timeLabel.Position = UDim2.new(0.62, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.Code
    timeLabel.TextStrokeTransparency = 0.4
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = bottom

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not billboard.Parent then
            conn:Disconnect()
            return
        end
        timeLabel.Text = os.date("%I:%M %p")
    end)
end

client.CharacterAdded:Connect(createHubGUI)
if client.Character then
    createHubGUI(client.Character)
end
------------------------------------------------------------------------------
----------------- END OF IT LOL ----------------------------------------------
------------------------------------------------------------------------------

-- Chat handler
client.Chatted:Connect(processCmd)

-- lol 4/19/26
