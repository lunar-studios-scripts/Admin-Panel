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
-- Lunar Hub watermakr yea
-- =============================================================
task.spawn(function()
    if client.PlayerGui:FindFirstChild("LunarWatermark") then
        client.PlayerGui.LunarWatermark:Destroy()
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "LunarWatermark"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999
    sg.Parent = client.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 380, 0, 34)           -- Slightly wider
    frame.Position = UDim2.new(1, -3220, 0, 15)       -- Right side, aligned under mic
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.BackgroundTransparency = 0.15
    frame.Parent = sg

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    -- Glows
    local s1 = Instance.new("UIStroke", frame)
    s1.Color = Color3.fromRGB(255, 215, 0)
    s1.Thickness = 2.5
    s1.Transparency = 0.65

    local s2 = Instance.new("UIStroke", frame)
    s2.Color = Color3.fromRGB(60, 60, 60)
    s2.Thickness = 1
    s2.Transparency = 0.4

    -- Moon Icon
    local moon = Instance.new("TextLabel", frame)
    moon.Size = UDim2.new(0, 32, 1, 0)
    moon.Position = UDim2.new(0, 12, 0, 0)
    moon.BackgroundTransparency = 1
    moon.Text = "🌙"
    moon.TextColor3 = Color3.fromRGB(255, 215, 0)
    moon.TextSize = 22
    moon.Font = Enum.Font.GothamBold

    -- Main Label
    local label = Instance.new("TextLabel", frame)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -68, 1, 0)
    label.Position = UDim2.new(0, 52, 0, 0)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "Lunar Hub | Loading..."

    -- FPS + Ping System
    local fps = 0
    local frames = 0
    local last = tick()

    RunService.RenderStepped:Connect(function()
        frames += 1
        if tick() - last >= 1 then
            fps = frames
            frames = 0
            last = tick()
        end
    end)

    local function getPing()
        local ping = 999
        pcall(function()
            local p = client:GetNetworkPing()
            if p then ping = math.floor(p * 2000) end
        end)
        return ping
    end

    task.spawn(function()
        while sg.Parent do
            label.Text = string.format("Lunar Hub | %d FPS | %d ms", fps, getPing())
            task.wait(0.25)
        end
    end)
end)
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
        grad1 = Color3.fromRGB(90, 25, 25),
        grad2 = Color3.fromRGB(60, 15, 15),
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
    s.Volume = 1
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 2)
end

-- =============================================================
-- AUTO APPLY SOUNDS TO ALL BUTTONS
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
-- IMPROVED NOTIFICATION SYSTEM + NON-OVERLAPPING SOUND
-- =============================================================
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "LunarNotifs"
notifGui.ResetOnSpawn = false
notifGui.DisplayOrder = 999999
notifGui.Parent = client.PlayerGui

local activeNotifications = {}
local notifHeight = 82
local notifSpacing = 12

local currentNotifSound = nil   -- Tracks the currently playing notification sound

local function playNotifSound()
    -- Stop any previous notification sound
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

local function notify(text, col)
    col = col or currentTheme.accent or Color3.fromRGB(100, 200, 255)
   
    -- Create notification frame
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 340, 0, 76)
    f.Position = UDim2.new(1, 100, 1, -100)
    f.BackgroundColor3 = currentTheme.glass
    f.BorderSizePixel = 0
    f.BackgroundTransparency = 1
    f.Parent = notifGui

    applyGlassEffect(f, globalConfig.uiTransparency, 0.35)

    -- Text Label
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 1, -20)
    lbl.Position = UDim2.new(0, 12, 0, 10)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 17
    lbl.TextColor3 = globalConfig.textColor
    lbl.TextTransparency = 1
    lbl.TextStrokeTransparency = 0.6
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    -- ==================== PLAY NOTIFICATION SOUND ====================
    playNotifSound()

    -- Add to stack
    table.insert(activeNotifications, f)

    -- Entrance Animation
    f.Size = UDim2.new(0, 280, 0, 60)
    f.Position = UDim2.new(1, 120, 1, -80)
    f.BackgroundTransparency = 1

    task.spawn(function()
        TweenService:Create(f, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 340, 0, 76),
            Position = UDim2.new(1, -360, 1, -90 - ((#activeNotifications - 1) * (notifHeight + notifSpacing))),
            BackgroundTransparency = globalConfig.uiTransparency
        }):Play()

        TweenService:Create(lbl, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
    end)

    -- Reposition existing notifications
    for i, notif in ipairs(activeNotifications) do
        if notif ~= f and notif.Parent then
            local targetY = -90 - ((i - 1) * (notifHeight + notifSpacing))
            TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -360, 1, targetY)
            }):Play()
        end
    end

    -- Auto remove after 5 seconds
    task.delay(5, function()
        if not f.Parent then return end

        for i, notif in ipairs(activeNotifications) do
            if notif == f then
                table.remove(activeNotifications, i)
                break
            end
        end

        -- Exit animation
        TweenService:Create(f, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 120, 1, f.Position.Y.Offset),
            BackgroundTransparency = 1
        }):Play()

        TweenService:Create(lbl, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
            TextTransparency = 1
        }):Play()

        task.delay(0.15, function()
            for i, notif in ipairs(activeNotifications) do
                if notif.Parent then
                    local targetY = -90 - ((i - 1) * (notifHeight + notifSpacing))
                    TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, -360, 1, targetY)
                    }):Play()
                end
            end
        end)

        task.delay(0.7, function()
            if f.Parent then f:Destroy() end
        end)
    end)

    -- Limit to 5 notifications
    if #activeNotifications > 5 then
        local old = table.remove(activeNotifications, 1)
        if old and old.Parent then
            TweenService:Create(old, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(1, 120, 1, old.Position.Y.Offset),
                BackgroundTransparency = 1
            }):Play()
            task.delay(0.4, function()
                if old.Parent then old:Destroy() end
            end)
        end
    end
end
-- =============================================================
--  speed SYSTEM
-- =============================================================
local speedPanelData = {
    panel = nil,
    enabled = false,
    bypassEnabled = false,
    speedValue = 100,
    connection = nil
}

local function createSpeedPanel()
    if speedPanelData.panel then
        speedPanelData.panel:Destroy()
        speedPanelData.panel = nil
        if speedPanelData.connection then
            speedPanelData.connection:Disconnect()
            speedPanelData.connection = nil
        end
        return
    end
    
    local panel = Instance.new("ScreenGui")
    panel.Name = "SpeedPanel"
    panel.ResetOnSpawn = false
    panel.DisplayOrder = 999999
    panel.Parent = client.PlayerGui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 350, 0, 280)
    main.Position = UDim2.new(0.5, -175, 0.5, -140)
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
    title.TextTransparency = 0 -- SOLID
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
    speedDisplay.TextTransparency = 0 -- SOLID
    speedDisplay.TextStrokeTransparency = 0.5
    speedDisplay.TextStrokeColor3 = Color3.new(0,0,0)
    
    local sliderFrame = Instance.new("Frame", main)
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 12)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, 95)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    applyGlassEffect(sliderFrame, 0.3, 0.7)
    
    local sliderFill = Instance.new("Frame", sliderFrame)
    sliderFill.Size = UDim2.new(speedPanelData.speedValue / 10000, 0, 1, 0)
    sliderFill.BackgroundColor3 = currentTheme.accent
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 6)
    
    local sliderKnob = Instance.new("TextButton", sliderFrame)
    sliderKnob.Size = UDim2.new(0, 24, 0, 24)
    sliderKnob.Position = UDim2.new(speedPanelData.speedValue / 10000, -12, 0.5, -12)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.Text = ""
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
    
    local toggle1Btn = Instance.new("TextButton", main)
    toggle1Btn.Size = UDim2.new(0.9, 0, 0, 45)
    toggle1Btn.Position = UDim2.new(0.05, 0, 0, 120)
    toggle1Btn.BackgroundColor3 = speedPanelData.enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    toggle1Btn.Text = "Walkspeed: " .. (speedPanelData.enabled and "ON" or "OFF")
    toggle1Btn.Font = Enum.Font.GothamBold
    toggle1Btn.TextSize = 18
    toggle1Btn.TextColor3 = Color3.new(0,0,0)
    toggle1Btn.TextTransparency = 0 -- SOLID
    applyGlassEffect(toggle1Btn, 0.2, 0.5)
    
    local toggle2Btn = Instance.new("TextButton", main)
    toggle2Btn.Size = UDim2.new(0.9, 0, 0, 45)
    toggle2Btn.Position = UDim2.new(0.05, 0, 0, 175)
    toggle2Btn.BackgroundColor3 = speedPanelData.bypassEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    toggle2Btn.Text = "Bypass Scripts: " .. (speedPanelData.bypassEnabled and "ON" or "OFF")
    toggle2Btn.Font = Enum.Font.GothamBold
    toggle2Btn.TextSize = 18
    toggle2Btn.TextColor3 = Color3.new(0,0,0)
    toggle2Btn.TextTransparency = 0 -- SOLID
    applyGlassEffect(toggle2Btn, 0.2, 0.5)
    
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(closeBtn, 0.2, 0.4)
    
    local dragging = false
    
    local function updateSpeed(val)
        speedPanelData.speedValue = math.clamp(math.floor(val), 1, 10000)
        speedDisplay.Text = "Speed: " .. speedPanelData.speedValue
        sliderFill.Size = UDim2.new(speedPanelData.speedValue / 10000, 0, 1, 0)
        sliderKnob.Position = UDim2.new(speedPanelData.speedValue / 10000, -12, 0.5, -12)
        
        if speedPanelData.enabled and hum then
            hum.WalkSpeed = speedPanelData.speedValue
        end
    end
    
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            updateSpeed(pos * 10000)
        end
    end)
    
    toggle1Btn.MouseButton1Click:Connect(function()
        speedPanelData.enabled = not speedPanelData.enabled
        toggle1Btn.Text = "Walkspeed: " .. (speedPanelData.enabled and "ON" or "OFF")
        toggle1Btn.BackgroundColor3 = speedPanelData.enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if speedPanelData.enabled and hum then
            hum.WalkSpeed = speedPanelData.speedValue
        elseif hum then
            hum.WalkSpeed = 16
        end
    end)
    
    toggle2Btn.MouseButton1Click:Connect(function()
        speedPanelData.bypassEnabled = not speedPanelData.bypassEnabled
        toggle2Btn.Text = "Bypass Scripts: " .. (speedPanelData.bypassEnabled and "ON" or "OFF")
        toggle2Btn.BackgroundColor3 = speedPanelData.bypassEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if speedPanelData.bypassEnabled then
            speedPanelData.connection = RunService.Heartbeat:Connect(function()
                if hum and speedPanelData.enabled then
                    hum.WalkSpeed = speedPanelData.speedValue
                end
            end)
        else
            if speedPanelData.connection then
                speedPanelData.connection:Disconnect()
                speedPanelData.connection = nil
            end
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        panel:Destroy()
        speedPanelData.panel = nil
    end)
    
    speedPanelData.panel = panel
    notify("Speed panel opened", currentTheme.accent)
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
    Title.Text = "✈️ FLY SYSTEM"
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
        self.flyBtn.Text = "⏹ STOP FLY"
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
    
    notify("🚀 Flying at speed " .. self.uiSpeed .. "!", Color3.fromRGB(0, 255, 150))
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
    
    notify("✋ Fly stopped", Color3.fromRGB(255, 160, 60))
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
        FlySystem.flyBtn.Text = "⏹ STOP FLY"
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

---------------------------------------------------------------------
-- DATA
---------------------------------------------------------------------
local espData = {
    enabled = false,
    playerESP = {},
    connections = {},
    distanceConn = nil
}

---------------------------------------------------------------------
-- SAFE HRP GETTER (prevents breaking when you die)
---------------------------------------------------------------------
local function getMyHRP()
    local char = client.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

---------------------------------------------------------------------
-- CLEAR PLAYER ESP
---------------------------------------------------------------------
local function clearPlayerESP(plr)
    local data = espData.playerESP[plr]
    if not data then return end

    for _,conn in ipairs(data.connections) do
        conn:Disconnect()
    end

    for _,obj in ipairs(data.objects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end

    espData.playerESP[plr] = nil
end

---------------------------------------------------------------------
-- ATTACH ESP TO CHARACTER
---------------------------------------------------------------------
local function attachESP(plr, char)

    if not espData.enabled then return end
    if plr == client then return end

    local data = espData.playerESP[plr]
    if not data then return end

    -- clear old objects (important for respawn)
    for _,obj in ipairs(data.objects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    data.objects = {}
    data.distLabel = nil

    local head = char:WaitForChild("Head",10)
    local hrp = char:WaitForChild("HumanoidRootPart",10)
    if not head or not hrp then return end

    ----------------------------------------------------
    -- HIGHLIGHT
    ----------------------------------------------------
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    if plr.Team then
        highlight.FillColor = plr.Team.TeamColor.Color
    else
        highlight.FillColor = Color3.new(1,0,0)
    end

    highlight.Parent = workspace
    table.insert(data.objects, highlight)

    ----------------------------------------------------
    -- BILLBOARD
    ----------------------------------------------------
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0,200,0,60)
    billboard.StudsOffset = Vector3.new(0,2.5,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = client.PlayerGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = highlight.FillColor
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.BackgroundTransparency = 1
    distLabel.Position = UDim2.new(0,0,0.55,0)
    distLabel.Size = UDim2.new(1,0,0.45,0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 13
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.new(0,0,0)
    distLabel.TextColor3 = Color3.new(1,1,1)
    distLabel.Text = "0 studs"
    distLabel.Parent = billboard

    table.insert(data.objects, billboard)
    data.distLabel = distLabel
end

---------------------------------------------------------------------
-- CREATE PLAYER ESP
---------------------------------------------------------------------
local function createPlayerESP(plr)
    if plr == client then return end
    if espData.playerESP[plr] then return end

    local data = {
        connections = {},
        objects = {},
        distLabel = nil
    }

    espData.playerESP[plr] = data

    if plr.Character then
        attachESP(plr, plr.Character)
    end

    -- Reattach every respawn
    local respawnConn = plr.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        attachESP(plr, char)
    end)

    table.insert(data.connections, respawnConn)
end

---------------------------------------------------------------------
-- ENABLE ALL
---------------------------------------------------------------------
function enableESPAll()

    if espData.enabled then return end
    espData.enabled = true

    -- Distance updater (never errors)
    espData.distanceConn = RunService.RenderStepped:Connect(function()

        local myHRP = getMyHRP()
        if not myHRP then return end

        for plr,data in pairs(espData.playerESP) do
            if data.distLabel and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = plr.Character.HumanoidRootPart
                local dist = (targetHRP.Position - myHRP.Position).Magnitude
                data.distLabel.Text = math.floor(dist).." studs"
            end
        end

    end)

    -- Apply to current players
    for _,plr in ipairs(Players:GetPlayers()) do
        createPlayerESP(plr)
    end

    -- Auto apply to new players
    table.insert(espData.connections,
        Players.PlayerAdded:Connect(function(plr)
            if espData.enabled then
                createPlayerESP(plr)
            end
        end)
    )

    -- Remove when they leave
    table.insert(espData.connections,
        Players.PlayerRemoving:Connect(clearPlayerESP)
    )
end

---------------------------------------------------------------------
-- DISABLE ALL
---------------------------------------------------------------------
function disableESPAll()

    if not espData.enabled then return end
    espData.enabled = false

    if espData.distanceConn then
        espData.distanceConn:Disconnect()
        espData.distanceConn = nil
    end

    for _,conn in ipairs(espData.connections) do
        conn:Disconnect()
    end
    espData.connections = {}

    for plr,_ in pairs(espData.playerESP) do
        clearPlayerESP(plr)
    end
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
    for _, gui in ipairs(client.PlayerGui:GetChildren()) do
        if gui.Name == "LunarGui" or gui.Name == "LunarNotifs" or 
           gui.Name == "AimbotPanel" or gui.Name == "logsPanel" or 
           gui.Name == "stopwatchPanel" or gui.Name == "SpeedPanel" or
           gui.Name == "JoinLogsPanel" or gui.Name == "ViewGui" or
           gui.Name == "CmdBarGui" then
            gui:Destroy()
        end
    end
    
    for _, data in pairs(spinData) do
        if data.connection then
            data.connection:Disconnect()
        end
    end
    
    if speedPanelData.connection then
        speedPanelData.connection:Disconnect()
    end
    
    if viewData.freezeConn then
        viewData.freezeConn:Disconnect()
    end
    
    disableESPAll()
    disableFreecam()
    
    notify("💥 Script destroyed", Color3.fromRGB(255, 80, 80))
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
    gui.DisplayOrder = 999999
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
    input.ClearTextOnFocus = false
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
        "!aimbot", "!clicktp", "!cmdbar", "!console", "!dance", "!destroyscript", 
        "!disablefalldamage", "!enable inventory", "!enable playerlist", "!esp all", "!unesp all", 
        "!explode", "!fire", "!unfire", "!firstp", "!fling", "!fly", "!unfly", "!freecam", 
        "!unfreecam", "!freeze", "!unfreeze",
        "!joinlogs", "!jump", "!kill", "!lay", "!leave", "!logs", "!noclip", 
        "!unnoclip", "!ping", "!ragdoll", "!unragdoll", "!rainbow", "!unrainbow", "!rejoin", 
        "!removewaypoint", "!resetspeed", "!sit", "!speed", "!spin", "!unspin", "!stopwatch", 
        "!thirdp", "!to", "!trip", "!tracers", "!untracers", "!view", "!unview", 
        "!waypoint", "!fov", "!kick", "!unlockmouse"
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
    
    notify("✅ Command Bar Auto-Opened • Press INSERT to toggle", currentTheme.accent)
end

-- ==================== AUTO SHOW + HOTKEY ====================

-- Auto show when script executes
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

-- Optional: You can change the hotkey here if you want
-- Example: F2 key → Enum.KeyCode.F2

-- =============================================================
-- AIMBOT SYSTEM
-- =============================================================
local aimbotData = {
    enabled = false,
    smoothness = 0.5,
    smoothnessEnabled = true,
    teamCheck = false,
    wallCheck = false,
    targetTeam = nil,
    aimPart = "HumanoidRootPart",
    predictionEnabled = false,
    predictionAmount = 0.15,
    espEnabled = false,

    -- Advanced ESP - ALL START DISABLED
    espBoxEnabled = false,
    espSkeletonEnabled = false,
    espTracersEnabled = false,
    espChamsEnabled = false,
    espHealthTextEnabled = false,
    espFilledBox = false,
    espBoxStyle = "Full",
    espMaxDistance = 1000, -- Max distance for ESP to work

    panel = nil,
    teamsList = nil,
    connection = nil,
    inputBeganConn = nil,
    inputEndedConn = nil,
    espConnection = nil,
    espDrawings = {},
    espHighlights = {},
    minimized = false,
    mainFrame = nil,
    rightClickHeld = false
}

-- Skeleton joint connections for ESP
local SKELETON_JOINTS = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function createAimbotPanel()
    -- Full cleanup
    if aimbotData.panel then aimbotData.panel:Destroy() end
    if aimbotData.espConnection then aimbotData.espConnection:Disconnect() end
    for _, drawings in pairs(aimbotData.espDrawings) do
        for _, obj in pairs(drawings) do if obj then obj:Remove() end end
    end
    for _, hl in pairs(aimbotData.espHighlights) do if hl then hl:Destroy() end end
    aimbotData.espDrawings = {}
    aimbotData.espHighlights = {}

    aimbotData.enabled = false
    aimbotData.targetTeam = nil
    aimbotData.espEnabled = false
    aimbotData.minimized = false
    aimbotData.rightClickHeld = false

    local panel = Instance.new("ScreenGui")
    panel.Name = "AimbotPanel"
    panel.ResetOnSpawn = false
    panel.DisplayOrder = 999999
    panel.Parent = client.PlayerGui

    -- Main UI
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 480, 0, 650)
    main.Position = UDim2.new(0, 430, 0.5, -325)
    main.BackgroundColor3 = currentTheme.glass
    main.Active = true
    main.Draggable = true
    main.Parent = panel
    applyGlassEffect(main, globalConfig.uiTransparency, 0.4)
    aimbotData.mainFrame = main

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 65)
    titleBar.BackgroundColor3 = currentTheme.glass
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    applyGlassEffect(titleBar, globalConfig.uiTransparency, 0.4)

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ADVANCED AIMBOT + ESP"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 26
    title.TextColor3 = currentTheme.accent
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextStrokeTransparency = 0.3
    title.TextStrokeColor3 = Color3.new(0,0,0)

    -- Minimize and Close Buttons
    local minimizeBtn = Instance.new("TextButton", titleBar)
    minimizeBtn.Size = UDim2.new(0, 38, 0, 38)
    minimizeBtn.Position = UDim2.new(1, -85, 0.5, -19)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBlack
    minimizeBtn.TextSize = 30
    minimizeBtn.TextColor3 = Color3.new(1,1,1)
    applyGlassEffect(minimizeBtn, 0.2, 0.4)

    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0, 38, 0, 38)
    closeBtn.Position = UDim2.new(1, -42, 0.5, -19)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 26
    closeBtn.TextColor3 = Color3.new(1,1,1)
    applyGlassEffect(closeBtn, 0.2, 0.4)

    -- Content ScrollingFrame
    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Name = "Content"
    contentScroll.Size = UDim2.new(1, -20, 1, -75)
    contentScroll.Position = UDim2.new(0, 10, 0, 70)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 6
    contentScroll.ScrollBarImageColor3 = currentTheme.accent
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroll.Parent = main

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = contentScroll

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.Parent = contentScroll

    minimizeBtn.MouseButton1Click:Connect(function()
        aimbotData.minimized = not aimbotData.minimized
        if aimbotData.minimized then
            main.Size = UDim2.new(0, 480, 0, 65)
            contentScroll.Visible = false
            minimizeBtn.Text = "+"
        else
            main.Size = UDim2.new(0, 480, 0, 650)
            contentScroll.Visible = true
            minimizeBtn.Text = "-"
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        aimbotData.enabled = false
        aimbotData.espEnabled = false
        if aimbotData.connection then aimbotData.connection:Disconnect() end
        if aimbotData.espConnection then aimbotData.espConnection:Disconnect() end
        if aimbotData.inputBeganConn then aimbotData.inputBeganConn:Disconnect() end
        if aimbotData.inputEndedConn then aimbotData.inputEndedConn:Disconnect() end

        for _, drawings in pairs(aimbotData.espDrawings) do
            for _, obj in pairs(drawings) do if obj then obj:Remove() end end
        end
        for _, hl in pairs(aimbotData.espHighlights) do if hl then hl:Destroy() end end

        panel:Destroy()
        aimbotData.panel = nil
        notify("Aimbot + ESP fully closed. Use !aimbot to reopen.", Color3.fromRGB(255, 160, 60))
    end)

    -- Headers
    local function createHeader(text)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 36)
        container.BackgroundColor3 = currentTheme.accent
        container.BorderSizePixel = 0
        container.Parent = contentScroll
        
        local corner = Instance.new("UICorner", container)
        corner.CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 16
        label.TextColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0.8
        
        local stroke = Instance.new("UIStroke", container)
        stroke.Color = Color3.new(1, 1, 1)
        stroke.Transparency = 0.7
        stroke.Thickness = 1
        
        return container
    end

    -- Helper for consistent button sizing
    local function createButtonContainer()
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95, 0, 0, 42)
        btn.BackgroundColor3 = currentTheme.btn
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 17
        btn.AutoButtonColor = true
        applyGlassEffect(btn, 0.2, 0.5)
        return btn
    end

    -- Team Selection
    createHeader("AIMBOT TARGETING")

    local teamsContainer = Instance.new("Frame")
    teamsContainer.Size = UDim2.new(0.95, 0, 0, 110)
    teamsContainer.BackgroundColor3 = Color3.fromRGB(30,30,40)
    teamsContainer.BorderSizePixel = 0
    applyGlassEffect(teamsContainer, 0.4, 0.6)
    teamsContainer.Parent = contentScroll

    local teamsScroll = Instance.new("ScrollingFrame", teamsContainer)
    teamsScroll.Size = UDim2.new(1, -10, 1, -10)
    teamsScroll.Position = UDim2.new(0, 5, 0, 5)
    teamsScroll.BackgroundTransparency = 1
    teamsScroll.BorderSizePixel = 0
    teamsScroll.ScrollBarThickness = 4

    local teamsListLayout = Instance.new("UIListLayout", teamsScroll)
    teamsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    teamsListLayout.Padding = UDim.new(0, 4)

    aimbotData.teamsList = teamsScroll

    local function refreshTeamsList()
        for _, child in pairs(teamsScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        local allBtn = Instance.new("TextButton")
        allBtn.Size = UDim2.new(1, -10, 0, 30)
        allBtn.BackgroundColor3 = (aimbotData.targetTeam == nil) and currentTheme.accent or currentTheme.btn
        allBtn.Text = "All Teams"
        allBtn.Font = Enum.Font.GothamBold
        allBtn.TextSize = 15
        allBtn.TextColor3 = (aimbotData.targetTeam == nil) and Color3.new(0,0,0) or globalConfig.textColor
        allBtn.Parent = teamsScroll
        allBtn.MouseButton1Click:Connect(function()
            aimbotData.targetTeam = nil
            refreshTeamsList()
        end)

        local seen = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Team and not seen[plr.Team] then
                seen[plr.Team] = true
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -10, 0, 30)
                btn.BackgroundColor3 = (aimbotData.targetTeam == plr.Team) and currentTheme.accent or currentTheme.btn
                btn.Text = plr.Team.Name
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 15
                btn.TextColor3 = (aimbotData.targetTeam == plr.Team) and Color3.new(0,0,0) or globalConfig.textColor
                btn.Parent = teamsScroll
                btn.MouseButton1Click:Connect(function()
                    aimbotData.targetTeam = plr.Team
                    refreshTeamsList()
                end)
            end
        end
        teamsScroll.CanvasSize = UDim2.new(0, 0, 0, teamsListLayout.AbsoluteContentSize.Y)
    end
    refreshTeamsList()

    -- Main Toggles
    createHeader("AIMBOT SETTINGS")

    local espToggleBtn = nil
    
    local function createToggle(name, key, callback)
        local btn = createButtonContainer()
        btn.Text = name .. ": " .. (aimbotData[key] and "ON" or "OFF")
        btn.TextColor3 = aimbotData[key] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        btn.TextStrokeTransparency = 0.3
        btn.TextStrokeColor3 = Color3.new(0,0,0)
        btn.Parent = contentScroll

        btn.MouseButton1Click:Connect(function()
            aimbotData[key] = not aimbotData[key]
            btn.Text = name .. ": " .. (aimbotData[key] and "ON" or "OFF")
            btn.TextColor3 = aimbotData[key] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
            
            if callback then
                callback(aimbotData[key])
            end
        end)
        
        return btn
    end

    createToggle("Aimbot Enabled", "enabled")
    createToggle("Smoothness", "smoothnessEnabled")
    createToggle("Wall Check", "wallCheck")
    createToggle("Prediction", "predictionEnabled")

    -- Aim Part Button
    local aimPartBtn = createButtonContainer()
    aimPartBtn.Text = "Aim Part: " .. (aimbotData.aimPart == "Head" and "HEAD" or "TORSO")
    aimPartBtn.TextColor3 = currentTheme.accent
    aimPartBtn.Parent = contentScroll
    aimPartBtn.MouseButton1Click:Connect(function()
        aimbotData.aimPart = aimbotData.aimPart == "Head" and "HumanoidRootPart" or "Head"
        aimPartBtn.Text = "Aim Part: " .. (aimbotData.aimPart == "Head" and "HEAD" or "TORSO")
    end)

    -- Sliders
    createHeader("FINE TUNING")

    local function createSlider(labelText, dataKey, minVal, maxVal, isInt)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 55)
        container.BackgroundTransparency = 1
        container.Parent = contentScroll

        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, 0, 0, 22)
        label.BackgroundTransparency = 1
        label.Text = labelText .. ": " .. aimbotData[dataKey]
        label.Font = Enum.Font.GothamBold
        label.TextSize = 15
        label.TextColor3 = globalConfig.textColor

        local sliderFrame = Instance.new("Frame", container)
        sliderFrame.Size = UDim2.new(1, 0, 0, 10)
        sliderFrame.Position = UDim2.new(0, 0, 0, 28)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(40,40,50)
        Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 5)

        local fill = Instance.new("Frame", sliderFrame)
        fill.BackgroundColor3 = currentTheme.accent
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)

        local drag = Instance.new("TextButton", sliderFrame)
        drag.Size = UDim2.new(0, 18, 0, 18)
        drag.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", drag).CornerRadius = UDim.new(1, 0)
        drag.Text = ""

        local dragging = false
        drag.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((i.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                drag.Position = UDim2.new(percent, -9, 0.5, -9)

                local value = minVal + percent * (maxVal - minVal)
                if isInt then value = math.floor(value) else value = math.round(value * 100) / 100 end

                aimbotData[dataKey] = value
                label.Text = labelText .. ": " .. value
            end
        end)

        local initP = (aimbotData[dataKey] - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(initP, 0, 1, 0)
        drag.Position = UDim2.new(initP, -9, 0.5, -9)
    end

    createSlider("Smoothness", "smoothness", 0.1, 1, false)
    createSlider("Prediction Strength", "predictionAmount", 0, 0.5, false)

    -- ESP Section
    createHeader("ESP SETTINGS")

    -- ESP Master Toggle
    espToggleBtn = createToggle("Toggle ESP", "espEnabled", function(enabled)
        if enabled then
            startESP()
            notify("ESP Enabled - Select features below", Color3.fromRGB(100, 255, 100))
        else
            -- Immediately hide all ESP elements
            for plr, drawings in pairs(aimbotData.espDrawings) do
                if drawings.box then drawings.box.Visible = false end
                if drawings.nameText then drawings.nameText.Visible = false end
                if drawings.healthText then drawings.healthText.Visible = false end
                if drawings.tracer then drawings.tracer.Visible = false end
                if drawings.skeleton then
                    for _, line in pairs(drawings.skeleton) do
                        if line then line.Visible = false end
                    end
                end
            end
            
            for _, hl in pairs(aimbotData.espHighlights) do
                if hl then hl.Enabled = false end
            end
            
            aimbotData.espEnabled = false
            
            task.delay(0.1, function()
                for _, drawings in pairs(aimbotData.espDrawings) do
                    for name, obj in pairs(drawings) do 
                        if typeof(obj) == "table" then
                            for _, line in pairs(obj) do if line then line:Remove() end end
                        elseif obj then 
                            obj:Remove() 
                        end 
                    end
                end
                for _, hl in pairs(aimbotData.espHighlights) do
                    if hl then hl:Destroy() end
                end
                aimbotData.espDrawings = {}
                aimbotData.espHighlights = {}
            end)
            
            notify("ESP Disabled", Color3.fromRGB(255, 100, 100))
        end
    end)

    -- All ESP feature toggles - start OFF by default
    createToggle("Box ESP", "espBoxEnabled")
    createToggle("Skeleton", "espSkeletonEnabled")
    createToggle("Tracers", "espTracersEnabled")
    createToggle("Chams (Wallhack)", "espChamsEnabled")
    createToggle("Health Text", "espHealthTextEnabled")

    local styleBtn = createButtonContainer()
    styleBtn.Text = "Box Style: " .. aimbotData.espBoxStyle
    styleBtn.TextColor3 = currentTheme.accent
    styleBtn.Parent = contentScroll
    styleBtn.MouseButton1Click:Connect(function()
        aimbotData.espBoxStyle = aimbotData.espBoxStyle == "Full" and "Corner" or "Full"
        styleBtn.Text = "Box Style: " .. aimbotData.espBoxStyle
    end)

    createToggle("Filled Box", "espFilledBox")

    aimbotData.panel = panel

    -- Aimbot Logic
    local function isValidTarget(plr)
        if not plr or plr == client or not plr.Character then return false end
        local char = plr.Character
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return false end

        if aimbotData.targetTeam then
            if not plr.Team or plr.Team ~= aimbotData.targetTeam then return false end
        elseif aimbotData.teamCheck and client.Team and plr.Team and client.Team == plr.Team then
            return false
        end

        if aimbotData.wallCheck then
            local cam = workspace.CurrentCamera
            local root = char:FindFirstChild(aimbotData.aimPart) or char:FindFirstChild("HumanoidRootPart")
            if not root then return false end
            local origin = cam.CFrame.Position
            local dir = root.Position - origin
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {client.Character or Instance.new("Folder")}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local result = workspace:Raycast(origin, dir, params)
            if result and not char:IsAncestorOf(result.Instance) then return false end
        end
        return true
    end

    local function getPredictedPosition(rootPart)
        local pos = rootPart.Position
        if aimbotData.predictionEnabled and rootPart.AssemblyLinearVelocity then
            local vel = rootPart.AssemblyLinearVelocity
            local dist = (pos - workspace.CurrentCamera.CFrame.Position).Magnitude
            pos = pos + vel * (dist / 220) * aimbotData.predictionAmount
        end
        return pos
    end

    local function getClosestPlayer()
        local closest, closestDist = nil, math.huge
        local mousePos = UserInputService:GetMouseLocation()
        local cam = workspace.CurrentCamera

        for _, plr in ipairs(Players:GetPlayers()) do
            if isValidTarget(plr) then
                local root = plr.Character:FindFirstChild(aimbotData.aimPart) or plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local predicted = getPredictedPosition(root)
                    local screenPos, onScreen = cam:WorldToViewportPoint(predicted)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = plr
                        end
                    end
                end
            end
        end
        return closest
    end

    aimbotData.connection = RunService.RenderStepped:Connect(function()
        if not (aimbotData.enabled and aimbotData.rightClickHeld) then return end

        local target = getClosestPlayer()
        if not target or not target.Character then return end

        local root = target.Character:FindFirstChild(aimbotData.aimPart) or target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local predictedPos = getPredictedPosition(root)
        local screenPos = workspace.CurrentCamera:WorldToViewportPoint(predictedPos)
        local mousePos = UserInputService:GetMouseLocation()
        local targetScreen = Vector2.new(screenPos.X, screenPos.Y)

        local moveVec = aimbotData.smoothnessEnabled 
            and mousePos:Lerp(targetScreen, 1 - aimbotData.smoothness) 
            or targetScreen

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
        end
    end)

    -- FIXED ESP System - Optimized for distance and performance
    function startESP()
        if aimbotData.espConnection then return end

        -- Use Heartbeat instead of RenderStepped for better performance [^11^]
        aimbotData.espConnection = RunService.Heartbeat:Connect(function()
            if not aimbotData.espEnabled then 
                -- Hide all drawings immediately
                for _, drawings in pairs(aimbotData.espDrawings) do
                    if drawings.box then drawings.box.Visible = false end
                    if drawings.nameText then drawings.nameText.Visible = false end
                    if drawings.healthText then drawings.healthText.Visible = false end
                    if drawings.tracer then drawings.tracer.Visible = false end
                    if drawings.skeleton then
                        for _, line in pairs(drawings.skeleton) do
                            if line then line.Visible = false end
                        end
                    end
                end
                for _, hl in pairs(aimbotData.espHighlights) do
                    if hl then hl.Enabled = false end
                end
                return 
            end

            local cam = workspace.CurrentCamera
            local localPlayer = client
            local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if not localRoot then return end -- Don't run if local player has no character

            local localPos = localRoot.Position

            -- Clean up disconnected players first
            for plr, drawings in pairs(aimbotData.espDrawings) do
                if not plr.Parent then
                    for name, obj in pairs(drawings) do 
                        if typeof(obj) == "table" then
                            for _, line in pairs(obj) do if line then line:Remove() end end
                        elseif obj then 
                            obj:Remove() 
                        end 
                    end
                    aimbotData.espDrawings[plr] = nil
                end
            end

            -- Process players with distance check
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == localPlayer then continue end

                local char = plr.Character
                -- CRITICAL FIX: Hide ESP if player is too far or has no character
                if not char then 
                    if aimbotData.espDrawings[plr] then
                        for _, obj in pairs(aimbotData.espDrawings[plr]) do 
                            if typeof(obj) == "table" then
                                for _, line in pairs(obj) do if line then line.Visible = false end end
                            elseif obj then 
                                obj.Visible = false
                            end 
                        end
                    end
                    continue 
                end

                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                local head = char:FindFirstChild("Head")
                
                -- CRITICAL FIX: Distance check - don't render if too far
                if not root or not hum or hum.Health <= 0 then
                    if aimbotData.espDrawings[plr] then
                        for _, obj in pairs(aimbotData.espDrawings[plr]) do 
                            if typeof(obj) == "table" then
                                for _, line in pairs(obj) do if line then line.Visible = false end end
                            elseif obj then 
                                obj.Visible = false
                            end 
                        end
                    end
                    if aimbotData.espHighlights[plr] then
                        aimbotData.espHighlights[plr].Enabled = false
                    end
                    continue
                end

                -- Distance check - max 1000 studs
                local distance = (root.Position - localPos).Magnitude
                if distance > aimbotData.espMaxDistance then
                    -- Hide ESP for far away players instead of keeping them visible
                    if aimbotData.espDrawings[plr] then
                        for _, obj in pairs(aimbotData.espDrawings[plr]) do 
                            if typeof(obj) == "table" then
                                for _, line in pairs(obj) do if line then line.Visible = false end end
                            elseif obj then 
                                obj.Visible = false
                            end 
                        end
                    end
                    if aimbotData.espHighlights[plr] then
                        aimbotData.espHighlights[plr].Enabled = false
                    end
                    continue
                end

                local teamColor = plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255,255,255)
                
                local torsoCenter = root.Position
                local headPos = head and head.Position or (root.Position + Vector3.new(0, 2.5, 0))
                local legPos = root.Position - Vector3.new(0, 3, 0)
                
                local screenPos, onScreen = cam:WorldToViewportPoint(torsoCenter)
                
                -- Initialize drawings if needed
                if not aimbotData.espDrawings[plr] then
                    aimbotData.espDrawings[plr] = {
                        box = Drawing.new("Square"),
                        nameText = Drawing.new("Text"),
                        healthText = Drawing.new("Text"),
                        tracer = Drawing.new("Line"),
                        skeleton = {}
                    }
                    
                    for i = 1, #SKELETON_JOINTS do
                        local line = Drawing.new("Line")
                        line.Thickness = 1.5
                        line.Transparency = 0.8
                        aimbotData.espDrawings[plr].skeleton[i] = line
                    end
                    
                    local d = aimbotData.espDrawings[plr]
                    d.box.Thickness = 2
                    d.box.Filled = aimbotData.espFilledBox
                    d.nameText.Size = 16
                    d.nameText.Center = true
                    d.nameText.Outline = true
                    d.healthText.Size = 15
                    d.healthText.Center = true
                    d.healthText.Outline = true
                    d.tracer.Thickness = 1.5
                    d.tracer.Transparency = 0.7
                end

                local d = aimbotData.espDrawings[plr]
                local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

                -- Hide if off screen
                if not onScreen then
                    d.box.Visible = false
                    d.nameText.Visible = false
                    d.healthText.Visible = false
                    d.tracer.Visible = false
                    for _, line in pairs(d.skeleton) do line.Visible = false end
                    if aimbotData.espHighlights[plr] then
                        aimbotData.espHighlights[plr].Enabled = false
                    end
                    continue
                end

                -- Box ESP
                if aimbotData.espBoxEnabled then
                    local headScreen, headVisible = cam:WorldToViewportPoint(headPos)
                    local legScreen, legVisible = cam:WorldToViewportPoint(legPos)
                    
                    if headVisible and legVisible then
                        local height = math.abs(headScreen.Y - legScreen.Y) * 1.1
                        local width = height * 0.55

                        d.box.Visible = true
                        d.box.Color = teamColor
                        d.box.Filled = aimbotData.espFilledBox
                        d.box.Size = Vector2.new(width, height)
                        d.box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height/2)
                    else
                        d.box.Visible = false
                    end
                else
                    d.box.Visible = false
                end

                -- Skeleton ESP
                if aimbotData.espSkeletonEnabled then
                    for i, joint in ipairs(SKELETON_JOINTS) do
                        local part1 = char:FindFirstChild(joint[1])
                        local part2 = char:FindFirstChild(joint[2])
                        local line = d.skeleton[i]
                        
                        if part1 and part2 then
                            local pos1, vis1 = cam:WorldToViewportPoint(part1.Position)
                            local pos2, vis2 = cam:WorldToViewportPoint(part2.Position)
                            
                            if vis1 and vis2 then
                                line.Visible = true
                                line.Color = teamColor
                                line.From = Vector2.new(pos1.X, pos1.Y)
                                line.To = Vector2.new(pos2.X, pos2.Y)
                            else
                                line.Visible = false
                            end
                        else
                            line.Visible = false
                        end
                    end
                else
                    for _, line in pairs(d.skeleton) do line.Visible = false end
                end

                -- Name
                d.nameText.Visible = true
                d.nameText.Text = "@" .. plr.Name
                d.nameText.Color = teamColor
                local boxHeight = aimbotData.espBoxEnabled and d.box.Size.Y or 60
                d.nameText.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight/2 - 20)

                -- Health Text
                if aimbotData.espHealthTextEnabled then
                    d.healthText.Visible = true
                    d.healthText.Text = math.floor(hum.Health) .. " HP"
                    d.healthText.Color = healthPercent > 0.6 and Color3.fromRGB(80,255,80) or (healthPercent > 0.3 and Color3.fromRGB(255,220,60) or Color3.fromRGB(255,70,70))
                    d.healthText.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight/2 - 5)
                else
                    d.healthText.Visible = false
                end

                -- Tracers
                if aimbotData.espTracersEnabled then
                    d.tracer.Visible = true
                    d.tracer.Color = teamColor
                    d.tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    d.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    d.tracer.Visible = false
                end

                -- Chams
                if aimbotData.espChamsEnabled then
                    if not aimbotData.espHighlights[plr] then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = char
                        hl.FillColor = teamColor
                        hl.OutlineColor = Color3.new(1,1,1)
                        hl.FillTransparency = 0.75
                        hl.OutlineTransparency = 0.2
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = panel
                        aimbotData.espHighlights[plr] = hl
                    else
                        aimbotData.espHighlights[plr].Enabled = true
                        aimbotData.espHighlights[plr].FillColor = teamColor
                    end
                elseif aimbotData.espHighlights[plr] then
                    aimbotData.espHighlights[plr].Enabled = false
                end
            end
        end)
    end

    
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
-- PANEL MANAGEMENT
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
-- LOGS PANEL
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
-- STOPWATCH PANEL
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
-- REMOVE WAYPOINT
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
-- ============================================
-- TRACER SYSTEM - Improved & Fixed
-- ============================================

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
    
    -- Optional: add texture for better look
    -- beam.Texture = TRACER_SETTINGS.texture
    -- beam.TextureLength = TRACER_SETTINGS.textureLength
    -- beam.TextureMode = TRACER_SETTINGS.textureMode
    
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
    
    notify(prefix .. cmd, Color3.fromRGB(180, 180, 255))
    local target = getPlr(args[1] or "me")
    
    if cmd == "aimbot" then 
        createAimbotPanel()
    elseif cmd == "bring" then 
        bring(target)
    elseif cmd == "clicktp" then 
        clickTP()
    elseif cmd == "cmdbar" then
        toggleCmdBar()
    elseif cmd == "console" then 
        console()
    elseif cmd == "dance" then 
        dance(target)
    elseif cmd == "destroyscript" then
        destroyScript()
    elseif cmd == "disablefalldamage" then 
        disableFallDamage()
    elseif cmd == "enable" then
        local what = args[1] or ""
        if what == "inventory" or what == "playerlist" then
            enableCore(what)
        end
    elseif cmd == "esp" then
        if args[1] == "all" then 
            enableESPAll()
        else 
            notify("Bleh", Color3.fromRGB(255, 200, 100))
        end
    elseif cmd == "unesp" then
        if args[1] == "all" then 
            disableESPAll()
        else 
            notify("I love femboys", Color3.fromRGB(255, 200, 100))
        end
    elseif cmd == "explode" then 
        explode(target)
    elseif cmd == "fire" then 
        fire(target)
    elseif cmd == "unfire" then 
        unfire(target)
    elseif cmd == "firstp" then 
        firstp()
	elseif cmd == "fling" then
    TouchFling:CreateGUI()
    StarterGui:SetCore("SendNotification", {
        Title = "Touch Fling", 
        Text = "GUI Opened", 
        Duration = 3
    })

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
	elseif cmd == "fly" then 
    fly(target, args[2])
	elseif cmd == "unfly" then 
    unfly(target)
    FlySystem:StopFly()
    elseif cmd == "freecam" then 
        enableFreecam()
    elseif cmd == "unfreecam" then 
        disableFreecam()
    elseif cmd == "freeze" then 
        freeze(target)
    elseif cmd == "unfreeze" then 
        unfreeze(target)
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
    elseif cmd == "unnoclip" then 
        unnoclip(target)
    elseif cmd == "ping" then 
        ping()
    elseif cmd == "ragdoll" then 
        ragdoll(client)
    elseif cmd == "unragdoll" then 
        unragdoll(client)
    elseif cmd == "rainbow" then 
        rainbow(target)
    elseif cmd == "unrainbow" then 
        unrainbow(target)
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
    elseif cmd == "unspin" then 
        unspin(client)
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

elseif cmd == "untracers" then
    tracerSystem:Disable()
    StarterGui:SetCore("SendNotification", {
        Title = "Tracers", 
        Text = "Disabled - All tracers cleared", 
        Duration = 3
    })
    elseif cmd == "view" then 
        view(target)
    elseif cmd == "unview" then 
        unview()
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
-- MAIN GUI - SOLID TEXT
-- =============================================================
lunarGui = Instance.new("ScreenGui")
lunarGui.Name = "LunarGui"
lunarGui.ResetOnSpawn = false
lunarGui.Enabled = false
lunarGui.DisplayOrder = 999999
lunarGui.Parent = client.PlayerGui

mainFrame = Instance.new("Frame", lunarGui)
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(1, -420, 0.5, -300)
mainFrame.BackgroundColor3 = currentTheme.glass
mainFrame.Active = true
mainFrame.Draggable = true
applyGlassEffect(mainFrame, globalConfig.uiTransparency, globalConfig.strokeTransparency)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "Lunar Hub"
title.Font = Enum.Font.GothamBlack
title.TextSize = 32
title.TextColor3 = currentTheme.accent
title.TextTransparency = 0 -- SOLID
title.TextStrokeTransparency = 0.5
title.TextStrokeColor3 = Color3.new(0,0,0)

-- Tabs
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, -20, 0, 50)
tabBar.Position = UDim2.new(0, 10, 0, 70)
tabBar.BackgroundTransparency = 1

local cmdTab = Instance.new("TextButton", tabBar)
cmdTab.Size = UDim2.new(0.5, -5, 1, 0)
cmdTab.BackgroundColor3 = currentTheme.accent
cmdTab.Text = "Commands"
cmdTab.Font = Enum.Font.GothamBold
cmdTab.TextSize = 18
cmdTab.TextColor3 = Color3.new(0,0,0)
cmdTab.TextTransparency = 0 -- SOLID
cmdTab.TextStrokeTransparency = 0.5
cmdTab.TextStrokeColor3 = Color3.new(1,1,1)
applyGlassEffect(cmdTab, 0.2, 0.4)

local settingsTab = Instance.new("TextButton", tabBar)
settingsTab.Size = UDim2.new(0.5, -5, 1, 0)
settingsTab.Position = UDim2.new(0.5, 5, 0, 0)
settingsTab.BackgroundColor3 = currentTheme.btn
settingsTab.Text = "Settings"
settingsTab.Font = Enum.Font.GothamBold
settingsTab.TextSize = 18
settingsTab.TextColor3 = globalConfig.textColor
settingsTab.TextTransparency = 0 -- SOLID
settingsTab.TextStrokeTransparency = 0.5
settingsTab.TextStrokeColor3 = Color3.new(0,0,0)
applyGlassEffect(settingsTab, 0.2, 0.5)

-- Commands tab
local cmdFrame = Instance.new("Frame", mainFrame)
cmdFrame.Size = UDim2.new(1, -20, 1, -130)
cmdFrame.Position = UDim2.new(0, 10, 0, 130)
cmdFrame.BackgroundTransparency = 1

local search = Instance.new("TextBox", cmdFrame)
search.Size = UDim2.new(1, 0, 0, 40)
search.BackgroundColor3 = currentTheme.list
search.PlaceholderText = "Search commands..."
search.Font = Enum.Font.Gotham
search.TextSize = 16
search.TextColor3 = globalConfig.textColor
search.TextTransparency = 0 -- SOLID
search.TextStrokeTransparency = 0.5
search.TextStrokeColor3 = Color3.new(0,0,0)
applyGlassEffect(search, 0.3, 0.6)

local scroll = Instance.new("ScrollingFrame", cmdFrame)
scroll.Size = UDim2.new(1, 0, 1, -50)
scroll.Position = UDim2.new(0, 0, 0, 50)
scroll.BackgroundTransparency = 0.3
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = currentTheme.accent
applyGlassEffect(scroll, 0.4, 0.7)

local uiList = Instance.new("UIListLayout", scroll)
uiList.Padding = UDim.new(0, 8)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

-- Command descriptions for hover tooltips
local commandDescriptions = {
    ["!aimbot"] = "Opens aimbot control panel with FOV and smoothness settings",
    ["!clicktp"] = "Toggle click teleport - click anywhere to teleport",
    ["!cmdbar"] = "Toggle command bar with autocomplete",
    ["!console"] = "Opens Roblox developer console",
    ["!dance [plr]"] = "Makes player dance",
    ["!destroyscript"] = "Removes all UI and stops all scripts",
    ["!disablefalldamage"] = "Working on this",
    ["!enable inventory"] = "Toggle backpack visibility",
    ["!enable playerlist"] = "Toggle player list visibility",
    ["!esp all"] = "Enable ESP on all players with team colors and names",
    ["!unesp all"] = "Disable ESP on all players",
    ["!explode [plr]"] = "Creates explosion at player position",
    ["!fire [plr]"] = "Sets player on fire",
    ["!unfire [plr]"] = "Extinguishes player",
    ["!firstp"] = "Enable first person mode",
    ["!fling"] = "Summons the Touch Fling GUI",
	["!unfling"] = "Destroys the Touch Fling GUI and resets all features",
    ["!fly"] = "Opens Advanced Fly control panel",
	["!unfly"] = "Stops flying and closes GUI",
	["!flyspeed [num]"] = "Set fly speed (1-10000)",
    ["!freecam"] = "Enables free camera mouse control",
    ["!unfreecam"] = "Disables free camera",
    ["!freeze [plr]"] = "Freezes player in place",
    ["!unfreeze [plr]"] = "Unfreezes player",
    ["!joinlogs"] = "Opens panel showing player joins/leaves",
    ["!jump [power]"] = "Sets jump power",
    ["!kill [plr/all/me]"] = "You can only kill your character",
    ["!lay"] = "Makes character lay down",
    ["!leave"] = "Force leaves the game",
    ["!logs"] = "Opens chat logs panel",
    ["!noclip [plr]"] = "Enables walking through walls",
    ["!unnoclip [plr]"] = "Disables noclip",
    ["!ping"] = "Shows current ping",
    ["!ragdoll"] = "Makes character ragdoll",
    ["!unragdoll"] = "Stops ragdoll",
    ["!rainbow [plr]"] = "Makes player cycle through colors",
    ["!unrainbow [plr]"] = "Stops rainbow effect",
    ["!rejoin"] = "Rejoins current server",
    ["!removewaypoint"] = "Removes last placed waypoint",
    ["!sit"] = "Makes character sit",
    ["!speed [plr] [num]"] = "Opens speed panel or sets walkspeed",
    ["!spin [speed]"] = "Spins character in place",
    ["!unspin"] = "Stops spinning",
    ["!stopwatch"] = "Opens stopwatch panel",
    ["!thirdp"] = "Enable third person mode",
    ["!to [plr]"] = "Teleport to player",
    ["!trip [plr]"] = "Makes player trip",
    ["!tracers"] = "Shows lines to all players",
    ["!untracers"] = "Hides tracers",
    ["!unlockmouse"] = "Toggle F key to unlock/lock mouse in FPS games",
    ["!view [plr]"] = "Spectate player (free look enabled)",
    ["!unview"] = "Stop spectating",
    ["!waypoint"] = "Creates waypoint at current position",
    ["!fov [1-120]"] = "Sets camera field of view",
    ["!kick [plr]"] = "You can only kick yourself"
}

-- Alphabetical command list
local cmds = {
    "!aimbot", "!clicktp", "!cmdbar", "!console", "!dance [plr]",
    "!destroyscript", "!disablefalldamage", "!enable inventory", "!enable playerlist",
    "!esp all", "!unesp all", "!explode [plr]", "!fire [plr]", "!unfire [plr]",
    "!firstp", "!fling", "!unfling", "!fly", "!unfly", "!flyspeed [num]", "!freecam",
    "!unfreecam", "!freeze [plr]", "!unfreeze [plr]", "!joinlogs", "!jump [power]",
	"!kill [plr/all/me]", "!lay", "!leave", "!logs",
    "!noclip [plr]", "!unnoclip [plr]", "!ping", "!ragdoll", "!unragdoll",
    "!rainbow [plr]", "!unrainbow [plr]", "!rejoin", "!removewaypoint",
	"!sit", "!speed [plr] [num]", "!spin [speed]", "!unspin",
    "!stopwatch", "!thirdp", "!to [plr]", "!trip [plr]",
    "!tracers", "!untracers", "!unlockmouse", "!view [plr]", "!unview", "!waypoint",
    "!fov [1-120]", "!kick [plr]"
}

for i, cmdStr in ipairs(cmds) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 44)
    btn.BackgroundColor3 = currentTheme.list
    btn.BackgroundTransparency = 0.2
    btn.Text = " " .. cmdStr
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.TextColor3 = globalConfig.textColor
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextTransparency = 0 -- SOLID
    btn.TextStrokeTransparency = 0.5
    btn.TextStrokeColor3 = Color3.new(0,0,0)
    applyGlassEffect(btn, 0.4, 0.7)
    btn.Parent = scroll
    btn.LayoutOrder = i
    
    local desc = commandDescriptions[cmdStr]
    if desc then
        btn.MouseEnter:Connect(function()
            btn.Text = " " .. cmdStr .. " - " .. desc
            btn.TextColor3 = currentTheme.accent
        end)
        btn.MouseLeave:Connect(function()
            btn.Text = " " .. cmdStr
            btn.TextColor3 = globalConfig.textColor
        end)
    end
    
    btn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(cmdStr)
            notify("Copied: " .. cmdStr, Color3.fromRGB(100, 255, 100))
        end
    end)
end

scroll.CanvasSize = UDim2.new(0,0,0, #cmds * 52)
search:GetPropertyChangedSignal("Text"):Connect(function()
    local filter = search.Text:lower()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child.Visible = filter == "" or child.Text:lower():find(filter, 1, true)
        end
    end
end)

-- Settings tab
local settingsFrame = Instance.new("Frame", mainFrame)
settingsFrame.Size = UDim2.new(1, -20, 1, -130)
settingsFrame.Position = UDim2.new(0, 10, 0, 130)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Visible = false

local settingsScroll = Instance.new("ScrollingFrame", settingsFrame)
settingsScroll.Size = UDim2.new(1, 0, 1, 0)
settingsScroll.BackgroundTransparency = 0.3
settingsScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
settingsScroll.ScrollBarThickness = 8
settingsScroll.ScrollBarImageColor3 = currentTheme.accent
applyGlassEffect(settingsScroll, 0.4, 0.7)

local settingsList = Instance.new("UIListLayout", settingsScroll)
settingsList.Padding = UDim.new(0, 15)
settingsList.SortOrder = Enum.SortOrder.LayoutOrder

-- Prefix Section
local prefixSection = Instance.new("Frame", settingsScroll)
prefixSection.Size = UDim2.new(1, -20, 0, 100)
prefixSection.BackgroundColor3 = currentTheme.btn
prefixSection.BackgroundTransparency = 0.3
applyGlassEffect(prefixSection, 0.3, 0.6)

local prefixTitle = Instance.new("TextLabel", prefixSection)
prefixTitle.Size = UDim2.new(1, 0, 0, 30)
prefixTitle.Position = UDim2.new(0, 0, 0, 5)
prefixTitle.BackgroundTransparency = 1
prefixTitle.Text = "COMMAND PREFIX"
prefixTitle.Font = Enum.Font.GothamBlack
prefixTitle.TextSize = 18
prefixTitle.TextColor3 = currentTheme.accent
prefixTitle.TextTransparency = 0 -- SOLID
prefixTitle.TextStrokeTransparency = 0.5
prefixTitle.TextStrokeColor3 = Color3.new(0,0,0)

local prefixInput = Instance.new("TextBox", prefixSection)
prefixInput.Size = UDim2.new(0.8, 0, 0, 40)
prefixInput.Position = UDim2.new(0.1, 0, 0, 45)
prefixInput.BackgroundColor3 = currentTheme.list
prefixInput.Text = prefix
prefixInput.Font = Enum.Font.GothamBold
prefixInput.TextSize = 20
prefixInput.TextColor3 = globalConfig.textColor
prefixInput.TextTransparency = 0 -- SOLID
prefixInput.TextStrokeTransparency = 0.5
prefixInput.TextStrokeColor3 = Color3.new(0,0,0)
applyGlassEffect(prefixInput, 0.25, 0.5)

prefixInput.FocusLost:Connect(function(enter)
    if enter then
        prefix = prefixInput.Text ~= "" and prefixInput.Text or "!"
        notify("Prefix changed to: " .. prefix, currentTheme.accent)
    end
end)

-- Text Color Section
local colorSection = Instance.new("Frame", settingsScroll)
colorSection.Size = UDim2.new(1, -20, 0, 150)
colorSection.BackgroundColor3 = currentTheme.btn
colorSection.BackgroundTransparency = 0.3
applyGlassEffect(colorSection, 0.3, 0.6)

local colorTitle = Instance.new("TextLabel", colorSection)
colorTitle.Size = UDim2.new(1, 0, 0, 30)
colorTitle.Position = UDim2.new(0, 0, 0, 5)
colorTitle.BackgroundTransparency = 1
colorTitle.Text = "TEXT COLOR"
colorTitle.Font = Enum.Font.GothamBlack
colorTitle.TextSize = 18
colorTitle.TextColor3 = currentTheme.accent
colorTitle.TextTransparency = 0 -- SOLID
colorTitle.TextStrokeTransparency = 0.5
colorTitle.TextStrokeColor3 = Color3.new(0,0,0)

local colorDisplay = Instance.new("TextLabel", colorSection)
colorDisplay.Size = UDim2.new(0.8, 0, 0, 30)
colorDisplay.Position = UDim2.new(0.1, 0, 0, 40)
colorDisplay.BackgroundColor3 = globalConfig.textColor
colorDisplay.Text = "Preview Text"
colorDisplay.Font = Enum.Font.GothamBold
colorDisplay.TextSize = 16
colorDisplay.TextColor3 = Color3.new(0,0,0)
colorDisplay.TextTransparency = 0 -- SOLID
colorDisplay.TextStrokeTransparency = 0.5
colorDisplay.TextStrokeColor3 = Color3.new(1,1,1)
applyGlassEffect(colorDisplay, 0, 0.4)

-- RGB Sliders
local rSlider = Instance.new("Frame", colorSection)
rSlider.Size = UDim2.new(0.8, 0, 0, 8)
rSlider.Position = UDim2.new(0.1, 0, 0, 80)
rSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
applyGlassEffect(rSlider, 0.3, 0.7)

local rFill = Instance.new("Frame", rSlider)
rFill.Size = UDim2.new(globalConfig.textColor.R, 0, 1, 0)
rFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
rFill.BorderSizePixel = 0
Instance.new("UICorner", rFill).CornerRadius = UDim.new(0, 4)

local gSlider = Instance.new("Frame", colorSection)
gSlider.Size = UDim2.new(0.8, 0, 0, 8)
gSlider.Position = UDim2.new(0.1, 0, 0, 95)
gSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
applyGlassEffect(gSlider, 0.3, 0.7)

local gFill = Instance.new("Frame", gSlider)
gFill.Size = UDim2.new(globalConfig.textColor.G, 0, 1, 0)
gFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
gFill.BorderSizePixel = 0
Instance.new("UICorner", gFill).CornerRadius = UDim.new(0, 4)

local bSlider = Instance.new("Frame", colorSection)
bSlider.Size = UDim2.new(0.8, 0, 0, 8)
bSlider.Position = UDim2.new(0.1, 0, 0, 110)
bSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
applyGlassEffect(bSlider, 0.3, 0.7)

local bFill = Instance.new("Frame", bSlider)
bFill.Size = UDim2.new(globalConfig.textColor.B, 0, 1, 0)
bFill.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
bFill.BorderSizePixel = 0
Instance.new("UICorner", bFill).CornerRadius = UDim.new(0, 4)

local function setupColorSlider(slider, fill, colorComponent)
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            
            local newColor = Color3.new(
                colorComponent == "R" and pos or globalConfig.textColor.R,
                colorComponent == "G" and pos or globalConfig.textColor.G,
                colorComponent == "B" and pos or globalConfig.textColor.B
            )
            globalConfig.textColor = newColor
            colorDisplay.BackgroundColor3 = newColor
            
            -- Update all text elements in LunarGui
            if lunarGui then
                for _, obj in ipairs(lunarGui:GetDescendants()) do
                    if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.TextColor3 ~= currentTheme.accent then
                        obj.TextColor3 = newColor
                    end
                end
            end
        end
    end)
end

setupColorSlider(rSlider, rFill, "R")
setupColorSlider(gSlider, gFill, "G")
setupColorSlider(bSlider, bFill, "B")

-- Transparency Section - FIXED
local transSection = Instance.new("Frame", settingsScroll)
transSection.Size = UDim2.new(1, -20, 0, 100)
transSection.BackgroundColor3 = currentTheme.btn
transSection.BackgroundTransparency = 0.3
applyGlassEffect(transSection, 0.3, 0.6)

local transTitle = Instance.new("TextLabel", transSection)
transTitle.Size = UDim2.new(1, 0, 0, 30)
transTitle.Position = UDim2.new(0, 0, 0, 5)
transTitle.BackgroundTransparency = 1
transTitle.Text = "UI TRANSPARENCY"
transTitle.Font = Enum.Font.GothamBlack
transTitle.TextSize = 18
transTitle.TextColor3 = currentTheme.accent
transTitle.TextTransparency = 0 -- SOLID
transTitle.TextStrokeTransparency = 0.5
transTitle.TextStrokeColor3 = Color3.new(0,0,0)

local transLabel = Instance.new("TextLabel", transSection)
transLabel.Size = UDim2.new(1, 0, 0, 25)
transLabel.Position = UDim2.new(0, 0, 0, 35)
transLabel.BackgroundTransparency = 1
transLabel.Text = "Transparency: " .. math.round(globalConfig.uiTransparency * 100) .. "%"
transLabel.Font = Enum.Font.GothamBold
transLabel.TextSize = 16
transLabel.TextColor3 = globalConfig.textColor
transLabel.TextTransparency = 0 -- SOLID
transLabel.TextStrokeTransparency = 0.5
transLabel.TextStrokeColor3 = Color3.new(0,0,0)

local transSlider = Instance.new("Frame", transSection)
transSlider.Size = UDim2.new(0.8, 0, 0, 12)
transSlider.Position = UDim2.new(0.1, 0, 0, 65)
transSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
applyGlassEffect(transSlider, 0.3, 0.7)

local transFill = Instance.new("Frame", transSlider)
transFill.Size = UDim2.new(globalConfig.uiTransparency, 0, 1, 0)
transFill.BackgroundColor3 = currentTheme.accent
transFill.BorderSizePixel = 0
Instance.new("UICorner", transFill).CornerRadius = UDim.new(0, 6)

local transDrag = Instance.new("TextButton", transSlider)
transDrag.Size = UDim2.new(0, 20, 0, 20)
transDrag.Position = UDim2.new(globalConfig.uiTransparency, -10, 0.5, -10)
transDrag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
transDrag.Text = ""
Instance.new("UICorner", transDrag).CornerRadius = UDim.new(1, 0)

local draggingTrans = false
transDrag.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingTrans = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingTrans = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingTrans and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - transSlider.AbsolutePosition.X) / transSlider.AbsoluteSize.X, 0, 1)
        transFill.Size = UDim2.new(pos, 0, 1, 0)
        transDrag.Position = UDim2.new(pos, -10, 0.5, -10)
        globalConfig.uiTransparency = pos
        transLabel.Text = "Transparency: " .. math.round(pos * 100) .. "%"
        
        -- Update main frame transparency
        if mainFrame then
            mainFrame.BackgroundTransparency = pos
        end
    end
end)

-- Theme Section
local themeSection = Instance.new("Frame", settingsScroll)
themeSection.Size = UDim2.new(1, -20, 0, 200)
themeSection.BackgroundColor3 = currentTheme.btn
themeSection.BackgroundTransparency = 0.3
applyGlassEffect(themeSection, 0.3, 0.6)

local themeTitle = Instance.new("TextLabel", themeSection)
themeTitle.Size = UDim2.new(1, 0, 0, 30)
themeTitle.Position = UDim2.new(0, 0, 0, 5)
themeTitle.BackgroundTransparency = 1
themeTitle.Text = "THEME SELECTOR"
themeTitle.Font = Enum.Font.GothamBlack
themeTitle.TextSize = 18
themeTitle.TextColor3 = currentTheme.accent
themeTitle.TextTransparency = 0 -- SOLID
themeTitle.TextStrokeTransparency = 0.5
themeTitle.TextStrokeColor3 = Color3.new(0,0,0)

local themeContainer = Instance.new("Frame", themeSection)
themeContainer.Size = UDim2.new(1, -20, 0, 140)
themeContainer.Position = UDim2.new(0, 10, 0, 45)
themeContainer.BackgroundTransparency = 1

local themeGrid = Instance.new("UIGridLayout", themeContainer)
themeGrid.CellSize = UDim2.new(0.48, 0, 0, 50)
themeGrid.CellPadding = UDim2.new(0, 10, 0, 10)

for name, th in pairs(themes) do
    local btn = Instance.new("TextButton", themeContainer)
    btn.BackgroundColor3 = th.accent
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = th.text
    btn.TextTransparency = 0 -- SOLID
    btn.TextStrokeTransparency = 0.5
    btn.TextStrokeColor3 = Color3.new(0,0,0)
    applyGlassEffect(btn, 0.15, 0.4)
    
    btn.MouseButton1Click:Connect(function()
        currentTheme = th
        mainFrame.BackgroundColor3 = th.glass
        title.TextColor3 = th.accent
        cmdTab.BackgroundColor3 = th.accent
        settingsTab.BackgroundColor3 = th.btn
        search.BackgroundColor3 = th.list
        prefixInput.BackgroundColor3 = th.list
        
        -- Update all UI elements with new theme
        for _, obj in ipairs(lunarGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.TextColor3 == currentTheme.accent then
                obj.TextColor3 = th.accent
            end
        end
        
        notify("Theme changed to " .. name, th.accent)
    end)
end

-- Discord Section
local discordSection = Instance.new("Frame", settingsScroll)
discordSection.Size = UDim2.new(1, -20, 0, 100)
discordSection.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordSection.BackgroundTransparency = 0.2
applyGlassEffect(discordSection, 0.3, 0.6)

local discordTitle = Instance.new("TextLabel", discordSection)
discordTitle.Size = UDim2.new(1, 0, 0, 30)
discordTitle.Position = UDim2.new(0, 0, 0, 5)
discordTitle.BackgroundTransparency = 1
discordTitle.Text = "COMMUNITY"
discordTitle.Font = Enum.Font.GothamBlack
discordTitle.TextSize = 18
discordTitle.TextColor3 = Color3.new(1,1,1)
discordTitle.TextTransparency = 0 -- SOLID
discordTitle.TextStrokeTransparency = 0.5
discordTitle.TextStrokeColor3 = Color3.new(0,0,0)

local discordBtn = Instance.new("TextButton", discordSection)
discordBtn.Size = UDim2.new(0.9, 0, 0, 45)
discordBtn.Position = UDim2.new(0.05, 0, 0, 45)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Join Discord Server"
discordBtn.Font = Enum.Font.GothamBlack
discordBtn.TextSize = 18
discordBtn.TextColor3 = Color3.new(1,1,1)
discordBtn.TextTransparency = 0 -- SOLID
discordBtn.TextStrokeTransparency = 0.5
discordBtn.TextStrokeColor3 = Color3.new(0,0,0)
applyGlassEffect(discordBtn, 0.15, 0.4)

discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/5GeQAXYYcW")
        notify("Discord link copied to clipboard!", Color3.fromRGB(88,101,242))
    else
        notify("Clipboard not supported in this executor", Color3.fromRGB(255,100,100))
    end
end)

settingsScroll.CanvasSize = UDim2.new(0,0,0, 700)

-- Tab switching
cmdTab.MouseButton1Click:Connect(function()
    cmdFrame.Visible = true
    settingsFrame.Visible = false
    cmdTab.BackgroundColor3 = currentTheme.accent
    cmdTab.TextColor3 = Color3.new(0,0,0)
    settingsTab.BackgroundColor3 = currentTheme.btn
    settingsTab.TextColor3 = globalConfig.textColor
end)

settingsTab.MouseButton1Click:Connect(function()
    cmdFrame.Visible = false
    settingsFrame.Visible = true
    settingsTab.BackgroundColor3 = currentTheme.accent
    settingsTab.TextColor3 = Color3.new(0,0,0)
    cmdTab.BackgroundColor3 = currentTheme.btn
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
    label.Text = "Created By @LunarRbxZ"
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
------------------------------------------------------------------------------
----------------- UI OVERHEAD THING I MADE YEA -------------------------------
------------------------------------------------------------------------------
-- 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function createHubGUI(character)
    -- Remove old one
    for _, v in ipairs(player.PlayerGui:GetChildren()) do
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
    billboard.Parent = player.PlayerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(5, 10, 8)
    mainFrame.BackgroundTransparency = 0.65
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = billboard
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = mainFrame
    
    --  neon outline
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 120)
    stroke.Thickness = 2.2
    stroke.Transparency = 0.2
    stroke.Parent = mainFrame
    
    -- soft glow for blurry effect
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 255, 140)
    glow.Thickness = 8
    glow.Transparency = 0.88
    glow.Parent = mainFrame
    
    -- Lunar Hub
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.40, 0)
    title.BackgroundTransparency = 1
    title.Text = "LUNAR HUB"
    title.TextColor3 = Color3.fromRGB(0, 255, 100)
    title.TextScaled = true
    title.Font = Enum.Font.Code
    title.TextStrokeTransparency = .1
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.Parent = mainFrame
    
     -- Greetings (you can rename it to whatever you want)
    local greeting = Instance.new("TextLabel")
    greeting.Size = UDim2.new(.3, 10, 1, 10)
    greeting.BackgroundTransparency = 1
    greeting.Text = "Greetings ------------"
    greeting.TextColor3 = Color3.fromRGB(0, 255, 100)
    greeting.TextScaled = true
    greeting.Font = Enum.Font.Code
    greeting.TextStrokeTransparency = .1
    greeting.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    greeting.Parent = mainFrame

    -- Username + Time Container
    local bottomFrame = Instance.new("Frame")
    bottomFrame.Size = UDim2.new(1, 0, 0.60, 0)
    bottomFrame.Position = UDim2.new(0, 0, 0.40, 0)
    bottomFrame.BackgroundTransparency = 1
    bottomFrame.Parent = mainFrame

    -- Username
    local username = Instance.new("TextLabel")
    username.Size = UDim2.new(0.62, 0, 1.3, 0)
    username.BackgroundTransparency = 1
    username.Text = player.Name
    username.TextColor3 = Color3.fromRGB(180, 255, 200)
    username.TextScaled = true
    username.Font = Enum.Font.Code
    username.TextStrokeTransparency = 0.5
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = bottomFrame

    -- Local Time
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.30, 10, .5, 1)
    timeLabel.Position = UDim2.new(0.62, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.Code
    timeLabel.TextStrokeTransparency = 0.4
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = bottomFrame

    -- Live Time Updater
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not billboard.Parent then
            connection:Disconnect()
            return
        end
        timeLabel.Text = os.date("%I:%M %p")   -- Example: 11:45 PM
    end)
end

-- Auto create when character loads / respawns
player.CharacterAdded:Connect(createHubGUI)

if player.Character then
    createHubGUI(player.Character)
end

------------------------------------------------------------------------------
----------------- SAY GREETINGS IN CHAT --------------------------------------
------------------------------------------------------------------------------

-- ts was created by @xlunarxzzrbxx
-- Time-Based Greeting System or smt
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer

-- Get player's local hour (0-23) using their system time
local function getLocalHour()
    local currentTime = os.date("*t") 
    return currentTime.hour
end


local function getTimeBasedGreeting()
    local hour = getLocalHour()
    local username = player.Name
    
    -- 12:00 AM (0) to 10:59 AM (10) = Good Morning
    if hour >= 0 and hour < 11 then
        return "Good Morning, " .. username
    
    -- 11:00 AM (11) to 4:59 PM (16) = Good Afternoon  
    elseif hour >= 11 and hour < 17 then
        return "Good Afternoon, " .. username
    
    -- 5:00 PM (17) to 9:59 PM (21) = Good Evening
    elseif hour >= 17 and hour < 22 then
        return "Good Evening, " .. username
    
    -- 10:00 PM (22) to 11:59 PM (23) = Goodnight
    else
        return "Goodnight, " .. username
    end
end

TextChatService.TextChannels.ChildAdded:Connect(function(channel)
    if channel.Name == "RBXGeneral" then
        task.wait(0.1)
        channel:SendAsync(getTimeBasedGreeting())
    end
end)

task.spawn(function()
    task.wait(0.5)
    local channel = TextChatService:FindFirstChild("TextChannels", true):FindFirstChild("RBXGeneral")
    if channel then
        channel:SendAsync(getTimeBasedGreeting())
    end
end)
------------------------------------------------------------------------------
----------------- END OF IT LOL ----------------------------------------------
------------------------------------------------------------------------------

-- Chat handler
client.Chatted:Connect(processCmd)
