-- SES_GET3 ULTIMATE v0.74 | Pulse Hub Edition | MM2 + VoteDupe + Anim + Mascot + Invisible

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")

local SAVE_FILE = "ses_get3_config.json"
local Config = {
    ESP = true, AutoShoot = false, MagicBullet = false, AutoKill = false,
    AutoGrabGun = false, AntiFling = false, CoolGuy = false, FarmCoins = false,
    FarmResetBagFull = false, AutoAttackAfterFarm = true, FlingOnDeath = false,
    NoClip = false, PredictionMultiplier = 2.5, MurdererKillAllOnFull = false,
    SpeedHack = false, SpeedValue = 32, HighJump = false, JumpValue = 120,
    ESPColor = {0, 255, 0},
    BackTrack = false, BackTrackTarget = "Others", BackTrackStyle = "Ghost",
    BackTrackColor = "Shimmer", BackTrackMaterial = "ForceField",
    BackTrackOutline = true, BackTrackMarker = true, BackTrackDelay = 400,
    BackTrackCount = 4, BackTrackDist = 150, BackTrackOpacity = 70,
    BackTrackCustomColor = {105, 205, 255},
    Shader = false, ShaderPreset = "Natural",
    AuraEnabled = false, AuraStyle = "Energy", AuraCustomColor = {105, 205, 255},
    AuraIntensity = 55, AuraSize = 100,
    OrbsEnabled = false, OrbsStyle = "Invoker", OrbsCount = 3, OrbsSpeed = 100,
    OrbsRadius = 100, OrbsCustomColor = {120, 200, 255},
    SkyWormsEnabled = false, SkyWormsCount = 30, SkyWormsSpeed = 100,
    AvatarHeadless = false, AvatarKorblox = false,
    GunSkinEnabled = false, GunSkinModel = "Green", GunSkinSize = 100, GunSkinTurn = 0,
    Invisible = false,
}
local AVATAR_ID = "82234486684685"
local FlingOnDeathEnabled = false

local function loadConfig()
    if writefile and readfile and isfile then
        pcall(function()
            if isfile(SAVE_FILE) then
                local data = HttpService:JSONDecode(readfile(SAVE_FILE))
                for k, v in pairs(data) do if Config[k] ~= nil then Config[k] = v end end
            end
        end)
    end
end
local function saveConfig()
    if writefile then pcall(function() writefile(SAVE_FILE, HttpService:JSONEncode(Config)) end) end
end
local function deleteConfig()
    if delfile and isfile and isfile(SAVE_FILE) then delfile(SAVE_FILE) end
end
loadConfig()

local UNLOADED = false
local function isUnloaded() return UNLOADED end

local IS_MM2 = (game.PlaceId == 142823291)

-- ============ STARTUP ============
local splashGui = Instance.new("ScreenGui")
splashGui.Name = "ses_get3_splash"
splashGui.ResetOnSpawn = false
splashGui.IgnoreGuiInset = true
splashGui.DisplayOrder = 99999
pcall(function() splashGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not splashGui.Parent then pcall(function() splashGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end

local splashFrame = Instance.new("Frame")
splashFrame.Size = UDim2.new(1, 0, 1, 0)
splashFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
splashFrame.BackgroundTransparency = 1
splashFrame.BorderSizePixel = 0
splashFrame.Parent = splashGui

local splashLabel = Instance.new("TextLabel")
splashLabel.Size = UDim2.new(1, 0, 0, 60)
splashLabel.Position = UDim2.new(0, 0, 0.5, -30)
splashLabel.BackgroundTransparency = 1
splashLabel.Text = "ses_get3 HUB👑"
splashLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
splashLabel.Font = Enum.Font.GothamBold
splashLabel.TextSize = 32
splashLabel.TextTransparency = 1
splashLabel.Parent = splashFrame

local splashSub = Instance.new("TextLabel")
splashSub.Size = UDim2.new(1, 0, 0, 24)
splashSub.Position = UDim2.new(0, 0, 0.5, 24)
splashSub.BackgroundTransparency = 1
splashSub.Text = "загрузка..."
splashSub.TextColor3 = Color3.fromRGB(180, 180, 180)
splashSub.Font = Enum.Font.GothamMedium
splashSub.TextSize = 14
splashSub.TextTransparency = 1
splashSub.Parent = splashFrame

TweenService:Create(splashFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
TweenService:Create(splashLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
TweenService:Create(splashSub, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
task.wait(2)
TweenService:Create(splashFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
TweenService:Create(splashLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
TweenService:Create(splashSub, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
task.wait(0.5)
splashGui:Destroy()

-- ============ SPEED / JUMP / NOCLIP ============
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

local speedConn = nil
local function updateSpeed()
    if speedConn then speedConn:Disconnect(); speedConn = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if Config.SpeedHack and not isUnloaded() then
        speedConn = RunService.Heartbeat:Connect(function()
            if not Config.SpeedHack or isUnloaded() then return end
            local c = LocalPlayer.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = Config.SpeedValue end
            end
        end)
    else
        if hum then hum.WalkSpeed = DEFAULT_WALKSPEED end
    end
end

local jumpConn = nil
local function updateJump()
    if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if Config.HighJump and not isUnloaded() then
        jumpConn = RunService.Heartbeat:Connect(function()
            if not Config.HighJump or isUnloaded() then return end
            local c = LocalPlayer.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then h.JumpPower = Config.JumpValue end
            end
        end)
    else
        if hum then hum.JumpPower = DEFAULT_JUMPPOWER end
    end
end

local noclipGlobalConn = nil
local function updateNoclip()
    if noclipGlobalConn then noclipGlobalConn:Disconnect(); noclipGlobalConn = nil end
    if Config.NoClip and not isUnloaded() then
        noclipGlobalConn = RunService.Stepped:Connect(function()
            if Config.NoClip and LocalPlayer.Character and not isUnloaded() then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

-- ============ INVISIBLE ============
local invisibleParts = {}
local invisibleConns = {}

local function setupInvisibleCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    invisibleParts = {}
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency == 0 then
            table.insert(invisibleParts, obj)
        elseif obj:IsA("Decal") and obj.Transparency == 0 then
            table.insert(invisibleParts, obj)
        end
    end
end

local function applyInvisible(state)
    for _, obj in ipairs(invisibleParts) do
        if obj and obj.Parent then
            if obj:IsA("BasePart") then
                obj.Transparency = state and 0.5 or 0
            elseif obj:IsA("Decal") then
                obj.Transparency = state and 0.5 or 0
            end
        end
    end
end

local function updateInvisible()
    for _, c in ipairs(invisibleConns) do
        if c then c:Disconnect() end
    end
    invisibleConns = {}

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not Config.Invisible or not char or not hum or not root then
        applyInvisible(false)
        return
    end

    setupInvisibleCharacter()

    table.insert(invisibleConns, UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.G and not isUnloaded() then
            Config.Invisible = not Config.Invisible
            saveConfig()
            applyInvisible(Config.Invisible)
        end
    end))

    table.insert(invisibleConns, RunService.Heartbeat:Connect(function()
        if isUnloaded() or not Config.Invisible then return end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not (c and h and r) then return end

        local cf = r.CFrame
        local camOffset = h.CameraOffset
        local hidden = cf * CFrame.new(0, -200000, 0)
        r.CFrame = hidden
        h.CameraOffset = hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
        RunService.RenderStepped:Wait()
        r.CFrame = cf
        h.CameraOffset = camOffset
    end))

    table.insert(invisibleConns, LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if Config.Invisible then
            setupInvisibleCharacter()
            applyInvisible(true)
        end
    end))

    applyInvisible(true)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.Invisible and not isUnloaded() then
        setupInvisibleCharacter()
        applyInvisible(true)
    end
end)

-- ============ MM2-ЛОГИКА ============
local playerData = {}
local murdererName, sheriffName, heroName = "", "", ""

local function isSheriffAlive()
    if sheriffName == "" then return false end
    local d = playerData[sheriffName]
    if not d then return false end
    return not d.Killed and not d.Dead
end
local function playerHasGun(pl)
    if not pl then return false end
    local char = pl.Character
    if char and char:FindFirstChild("Gun") then return true end
    local bp = pl.Backpack
    if bp and bp:FindFirstChild("Gun") then return true end
    return false
end
local function updateHero()
    heroName = ""
    if isSheriffAlive() then return end
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl:GetAttribute("Alive") == true and playerHasGun(pl) then
            if pl.Name ~= murdererName then heroName = pl.Name; return end
        end
    end
end
if IS_MM2 then
    task.spawn(function()
        while not isUnloaded() do
            pcall(function()
                local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
                if remote then
                    playerData = remote:InvokeServer()
                    murdererName, sheriffName = "", ""
                    for name, data in pairs(playerData) do
                        if data.Role == "Murderer" then murdererName = name
                        elseif data.Role == "Sheriff" then sheriffName = name end
                    end
                    updateHero()
                end
            end)
            task.wait(0.1)
        end
    end)
end
local function IsAlive(name)
    for n, data in pairs(playerData) do
        if n == name then return not data.Killed and not data.Dead end
    end
    return false
end
local function getRoleString()
    if not IS_MM2 then return nil end
    local d = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not d then return nil end
    local ok, data = pcall(function() return d:InvokeServer() end)
    if not ok or not data then return nil end
    local me = data[LocalPlayer.Name]
    if me and me.Role then return me.Role end
    return nil
end
local function isPlayerDead()
    local ok, data = pcall(function()
        return ReplicatedStorage.Remotes.Extras.GetPlayerData:InvokeServer()[LocalPlayer.Name]
    end)
    if ok and data then return data["Dead"] == true end
    return false
end
local function getPing() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end
local function getMurdererPlayer()
    if murdererName == "" then return nil end
    return Players:FindFirstChild(murdererName)
end
local function findMap()
    for _, child in ipairs(workspace:GetChildren()) do
        if child:GetAttribute("MapID") then return child end
    end
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("CoinContainer") then return child end
    end
    return nil
end
local function getGun()
    if LocalPlayer.Character then
        local g = LocalPlayer.Character:FindFirstChild("Gun")
        if g then return g end
    end
    if LocalPlayer.Backpack then
        local g = LocalPlayer.Backpack:FindFirstChild("Gun")
        if g then return g end
    end
    return nil
end
local function isLocalAlive() return LocalPlayer:GetAttribute("Alive") == true end

-- ============ ФАРМ ============
local farmingActive = false
local currentCoinsCollected, maxCoinsInRound = 0, 0
local allCoinsCollected = false
local noclipConn, currentTween, bagFullActionInProgress = nil, nil, false
local originalPartProperties = {}

local function restoreNormalGravity()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        for _, c in pairs(root:GetChildren()) do
            if c:IsA("BodyVelocity") or c:IsA("BodyGyro") or c:IsA("BodyPosition") or c:IsA("BodyThrust") or c:IsA("BodyForce") then c:Destroy() end
        end
    end
end
local function addFarmGravity()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if root:FindFirstChild("FarmGravity") then root.FarmGravity:Destroy() end
        local bp = Instance.new("BodyPosition")
        bp.Name = "FarmGravity"; bp.MaxForce = Vector3.new(0, math.huge, 0)
        bp.D = 1000; bp.P = 10000; bp.Position = root.Position; bp.Parent = root
    end
end
local function returncoincontainer()
    for _, child in pairs(workspace:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("CoinContainer") then return child.CoinContainer end
    end
    return nil
end
local function FindNearestCoin(container)
    if not container then return nil, math.huge end
    local nearest, nearestDist = nil, math.huge
    for _, coin in pairs(container:GetChildren()) do
        if coin:GetAttribute("CoinID") == "Coin" and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                if dist < nearestDist then nearest, nearestDist = coin, dist end
            end
        end
    end
    return nearest, nearestDist
end
local function enableNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if Config.FarmCoins and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end
local function startFarming()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if not isLocalAlive() then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    addFarmGravity()
    originalPartProperties = {}
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalPartProperties[part] = {CanCollide = part.CanCollide, Massless = part.Massless}
        end
    end
    root.CFrame = root.CFrame - Vector3.new(0, 2.5, 0)
    root.CFrame = root.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    if hum then
        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
    farmingActive = true
end
local function stopFarming()
    farmingActive = false
    if currentTween then currentTween:Cancel(); currentTween = nil end
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if LocalPlayer.Character then
        for part, props in pairs(originalPartProperties) do
            if part and part.Parent then part.CanCollide = props.CanCollide; part.Massless = props.Massless end
        end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, 0, 0); root.RotVelocity = Vector3.new(0, 0, 0)
            root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            root.CFrame = root.CFrame + Vector3.new(0, 2.5, 0)
        end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
    originalPartProperties = {}
end

if IS_MM2 then
    ReplicatedStorage.Remotes.Gameplay.CoinCollected.OnClientEvent:Connect(function(coinType, current, max)
        if coinType == "Coin" then
            currentCoinsCollected = tonumber(current) or 0
            maxCoinsInRound = tonumber(max) or 0
            if currentCoinsCollected >= maxCoinsInRound then
                allCoinsCollected = true
                if farmingActive then stopFarming(); restoreNormalGravity() end
            else allCoinsCollected = false end
        end
    end)
    ReplicatedStorage.Remotes.Gameplay.RoundStart.OnClientEvent:Connect(function()
        allCoinsCollected, currentCoinsCollected, maxCoinsInRound, bagFullActionInProgress = false, 0, 0, false
    end)
    ReplicatedStorage.Remotes.Gameplay.RoundEndFade.OnClientEvent:Connect(function()
        allCoinsCollected, currentCoinsCollected, maxCoinsInRound, bagFullActionInProgress = false, 0, 0, false
        if farmingActive then stopFarming(); restoreNormalGravity() end
    end)

    task.spawn(function()
        while not isUnloaded() do
            RunService.Heartbeat:Wait()
            local role = getRoleString()
            local validRole = role == "Innocent" or role == "Sheriff" or role == "Murderer" or role == "Hero"
            if Config.FarmCoins and farmingActive and validRole and LocalPlayer.Character and isLocalAlive() then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local container = returncoincontainer()
                if root and container then
                    for _, coin in pairs(container:GetChildren()) do
                        if coin:GetAttribute("CoinID") == "Coin" and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 then
                            if (root.Position - coin.Position).Magnitude <= 7.5 then
                                firetouchinterest(root, coin, 0); firetouchinterest(root, coin, 1)
                            end
                        end
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while not isUnloaded() do
            RunService.Heartbeat:Wait()
            if bagFullActionInProgress then continue end
            if not Config.FarmCoins then
                if farmingActive then stopFarming(); restoreNormalGravity() end
                continue
            end
            local role = getRoleString()
            local validRole = role == "Innocent" or role == "Sheriff" or role == "Murderer" or role == "Hero"
            if farmingActive and not validRole then stopFarming(); restoreNormalGravity() end
            if farmingActive and allCoinsCollected then stopFarming(); restoreNormalGravity() end
            if not allCoinsCollected and isLocalAlive() and validRole
                and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local container = returncoincontainer()
                if container then
                    local coin, dist = FindNearestCoin(container)
                    if coin and coin.Transparency == 1 and not allCoinsCollected then
                        if not farmingActive then startFarming() end
                        local root = LocalPlayer.Character.HumanoidRootPart
                        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        root.Velocity = Vector3.new(0, 0, 0); root.RotVelocity = Vector3.new(0, 0, 0)
                        local targetPos = coin.Position - Vector3.new(0, 2.5, 0)
                        local targetCF = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)
                        enableNoclip()
                        currentTween = TweenService:Create(root, TweenInfo.new(dist / 23, Enum.EasingStyle.Linear), {CFrame = targetCF})
                        currentTween:Play()
                        local hb
                        hb = RunService.Heartbeat:Connect(function()
                            if Config.FarmCoins and isLocalAlive() and root then
                                root.Velocity = Vector3.new(0, 0, 0); root.RotVelocity = Vector3.new(0, 0, 0)
                                local grav = root:FindFirstChild("FarmGravity")
                                if grav and grav:IsA("BodyPosition") then grav.Position = root.Position end
                                if hum then hum.PlatformStand = true end
                            else if hb then hb:Disconnect() end end
                        end)
                        while coin and coin.Parent and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1
                            and not allCoinsCollected and Config.FarmCoins and isLocalAlive() do
                            RunService.Heartbeat:Wait()
                        end
                        if hb then hb:Disconnect() end
                        if currentTween then currentTween:Cancel() end
                        if root then root.Velocity = Vector3.new(0, 0, 0); root.RotVelocity = Vector3.new(0, 0, 0) end
                    else if farmingActive then stopFarming(); restoreNormalGravity() end end
                else if farmingActive then stopFarming(); restoreNormalGravity() end end
            else if farmingActive then stopFarming(); restoreNormalGravity() end end
        end
    end)

    task.spawn(function()
        while not isUnloaded() do
            task.wait(0.5)
            if not Config.FarmCoins then bagFullActionInProgress = false; continue end
            if not bagFullActionInProgress and allCoinsCollected then
                if isPlayerDead() then continue end
                bagFullActionInProgress = true
                local role = getRoleString()
                restoreNormalGravity(); if farmingActive then stopFarming() end
                if role == "Innocent" and Config.FarmResetBagFull then
                    task.wait(0.5); restoreNormalGravity()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.Health = 0
                    end
                    task.wait(6)
                end
                bagFullActionInProgress = false
            end
        end
    end)
end

-- ============ ФЛИНГ ============
local FlingActive = false
local OldPos = nil
local FPDH = workspace.FallenPartsDestroyHeight

local function SkidFling(TargetPlayer)
    if not TargetPlayer then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = hum and hum.RootPart
    local tChar = TargetPlayer.Character
    if not tChar then return end
    local tHum = tChar:FindFirstChildOfClass("Humanoid")
    local tRoot = tHum and tHum.RootPart
    local tHead = tChar:FindFirstChild("Head")
    local acc = tChar:FindFirstChildOfClass("Accessory")
    local handle = acc and acc:FindFirstChild("Handle")

    if not (char and hum and root and tHum and tRoot) then return end
    if tHum.Sit then return end

    local savedPivot = char:GetPivot()
    local savedAutoRotate = hum.AutoRotate
    local savedFallenHeight = workspace.FallenPartsDestroyHeight
    local savedSeatedEnabled = hum:GetStateEnabled(Enum.HumanoidStateType.Seated)
    local wasAntiFling = Config.AntiFling

    if wasAntiFling then Config.AntiFling = false end
    pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
    pcall(hum.SetStateEnabled, hum, Enum.HumanoidStateType.Seated, false)
    pcall(function()
        if sethiddenproperty then sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end
    end)
    hum.AutoRotate = false

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = root

    if root.Velocity.Magnitude < 50 then OldPos = root.CFrame end

    if tHead then
        workspace.CurrentCamera.CameraSubject = tHead
    elseif handle then
        workspace.CurrentCamera.CameraSubject = handle
    else
        workspace.CurrentCamera.CameraSubject = tHum
    end

    if not tChar:FindFirstChildWhichIsA("BasePart") then
        bv:Destroy()
        workspace.FallenPartsDestroyHeight = FPDH
        if wasAntiFling then Config.AntiFling = true end
        return
    end

    local launchOrigin = tRoot.Position
    local lastPos = tRoot.Position
    local targetPart = tRoot or tHead or handle

    local function FPos(pos, ang)
        local cf = CFrame.new(targetPart.Position) * pos * ang
        root.CFrame = cf
        char:SetPrimaryPartCFrame(cf)
        root.Velocity = Vector3.new(9e7, 9e8, 9e7)
        root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function targetEscaped()
        if not targetPart.Parent then return false end
        lastPos = targetPart.Position
        local distance = (lastPos - launchOrigin).Magnitude
        local speed = targetPart.AssemblyLinearVelocity.Magnitude
        return lastPos.Y <= FPDH + 30 or distance > 350 or (distance > 120 and speed > 200)
    end

    local started = os.clock()
    local angle = 0

    repeat
        if not (root and tHum and root.Parent and hum.Health > 0) then break end
        if targetEscaped() then break end
        if os.clock() - started > 2 then break end
        if not FlingActive or isUnloaded() then break end

        local speed = targetPart.AssemblyLinearVelocity.Magnitude
        angle = angle + 100
        local rot = CFrame.Angles(math.rad(angle), 0, 0)

        if speed < 50 then
            local lead = tHum.MoveDirection * speed / 1.25
            FPos(CFrame.new(0, 1.5, 0) + lead, rot); task.wait()
            FPos(CFrame.new(0, -1.5, 0) + lead, rot); task.wait()
            FPos(CFrame.new(0, 1.5, 0) + lead, rot); task.wait()
            FPos(CFrame.new(0, -1.5, 0) + lead, rot); task.wait()
            FPos(CFrame.new(0, 1.5, 0) + tHum.MoveDirection, rot); task.wait()
            FPos(CFrame.new(0, -1.5, 0) + tHum.MoveDirection, rot); task.wait()
        else
            FPos(CFrame.new(0, 1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
            FPos(CFrame.new(0, -1.5, -tHum.WalkSpeed), CFrame.new()); task.wait()
            FPos(CFrame.new(0, 1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
            FPos(CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
            FPos(CFrame.new(0, -1.5, 0), CFrame.new()); task.wait()
            FPos(CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
            FPos(CFrame.new(0, -1.5, 0), CFrame.new()); task.wait()
        end
    until false

    bv:Destroy()
    pcall(hum.SetStateEnabled, hum, Enum.HumanoidStateType.Seated, savedSeatedEnabled)

    if char.Parent and hum.Health > 0 then
        pcall(function()
            for _ = 1, 6 do
                char:PivotTo(savedPivot * CFrame.new(0, 0.5, 0))
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
                if (root.Position - savedPivot.Position).Magnitude < 25 then break end
                RunService.Heartbeat:Wait()
            end
            hum.AutoRotate = savedAutoRotate
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end

    pcall(function() workspace.FallenPartsDestroyHeight = savedFallenHeight end)
    if wasAntiFling then Config.AntiFling = true end
    workspace.CurrentCamera.CameraSubject = hum
    FPDH = workspace.FallenPartsDestroyHeight
end

local function FindPlayerByPartialName(name)
    if not name or name == "" then return nil end
    local lower = string.lower(name)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and string.lower(p.Name) == lower then return p end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and string.sub(string.lower(p.Name), 1, #lower) == lower then return p end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and string.find(string.lower(p.Name), lower, 1, true) then return p end
    end
    return nil
end

local function FlingByRole(roleName)
    if FlingActive or isUnloaded() then return end
    local target = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p:GetAttribute("Alive") == true then
            local data = playerData[p.Name]
            if data and data.Role == roleName then target = p; break end
        end
    end
    if target then
        FlingActive = true
        task.spawn(function()
            pcall(SkidFling, target)
            FlingActive = false
            if workspace.CurrentCamera and LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
        end)
    end
end

local function StopFling()
    if FlingActive then
        FlingActive = false
        task.wait(0.5)
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local root = hum and hum.RootPart
            if root and OldPos then
                root.CFrame = OldPos * CFrame.new(0, 0.5, 0)
                LocalPlayer.Character:SetPrimaryPartCFrame(OldPos * CFrame.new(0, 0.5, 0))
                root.Velocity = Vector3.new(0, 0, 0); root.RotVelocity = Vector3.new(0, 0, 0)
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
        workspace.FallenPartsDestroyHeight = FPDH
    end
end

-- ============ СТРЕЛЬБА / УБИЙСТВО ============
local magicBulletToolConn = nil
local disabledGunClients = {}
local gunMonitorConns = {}

local function disableGunClient(tool)
    if not tool then return end
    local gc = tool:FindFirstChild("GunClient")
    if gc and gc:IsA("LocalScript") and gc.Enabled then gc.Enabled = false; disabledGunClients[tool] = gc end
end
local function enableGunClient(tool)
    if not tool then return end
    local gc = disabledGunClients[tool]
    if gc and gc:IsA("LocalScript") then gc.Enabled = true; disabledGunClients[tool] = nil
    else
        local c = tool:FindFirstChild("GunClient")
        if c and c:IsA("LocalScript") and not c.Enabled then c.Enabled = true end
    end
end
local function magicBulletShoot(tool)
    if not tool or isUnloaded() then return end
    local murderer = getMurdererPlayer()
    if not murderer or not murderer.Character then return end
    local root = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end    local ping = getPing()
    local predictTime = (ping / 1000) * Config.PredictionMultiplier
    local v = root.Velocity
    local speed = v.Magnitude
    local targetPos
    if speed < 1 then targetPos = root.Position + root.CFrame.LookVector * 2
    else targetPos = root.Position + (v * (predictTime * (1 + speed / 50))) end
    local origin = root.Position - root.CFrame.LookVector * 1
    local se = tool:FindFirstChild("Shoot")
    if se and se:IsA("RemoteEvent") then se:FireServer(CFrame.new(origin), CFrame.new(targetPos)) end
end
local function setupMagicBulletTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    if magicBulletToolConn then magicBulletToolConn:Disconnect() end
    magicBulletToolConn = tool.Activated:Connect(function()
        if Config.MagicBullet and not isUnloaded() then magicBulletShoot(tool) end
    end)
end
local function monitorGunAppearance()
    for _, c in pairs(gunMonitorConns) do if c then c:Disconnect() end end
    gunMonitorConns = {}
    local c1 = LocalPlayer.CharacterAdded:Connect(function(char)
        if not Config.MagicBullet then return end
        table.insert(gunMonitorConns, char.ChildAdded:Connect(function(child)
            if child.Name == "Gun" and child:IsA("Tool") and Config.MagicBullet and not isUnloaded() then
                task.wait(0.1); disableGunClient(child); setupMagicBulletTool(child)
            end
        end))
    end)
    table.insert(gunMonitorConns, c1)
    if LocalPlayer.Backpack then
        table.insert(gunMonitorConns, LocalPlayer.Backpack.ChildAdded:Connect(function(child)
            if child.Name == "Gun" and child:IsA("Tool") and Config.MagicBullet and not isUnloaded() then
                task.wait(0.1); disableGunClient(child); setupMagicBulletTool(child)
            end
        end))
    end
end
local function enableMagicBullet()
    if LocalPlayer.Character then
        local gun = LocalPlayer.Character:FindFirstChild("Gun")
        if gun then disableGunClient(gun); setupMagicBulletTool(gun) end
    end
    if LocalPlayer.Backpack then
        local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
        if gun then disableGunClient(gun); setupMagicBulletTool(gun) end
    end
    monitorGunAppearance()
end
local function disableMagicBullet()
    if magicBulletToolConn then magicBulletToolConn:Disconnect(); magicBulletToolConn = nil end
    for _, c in pairs(gunMonitorConns) do if c then c:Disconnect() end end
    gunMonitorConns = {}
    for tool, _ in pairs(disabledGunClients) do enableGunClient(tool) end
    disabledGunClients = {}
end
if IS_MM2 then monitorGunAppearance() end

local function autoShootMurderer()
    if isUnloaded() then return end
    local gun = getGun()
    if not gun then return end
    if gun.Parent ~= LocalPlayer.Character then gun.Parent = LocalPlayer.Character; task.wait(0.05) end
    local murderer = getMurdererPlayer()
    if not murderer or not murderer.Character then return end
    local root = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local ping = getPing()
    local predictTime = (ping / 1000) * Config.PredictionMultiplier
    local v = root.Velocity
    local speed = v.Magnitude
    local targetPos
    if speed < 1 then targetPos = root.Position + root.CFrame.LookVector * 2
    else targetPos = root.Position + (v * (predictTime * (1 + speed / 50))) end
    local origin = root.Position - root.CFrame.LookVector * 1
    local se = gun:FindFirstChild("Shoot")
    if se and se:IsA("RemoteEvent") then se:FireServer(CFrame.new(origin), CFrame.new(targetPos)) end
end
if IS_MM2 then
    task.spawn(function()
        while not isUnloaded() do task.wait(0.1); if Config.AutoShoot then autoShootMurderer() end end
    end)
end

if IS_MM2 then
    task.spawn(function()
        while not isUnloaded() do
            task.wait(0.5)
            if Config.AutoKill and LocalPlayer.Character then
                local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
                if knife then
                    if knife.Parent == LocalPlayer.Backpack then knife.Parent = LocalPlayer.Character end
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                            pcall(function()
                                knife.Events.KnifeStabbed:FireServer()
                                knife.Events.HandleTouched:FireServer(player.Character.Head)
                            end)
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end)
end

-- ============ AUTO GRAB GUN ============
local function grabGunAuto()
    pcall(function()
        if isUnloaded() or not Config.AutoGrabGun then return end
        if not isLocalAlive() then return end
        if getRoleString() == "Murderer" then return end
        local map = findMap(); if not map then return end
        local gunDrop = map:FindFirstChild("GunDrop"); if not gunDrop then return end
        if gunDrop:FindFirstChild("TouchInterest") and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                firetouchinterest(root, gunDrop, 0); firetouchinterest(root, gunDrop, 1)
            end
        end
    end)
end
if IS_MM2 then
    task.spawn(function()
        while not isUnloaded() do RunService.Heartbeat:Wait(); grabGunAuto() end
    end)
end

-- ============ УБИЙСТВО ВСЕХ (полный мешок) ============
if IS_MM2 then
    task.spawn(function()
        while not isUnloaded() do
            task.wait(0.15)
            if not Config.FarmCoins then continue end
            if not Config.MurdererKillAllOnFull then continue end
            if not allCoinsCollected then continue end
            if not isLocalAlive() then continue end
            if getRoleString() ~= "Murderer" then continue end
            local char = LocalPlayer.Character
            if not char then continue end
            local knife = char:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            if not knife then continue end
            if knife.Parent ~= char then pcall(function() knife.Parent = char end); task.wait(0.05) end
            for _, player in pairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                if not player.Character then continue end
                local head = player.Character:FindFirstChild("Head")
                if not head then continue end
                pcall(function()
                    knife.Events.KnifeStabbed:FireServer()
                    knife.Events.HandleTouched:FireServer(head)
                end)
                task.wait(0.04)
            end
        end
    end)

    task.spawn(function()
        while not isUnloaded() do
            task.wait(0.3)
            if not Config.FarmCoins then continue end
            if not FlingOnDeathEnabled then continue end
            local me = playerData[LocalPlayer.Name]
            if me and (me.Killed or me.Dead) and murdererName ~= "" and murdererName ~= LocalPlayer.Name then
                local murderer = Players:FindFirstChild(murdererName)
                if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                    local mHum = murderer.Character:FindFirstChildOfClass("Humanoid")
                    if mHum and mHum.Health > 0 and not FlingActive then
                        FlingActive = true
                        task.spawn(function() pcall(SkidFling, murderer); FlingActive = false end)
                    end
                end
                task.wait(3)
            end
        end
    end)
end

-- ============ АТАКА ПОСЛЕ СБОРА ============
local autoAttackInnocentBusy = false
local function findGunDrop()
    local map = findMap()
    if not map then return nil end
    return map:FindFirstChild("GunDrop")
end
local function grabGunDrop()
    local gunDrop = findGunDrop()
    if not gunDrop then return false end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    pcall(function()
        firetouchinterest(root, gunDrop, 0)
        firetouchinterest(root, gunDrop, 1)
    end)
    return getGun() ~= nil
end
local function shootAtMurdererWithGun(gun, usePrediction)
    if not gun or isUnloaded() then return end
    local murderer = getMurdererPlayer()
    if not murderer or not murderer.Character then return end
    local root = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local origin, targetPos
    if usePrediction then
        local ping = getPing()
        local predictTime = (ping / 1000) * Config.PredictionMultiplier
        local v = root.Velocity
        local speed = v.Magnitude
        if speed < 1 then targetPos = root.Position + root.CFrame.LookVector * 2
        else targetPos = root.Position + (v * (predictTime * (1 + speed / 50))) end
        origin = root.Position - root.CFrame.LookVector * 1
    else
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        origin = myRoot.Position + Vector3.new(0, 0.5, 0)
        local ping = getPing()
        local predictTime = (ping / 1000) * Config.PredictionMultiplier
        targetPos = root.Position + root.Velocity * predictTime
    end
    local se = gun:FindFirstChild("Shoot")
    if se and se:IsA("RemoteEvent") then se:FireServer(CFrame.new(origin), CFrame.new(targetPos)) end
end
local function flingSheriffOrHero()
    local target = nil
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl:GetAttribute("Alive") == true then
            local data = playerData[pl.Name]
            if data and (data.Role == "Sheriff" or data.Role == "Hero") then target = pl; break end
        end
    end
    if target and not FlingActive then
        FlingActive = true
        task.spawn(function()
            pcall(SkidFling, target)
            FlingActive = false
            if workspace.CurrentCamera and LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
        end)
        return true
    end
    return false
end

if IS_MM2 then
    task.spawn(function()
        while not isUnloaded() do
            task.wait(0.15)
            if not Config.FarmCoins then continue end
            if not Config.AutoAttackAfterFarm then continue end
            if not allCoinsCollected then continue end
            if not isLocalAlive() then continue end
            local role = getRoleString()
            if role ~= "Sheriff" and role ~= "Innocent" and role ~= "Hero" then continue end
            local murderer = getMurdererPlayer()
            if not murderer or not murderer.Character then continue end
            local mHum = murderer.Character:FindFirstChildOfClass("Humanoid")
            if not mHum or mHum.Health <= 0 then continue end
            if role == "Sheriff" or role == "Hero" then
                local gun = getGun()
                if gun then
                    if gun.Parent ~= LocalPlayer.Character then pcall(function() gun.Parent = LocalPlayer.Character end); task.wait(0.05) end
                    pcall(shootAtMurdererWithGun, gun, true)
                end
            end
            if role == "Innocent" then
                if autoAttackInnocentBusy then continue end
                local gun = getGun()
                if not gun then
                    autoAttackInnocentBusy = true
                    pcall(flingSheriffOrHero)
                    local waitStart = tick()
                    while FlingActive and tick() - waitStart < 5 do task.wait(0.1) end
                    local gunDrop = findGunDrop()
                    if gunDrop then
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            local dist = (myRoot.Position - gunDrop.Position).Magnitude
                            if dist > 5 and dist < 500 then
                                local tween = TweenService:Create(myRoot,
                                    TweenInfo.new(dist / 60, Enum.EasingStyle.Linear),
                                    {CFrame = CFrame.new(gunDrop.Position + Vector3.new(0, 2, 0))})
                                tween:Play()
                                task.wait(math.min(dist / 60, 0.4))
                            end
                        end
                    end
                    pcall(grabGunDrop)
                    gun = getGun()
                    autoAttackInnocentBusy = false
                end
                if gun then
                    if gun.Parent ~= LocalPlayer.Character then pcall(function() gun.Parent = LocalPlayer.Character end); task.wait(0.05) end
                    pcall(shootAtMurdererWithGun, gun, true)
                end
            end
        end
    end)
end

-- ============ COOL GUY ============
local coolGuyConns = {}
local coolGuyState = { jumping = false, savedCFrame = nil, originalYaw = nil, lastShot = 0 }
local COOLGUY_FIRE_RATE = 0.03
local function getGunFromChar() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") end
local function isSheriffOrHero()
    local r = getRoleString()
    return r == "Sheriff" or r == "Hero"
end
local function predictTargetPos(root)
    local ping = getPing()
    local t = math.max(ping / 1000, 0.01) * Config.PredictionMultiplier
    local v = root.Velocity
    if v.Magnitude < 2 then return root.Position + Vector3.new(0, 0.5, 0) end
    return root.Position + v * t + Vector3.new(0, 0.5, 0)
end
local function faceMurderer()
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local m = getMurdererPlayer()
    if not m or not m.Character then return end
    local mRoot = m.Character:FindFirstChild("HumanoidRootPart")
    if not mRoot then return end
    local look = Vector3.new(mRoot.Position.X, root.Position.Y, mRoot.Position.Z)
    if (look - root.Position).Magnitude > 0.5 then root.CFrame = CFrame.new(root.Position, look) end
end
local function coolGuyShoot()
    if isUnloaded() then return end
    if not Config.CoolGuy or not isSheriffOrHero() then return end
    local char = LocalPlayer.Character; if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
    local gun = getGunFromChar(); if not gun then return end
    local m = getMurdererPlayer()
    if not m or not m.Character then return end
    local mRoot = m.Character:FindFirstChild("HumanoidRootPart")
    local mHead = m.Character:FindFirstChild("Head")
    if not mRoot then return end
    if (myRoot.Position - mRoot.Position).Magnitude > 250 then return end
    local now = tick()
    if now - coolGuyState.lastShot < COOLGUY_FIRE_RATE then return end
    coolGuyState.lastShot = now
    local origin = myRoot.Position + Vector3.new(0, 0.5, 0)
    local targetPos = predictTargetPos(mRoot)
    local se = gun:FindFirstChild("Shoot")
    if se and se:IsA("RemoteEvent") then
        se:FireServer(CFrame.new(origin), CFrame.new(targetPos))
        if mHead then
            local hp = mHead.Position + mHead.Velocity * (getPing()/1000) * Config.PredictionMultiplier
            se:FireServer(CFrame.new(origin), CFrame.new(hp))
        end
    end
end
local function coolGuyTurnBack()
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    coolGuyState.savedCFrame = root.CFrame
    local _, yaw = root.CFrame:ToEulerAnglesYXZ()
    coolGuyState.originalYaw = yaw
end
local function coolGuyRestore()
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root or not coolGuyState.savedCFrame then return end
    local _, yaw = coolGuyState.savedCFrame:ToEulerAnglesYXZ()
    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
end
local function coolGuySetupCharacter(char)
    for _, c in ipairs(coolGuyConns) do if c then c:Disconnect() end end
    coolGuyConns = {}
    local hum = char:WaitForChild("Humanoid", 5); if not hum then return end
    table.insert(coolGuyConns, hum.Jumping:Connect(function()
        if isUnloaded() then return end
        if not Config.CoolGuy or not isSheriffOrHero() or not getGunFromChar() then return end
        if coolGuyState.jumping then return end
        coolGuyState.jumping = true
        coolGuyTurnBack()
        task.spawn(function()
            local char2 = LocalPlayer.Character
            local hum2 = char2 and char2:FindFirstChildOfClass("Humanoid")
            if not hum2 then return end
            while coolGuyState.jumping and Config.CoolGuy and hum2.Health > 0 and not isUnloaded() do
                local st = hum2:GetState()
                if st == Enum.HumanoidStateType.Landed or st == Enum.HumanoidStateType.Running
                    or st == Enum.HumanoidStateType.RunningNoPhysics then break end
                if getGunFromChar() then pcall(faceMurderer); pcall(coolGuyShoot) end
                RunService.RenderStepped:Wait()
            end
            coolGuyState.jumping = false
            pcall(coolGuyRestore)
        end)
    end))
    table.insert(coolGuyConns, hum.StateChanged:Connect(function(_, ns)
        if ns == Enum.HumanoidStateType.Landed and coolGuyState.jumping then
            coolGuyState.jumping = false; pcall(coolGuyRestore)
        end
    end))
end
if LocalPlayer.Character then task.spawn(coolGuySetupCharacter, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if Config.CoolGuy and not isUnloaded() then coolGuySetupCharacter(char) end
end)

-- ============ ANTI-FLING ============
local function setupCharacterCollision(character)
    local function disableCollide(part)
        if Config.AntiFling and part:IsA("BasePart") then part.CanCollide = false end
    end
    for _, child in ipairs(character:GetChildren()) do disableCollide(child) end
    local c1 = character.ChildAdded:Connect(disableCollide)
    local c2 = RunService.Stepped:Connect(function()
        if Config.AntiFling and character:IsDescendantOf(workspace) then
            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("BasePart") and child.CanCollide then child.CanCollide = false end
            end
        end
    end)
    character.Destroying:Connect(function() c1:Disconnect(); c2:Disconnect() end)
end
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(setupCharacterCollision)
        if p.Character then setupCharacterCollision(p.Character) end
    end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(setupCharacterCollision)
        if p.Character then setupCharacterCollision(p.Character) end
    end
end)

-- ============ ESP ============
local function setupESP(player)
    if player == LocalPlayer then return end
    local function applyESP(character)
        task.wait(0.3)
        if isUnloaded() then return end
        if not character or not character.Parent then return end
        if character:FindFirstChild("MM2_Highlight") then character.MM2_Highlight:Destroy() end
        if character:FindFirstChild("MM2_ESP_Text") then character.MM2_ESP_Text:Destroy() end
        if not Config.ESP then return end

        local function getESPColor()
            local c = Config.ESPColor or {0, 255, 0}
            return Color3.fromRGB(c[1], c[2], c[3])
        end

        local head = character:FindFirstChild("Head") or character.PrimaryPart
        if not head then return end

        local hl = Instance.new("Highlight")
        hl.Name = "MM2_Highlight"
        hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = character

        local bb = Instance.new("BillboardGui")
        bb.Name = "MM2_ESP_Text"
        bb.Size = UDim2.new(0, 200, 0, 40)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.Parent = character

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextStrokeTransparency = 0.3
        lbl.Parent = bb

        task.spawn(function()
            while character and character.Parent and hl and lbl and not isUnloaded() do
                local name = player.Name
                local displayName = player.DisplayName or name
                local espColor = getESPColor()

                if not Config.ESP then
                    lbl.Text = ""; hl.FillTransparency = 1; hl.OutlineTransparency = 1
                elseif IS_MM2 then
                    if not IsAlive(name) then
                        lbl.Text = name .. " [Мёртв 💀]"
                        hl.FillColor = Color3.fromRGB(120, 120, 120)
                        lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
                        hl.FillTransparency = 0.7
                    elseif name == murdererName then
                        lbl.Text = name .. " [Декстер 🔪]"
                        hl.FillColor = Color3.fromRGB(225, 0, 0)
                        lbl.TextColor3 = Color3.fromRGB(255, 30, 30)
                        hl.FillTransparency = 0.5
                    elseif name == sheriffName and isSheriffAlive() then
                        lbl.Text = name .. " [Шериф 🎯]"
                        hl.FillColor = Color3.fromRGB(0, 0, 225)
                        lbl.TextColor3 = Color3.fromRGB(30, 144, 255)
                        hl.FillTransparency = 0.5
                    elseif not isSheriffAlive() and playerHasGun(player) then
                        lbl.Text = name .. " [Солнечный 🌟]"
                        hl.FillColor = Color3.fromRGB(255, 215, 0)
                        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                        hl.FillTransparency = 0.5
                    else
                        lbl.Text = name .. " [Невинный]"
                        hl.FillColor = Color3.fromRGB(0, 225, 0)
                        lbl.TextColor3 = Color3.fromRGB(50, 205, 50)
                        hl.FillTransparency = 0.5
                    end
                else
                    local hum = character:FindFirstChildOfClass("Humanoid")
                    local hp = hum and math.floor(hum.Health) or 0
                    local maxHp = hum and math.floor(hum.MaxHealth) or 100
                    local distance = 0
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart") then
                        distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude)
                    end
                    lbl.Text = displayName .. "\n" .. hp .. "/" .. maxHp .. " HP  |  " .. distance .. "m"
                    lbl.TextColor3 = espColor
                    hl.FillColor = espColor
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0.2
                end
                task.wait(0.05)
            end
        end)
    end
    if player.Character then applyESP(player.Character) end
    player.CharacterAdded:Connect(applyESP)
end
for _, p in ipairs(Players:GetPlayers()) do setupESP(p) end
Players.PlayerAdded:Connect(setupESP)

-- ============ ESP GUNDROP ============
if IS_MM2 then
    local gunDropHighlight, gunDropBillboard = nil, nil
    local function clearGunDropESP()
        if gunDropHighlight then gunDropHighlight:Destroy(); gunDropHighlight = nil end
        if gunDropBillboard then gunDropBillboard:Destroy(); gunDropBillboard = nil end
    end
    local function applyGunDropESP(gunDrop)
        clearGunDropESP()
        if not gunDrop or not gunDrop.Parent then return end
        gunDropHighlight = Instance.new("Highlight")
        gunDropHighlight.Name = "MM2_GunDrop_Highlight"
        gunDropHighlight.FillColor = Color3.fromRGB(255, 215, 0)
        gunDropHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        gunDropHighlight.FillTransparency = 0.4
        gunDropHighlight.OutlineTransparency = 0.1
        gunDropHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        gunDropHighlight.Adornee = gunDrop
        gunDropHighlight.Parent = gunDrop
        gunDropBillboard = Instance.new("BillboardGui")
        gunDropBillboard.Name = "MM2_GunDrop_Text"
        gunDropBillboard.Size = UDim2.new(0, 160, 0, 26)
        gunDropBillboard.AlwaysOnTop = true
        gunDropBillboard.Adornee = gunDrop
        gunDropBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
        gunDropBillboard.Parent = gunDrop
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "🔫 ПИСТОЛЕТ"
        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextStrokeTransparency = 0.3
        lbl.Parent = gunDropBillboard
    end
    task.spawn(function()
        while not isUnloaded() do
            RunService.Heartbeat:Wait()
            if not Config.ESP then
                if gunDropHighlight or gunDropBillboard then clearGunDropESP() end
                continue
            end
            local map = findMap()
            local gunDrop = map and map:FindFirstChild("GunDrop")
            if gunDrop and gunDrop:IsA("BasePart") then
                if not gunDropHighlight or gunDropHighlight.Parent ~= gunDrop then
                    applyGunDropESP(gunDrop)
                end
            else
                if gunDropHighlight or gunDropBillboard then clearGunDropESP() end
            end
        end
    end)
end

-- ============ АНИМАЦИИ ============
local OriginalAnimations = {}
local AnimState = {
    LastEmote = "", EmoteSpeed = 1, Looped = false, Reversed = false,
    PlayAlways = true, FreezeEmote = false, SelectedAnimation = "",
    AnimationSpeed = 1, RandomEmoteActive = false,
}
local _G_LoadAnim = nil

local function cacheOriginalAnimations()
    local char = LocalPlayer.Character
    if not char then return end
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    if animate:FindFirstChild("pose") then
        local p = animate.pose:FindFirstChildOfClass("Animation")
        if p then OriginalAnimations[3] = p.AnimationId end
    end
    OriginalAnimations[1] = animate.idle.Animation1.AnimationId
    OriginalAnimations[2] = animate.idle.Animation2.AnimationId
    OriginalAnimations[4] = animate.walk:FindFirstChildOfClass("Animation").AnimationId
    OriginalAnimations[5] = animate.run:FindFirstChildOfClass("Animation").AnimationId
    OriginalAnimations[6] = animate.jump:FindFirstChildOfClass("Animation").AnimationId
    OriginalAnimations[7] = animate.climb:FindFirstChildOfClass("Animation").AnimationId
    OriginalAnimations[8] = animate.fall:FindFirstChildOfClass("Animation").AnimationId
    if animate:FindFirstChild("swim") then
        OriginalAnimations[9] = animate.swim:FindFirstChildOfClass("Animation").AnimationId
        OriginalAnimations[10] = animate.swimidle:FindFirstChildOfClass("Animation").AnimationId
    end
end
task.spawn(function()
    repeat task.wait() until LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("Animate")
        and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    cacheOriginalAnimations()
end)

local function StopEmotes()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, v in ipairs(animator:GetPlayingAnimationTracks()) do v:Stop() end
    end
    if _G_LoadAnim then pcall(function() _G_LoadAnim:Stop() end) end
end

local function RefreshAnims()
    local char = LocalPlayer.Character
    if not char then return end
    local animate = char:FindFirstChild("Animate")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not animate or not hum then return end
    animate.Disabled = true
    for _, v in ipairs(hum:GetPlayingAnimationTracks()) do v:Stop() end
    animate.Disabled = false
    local s = hum.WalkSpeed
    hum.WalkSpeed = 0
    task.wait()
    hum.WalkSpeed = s
end

local function resolveEmoteToAnimationId(emoteId)
    local fallbackId = tonumber(emoteId)
    if not emoteId or emoteId == "" then return fallbackId end
    local idStr = tostring(emoteId)
    local objects, ok = nil, false
    for _, url in ipairs({
        "rbxassetid://" .. idStr,
        "http://www.roblox.com/asset/?id=" .. idStr
    }) do
        ok, objects = pcall(function() return game:GetObjects(url) end)
        if ok and type(objects) == "table" and #objects > 0 then break end
    end
    if ok and type(objects) == "table" then
        local function findAnimId(obj)
            if obj:IsA("Animation") then
                local animId = tonumber((obj.AnimationId:gsub("rbxassetid://", "")))
                if animId and animId > 0 then return animId end
            end
            for _, child in ipairs(obj:GetChildren()) do
                local found = findAnimId(child)
                if found then return found end
            end
            return nil
        end
        for _, obj in ipairs(objects) do
            local found = findAnimId(obj)
            pcall(function() obj:Destroy() end)
            if found then return found end
        end
    end
    return fallbackId
end

local function PlayAnimation(id)
    if isUnloaded() then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local resolvedId = resolveEmoteToAnimationId(id)
    if not resolvedId then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(resolvedId)
    local ok, track = pcall(function() return hum:LoadAnimation(anim) end)
    if not ok or not track then return end
    _G_LoadAnim = track
    _G_LoadAnim.Priority = Enum.AnimationPriority.Action
    if not AnimState.PlayAlways then _G_LoadAnim:Stop() end
    if AnimState.Reversed then
        _G_LoadAnim:Play(0); _G_LoadAnim:AdjustSpeed(-1)
    else
        _G_LoadAnim:Play(0); _G_LoadAnim:AdjustSpeed(AnimState.EmoteSpeed)
    end
    if AnimState.Looped then _G_LoadAnim.Looped = true end
    if AnimState.FreezeEmote then _G_LoadAnim:AdjustSpeed(0) end
    local animate = char:FindFirstChild("Animate")
    if animate and not animate.Disabled then animate.Disabled = true end
end

local function ApplyAnimationSpeed()
    if isUnloaded() then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        pcall(function() track:AdjustSpeed(AnimState.AnimationSpeed) end)
    end
end

-- ============ ТАБЛИЦЫ АНИМАЦИЙ ============
local Emotes = {
    ['Fashion'] = 3333331310, ["Baby Dance"] = 4265725525, ["Cha-Cha"] = 6862001787,
    ['Monkey'] = 3333499508, ['Shuffle'] = 4349242221, ["Top Rock"] = 3361276673,
    ["Around Town"] = 3303391864, ["Fancy Feet"] = 3333432454, ["Hype Dance"] = 3695333486,
    ['Bodybuilder'] = 3333387824, ['Idol'] = 4101966434, ['Curtsy'] = 4555816777,
    ['Happy'] = 4841405708, ["Quiet Waves"] = 7465981288, ['Sleep'] = 4686925579,
    ["Floss Dance"] = 5917459365, ['Shy'] = 3337978742, ['Godlike'] = 3337994105,
    ["Hero Landing"] = 5104344710, ["High Wave"] = 5915690960, ['Cower'] = 4940563117,
    ['Bored'] = 5230599789, ['Celebrate'] = 3338097973, ['Dash'] = 582855105,
    ['Beckon'] = 5230598276, ['Haha'] = 3337966527, ["Line Dance"] = 4049037604,
    ['Shrug'] = 3334392772, ['Point2'] = 3344585679, ['Stadium'] = 3338055167,
    ['Confused'] = 4940561610, ['Side to Side'] = 3333136415, ['Hello'] = 3344650532,
    ['Dolphin Dance'] = 5918726674, ['Samba'] = 6869766175, ['Break Dance'] = 5915648917,
    ['Greatest'] = 3338042785, ['Sad'] = 4841407203, ['Flowing Breeze'] = 7465946930,
    ['Twirl'] = 3334968680, ['Jumping Wave'] = 4940564896, ['Dizzy'] = 3361426436,
    ['Fast Hands'] = 4265701731, ['Tree'] = 4049551434, ['Agree'] = 4841397952,
    ['Power Blast'] = 4841403964, ['Swoosh'] = 3361481910, ['Jumping Cheer'] = 5895324424,
    ['Disagree'] = 4841401869, ['Rock On'] = 5915714366, ['Block Partier'] = 6862022283,
    ['Dorky Dance'] = 4212455378, ['Zombie'] = 4210116953, ['T'] = 3338010159,
    ['Fishing'] = 3334832150, ['Robot'] = 3338025566, ['Keeping Time'] = 4555808220,
    ['Air Dance'] = 4555782893, ['Swan Dance'] = 7465997989, ['Louder'] = 3338083565,
    ['Sneaky'] = 3334424322, ['Heisman Pose'] = 3695263073, ['Jacks'] = 3338066331,
    ['Cha-Cha 2'] = 3695322025, ['Superhero Reveal'] = 3695373233, ['Air Guitar'] = 3695300085,
    ['Salute'] = 3333474484, ['Applaud'] = 5915693819, ['Bunny Hop'] = 4641985101,
    ['Tantrum'] = 5104341999, ['High Hands'] = 9710985298, ['Tilt'] = 3334538554,
    ['Chicken Dance'] = 4841399916, ['Rodeo'] = 5918728267, ['Old Town Road'] = 5937560570,
    ['Panini'] = 5915713518, ['Sturdy Dance'] = 17746180844, ['Skibidi Toilet'] = 134283166482394,
    ['M3GAN Dance'] = 99649534578309, ['NBA Fadeaway'] = 18526362841,
    ['TMNT Dance'] = 18665811005, ['Shrek Roar'] = 18524313628,
    ['SpongeBob Dance'] = 18443245017, ['Vroom Vroom'] = 18526397037,
    ['Cartwheel'] = 10370351535, ['Sidekicks'] = 10370362157, ['Boneless'] = 5918726674,
    ['Rock Star'] = 10714400171, ['Man City Backflip'] = 13694100677,
}

local Animations = {
    Stylish = {Idle=616136790, Idle2=616138447, Idle3=886888594, Walk=616146177, Run=616140816, Jump=616139451, Climb=616133594, Fall=616134815, Swim=616143378, SwimIdle=616144772},
    Zombie = {Idle=616158929, Idle2=616160636, Idle3=885545458, Walk=616168032, Run=616163682, Jump=616161997, Climb=616156119, Fall=616157476, Swim=616165109, SwimIdle=616166655},
    Robot = {Idle=616088211, Idle2=616089559, Idle3=885531463, Walk=616095330, Run=616091570, Jump=616090535, Climb=616086039, Fall=616087089, Swim=616092998, SwimIdle=616094091},
    Toy = {Idle=782841498, Idle2=782845736, Idle3=980952228, Walk=782843345, Run=782842708, Jump=782847020, Climb=782843869, Fall=782846423, Swim=782844582, SwimIdle=782845186},
    Cartoony = {Idle=742637544, Idle2=742638445, Idle3=885477856, Walk=742640026, Run=742638842, Jump=742637942, Climb=742636889, Fall=742637151, Swim=742639220, SwimIdle=742639812},
    Superhero = {Idle=616111295, Idle2=616113536, Idle3=885535855, Walk=616122287, Run=616117076, Jump=616115533, Climb=616104706, Fall=616108001, Swim=616119360, SwimIdle=616120861},
    Mage = {Idle=707742142, Idle2=707855907, Idle3=885508740, Walk=707897309, Run=707861613, Jump=707853694, Climb=707826056, Fall=707829716, Swim=707876443, SwimIdle=707894699},
    Levitation = {Idle=616006778, Idle2=616008087, Idle3=886862142, Walk=616013216, Run=616010382, Jump=616008936, Climb=616003713, Fall=616005863, Swim=616011509, SwimIdle=616012453},
    Vampire = {Idle=1083445855, Idle2=1083450166, Idle3=1088037547, Walk=1083473930, Run=1083462077, Jump=1083455352, Climb=1083439238, Fall=1083443587, Swim=1083464683, SwimIdle=1083467779},
    Ninja = {Idle=656117400, Idle2=656118341, Idle3=886742569, Walk=656121766, Run=656118852, Jump=656117878, Climb=656114359, Fall=656115606, Swim=656119721, SwimIdle=656121397},
    Knight = {Idle=657595757, Idle2=657568135, Idle3=885499184, Walk=657552124, Run=657564596, Jump=658409194, Climb=658360781, Fall=657600338, Swim=657560551, SwimIdle=657557095},
    Elder = {Idle=845397899, Idle2=845400520, Idle3=901160519, Walk=845403856, Run=845386501, Jump=845398858, Climb=845392038, Fall=845396048, Swim=845401742, SwimIdle=845403127},
    Werewolf = {Idle=1083195517, Idle2=1083214717, Idle3=1099492820, Walk=1083178339, Run=1083216690, Jump=1083218792, Climb=1083182000, Fall=1083189019, Swim=1083222527, SwimIdle=1083225406},
    Bold = {Idle=16738333868, Idle2=16738334710, Idle3=16738335517, Walk=16738340646, Run=16738337225, Jump=16738336650, Climb=16738332169, Fall=16738333171, Swim=16738339158, SwimIdle=16738339817},
    Astronaut = {Idle=891621366, Idle2=891633237, Idle3=1047759695, Walk=891667138, Run=891636393, Jump=891627522, Climb=891609353, Fall=891617961, Swim=891639666, SwimIdle=891663592},
    Bubbly = {Idle=910004836, Idle2=910009958, Idle3=1018536639, Walk=910034870, Run=910025107, Jump=910016857, Climb=909997997, Fall=910001910, Swim=910028158, SwimIdle=910030921},
    Pirate = {Idle=750781874, Idle2=750782770, Idle3=885515365, Walk=750785693, Run=750783738, Jump=750782230, Climb=750779899, Fall=750780242, Swim=750784579, SwimIdle=750785176},
    Rthro = {Idle=2510196951, Idle2=2510197257, Idle3=3711062489, Walk=2510202577, Run=2510198475, Jump=2510197830, Climb=2510192778, Fall=2510195892, Swim=2510199791, SwimIdle=2510201162},
    Oldschool = {Idle=5319828216, Idle2=5319831086, Idle3=5392107832, Walk=5319847204, Run=5319844329, Jump=5319841935, Climb=5319816685, Fall=5319839762, Swim=5319850266, SwimIdle=5319852613},
    Realistic = {Idle=17172918855, Idle2=17173014241, Idle3=17173014241, Walk=11600249883, Run=11600211410, Jump=11600210487, Climb=11600205519, Fall=11600206437, Swim=11600212676, SwimIdle=11600213505},
    Princess = {Idle=941003647, Idle2=941013098, Idle3=1159195712, Walk=941028902, Run=941015281, Jump=941008832, Climb=940996062, Fall=941000007, Swim=941018893, SwimIdle=941025398},
    Confident = {Idle=1069977950, Idle2=1069987858, Idle3=1116160740, Walk=1070017263, Run=1070001516, Jump=1069984524, Climb=1069946257, Fall=1069973677, Swim=1070009914, SwimIdle=1070012133},
    Popstar = {Idle=1212900985, Idle2=1150842221, Idle3=1239733474, Walk=1212980338, Run=1212980348, Jump=1212954642, Climb=1213044953, Fall=1212900995, Swim=1212852603, SwimIdle=1070012133},
    Patrol = {Idle=1149612882, Idle2=1150842221, Idle3=1159573567, Walk=1151231493, Run=1150967949, Jump=1150944216, Climb=1148811837, Fall=1148863382, Swim=1151204998, SwimIdle=1151221899},
    Cowboy = {Idle=1014390418, Idle2=1014398616, Idle3=1159487651, Walk=1014421541, Run=1014401683, Jump=1014394726, Climb=1014380606, Fall=1014384571, Swim=1014406523, SwimIdle=1014411816},
    Ghost = {Idle=616006778, Idle2=616008087, Idle3=616008087, Walk=616013216, Run=616013216, Jump=616008936, Climb=616003713, Fall=616005863, Swim=616011509, SwimIdle=616012453},
    Mocap = {Idle=913367814, Idle2=913373430, Idle3=913367814, Walk=913402848, Run=913376220, Jump=913370268, Climb=913362637, Fall=913365531, Swim=913384386, SwimIdle=913389285},
}

-- ============ РАЗБОР BUNDLE ============
local function resolveBundleMappings(bundledItems)
    local mappings = {}
    if not bundledItems then return mappings end
    for _, assetIds in pairs(bundledItems) do
        for _, assetId in pairs(assetIds) do
            local ok, objects = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(assetId))
            end)
            if ok and objects then
                local function searchTree(parent, parentPath)
                    for _, child in pairs(parent:GetChildren()) do
                        if child:IsA("Animation") then
                            local animationPath = parentPath .. "." .. child.Name
                            local pathParts = animationPath:split(".")
                            local cat = pathParts[#pathParts - 1]
                            local nm  = pathParts[#pathParts]
                            if not mappings[cat] then mappings[cat] = {} end
                            mappings[cat][nm] = child.AnimationId
                        elseif #child:GetChildren() > 0 then
                            searchTree(child, parentPath .. "." .. child.Name)
                        end
                    end
                end
                for _, obj in pairs(objects) do
                    searchTree(obj, obj.Name)
                    obj.Parent = workspace
                    task.delay(1, function() pcall(function() obj:Destroy() end) end)
                end
            end
        end
    end
    return mappings
end

local function applyEmoteByName(name)
    local id = Emotes[name]
    if not id then return end
    StopEmotes()
    AnimState.LastEmote = name
    PlayAnimation(id)
end

local function applyBundle(name)
    local a = Animations[name]
    if not a then return end
    if a.bundledItems then
        AnimState.SelectedAnimation = name
        StopEmotes()
        local mappings = resolveBundleMappings(a.bundledItems)
        if not mappings or not next(mappings) then return end
        local char = LocalPlayer.Character
        if not char then return end
        local animate = char:FindFirstChild("Animate")
        if not animate then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop() end)
            end
        end
        animate.Disabled = true
        for cat, anims in pairs(mappings) do
            local folder = animate:FindFirstChild(cat)
            if not folder then
                folder = Instance.new("Folder")
                folder.Name = cat
                folder.Parent = animate
            end
            for nm, animId in pairs(anims) do
                local animObj = folder:FindFirstChild(nm)
                if not animObj or not animObj:IsA("Animation") then
                    if animObj then animObj:Destroy() end
                    animObj = Instance.new("Animation")
                    animObj.Name = nm
                    animObj.Parent = folder
                end
                animObj.AnimationId = animId
            end
        end
        animate.Disabled = false
        if hum then
            local s = hum.WalkSpeed
            hum.WalkSpeed = 0
            task.wait()
            hum.WalkSpeed = s
        end
        return
    end
    AnimState.SelectedAnimation = name
    StopEmotes()
    local char = LocalPlayer.Character
    if not char then return end
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() t:Stop() end)
        end
    end
    animate.Disabled = true
    for _, folderName in ipairs({"idle", "walk", "run", "jump", "fall", "climb", "swim", "swimidle", "pose"}) do
        local folder = animate:FindFirstChild(folderName)
        if folder and a[folderName:gsub("^%l", string.upper)] then
            local anims = folder:GetChildren()
            for i, animObj in ipairs(anims) do
                if animObj:IsA("Animation") then
                    local key = folderName == "idle" and (i == 1 and "Idle" or i == 2 and "Idle2" or "Idle3") or
                                 folderName:gsub("^%l", string.upper)
                    if a[key] then
                        animObj.AnimationId = "rbxassetid://" .. tostring(a[key])
                    end
                end
            end
        end
    end
    animate.Disabled = false
    if hum then
        local speed = hum.WalkSpeed
        hum.WalkSpeed = 0
        task.wait()
        hum.WalkSpeed = speed
    end
end

-- ============ АВТОЗАГРУЗКА ============
task.spawn(function()
    local ok, err = pcall(function()
        local emoteJson = game:HttpGet("https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/EmoteSniper.json")
        local emoteData = HttpService:JSONDecode(emoteJson)
        local addedEmotes = 0
        if emoteData and emoteData.data then
            for _, item in ipairs(emoteData.data) do
                if item.name and item.id and not Emotes[item.name] then
                    Emotes[item.name] = tonumber(item.id)
                    addedEmotes = addedEmotes + 1
                end
            end
        end
        print("[ses_get3] Эмоций добавлено: " .. addedEmotes)

        local animJson = game:HttpGet("https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/AnimationSniper.json")
        local animData = HttpService:JSONDecode(animJson)
        local addedAnims = 0
        if animData and animData.data then
            for _, item in ipairs(animData.data) do
                if item.name and item.bundledItems and not Animations[item.name] then
                    Animations[item.name] = {
                        bundledItems = item.bundledItems,
                    }
                    addedAnims = addedAnims + 1
                end
            end
        end
        print("[ses_get3] Паков добавлено: " .. addedAnims)
    end)
    if not ok then warn("[ses_get3] Ошибка автозагрузки: " .. tostring(err)) end
end)

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ses_get3_pulse"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okParent = pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not okParent then pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end

local COL = {
    bg = Color3.fromRGB(14, 14, 16),
    panel = Color3.fromRGB(20, 20, 23),
    sidebar = Color3.fromRGB(18, 18, 20),
    card = Color3.fromRGB(28, 28, 32),
    cardHover = Color3.fromRGB(34, 34, 38),
    border = Color3.fromRGB(40, 40, 44),
    accent = Color3.fromRGB(120, 90, 255),
    accentBlue = Color3.fromRGB(59, 123, 255),
    green = Color3.fromRGB(76, 175, 80),
    text = Color3.fromRGB(235, 235, 240),
    textDim = Color3.fromRGB(138, 138, 143),
    toggleOff = Color3.fromRGB(50, 50, 54),
    red = Color3.fromRGB(220, 70, 70),
}

local function getViewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(720, 1280)
end

local vp = getViewport()
local isPortrait = vp.Y > vp.X
local FW = math.floor(vp.X * 0.96)
local FH = math.floor(vp.Y * (isPortrait and 0.78 or 0.85))
local SIDEBAR_W = isPortrait and 56 or 200

local MainFrame = nil
local CircleBtn = nil

local function minimizeMenu()
    if MainFrame then MainFrame.Visible = false end
    if CircleBtn then CircleBtn.Visible = true end
end

local function restoreMenu()
    if MainFrame then MainFrame.Visible = true end
    if CircleBtn then CircleBtn.Visible = false end
end

local function buildMM2Gui()
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, FW, 0, FH)
    Main.Position = UDim2.new(0.5, -FW/2, 0.5, -FH/2)
    Main.BackgroundColor3 = COL.bg
    Main.BackgroundTransparency = 0.15
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = COL.border
    MainStroke.Thickness = 1
    MainFrame = Main

    local TopStrip = Instance.new("Frame")
    TopStrip.Size = UDim2.new(0, 60, 0, 4)
    TopStrip.Position = UDim2.new(0.5, -30, 0, 4)
    TopStrip.BackgroundColor3 = COL.red
    TopStrip.BorderSizePixel = 0
    TopStrip.Parent = Main
    Instance.new("UICorner", TopStrip).CornerRadius = UDim.new(1, 0)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
    Sidebar.BackgroundColor3 = COL.sidebar
    Sidebar.BackgroundTransparency = 0.15
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

    local SidebarRightFix = Instance.new("Frame")
    SidebarRightFix.Size = UDim2.new(0, 12, 1, 0)
    SidebarRightFix.Position = UDim2.new(1, -12, 0, 0)
    SidebarRightFix.BackgroundColor3 = COL.sidebar
    SidebarRightFix.BorderSizePixel = 0
    SidebarRightFix.Parent = Sidebar

    local LogoWrap = Instance.new("Frame")
    LogoWrap.Size = UDim2.new(1, 0, 0, 50)
    LogoWrap.BackgroundTransparency = 1
    LogoWrap.Parent = Sidebar

    local LogoIcon = Instance.new("Frame")
    LogoIcon.Size = UDim2.new(0, 32, 0, 32)
    LogoIcon.Position = UDim2.new(0, 12, 0, 10)
    LogoIcon.BackgroundColor3 = COL.accent
    LogoIcon.BorderSizePixel = 0
    LogoIcon.Parent = LogoWrap
    Instance.new("UICorner", LogoIcon).CornerRadius = UDim.new(0, 6)

    local LogoTxt = Instance.new("TextLabel")
    LogoTxt.Size = UDim2.new(1, 0, 1, 0)
    LogoTxt.BackgroundTransparency = 1
    LogoTxt.Text = "S"
    LogoTxt.TextColor3 = COL.text
    LogoTxt.Font = Enum.Font.GothamBold
    LogoTxt.TextSize = 16
    LogoTxt.Parent = LogoIcon

    local NavList = Instance.new("ScrollingFrame")
    NavList.Name = "NavList"
    NavList.Size = UDim2.new(1, 0, 1, -50)
    NavList.Position = UDim2.new(0, 0, 0, 50)
    NavList.BackgroundTransparency = 1
    NavList.BorderSizePixel = 0
    NavList.ScrollBarThickness = 2
    NavList.ScrollBarImageColor3 = COL.accent
    NavList.ScrollBarImageTransparency = 0.4
    NavList.CanvasSize = UDim2.new(0, 0, 0, 0)
    NavList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    NavList.ScrollingDirection = Enum.ScrollingDirection.Y
    NavList.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    NavList.Active = true
    NavList.Parent = Sidebar
    local NavLayout = Instance.new("UIListLayout")
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Parent = NavList
    local NavPad = Instance.new("UIPadding", NavList)
    NavPad.PaddingLeft = UDim.new(0, 6)
    NavPad.PaddingRight = UDim.new(0, 6)
    NavPad.PaddingTop = UDim.new(0, 4)
    NavPad.PaddingBottom = UDim.new(0, 12)

    local navButtons, pages = {}, {}
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
    Content.Position = UDim2.new(0, SIDEBAR_W, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local function createNavBtn(icon, label, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = COL.sidebar
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.Parent = NavList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local iconLbl = Instance.new("TextLabel")
        iconLbl.Name = "Icon"
        iconLbl.Size = UDim2.new(0, 26, 1, 0)
        iconLbl.Position = UDim2.new(0, isPortrait and 15 or 8, 0, 0)
        iconLbl.BackgroundTransparency = 1
        iconLbl.Text = icon
        iconLbl.TextColor3 = COL.textDim
        iconLbl.Font = Enum.Font.Gotham
        iconLbl.TextSize = 16
        iconLbl.Parent = btn
        if not isPortrait then
            local textLbl = Instance.new("TextLabel")
            textLbl.Name = "Label"
            textLbl.Size = UDim2.new(1, -40, 1, 0)
            textLbl.Position = UDim2.new(0, 38, 0, 0)
            textLbl.BackgroundTransparency = 1
            textLbl.Text = label
            textLbl.TextColor3 = COL.textDim
            textLbl.Font = Enum.Font.GothamMedium
            textLbl.TextSize = 13
            textLbl.TextXAlignment = Enum.TextXAlignment.Left
            textLbl.Parent = btn
            local arrow = Instance.new("TextLabel")
            arrow.Name = "Arrow"
            arrow.Size = UDim2.new(0, 16, 1, 0)
            arrow.Position = UDim2.new(1, -20, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "›"
            arrow.TextColor3 = COL.textDim
            arrow.Font = Enum.Font.Gotham
            arrow.TextSize = 16
            arrow.Parent = btn
        end
        return btn
    end

    local function createPage(order)
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = COL.accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
        page.ScrollBarImageTransparency = 0.5
        page.Visible = false
        page.Parent = Content
        local list = Instance.new("UIListLayout", page)
        list.Padding = UDim.new(0, 8)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pad = Instance.new("UIPadding", page)
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingBottom = UDim.new(0, 16)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        return page
    end

    local function selectPage(idx)
        for i, p in ipairs(pages) do p.Visible = (i == idx) end
        for i, b in ipairs(navButtons) do
            local icon = b:FindFirstChild("Icon")
            local label = b:FindFirstChild("Label")
            if i == idx then
                b.BackgroundTransparency = 0
                b.BackgroundColor3 = COL.card
                if icon then icon.TextColor3 = COL.text end
                if label then label.TextColor3 = COL.text end
            else
                b.BackgroundTransparency = 1
                if icon then icon.TextColor3 = COL.textDim end
                if label then label.TextColor3 = COL.textDim end
            end
        end
    end

    local function createToggle(parent, title, desc, initial, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 54)
        row.BackgroundColor3 = COL.card
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", row)
        stroke.Color = COL.border
        stroke.Thickness = 1
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -80, 0, 18)
        t.Position = UDim2.new(0, 12, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = COL.text
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = row
        if desc then
            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(1, -80, 0, 16)
            d.Position = UDim2.new(0, 12, 0, 28)
            d.BackgroundTransparency = 1
            d.Text = desc
            d.TextColor3 = COL.textDim
            d.Font = Enum.Font.Gotham
            d.TextSize = 10
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.TextWrapped = true
            d.Parent = row
        end
        local switchBg = Instance.new("Frame")
        switchBg.Size = UDim2.new(0, 46, 0, 26)
        switchBg.Position = UDim2.new(1, -58, 0.5, -13)
        switchBg.BackgroundColor3 = initial and COL.accent or COL.toggleOff
        switchBg.BorderSizePixel = 0
        switchBg.Parent = row
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.Position = initial and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = switchBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local state = initial
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = row
        btn.MouseButton1Click:Connect(function()
            if isUnloaded() then return end
            state = not state
            TweenService:Create(switchBg, TweenInfo.new(0.15), {
                BackgroundColor3 = state and COL.accent or COL.toggleOff
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            }):Play()
            if callback then pcall(callback, state) end
        end)
    end

    local function createActionBtn(parent, title, color, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 42)
        b.BackgroundColor3 = color or COL.card
        b.Text = title
        b.TextColor3 = COL.text
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 13
        b.BorderSizePixel = 0
        b.AutoButtonColor = true
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", b)
        stroke.Color = COL.border
        stroke.Thickness = 1
        b.MouseButton1Click:Connect(function() if callback and not isUnloaded() then pcall(callback) end end)
        return b
    end

    local function createActionGrid(parent, buttons)
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, 0, 0, 0)
        wrap.AutomaticSize = Enum.AutomaticSize.Y
        wrap.BackgroundTransparency = 1
        wrap.Parent = parent
        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0.5, -4, 0, 42)
        grid.CellPadding = UDim2.new(0, 8, 0, 8)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        grid.Parent = wrap
        for i, def in ipairs(buttons) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 1, 0)
            b.BackgroundColor3 = def.color or COL.card
            b.Text = def.title
            b.TextColor3 = COL.text
            b.Font = Enum.Font.GothamMedium
            b.TextSize = 12
            b.BorderSizePixel = 0
            b.LayoutOrder = i
            b.AutoButtonColor = true
            b.Parent = wrap
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
            local stroke = Instance.new("UIStroke", b)
            stroke.Color = COL.border
            stroke.Thickness = 1
            b.MouseButton1Click:Connect(function()
                if def.callback and not isUnloaded() then pcall(def.callback) end
            end)
        end
        return wrap
    end

    local function createInput(parent, placeholder)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, 0, 0, 42)
        box.BackgroundColor3 = COL.card
        box.BorderSizePixel = 0
        box.PlaceholderText = placeholder or ""
        box.Text = ""
        box.TextColor3 = COL.text
        box.PlaceholderColor3 = COL.textDim
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.ClearTextOnFocus = false
        box.Parent = parent
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
        local s = Instance.new("UIStroke", box)
        s.Color = COL.border
        s.Thickness = 1
        return box
    end

    local function createPageHeader(parent, title, subtitle)
        local h = Instance.new("Frame")
        h.Size = UDim2.new(1, 0, 0, 46)
        h.BackgroundTransparency = 1
        h.Parent = parent
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 24)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = COL.text
        t.Font = Enum.Font.GothamBold
        t.TextSize = 16
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = h
        if subtitle then
            local s = Instance.new("TextLabel")
            s.Size = UDim2.new(1, 0, 0, 16)
            s.Position = UDim2.new(0, 0, 0, 26)
            s.BackgroundTransparency = 1
            s.Text = subtitle
            s.TextColor3 = COL.textDim
            s.Font = Enum.Font.Gotham
            s.TextSize = 11
            s.TextXAlignment = Enum.TextXAlignment.Left
            s.TextWrapped = true
            s.Parent = h
        end
        return h
    end

    local function createSectionLabel(parent, text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 18)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = COL.textDim
        l.Font = Enum.Font.GothamBold
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = parent
        return l
    end

    -- ВКЛАДКИ
    local MainBtn     = createNavBtn("🏠", "Главная", 1);   local MainPage     = createPage(1)
    local BattleBtn   = createNavBtn("⚔️", "Бой", 2);       local BattlePage   = createPage(2)
    local FarmBtn     = createNavBtn("🛒", "Фарм", 3);      local FarmPage     = createPage(3)
    local FlingBtn    = createNavBtn("⚡", "Флинг", 4);     local FlingPage    = createPage(4)
    local VoteBtn     = createNavBtn("🗳️", "Vote Dupe", 5); local VotePage     = createPage(5)
    local AnimBtn     = createNavBtn("🎬", "Анимации", 6);  local AnimPage     = createPage(6)
    local FeaturesBtn = createNavBtn("🧩", "Фишки", 7);     local FeaturesPage = createPage(7)
    local SettingsBtn = createNavBtn("⚙️", "Настройки", 8); local SettingsPage = createPage(8)

    pages = {MainPage, BattlePage, FarmPage, FlingPage, VotePage, AnimPage, FeaturesPage, SettingsPage}
    navButtons = {MainBtn, BattleBtn, FarmBtn, FlingBtn, VoteBtn, AnimBtn, FeaturesBtn, SettingsBtn}
    for i, b in ipairs(navButtons) do
        b.MouseButton1Click:Connect(function() selectPage(i) end)
    end
    selectPage(1)

    -- ГЛАВНАЯ
    createPageHeader(MainPage, "Главная", "Быстрый доступ")
    createSectionLabel(MainPage, "ОСНОВНОЕ")
    createToggle(MainPage, "ESP", "Подсветка ролей", Config.ESP, function(v) Config.ESP = v; saveConfig() end)
    createToggle(MainPage, "Anti-Fling", "Защита от флинга", Config.AntiFling, function(v) Config.AntiFling = v; saveConfig() end)
    createToggle(MainPage, "Invisible", "Невидимость (клавиша G)", Config.Invisible, function(v)
        Config.Invisible = v
        saveConfig()
        updateInvisible()
    end)
    createSectionLabel(MainPage, "ИНФО")
    local roleInfoLbl = Instance.new("TextLabel")
    roleInfoLbl.Size = UDim2.new(1, 0, 0, 42)
    roleInfoLbl.BackgroundColor3 = COL.card
    roleInfoLbl.BorderSizePixel = 0
    roleInfoLbl.Text = "Твоя роль: загрузка..."
    roleInfoLbl.TextColor3 = COL.text
    roleInfoLbl.Font = Enum.Font.GothamMedium
    roleInfoLbl.TextSize = 13
    roleInfoLbl.Parent = MainPage
    Instance.new("UICorner", roleInfoLbl).CornerRadius = UDim.new(0, 10)
    task.spawn(function()
        while not isUnloaded() do
            task.wait(0.5)
            pcall(function()
                local r = getRoleString() or "Неизвестно"
                local rn = r
                if r == "Murderer" then rn = "🔪 Маньяк"
                elseif r == "Sheriff" then rn = "🎯 Шериф"
                elseif r == "Hero" then rn = "🌟 Герой"
                elseif r == "Innocent" then rn = "😇 Невинный" end
                roleInfoLbl.Text = "Твоя роль: " .. rn
            end)
        end
    end)

    -- БОЙ
    createPageHeader(BattlePage, "Бой", "Оружие и автоатака")
    createSectionLabel(BattlePage, "СТРЕЛЬБА")
    createToggle(BattlePage, "Авто-стрельба", "Стрельба в маньяка", Config.AutoShoot, function(v) Config.AutoShoot = v; saveConfig() end)
    createToggle(BattlePage, "Magic Bullet", "Стрельба сквозь стены", Config.MagicBullet, function(v)
        Config.MagicBullet = v; saveConfig()
        if v then enableMagicBullet() else disableMagicBullet() end
    end)
    createSectionLabel(BattlePage, "АВТО-УБИЙСТВО")
    createToggle(BattlePage, "Убийство всех", "Только для маньяка", Config.AutoKill, function(v) Config.AutoKill = v; saveConfig() end)
    createSectionLabel(BattlePage, "ПОДБОР")
    createToggle(BattlePage, "Авто-подбор пистолета", "Подбирать GunDrop", Config.AutoGrabGun, function(v) Config.AutoGrabGun = v; saveConfig() end)

    -- ФАРМ
    createPageHeader(FarmPage, "Автофарм", "Только при Сборе монет")
    createSectionLabel(FarmPage, "ГЛАВНЫЙ ПЕРЕКЛЮЧАТЕЛЬ")
    createToggle(FarmPage, "Сбор монет", "Автосбор всех монет", Config.FarmCoins, function(v)
        Config.FarmCoins = v; saveConfig()
        if not v then
            if farmingActive then stopFarming(); restoreNormalGravity() end
            allCoinsCollected = false
            bagFullActionInProgress = false
        end
    end)
    createSectionLabel(FarmPage, "НАСТРОЙКИ")
    createToggle(FarmPage, "Сброс при полном", "Автосуицид", Config.FarmResetBagFull, function(v) Config.FarmResetBagFull = v; saveConfig() end)
    createToggle(FarmPage, "Атака после сбора", "Sheriff/Innocent", Config.AutoAttackAfterFarm, function(v) Config.AutoAttackAfterFarm = v; saveConfig() end)
    createToggle(FarmPage, "Убить всех за маньяка", "Когда мешок полон", Config.MurdererKillAllOnFull, function(v) Config.MurdererKillAllOnFull = v; saveConfig() end)
    createToggle(FarmPage, "Флинг маньяка при смерти", "Если убил тебя", Config.FlingOnDeath, function(v)
        FlingOnDeathEnabled = v; Config.FlingOnDeath = v; saveConfig()
    end)
    createSectionLabel(FarmPage, "СТАТИСТИКА")
    local farmStat = Instance.new("TextLabel")
    farmStat.Size = UDim2.new(1, 0, 0, 42)
    farmStat.BackgroundColor3 = COL.card
    farmStat.BorderSizePixel = 0
    farmStat.Text = "Монет: 0 / 0"
    farmStat.TextColor3 = COL.text
    farmStat.Font = Enum.Font.GothamMedium
    farmStat.TextSize = 13
    farmStat.Parent = FarmPage
    Instance.new("UICorner", farmStat).CornerRadius = UDim.new(0, 10)
    task.spawn(function()
        while not isUnloaded() do
            task.wait(0.5)
            pcall(function() farmStat.Text = "Монет: " .. currentCoinsCollected .. " / " .. maxCoinsInRound end)
        end
    end)

    -- ФЛИНГ
    createPageHeader(FlingPage, "Флинг", "Отправка игроков в полёт")
    createSectionLabel(FlingPage, "ПО РОЛИ")
    createActionGrid(FlingPage, {
        {title = "⚡ Маньяк", color = Color3.fromRGB(180, 40, 40), callback = function() FlingByRole("Murderer") end},
        {title = "⚡ Шериф", color = Color3.fromRGB(40, 90, 180), callback = function() FlingByRole("Sheriff") end},
        {title = "⚡ Невинный", color = Color3.fromRGB(40, 140, 60), callback = function() FlingByRole("Innocent") end},
        {title = "⚡ Герой", color = Color3.fromRGB(180, 150, 40), callback = function() FlingByRole("Hero") end},
    })
    createSectionLabel(FlingPage, "ПО НИКУ")
    local nameInput = createInput(FlingPage, "Введи ник...")
    createActionBtn(FlingPage, "⚡ Флинг по нику", COL.accent, function()
        local target = FindPlayerByPartialName(nameInput.Text)
        if target then
            FlingActive = true
            task.spawn(function() pcall(SkidFling, target); FlingActive = false end)
        end
    end)
    createActionBtn(FlingPage, "⛔ Остановить", Color3.fromRGB(150, 50, 50), StopFling)

    -- ============ VOTE DUPE ============
    local voteActivePad
    local voteLoopThread
    local voteVotesCast = 0
    local voteCards = {}

    local function getVoteLobby()
        return workspace:FindFirstChild("RegularLobby") or workspace:FindFirstChild("Lobby")
    end
    local function getVotePad(i)
        local lobby = getVoteLobby()
        if not lobby then return nil end
        return lobby:FindFirstChild("VotePad" .. i) or lobby:FindFirstChild("VotePad" .. i, true)
    end
    local function getVotePadCF(pad)
        if not pad then return nil end
        if pad:IsA("BasePart") then return pad.CFrame end
        if pad:IsA("Model") then return pad:GetPivot() end
        local part = pad:FindFirstChildWhichIsA("BasePart", true)
        return part and part.CFrame
    end

    local voteGuisByAdornee = {}
    local function scanVoteGuis()
        table.clear(voteGuisByAdornee)
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not playerGui then return end
        for _, g in ipairs(playerGui:GetDescendants()) do
            if (g:IsA("SurfaceGui") or g:IsA("BillboardGui")) and g.Adornee then
                local list = voteGuisByAdornee[g.Adornee] or {}
                voteGuisByAdornee[g.Adornee] = list
                table.insert(list, g)
            end
        end
    end
    local function getVotePadGuis(pad)
        local out = {}
        for adornee, list in pairs(voteGuisByAdornee) do
            if adornee == pad or adornee:IsDescendantOf(pad) then
                for _, g in ipairs(list) do table.insert(out, g) end
            end
        end
        local voteInfo = pad:FindFirstChild("VoteInfoGui", true)
        if voteInfo then table.insert(out, voteInfo) end
        return out
    end
    local function readVotePad(pad)
        if not pad then return nil, nil end
        local map, votes
        for _, g in ipairs(getVotePadGuis(pad)) do
            if g:IsA("LayerCollector") and not g.Enabled then continue end
            local box = g:FindFirstChild("Container", true) or g
            local function hex(name)
                local o = box:FindFirstChild(name, true)
                if o and (o:IsA("TextLabel") or o:IsA("TextButton")) and o.Text ~= "" then
                    return o.Text
                end
            end
            map = map or hex("MapName")
            local v = hex("Votes")
            if v and (not votes or (tonumber(v:match("%d+")) or 0) > (tonumber(votes:match("%d+")) or 0)) then
                votes = v
            end
        end
        return map, votes
    end
    local function findVotePadImage(pad)
        if not pad then return nil end
        local best, bestScore = nil, 0
        for _, d in ipairs(pad:GetDescendants()) do
            local img, name = nil, d.Name:lower()
            if d:IsA("ImageLabel") or d:IsA("ImageButton") then
                img = d.Image
                if img and img ~= "" and d.ImageTransparency < 0.95 then
                    local score = (name:find("map") or name:find("thumb") or name:find("preview")) and 3
                        or ((name:find("image") or name:find("icon") or name:find("picture")) and 2 or 1)
                    if score > bestScore then best, bestScore = img, score end
                end
            elseif d:IsA("Decal") or d:IsA("Texture") then
                img = d.Texture
                if img and img ~= "" then
                    local score = (name:find("map") or name:find("thumb")) and 3 or 1
                    if score > bestScore then best, bestScore = img, score end
                end
            end
        end
        return best
    end

    createPageHeader(VotePage, "Vote Dupe Map", "Зацикливание голосования за карту")
    createSectionLabel(VotePage, "ВЫБОР КАРТЫ")

    local voteGrid = Instance.new("Frame")
    voteGrid.Size = UDim2.new(1, 0, 0, 0)
    voteGrid.AutomaticSize = Enum.AutomaticSize.Y
    voteGrid.BackgroundTransparency = 1
    voteGrid.Parent = VotePage
    local voteGridLayout = Instance.new("UIGridLayout")
    voteGridLayout.CellSize = UDim2.new(1, 0, 0, 76)
    voteGridLayout.CellPadding = UDim2.new(0, 0, 0, 8)
    voteGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    voteGridLayout.Parent = voteGrid

    for i = 1, 3 do
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(1, 0, 1, 0)
        card.BackgroundColor3 = COL.card
        card.Text = ""
        card.BorderSizePixel = 0
        card.LayoutOrder = i
        card.AutoButtonColor = false
        card.ClipsDescendants = true
        card.Parent = voteGrid
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
        local cardStroke = Instance.new("UIStroke", card)
        cardStroke.Color = COL.border
        cardStroke.Thickness = 1

        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0, 76, 0, 76)
        thumb.BackgroundColor3 = COL.card
        thumb.ClipsDescendants = true
        thumb.ZIndex = 2
        thumb.Parent = card
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 10)

        local ph = Instance.new("TextLabel")
        ph.Text = "?"
        ph.Font = Enum.Font.GothamBlack
        ph.TextSize = 22
        ph.TextColor3 = COL.textDim
        ph.BackgroundTransparency = 1
        ph.Size = UDim2.fromScale(1, 1)
        ph.ZIndex = 3
        ph.Parent = thumb

        local img = Instance.new("ImageLabel")
        img.Size = UDim2.fromScale(1, 1)
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Crop
        img.ImageColor3 = Color3.fromRGB(220, 220, 220)
        img.ImageTransparency = 1
        img.ZIndex = 4
        img.Parent = thumb
        Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -90, 0, 22)
        nameLbl.Position = UDim2.new(0, 86, 0, 10)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = "LOADING..."
        nameLbl.TextColor3 = COL.text
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 14
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.ZIndex = 3
        nameLbl.Parent = card

        local votesLbl = Instance.new("TextLabel")
        votesLbl.Size = UDim2.new(1, -90, 0, 16)
        votesLbl.Position = UDim2.new(0, 86, 0, 34)
        votesLbl.BackgroundTransparency = 1
        votesLbl.Text = "votes —"
        votesLbl.TextColor3 = COL.textDim
        votesLbl.Font = Enum.Font.Gotham
        votesLbl.TextSize = 12
        votesLbl.TextXAlignment = Enum.TextXAlignment.Left
        votesLbl.ZIndex = 3
        votesLbl.Parent = card

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -90, 0, 14)
        statusLbl.Position = UDim2.new(0, 86, 0, 54)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "idle"
        statusLbl.TextColor3 = COL.textDim
        statusLbl.Font = Enum.Font.GothamBold
        statusLbl.TextSize = 11
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.ZIndex = 3
        statusLbl.Parent = card

        voteCards[i] = {
            card = card, stroke = cardStroke, thumb = thumb, img = img, ph = ph,
            name = nameLbl, votes = votesLbl, status = statusLbl, image = nil, map = nil,
        }

        card.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = COL.cardHover}):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = COL.card}):Play()
        end)
    end

    local function relayoutVoteCards()
        for i, c in ipairs(voteCards) do
            local on = voteActivePad == i
            TweenService:Create(c.stroke, TweenInfo.new(0.2), {
                Color = on and COL.accent or COL.border,
                Thickness = on and 1.5 or 1,
            }):Play()
            c.status.TextColor3 = on and COL.accent or COL.textDim
            c.status.Text = on and ("voting " .. voteVotesCast) or "idle"
        end
    end

    local function stopVoteLoop(silent)
        if voteLoopThread then pcall(task.cancel, voteLoopThread); voteLoopThread = nil end
        voteActivePad = nil
        relayoutVoteCards()
    end
    local function votePadVotes(i)
        local pad = getVotePad(i)
        if not pad then return false end
        local map, votes = readVotePad(pad)
        if not (map and votes) then return false end
        return true, tonumber(votes:match("%d+"))
    end
    local function startVoteLoop(i)
        stopVoteLoop(true)
        voteActivePad = i
        voteVotesCast = 0
        relayoutVoteCards()
        voteLoopThread = task.spawn(function()
            local best, stale = nil, 0
            while voteActivePad == i do
                scanVoteGuis()
                local active, count = votePadVotes(i)
                if not active then stopVoteLoop(true); return end
                best = best or count
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local target = getVotePadCF(getVotePad(i))
                if hum and hum.Health > 0 and root and target then
                    root.CFrame = target + Vector3.new(0, 2.5, 0)
                    local before = count
                    local waitStart = os.clock()
                    repeat
                        RunService.Heartbeat:Wait()
                        root.CFrame = target + Vector3.new(0, 2.5, 0)
                        scanVoteGuis()
                        local _, c = votePadVotes(i)
                        if c and before and c > before then break end
                    until os.clock() - waitStart >= 0.4 or voteActivePad ~= i
                    if voteActivePad ~= i then break end
                    scanVoteGuis()
                    active, count = votePadVotes(i)
                    if not active then stopVoteLoop(true); return end
                    if count and best and count <= best then
                        stale += 1
                        if stale >= 3 then stopVoteLoop(true); return end
                    else stale = 0; best = count or best end
                    voteVotesCast += 1
                    if hum.Health > 0 then hum.Health = 0 end
                    local newChar = LocalPlayer.CharacterAdded:Wait()
                    newChar:WaitForChild("HumanoidRootPart", 3)
                    task.wait(0.12)
                elseif not hum or hum.Health <= 0 then
                    local respawned = LocalPlayer.CharacterAdded:Wait()
                    respawned:WaitForChild("HumanoidRootPart", 3)
                    task.wait(0.12)
                else task.wait(0.2) end
            end
        end)
    end

    for i, c in ipairs(voteCards) do
        c.card.MouseButton1Click:Connect(function()
            if isUnloaded() then return end
            if voteActivePad == i then stopVoteLoop() else startVoteLoop(i) end
        end)
    end

    createActionBtn(VotePage, "⛔ Остановить Vote Dupe", Color3.fromRGB(150, 50, 50), function()
        if voteActivePad then stopVoteLoop() end
    end)

    createSectionLabel(VotePage, "ИНФО")
    local voteInfoLbl = Instance.new("TextLabel")
    voteInfoLbl.Size = UDim2.new(1, 0, 0, 60)
    voteInfoLbl.BackgroundColor3 = COL.card
    voteInfoLbl.BorderSizePixel = 0
    voteInfoLbl.Text = "Выбери карту выше чтобы начать дупать. Превью карт показываются если доступны."
    voteInfoLbl.TextColor3 = COL.textDim
    voteInfoLbl.Font = Enum.Font.Gotham
    voteInfoLbl.TextSize = 11
    voteInfoLbl.TextWrapped = true
    voteInfoLbl.Parent = VotePage
    Instance.new("UICorner", voteInfoLbl).CornerRadius = UDim.new(0, 10)

    task.spawn(function()
        while not isUnloaded() do
            pcall(function()
                scanVoteGuis()
                local lobby = getVoteLobby()
                local roundActive = (lobby == nil)
                for i, c in ipairs(voteCards) do
                    if roundActive then
                        c.card.Visible = false
                        c.map = nil; c.image = nil
                        c.img.Image = ""; c.img.ImageTransparency = 1
                        c.ph.Visible = true; c.ph.Text = "?"
                        c.name.Text = ""; c.votes.Text = ""; c.status.Text = ""
                    else
                        c.card.Visible = true
                        local pad = getVotePad(i)
                        local map, votes
                        if pad then map, votes = readVotePad(pad) end
                        if not pad then
                            c.map = nil
                            c.name.Text = "UNAVAILABLE"
                            c.img.Image = ""; c.img.ImageTransparency = 1
                            c.ph.Visible = true; c.ph.Text = "?"
                        elseif map then
                            if map ~= c.map then
                                c.map = map
                                c.name.Text = string.upper(map)
                                local initials = ""
                                for w in map:gmatch("%S+") do initials = initials .. w:sub(1,1):upper() end
                                c.ph.Text = initials:sub(1, 3)
                            end
                            local image = findVotePadImage(pad)
                            if image and c.image ~= image then
                                c.image = image
                                c.img.Image = image
                                c.img.ImageTransparency = 0
                                c.ph.Visible = false
                            elseif not image then
                                c.img.Image = ""
                                c.img.ImageTransparency = 1
                                c.ph.Visible = true
                            end
                        else
                            c.map = nil; c.image = nil
                            c.name.Text = "WAITING..."
                            c.img.Image = ""; c.img.ImageTransparency = 1
                            c.ph.Visible = true; c.ph.Text = "?"
                        end
                        c.votes.Text = "votes " .. (votes or "—")
                    end
                end
                if voteActivePad and (roundActive or not votePadVotes(voteActivePad)) then
                    stopVoteLoop(true)
                end
            end)
            task.wait(0.5)
        end
    end)

    -- ============ АНИМАЦИИ UI ============
    local FAV_FILE = "ses_get3_favorites.json"
    local Favorites = { Bundles = {}, Emotes = {} }
    local function loadFavorites()
        pcall(function()
            if isfile and isfile(FAV_FILE) then
                local data = HttpService:JSONDecode(readfile(FAV_FILE))
                if data.Bundles then Favorites.Bundles = data.Bundles end
                if data.Emotes then Favorites.Emotes = data.Emotes end
            end
        end)
    end
    local function saveFavorites()
        pcall(function()
            if writefile then writefile(FAV_FILE, HttpService:JSONEncode(Favorites)) end
        end)
    end
    loadFavorites()
    local function isFavBundle(name) return Favorites.Bundles[name] == true end
    local function isFavEmote(name) return Favorites.Emotes[name] == true end

    createPageHeader(AnimPage, "Настройки анимации", nil)

    local TabRow = Instance.new("Frame")
    TabRow.Size = UDim2.new(1, 0, 0, 36)
    TabRow.BackgroundTransparency = 1
    TabRow.Parent = AnimPage
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.Padding = UDim.new(0, 6)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.VerticalAlignment = Enum.VerticalAlignment.Center
    TabList.Parent = TabRow

    local currentTab = "Bundles"
    local searchTerm = ""
    local currentPage = 1
    local ITEMS_PER_PAGE = 60
    local tabs = {}
    local function createTabBtn(text, order, width, withDot)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, width or 90, 1, 0)
        b.BackgroundColor3 = COL.card
        b.BackgroundTransparency = 1
        b.Text = withDot and ("● " .. text) or text
        b.TextColor3 = COL.textDim
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 12
        b.LayoutOrder = order
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Parent = TabRow
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        return b
    end
    local TabBundles = createTabBtn("Бандлы", 1, 100, true)
    local TabEmotes  = createTabBtn("Эмоции", 2, 80, false)
    local TabFav     = createTabBtn("Избр.", 3, 70, false)
    tabs.Bundles, tabs.Emotes, tabs.Favorites = TabBundles, TabEmotes, TabFav

    local function updateTabs()
        for k, b in pairs(tabs) do
            if k == currentTab then
                b.BackgroundTransparency = 0
                b.BackgroundColor3 = COL.card
                b.TextColor3 = COL.text
            else
                b.BackgroundTransparency = 1
                b.TextColor3 = COL.textDim
            end
        end
    end

    local SearchRow = Instance.new("Frame")
    SearchRow.Size = UDim2.new(1, 0, 0, 42)
    SearchRow.BackgroundTransparency = 1
    SearchRow.Parent = AnimPage

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -70, 1, 0)
    SearchBox.BackgroundColor3 = COL.card
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "🔍 Поиск эмоций/паков"
    SearchBox.TextColor3 = COL.text
    SearchBox.PlaceholderColor3 = COL.textDim
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.ClearTextOnFocus = false
    SearchBox.BorderSizePixel = 0
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Parent = SearchRow
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)
    local sspad = Instance.new("UIPadding", SearchBox)
    sspad.PaddingLeft = UDim.new(0, 10)
    local ss = Instance.new("UIStroke", SearchBox)
    ss.Color = COL.border
    ss.Thickness = 1

    local GoBtn = Instance.new("TextButton")
    GoBtn.Size = UDim2.new(0, 60, 1, 0)
    GoBtn.Position = UDim2.new(1, -60, 0, 0)
    GoBtn.BackgroundColor3 = COL.green
    GoBtn.Text = "Go"
    GoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GoBtn.Font = Enum.Font.GothamBold
    GoBtn.TextSize = 13
    GoBtn.BorderSizePixel = 0
    GoBtn.Parent = SearchRow
    Instance.new("UICorner", GoBtn).CornerRadius = UDim.new(0, 10)

    local CounterLbl = Instance.new("TextLabel")
    CounterLbl.Size = UDim2.new(1, 0, 0, 20)
    CounterLbl.BackgroundTransparency = 1
    CounterLbl.Text = "Загрузка..."
    CounterLbl.TextColor3 = COL.textDim
    CounterLbl.Font = Enum.Font.Gotham
    CounterLbl.TextSize = 12
    CounterLbl.TextXAlignment = Enum.TextXAlignment.Left
    CounterLbl.Parent = AnimPage

    local Grid = Instance.new("Frame")
    Grid.Size = UDim2.new(1, 0, 0, 0)
    Grid.AutomaticSize = Enum.AutomaticSize.Y
    Grid.BackgroundTransparency = 1
    Grid.Parent = AnimPage

    local COLUMNS = 3
    local CELL_W = math.floor((FW - SIDEBAR_W - 40 - (COLUMNS-1)*8) / COLUMNS)
    if CELL_W < 90 then COLUMNS = 2; CELL_W = math.floor((FW - SIDEBAR_W - 40 - 8) / 2) end
    if CELL_W < 90 then CELL_W = 90 end
    local CELL_H = CELL_W + 36

    local GridLayout = Instance.new("UIGridLayout")
    GridLayout.CellSize = UDim2.new(0, CELL_W, 0, CELL_H)
    GridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    GridLayout.Parent = Grid

    local cardButtons = {}
    local refreshCards

    local PaginationRow = Instance.new("Frame")
    PaginationRow.Size = UDim2.new(1, 0, 0, 44)
    PaginationRow.BackgroundTransparency = 1
    PaginationRow.Parent = AnimPage

    local PageLbl = Instance.new("TextLabel")
    PageLbl.Size = UDim2.new(1, -220, 1, 0)
    PageLbl.Position = UDim2.new(0, 220, 0, 0)
    PageLbl.BackgroundTransparency = 1
    PageLbl.Text = "Стр. 1 / 1"
    PageLbl.TextColor3 = COL.text
    PageLbl.Font = Enum.Font.GothamBold
    PageLbl.TextSize = 13
    PageLbl.TextXAlignment = Enum.TextXAlignment.Center
    PageLbl.Parent = PaginationRow

    local function createCard(name, id, kind, order)
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(1, 0, 1, 0)
        card.BackgroundColor3 = COL.card
        card.Text = ""
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.AutoButtonColor = false
        card.Parent = Grid
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 9)
        local s = Instance.new("UIStroke", card)
        s.Color = COL.border
        s.Thickness = 1

        local star = Instance.new("TextButton")
        star.Size = UDim2.new(0, 22, 0, 22)
        star.Position = UDim2.new(1, -26, 0, 4)
        star.BackgroundTransparency = 1
        star.Text = ""
        star.Parent = card
        local starIcon = Instance.new("TextLabel")
        starIcon.Size = UDim2.new(1, 0, 1, 0)
        starIcon.BackgroundTransparency = 1
        local isFav = (kind == "bundle") and isFavBundle(name) or isFavEmote(name)
        starIcon.Text = isFav and "★" or "☆"
        starIcon.TextColor3 = isFav and Color3.fromRGB(255, 215, 0) or COL.textDim
        starIcon.Font = Enum.Font.GothamBold
        starIcon.TextSize = 16
        starIcon.Parent = star

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -8, 1, -8)
        nameLbl.Position = UDim2.new(0, 4, 0, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = name
        nameLbl.TextColor3 = COL.text
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 10
        nameLbl.TextWrapped = true
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextYAlignment = Enum.TextYAlignment.Top
        nameLbl.Parent = card

        card.MouseButton1Click:Connect(function()
            if isUnloaded() then return end
            if kind == "bundle" then
                applyBundle(name)
            else
                applyEmoteByName(name)
            end
        end)
        star.MouseButton1Click:Connect(function()
            if isUnloaded() then return end
            if kind == "bundle" then
                if Favorites.Bundles[name] then Favorites.Bundles[name] = nil else Favorites.Bundles[name] = true end
            else
                if Favorites.Emotes[name] then Favorites.Emotes[name] = nil else Favorites.Emotes[name] = true end
            end
            saveFavorites()
            if refreshCards then refreshCards() end
        end)
        table.insert(cardButtons, card)
    end

    refreshCards = function()
        for _, c in ipairs(cardButtons) do c:Destroy() end
        cardButtons = {}

        local term = string.lower(searchTerm)
        local list = {}

        if currentTab == "Bundles" then
            for name, data in pairs(Animations) do
                if term == "" or string.find(string.lower(name), term, 1, true) then
                    table.insert(list, {name = name, id = data.Idle or 0, kind = "bundle"})
                end
            end
            table.sort(list, function(a,b) return a.name:lower() < b.name:lower() end)
            CounterLbl.Text = "Bundles: " .. #list
        elseif currentTab == "Emotes" then
            for name, id in pairs(Emotes) do
                if term == "" or string.find(string.lower(name), term, 1, true) then
                    table.insert(list, {name = name, id = id, kind = "emote"})
                end
            end
            table.sort(list, function(a,b) return a.name:lower() < b.name:lower() end)
            CounterLbl.Text = "Emotes: " .. #list
        elseif currentTab == "Favorites" then
            for name, _ in pairs(Favorites.Bundles) do
                if Animations[name] and (term == "" or string.find(string.lower(name), term, 1, true)) then
                    table.insert(list, {name = name, id = Animations[name].Idle or 0, kind = "bundle"})
                end
            end
            for name, _ in pairs(Favorites.Emotes) do
                if Emotes[name] and (term == "" or string.find(string.lower(name), term, 1, true)) then
                    table.insert(list, {name = name, id = Emotes[name], kind = "emote"})
                end
            end
            table.sort(list, function(a,b) return a.name:lower() < b.name:lower() end)
            CounterLbl.Text = "Favorites: " .. #list
        end

        local totalPages = math.max(1, math.ceil(#list / ITEMS_PER_PAGE))
        if currentPage > totalPages then currentPage = totalPages end
        if currentPage < 1 then currentPage = 1 end

        local startIndex = (currentPage - 1) * ITEMS_PER_PAGE + 1
        local endIndex = math.min(startIndex + ITEMS_PER_PAGE - 1, #list)

        for i = startIndex, endIndex do
            local item = list[i]
            if item then
                createCard(item.name, item.id, item.kind, i)
            end
        end

        if PageLbl then
            PageLbl.Text = "Стр. " .. currentPage .. " / " .. totalPages
        end
    end

    local function makePageBtn(text, posX, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 100, 0, 38)
        b.Position = UDim2.new(0, posX, 0.5, -19)
        b.BackgroundColor3 = COL.card
        b.Text = text
        b.TextColor3 = COL.text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 13
        b.BorderSizePixel = 0
        b.AutoButtonColor = true
        b.Parent = PaginationRow
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        local s = Instance.new("UIStroke", b)
        s.Color = COL.border
        s.Thickness = 1
        b.MouseButton1Click:Connect(function()
            if isUnloaded() then return end
            pcall(callback)
        end)
        return b
    end

    makePageBtn("◀ Назад", 0, function()
        currentPage = currentPage - 1
        if currentPage < 1 then currentPage = 1 end
        refreshCards()
    end)

    makePageBtn("Вперёд ▶", 110, function()
        currentPage = currentPage + 1
        refreshCards()
    end)

    local function setTab(t)
        currentTab = t
        currentPage = 1
        updateTabs()
        refreshCards()
    end
    TabBundles.MouseButton1Click:Connect(function() setTab("Bundles") end)
    TabEmotes.MouseButton1Click:Connect(function() setTab("Emotes") end)
    TabFav.MouseButton1Click:Connect(function() setTab("Favorites") end)
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchTerm = SearchBox.Text
        currentPage = 1
        refreshCards()
    end)
    GoBtn.MouseButton1Click:Connect(function()
        searchTerm = SearchBox.Text
        currentPage = 1
        refreshCards()
    end)
    updateTabs()
    task.delay(3, refreshCards)

    createSectionLabel(AnimPage, "НАСТРОЙКИ АНИМАЦИИ")
    local animSpeedLbl = Instance.new("TextLabel")
    animSpeedLbl.Size = UDim2.new(1, 0, 0, 18)
    animSpeedLbl.BackgroundTransparency = 1
    animSpeedLbl.Text = "Скорость: " .. AnimState.AnimationSpeed
    animSpeedLbl.TextColor3 = COL.text
    animSpeedLbl.Font = Enum.Font.Gotham
    animSpeedLbl.TextSize = 12
    animSpeedLbl.TextXAlignment = Enum.TextXAlignment.Left
    animSpeedLbl.Parent = AnimPage
    local animSpeedInput = createInput(AnimPage, "Например 1.5")
    animSpeedInput.Text = tostring(AnimState.AnimationSpeed)
    animSpeedInput.FocusLost:Connect(function()
        local n = tonumber(animSpeedInput.Text)
        if n and n > 0 then
            AnimState.AnimationSpeed = n
            animSpeedLbl.Text = "Скорость: " .. n
            ApplyAnimationSpeed()
        else
            animSpeedInput.Text = tostring(AnimState.AnimationSpeed)
        end
    end)
    createActionBtn(AnimPage, "🔄 Сбросить анимации", COL.accent, function()
        StopEmotes()
        local char = LocalPlayer.Character
        if not char then return end
        local animate = char:FindFirstChild("Animate")
        if not animate then return end
        animate.idle.Animation1.AnimationId = OriginalAnimations[1] or ""
        animate.idle.Animation2.AnimationId = OriginalAnimations[2] or ""
        if animate:FindFirstChild("pose") then
            local p = animate.pose:FindFirstChildOfClass("Animation")
            if p then p.AnimationId = OriginalAnimations[3] or "" end
        end
        animate.walk:FindFirstChildOfClass("Animation").AnimationId = OriginalAnimations[4] or ""
        animate.run:FindFirstChildOfClass("Animation").AnimationId = OriginalAnimations[5] or ""
        animate.jump:FindFirstChildOfClass("Animation").AnimationId = OriginalAnimations[6] or ""
        animate.climb:FindFirstChildOfClass("Animation").AnimationId = OriginalAnimations[7] or ""
        animate.fall:FindFirstChildOfClass("Animation").AnimationId = OriginalAnimations[8] or ""
        if animate:FindFirstChild("swim") then
            animate.swim:FindFirstChildOfClass("Animation").AnimationId = OriginalAnimations[9] or ""
            animate.swimidle:FindFirstChildOfClass("Animation").AnimationId = OriginalAnimations[10] or ""
        end
        RefreshAnims()
        task.wait(0.1)
        if AnimState.AnimationSpeed ~= 1 then pcall(ApplyAnimationSpeed) end
        AnimState.SelectedAnimation = ""
    end)

    -- ФИШКИ
    createPageHeader(FeaturesPage, "Фишки", "NoClip, скорость, прыжок")
    createSectionLabel(FeaturesPage, "ПЕРЕМЕЩЕНИЕ")
    createToggle(FeaturesPage, "NoClip", "Проход сквозь стены", Config.NoClip, function(v)
        Config.NoClip = v; updateNoclip(); saveConfig()
    end)
    createToggle(FeaturesPage, "Speed Hack", "Ускорение", Config.SpeedHack, function(v)
        Config.SpeedHack = v; updateSpeed(); saveConfig()
    end)
    createToggle(FeaturesPage, "High Jump", "Высокий прыжок", Config.HighJump, function(v)
        Config.HighJump = v; updateJump(); saveConfig()
    end)
    createSectionLabel(FeaturesPage, "БОЕВЫЕ ФИШКИ")
    createToggle(FeaturesPage, "Крутой чел", "Прыжок спиной + стрельба", Config.CoolGuy, function(v)
        Config.CoolGuy = v; saveConfig()
        if v and LocalPlayer.Character then coolGuySetupCharacter(LocalPlayer.Character) end
    end)

    -- НАСТРОЙКИ
    createPageHeader(SettingsPage, "Настройки", "Параметры скрипта")
    createSectionLabel(SettingsPage, "ПРЕДСКАЗАНИЕ")
    local predLbl = Instance.new("TextLabel")
    predLbl.Size = UDim2.new(1, 0, 0, 18)
    predLbl.BackgroundTransparency = 1
    predLbl.Text = "Множитель: " .. Config.PredictionMultiplier
    predLbl.TextColor3 = COL.text
    predLbl.Font = Enum.Font.Gotham
    predLbl.TextSize = 12
    predLbl.TextXAlignment = Enum.TextXAlignment.Left
    predLbl.Parent = SettingsPage
    local predInput = createInput(SettingsPage, "Например 2.5")
    predInput.Text = tostring(Config.PredictionMultiplier)
    predInput.FocusLost:Connect(function()
        local n = tonumber(predInput.Text)
        if n then
            Config.PredictionMultiplier = n
            predLbl.Text = "Множитель: " .. n
            saveConfig()
        end
    end)
    createSectionLabel(SettingsPage, "СКОРОСТЬ И ПРЫЖОК")
    local speedLbl = Instance.new("TextLabel")
    speedLbl.Size = UDim2.new(1, 0, 0, 18)
    speedLbl.BackgroundTransparency = 1
    speedLbl.Text = "Speed: " .. Config.SpeedValue
    speedLbl.TextColor3 = COL.text
    speedLbl.Font = Enum.Font.Gotham
    speedLbl.TextSize = 12
    speedLbl.TextXAlignment = Enum.TextXAlignment.Left
    speedLbl.Parent = SettingsPage
    local speedInput = createInput(SettingsPage, "Например 32")
    speedInput.Text = tostring(Config.SpeedValue)
    speedInput.FocusLost:Connect(function()
        local n = tonumber(speedInput.Text)
        if n then
            Config.SpeedValue = n
            speedLbl.Text = "Speed: " .. n
            saveConfig()
        end
    end)
    local jumpLbl = Instance.new("TextLabel")
    jumpLbl.Size = UDim2.new(1, 0, 0, 18)
    jumpLbl.BackgroundTransparency = 1
    jumpLbl.Text = "Jump: " .. Config.JumpValue
    jumpLbl.TextColor3 = COL.text
    jumpLbl.Font = Enum.Font.Gotham
    jumpLbl.TextSize = 12
    jumpLbl.TextXAlignment = Enum.TextXAlignment.Left
    jumpLbl.Parent = SettingsPage
    local jumpInput = createInput(SettingsPage, "Например 120")
    jumpInput.Text = tostring(Config.JumpValue)
    jumpInput.FocusLost:Connect(function()
        local n = tonumber(jumpInput.Text)
        if n then
            Config.JumpValue = n
            jumpLbl.Text = "Jump: " .. n
            saveConfig()
        end
    end)
    createSectionLabel(SettingsPage, "СБРОС")
    createActionBtn(SettingsPage, "🗑 Сбросить настройки", COL.red, function()
        deleteConfig()
        for k, v in pairs(Config) do
            if type(v) == "boolean" then Config[k] = false end
        end
        Config.ESP = true
        Config.AutoAttackAfterFarm = true
        Config.PredictionMultiplier = 2.5
        Config.SpeedValue = 32
        Config.JumpValue = 120
        saveConfig()
    end)

    -- КНОПКИ ОКНА
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -36, 0, 8)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = COL.text
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Main

    local Circle = Instance.new("ImageButton")
    Circle.Name = "CircleBtn"
    Circle.AnchorPoint = Vector2.new(0, 0.5)
    Circle.Size = UDim2.new(0, 56, 0, 56)
    Circle.Position = UDim2.new(0, 10, 0.5, 0)
    Circle.BackgroundColor3 = COL.accent
    Circle.Image = "rbxthumb://type=Asset&id=" .. AVATAR_ID .. "&w=150&h=150"
    Circle.ScaleType = Enum.ScaleType.Crop
    Circle.Visible = false
    Circle.Active = true
    Circle.Draggable = true
    Circle.ZIndex = 999
    Circle.Parent = ScreenGui
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    local circleStroke = Instance.new("UIStroke", Circle)
    circleStroke.Color = Color3.fromRGB(255, 255, 255)
    circleStroke.Thickness = 2
    circleStroke.Transparency = 0.4
    CircleBtn = Circle

    Circle.MouseButton1Click:Connect(function()
        restoreMenu()
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        minimizeMenu()
    end)
end

-- Строим GUI только для MM2
if IS_MM2 then
    buildMM2Gui()
else
    local otherGui = Instance.new("ScreenGui")
    otherGui.Name = "ses_get3_other"
    otherGui.ResetOnSpawn = false
    otherGui.IgnoreGuiInset = true
    pcall(function()
        otherGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if not otherGui.Parent then
        pcall(function() otherGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, FW, 0, FH)
    Frame.Position = UDim2.new(0.5, -FW/2, 0.5, -FH/2)
    Frame.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
    Frame.BackgroundTransparency = 0.15
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = otherGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", Frame)
    stroke.Color = Color3.fromRGB(40, 40, 44)
    stroke.Thickness = 1
    MainFrame = Frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "ses_get3 HUB👑 | Другие игры"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = Frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -50)
    scroll.Position = UDim2.new(0, 10, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = Frame
    local list = Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0, 8)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop = UDim.new(0, 8)

    local function makeToggle(titleText, desc, initial, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -20, 0, 54)
        row.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        row.BorderSizePixel = 0
        row.Parent = scroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -80, 0, 18)
        t.Position = UDim2.new(0, 12, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = titleText
        t.TextColor3 = Color3.fromRGB(235, 235, 240)
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = row
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -80, 0, 16)
        d.Position = UDim2.new(0, 12, 0, 28)
        d.BackgroundTransparency = 1
        d.Text = desc or ""
        d.TextColor3 = Color3.fromRGB(138, 138, 143)
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = row
        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 46, 0, 26)
        sw.Position = UDim2.new(1, -58, 0.5, -13)
        sw.BackgroundColor3 = initial and Color3.fromRGB(120, 90, 255) or Color3.fromRGB(50, 50, 54)
        sw.BorderSizePixel = 0
        sw.Parent = row
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.Position = initial and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = sw
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local state = initial
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = row
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(sw, TweenInfo.new(0.15), {
                BackgroundColor3 = state and Color3.fromRGB(120, 90, 255) or Color3.fromRGB(50, 50, 54)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            }):Play()
            if callback then pcall(callback, state) end
        end)
    end

    local function makeInput(placeholder, initial, callback)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -20, 0, 42)
        box.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        box.BorderSizePixel = 0
        box.PlaceholderText = placeholder
        box.Text = tostring(initial or "")
        box.TextColor3 = Color3.fromRGB(235, 235, 240)
        box.PlaceholderColor3 = Color3.fromRGB(138, 138, 143)
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.ClearTextOnFocus = false
        box.Parent = scroll
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
        box.FocusLost:Connect(function()
            if callback then pcall(callback, box.Text) end
        end)
    end

    makeToggle("ESP", "Подсветка игроков", Config.ESP, function(v)
        Config.ESP = v; saveConfig()
    end)
    makeToggle("Anti-Fling", "Защита от флинга", Config.AntiFling, function(v)
        Config.AntiFling = v; saveConfig()
    end)
    makeToggle("Invisible", "Невидимость (клавиша G)", Config.Invisible, function(v)
        Config.Invisible = v; saveConfig(); updateInvisible()
    end)
    makeToggle("Speed Hack", "Ускорение", Config.SpeedHack, function(v)
        Config.SpeedHack = v; updateSpeed(); saveConfig()
    end)
    makeInput("Speed Value", Config.SpeedValue, function(t)
        local n = tonumber(t)
        if n then Config.SpeedValue = n; saveConfig(); updateSpeed() end
    end)
    makeToggle("High Jump", "Высокий прыжок", Config.HighJump, function(v)
        Config.HighJump = v; updateJump(); saveConfig()
    end)
    makeInput("Jump Value", Config.JumpValue, function(t)
        local n = tonumber(t)
        if n then Config.JumpValue = n; saveConfig(); updateJump() end
    end)
    makeToggle("NoClip", "Проход сквозь стены", Config.NoClip, function(v)
        Config.NoClip = v; updateNoclip(); saveConfig()
    end)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 255)
    toggleBtn.Text = "S"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 20
    toggleBtn.Parent = otherGui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    toggleBtn.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
    end)
end

-- ============ СЛУЖЕБНЫЕ ЦИКЛЫ ============
updateSpeed()
updateJump()
updateNoclip()
setupInvisibleCharacter()

task.spawn(function()
    while not isUnloaded() and LocalPlayer.Parent do
        task.wait(0.25)
        if AnimState.AnimationSpeed ~= 1 then pcall(ApplyAnimationSpeed) end
    end
end)

-- ============ МАСКОТ ============
if IS_MM2 and MainFrame then
    local MASCOT_URL = "https://raw.githubusercontent.com/partilaharli-boop/Hj/36e1de7e82d26901bdc890a5582b601d343aa76e/lv_0_20261005184448.png"
    local MASCOT_PRESSED_URL = "https://raw.githubusercontent.com/partilaharli-boop/Skak/refs/heads/main/phakka.png"
    local MASCOT_FILE = "rockhub_mascot_v3.png"
    local MASCOT_PRESSED_FILE = "rockhub_mascot_pressed_v2.png"

    local mascot = Instance.new("ImageButton")
    mascot.Name = "Mascot"
    mascot.AnchorPoint = Vector2.new(0.5, 0.5)
    mascot.Size = UDim2.fromOffset(80, 80)
    mascot.BackgroundTransparency = 1
    mascot.ScaleType = Enum.ScaleType.Fit
    mascot.ZIndex = 1000
    mascot.Parent = ScreenGui

    local baseX = -35
    local baseY = 55
    mascot.Position = UDim2.new(1, baseX, 0, baseY)

    local function loadImage(url, file)
        local getAsset = getcustomasset or getsynasset
        if not (writefile and getAsset) then return nil end
        if not (isfile and isfile(file)) then
            local ok, data = pcall(game.HttpGet, game, url)
            if not ok or type(data) ~= "string" or #data == 0 then return nil end
            pcall(writefile, file, data)
        end
        local ok, asset = pcall(getAsset, file)
        return ok and asset or nil
    end

    local normalImage = loadImage(MASCOT_URL, MASCOT_FILE)
    local pressedImage = loadImage(MASCOT_PRESSED_URL, MASCOT_PRESSED_FILE)
    mascot.Image = normalImage or "rbxassetid://72818680149869"

    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not mascot:GetAttribute("Falling") then
            mascot.Visible = MainFrame.Visible
        end
    end)
    mascot.Visible = MainFrame.Visible

    local mascotStart = os.clock()
    RunService.RenderStepped:Connect(function()
        if mascot:GetAttribute("Falling") then return end
        if not mascot.Visible or not MainFrame.Visible then return end
        local t = os.clock() - mascotStart
        local y = math.sin(t * 2) * 4
        mascot.Position = UDim2.new(1, baseX, 0, baseY + y)
        mascot.Rotation = math.sin(t * 1.5) * 3
    end)

    local clickCount = 0
    local clickTimer = nil
    local busy = false
    local falling = false
    local walkConn = nil

    local function doClickAction()
        if pressedImage then
            mascot.Image = pressedImage
        else
            mascot.Size = UDim2.fromOffset(60, 60)
            task.delay(0.15, function()
                mascot.Size = UDim2.fromOffset(80, 80)
            end)
        end
        task.wait(0.25)
        if pressedImage then
            mascot.Image = normalImage or mascot.Image
        end
        minimizeMenu()
    end

    local function triggerFall()
        falling = true
        mascot:SetAttribute("Falling", true)
        mascot.Visible = true
        restoreMenu()

        local fallTarget = UDim2.new(1, baseX, 0, baseY + 400)
        local fallTween = TweenService:Create(
            mascot,
            TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = fallTarget, Rotation = 720 }
        )
        fallTween:Play()
        task.wait(0.6)

        local bounceTarget = UDim2.new(1, baseX, 0, baseY + 250)
        local bounceTween = TweenService:Create(
            mascot,
            TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
            { Position = bounceTarget, Rotation = 0 }
        )
        bounceTween:Play()
        task.wait(0.5)

        local walkStart = os.clock()
        local walkAmp = 180
        walkConn = RunService.Heartbeat:Connect(function()
            if not falling then return end
            local t = os.clock() - walkStart
            local walkX = math.sin(t * 2) * walkAmp
            mascot.Position = UDim2.new(1, baseX + walkX, 0, baseY + 250)
            mascot.Rotation = math.sin(t * 8) * 10
        end)

        task.delay(5, function()
            if walkConn then walkConn:Disconnect(); walkConn = nil end
            falling = false
            mascot:SetAttribute("Falling", false)

            local returnTween = TweenService:Create(
                mascot,
                TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Position = UDim2.new(1, baseX, 0, baseY), Rotation = 0 }
            )
            returnTween:Play()
            task.wait(0.8)
            mascot.Visible = MainFrame.Visible
        end)
    end

    mascot.MouseButton1Click:Connect(function()
        if busy or falling then return end
        busy = true

        clickCount += 1
        print("[Mascot] Клик #" .. clickCount)

        if clickCount >= 7 then
            clickCount = 0
            busy = false
            if clickTimer then
                task.cancel(clickTimer)
                clickTimer = nil
            end
            task.spawn(triggerFall)
            return
        end

        if clickTimer then
            task.cancel(clickTimer)
        end

        clickTimer = task.delay(0.03, function()
            clickTimer = nil
            if falling then
                busy = false
                return
            end
            task.spawn(function()
                doClickAction()
                clickCount = 0
                busy = false
            end)
        end)
    end)
end

print("[ses_get3] v0.74 Pulse Hub Edition + Invisible загружен!")
