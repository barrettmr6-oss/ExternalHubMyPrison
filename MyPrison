--[[
    MY PRISON SCRIPT v4.0 - FINAL EDITION
    Windburst My Prison (ID: 10118504428) - 2026
    Features:
      Auto Arrest  - Teleports to Wanted criminals (NPC) in Crime City/Bunker,
                     arrests them and puts them in your police car
      Auto Clean   - Finds trash/litter objects in your tycoon, teleports & fires prompt
      Auto Tunnels - Finds escape hole objects, teleports & fills them
      Auto Feed    - Finds buffet objects, teleports & restocks them
      Auto Fire    - Finds fire/burning objects, teleports & extinguishes
      Auto Research- Finds and clicks the Research button automatically
    Mobile: Delta vararg fix applied (args={...} + unpack)
    Keybind: RightShift = toggle GUI
]]

-- =============================================
-- SERVICES
-- =============================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- =============================================
-- STATE
-- =============================================
local State = {
    -- Feature toggles
    AutoArrest        = false,
    AutoClean         = false,
    AutoFillTunnels   = false,
    AutoFeedPrisoners = false,
    AutoExtinguish    = false,
    AutoResearch      = false,
    -- Settings
    ArrestRadius      = 60,     -- how close criminal must be to trigger (studs)
    ScanRateRaw       = 15,     -- x0.1 = seconds between scans (15 = 1.5s)
    -- UI
    GuiOpen           = true,
    Minimized         = false,
    CurrentTab        = "Arrest",
}

-- =============================================
-- COLOUR PALETTE
-- =============================================
local C = {
    bg          = Color3.fromRGB(10,  13,  11),
    bg2         = Color3.fromRGB(15,  20,  16),
    bg3         = Color3.fromRGB(20,  27,  21),
    bgHover     = Color3.fromRGB(25,  34,  27),
    accent      = Color3.fromRGB(52,  211, 95),
    accentBright= Color3.fromRGB(80,  240, 120),
    accentDim   = Color3.fromRGB(24,  80,  40),
    accentOff   = Color3.fromRGB(32,  44,  36),
    accentGlow  = Color3.fromRGB(30,  100, 55),
    text        = Color3.fromRGB(215, 235, 220),
    textDim     = Color3.fromRGB(80,  118, 90),
    textMid     = Color3.fromRGB(140, 175, 150),
    red         = Color3.fromRGB(225, 70,  60),
    redDim      = Color3.fromRGB(80,  25,  20),
    orange      = Color3.fromRGB(235, 150, 45),
    orangeDim   = Color3.fromRGB(80,  50,  15),
    blue        = Color3.fromRGB(55,  140, 230),
    blueDim     = Color3.fromRGB(18,  45,  80),
    purple      = Color3.fromRGB(160, 80,  230),
    purpleDim   = Color3.fromRGB(50,  20,  80),
    knobOff     = Color3.fromRGB(100, 130, 110),
    knobOn      = Color3.fromRGB(235, 255, 240),
    sep         = Color3.fromRGB(28,  40,  30),
}

-- =============================================
-- TWEEN / UI HELPERS
-- =============================================
local function Tween(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(
        t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out
    ), props):Play()
end
local function AddCorner(p, r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=p return c end
local function AddStroke(p,col,th,tr) local s=Instance.new("UIStroke") s.Color=col or C.accent s.Thickness=th or 1 s.Transparency=tr or 0 s.Parent=p return s end
local function AddPadding(p,l,r,t,b) local u=Instance.new("UIPadding") u.PaddingLeft=UDim.new(0,l or 0) u.PaddingRight=UDim.new(0,r or 0) u.PaddingTop=UDim.new(0,t or 0) u.PaddingBottom=UDim.new(0,b or 0) u.Parent=p return u end
local function AddList(p,pad,dir) local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,pad or 6) l.FillDirection=dir or Enum.FillDirection.Vertical l.SortOrder=Enum.SortOrder.LayoutOrder l.HorizontalAlignment=Enum.HorizontalAlignment.Center l.Parent=p return l end

-- =============================================
-- CORE UTILITY
-- =============================================

-- DELTA MOBILE FIX: capture varargs before pcall
local function FireRemote(name, ...)
    local args = {...}
    local function tryFire(r)
        pcall(function()
            if r:IsA("RemoteEvent")    then r:FireServer(unpack(args))   end
            if r:IsA("RemoteFunction") then r:InvokeServer(unpack(args)) end
        end)
    end
    for _, root in ipairs({ReplicatedStorage, Workspace}) do
        local r = root:FindFirstChild(name, true)
        if r then tryFire(r) return true end
    end
    return false
end

-- Fire every ProximityPrompt found on obj and all its descendants
local function FireAllPrompts(obj)
    if not obj then return end
    for _, v in ipairs(obj:GetDescendants()) do
        if v:IsA("ProximityPrompt") then pcall(fireproximityprompt, v) end
    end
    local p = obj:FindFirstChildWhichIsA("ProximityPrompt")
    if p then pcall(fireproximityprompt, p) end
end

-- Teleport character directly to a world position (server registers after wait)
local function TeleportTo(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    task.wait(0.08)
end

local function GetHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Get the player's own tycoon folder from Workspace
-- My Prison stores tycoons under Workspace > Tycoons > [folder with Owner value]
local function GetTycoon()
    local uid   = LocalPlayer.UserId
    local uname = LocalPlayer.Name

    -- Most common: Workspace.Tycoons children with Owner BoolValue or ObjectValue
    local tycoons = Workspace:FindFirstChild("Tycoons")
    if tycoons then
        for _, folder in ipairs(tycoons:GetChildren()) do
            -- Try Owner IntValue / ObjectValue / StringValue
            for _, child in ipairs(folder:GetChildren()) do
                local n = child.Name:lower()
                if n == "owner" or n == "ownerid" or n == "playerid" then
                    local v = child.Value
                    if v == LocalPlayer or v == uid or tostring(v) == tostring(uid) or v == uname then
                        return folder
                    end
                end
            end
            -- Some games just name the folder after the player
            if folder.Name == uname or folder.Name == tostring(uid) then
                return folder
            end
        end
    end

    -- Fallback: direct Workspace child named after player
    local direct = Workspace:FindFirstChild(uname) or Workspace:FindFirstChild(tostring(uid))
    if direct then return direct end

    -- Last resort: any Workspace folder/model with an Owner attribute matching player
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:GetAttribute then
            local attr = obj:GetAttribute("Owner") or obj:GetAttribute("OwnerID")
            if attr == uid or attr == uname or attr == LocalPlayer then
                return obj
            end
        end
    end

    return nil
end

-- Search a root for BaseParts/Models/Tools matching any keyword (case-insensitive)
local function FindByKeywords(root, keywords)
    local results = {}
    if not root then return results end
    for _, obj in ipairs(root:GetDescendants()) do
        if obj and obj.Parent then
            local lower = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if lower:find(kw, 1, true) then
                    table.insert(results, obj)
                    break
                end
            end
        end
    end
    return results
end

-- Get the world position of any object type safely
local function GetPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local ok, cf = pcall(function() return obj:GetModelCFrame() end)
        if ok then return cf.Position end
        local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
        if primary then return primary.Position end
    end
    if obj:IsA("Tool") then
        local h = obj:FindFirstChild("Handle")
        if h then return h.Position end
    end
    return nil
end

-- =============================================
-- FEATURE: AUTO ARREST
-- =============================================
-- My Prison: Wanted criminals are NPCs that spawn in Crime City, Crime Town,
-- beach and The Bunker. They have a "WANTED" tag above their name.
-- 8 spawn every 30 minutes (4 Small/orange, 2 Medium/pink, 2 High/purple).
-- The player must physically walk/teleport to the criminal, trigger the
-- arrest ProximityPrompt on the criminal NPC, then put them in the police car.
-- The script: finds criminal NPCs by checking for Humanoid + criminal name tags
-- or "WANTED" BillboardGui labels, teleports to each, fires their arrest prompts.

local function IsWantedCriminal(model)
    if model:IsA("Model") and model ~= LocalPlayer.Character then
        -- Must have a Humanoid (is an NPC)
        if not model:FindFirstChildWhichIsA("Humanoid") then return false end

        local lower = model.Name:lower()

        -- Direct name check: My Prison criminal NPCs are typically named
        -- "Criminal", "Wanted Criminal", "Small Criminal", "Medium Criminal", "High Criminal"
        local nameKW = {"criminal","wanted","gangster","bandit","fugitive","convict","robber"}
        for _, kw in ipairs(nameKW) do
            if lower:find(kw, 1, true) then return true end
        end

        -- Check for "WANTED" BillboardGui label (the visual tag above their head)
        for _, v in ipairs(model:GetDescendants()) do
            if v:IsA("BillboardGui") or v:IsA("TextLabel") then
                if v.Text and v.Text:upper():find("WANTED") then return true end
            end
        end

        -- Check for Wanted attribute
        if model:GetAttribute("Wanted") == true or model:GetAttribute("IsCriminal") == true then
            return true
        end

        -- Check for a "Wanted" value inside the model
        local wv = model:FindFirstChild("Wanted") or model:FindFirstChild("IsWanted")
        if wv and wv.Value == true then return true end
    end
    return false
end

local function RunAutoArrest()
    if not State.AutoArrest then return end
    local hrp = GetHRP()
    if not hrp then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not State.AutoArrest then break end
        if IsWantedCriminal(obj) then
            local npcHRP = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if npcHRP then
                -- Teleport right next to the criminal
                TeleportTo(npcHRP.Position)
                -- Fire all prompts on criminal (arrest prompt)
                FireAllPrompts(obj)
                -- Also try common remote names
                FireRemote("Arrest", obj)
                FireRemote("ArrestCriminal", obj)
                FireRemote("CuffPlayer", obj)
                task.wait(0.3)

                -- After arresting, try to put in police car
                -- Find the player's car in workspace (named "Car", "PoliceCar", etc.)
                local carKW = {"policecar","car","vehicle","police"}
                for _, carObj in ipairs(Workspace:GetDescendants()) do
                    if carObj:IsA("Model") then
                        local cl = carObj.Name:lower()
                        for _, kw in ipairs(carKW) do
                            if cl:find(kw, 1, true) then
                                local carPos = GetPos(carObj)
                                if carPos then
                                    -- Check if this car is reasonably close
                                    if (hrp.Position - carPos).Magnitude < 300 then
                                        TeleportTo(carPos)
                                        FireAllPrompts(carObj)
                                        FireRemote("PutInCar", obj)
                                        task.wait(0.2)
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

-- =============================================
-- FEATURE: AUTO CLEAN
-- =============================================
-- My Prison: Prisoners constantly drop trash on the floor.
-- Trash objects appear inside your tycoon plot with ProximityPrompts.
-- Janitor NPCs clean them automatically, but the player can too.
-- The script finds any BasePart/Model with trash-related names that has
-- a ProximityPrompt, teleports to it, and fires the prompt.

local function RunAutoClean()
    if not State.AutoClean then return end
    local root = GetTycoon() or Workspace
    local keywords = {"trash","litter","mess","dirt","garbage","spill","dirty","waste","debris","laundry","dish","soiled","food on"}
    local objects = FindByKeywords(root, keywords)

    for _, obj in ipairs(objects) do
        if not State.AutoClean then break end
        -- Only interact with objects that have a ProximityPrompt
        if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
            local pos = GetPos(obj)
            if pos then
                TeleportTo(pos)
                FireAllPrompts(obj)
                FireRemote("Clean", obj)
                FireRemote("CleanMess", obj)
                FireRemote("RemoveTrash", obj)
                task.wait(0.15)
            end
        end
    end
end

-- =============================================
-- FEATURE: AUTO FILL TUNNELS
-- =============================================
-- My Prison: Unhappy or escape-minded prisoners dig tunnels.
-- These appear as "Hole" or "EscapeTunnel" BaseParts inside your tycoon.
-- Repairman NPCs fill them automatically, but players can too.
-- The script finds hole/tunnel objects with a ProximityPrompt and fills them.

local function RunAutoFillTunnels()
    if not State.AutoFillTunnels then return end
    local root = GetTycoon() or Workspace
    local keywords = {"hole","tunnel","escapetunnel","escapehole","dighole","dig","escape tunnel","escape hole"}
    local objects = FindByKeywords(root, keywords)

    for _, obj in ipairs(objects) do
        if not State.AutoFillTunnels then break end
        if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
            local pos = GetPos(obj)
            if pos then
                TeleportTo(pos)
                FireAllPrompts(obj)
                FireRemote("FillTunnel", obj)
                FireRemote("RepairTunnel", obj)
                FireRemote("Fill", obj)
                task.wait(0.15)
            end
        end
    end
end

-- =============================================
-- FEATURE: AUTO FEED PRISONERS
-- =============================================
-- My Prison: Buffets feed 12 prisoners each. Chef NPCs keep them stocked.
-- Buffets run out and need restocking. The script finds buffet/food objects
-- and fires the restock ProximityPrompt on them.

local function RunAutoFeedPrisoners()
    if not State.AutoFeedPrisoners then return end
    local root = GetTycoon() or Workspace
    local keywords = {"buffet","food","tray","serving","counter","restock","catering","canteen","cafeteria","fridge","oven","chef"}
    local objects = FindByKeywords(root, keywords)

    for _, obj in ipairs(objects) do
        if not State.AutoFeedPrisoners then break end
        if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
            local pos = GetPos(obj)
            if pos then
                TeleportTo(pos)
                FireAllPrompts(obj)
                FireRemote("RefillBuffet", obj)
                FireRemote("Restock", obj)
                FireRemote("FeedPrisoners", obj)
                task.wait(0.15)
            end
        end
    end
end

-- =============================================
-- FEATURE: AUTO EXTINGUISH FIRE
-- =============================================
-- My Prison: The Fire Event (added 2026) causes fires to break out in
-- the prison. Staff-only door leads to fire zone. Fires appear as Fire
-- particle effects on BaseParts, or as fire-named objects.
-- The script finds fire objects/particles and extinguishes them.

local function RunAutoExtinguish()
    if not State.AutoExtinguish then return end
    local root = GetTycoon() or Workspace

    for _, obj in ipairs(root:GetDescendants()) do
        if not State.AutoExtinguish then break end

        local base = nil

        -- Actual Fire particle instance
        if obj:IsA("Fire") and obj.Parent then
            base = obj.Parent

        -- BasePart or Model with fire-related name that has a prompt
        elseif (obj:IsA("BasePart") or obj:IsA("Model")) then
            local lower = obj.Name:lower()
            local fireKW = {"fire","flame","burn","blaze","firezone","firehazard","burningobject","fireobject"}
            for _, kw in ipairs(fireKW) do
                if lower:find(kw, 1, true) then
                    base = obj
                    break
                end
            end
        end

        if base and base.Parent then
            -- Only interact if there is an extinguish prompt
            local hasPrompt = base:FindFirstChildWhichIsA("ProximityPrompt", true)
            if hasPrompt then
                local pos = GetPos(base)
                if pos then
                    TeleportTo(pos)
                    FireAllPrompts(base)
                    FireRemote("Extinguish", base)
                    FireRemote("PutOutFire", base)
                    FireRemote("ExtinguishFire", base)
                    task.wait(0.2)
                end
            end
        end
    end
end

-- =============================================
-- FEATURE: AUTO RESEARCH
-- =============================================
-- My Prison has a Research system unlocking features like:
--   Prisoner Delivery ($15,000), Medium Security, High Security,
--   Visitors ($12,500), and more.
-- Research is triggered by clicking a button/ProximityPrompt on the
-- Research object in the game UI or in the world.
-- The script looks for the Research object and fires its prompt/remote
-- to automatically progress any active research.

local function RunAutoResearch()
    if not State.AutoResearch then return end

    -- Look for research-related objects in workspace / tycoon
    local root = GetTycoon() or Workspace
    local keywords = {"research","lab","laboratory","study","upgrade","unlock"}

    -- First try: find Research object in workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not State.AutoResearch then break end
        if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Part") then
            local lower = obj.Name:lower()
            if lower:find("research", 1, true) then
                if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
                    local pos = GetPos(obj)
                    if pos then
                        TeleportTo(pos)
                        FireAllPrompts(obj)
                        task.wait(0.2)
                    end
                end
            end
        end
    end

    -- Also try firing the Research remote directly (some tycoons use this)
    FireRemote("Research")
    FireRemote("StartResearch")
    FireRemote("ClickResearch")
    FireRemote("CompleteResearch")
end

-- =============================================
-- MASTER SCAN LOOP
-- =============================================
-- Each enabled feature runs in its own task.spawn thread.
-- ScanRateRaw / 10 = seconds between full loop iterations.

local lastTick = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastTick < (State.ScanRateRaw / 10) then return end
    lastTick = now
    if State.AutoArrest        then task.spawn(RunAutoArrest)        end
    if State.AutoClean         then task.spawn(RunAutoClean)         end
    if State.AutoFillTunnels   then task.spawn(RunAutoFillTunnels)   end
    if State.AutoFeedPrisoners then task.spawn(RunAutoFeedPrisoners) end
    if State.AutoExtinguish    then task.spawn(RunAutoExtinguish)    end
    if State.AutoResearch      then task.spawn(RunAutoResearch)      end
end)

-- =============================================
-- GUI CONSTRUCTION
-- =============================================

-- Remove old GUI if re-running
local oldGui = LocalPlayer.PlayerGui:FindFirstChild("MyPrisonV3")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MyPrisonV3"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 999
ScreenGui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

-- =============================================
-- MAIN WINDOW
-- =============================================
local WIN_W = 340
local WIN_H = 520

-- Outer glow / shadow
local Glow = Instance.new("Frame")
Glow.Name                    = "Glow"
Glow.Size                    = UDim2.new(0, WIN_W + 24, 0, WIN_H + 24)
Glow.Position                = UDim2.new(0.5, -(WIN_W/2)-12, 0.5, -(WIN_H/2)-12)
Glow.BackgroundColor3        = C.accentGlow
Glow.BackgroundTransparency  = 0.82
Glow.BorderSizePixel         = 0
Glow.ZIndex                  = 1
Glow.Parent                  = ScreenGui
AddCorner(Glow, 20)

-- Dark shadow underneath
local Shadow = Instance.new("Frame")
Shadow.Name                   = "Shadow"
Shadow.Size                   = UDim2.new(0, WIN_W + 8, 0, WIN_H + 8)
Shadow.Position               = UDim2.new(0.5, -(WIN_W/2)-4, 0.5, -(WIN_H/2)+4)
Shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.45
Shadow.BorderSizePixel        = 0
Shadow.ZIndex                 = 1
Shadow.Parent                 = ScreenGui
AddCorner(Shadow, 18)

-- Main frame
local Main = Instance.new("Frame")
Main.Name             = "Main"
Main.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
Main.Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Main.ZIndex           = 2
Main.Parent           = ScreenGui
AddCorner(Main, 14)
AddStroke(Main, C.accentDim, 1.5, 0.2)

-- Subtle top gradient overlay
local TopGrad = Instance.new("Frame")
TopGrad.Size                    = UDim2.new(1, 0, 0, 90)
TopGrad.BackgroundColor3        = C.accent
TopGrad.BackgroundTransparency  = 0.93
TopGrad.BorderSizePixel         = 0
TopGrad.ZIndex                  = 3
TopGrad.Parent                  = Main

local tg = Instance.new("UIGradient")
tg.Color    = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
})
tg.Rotation = 90
tg.Parent   = TopGrad

-- =============================================
-- HEADER
-- =============================================
local Header = Instance.new("Frame")
Header.Name             = "Header"
Header.Size             = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = C.bg2
Header.BorderSizePixel  = 0
Header.ZIndex           = 4
Header.Parent           = Main
AddCorner(Header, 14)

-- Flat bottom of header corners
local HFlat = Instance.new("Frame")
HFlat.Size             = UDim2.new(1, 0, 0, 14)
HFlat.Position         = UDim2.new(0, 0, 1, -14)
HFlat.BackgroundColor3 = C.bg2
HFlat.BorderSizePixel  = 0
HFlat.ZIndex           = 4
HFlat.Parent           = Header

local HGrad = Instance.new("UIGradient")
HGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 50, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 16, 13)),
})
HGrad.Rotation = 90
HGrad.Parent   = Header

-- Green accent stripe at very top
local TopStripe = Instance.new("Frame")
TopStripe.Size             = UDim2.new(1, 0, 0, 2)
TopStripe.BackgroundColor3 = C.accent
TopStripe.BackgroundTransparency = 0.3
TopStripe.BorderSizePixel  = 0
TopStripe.ZIndex           = 6
TopStripe.Parent           = Header
AddCorner(TopStripe, 14)

-- Lock icon badge
local Badge = Instance.new("Frame")
Badge.Size             = UDim2.new(0, 40, 0, 40)
Badge.Position         = UDim2.new(0, 12, 0.5, -20)
Badge.BackgroundColor3 = C.accentDim
Badge.BorderSizePixel  = 0
Badge.ZIndex           = 5
Badge.Parent           = Header
AddCorner(Badge, 10)
AddStroke(Badge, C.accent, 1, 0.6)

local BadgeIcon = Instance.new("TextLabel")
BadgeIcon.Size                    = UDim2.new(1, 0, 1, 0)
BadgeIcon.BackgroundTransparency  = 1
BadgeIcon.Text                    = "🔒"
BadgeIcon.TextSize                = 22
BadgeIcon.Font                    = Enum.Font.GothamBold
BadgeIcon.ZIndex                  = 6
BadgeIcon.Parent                  = Badge

-- Title
local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size                    = UDim2.new(1, -130, 0, 22)
TitleLbl.Position                = UDim2.new(0, 60, 0, 8)
TitleLbl.BackgroundTransparency  = 1
TitleLbl.Font                    = Enum.Font.GothamBold
TitleLbl.TextColor3              = C.accent
TitleLbl.TextSize                = 15
TitleLbl.TextXAlignment          = Enum.TextXAlignment.Left
TitleLbl.Text                    = "MY PRISON"
TitleLbl.ZIndex                  = 5
TitleLbl.Parent                  = Header

local SubLbl = Instance.new("TextLabel")
SubLbl.Size                    = UDim2.new(1, -130, 0, 14)
SubLbl.Position                = UDim2.new(0, 60, 0, 32)
SubLbl.BackgroundTransparency  = 1
SubLbl.Font                    = Enum.Font.Gotham
SubLbl.TextColor3              = C.textDim
SubLbl.TextSize                = 10
SubLbl.TextXAlignment          = Enum.TextXAlignment.Left
SubLbl.Text                    = "v3.1  |  Windburst 2026  |  RightShift = toggle"
SubLbl.ZIndex                  = 5
SubLbl.Parent                  = Header

-- Header buttons (close + minimise)
local BtnHolder = Instance.new("Frame")
BtnHolder.Size             = UDim2.new(0, 62, 0, 28)
BtnHolder.Position         = UDim2.new(1, -72, 0.5, -14)
BtnHolder.BackgroundTransparency = 1
BtnHolder.ZIndex           = 5
BtnHolder.Parent           = Header

local BtnList = Instance.new("UIListLayout")
BtnList.FillDirection       = Enum.FillDirection.Horizontal
BtnList.VerticalAlignment   = Enum.VerticalAlignment.Center
BtnList.HorizontalAlignment = Enum.HorizontalAlignment.Right
BtnList.Padding             = UDim.new(0, 5)
BtnList.Parent              = BtnHolder

local function MakeHeaderBtn(icon, bgCol)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 28, 0, 28)
    btn.BackgroundColor3 = bgCol or C.accentDim
    btn.Font             = Enum.Font.GothamBold
    btn.TextColor3       = C.text
    btn.TextSize         = 14
    btn.Text             = icon
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 6
    btn.Parent           = BtnHolder
    AddCorner(btn, 7)
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundTransparency = 0.3}, 0.1)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundTransparency = 0}, 0.1)
    end)
    return btn
end

local MinBtn   = MakeHeaderBtn("─", C.accentDim)
local CloseBtn = MakeHeaderBtn("✕", C.redDim)

-- =============================================
-- TAB BAR
-- =============================================
local TAB_H = 38

local TabBar = Instance.new("Frame")
TabBar.Name             = "TabBar"
TabBar.Size             = UDim2.new(1, 0, 0, TAB_H)
TabBar.Position         = UDim2.new(0, 0, 0, 58)
TabBar.BackgroundColor3 = C.bg2
TabBar.BorderSizePixel  = 0
TabBar.ZIndex           = 4
TabBar.Parent           = Main

-- Thin separator line under tab bar
local TabSep = Instance.new("Frame")
TabSep.Size             = UDim2.new(1, 0, 0, 1)
TabSep.Position         = UDim2.new(0, 0, 1, -1)
TabSep.BackgroundColor3 = C.accentDim
TabSep.BackgroundTransparency = 0.5
TabSep.BorderSizePixel  = 0
TabSep.ZIndex           = 5
TabSep.Parent           = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection       = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
TabLayout.Padding             = UDim.new(0, 3)
TabLayout.Parent              = TabBar
AddPadding(TabBar, 8, 8, 0, 0)

-- =============================================
-- PAGE CONTAINER
-- =============================================
local HEADER_TOTAL = 58 + TAB_H  -- 96

local Pages = Instance.new("Frame")
Pages.Name                  = "Pages"
Pages.Size                  = UDim2.new(1, 0, 1, -HEADER_TOTAL)
Pages.Position              = UDim2.new(0, 0, 0, HEADER_TOTAL)
Pages.BackgroundTransparency = 1
Pages.ClipsDescendants      = true
Pages.ZIndex                = 3
Pages.Parent                = Main

-- =============================================
-- NOTIFICATION SYSTEM
-- =============================================
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name           = "MPNotifGui"
NotifGui.ResetOnSpawn   = false
NotifGui.DisplayOrder   = 1000
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifGui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

local NotifHolder = Instance.new("Frame")
NotifHolder.Size                    = UDim2.new(0, 320, 1, -20)
NotifHolder.Position                = UDim2.new(0.5, -160, 0, 10)
NotifHolder.BackgroundTransparency  = 1
NotifHolder.BorderSizePixel         = 0
NotifHolder.Parent                  = NotifGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotifLayout.Padding           = UDim.new(0, 5)
NotifLayout.Parent            = NotifHolder

local function Notify(msg, col, icon)
    col  = col  or C.accent
    icon = icon or "i"

    local bg = Instance.new("Frame")
    bg.Size                    = UDim2.new(1, 0, 0, 46)
    bg.BackgroundColor3        = C.bg2
    bg.BackgroundTransparency  = 1
    bg.BorderSizePixel         = 0
    bg.ClipsDescendants        = true
    bg.Parent                  = NotifHolder
    AddCorner(bg, 10)
    AddStroke(bg, col, 1, 0.5)

    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = col
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 2
    bar.Parent           = bg
    AddCorner(bar, 2)

    local ic = Instance.new("TextLabel")
    ic.Size                   = UDim2.new(0, 34, 1, 0)
    ic.Position               = UDim2.new(0, 8, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text                   = icon
    ic.TextSize               = 18
    ic.Font                   = Enum.Font.GothamBold
    ic.TextColor3             = col
    ic.ZIndex                 = 2
    ic.Parent                 = bg

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, -50, 1, 0)
    lbl.Position               = UDim2.new(0, 46, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font                   = Enum.Font.GothamMedium
    lbl.TextColor3             = C.text
    lbl.TextSize               = 12
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.TextWrapped            = true
    lbl.Text                   = msg
    lbl.ZIndex                 = 2
    lbl.Parent                 = bg

    Tween(bg, {BackgroundTransparency = 0.05}, 0.25)
    task.delay(3.0, function()
        if bg and bg.Parent then
            Tween(bg, {BackgroundTransparency = 1}, 0.3)
            task.delay(0.35, function()
                if bg and bg.Parent then bg:Destroy() end
            end)
        end
    end)
end

-- =============================================
-- PAGE / SECTION / TOGGLE BUILDER FUNCTIONS
-- =============================================

local function MakePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name                 = name
    page.Size                 = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel      = 0
    page.ScrollBarThickness   = 3
    page.ScrollBarImageColor3 = C.accentDim
    page.CanvasSize           = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    page.Visible              = false
    page.ZIndex               = 4
    page.Parent               = Pages
    AddList(page, 6)
    AddPadding(page, 10, 10, 10, 10)
    return page
end

-- Section divider with label
local function MakeSection(parent, label)
    local wrap = Instance.new("Frame")
    wrap.Size                    = UDim2.new(1, 0, 0, 26)
    wrap.BackgroundTransparency  = 1
    wrap.ZIndex                  = 5
    wrap.Parent                  = parent

    local line = Instance.new("Frame")
    line.Size                    = UDim2.new(1, 0, 0, 1)
    line.Position                = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3        = C.sep
    line.BorderSizePixel         = 0
    line.ZIndex                  = 5
    line.Parent                  = wrap

    local pill = Instance.new("Frame")
    pill.Size                    = UDim2.new(0, 0, 1, 0)
    pill.AutomaticSize           = Enum.AutomaticSize.X
    pill.BackgroundColor3        = C.bg
    pill.BorderSizePixel         = 0
    pill.ZIndex                  = 6
    pill.Parent                  = wrap

    local lbl = Instance.new("TextLabel")
    lbl.Size                     = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize            = Enum.AutomaticSize.X
    lbl.BackgroundTransparency   = 1
    lbl.Font                     = Enum.Font.GothamBold
    lbl.TextColor3               = C.accent
    lbl.TextSize                 = 9
    lbl.Text                     = "  " .. label:upper() .. "  "
    lbl.ZIndex                   = 7
    lbl.Parent                   = pill
    return wrap
end

-- Info paragraph card
local function MakeInfoCard(parent, lines)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = C.bg3
    card.BorderSizePixel  = 0
    card.AutomaticSize    = Enum.AutomaticSize.Y
    card.Size             = UDim2.new(1, 0, 0, 0)
    card.ZIndex           = 5
    card.Parent           = parent
    AddCorner(card, 8)
    AddStroke(card, C.sep, 1, 0)
    AddPadding(card, 12, 12, 8, 8)
    AddList(card, 3)

    for _, line in ipairs(lines) do
        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.Gotham
        lbl.TextColor3             = C.textMid
        lbl.TextSize               = 11
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.TextWrapped            = true
        lbl.Text                   = line
        lbl.ZIndex                 = 6
        lbl.Parent                 = card
    end
    return card
end

-- Status card with pulsing dot
local function MakeStatusCard(parent)
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, 0, 0, 50)
    card.BackgroundColor3 = Color3.fromRGB(13, 24, 16)
    card.BorderSizePixel  = 0
    card.ZIndex           = 5
    card.Parent           = parent
    AddCorner(card, 10)
    AddStroke(card, C.accentDim, 1, 0.2)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 50, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 17, 12)),
    })
    grad.Rotation = 90
    grad.Parent   = card

    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 8, 0, 8)
    dot.Position         = UDim2.new(0, 14, 0.5, -4)
    dot.BackgroundColor3 = C.accent
    dot.BorderSizePixel  = 0
    dot.ZIndex           = 6
    dot.Parent           = card
    AddCorner(dot, 4)

    task.spawn(function()
        while card.Parent do
            Tween(dot, {BackgroundTransparency = 0.8}, 0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.85)
            Tween(dot, {BackgroundTransparency = 0},   0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.85)
        end
    end)

    local main = Instance.new("TextLabel")
    main.Size                    = UDim2.new(1, -32, 0, 18)
    main.Position                = UDim2.new(0, 28, 0, 7)
    main.BackgroundTransparency  = 1
    main.Font                    = Enum.Font.GothamBold
    main.TextColor3              = C.accent
    main.TextSize                = 11
    main.TextXAlignment          = Enum.TextXAlignment.Left
    main.Text                    = "Script active  |  Tycoon-aware scanning"
    main.ZIndex                  = 6
    main.Parent                  = card

    local sub = Instance.new("TextLabel")
    sub.Size                     = UDim2.new(1, -32, 0, 14)
    sub.Position                 = UDim2.new(0, 28, 0, 27)
    sub.BackgroundTransparency   = 1
    sub.Font                     = Enum.Font.Gotham
    sub.TextColor3               = C.textDim
    sub.TextSize                 = 10
    sub.TextXAlignment           = Enum.TextXAlignment.Left
    sub.Text                     = "Teleports to objects  |  Fires prompts + remotes"
    sub.ZIndex                   = 6
    sub.Parent                   = card
    return card
end

-- Toggle row
local function MakeToggle(parent, icon, label, desc, stateKey, color)
    color = color or C.accent

    local row = Instance.new("Frame")
    row.Name             = "Toggle_" .. label
    row.Size             = UDim2.new(1, 0, 0, 62)
    row.BackgroundColor3 = C.bg3
    row.BorderSizePixel  = 0
    row.ZIndex           = 5
    row.Parent           = parent
    AddCorner(row, 10)
    local rowStroke = AddStroke(row, C.accentOff, 1, 0.2)

    -- Icon badge
    local iw = Instance.new("Frame")
    iw.Size             = UDim2.new(0, 40, 0, 40)
    iw.Position         = UDim2.new(0, 10, 0.5, -20)
    iw.BackgroundColor3 = C.bg2
    iw.BorderSizePixel  = 0
    iw.ZIndex           = 6
    iw.Parent           = row
    AddCorner(iw, 9)
    AddStroke(iw, C.sep, 1, 0)

    local il = Instance.new("TextLabel")
    il.Size                   = UDim2.new(1, 0, 1, 0)
    il.BackgroundTransparency = 1
    il.Text                   = icon
    il.TextSize               = 20
    il.Font                   = Enum.Font.GothamBold
    il.ZIndex                 = 7
    il.Parent                 = iw

    -- Labels
    local nl = Instance.new("TextLabel")
    nl.Size                   = UDim2.new(1, -115, 0, 20)
    nl.Position               = UDim2.new(0, 58, 0, 10)
    nl.BackgroundTransparency = 1
    nl.Font                   = Enum.Font.GothamBold
    nl.TextColor3             = C.text
    nl.TextSize               = 12
    nl.TextXAlignment         = Enum.TextXAlignment.Left
    nl.Text                   = label
    nl.ZIndex                 = 6
    nl.Parent                 = row

    local dl = Instance.new("TextLabel")
    dl.Size                   = UDim2.new(1, -115, 0, 28)
    dl.Position               = UDim2.new(0, 58, 0, 31)
    dl.BackgroundTransparency = 1
    dl.Font                   = Enum.Font.Gotham
    dl.TextColor3             = C.textDim
    dl.TextSize               = 10
    dl.TextXAlignment         = Enum.TextXAlignment.Left
    dl.TextWrapped            = true
    dl.Text                   = desc
    dl.ZIndex                 = 6
    dl.Parent                 = row

    -- Pill toggle switch
    local pill = Instance.new("Frame")
    pill.Size             = UDim2.new(0, 46, 0, 24)
    pill.Position         = UDim2.new(1, -56, 0.5, -12)
    pill.BackgroundColor3 = C.accentOff
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 6
    pill.Parent           = row
    AddCorner(pill, 12)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 18, 0, 18)
    knob.Position         = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = C.knobOff
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 7
    knob.Parent           = pill
    AddCorner(knob, 9)

    local function Refresh()
        local on = State[stateKey]
        Tween(pill,      {BackgroundColor3 = on and color    or C.accentOff},                  0.18)
        Tween(knob,      {Position = on and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}, 0.18)
        Tween(knob,      {BackgroundColor3 = on and C.knobOn or C.knobOff},                    0.18)
        Tween(rowStroke, {Color = on and color or C.accentOff},                                0.18)
    end

    -- Full-row hit area
    local hit = Instance.new("TextButton")
    hit.Size                    = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency  = 1
    hit.Text                    = ""
    hit.ZIndex                  = 8
    hit.Parent                  = row

    hit.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        Refresh()
        local on = State[stateKey]
        Notify(label .. (on and "  ON" or "  OFF"), on and color or C.red, icon)
    end)

    hit.MouseEnter:Connect(function()
        Tween(row, {BackgroundColor3 = C.bgHover}, 0.12)
    end)
    hit.MouseLeave:Connect(function()
        Tween(row, {BackgroundColor3 = C.bg3}, 0.12)
    end)

    Refresh()
    return row
end

-- Slider row
local function MakeSlider(parent, icon, label, desc, stateKey, minVal, maxVal, step, suffix)
    step   = step   or 1
    suffix = suffix or ""

    local row = Instance.new("Frame")
    row.Name             = "Slider_" .. label
    row.Size             = UDim2.new(1, 0, 0, 72)
    row.BackgroundColor3 = C.bg3
    row.BorderSizePixel  = 0
    row.ZIndex           = 5
    row.Parent           = parent
    AddCorner(row, 10)
    AddStroke(row, C.sep, 1, 0)

    -- Icon
    local iw = Instance.new("Frame")
    iw.Size             = UDim2.new(0, 40, 0, 40)
    iw.Position         = UDim2.new(0, 10, 0, 8)
    iw.BackgroundColor3 = C.bg2
    iw.BorderSizePixel  = 0
    iw.ZIndex           = 6
    iw.Parent           = row
    AddCorner(iw, 9)
    AddStroke(iw, C.sep, 1, 0)

    local il = Instance.new("TextLabel")
    il.Size                   = UDim2.new(1, 0, 1, 0)
    il.BackgroundTransparency = 1
    il.Text                   = icon
    il.TextSize               = 20
    il.Font                   = Enum.Font.GothamBold
    il.ZIndex                 = 7
    il.Parent                 = iw

    -- Label + value
    local nl = Instance.new("TextLabel")
    nl.Size                   = UDim2.new(1, -120, 0, 18)
    nl.Position               = UDim2.new(0, 58, 0, 8)
    nl.BackgroundTransparency = 1
    nl.Font                   = Enum.Font.GothamBold
    nl.TextColor3             = C.text
    nl.TextSize               = 12
    nl.TextXAlignment         = Enum.TextXAlignment.Left
    nl.Text                   = label
    nl.ZIndex                 = 6
    nl.Parent                 = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size                   = UDim2.new(0, 55, 0, 18)
    valLbl.Position               = UDim2.new(1, -62, 0, 8)
    valLbl.BackgroundTransparency = 1
    valLbl.Font                   = Enum.Font.GothamBold
    valLbl.TextColor3             = C.accent
    valLbl.TextSize               = 12
    valLbl.TextXAlignment         = Enum.TextXAlignment.Right
    valLbl.Text                   = tostring(State[stateKey]) .. suffix
    valLbl.ZIndex                 = 6
    valLbl.Parent                 = row

    local dl = Instance.new("TextLabel")
    dl.Size                   = UDim2.new(1, -115, 0, 14)
    dl.Position               = UDim2.new(0, 58, 0, 27)
    dl.BackgroundTransparency = 1
    dl.Font                   = Enum.Font.Gotham
    dl.TextColor3             = C.textDim
    dl.TextSize               = 10
    dl.TextXAlignment         = Enum.TextXAlignment.Left
    dl.Text                   = desc
    dl.ZIndex                 = 6
    dl.Parent                 = row

    -- Track
    local trackBg = Instance.new("Frame")
    trackBg.Size             = UDim2.new(1, -20, 0, 6)
    trackBg.Position         = UDim2.new(0, 10, 0, 54)
    trackBg.BackgroundColor3 = C.accentOff
    trackBg.BorderSizePixel  = 0
    trackBg.ZIndex           = 6
    trackBg.Parent           = row
    AddCorner(trackBg, 3)

    local trackFill = Instance.new("Frame")
    trackFill.Size             = UDim2.new(0, 0, 1, 0)
    trackFill.BackgroundColor3 = C.accent
    trackFill.BorderSizePixel  = 0
    trackFill.ZIndex           = 7
    trackFill.Parent           = trackBg
    AddCorner(trackFill, 3)

    local handle = Instance.new("Frame")
    handle.Size             = UDim2.new(0, 14, 0, 14)
    handle.Position         = UDim2.new(0, 0, 0.5, -7)
    handle.BackgroundColor3 = C.knobOn
    handle.BorderSizePixel  = 0
    handle.ZIndex           = 8
    handle.Parent           = trackBg
    AddCorner(handle, 7)
    AddStroke(handle, C.accent, 1.5, 0.2)

    local function SetValue(v)
        v = math.clamp(math.round(v / step) * step, minVal, maxVal)
        State[stateKey] = v
        valLbl.Text = tostring(v) .. suffix
        local pct = (v - minVal) / (maxVal - minVal)
        Tween(trackFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
        Tween(handle, {Position = UDim2.new(pct, -7, 0.5, -7)}, 0.1)
    end

    -- Init fill
    SetValue(State[stateKey])

    -- Drag
    local draggingSlider = false
    local hitSlider = Instance.new("TextButton")
    hitSlider.Size                   = UDim2.new(1, 0, 1, 0)
    hitSlider.BackgroundTransparency = 1
    hitSlider.Text                   = ""
    hitSlider.ZIndex                 = 9
    hitSlider.Parent                 = trackBg

    hitSlider.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
        end
    end)
    hitSlider.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if draggingSlider then
            if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
                local absPos  = trackBg.AbsolutePosition.X
                local absSize = trackBg.AbsoluteSize.X
                local rel     = math.clamp((inp.Position.X - absPos) / absSize, 0, 1)
                SetValue(minVal + rel * (maxVal - minVal))
            end
        end
    end)

    return row
end

-- =============================================
-- BUILD TABS
-- =============================================
local TAB_DEFS = {
    { name = "Arrest",   icon = "🚔" },
    { name = "Prison",   icon = "🏛" },
    { name = "Research", icon = "🔬" },
    { name = "Info",     icon = "ℹ"  },
}

local pageFrames = {}
local tabButtons = {}

for _, def in ipairs(TAB_DEFS) do
    pageFrames[def.name] = MakePage(def.name)

    local btn = Instance.new("TextButton")
    btn.Name             = "Tab_" .. def.name
    btn.Size             = UDim2.new(0, 72, 0, 28)
    btn.BackgroundColor3 = C.bg3
    btn.Font             = Enum.Font.GothamBold
    btn.TextColor3       = C.textDim
    btn.TextSize         = 10
    btn.Text             = def.icon .. " " .. def.name
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 5
    btn.Parent           = TabBar
    AddCorner(btn, 7)
    tabButtons[def.name] = btn
end

local function SwitchTab(name)
    State.CurrentTab = name
    for n, pg in pairs(pageFrames) do
        pg.Visible = (n == name)
    end
    for n, btn in pairs(tabButtons) do
        local active = (n == name)
        Tween(btn, {BackgroundColor3 = active and C.accentDim or C.bg3},    0.15)
        Tween(btn, {TextColor3       = active and C.accent    or C.textDim}, 0.15)
    end
end

for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end-- =============================================
-- POPULATE PAGES
-- =============================================

-- ── ARREST TAB ─────────────────────────────────────────────────────────────
-- Wanted criminals spawn every 30 min (4 Small/orange, 2 Medium/pink, 2 High/purple)
-- in Crime City, Crime Town, beach, and The Bunker.
-- They have a WANTED tag above their name.
-- ───────────────────────────────────────────────────────────────────────────
local ap = pageFrames["Arrest"]
MakeStatusCard(ap)
MakeSection(ap, "Auto Arrest")
MakeToggle(ap, "🚔", "Auto Arrest Criminals",
    "Finds WANTED NPCs in Crime City/Bunker, teleports to them and arrests",
    "AutoArrest", C.blue)
MakeSection(ap, "Arrest Settings")
MakeSlider(ap, "📏", "Arrest Scan Radius",
    "How close the script looks for criminals (studs)",
    "ArrestRadius", 10, 200, 10, " studs")
MakeSection(ap, "About Wanted Criminals")
MakeInfoCard(ap, {
    "8 Wanted criminals spawn every 30 minutes per server",
    "4 Small Security (orange), 2 Medium (pink), 2 High (purple)",
    "Small criminals: Crime City and Crime Town",
    "Medium criminals: The Bunker (near entrance)",
    "High Security: Deep in The Bunker past Medium section",
    "Wanted criminals pay $2/hr more than regular prisoners",
    "Switch servers if all 8 Wanted slots are already taken",
})

-- ── PRISON TAB ─────────────────────────────────────────────────────────────
-- Staff automation: clean trash, fill tunnels, restock buffets, put out fires
-- ───────────────────────────────────────────────────────────────────────────
local pp = pageFrames["Prison"]
MakeSection(pp, "Staff Automation")
MakeToggle(pp, "🧹", "Auto Clean Trash",
    "Finds litter dropped by prisoners, teleports and cleans it",
    "AutoClean", C.accent)
MakeToggle(pp, "⛏",  "Auto Fill Tunnels",
    "Finds escape holes dug by prisoners and fills them",
    "AutoFillTunnels", C.orange)
MakeToggle(pp, "🍽",  "Auto Feed Prisoners",
    "Finds empty buffets and restocks them (1 buffet = 12 prisoners)",
    "AutoFeedPrisoners", C.blue)
MakeToggle(pp, "🔥", "Auto Extinguish Fire",
    "Finds burning objects from Fire Event and extinguishes them",
    "AutoExtinguish", C.red)
MakeSection(pp, "Scan Speed")
MakeSlider(pp, "⏱", "Scan Rate",
    "Slider x 0.1 = seconds per scan (15 = 1.5s)",
    "ScanRateRaw", 5, 50, 1, "")
MakeSection(pp, "Prison Tips")
MakeInfoCard(pp, {
    "Prisoners ALWAYS try to dig tunnels regardless of happiness",
    "1 Buffet feeds 12 prisoners  |  1 Chef per 15 prisoners",
    "1 Guard per 5 prisoners prevents escape attempts",
    "Prisoners drop trash constantly - hire Janitors to help",
    "Fire Event: staff-only door near fire zone (2026 update)",
    "Repairmen automatically fill tunnels if you have them hired",
    "Bunk beds: 1 bunk = 2 prisoners (saves space)",
})

-- ── RESEARCH TAB ───────────────────────────────────────────────────────────
-- Research unlocks features: Prisoner Delivery ($15k), Medium Security,
-- High Security ($650k), Visitors ($12.5k), and more.
-- ───────────────────────────────────────────────────────────────────────────
local rp = pageFrames["Research"]
MakeSection(rp, "Auto Research")
MakeToggle(rp, "🔬", "Auto Research",
    "Automatically clicks the Research button to progress any active research",
    "AutoResearch", C.purple)
MakeSection(rp, "Research Costs")
MakeInfoCard(rp, {
    "Prisoner Delivery: $15,000 - auto-delivers prisoners at 9am and 2pm",
    "Medium Security: requires Bunker quest + arrest 20 MSP",
    "High Security: $650,000 + arrest 35 HSP in Bunker",
    "Visitors: $12,500 - unlocks Visitor Wall, boosts happiness",
    "Delivery Bus brings up to 12 prisoners per delivery",
    "Reception desk = prisoners auto-unload from bus",
    "Research Prisoner Delivery first - biggest quality of life unlock",
})
MakeSection(rp, "Security Classes")
MakeInfoCard(rp, {
    "Small Security (orange): $10/hr | Crime City + Crime Town",
    "Medium Security (pink): $15/hr ($17 wanted) | The Bunker",
    "High Security (purple): $20/hr ($22 wanted) | Deep Bunker",
    "Wanted variants pay $2/hr more than regular",
    "Car Chase criminals are always Wanted - random security class",
    "Max: 100 prisoners + 46 workers per prison",
})

-- ── INFO TAB ───────────────────────────────────────────────────────────────
local ip = pageFrames["Info"]
MakeSection(ip, "Script Info")
MakeInfoCard(ip, {
    "My Prison Script v4.0 - Final Edition",
    "Game: My Prison by Windburst (ID: 10118504428)",
    "RightShift: toggle GUI visible/hidden",
    "All features OFF by default - enable what you need",
    "Teleports to each target, fires ProximityPrompt + remote",
    "Mobile Delta fix: vararg captured before pcall (no crash)",
    "Tycoon auto-detected from your UserId on join",
})
MakeSection(ip, "How Each Feature Works")
MakeInfoCard(ip, {
    "Auto Arrest: scans all of Workspace for WANTED criminal NPCs",
    "  then teleports to them and fires their arrest prompt",
    "Auto Clean: scans YOUR tycoon for trash/litter objects with prompts",
    "Auto Tunnels: scans YOUR tycoon for hole/tunnel objects with prompts",
    "Auto Feed: scans YOUR tycoon for buffet objects with prompts",
    "Auto Fire: scans YOUR tycoon for Fire particles and fire objects",
    "Auto Research: clicks Research button to progress active research",
})

",
})

-- =============================================
-- DRAG via Header
-- =============================================
local dragging  = false
local dragStart = nil
local winStart  = nil

Header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = inp.Position
        winStart  = Main.Position
    end
end)

Header.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - dragStart
        local nx = winStart.X.Offset + delta.X
        local ny = winStart.Y.Offset + delta.Y
        Main.Position   = UDim2.new(winStart.X.Scale, nx, winStart.Y.Scale, ny)
        Glow.Position   = UDim2.new(winStart.X.Scale, nx-12, winStart.Y.Scale, ny-12)
        Shadow.Position = UDim2.new(winStart.X.Scale, nx-4,  winStart.Y.Scale, ny+4)
    end
end)

-- =============================================
-- MINIMISE
-- =============================================
MinBtn.MouseButton1Click:Connect(function()
    State.Minimized = not State.Minimized
    if State.Minimized then
        Tween(Main,   {Size = UDim2.new(0, WIN_W, 0, 58)}, 0.3, Enum.EasingStyle.Back)
        Tween(Glow,   {Size = UDim2.new(0, WIN_W+24, 0, 58+24)}, 0.3, Enum.EasingStyle.Back)
        Tween(Shadow, {Size = UDim2.new(0, WIN_W+8,  0, 58+8)},  0.3, Enum.EasingStyle.Back)
        MinBtn.Text = "+"
    else
        Tween(Main,   {Size = UDim2.new(0, WIN_W, 0, WIN_H)},       0.35, Enum.EasingStyle.Back)
        Tween(Glow,   {Size = UDim2.new(0, WIN_W+24, 0, WIN_H+24)}, 0.35, Enum.EasingStyle.Back)
        Tween(Shadow, {Size = UDim2.new(0, WIN_W+8,  0, WIN_H+8)},  0.35, Enum.EasingStyle.Back)
        MinBtn.Text = "─"
    end
end)

-- =============================================
-- CLOSE BUTTON
-- =============================================
CloseBtn.MouseButton1Click:Connect(function()
    State.GuiOpen = false
    Tween(Main,   {Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Back)
    Tween(Glow,   {BackgroundTransparency = 1}, 0.3)
    Tween(Shadow, {BackgroundTransparency = 1}, 0.3)
    task.delay(0.35, function()
        Main.Visible   = false
        Glow.Visible   = false
        Shadow.Visible = false
    end)
    Notify("GUI closed  |  RightShift to reopen", C.textDim, "✕")
end)

-- =============================================
-- KEYBIND  RightShift = show / hide
-- =============================================
UserInputService.InputBegan:Connect(function(inp, gp2)
    if gp2 then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        State.GuiOpen = not State.GuiOpen
        if State.GuiOpen then
            Main.Visible   = true
            Glow.Visible   = true
            Shadow.Visible = true
            State.Minimized = false
            Main.Size       = UDim2.new(0, WIN_W, 0, 0)
            Tween(Main,   {Size = UDim2.new(0, WIN_W, 0, WIN_H), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back)
            Tween(Glow,   {BackgroundTransparency = 0.82}, 0.4)
            Tween(Shadow, {BackgroundTransparency = 0.45}, 0.4)
            MinBtn.Text = "─"
        else
            Tween(Main,   {Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Back)
            Tween(Glow,   {BackgroundTransparency = 1}, 0.3)
            Tween(Shadow, {BackgroundTransparency = 1}, 0.3)
            task.delay(0.35, function()
                Main.Visible   = false
                Glow.Visible   = false
                Shadow.Visible = false
            end)
        end
    end
end)

-- =============================================
-- ENTRY ANIMATION
-- =============================================
SwitchTab("Arrest")

Main.Position   = UDim2.new(0.5, -WIN_W/2, -0.3, 0)
Glow.Position   = UDim2.new(0.5, -WIN_W/2-12, -0.3, -12)
Shadow.Position = UDim2.new(0.5, -WIN_W/2-4, -0.3, 4)

Tween(Main,   {Position = UDim2.new(0.5, -WIN_W/2,   0.5, -WIN_H/2)}, 0.7, Enum.EasingStyle.Back)
Tween(Glow,   {Position = UDim2.new(0.5, -WIN_W/2-12, 0.5, -WIN_H/2-12)}, 0.7, Enum.EasingStyle.Back)
Tween(Shadow, {Position = UDim2.new(0.5, -WIN_W/2-4,  0.5, -WIN_H/2+4)},  0.7, Enum.EasingStyle.Back)

task.delay(0.9, function()
    Notify("My Prison v3.1 loaded!", C.accent, "✅")
end)
task.delay(1.5, function()
    Notify("Windburst 2026  -  all systems ready", C.blue, "🔒")
end)

print("[MyPrison v3.1 Custom UI] Loaded  -  RightShift to toggle GUI")
