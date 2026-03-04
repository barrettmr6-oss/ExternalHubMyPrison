--[[
    MY PRISON SCRIPT v3.1 - RAYFIELD EDITION
    Windburst My Prison (ID: 10118504428) - 2026 Edition
    Features: Auto Clean, Auto Fill Tunnels, Auto Arrest,
              Auto Feed, Auto Extinguish Fire, Auto Contraband
    UI: ArrayField / Rayfield Library
]]

-- =============================================
-- SERVICES
-- =============================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- =============================================
-- STATE
-- =============================================
local State = {
    AutoClean         = false,
    AutoFillTunnels   = false,
    AutoArrestCrim    = false,
    AutoFeedPrisoners = false,
    AutoExtinguish    = false,
    AutoContraband    = false,
    ArrestRadius      = 45,
    ScanRate          = 1.2,
}

-- =============================================
-- UTILITY HELPERS
-- =============================================

local function GetHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function FireRemote(name, ...)
    local targets = {
        ReplicatedStorage:FindFirstChild(name, true),
        Workspace:FindFirstChild(name, true),
    }
    for _, r in ipairs(targets) do
        if r then
            pcall(function()
                if r:IsA("RemoteEvent")    then r:FireServer(...)   end
                if r:IsA("RemoteFunction") then r:InvokeServer(...) end
            end)
            return true
        end
    end
    return false
end

local function FirePrompt(obj)
    if not obj then return false end
    local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if p then
        pcall(fireproximityprompt, p)
        return true
    end
    return false
end

-- =============================================
-- FEATURE LOGIC
-- =============================================

local CLEAN_NAMES  = {"mess","litter","dirt","trash","spill","debris","dirty","laundry","waste","dish"}
local TUNNEL_NAMES = {"tunnel","escapehole","dighole","hole","escapetunnel"}
local FOOD_NAMES   = {"buffet","foodtray","foodplatform","servingstation","foodcounter"}
local FIRE_NAMES   = {"fireobject","burningobject","firehazard","firezone"}
local CONTRA_NAMES = {"contraband","shiv","illegalitem","drugitem","weapon","knife"}

local function matchesAny(name, list)
    local lower = name:lower()
    for _, tag in ipairs(list) do
        if lower:find(tag, 1, true) then return true end
    end
    return false
end

local function RunAutoClean()
    if not State.AutoClean then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj and obj.Parent and (obj:IsA("BasePart") or obj:IsA("Model")) then
            if matchesAny(obj.Name, CLEAN_NAMES) then
                local pos
                if obj:IsA("BasePart") then
                    pos = obj.Position
                elseif obj:IsA("Model") then
                    local ok, cf = pcall(function() return obj:GetModelCFrame() end)
                    if ok then pos = cf.Position end
                end
                if pos and (hrp.Position - pos).Magnitude < 80 then
                    FirePrompt(obj)
                    FireRemote("CleanMess", obj)
                    FireRemote("Clean", obj)
                end
            end
        end
    end
end

local function RunAutoFillTunnels()
    if not State.AutoFillTunnels then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj and obj.Parent and (obj:IsA("BasePart") or obj:IsA("Model")) then
            if matchesAny(obj.Name, TUNNEL_NAMES) then
                local pos
                if obj:IsA("BasePart") then
                    pos = obj.Position
                elseif obj:IsA("Model") then
                    local ok, cf = pcall(function() return obj:GetModelCFrame() end)
                    if ok then pos = cf.Position end
                end
                if pos and (hrp.Position - pos).Magnitude < 100 then
                    FirePrompt(obj)
                    FireRemote("FillTunnel", obj)
                    FireRemote("RepairTunnel", obj)
                end
            end
        end
    end
end

local function RunAutoArrest()
    if not State.AutoArrestCrim then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if tHRP and (hrp.Position - tHRP.Position).Magnitude <= State.ArrestRadius then
                local remotes = {"ArrestPlayer","Arrest","HandcuffPlayer","PutInCar","ArrestCriminal","CuffPlayer"}
                for _, rn in ipairs(remotes) do
                    if FireRemote(rn, plr) then break end
                end
            end
        end
    end
end

local function RunAutoFeed()
    if not State.AutoFeedPrisoners then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj and obj.Parent and (obj:IsA("BasePart") or obj:IsA("Model")) then
            if matchesAny(obj.Name, FOOD_NAMES) then
                local pos
                if obj:IsA("BasePart") then
                    pos = obj.Position
                elseif obj:IsA("Model") then
                    local ok, cf = pcall(function() return obj:GetModelCFrame() end)
                    if ok then pos = cf.Position end
                end
                if pos and (hrp.Position - pos).Magnitude < 60 then
                    FirePrompt(obj)
                    FireRemote("RefillBuffet", obj)
                end
            end
        end
    end
end

local function RunAutoExtinguish()
    if not State.AutoExtinguish then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj and obj.Parent then
            local isFire = (obj:IsA("Fire")) or
                           (obj:IsA("BasePart") and matchesAny(obj.Name, FIRE_NAMES)) or
                           (obj:IsA("Model")    and matchesAny(obj.Name, FIRE_NAMES))
            if isFire then
                local base = obj:IsA("Fire") and obj.Parent or obj
                local pos  = base and base:IsA("BasePart") and base.Position
                if pos and (hrp.Position - pos).Magnitude < 70 then
                    FirePrompt(base)
                    FireRemote("Extinguish", base)
                    FireRemote("PutOutFire", base)
                end
            end
        end
    end
end

local function RunAutoContraband()
    if not State.AutoContraband then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj and obj.Parent and (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool")) then
            if matchesAny(obj.Name, CONTRA_NAMES) then
                local pos
                if obj:IsA("BasePart") then
                    pos = obj.Position
                elseif obj:IsA("Model") then
                    local ok, cf = pcall(function() return obj:GetModelCFrame() end)
                    if ok then pos = cf.Position end
                end
                if pos and (hrp.Position - pos).Magnitude < 50 then
                    FirePrompt(obj)
                    FireRemote("ConfiscateContraband", obj)
                    FireRemote("Confiscate", obj)
                end
            end
        end
    end
end

-- Master scan loop
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

-- =============================================
-- RAYFIELD (ARRAYFIELD) UI
-- =============================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'))()

local Window = Rayfield:CreateWindow({
    Name            = "My Prison  v3.1",
    LoadingTitle    = "My Prison Script",
    LoadingSubtitle = "Windburst 2026 Edition",
    ConfigurationSaving = {
        Enabled  = true,
        FileName = "MyPrisonV3Config",
    },
    KeySystem = false,
})

-- =============================================
-- TAB: MAIN  (overview + info only, no toggles here)
-- =============================================

local MainTab = Window:CreateTab("Main", nil)

MainTab:CreateSection("Status")

MainTab:CreateParagraph({
    Title   = "Script Active",
    Content = "Scanning loop is running. All automations are OFF on first run.\nEnable features in the Guards and Staff tabs.\nSettings are saved and restored automatically."
})

MainTab:CreateSection("Game Info")

MainTab:CreateParagraph({
    Title   = "My Prison  ID 10118504428",
    Content = "Active updates (2025-2026)\nPrison Reputation + Satisfaction system\nArrest criminals in Crime City streets\nEarn cash by keeping prisoners happy"
})

MainTab:CreateSection("Recent Updates 2025-2026")

MainTab:CreateParagraph({
    Title   = "Whats New",
    Content = "Fire Event + Staff Only Door\nPrison Shop + Wall Painting\nTrial System + New Car Models\nContraband System + Garage Door\nFootball + Jukebox + New Walls\nLaundry + Prison Reputation\nEditable Signs + New Decorations\nMerchant Update (latest 2026)"
})

-- =============================================
-- TAB: GUARDS
-- =============================================

local GuardsTab = Window:CreateTab("Guards", nil)

GuardsTab:CreateSection("Guard Automation")

-- Single authoritative flag "AutoArrestCrim" for arrest state.
-- Do NOT duplicate this toggle in any other tab.
GuardsTab:CreateToggle({
    Name         = "Auto Arrest Criminal",
    CurrentValue = false,
    Flag         = "AutoArrestCrim",
    Callback     = function(value)
        State.AutoArrestCrim = value
    end,
})

GuardsTab:CreateToggle({
    Name         = "Auto Extinguish Fire",
    CurrentValue = false,
    Flag         = "AutoExtinguish",
    Callback     = function(value)
        State.AutoExtinguish = value
    end,
})

GuardsTab:CreateToggle({
    Name         = "Auto Confiscate Contraband",
    CurrentValue = false,
    Flag         = "AutoContraband",
    Callback     = function(value)
        State.AutoContraband = value
    end,
})

GuardsTab:CreateSection("Arrest Settings")

-- Rayfield sliders require whole-number increments.
-- Radius stored as integer studs (10 to 120, step 5). No math needed.
GuardsTab:CreateSlider({
    Name         = "Arrest Radius",
    Range        = {10, 120},
    Increment    = 5,
    Suffix       = " studs",
    CurrentValue = 45,
    Flag         = "ArrestRadius",
    Callback     = function(value)
        State.ArrestRadius = value
    end,
})

GuardsTab:CreateSection("Guard Tips 2026")

GuardsTab:CreateParagraph({
    Title   = "Tips",
    Content = "Watch for riots - check Satisfaction bars\nScan rooms for escape tunnels regularly\nPolice car needed to patrol Crime City\nNew: Trial system - take criminals to trial\nPrison Shop - manage inmate purchases\nFire Event - staff-only door near fire zone\nContraband added in 2026 update"
})

-- =============================================
-- TAB: STAFF
-- =============================================

local StaffTab = Window:CreateTab("Staff", nil)

StaffTab:CreateSection("Staff Automation")

-- Single authoritative flag "AutoClean" for clean state.
StaffTab:CreateToggle({
    Name         = "Auto Clean",
    CurrentValue = false,
    Flag         = "AutoClean",
    Callback     = function(value)
        State.AutoClean = value
    end,
})

-- Single authoritative flag "AutoFillTunnels" for tunnel state.
StaffTab:CreateToggle({
    Name         = "Auto Fill Tunnels",
    CurrentValue = false,
    Flag         = "AutoFillTunnels",
    Callback     = function(value)
        State.AutoFillTunnels = value
    end,
})

StaffTab:CreateToggle({
    Name         = "Auto Feed Prisoners",
    CurrentValue = false,
    Flag         = "AutoFeedPrisoners",
    Callback     = function(value)
        State.AutoFeedPrisoners = value
    end,
})

StaffTab:CreateSection("Scan Settings")

-- Rayfield needs integer increments, so scan rate is stored x10.
-- Range 5-50 maps to 0.5s-5.0s. Divided by 10 in callback.
-- Example: slider value 12 -> State.ScanRate = 1.2
StaffTab:CreateSlider({
    Name         = "Scan Rate",
    Range        = {5, 50},
    Increment    = 1,
    Suffix       = " (x0.1s)",
    CurrentValue = 12,
    Flag         = "ScanRateTenths",
    Callback     = function(value)
        State.ScanRate = value / 10
    end,
})

StaffTab:CreateSection("Staff Tips 2026")

StaffTab:CreateParagraph({
    Title   = "Tips",
    Content = "Laundry update: dirty laundry needs washing\nChefs: oven + sink + fridge = full kitchen\nTrash cans near dining reduces mess spam\n1 bed per prisoner - bunk beds save space\nRepairman fills tunnels and fixes broken items\nSatisfied prisoners = more cash earned\nNew wall painting and poster decorations"
})

-- =============================================
-- TAB: INFO
-- =============================================

local InfoTab = Window:CreateTab("Info", nil)

InfoTab:CreateSection("Script Info")

InfoTab:CreateParagraph({
    Title   = "My Prison Script v3.1 Fixed Edition",
    Content = "Windburst My Prison - game ID 10118504428\nAll automations OFF by default (safe)\nAll features wrapped in pcall - no crashes\nScan loop rate adjustable in Staff tab\nConfig auto-saved and restored on next run"
})

InfoTab:CreateSection("How To Use")

InfoTab:CreateParagraph({
    Title   = "Guards Tab",
    Content = "Enable Auto Arrest to cuff nearby criminals.\nEnable Auto Extinguish to fight fires automatically.\nEnable Auto Confiscate to remove contraband items.\nAdjust Arrest Radius slider to control detection range."
})

InfoTab:CreateParagraph({
    Title   = "Staff Tab",
    Content = "Enable Auto Clean to remove mess and litter.\nEnable Auto Fill Tunnels to block escape holes.\nEnable Auto Feed to restock buffets and food stations.\nAdjust Scan Rate to control how often the loop runs.\n(Value 12 on the slider = 1.2 seconds per scan)"
})

-- =============================================
-- LOAD SAVED CONFIGURATION
-- Called last so saved flags correctly restore
-- all toggle and slider states via their callbacks.
-- =============================================

Rayfield:LoadConfiguration()

-- Startup notification
Rayfield:Notify({
    Title    = "My Prison v3.1 Loaded",
    Content  = "Windburst 2026 Edition ready! Config restored.",
    Duration = 5,
    Image    = "rbxassetid://4483345998",
})

print("[MyPrison v3.1 Rayfield] Script loaded successfully")
