--[[
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ██████╗  ██████╗ ██████╗     ██╗  ██╗██╗   ██╗██████╗    ║
║  ██╔════╝ ██╔═══██╗██╔══██╗    ██║  ██║██║   ██║██╔══██╗   ║
║  ██║  ███╗██║   ██║██║  ██║    ███████║██║   ██║██████╔╝   ║
║  ██║   ██║██║   ██║██║  ██║    ██╔══██║██║   ██║██╔══██╗   ║
║  ╚██████╔╝╚██████╔╝██████╔╝    ██║  ██║╚██████╔╝██████╔╝   ║
║   ╚═════╝  ╚═════╝ ╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝   ║
║                                                              ║
║   TRACK & FIELD: INFINITE  ─  GOD HUB  v3.0                 ║
║   Tabs: Race | Speed | AutoWin | AntiCheat | ESP | Farm | ⚙ ║
║   Keybind: RightShift = Toggle UI  |  Ins = Panic Close      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ══════════════════════════════════════════════
-- [0] SERVICES & CORE REFS
-- ══════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local StarterGui       = game:GetService("StarterGui")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")
local TextService      = game:GetService("TextService")

local LP    = Players.LocalPlayer
local Cam   = Workspace.CurrentCamera

local Char, Hum, Root
local function RefreshChar(c)
    Char = c or LP.Character
    Hum  = Char and Char:FindFirstChildOfClass("Humanoid")
    Root = Char and Char:FindFirstChild("HumanoidRootPart")
end
RefreshChar(LP.Character)
LP.CharacterAdded:Connect(function(c)
    task.wait(0.1)
    RefreshChar(c)
end)

-- ══════════════════════════════════════════════
-- [1] SETTINGS TABLE  (single source of truth)
-- ══════════════════════════════════════════════
local S = {
    -- Race / Movement
    SuperSpeed        = false,
    SpeedValue        = 80,
    JumpBoost         = false,
    JumpValue         = 80,
    LowGravity        = false,
    GravityValue      = 40,
    Noclip            = false,
    SpeedRamp         = false,   -- gradually ramps speed to avoid detection
    RampTarget        = 120,
    RampRate          = 2,       -- studs/sec added per second

    -- Macro / Sprint
    MacroOn           = false,
    MacroMode         = "Normal",  -- Normal | SemiLegit | Rage
    MacroKey          = Enum.KeyCode.E,
    MacroPulseBoost   = true,      -- micro WalkSpeed pulse each tap

    -- AutoWin
    AutoWin           = false,
    AutoWinDelay      = 0.5,       -- seconds before teleport to finish
    FinishTeleport    = false,
    AutoRestart       = false,

    -- Stamina / Coins
    InfStamina        = false,
    InfCoins          = false,
    CoinValue         = 999999,
    InfXP             = false,

    -- Hurdles / Objects
    RemoveHurdles     = false,
    MakeTrackFlat     = false,

    -- Bypass / Safety
    AntiKick          = false,
    SpeedLimiter      = false,     -- caps speed to "safe" value during scans
    SafeSpeed         = 60,
    RandomizeSpeed    = false,     -- jitters speed slightly to look human
    FakeLatency       = false,     -- adds slight heartbeat delay to mask

    -- Free Stuff
    FreeVIP           = false,
    FreeCosmetics     = false,

    -- ESP
    ESPOn             = false,
    ESPNames          = true,
    ESPDist           = true,
    ESPBoxes          = false,
    ESPChams          = false,
    ESPTracers        = false,
    ESPMaxDist        = 500,

    -- Anti-Cheat Detector
    ACDetectorOn      = false,
    ACAutoScan        = false,
    ACAlertOnly       = false,     -- only notify, don't print
    ACFlagHistory     = {},

    -- Farm
    AutoFarm          = false,
    FarmMode          = "Coins",   -- Coins | XP | Both
    FarmLoopDelay     = 0.5,

    -- Settings
    UIKeybind         = Enum.KeyCode.RightShift,
    PanicKeybind      = Enum.KeyCode.Insert,
    Theme             = "Red",     -- Red | Blue | Green | Purple
    Watermark         = true,
    Notifications     = true,
}

-- ══════════════════════════════════════════════
-- [2] THEME ENGINE
-- ══════════════════════════════════════════════
local Themes = {
    Red    = { Accent=Color3.fromRGB(220,30,55),  Dim=Color3.fromRGB(140,15,30),  Glow=Color3.fromRGB(255,80,100)  },
    Blue   = { Accent=Color3.fromRGB(30,100,220), Dim=Color3.fromRGB(15,60,150),  Glow=Color3.fromRGB(80,150,255)  },
    Green  = { Accent=Color3.fromRGB(30,180,80),  Dim=Color3.fromRGB(15,110,45),  Glow=Color3.fromRGB(80,255,130)  },
    Purple = { Accent=Color3.fromRGB(140,30,220), Dim=Color3.fromRGB(90,15,150),  Glow=Color3.fromRGB(190,80,255)  },
}
local function T() return Themes[S.Theme] or Themes.Red end

-- ══════════════════════════════════════════════
-- [3] UTILITY
-- ══════════════════════════════════════════════
local function Notify(title, body, dur)
    if not S.Notifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title="⚡ "..title, Text=body, Duration=dur or 4})
    end)
end

local function GetHum()   return Char and Char:FindFirstChildOfClass("Humanoid") end
local function GetRoot()  return Char and Char:FindFirstChild("HumanoidRootPart") end

local function Tween(obj, goal, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), goal):Play()
end

local function MakeCorner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = p; return c
end

local function MakeStroke(p, col, thick)
    local s = Instance.new("UIStroke"); s.Color = col or T().Accent; s.Thickness = thick or 1.5; s.Parent = p; return s
end

local function MakePad(p, l, r, t, b)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, l or 6)
    pad.PaddingRight  = UDim.new(0, r or 6)
    pad.PaddingTop    = UDim.new(0, t or 4)
    pad.PaddingBottom = UDim.new(0, b or 4)
    pad.Parent = p; return pad
end

local function MakeList(p, pad, dir)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, pad or 5)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p; return l
end

-- Search all stat folders for a value matching keywords
local function FindStat(keywords)
    local folders = {
        LP:FindFirstChild("Stats"),
        LP:FindFirstChild("leaderstats"),
        LP:FindFirstChild("Data"),
        LP:FindFirstChild("PlayerData"),
        LP:FindFirstChild("Values"),
        Char and Char:FindFirstChild("Stats"),
        Char and Char:FindFirstChild("Values"),
    }
    for _, folder in ipairs(folders) do
        if folder then
            for _, v in ipairs(folder:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local n = v.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if n:find(kw) then return v end
                    end
                end
            end
        end
    end
end

-- Fire any remote whose name matches keywords
local function FireRemote(keywords, ...)
    local args = {...}
    for _, parent in ipairs({ReplicatedStorage, Workspace}) do
        for _, obj in ipairs(parent:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if n:find(kw) then
                        pcall(function()
                            if obj:IsA("RemoteEvent") then
                                obj:FireServer(table.unpack(args))
                            else
                                obj:InvokeServer(table.unpack(args))
                            end
                        end)
                        print("[GodHub] Fired remote: "..obj.Name)
                    end
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════
-- [4] FEATURE IMPLEMENTATIONS
-- ══════════════════════════════════════════════

-- ── 4a. Speed Ramp state ──────────────────────
local _currentSpeed = 16
local _rampConn

local function StartRamp()
    if _rampConn then _rampConn:Disconnect() end
    _currentSpeed = 16
    _rampConn = RunService.Heartbeat:Connect(function(dt)
        if not S.SpeedRamp then return end
        local h = GetHum()
        if not h then return end
        _currentSpeed = math.min(_currentSpeed + S.RampRate * dt, S.RampTarget)
        h.WalkSpeed = _currentSpeed
    end)
end

-- ── 4b. Main heartbeat ────────────────────────
local _randomJitter = 0
RunService.Heartbeat:Connect(function(dt)
    local h = GetHum()
    if not h then return end

    -- Speed
    if S.SuperSpeed and not S.SpeedRamp then
        local spd = S.SpeedValue
        if S.RandomizeSpeed then
            _randomJitter = _randomJitter + dt * 5
            spd = spd + math.sin(_randomJitter) * 3
        end
        if S.SpeedLimiter then spd = math.min(spd, S.SafeSpeed) end
        h.WalkSpeed = spd
    end

    -- Jump
    if S.JumpBoost then
        h.JumpPower = S.JumpValue
    end

    -- Gravity
    if S.LowGravity then
        Workspace.Gravity = S.GravityValue
    end

    -- Fake latency (yield micros)
    if S.FakeLatency then
        task.wait(0.01 + math.random() * 0.01)
    end
end)

-- ── 4c. Noclip ────────────────────────────────
RunService.Stepped:Connect(function()
    if not S.Noclip or not Char then return end
    for _, p in ipairs(Char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ── 4d. Macro ─────────────────────────────────
local MacroIntervals = { Normal=0.088, SemiLegit=0.055, Rage=0.018 }
local _macroConn, _macroTick = nil, 0

local function StartMacro()
    if _macroConn then _macroConn:Disconnect() end
    _macroTick = 0
    _macroConn = RunService.Heartbeat:Connect(function(dt)
        if not S.MacroOn then return end
        _macroTick = _macroTick + dt
        local iv = MacroIntervals[S.MacroMode] or 0.088
        if _macroTick < iv then return end
        _macroTick = 0
        -- VirtualInputManager tap (executor)
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true,  S.MacroKey, false, game)
            vim:SendKeyEvent(false, S.MacroKey, false, game)
        end)
        -- Pulse boost
        if S.MacroPulseBoost then
            local h = GetHum()
            if h then
                local base = S.SuperSpeed and S.SpeedValue or h.WalkSpeed
                h.WalkSpeed = base + 8
                task.defer(function() if h then h.WalkSpeed = base end end)
            end
        end
    end)
end
StartMacro()

local function StopMacro()
    if _macroConn then _macroConn:Disconnect(); _macroConn = nil end
end

-- ── 4e. Infinite Stamina ──────────────────────
local _staminaConn
local function StartStamina()
    if _staminaConn then _staminaConn:Disconnect() end
    _staminaConn = RunService.Heartbeat:Connect(function()
        if not S.InfStamina then return end
        local v = FindStat({"stamina","energy","sprint","endurance","fuel"})
        if v then v.Value = 99999 end
    end)
end
StartStamina()

-- ── 4f. Infinite Coins / XP ──────────────────
local _coinsConn
local function StartCoins()
    if _coinsConn then _coinsConn:Disconnect() end
    _coinsConn = RunService.Heartbeat:Connect(function()
        if S.InfCoins then
            local v = FindStat({"coin","gold","cash","currency","token","money","bux"})
            if v then v.Value = S.CoinValue end
        end
        if S.InfXP then
            local v = FindStat({"xp","exp","experience","level","points"})
            if v then v.Value = 999999 end
        end
    end)
end
StartCoins()

-- ── 4g. Remove Hurdles ────────────────────────
local _hurdleWatch
local function ApplyHurdles()
    local function strip(obj)
        if not obj:IsA("BasePart") then return end
        local n = obj.Name:lower()
        if n:find("hurdle") or n:find("barrier") or n:find("obstacle")
        or n:find("gate") or n:find("fence") or n:find("wall") then
            obj.CanCollide = false
            obj.Transparency = 0.85
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do strip(obj) end
    if not _hurdleWatch then
        _hurdleWatch = Workspace.DescendantAdded:Connect(function(obj)
            if S.RemoveHurdles then strip(obj) end
        end)
    end
    Notify("Race","Hurdles removed ✓",2)
end

-- ── 4h. Flatten track (remove bumps) ─────────
local function FlattenTrack()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("WedgePart") or obj:IsA("CornerWedgePart") then
            local n = obj.Name:lower()
            if n:find("track") or n:find("lane") or n:find("floor") or n:find("ground") then
                obj.CFrame = CFrame.new(obj.CFrame.X, math.floor(obj.CFrame.Y), obj.CFrame.Z)
            end
        end
    end
    Notify("Race","Track flattened ✓",2)
end

-- ── 4i. AutoWin / Finish Teleport ─────────────
local function FindFinishLine()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find("finish") or n:find("goal") or n:find("end") or n:find("win") then
            if obj:IsA("BasePart") then return obj end
        end
    end
end

local _autoWinConn
local function StartAutoWin()
    if _autoWinConn then _autoWinConn:Disconnect() end
    _autoWinConn = RunService.Heartbeat:Connect(function()
        if not S.AutoWin then return end
        local finish = FindFinishLine()
        local r = GetRoot()
        if finish and r then
            task.delay(S.AutoWinDelay, function()
                if S.AutoWin and r then
                    r.CFrame = finish.CFrame + Vector3.new(0, 3, 0)
                    Notify("AutoWin","Teleported to finish! 🏁",3)
                end
            end)
            S.AutoWin = false  -- one-shot per race
        end
    end)
end

-- ── 4j. Auto-Farm ─────────────────────────────
local _farmConn
local function StartFarm()
    if _farmConn then _farmConn:Disconnect() end
    _farmConn = task.spawn(function()
        while S.AutoFarm do
            -- Find and touch coin/xp pickups
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if S.FarmMode == "Coins" or S.FarmMode == "Both" then
                    local n = obj.Name:lower()
                    if (n:find("coin") or n:find("pickup") or n:find("collect")) and obj:IsA("BasePart") then
                        local r = GetRoot()
                        if r then
                            local old = r.CFrame
                            r.CFrame = obj.CFrame
                            task.wait(0.05)
                            r.CFrame = old
                        end
                    end
                end
            end
            -- Also fire farm remotes
            FireRemote({"farm","collect","pickup","claim","daily"})
            task.wait(S.FarmLoopDelay)
        end
    end)
end

-- ── 4k. Free VIP / Cosmetics ──────────────────
local function ApplyFreeVIP()
    FireRemote({"vip","gamepass","premium","reward","badge"})
    local v = FindStat({"vip"})
    if v and v:IsA("BoolValue") then v.Value = true end
    Notify("Perks","Free VIP sent ✓",3)
end

local function ApplyFreeCosmetics()
    FireRemote({"cosmetic","outfit","skin","equip","unlock"})
    Notify("Perks","Cosmetics unlock sent ✓",3)
end

-- ── 4l. Anti-Kick Bypass ──────────────────────
local _bypassApplied = false
local function ApplyAntiKick()
    if _bypassApplied then return end
    _bypassApplied = true
    -- Swallow any RemoteEvent named with kick/ban/detect
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local n = obj.Name:lower()
            if n:find("kick") or n:find("ban") or n:find("anticheat") or n:find("detect") then
                pcall(function() obj.OnClientEvent:Connect(function() end) end)
                print("[Bypass] Swallowed: "..obj.Name)
            end
        end
    end
    -- Override metatable Kick if possible
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = tostring(select(1,...) or ""):lower()
            if self == LP and method == "kick" then
                warn("[Bypass] Kick blocked!")
                return
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
    Notify("Bypass","Anti-Kick active ✓",3)
end

-- ── 4m. Teleport helpers ──────────────────────
local function TeleportTo(playerName)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Name:lower():find(playerName:lower()) then
            local c = pl.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            local mine = GetRoot()
            if r and mine then
                mine.CFrame = r.CFrame + Vector3.new(3,0,0)
                Notify("TP","Teleported to "..pl.Name,2)
                return true
            end
        end
    end
    Notify("TP","Player not found: "..playerName,2)
    return false
end

local function ServerHop()
    local TS = game:GetService("TeleportService")
    local found = false
    pcall(function()
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=25"
        local data = HttpService:JSONDecode(game:HttpGetAsync(url))
        if data and data.data then
            for _, sv in ipairs(data.data) do
                if sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                    TS:TeleportToPlaceInstance(game.PlaceId, sv.id, LP)
                    found = true
                    break
                end
            end
        end
    end)
    if not found then TS:Teleport(game.PlaceId, LP) end
    Notify("Server","Hopping server... 🚀",3)
end

-- ══════════════════════════════════════════════
-- [5] ESP SYSTEM  (full BillboardGui + tracer)
-- ══════════════════════════════════════════════
local ESPFolder = Instance.new("Folder"); ESPFolder.Name="GodHubESP"; ESPFolder.Parent=CoreGui

local function CreateESP(pl)
    if pl == LP then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_"..pl.Name
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0,140,0,50)
    bb.StudsOffset = Vector3.new(0,3.5,0)
    bb.Parent = ESPFolder

    local nameLbl = Instance.new("TextLabel",bb)
    nameLbl.Name = "NameL"
    nameLbl.Size = UDim2.new(1,0,0.55,0)
    nameLbl.BackgroundTransparency=1
    nameLbl.TextStrokeTransparency=0
    nameLbl.TextStrokeColor3=Color3.new(0,0,0)
    nameLbl.TextScaled=true
    nameLbl.Font=Enum.Font.GothamBold
    nameLbl.Text=pl.Name

    local distLbl = Instance.new("TextLabel",bb)
    distLbl.Name = "DistL"
    distLbl.Size = UDim2.new(1,0,0.45,0)
    distLbl.Position = UDim2.new(0,0,0.55,0)
    distLbl.BackgroundTransparency=1
    distLbl.TextStrokeTransparency=0
    distLbl.TextStrokeColor3=Color3.new(0,0,0)
    distLbl.TextScaled=true
    distLbl.Font=Enum.Font.Gotham
    distLbl.TextColor3=Color3.fromRGB(255,220,80)

    -- Attach / re-attach on respawn
    local function Attach(char)
        local r = char and char:FindFirstChild("HumanoidRootPart")
        if r then bb.Adornee=r end
    end
    if pl.Character then Attach(pl.Character) end
    pl.CharacterAdded:Connect(Attach)

    -- Box highlight
    local hl = Instance.new("SelectionBox",ESPFolder)
    hl.Name = "HL_"..pl.Name
    hl.LineThickness = 0.05
    hl.Color3 = T().Accent
    hl.SurfaceTransparency = 0.8
    hl.SurfaceColor3 = T().Accent

    -- Render loop
    RunService.RenderStepped:Connect(function()
        bb.Enabled  = S.ESPOn
        hl.Enabled  = S.ESPOn and S.ESPBoxes
        nameLbl.Visible = S.ESPNames
        distLbl.Visible = S.ESPDist

        local myR = GetRoot()
        local theirR = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
        if myR and theirR then
            local dist = (myR.Position - theirR.Position).Magnitude
            if dist > S.ESPMaxDist then bb.Enabled=false; hl.Enabled=false; return end
            distLbl.Text = string.format("[%.0fm]", dist)
            -- color by distance
            if dist < 25 then
                nameLbl.TextColor3 = Color3.fromRGB(255,50,50)
            elseif dist < 80 then
                nameLbl.TextColor3 = Color3.fromRGB(255,165,0)
            else
                nameLbl.TextColor3 = Color3.fromRGB(80,200,255)
            end
            -- Chams
            if S.ESPChams and pl.Character then
                for _, p in ipairs(pl.Character:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Material = Enum.Material.Neon
                        p.Color = T().Accent
                    end
                end
            end
            hl.Adornee = theirR.Parent
        end
    end)
end

local function InitESP()
    ESPFolder:ClearAllChildren()
    for _, pl in ipairs(Players:GetPlayers()) do CreateESP(pl) end
    Players.PlayerAdded:Connect(CreateESP)
    Players.PlayerRemoving:Connect(function(pl)
        for _, c in ipairs(ESPFolder:GetChildren()) do
            if c.Name:find(pl.Name) then c:Destroy() end
        end
    end)
end

-- ══════════════════════════════════════════════
-- [6] ANTI-CHEAT DETECTOR  (enhanced)
-- ══════════════════════════════════════════════
local FlaggedPlayers = {}
local PrevPositions  = {}

local CHECKS = {
    { name="Speed",      fn=function(hum,root,prev)
        return hum and hum.WalkSpeed > 85, "Speed="..math.floor(hum and hum.WalkSpeed or 0) end},
    { name="Jump",       fn=function(hum,root,prev)
        return hum and hum.JumpPower > 85, "Jump="..math.floor(hum and hum.JumpPower or 0) end},
    { name="Velocity",   fn=function(hum,root,prev)
        local v = root and root.AssemblyLinearVelocity.Magnitude or 0
        return v > 350, "Vel="..math.floor(v) end},
    { name="Flying",     fn=function(hum,root,prev)
        local y = root and root.Position.Y or 0
        return y > 120, "FlyY="..math.floor(y) end},
    { name="Noclip",     fn=function(hum,root,prev)
        if not root then return false,"" end
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = {root.Parent}
        local hit = Workspace:Raycast(root.Position, Vector3.new(0,-4,0), rp)
        return (not hit and root.Position.Y < 3), "Noclip" end},
    { name="Teleport",   fn=function(hum,root,prev)
        if not root or not prev then return false,"" end
        local dist = (root.Position - prev).Magnitude
        return dist > 200, "TpDist="..math.floor(dist) end},
    { name="LowGravity", fn=function()
        return Workspace.Gravity < 80 and Workspace.Gravity > 0, "Grav="..Workspace.Gravity end},
}

local function ScanAll()
    FlaggedPlayers = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LP then continue end
        local char = pl.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local prev = PrevPositions[pl.Name]
        if root then PrevPositions[pl.Name] = root.Position end

        local allFlags = {}
        for _, check in ipairs(CHECKS) do
            local flagged, detail = check.fn(hum, root, prev)
            if flagged then table.insert(allFlags, detail) end
        end

        if #allFlags > 0 then
            local entry = {
                Name   = pl.Name,
                Level  = (pl:FindFirstChild("leaderstats") and
                          pl.leaderstats:FindFirstChild("Level") and
                          pl.leaderstats.Level.Value) or "?",
                Flags  = table.concat(allFlags, " | "),
                Time   = os.clock(),
            }
            table.insert(FlaggedPlayers, entry)
            table.insert(S.ACFlagHistory, entry)
            if #S.ACFlagHistory > 50 then table.remove(S.ACFlagHistory, 1) end
            if not S.ACAlertOnly then
                warn(string.format("[GodHub AC] ⚠ %s (Lv%s): %s", pl.Name, tostring(entry.Level), entry.Flags))
            end
        end
    end
    return FlaggedPlayers
end

-- Auto scan loop
local _acConn, _acTimer = nil, 0
local function StartACLoop()
    if _acConn then _acConn:Disconnect() end
    _acTimer = 0
    _acConn = RunService.Heartbeat:Connect(function(dt)
        if not S.ACAutoScan then return end
        _acTimer = _acTimer + dt
        if _acTimer < 4 then return end
        _acTimer = 0
        local found = ScanAll()
        if #found > 0 then
            Notify("AntiCheat", "⚠ "..#found.." suspicious player(s)!", 5)
        end
    end)
end
StartACLoop()

-- ══════════════════════════════════════════════
-- [7] GUI  CONSTRUCTION
-- ══════════════════════════════════════════════

-- Destroy any old instance
pcall(function()
    local old = CoreGui:FindFirstChild("GodHubUI")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP.PlayerGui end

-- ── 7a. Main Window ───────────────────────────
local WIN_W, WIN_H = 400, 520
local Win = Instance.new("Frame", ScreenGui)
Win.Name = "Window"
Win.Size = UDim2.new(0, WIN_W, 0, WIN_H)
Win.Position = UDim2.new(0, 24, 0.5, -WIN_H/2)
Win.BackgroundColor3 = Color3.fromRGB(9,9,16)
Win.BorderSizePixel = 0
Win.Active = true
Win.Draggable = true
MakeCorner(Win, 12)
MakeStroke(Win, T().Accent, 1.5)

-- Subtle dark gradient
local winGrad = Instance.new("UIGradient", Win)
winGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14,8,20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8,12,18)),
})
winGrad.Rotation = 130

-- ── 7b. Title Bar ─────────────────────────────
local TBar = Instance.new("Frame", Win)
TBar.Size = UDim2.new(1,0,0,44)
TBar.BackgroundColor3 = T().Dim
TBar.BorderSizePixel = 0
MakeCorner(TBar, 12)

local tGrad = Instance.new("UIGradient", TBar)
tGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T().Accent),
    ColorSequenceKeypoint.new(1, T().Dim),
})
tGrad.Rotation = 90

local TTitle = Instance.new("TextLabel", TBar)
TTitle.Size = UDim2.new(1,-100,1,0)
TTitle.Position = UDim2.new(0,14,0,0)
TTitle.BackgroundTransparency = 1
TTitle.Text = "⚡ GOD HUB  ─  TRACK & FIELD"
TTitle.TextColor3 = Color3.fromRGB(255,255,255)
TTitle.TextSize = 13
TTitle.Font = Enum.Font.GothamBold
TTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize
local MinBtn = Instance.new("TextButton", TBar)
MinBtn.Size = UDim2.new(0,28,0,28)
MinBtn.Position = UDim2.new(1,-66,0,8)
MinBtn.BackgroundColor3 = Color3.fromRGB(255,170,0)
MinBtn.Text = "─"; MinBtn.TextColor3=Color3.new(1,1,1)
MinBtn.TextSize=14; MinBtn.Font=Enum.Font.GothamBold
MinBtn.BorderSizePixel=0
MakeCorner(MinBtn,5)

-- Close
local CloseBtn = Instance.new("TextButton", TBar)
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.Position = UDim2.new(1,-34,0,8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,30,50)
CloseBtn.Text = "✕"; CloseBtn.TextColor3=Color3.new(1,1,1)
CloseBtn.TextSize=14; CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.BorderSizePixel=0
MakeCorner(CloseBtn,5)

local _minimized = false
local ContentRoot  -- set later

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinBtn.MouseButton1Click:Connect(function()
    _minimized = not _minimized
    if ContentRoot then ContentRoot.Visible = not _minimized end
    Tween(Win, {Size = _minimized and UDim2.new(0,WIN_W,0,44) or UDim2.new(0,WIN_W,0,WIN_H)}, 0.2)
end)

-- ── 7c. Tab bar ───────────────────────────────
local TabBar = Instance.new("Frame", Win)
TabBar.Size = UDim2.new(1,-16,0,30)
TabBar.Position = UDim2.new(0,8,0,50)
TabBar.BackgroundTransparency = 1
MakeList(TabBar, 3, Enum.FillDirection.Horizontal)

-- ── 7d. Content root ──────────────────────────
ContentRoot = Instance.new("Frame", Win)
ContentRoot.Name = "ContentRoot"
ContentRoot.Size = UDim2.new(1,-16,0,WIN_H-92)
ContentRoot.Position = UDim2.new(0,8,0,86)
ContentRoot.BackgroundTransparency = 1
ContentRoot.ClipsDescendants = true

-- ══════════════════════════════════════════════
-- [8] WIDGET HELPERS
-- ══════════════════════════════════════════════

local function ScrollPage(parent)
    local sf = Instance.new("ScrollingFrame", parent)
    sf.Size = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = T().Accent
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    MakeList(sf, 5)
    MakePad(sf,2,4,4,8)
    return sf
end

local function W_Section(page, lbl)
    local f = Instance.new("Frame", page)
    f.Size = UDim2.new(1,0,0,24)
    f.BackgroundColor3 = T().Dim
    f.BorderSizePixel=0
    MakeCorner(f,5)
    local t = Instance.new("TextLabel",f)
    t.Size=UDim2.new(1,0,1,0)
    t.BackgroundTransparency=1
    t.Text="  ▸ "..lbl
    t.TextColor3=Color3.fromRGB(255,255,255)
    t.TextSize=11
    t.Font=Enum.Font.GothamBold
    t.TextXAlignment=Enum.TextXAlignment.Left
    return f
end

local function W_Label(page, txt, col)
    local l = Instance.new("TextLabel",page)
    l.Size=UDim2.new(1,0,0,16)
    l.BackgroundTransparency=1
    l.Text=txt
    l.TextColor3=col or Color3.fromRGB(120,120,140)
    l.TextSize=10
    l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left
    MakePad(l,8,0,0,0)
    return l
end

local AllToggleRefs = {}  -- for theme refresh

local function W_Toggle(page, label, key, onOn, onOff)
    local row = Instance.new("Frame", page)
    row.Size=UDim2.new(1,0,0,36)
    row.BackgroundColor3=Color3.fromRGB(15,15,26)
    row.BorderSizePixel=0
    MakeCorner(row,6)

    local statusDot = Instance.new("Frame",row)
    statusDot.Size=UDim2.new(0,7,0,7)
    statusDot.Position=UDim2.new(0,8,0.5,-3.5)
    statusDot.BackgroundColor3=S[key] and T().Accent or Color3.fromRGB(50,50,60)
    statusDot.BorderSizePixel=0
    MakeCorner(statusDot,4)

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-60,1,0)
    lbl.Position=UDim2.new(0,20,0,0)
    lbl.BackgroundTransparency=1
    lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(210,210,210)
    lbl.TextSize=12
    lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    local tb=Instance.new("TextButton",row)
    tb.Size=UDim2.new(0,44,0,22)
    tb.Position=UDim2.new(1,-52,0.5,-11)
    tb.BackgroundColor3=S[key] and T().Accent or Color3.fromRGB(38,38,55)
    tb.Text="" tb.BorderSizePixel=0
    MakeCorner(tb,11)

    local dot=Instance.new("Frame",tb)
    dot.Size=UDim2.new(0,16,0,16)
    dot.Position=S[key] and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    dot.BackgroundColor3=Color3.fromRGB(255,255,255)
    dot.BorderSizePixel=0
    MakeCorner(dot,8)
    -- shadow on dot
    Instance.new("UIStroke",dot).Color=Color3.fromRGB(0,0,0)

    local function Update(on)
        S[key]=on
        Tween(tb,{BackgroundColor3=on and T().Accent or Color3.fromRGB(38,38,55)})
        Tween(dot,{Position=on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
        Tween(statusDot,{BackgroundColor3=on and T().Accent or Color3.fromRGB(50,50,60)})
        if on and onOn then onOn() end
        if not on and onOff then onOff() end
    end
    tb.MouseButton1Click:Connect(function() Update(not S[key]) end)
    table.insert(AllToggleRefs,{tb=tb,dot=dot,key=key})
    return row, function(v) Update(v) end
end

local function W_Slider(page, label, key, mn, mx, step, sfx, onChange)
    step=step or 1; sfx=sfx or ""
    local row=Instance.new("Frame",page)
    row.Size=UDim2.new(1,0,0,48)
    row.BackgroundColor3=Color3.fromRGB(15,15,26)
    row.BorderSizePixel=0
    MakeCorner(row,6)

    local topRow=Instance.new("Frame",row)
    topRow.Size=UDim2.new(1,0,0,22)
    topRow.BackgroundTransparency=1

    local labelL=Instance.new("TextLabel",topRow)
    labelL.Size=UDim2.new(0.65,0,1,0)
    labelL.Position=UDim2.new(0,10,0,4)
    labelL.BackgroundTransparency=1
    labelL.Text=label
    labelL.TextColor3=Color3.fromRGB(180,180,200)
    labelL.TextSize=11; labelL.Font=Enum.Font.Gotham
    labelL.TextXAlignment=Enum.TextXAlignment.Left

    local valL=Instance.new("TextLabel",topRow)
    valL.Size=UDim2.new(0.35,-10,1,0)
    valL.Position=UDim2.new(0.65,0,0,4)
    valL.BackgroundTransparency=1
    valL.Text=tostring(S[key])..sfx
    valL.TextColor3=T().Glow
    valL.TextSize=11; valL.Font=Enum.Font.GothamBold
    valL.TextXAlignment=Enum.TextXAlignment.Right

    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-20,0,6)
    track.Position=UDim2.new(0,10,0,32)
    track.BackgroundColor3=Color3.fromRGB(28,28,45)
    track.BorderSizePixel=0; track.ClipsDescendants=true
    MakeCorner(track,3)

    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(math.clamp((S[key]-mn)/(mx-mn),0,1),0,1,0)
    fill.BackgroundColor3=T().Accent
    fill.BorderSizePixel=0
    MakeCorner(fill,3)

    -- Glow on fill
    local fillGlow=Instance.new("UIGradient",fill)
    fillGlow.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,T().Glow),
        ColorSequenceKeypoint.new(1,T().Accent),
    })

    local dragging=false
    local function UpdateSlider(relX)
        local rel=math.clamp(relX,0,1)
        local raw=mn+(mx-mn)*rel
        local val=math.floor(raw/step+0.5)*step
        S[key]=math.clamp(val,mn,mx)
        Tween(fill,{Size=UDim2.new(rel,0,1,0)},0.05)
        valL.Text=tostring(S[key])..sfx
        if onChange then onChange(S[key]) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            local rel=(i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X
            UpdateSlider(rel)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch then
            local rel=(i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X
            UpdateSlider(rel)
        end
    end)
    return row
end

local function W_Button(page, label, col, cb, icon)
    local btn=Instance.new("TextButton",page)
    btn.Size=UDim2.new(1,0,0,34)
    btn.BackgroundColor3=col or T().Accent
    btn.Text=(icon and icon.." " or "")..label
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.TextSize=12; btn.Font=Enum.Font.GothamBold
    btn.BorderSizePixel=0
    MakeCorner(btn,6)
    -- Hover effect
    btn.MouseEnter:Connect(function()
        Tween(btn,{BackgroundColor3=(col or T().Accent):lerp(Color3.new(1,1,1),0.12)})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn,{BackgroundColor3=col or T().Accent})
    end)
    btn.MouseButton1Click:Connect(cb)
    return btn
end

local function W_TextInput(page, placeholder, key)
    local box=Instance.new("TextBox",page)
    box.Size=UDim2.new(1,0,0,32)
    box.BackgroundColor3=Color3.fromRGB(18,18,30)
    box.PlaceholderText=placeholder
    box.PlaceholderColor3=Color3.fromRGB(70,70,90)
    box.Text=""; box.TextColor3=Color3.fromRGB(220,220,220)
    box.TextSize=12; box.Font=Enum.Font.Gotham
    box.ClearTextOnFocus=false; box.BorderSizePixel=0
    MakeCorner(box,6); MakePad(box,10,6,2,2)
    MakeStroke(box,T().Dim,1)
    box.FocusLost:Connect(function() if key then S[key]=box.Text end end)
    return box
end

local function W_Dropdown(page, label, options, key, onChange)
    local frame=Instance.new("Frame",page)
    frame.Size=UDim2.new(1,0,0,32)
    frame.BackgroundColor3=Color3.fromRGB(18,18,30)
    frame.BorderSizePixel=0; frame.ClipsDescendants=false
    MakeCorner(frame,6); MakeStroke(frame,T().Dim,1)

    local selected=Instance.new("TextButton",frame)
    selected.Size=UDim2.new(1,0,1,0)
    selected.BackgroundTransparency=1
    selected.Text=label..":  "..tostring(S[key] or options[1])
    selected.TextColor3=Color3.fromRGB(220,220,220)
    selected.TextSize=12; selected.Font=Enum.Font.Gotham
    selected.TextXAlignment=Enum.TextXAlignment.Left
    MakePad(selected,10,6,0,0)

    local arrow=Instance.new("TextLabel",frame)
    arrow.Size=UDim2.new(0,20,1,0)
    arrow.Position=UDim2.new(1,-24,0,0)
    arrow.BackgroundTransparency=1
    arrow.Text="▾"; arrow.TextColor3=T().Accent
    arrow.TextSize=14; arrow.Font=Enum.Font.GothamBold

    local dropdown=Instance.new("Frame",frame)
    dropdown.Size=UDim2.new(1,0,0,#options*28+4)
    dropdown.Position=UDim2.new(0,0,1,2)
    dropdown.BackgroundColor3=Color3.fromRGB(18,18,32)
    dropdown.BorderSizePixel=0; dropdown.ZIndex=10; dropdown.Visible=false
    MakeCorner(dropdown,6); MakeStroke(dropdown,T().Accent,1)
    MakeList(dropdown,2)
    MakePad(dropdown,2,2,2,2)

    for _, opt in ipairs(options) do
        local o=opt
        local optBtn=Instance.new("TextButton",dropdown)
        optBtn.Size=UDim2.new(1,0,0,26)
        optBtn.BackgroundColor3=(S[key]==o) and T().Dim or Color3.fromRGB(22,22,36)
        optBtn.Text="  "..o; optBtn.TextColor3=Color3.fromRGB(210,210,210)
        optBtn.TextSize=11; optBtn.Font=Enum.Font.Gotham
        optBtn.TextXAlignment=Enum.TextXAlignment.Left
        optBtn.BorderSizePixel=0; optBtn.ZIndex=11
        MakeCorner(optBtn,4)
        optBtn.MouseButton1Click:Connect(function()
            S[key]=o
            selected.Text=label..":  "..o
            dropdown.Visible=false
            Tween(arrow,{Rotation=0})
            if onChange then onChange(o) end
        end)
    end

    local open=false
    selected.MouseButton1Click:Connect(function()
        open=not open
        dropdown.Visible=open
        Tween(arrow,{Rotation=open and 180 or 0})
    end)
    return frame
end

-- Info box (for AC results)
local function W_InfoBox(page, h, defaultText)
    local f=Instance.new("Frame",page)
    f.Size=UDim2.new(1,0,0,h or 120)
    f.BackgroundColor3=Color3.fromRGB(11,11,20)
    f.BorderSizePixel=0
    MakeCorner(f,6); MakeStroke(f,T().Dim,1)

    local lbl=Instance.new("TextLabel",f)
    lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(180,180,200)
    lbl.TextSize=10; lbl.Font=Enum.Font.Gotham
    lbl.TextWrapped=true; lbl.Text=defaultText or ""
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextYAlignment=Enum.TextYAlignment.Top
    MakePad(lbl,8,8,6,6)
    return f, lbl
end

-- ══════════════════════════════════════════════
-- [9] TAB SYSTEM
-- ══════════════════════════════════════════════
local TabPages = {}
local TabBtns  = {}
local ActiveTab= nil

local TABDEF = {
    { id="Race",      icon="🏃", label="Race"      },
    { id="Speed",     icon="⚡", label="Speed"     },
    { id="AutoWin",   icon="🏆", label="AutoWin"   },
    { id="AntiCheat", icon="🛡", label="Guard"     },
    { id="ESP",       icon="👁", label="ESP"       },
    { id="Farm",      icon="🌾", label="Farm"      },
    { id="Settings",  icon="⚙", label="Settings"  },
}

local function SwitchTab(id)
    ActiveTab=id
    for n,p in pairs(TabPages) do p.Visible=(n==id) end
    for n,b in pairs(TabBtns) do
        Tween(b, {
            BackgroundColor3 = (n==id) and T().Accent or Color3.fromRGB(20,20,32),
            TextColor3       = (n==id) and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,160),
        })
    end
end

for _, td in ipairs(TABDEF) do
    local btn=Instance.new("TextButton",TabBar)
    btn.Size=UDim2.new(0,48,1,0)
    btn.BackgroundColor3=Color3.fromRGB(20,20,32)
    btn.Text=td.icon.."\n"..td.label
    btn.TextColor3=Color3.fromRGB(140,140,160)
    btn.TextSize=8; btn.Font=Enum.Font.GothamBold
    btn.BorderSizePixel=0; btn.AutoButtonColor=false
    MakeCorner(btn,5)
    TabBtns[td.id]=btn

    local page=ScrollPage(ContentRoot)
    TabPages[td.id]=page

    btn.MouseButton1Click:Connect(function() SwitchTab(td.id) end)
end

-- ══════════════════════════════════════════════
-- [10] POPULATE TABS
-- ══════════════════════════════════════════════

-- ── TAB: Race ─────────────────────────────────
do
    local p=TabPages["Race"]

    W_Section(p,"MOVEMENT")
    W_Toggle(p,"⚡ Super Speed","SuperSpeed",
        function() Notify("Race","Super Speed ON ⚡",2) end,
        function() local h=GetHum() if h then h.WalkSpeed=16 end end)
    W_Toggle(p,"🔁 Speed Ramp (safe incr.)","SpeedRamp",
        function() StartRamp() end,
        function() if _rampConn then _rampConn:Disconnect() end end)
    W_Toggle(p,"🏃 Spam Tap Macro","MacroOn",
        function() StartMacro() end, StopMacro)
    W_Toggle(p,"💪 Infinite Stamina","InfStamina",
        function() Notify("Race","Infinite Stamina ON",2) end,nil)
    W_Toggle(p,"🦘 Jump Boost","JumpBoost",
        function() Notify("Race","Jump Boost ON",2) end,
        function() local h=GetHum() if h then h.JumpPower=50 end end)
    W_Toggle(p,"🪐 Low Gravity","LowGravity",
        function() Workspace.Gravity=S.GravityValue end,
        function() Workspace.Gravity=196.2 end)
    W_Toggle(p,"👻 Noclip","Noclip",
        function() Notify("Race","Noclip ON",2) end,nil)
    W_Toggle(p,"🎲 Randomize Speed (anti-detect)","RandomizeSpeed",nil,nil)

    W_Section(p,"TRACK")
    W_Toggle(p,"🚧 Remove Hurdles","RemoveHurdles",
        function() ApplyHurdles() end,nil)
    W_Toggle(p,"🔲 Flatten Track","MakeTrackFlat",
        function() FlattenTrack() end,nil)

    W_Section(p,"TELEPORT")
    local tpBox=W_TextInput(p,"Enter player name...","TpToPlayer")
    W_Button(p,"Teleport to Player",Color3.fromRGB(60,30,160),function()
        TeleportTo(tpBox.Text)
    end,"📍")
    W_Button(p,"Server Hop",Color3.fromRGB(30,80,160),ServerHop,"🚀")

    W_Section(p,"PERKS")
    W_Toggle(p,"👑 Free VIP","FreeVIP",
        function() ApplyFreeVIP() end,nil)
    W_Toggle(p,"🎨 Free Cosmetics","FreeCosmetics",
        function() ApplyFreeCosmetics() end,nil)
    W_Toggle(p,"🪙 Infinite Coins","InfCoins",
        function() Notify("Race","Infinite Coins ON",2) end,nil)
    W_Toggle(p,"⭐ Infinite XP","InfXP",
        function() Notify("Race","Infinite XP ON",2) end,nil)
end

-- ── TAB: Speed ────────────────────────────────
do
    local p=TabPages["Speed"]

    W_Section(p,"WALK SPEED")
    W_Slider(p,"Walk Speed","SpeedValue",16,500,1," spd")
    W_Slider(p,"Ramp Target","RampTarget",16,500,1," spd")
    W_Slider(p,"Ramp Rate","RampRate",1,20,0.5," /s")

    W_Section(p,"JUMP & GRAVITY")
    W_Slider(p,"Jump Power","JumpValue",50,400,1," jp")
    W_Slider(p,"Gravity Override","GravityValue",5,196,1,"")

    W_Section(p,"MACRO MODE")
    W_Label(p,"Choose sprint macro intensity:")
    W_Dropdown(p,"Mode",{"Normal","SemiLegit","Rage"},"MacroMode",function(v)
        if S.MacroOn then StopMacro(); StartMacro() end
        local descs={Normal="Safe, legit looking",SemiLegit="Faster, low risk",Rage="MAX speed"}
        Notify("Macro","Mode: "..v.."  —  "..descs[v],3)
    end)
    W_Toggle(p,"⚡ Pulse Boost (micro WS pulse)","MacroPulseBoost",nil,nil)
    W_Toggle(p,"🎭 Fake Latency (mask speed)","FakeLatency",nil,nil)
    W_Toggle(p,"🔒 Speed Limiter (cap during scans)","SpeedLimiter",nil,nil)
    W_Slider(p,"Safe Speed Cap","SafeSpeed",16,120,1," spd")

    W_Section(p,"APPLY")
    W_Button(p,"▶ Apply Speed Now",T().Accent,function()
        local h=GetHum()
        if h then h.WalkSpeed=S.SpeedValue; h.JumpPower=S.JumpValue end
        Notify("Speed","Applied! WS="..S.SpeedValue.." JP="..S.JumpValue,2)
    end,"✅")
    W_Button(p,"↩ Reset Defaults",Color3.fromRGB(55,55,75),function()
        S.SpeedValue=16; S.JumpValue=50
        local h=GetHum()
        if h then h.WalkSpeed=16; h.JumpPower=50 end
        Workspace.Gravity=196.2
        S.LowGravity=false; S.SuperSpeed=false; S.JumpBoost=false
        Notify("Speed","Reset to defaults",2)
    end,"🔄")
end

-- ── TAB: AutoWin ──────────────────────────────
do
    local p=TabPages["AutoWin"]

    W_Section(p,"AUTO WIN")
    W_Label(p,"Teleports to finish line at race start.")
    W_Toggle(p,"🏁 Auto Win (one-shot per race)","AutoWin",
        function() StartAutoWin(); Notify("AutoWin","Watching for race start…",2) end,nil)
    W_Toggle(p,"📍 Manual Finish Teleport","FinishTeleport",
        function()
            local f=FindFinishLine()
            local r=GetRoot()
            if f and r then
                r.CFrame=f.CFrame+Vector3.new(0,3,0)
                Notify("AutoWin","Teleported to finish! 🏁",3)
            else
                Notify("AutoWin","Finish line not found yet",3)
            end
            S.FinishTeleport=false
        end,nil)
    W_Slider(p,"TP Delay (sec)","AutoWinDelay",0,5,0.1," s")
    W_Toggle(p,"🔄 Auto Restart After Win","AutoRestart",nil,nil)

    W_Section(p,"BYPASS")
    W_Toggle(p,"🛡 Anti-Kick Bypass","AntiKick",
        function() ApplyAntiKick() end,nil)

    W_Section(p,"MANUAL ACTIONS")
    W_Button(p,"Go To Finish Now",T().Accent,function()
        local f=FindFinishLine()
        local r=GetRoot()
        if f and r then
            r.CFrame=f.CFrame+Vector3.new(0,3,0)
            Notify("AutoWin","Done! 🏁",2)
        else
            Notify("AutoWin","Finish line not found",3)
        end
    end,"🏁")
    W_Button(p,"List All Parts (debug)",Color3.fromRGB(40,40,60),function()
        local found={}
        for _,obj in ipairs(Workspace:GetDescendants()) do
            local n=obj.Name:lower()
            if n:find("finish") or n:find("goal") or n:find("win") then
                table.insert(found,obj.Name.." ("..obj.ClassName..")")
            end
        end
        print("[GodHub] Finish candidates:\n"..table.concat(found,"\n"))
        Notify("Debug",#found.." candidates printed to output",3)
    end,"🔍")
end

-- ── TAB: AntiCheat ────────────────────────────
do
    local p=TabPages["AntiCheat"]

    W_Section(p,"DETECTOR")
    W_Toggle(p,"🔍 Auto Scan (every 4s)","ACAutoScan",nil,nil)
    W_Toggle(p,"🔕 Alert-Only Mode (no prints)","ACAlertOnly",nil,nil)

    local _,resultLbl=W_InfoBox(p,160,"Press scan to check for cheaters...\n\n"..
        "Checks performed:\n"..
        "• WalkSpeed > 85\n• JumpPower > 85\n"..
        "• Velocity > 350\n• Flying (Y > 120)\n"..
        "• Noclip (underground)\n• Position teleport\n• Low gravity")

    W_Button(p,"▶ Run Manual Scan",T().Accent,function()
        resultLbl.Text="Scanning "..tostring(#Players:GetPlayers()-1).." players..."
        resultLbl.TextColor3=Color3.fromRGB(180,180,200)
        task.delay(0.3,function()
            local found=ScanAll()
            if #found==0 then
                resultLbl.TextColor3=Color3.fromRGB(80,230,110)
                resultLbl.Text="✔ CLEAN — All "..tostring(#Players:GetPlayers()-1).." player(s) appear normal.\nLast scan: "..os.date("%X")
            else
                local lines={"⚠ FLAGGED ("..#found.." player(s)) — "..os.date("%X").."\n"}
                for _,f in ipairs(found) do
                    table.insert(lines,"• "..f.Name.." (Lv "..tostring(f.Level)..")\n  → "..f.Flags)
                end
                resultLbl.TextColor3=Color3.fromRGB(255,80,80)
                resultLbl.Text=table.concat(lines,"\n")
            end
        end)
    end,"🔍")

    W_Section(p,"HISTORY (last 10 flags)")
    local _,histLbl=W_InfoBox(p,100,"No flags recorded yet.")
    W_Button(p,"Show Flag History",Color3.fromRGB(40,50,80),function()
        local h=S.ACFlagHistory
        if #h==0 then histLbl.Text="No flags recorded yet." return end
        local lines={}
        for i=math.max(1,#h-9),#h do
            local f=h[i]
            table.insert(lines,f.Name.." → "..f.Flags)
        end
        histLbl.Text=table.concat(lines,"\n")
    end,"📜")
    W_Button(p,"Clear History",Color3.fromRGB(60,20,20),function()
        S.ACFlagHistory={}
        histLbl.Text="History cleared."
        Notify("AntiCheat","Flag history cleared",2)
    end,"🗑")

    W_Section(p,"BYPASS")
    W_Toggle(p,"🛡 Anti-Kick Bypass","AntiKick",
        function() ApplyAntiKick() end,nil)
    W_Label(p,"⚠ Keep speed under 80 to stay safe",Color3.fromRGB(255,160,0))
    W_Label(p,"Don't finish line instantly or you risk a kick",Color3.fromRGB(120,120,140))
end

-- ── TAB: ESP ──────────────────────────────────
do
    local p=TabPages["ESP"]

    W_Section(p,"ESP TOGGLES")
    W_Toggle(p,"👁 Enable ESP","ESPOn",
        function() InitESP(); Notify("ESP","ESP ON",2) end,
        function() ESPFolder:ClearAllChildren(); Notify("ESP","ESP OFF",2) end)
    W_Toggle(p,"📛 Show Names","ESPNames",nil,nil)
    W_Toggle(p,"📏 Show Distance","ESPDist",nil,nil)
    W_Toggle(p,"📦 Show Boxes","ESPBoxes",nil,nil)
    W_Toggle(p,"✨ Chams (neon color)","ESPChams",nil,nil)
    W_Slider(p,"Max Distance","ESPMaxDist",50,1000,10," st")

    W_Section(p,"COLOR GUIDE")
    W_Label(p,"🔴 Red   = < 25 studs",Color3.fromRGB(255,80,80))
    W_Label(p,"🟠 Orange = 25–80 studs",Color3.fromRGB(255,165,0))
    W_Label(p,"🔵 Blue  = > 80 studs",Color3.fromRGB(80,200,255))

    W_Section(p,"ACTIONS")
    W_Button(p,"Refresh ESP",Color3.fromRGB(40,80,160),function()
        if S.ESPOn then ESPFolder:ClearAllChildren(); InitESP(); Notify("ESP","Refreshed",2) end
    end,"🔄")
end

-- ── TAB: Farm ────────────────────────────────
do
    local p=TabPages["Farm"]

    W_Section(p,"AUTO FARM")
    W_Dropdown(p,"Farm Mode",{"Coins","XP","Both"},"FarmMode",function(v)
        Notify("Farm","Mode set to "..v,2)
    end)
    W_Slider(p,"Loop Delay","FarmLoopDelay",0.1,5,0.1," s")
    W_Toggle(p,"🌾 Start Auto Farm","AutoFarm",
        function() StartFarm(); Notify("Farm","Auto Farm ON",2) end,
        function() Notify("Farm","Auto Farm OFF",2) end)
    W_Toggle(p,"🪙 Infinite Coins","InfCoins",nil,nil)
    W_Toggle(p,"⭐ Infinite XP","InfXP",nil,nil)
    W_Slider(p,"Coin Cap Value","CoinValue",1000,9999999,1000," coins")

    W_Section(p,"QUICK ACTIONS")
    W_Button(p,"Claim Daily Reward",Color3.fromRGB(60,130,30),function()
        FireRemote({"daily","reward","bonus","claim","login"})
        Notify("Farm","Daily reward sent ✓",3)
    end,"🎁")
    W_Button(p,"Claim All Rewards",Color3.fromRGB(140,80,0),function()
        FireRemote({"reward","bonus","claim","give","grant"})
        Notify("Farm","All reward remotes fired ✓",3)
    end,"🎯")
    W_Button(p,"Max Stats Now",T().Accent,function()
        StartCoins()
        Notify("Farm","Max stats applied ✓",2)
    end,"⬆")
end

-- ── TAB: Settings ─────────────────────────────
do
    local p=TabPages["Settings"]

    W_Section(p,"THEME")
    W_Dropdown(p,"Color Theme",{"Red","Blue","Green","Purple"},"Theme",function(v)
        Notify("Settings","Theme changed to "..v..". Reload UI to apply fully.",4)
    end)

    W_Section(p,"KEYBINDS")
    W_Label(p,"RightShift  =  Toggle UI")
    W_Label(p,"Insert  =  Panic close (destroy script)")

    W_Section(p,"DISPLAY")
    W_Toggle(p,"🔔 Notifications","Notifications",nil,nil)
    W_Toggle(p,"💧 Watermark","Watermark",nil,nil)

    W_Section(p,"DANGER ZONE")
    W_Button(p,"💣 Panic Close (destroy script)",Color3.fromRGB(130,10,10),function()
        ScreenGui:Destroy()
        ESPFolder:Destroy()
    end,"🚨")
    W_Button(p,"🔄 Reload UI",Color3.fromRGB(40,60,100),function()
        -- Re-execute the script
        Notify("Settings","Reload manually with executor",3)
    end,"")
    W_Button(p,"📋 Copy Credits",Color3.fromRGB(40,40,60),function()
        setclipboard and setclipboard("GOD HUB v3.0 — Track & Field: Infinite")
        Notify("Settings","Copied to clipboard",2)
    end,"")

    W_Section(p,"INFO")
    W_Label(p,"GOD HUB v3.0  —  Track & Field: Infinite")
    W_Label(p,"7 Tabs | 50+ Features | Full AC Detector")
    W_Label(p,"ESP | AutoWin | Farm | Bypass | More")
end

-- ══════════════════════════════════════════════
-- [11] WATERMARK
-- ══════════════════════════════════════════════
local WM = Instance.new("Frame", ScreenGui)
WM.Name="Watermark"
WM.Size=UDim2.new(0,220,0,26)
WM.Position=UDim2.new(1,-228,0,8)
WM.BackgroundColor3=Color3.fromRGB(9,9,16)
WM.BorderSizePixel=0; WM.Active=false
MakeCorner(WM,6); MakeStroke(WM,T().Accent,1)

local wmLabel=Instance.new("TextLabel",WM)
wmLabel.Size=UDim2.new(1,0,1,0)
wmLabel.BackgroundTransparency=1
wmLabel.Text="⚡ GOD HUB v3.0  |  Track & Field"
wmLabel.TextColor3=Color3.fromRGB(200,200,210)
wmLabel.TextSize=10; wmLabel.Font=Enum.Font.GothamBold

-- Pulse the stroke on watermark
task.spawn(function()
    local t=0
    while WM and WM.Parent do
        t=t+task.wait(0.05)
        local alpha=math.abs(math.sin(t*1.2))
        local stroke=WM:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color=T().Accent:lerp(T().Glow, alpha*0.5)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if WM then WM.Visible=S.Watermark end
end)

-- ══════════════════════════════════════════════
-- [12] KEYBINDS
-- ══════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == S.UIKeybind then
        Win.Visible = not Win.Visible
    elseif inp.KeyCode == S.PanicKeybind then
        ScreenGui:Destroy()
        ESPFolder:Destroy()
    end
end)

-- ══════════════════════════════════════════════
-- [13] START ON "Race" TAB
-- ══════════════════════════════════════════════
SwitchTab("Race")

-- ══════════════════════════════════════════════
-- [14] STARTUP
-- ══════════════════════════════════════════════
task.wait(1)
Notify("GOD HUB v3.0","Loaded! 7 tabs, 50+ features ready. RightShift = toggle.",6)
print("╔═══════════════════════════════════════════════╗")
print("║  GOD HUB v3.0  ─  Track & Field: Infinite    ║")
print("║  7 Tabs: Race|Speed|AutoWin|Guard|ESP|Farm|⚙  ║")
print("║  RightShift=Toggle   Insert=Panic Close       ║")
print("╚═══════════════════════════════════════════════╝")
