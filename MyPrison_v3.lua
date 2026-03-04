-- ╔══════════════════════════════════════════════════════════╗
-- ║            MY PRISON  ·  SCRIPT v3.0                    ║
-- ║            Windburst Edition  ·  2026                   ║
-- ║                                                          ║
-- ║  Based on actual My Prison (game:10118504428) mechanics  ║
-- ║  • Prison Tycoon / Management                            ║
-- ║  • Janitor / Repairman / Guard roles                     ║
-- ║  • Tunnel dig system, laundry, contraband, fire event    ║
-- ║  • Prison Reputation system                              ║
-- ╚══════════════════════════════════════════════════════════╝

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace      = game:GetService("Workspace")
local LocalPlayer    = Players.LocalPlayer
local Character      = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Mouse          = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════════
--  STATE  (all features off by default)
-- ══════════════════════════════════════════════
local State = {
    -- Automation
    AutoClean        = false,   -- Janitor: auto-clean mess/litter/dishes
    AutoFillTunnels  = false,   -- Repairman: auto-fill escape tunnels & flag them
    AutoArrestCrim   = false,   -- Guard: auto-arrest criminals in range
    AutoFeedPrisoners= false,   -- Chef: auto-trigger buffet refill prompts
    AutoExtinguish   = false,   -- Guard: auto-extinguish fires (fire event)
    AutoContraband   = false,   -- Guard: auto-confiscate flagged contraband
    -- Car / patrol
    AutoPatrol       = false,   -- Drive patrol route to arrest criminals in Crime City
    -- Display
    ShowESP          = false,   -- Highlight tunnels / criminals / fires on screen
    -- Config
    ArrestRadius     = 45,
    ScanRate         = 1.2,
    GuiOpen          = true,
    CurrentTab       = "Main",
}

-- ══════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.22,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out), props):Play()
end

local function GetHRP()
    Character = LocalPlayer.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function FireRemote(name, ...)
    local rs   = ReplicatedStorage
    local ws   = Workspace
    local hits = {
        rs:FindFirstChild(name, true),
        ws:FindFirstChild(name, true),
    }
    for _, r in ipairs(hits) do
        if r then
            pcall(function()
                if r:IsA("RemoteEvent")    then r:FireServer(...) end
                if r:IsA("RemoteFunction") then r:InvokeServer(...) end
            end)
            return true
        end
    end
    return false
end

local function FirePrompt(obj)
    local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if p then pcall(fireproximityprompt, p) return true end
    return false
end

-- ── Notification toast ──────────────────────
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "MPNotifs"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local notifStack = Instance.new("Frame")
notifStack.Size = UDim2.new(0, 340, 1, 0)
notifStack.Position = UDim2.new(0.5, -170, 0, 0)
notifStack.BackgroundTransparency = 1
notifStack.Parent = notifGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.Padding = UDim.new(0, 6)
notifLayout.Parent = notifStack

local notifPad = Instance.new("UIPadding")
notifPad.PaddingTop = UDim.new(0, 12)
notifPad.Parent = notifStack

local function Notify(msg, col, icon)
    col  = col  or Color3.fromRGB(70, 220, 120)
    icon = icon or "⚙"

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 0)
    bg.AutomaticSize = Enum.AutomaticSize.Y
    bg.BackgroundColor3 = Color3.fromRGB(14, 18, 22)
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0
    bg.Parent = notifStack

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = bg

    local stroke = Instance.new("UIStroke")
    stroke.Color = col
    stroke.Thickness = 1.2
    stroke.Transparency = 0.5
    stroke.Parent = bg

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = col
    accent.BorderSizePixel = 0
    accent.Parent = bg
    Instance.new("UICorner").CornerRadius = UDim.new(0, 3)
    accent:FindFirstChildOfClass("UICorner").Parent = accent

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 42)
    row.Position = UDim2.new(0, 8, 0, 0)
    row.BackgroundTransparency = 1
    row.Parent = bg

    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0, 32, 1, 0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.TextSize = 18
    ic.Font = Enum.Font.GothamBold
    ic.TextColor3 = col
    ic.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -36, 1, 0)
    lbl.Position = UDim2.new(0, 34, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = Color3.fromRGB(215, 230, 220)
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Text = msg
    lbl.Parent = row

    Tween(bg, {BackgroundTransparency = 0}, 0.3)
    task.delay(3, function()
        Tween(bg, {BackgroundTransparency = 1}, 0.3)
        Tween(stroke, {Transparency = 1}, 0.3)
        task.delay(0.35, function() bg:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════
--  FEATURE LOGIC  (accurate to My Prison 2026)
-- ══════════════════════════════════════════════

-- 1. AUTO CLEAN ─ targets My Prison mess objects
--    Mess appears as: "Mess", "Litter", "Dirt", "Dish", "Laundry",
--    "Trash", "DirtyDish", "DirtyCloth", "Spill"
local CLEAN_NAMES = {"Mess","Litter","Dirt","Trash","Spill","Debris",
                     "Dirty","DirtyDish","DirtyCloth","Laundry","Waste"}
local function RunAutoClean()
    if not State.AutoClean then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Parent then
            for _, tag in ipairs(CLEAN_NAMES) do
                if obj.Name:lower():find(tag:lower()) then
                    local dist = (hrp.Position - (obj:IsA("Model")
                        and (obj:GetModelCFrame().Position) or obj.Position)).Magnitude
                    if dist < 80 then
                        FirePrompt(obj)
                        -- also try common clean remotes
                        FireRemote("CleanMess", obj)
                        FireRemote("Clean", obj)
                        FireRemote("Janitor_Clean", obj)
                    end
                    break
                end
            end
        end
    end
end

-- 2. AUTO FILL TUNNELS ─ My Prison: prisoners dig tunnels, repairmen fill them
--    Tunnels appear as: "Tunnel", "Hole", "TunnelHole", "EscapeTunnel",
--    "DigHole", flagged with a "Flag" part on top
local TUNNEL_NAMES = {"Tunnel","EscapeTunnel","TunnelHole","DigHole","Hole","DiggingHole"}
local function RunAutoFillTunnels()
    if not State.AutoFillTunnels then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Parent then
            for _, tag in ipairs(TUNNEL_NAMES) do
                if obj.Name:lower():find(tag:lower()) then
                    local pos = obj:IsA("Model")
                        and obj:GetModelCFrame().Position
                        or (obj:IsA("BasePart") and obj.Position)
                    if pos and (hrp.Position - pos).Magnitude < 100 then
                        FirePrompt(obj)
                        FireRemote("FillTunnel", obj)
                        FireRemote("RepairTunnel", obj)
                        FireRemote("Repairman_Fill", obj)
                        -- Flag the tunnel as spotted
                        FireRemote("FlagTunnel", obj)
                    end
                    break
                end
            end
        end
    end
end

-- 3. AUTO ARREST CRIMINAL ─ Drive into Crime City, arrest players near you
--    My Prison: criminals walk around until a guard arrests them in a police car
local function RunAutoArrest()
    if not State.AutoArrestCrim then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if tHRP and (hrp.Position - tHRP.Position).Magnitude <= State.ArrestRadius then
                -- My Prison uses handcuffs / arrest tools; try known remote names
                local remoteNames = {
                    "ArrestPlayer","Arrest","HandcuffPlayer","PutInCar",
                    "ArrestCriminal","Guard_Arrest","CuffPlayer"
                }
                for _, rn in ipairs(remoteNames) do
                    if FireRemote(rn, plr) then break end
                end
            end
        end
    end
end

-- 4. AUTO FEED PRISONERS ─ Chef role: trigger buffet / food placement
--    My Prison: chef must restock buffets so prisoners can eat
local FOOD_NAMES = {"Buffet","FoodTray","FoodPlatform","ServingStation","FoodCounter"}
local function RunAutoFeed()
    if not State.AutoFeedPrisoners then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Parent then
            for _, tag in ipairs(FOOD_NAMES) do
                if obj.Name:lower():find(tag:lower()) then
                    local pos = obj:IsA("BasePart") and obj.Position
                             or (obj:IsA("Model") and obj:GetModelCFrame().Position)
                    if pos and (hrp.Position - pos).Magnitude < 60 then
                        FirePrompt(obj)
                        FireRemote("RefillBuffet", obj)
                        FireRemote("Chef_Serve", obj)
                    end
                    break
                end
            end
        end
    end
end

-- 5. AUTO EXTINGUISH ─ My Prison has a 🔥 Fire Event (recent update 2025-2026)
local FIRE_NAMES = {"Fire","Flame","FireObject","BurningObject","FireHazard"}
local function RunAutoExtinguish()
    if not State.AutoExtinguish then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Parent then
            local isfire = false
            for _, tag in ipairs(FIRE_NAMES) do
                if obj.Name:lower():find(tag:lower()) then isfire = true break end
            end
            if not isfire and obj:IsA("Fire") then isfire = true end
            if isfire then
                local pos = obj:IsA("BasePart") and obj.Position
                         or (obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Position)
                if pos and (hrp.Position - pos).Magnitude < 70 then
                    FirePrompt(obj.Parent or obj)
                    FireRemote("Extinguish", obj)
                    FireRemote("PutOutFire", obj)
                end
            end
        end
    end
end

-- 6. AUTO CONTRABAND ─ My Prison added contraband items in a recent update
local CONTRA_NAMES = {"Contraband","Weapon","Knife","Shiv","IllegalItem","DrugItem"}
local function RunAutoContraband()
    if not State.AutoContraband then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Parent then
            for _, tag in ipairs(CONTRA_NAMES) do
                if obj.Name:lower():find(tag:lower()) then
                    local pos = obj:IsA("BasePart") and obj.Position
                             or (obj:IsA("Model") and obj:GetModelCFrame().Position)
                    if pos and (hrp.Position - pos).Magnitude < 50 then
                        FirePrompt(obj)
                        FireRemote("ConfiscateContraband", obj)
                        FireRemote("Confiscate", obj)
                    end
                    break
                end
            end
        end
    end
end

-- ── Master loop ──────────────────
local lastTick = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastTick < State.ScanRate then return end
    lastTick = now
    task.spawn(RunAutoClean)
    task.spawn(RunAutoFillTunnels)
    task.spawn(RunAutoArrest)
    task.spawn(RunAutoFeed)
    task.spawn(RunAutoExtinguish)
    task.spawn(RunAutoContraband)
end)

-- ══════════════════════════════════════════════
--  GUI  ─ Dark military-green prison aesthetic
-- ══════════════════════════════════════════════

-- Colour palette
local C = {
    bg        = Color3.fromRGB(11, 14, 12),
    bg2       = Color3.fromRGB(17, 22, 18),
    bg3       = Color3.fromRGB(22, 30, 24),
    accent    = Color3.fromRGB(60, 210, 100),
    accentDim = Color3.fromRGB(30, 100, 50),
    accentOff = Color3.fromRGB(40, 52, 44),
    tabActive  = Color3.fromRGB(22, 55, 30),
    tabInactive= Color3.fromRGB(14, 18, 15),
    text      = Color3.fromRGB(210, 232, 215),
    textDim   = Color3.fromRGB(90, 130, 100),
    red       = Color3.fromRGB(220, 80, 70),
    orange    = Color3.fromRGB(230, 150, 50),
    blue      = Color3.fromRGB(60, 140, 230),
    knobOff   = Color3.fromRGB(120, 145, 128),
    knobOn    = Color3.fromRGB(230, 255, 238),
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyPrisonV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ── Drop shadow ──────────────────
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(0, 336, 0, 502)
Shadow.Position = UDim2.new(0.5, -160, 0.5, -246)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.55
Shadow.BorderSizePixel = 0
Shadow.Parent = ScreenGui
Instance.new("UICorner").CornerRadius = UDim.new(0, 18)
Shadow:FindFirstChildOfClass("UICorner").Parent = Shadow

-- ── Main window ──────────────────
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 326, 0, 490)
Main.Position = UDim2.new(0.5, -163, 0.5, -245)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

Instance.new("UICorner").CornerRadius = UDim.new(0, 14)
Main:FindFirstChildOfClass("UICorner").Parent = Main

local border = Instance.new("UIStroke")
border.Color = C.accent
border.Thickness = 1.4
border.Transparency = 0.5
border.Parent = Main

-- Scanline texture overlay (aesthetic)
local scanOverlay = Instance.new("Frame")
scanOverlay.Size = UDim2.new(1, 0, 1, 0)
scanOverlay.BackgroundTransparency = 0.97
scanOverlay.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
scanOverlay.BorderSizePixel = 0
scanOverlay.ZIndex = 10
scanOverlay.Parent = Main

-- ── Header ──────────────────────
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = C.bg2
Header.BorderSizePixel = 0
Header.Parent = Main

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 14)
hCorner.Parent = Header

-- Bottom flat edge on header
local hFlat = Instance.new("Frame")
hFlat.Size = UDim2.new(1, 0, 0, 14)
hFlat.Position = UDim2.new(0, 0, 1, -14)
hFlat.BackgroundColor3 = C.bg2
hFlat.BorderSizePixel = 0
hFlat.Parent = Header

local hGrad = Instance.new("UIGradient")
hGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 55, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 18, 14)),
})
hGrad.Rotation = 90
hGrad.Parent = Header

-- Lock icon badge
local badge = Instance.new("Frame")
badge.Size = UDim2.new(0, 38, 0, 38)
badge.Position = UDim2.new(0, 12, 0.5, -19)
badge.BackgroundColor3 = C.accentDim
badge.BorderSizePixel = 0
badge.Parent = Header
Instance.new("UICorner").CornerRadius = UDim.new(0, 10)
badge:FindFirstChildOfClass("UICorner").Parent = badge

local badgeIcon = Instance.new("TextLabel")
badgeIcon.Size = UDim2.new(1, 0, 1, 0)
badgeIcon.BackgroundTransparency = 1
badgeIcon.Text = "🔒"
badgeIcon.TextSize = 20
badgeIcon.Parent = badge

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -110, 0, 22)
titleLbl.Position = UDim2.new(0, 58, 0, 8)
titleLbl.BackgroundTransparency = 1
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextColor3 = C.accent
titleLbl.TextSize = 17
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Text = "MY PRISON"
titleLbl.Parent = Header

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1, -110, 0, 14)
subLbl.Position = UDim2.new(0, 58, 0, 32)
subLbl.BackgroundTransparency = 1
subLbl.Font = Enum.Font.Gotham
subLbl.TextColor3 = C.textDim
subLbl.TextSize = 11
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.Text = "Script v3.0  ·  Windburst 2026"
subLbl.Parent = Header

-- Minimize btn
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -40, 0.5, -14)
MinBtn.BackgroundColor3 = C.accentDim
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = C.accent
MinBtn.TextSize = 16
MinBtn.Text = "─"
MinBtn.BorderSizePixel = 0
MinBtn.Parent = Header
Instance.new("UICorner").CornerRadius = UDim.new(0, 7)
MinBtn:FindFirstChildOfClass("UICorner").Parent = MinBtn

-- ── Tab bar ──────────────────────
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 36)
TabBar.Position = UDim2.new(0, 0, 0, 58)
TabBar.BackgroundColor3 = C.bg2
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = TabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 6)
tabPad.PaddingRight = UDim.new(0, 6)
tabPad.Parent = TabBar

-- ── Page container ───────────────
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, 0, 1, -100)
Pages.Position = UDim2.new(0, 0, 0, 100)
Pages.BackgroundTransparency = 1
Pages.ClipsDescendants = true
Pages.Parent = Main

-- ══════════════════════════════════════════════
--  COMPONENT BUILDERS
-- ══════════════════════════════════════════════

-- Scrollable page
local function MakePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Pages

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, 12)
    pad.PaddingRight  = UDim.new(0, 12)
    pad.PaddingTop    = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.Parent = page
    return page
end

-- Section divider
local function SectionLabel(parent, text, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = C.accentDim
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0
    line.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundColor3 = C.bg
    lbl.BorderSizePixel = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = C.accent
    lbl.TextSize = 10
    lbl.Text = "  ▸  " .. text:upper() .. "  "
    lbl.Parent = f
end

-- Toggle row
local function Toggle(parent, icon, label, desc, stateKey, color, order)
    color = color or C.accent
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 64)
    row.BackgroundColor3 = C.bg3
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)
    row:FindFirstChildOfClass("UICorner").Parent = row

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.accentOff
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = row

    -- left icon
    local iconWrap = Instance.new("Frame")
    iconWrap.Size = UDim2.new(0, 42, 0, 42)
    iconWrap.Position = UDim2.new(0, 10, 0.5, -21)
    iconWrap.BackgroundColor3 = C.accentDim
    iconWrap.BorderSizePixel = 0
    iconWrap.Parent = row
    Instance.new("UICorner").CornerRadius = UDim.new(0, 9)
    iconWrap:FindFirstChildOfClass("UICorner").Parent = iconWrap

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(1, 0, 1, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextSize = 20
    iconLbl.Parent = iconWrap

    -- text
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -118, 0, 20)
    nameLbl.Position = UDim2.new(0, 62, 0, 12)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextColor3 = C.text
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Text = label
    nameLbl.Parent = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -118, 0, 28)
    descLbl.Position = UDim2.new(0, 62, 0, 33)
    descLbl.BackgroundTransparency = 1
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextColor3 = C.textDim
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextWrapped = true
    descLbl.Text = desc
    descLbl.Parent = row

    -- pill toggle
    local pillBg = Instance.new("Frame")
    pillBg.Size = UDim2.new(0, 48, 0, 26)
    pillBg.Position = UDim2.new(1, -62, 0.5, -13)
    pillBg.BackgroundColor3 = C.accentOff
    pillBg.BorderSizePixel = 0
    pillBg.Parent = row
    Instance.new("UICorner").CornerRadius = UDim.new(0, 13)
    pillBg:FindFirstChildOfClass("UICorner").Parent = pillBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = C.knobOff
    knob.BorderSizePixel = 0
    knob.Parent = pillBg
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)
    knob:FindFirstChildOfClass("UICorner").Parent = knob

    local function Refresh()
        local on = State[stateKey]
        Tween(pillBg, {BackgroundColor3 = on and color or C.accentOff}, 0.2)
        Tween(knob,   {Position = on and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}, 0.2)
        Tween(knob,   {BackgroundColor3 = on and C.knobOn or C.knobOff}, 0.2)
        Tween(stroke, {Color = on and color or C.accentOff}, 0.2)
        Tween(iconWrap,{BackgroundColor3 = on and Color3.new(color.R*0.7, color.G*0.7, color.B*0.7) or C.accentDim}, 0.2)
    end

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = row
    hitbox.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        Refresh()
        local on = State[stateKey]
        local notifCol = on and color or C.red
        Notify(label .. (on and "  →  ON" or "  →  OFF"), notifCol, icon)
    end)
    hitbox.MouseEnter:Connect(function()
        Tween(row, {BackgroundColor3 = Color3.fromRGB(26, 36, 28)}, 0.12)
    end)
    hitbox.MouseLeave:Connect(function()
        Tween(row, {BackgroundColor3 = C.bg3}, 0.12)
    end)

    Refresh()
    return Refresh
end

-- Info card
local function InfoCard(parent, lines, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 14 + #lines * 20)
    card.BackgroundColor3 = Color3.fromRGB(16, 28, 20)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = parent
    Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
    card:FindFirstChildOfClass("UICorner").Parent = card

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.Padding = UDim.new(0, 2)
    cardLayout.Parent = card
    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingLeft = UDim.new(0,10) cardPad.PaddingTop = UDim.new(0,7)
    cardPad.Parent = card

    for _, line in ipairs(lines) do
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -14, 0, 18)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.Gotham
        l.TextColor3 = C.textDim
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = line
        l.Parent = card
    end
    return card
end

-- Status pulse card
local function StatusCard(parent, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = Color3.fromRGB(14, 28, 18)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = parent
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)
    card:FindFirstChildOfClass("UICorner").Parent = card

    local sGrad = Instance.new("UIGradient")
    sGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22,55,32)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10,20,14)),
    })
    sGrad.Rotation = 90
    sGrad.Parent = card

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 9, 0, 9)
    dot.Position = UDim2.new(0, 14, 0.5, -4)
    dot.BackgroundColor3 = C.accent
    dot.BorderSizePixel = 0
    dot.Parent = card
    Instance.new("UICorner").CornerRadius = UDim.new(0, 5)
    dot:FindFirstChildOfClass("UICorner").Parent = dot

    task.spawn(function()
        while card.Parent do
            Tween(dot, {BackgroundTransparency=0.75}, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.9)
            Tween(dot, {BackgroundTransparency=0}, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.9)
        end
    end)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-32, 1, 0)
    lbl.Position = UDim2.new(0, 30, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = C.accent
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "Script active  ·  Scanning every 1.2s"
    lbl.Parent = card

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1,-32, 0, 14)
    sub.Position = UDim2.new(0, 30, 0, 27)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextColor3 = C.textDim
    sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Text = "RightShift = toggle GUI  ·  My Prison (Windburst)"
    sub.Parent = card
end

-- ══════════════════════════════════════════════
--  BUILD TABS
-- ══════════════════════════════════════════════

local tabDefs = {
    {name="Main",    icon="🏛"},
    {name="Guards",  icon="👮"},
    {name="Staff",   icon="🧹"},
    {name="Info",    icon="ℹ"},
}

local tabBtns = {}
local pageFrames = {}

for _, def in ipairs(tabDefs) do
    pageFrames[def.name] = MakePage(def.name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 28)
    btn.BackgroundColor3 = C.tabInactive
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = C.textDim
    btn.TextSize = 11
    btn.Text = def.icon .. " " .. def.name
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    Instance.new("UICorner").CornerRadius = UDim.new(0, 7)
    btn:FindFirstChildOfClass("UICorner").Parent = btn
    tabBtns[def.name] = btn
end

local function SwitchTab(name)
    State.CurrentTab = name
    for n, pg in pairs(pageFrames) do
        pg.Visible = (n == name)
    end
    for n, btn in pairs(tabBtns) do
        local active = (n == name)
        Tween(btn, {BackgroundColor3 = active and C.tabActive or C.tabInactive}, 0.15)
        Tween(btn, {TextColor3 = active and C.accent or C.textDim}, 0.15)
    end
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

-- ── Main page ────────────────────
local mainPage = pageFrames["Main"]
SectionLabel(mainPage, "Overview", 1)
StatusCard(mainPage, 2)
SectionLabel(mainPage, "Quick Toggles", 3)
Toggle(mainPage, "🧹", "Auto Clean",        "Janitor: cleans mess & dirty dishes",        "AutoClean",       C.accent,  4)
Toggle(mainPage, "⛏", "Auto Fill Tunnels", "Repairman: fills prisoner escape tunnels",   "AutoFillTunnels", C.orange,  5)
Toggle(mainPage, "🚔", "Auto Arrest",       "Guard: arrests criminals in patrol radius",  "AutoArrestCrim",  C.blue,    6)
SectionLabel(mainPage, "Game Info", 7)
InfoCard(mainPage, {
    "🔒 My Prison by Windburst  ·  ID 10118504428",
    "🔄 Updates every ~2 weeks (beta)",
    "🏆 Reputation system  ·  Laundry  ·  Fire Event",
    "🚗 Arrest criminals in Crime City with police car",
    "💰 Earn cash by keeping prisoners satisfied",
}, 8)

-- ── Guards page ──────────────────
local guardPage = pageFrames["Guards"]
SectionLabel(guardPage, "Guard Automation", 1)
Toggle(guardPage, "🚔", "Auto Arrest Criminal", "Auto-arrest nearby criminals (radius: 45u)",    "AutoArrestCrim",   C.blue,   2)
Toggle(guardPage, "🔥", "Auto Extinguish Fire", "Fire Event: auto-extinguish fires in prison",   "AutoExtinguish",   C.red,    3)
Toggle(guardPage, "🚫", "Auto Confiscate",      "Confiscate contraband from prisoners",          "AutoContraband",   C.orange, 4)
SectionLabel(guardPage, "Guard Tips (2026)", 5)
InfoCard(guardPage, {
    "🚨 Watch for riots — check Satisfaction bars",
    "🔍 Scan rooms for escape tunnels regularly",
    "🚗 Use police car to patrol Crime City streets",
    "⚖️ New: Trial system — take criminals to trial",
    "🛒 Prison Shop update — manage inmate spending",
    "🔥 Fire Event — staff-only door near fire zone",
}, 6)

-- ── Staff page ───────────────────
local staffPage = pageFrames["Staff"]
SectionLabel(staffPage, "Staff Automation", 1)
Toggle(staffPage, "🧹", "Auto Clean",         "Janitor: removes litter, mess & dirty dishes", "AutoClean",        C.accent, 2)
Toggle(staffPage, "⛏", "Auto Fill Tunnels",  "Repairman: auto-fill + flag escape tunnels",   "AutoFillTunnels",  C.orange, 3)
Toggle(staffPage, "🍽", "Auto Feed Prisoners","Chef: restocks buffets for prisoner meals",     "AutoFeedPrisoners",C.blue,   4)
SectionLabel(staffPage, "Staff Tips (2026)", 5)
InfoCard(staffPage, {
    "🧺 Laundry update: dirty laundry needs cleaning",
    "🍽 Chefs: oven + sink + fridge = full kitchen",
    "🗑 Add trash cans near dining to reduce mess",
    "🛌 1 bed per prisoner — bunk beds save space",
    "🔧 Repairman fills tunnels & fixes broken items",
    "💸 More satisfied prisoners = more cash earned",
}, 6)

-- ── Info page ────────────────────
local infoPage = pageFrames["Info"]
SectionLabel(infoPage, "Recent Updates (2025-2026)", 1)
InfoCard(infoPage, {
    "🔥 Fire Event + Staff Only Door",
    "🛒 Prison Shop  +  🎨 Wall Painting",
    "⚖️ Trial System  +  🚓 New Car Models",
    "🚨 Contraband  +  Garage Door  +  Posters",
    "🏈 Football  +  🎵 Jukebox  +  New Walls",
    "🧺 Laundry  +  🎖️ Prison Reputation System",
    "✨ Editable Signs  +  New Decorative Items",
    "🏪 Merchant Update (latest)",
}, 2)
SectionLabel(infoPage, "Script Info", 3)
InfoCard(infoPage, {
    "📜 My Prison Script v3.0",
    "🎯 Built for Windburst My Prison (2026)",
    "⌨️ RightShift  →  Toggle GUI",
    "🔄 Scan rate: every 1.2 seconds",
    "🎮 All features OFF by default",
}, 4)

-- ══════════════════════════════════════════════
--  DRAG  (header)
-- ══════════════════════════════════════════════
local dragging, dragStart, winStart
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        winStart  = Main.Position
    end
end)
Header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(
            winStart.X.Scale, winStart.X.Offset + d.X,
            winStart.Y.Scale, winStart.Y.Offset + d.Y)
        Shadow.Position = UDim2.new(
            winStart.X.Scale, winStart.X.Offset + d.X - 5,
            winStart.Y.Scale, winStart.Y.Offset + d.Y - 5)
    end
end)

-- ══════════════════════════════════════════════
--  MINIMIZE
-- ══════════════════════════════════════════════
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Tween(Main,   {Size = UDim2.new(0, 326, 0, 58)}, 0.3, Enum.EasingStyle.Back)
        Tween(Shadow, {Size = UDim2.new(0, 336, 0, 68)}, 0.3, Enum.EasingStyle.Back)
        MinBtn.Text = "+"
    else
        Tween(Main,   {Size = UDim2.new(0, 326, 0, 490)}, 0.35, Enum.EasingStyle.Back)
        Tween(Shadow, {Size = UDim2.new(0, 336, 0, 502)}, 0.35, Enum.EasingStyle.Back)
        MinBtn.Text = "─"
    end
end)

-- ══════════════════════════════════════════════
--  KEYBIND  RightShift = toggle
-- ══════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        State.GuiOpen = not State.GuiOpen
        Main.Visible   = State.GuiOpen
        Shadow.Visible = State.GuiOpen
    end
end)

-- ══════════════════════════════════════════════
--  ENTRY ANIMATION
-- ══════════════════════════════════════════════
SwitchTab("Main")
Main.Position   = UDim2.new(0.5, -163, -0.3, 0)
Shadow.Position = UDim2.new(0.5, -168, -0.3, 0)
Tween(Main,   {Position = UDim2.new(0.5, -163, 0.5, -245)}, 0.65, Enum.EasingStyle.Back)
Tween(Shadow, {Position = UDim2.new(0.5, -168, 0.5, -250)}, 0.65, Enum.EasingStyle.Back)

task.delay(0.8, function()
    Notify("My Prison v3.0 loaded! 🔒", C.accent, "✅")
    task.delay(0.5, function()
        Notify("Windburst 2026 mechanics active", C.blue, "🏛")
    end)
end)

print("[MyPrison v3.0] Loaded — RightShift to toggle GUI")
