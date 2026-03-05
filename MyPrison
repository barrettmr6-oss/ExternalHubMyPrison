--[[
  ╔══════════════════════════════════════════════════╗
  ║   MY PRISON  ULTIMATE HUB  v6.1                  ║
  ║   Windburst · ID 10118504428 · 2026              ║
  ║   Delta Mobile + PC · Zero-error build           ║
  ╠══════════════════════════════════════════════════╣
  ║  Auto Clean · Auto Fill Tunnels · Auto Feed      ║
  ║  Auto Extinguish · Auto Confiscate               ║
  ║  Auto Arrest (NPC cache + radius + alive check)  ║
  ║  Auto Buy Items · Auto Hire Workers              ║
  ║  Redeem 5 Codes · 4 Build Templates              ║
  ║  Drag · Minimise · Close · RightShift toggle     ║
  ╚══════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════
-- COMPATIBILITY  (Lua 5.1 / Delta mobile)
-- ═══════════════════════════════════════
local unpack = table.unpack or unpack   -- Lua 5.2+ uses table.unpack

-- ═══════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local LocalPlayer       = Players.LocalPlayer

-- ═══════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════
local State = {
    AutoClean         = false,
    AutoFillTunnels   = false,
    AutoArrest        = false,
    AutoFeed          = false,
    AutoExtinguish    = false,
    AutoContraband    = false,
    AutoBuy           = false,
    AutoHire          = false,
    ArrestRadius      = 30,     -- studs
    ScanRateRaw       = 20,     -- /10 = seconds between cycles
    GuiOpen           = true,
    Minimized         = false,
    BuildRunning      = false,
}

-- ═══════════════════════════════════════
-- GAME DATA
-- ═══════════════════════════════════════
local WORKERS = {
    { name="Guard",     cost=100,  icon="👮", desc="1 per 5 prisoners · $5/hr" },
    { name="Chef",      cost=100,  icon="🍳", desc="1 per 15 prisoners · $8/hr · needs kitchen" },
    { name="Janitor",   cost=500,  icon="🧹", desc="Cleans trash · $20/hr" },
    { name="Repairman", cost=550,  icon="🔧", desc="Fills tunnels · $15/hr" },
    { name="Nurse",     cost=1000, icon="💊", desc="Heals prisoners · research required" },
    { name="Dog",       cost=750,  icon="🐶", desc="Finds tunnels · research required" },
}

local ITEMS = {
    { name="Wooden Bunk Bed",     cost=75,  icon="🛏", desc="Holds 2 prisoners" },
    { name="Toilet",              cost=40,  icon="🚽", desc="1 per 2 prisoners" },
    { name="Shower",              cost=60,  icon="🚿", desc="1 per 2 prisoners" },
    { name="Buffet",              cost=120, icon="🍽", desc="1 per 12 prisoners" },
    { name="Rounded Lunch Table", cost=50,  icon="🪑", desc="1 per 4 prisoners" },
    { name="Bleacher",            cost=80,  icon="🏟", desc="Happiness seating" },
    { name="Weight Bench",        cost=90,  icon="🏋", desc="Sports · small security" },
    { name="Sink",                cost=30,  icon="🚰", desc="Required per Chef" },
    { name="Oven",                cost=50,  icon="♨",  desc="Required per Chef" },
    { name="Refrigerator",        cost=60,  icon="❄",  desc="Required per Chef" },
    { name="Trash Can",           cost=25,  icon="🗑",  desc="Reduces mess buildup" },
    { name="Soda Machine",        cost=100, icon="🥤", desc="1 per 3.5 prisoners" },
}

local CODES = {
    { code="Fire",             reward="$350" },
    { code="StaffOnly",        reward="$500" },
    { code="American Footbal", reward="Cash" },
    { code="Robber",           reward="$375" },
    { code="honeystrom",       reward="$750" },
}

local TEMPLATES = {
    {
        name="Starter (~$800)",  icon="🏚",
        desc="3 prisoners · beds, toilet, buffet, 1 guard",
        cost=790,
        steps={
            {t="buy",name="Wooden Bunk Bed",qty=2},{t="buy",name="Toilet",qty=1},
            {t="buy",name="Buffet",qty=1},{t="buy",name="Rounded Lunch Table",qty=1},
            {t="hire",name="Guard",qty=1},
        },
    },
    {
        name="Budget (~$2,500)",  icon="🏠",
        desc="10 prisoners · 5 beds, showers, 2 guards, chef",
        cost=2490,
        steps={
            {t="buy",name="Wooden Bunk Bed",qty=5},{t="buy",name="Toilet",qty=3},
            {t="buy",name="Shower",qty=2},{t="buy",name="Buffet",qty=1},
            {t="buy",name="Rounded Lunch Table",qty=3},{t="buy",name="Bleacher",qty=2},
            {t="buy",name="Sink",qty=1},{t="buy",name="Oven",qty=1},
            {t="buy",name="Refrigerator",qty=1},{t="buy",name="Weight Bench",qty=4},
            {t="hire",name="Guard",qty=2},{t="hire",name="Chef",qty=1},
        },
    },
    {
        name="Medium (~$6,000)",  icon="🏢",
        desc="25 prisoners · full block + all staff",
        cost=5900,
        steps={
            {t="buy",name="Wooden Bunk Bed",qty=13},{t="buy",name="Toilet",qty=7},
            {t="buy",name="Shower",qty=7},{t="buy",name="Buffet",qty=2},
            {t="buy",name="Rounded Lunch Table",qty=7},{t="buy",name="Bleacher",qty=4},
            {t="buy",name="Sink",qty=2},{t="buy",name="Oven",qty=2},
            {t="buy",name="Refrigerator",qty=2},{t="buy",name="Weight Bench",qty=10},
            {t="buy",name="Soda Machine",qty=4},{t="buy",name="Trash Can",qty=5},
            {t="hire",name="Guard",qty=5},{t="hire",name="Chef",qty=2},
            {t="hire",name="Janitor",qty=1},{t="hire",name="Repairman",qty=1},
        },
    },
    {
        name="Full 100 (~$25,000)",  icon="🏰",
        desc="Max 100 prisoners · everything maxed",
        cost=24800,
        steps={
            {t="buy",name="Wooden Bunk Bed",qty=50},{t="buy",name="Toilet",qty=50},
            {t="buy",name="Shower",qty=50},{t="buy",name="Buffet",qty=9},
            {t="buy",name="Rounded Lunch Table",qty=25},{t="buy",name="Bleacher",qty=20},
            {t="buy",name="Sink",qty=7},{t="buy",name="Oven",qty=7},
            {t="buy",name="Refrigerator",qty=7},{t="buy",name="Weight Bench",qty=40},
            {t="buy",name="Soda Machine",qty=29},{t="buy",name="Trash Can",qty=15},
            {t="hire",name="Guard",qty=20},{t="hire",name="Chef",qty=7},
            {t="hire",name="Janitor",qty=3},{t="hire",name="Repairman",qty=2},
        },
    },
}

-- ═══════════════════════════════════════
-- COLOURS
-- ═══════════════════════════════════════
local C = {
    bg=Color3.fromRGB(9,12,10), bg2=Color3.fromRGB(14,19,15),
    bg3=Color3.fromRGB(19,26,20), bgCard=Color3.fromRGB(16,22,17),
    bgHover=Color3.fromRGB(24,33,26),
    accent=Color3.fromRGB(50,210,90), accentDim=Color3.fromRGB(22,78,38),
    accentOff=Color3.fromRGB(30,42,34), accentGlow=Color3.fromRGB(28,95,50),
    text=Color3.fromRGB(218,238,222), textDim=Color3.fromRGB(76,115,87),
    textMid=Color3.fromRGB(138,172,148),
    red=Color3.fromRGB(228,68,58), redDim=Color3.fromRGB(75,22,18),
    orange=Color3.fromRGB(238,152,42), orangeDim=Color3.fromRGB(78,48,12),
    blue=Color3.fromRGB(52,138,232), blueDim=Color3.fromRGB(16,42,78),
    purple=Color3.fromRGB(148,88,232),
    gold=Color3.fromRGB(255,200,50), goldDim=Color3.fromRGB(80,60,10),
    sep=Color3.fromRGB(26,38,28),
    knobOff=Color3.fromRGB(95,128,106), knobOn=Color3.fromRGB(232,255,240),
}

-- ═══════════════════════════════════════
-- UI MICRO-HELPERS
-- ═══════════════════════════════════════
local function Tw(o,p,t,s,d)
    if not o or not o.Parent then return end
    TweenService:Create(o,TweenInfo.new(t or .2,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),p):Play()
end
local function Cor(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=p;return c end
local function Str(p,col,th,tr) local s=Instance.new("UIStroke");s.Color=col or C.accent;s.Thickness=th or 1;s.Transparency=tr or 0;s.Parent=p;return s end
local function Pad(p,l,r,t,b) local x=Instance.new("UIPadding");x.PaddingLeft=UDim.new(0,l or 0);x.PaddingRight=UDim.new(0,r or 0);x.PaddingTop=UDim.new(0,t or 0);x.PaddingBottom=UDim.new(0,b or 0);x.Parent=p;return x end
local function Lst(p,pad,dir)
    local l=Instance.new("UIListLayout");l.Padding=UDim.new(0,pad or 6)
    l.FillDirection=dir or Enum.FillDirection.Vertical;l.SortOrder=Enum.SortOrder.LayoutOrder;l.Parent=p;return l
end

-- ═══════════════════════════════════════
-- GAME HELPERS
-- ═══════════════════════════════════════

-- Safe character root part getter
local function GetHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

-- Character alive check  (returns false if respawning or dead)
local function CharAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    if not char:FindFirstChild("HumanoidRootPart") then return false end
    local h = char:FindFirstChildWhichIsA("Humanoid")
    return h ~= nil and h.Health > 0
end

-- Teleport safely (pcall'd, skips if dead or respawning)
local function TeleportTo(targetPos)
    if not targetPos then return end
    if not CharAlive() then return end
    local hrp = GetHRP()
    if not hrp then return end
    pcall(function()
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
    end)
    task.wait(0.1)
end

-- Read player's cash from leaderstats (most reliable) with GUI fallback
local function GetMoney()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, n in ipairs({"Cash","Money","Coins","Gold","Dollars","Credits"}) do
            local v = ls:FindFirstChild(n)
            if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then
                local num = tonumber(v.Value)
                if num and num >= 0 then return num end
            end
        end
    end
    -- GUI text fallback
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local best = 0
        pcall(function()
            for _, obj in ipairs(pg:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    local s = obj.Text:gsub(",",""):match("%$?(%d+)")
                    if s then
                        local n = tonumber(s)
                        if n and n > best and n < 10000000 then best = n end
                    end
                end
            end
        end)
        if best > 0 then return best end
    end
    return 0
end

-- Find the local player's tycoon folder (tries many naming conventions)
local function GetTycoon()
    local uid  = tostring(LocalPlayer.UserId)
    local uname = LocalPlayer.Name

    local function ownerMatch(folder)
        local ok, result = pcall(function()
            local o = folder:FindFirstChild("Owner")
                   or folder:FindFirstChild("OwnerID")
                   or folder:FindFirstChild("OwnerId")
            if not o then return false end
            local v = o.Value
            return tostring(v) == uid or v == LocalPlayer
        end)
        return ok and result
    end

    -- Check named containers first
    for _, cname in ipairs({"Tycoons","Plots","Prisons","Prison"}) do
        local container = Workspace:FindFirstChild(cname)
        if container then
            -- By UID or username directly
            local direct = container:FindFirstChild(uid) or container:FindFirstChild(uname)
            if direct then return direct end
            -- By Owner value
            for _, f in ipairs(container:GetChildren()) do
                if ownerMatch(f) then return f end
            end
        end
    end

    -- Direct workspace child named after player
    local direct = Workspace:FindFirstChild(uid) or Workspace:FindFirstChild(uname)
    if direct then return direct end

    -- Last resort: scan workspace children for owner match
    for _, obj in ipairs(Workspace:GetChildren()) do
        if (obj:IsA("Folder") or obj:IsA("Model")) and ownerMatch(obj) then
            return obj
        end
    end
    return nil
end

-- Snapshot-safe keyword search (captures list before iterating to avoid mutation errors)
local function FindByKW(root, kws)
    local results = {}
    if not root then return results end

    local snap = {}
    pcall(function()
        for _, v in ipairs(root:GetDescendants()) do
            snap[#snap+1] = v
        end
    end)

    for _, obj in ipairs(snap) do
        if obj and obj.Parent then
            pcall(function()
                local low = obj.Name:lower()
                for _, kw in ipairs(kws) do
                    if low:find(kw, 1, true) then
                        results[#results+1] = obj
                        break
                    end
                end
            end)
        end
    end
    return results
end

-- Get position of any object type safely
local function GetPos(obj)
    if not obj or not obj.Parent then return nil end
    local ok, pos = pcall(function()
        if obj:IsA("BasePart") then return obj.Position end
        if obj:IsA("Model") then return obj:GetModelCFrame().Position end
        if obj:IsA("Tool") then
            local h = obj:FindFirstChild("Handle")
            if h then return h.Position end
        end
        return nil
    end)
    return ok and pos or nil
end

-- Delta-safe ProximityPrompt trigger (three methods, all pcall'd)
local function SafeFirePrompt(p)
    if not p or not p.Parent then return end
    pcall(function() p.Triggered:Fire(LocalPlayer) end)                -- always works in Roblox
    if type(fireproximityprompt) == "function" then                    -- Synapse / Fluxus etc.
        pcall(fireproximityprompt, p)
    end
    pcall(function()                                                    -- fire parent remotes
        for _, v in ipairs(p.Parent:GetChildren()) do
            if v:IsA("RemoteEvent") then v:FireServer() end
        end
    end)
end

-- Fire every ProximityPrompt on an object (deduped)
local function FireAllPrompts(obj)
    if not obj or not obj.Parent then return end
    local seen = {}
    pcall(function()
        for _, v in ipairs(obj:GetDescendants()) do
            if v:IsA("ProximityPrompt") and not seen[v] then
                seen[v] = true
                SafeFirePrompt(v)
            end
        end
    end)
end

-- Fire a named RemoteEvent/Function (exact match first, then contains-match)
local function FireRemote(name, ...)
    local args = {...}
    local function tryFire(r)
        pcall(function()
            if r:IsA("RemoteEvent") then r:FireServer(unpack(args)) end
            if r:IsA("RemoteFunction") then r:InvokeServer(unpack(args)) end
        end)
    end
    -- Exact name match
    for _, root in ipairs({ReplicatedStorage, Workspace}) do
        local r = root:FindFirstChild(name, true)
        if r then tryFire(r); return end
    end
    -- Contains match (handles obfuscated names)
    local lower = name:lower()
    for _, root in ipairs({ReplicatedStorage, Workspace}) do
        pcall(function()
            for _, r in ipairs(root:GetDescendants()) do
                if (r:IsA("RemoteEvent") or r:IsA("RemoteFunction"))
                   and r.Name:lower():find(lower, 1, true) then
                    tryFire(r)
                end
            end
        end)
    end
end

-- Buy an item: fire purchase remotes + nearby ProximityPrompts
local function TryBuyItem(itemName)
    local args = {itemName}
    local keywords = {"buy","purchase","place","build","shop","item"}
    -- Fire any remote whose name contains a purchase keyword
    for _, root in ipairs({ReplicatedStorage, Workspace}) do
        pcall(function()
            for _, r in ipairs(root:GetDescendants()) do
                if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                    local rn = r.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if rn:find(kw, 1, true) then
                            pcall(function()
                                if r:IsA("RemoteEvent") then r:FireServer(unpack(args))
                                else r:InvokeServer(unpack(args)) end
                            end)
                            break
                        end
                    end
                end
            end
        end)
    end
    -- Also fire ProximityPrompts on objects named after the item
    local low = itemName:lower()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj.Parent and obj.Name:lower():find(low, 1, true) then
                if obj:IsA("ProximityPrompt") then SafeFirePrompt(obj)
                elseif obj:IsA("BasePart") or obj:IsA("Model") then FireAllPrompts(obj) end
            end
        end
    end)
end

-- Hire a worker: same pattern as TryBuyItem
local function TryHireWorker(workerName)
    local args = {workerName}
    local keywords = {"hire","worker","spawn","staff","buy","add"}
    for _, root in ipairs({ReplicatedStorage, Workspace}) do
        pcall(function()
            for _, r in ipairs(root:GetDescendants()) do
                if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                    local rn = r.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if rn:find(kw, 1, true) then
                            pcall(function()
                                if r:IsA("RemoteEvent") then r:FireServer(unpack(args))
                                else r:InvokeServer(unpack(args)) end
                            end)
                            break
                        end
                    end
                end
            end
        end)
    end
    -- Also interact with any in-world hire button
    local low = workerName:lower()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj.Parent and obj.Name:lower():find(low, 1, true) then
                local pos = GetPos(obj)
                if pos then TeleportTo(pos) end
                if obj:IsA("ProximityPrompt") then SafeFirePrompt(obj)
                else FireAllPrompts(obj) end
            end
        end
    end)
end

-- Redeem a promo code: remotes + GUI automation
local function RedeemCode(code)
    local args = {code}
    local keywords = {"code","redeem","promo"}
    for _, root in ipairs({ReplicatedStorage, Workspace}) do
        pcall(function()
            for _, r in ipairs(root:GetDescendants()) do
                if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                    local rn = r.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if rn:find(kw, 1, true) then
                            pcall(function()
                                if r:IsA("RemoteEvent") then r:FireServer(unpack(args))
                                else r:InvokeServer(unpack(args)) end
                            end)
                        end
                    end
                end
            end
        end)
    end
    -- GUI automation: find the code TextBox and Redeem button
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    pcall(function()
        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("TextBox") then
                local ph = obj.PlaceholderText:lower()
                local nm = obj.Name:lower()
                if ph:find("code",1,true) or ph:find("promo",1,true)
                or nm:find("code",1,true) or nm:find("promo",1,true) then
                    obj.Text = code
                    obj.FocusLost:Fire(true)
                end
            end
        end
        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("TextButton") then
                local t = obj.Text:lower()
                if t:find("redeem",1,true) or t:find("claim",1,true) then
                    obj.MouseButton1Click:Fire()
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════
-- CRIMINAL NPC CACHE
-- Rebuilt every 5 seconds. Only scans direct
-- children + one level of Folders so we never
-- iterate 10,000+ descendants on the heartbeat.
-- ═══════════════════════════════════════
local _crimCache     = {}
local _crimCacheTick = 0
local CRIM_KWS = {
    "criminal","gangster","robber","thief","suspect",
    "wanted","fugitive","bandit","convict","inmate"
}

local function IsCriminal(model)
    -- Name match
    local low = model.Name:lower()
    for _, kw in ipairs(CRIM_KWS) do
        if low:find(kw, 1, true) then return true end
    end
    -- Attribute / Value tag check
    local ok, result = pcall(function()
        if model:GetAttribute("Wanted")   then return true end
        if model:GetAttribute("Criminal") then return true end
        local w = model:FindFirstChild("Wanted") or model:FindFirstChild("IsCriminal")
                  or model:FindFirstChild("Criminal") or model:FindFirstChild("IsWanted")
        if w and (w.Value == true or w.Value == 1) then return true end
        return false
    end)
    return ok and result
end

local function RebuildCrimCache()
    if tick() - _crimCacheTick < 5 then return end
    _crimCacheTick = tick()
    local newCache = {}
    local char = LocalPlayer.Character

    pcall(function()
        -- Pass 1: direct Workspace children (Models and Folders)
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= char then
                if IsCriminal(obj) then
                    newCache[#newCache+1] = obj
                end
            elseif obj:IsA("Folder") then
                -- Pass 2: one level inside Folders (CrimeCity, NPCs, etc.)
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("Model") and child ~= char then
                        if IsCriminal(child) then
                            newCache[#newCache+1] = child
                        end
                    end
                end
            end
        end
    end)

    _crimCache = newCache
end

-- ═══════════════════════════════════════
-- AUTOMATION RUNNERS
-- Every runner is fully pcall-wrapped.
-- ═══════════════════════════════════════

local function RunAutoClean()
    if not State.AutoClean then return end
    local root = GetTycoon() or Workspace
    local KWS = {"trash","mess","dirt","litter","spill","dirty","laundry","waste","debris","garbage","mop"}
    for _, obj in ipairs(FindByKW(root, KWS)) do
        if not State.AutoClean then break end
        local pos = GetPos(obj)
        if pos then
            TeleportTo(pos)
            FireAllPrompts(obj)
            FireRemote("Clean")
            FireRemote("CleanMess")
            task.wait(0.2)
        end
    end
end

local function RunAutoFillTunnels()
    if not State.AutoFillTunnels then return end
    local root = GetTycoon() or Workspace
    local KWS = {"tunnel","hole","escape","dighole","digtunnel"}
    for _, obj in ipairs(FindByKW(root, KWS)) do
        if not State.AutoFillTunnels then break end
        local pos = GetPos(obj)
        if pos then
            TeleportTo(pos)
            FireAllPrompts(obj)
            FireRemote("FillTunnel")
            FireRemote("Fill")
            task.wait(0.2)
        end
    end
end

local function RunAutoArrest()
    if not State.AutoArrest then return end
    if not CharAlive() then return end

    RebuildCrimCache()

    local hrp = GetHRP()
    if not hrp then return end
    local radius = State.ArrestRadius

    for _, npc in ipairs(_crimCache) do
        if not State.AutoArrest then break end

        -- Skip if NPC no longer exists
        if not npc or not npc.Parent then continue end

        -- Skip if NPC is dead
        local hum = npc:FindFirstChildWhichIsA("Humanoid")
        if hum and hum.Health <= 0 then continue end

        -- Get NPC root position
        local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                     or npc:FindFirstChild("RootPart")
                     or npc:FindFirstChildWhichIsA("BasePart")
        if not npcRoot then continue end

        local npcPos = npcRoot.Position

        -- Refresh HRP each iteration in case of respawn
        hrp = GetHRP()
        if not hrp then break end

        local dist = (hrp.Position - npcPos).Magnitude

        pcall(function()
            -- Step 1: get within arrest radius if needed
            if dist > radius then
                -- Teleport toward the NPC, stopping just outside melee range (5 studs)
                local toNPC = npcPos - hrp.Position
                local mag   = toNPC.Magnitude
                if mag > 0 then
                    -- Place ourselves 5 studs away from NPC (well inside arrest radius)
                    local dest = npcPos - toNPC.Unit * 5
                    TeleportTo(dest)
                else
                    TeleportTo(npcPos + Vector3.new(4, 0, 0))
                end
                task.wait(0.08)
                hrp = GetHRP()
                if not hrp then return end
            end

            -- Step 2: fire every ProximityPrompt on the NPC model
            FireAllPrompts(npc)

            -- Step 3: fire arrest-related remotes (no Instance arg)
            FireRemote("Arrest")
            FireRemote("ArrestCriminal")
            FireRemote("ArrestNPC")
            FireRemote("Handcuff")
            FireRemote("Cuff")

            -- Step 4: fire with NPC name as string arg (some games use this)
            pcall(function()
                FireRemote("Arrest", npc.Name)
                FireRemote("ArrestCriminal", npc.Name)
            end)
        end)

        task.wait(0.3)
    end
end

local function RunAutoFeed()
    if not State.AutoFeed then return end
    local root = GetTycoon() or Workspace
    local KWS = {"buffet","food","tray","serving","kitchen","meal"}
    for _, obj in ipairs(FindByKW(root, KWS)) do
        if not State.AutoFeed then break end
        local pos = GetPos(obj)
        if pos then
            TeleportTo(pos)
            FireAllPrompts(obj)
            FireRemote("RefillBuffet")
            FireRemote("Restock")
            FireRemote("Feed")
            task.wait(0.2)
        end
    end
end

local function RunAutoExtinguish()
    if not State.AutoExtinguish then return end
    local root = GetTycoon() or Workspace

    -- Take a snapshot of descendants so iteration doesn't break on removal
    local snap = {}
    pcall(function()
        for _, v in ipairs(root:GetDescendants()) do snap[#snap+1] = v end
    end)

    for _, obj in ipairs(snap) do
        if not State.AutoExtinguish then break end
        if not obj or not obj.Parent then continue end

        local isFire = false
        pcall(function()
            isFire = obj:IsA("Fire")
            if not isFire and (obj:IsA("BasePart") or obj:IsA("Model")) then
                local low = obj.Name:lower()
                for _, kw in ipairs({"fire","burn","flame","blaze","firezone"}) do
                    if low:find(kw, 1, true) then isFire = true; break end
                end
            end
        end)

        if isFire then
            pcall(function()
                local base = obj:IsA("Fire") and obj.Parent or obj
                if not base or not base.Parent then return end
                local pos = GetPos(base)
                if pos then
                    TeleportTo(pos)
                    FireAllPrompts(base)
                    FireRemote("Extinguish")
                    FireRemote("PutOutFire")
                    FireRemote("ExtinguishFire")
                    task.wait(0.2)
                end
            end)
        end
    end
end

local function RunAutoContraband()
    if not State.AutoContraband then return end
    local root = GetTycoon() or Workspace
    local KWS = {"contraband","shiv","drug","weapon","knife","illegal","smuggle"}
    for _, obj in ipairs(FindByKW(root, KWS)) do
        if not State.AutoContraband then break end
        local pos = GetPos(obj)
        if pos then
            TeleportTo(pos)
            FireAllPrompts(obj)
            FireRemote("Confiscate")
            FireRemote("ConfiscateContraband")
            FireRemote("RemoveContraband")
            task.wait(0.2)
        end
    end
end

local function RunAutoBuy()
    if not State.AutoBuy then return end
    local money = GetMoney()
    for _, item in ipairs(ITEMS) do
        if not State.AutoBuy then break end
        if money >= item.cost then
            TryBuyItem(item.name)
            money = money - item.cost
            task.wait(0.4)
        end
    end
end

local function RunAutoHire()
    if not State.AutoHire then return end
    local money = GetMoney()
    for _, w in ipairs(WORKERS) do
        if not State.AutoHire then break end
        if money >= w.cost then
            TryHireWorker(w.name)
            money = money - w.cost
            task.wait(0.4)
        end
    end
end

local function RunBuildTemplate(tmpl, onProgress)
    State.BuildRunning = true
    local money = GetMoney()
    if money < tmpl.cost then
        onProgress("NEED $" .. tostring(tmpl.cost - money) .. " MORE!")
        task.wait(2.5)
        onProgress("")
        State.BuildRunning = false
        return
    end
    local total = 0
    for _, s in ipairs(tmpl.steps) do total = total + s.qty end
    local done = 0
    for _, step in ipairs(tmpl.steps) do
        if not State.BuildRunning then break end
        for i = 1, step.qty do
            if not State.BuildRunning then break end
            done = done + 1
            if step.t == "buy" then
                onProgress("Buying " .. step.name .. "  " .. i .. "/" .. step.qty .. "  (" .. done .. "/" .. total .. ")")
                TryBuyItem(step.name)
            else
                onProgress("Hiring " .. step.name .. "  " .. i .. "/" .. step.qty .. "  (" .. done .. "/" .. total .. ")")
                TryHireWorker(step.name)
            end
            task.wait(0.45)
        end
    end
    if State.BuildRunning then
        onProgress("COMPLETE!")
        task.wait(2)
        onProgress("")
    end
    State.BuildRunning = false
end

-- ═══════════════════════════════════════
-- MASTER HEARTBEAT LOOP
-- Each runner gets its own task.spawn +
-- pcall so one error never stops the rest.
-- ═══════════════════════════════════════
local lastTick = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastTick < State.ScanRateRaw / 10 then return end
    lastTick = now
    if State.AutoClean      then task.spawn(function() pcall(RunAutoClean)       end) end
    if State.AutoFillTunnels then task.spawn(function() pcall(RunAutoFillTunnels) end) end
    if State.AutoArrest     then task.spawn(function() pcall(RunAutoArrest)      end) end
    if State.AutoFeed       then task.spawn(function() pcall(RunAutoFeed)        end) end
    if State.AutoExtinguish then task.spawn(function() pcall(RunAutoExtinguish)  end) end
    if State.AutoContraband then task.spawn(function() pcall(RunAutoContraband)  end) end
    if State.AutoBuy        then task.spawn(function() pcall(RunAutoBuy)         end) end
    if State.AutoHire       then task.spawn(function() pcall(RunAutoHire)        end) end
end)

-- ═══════════════════════════════════════
-- GUI
-- ═══════════════════════════════════════
do
    local g = LocalPlayer.PlayerGui:FindFirstChild("MPrisonV6")
    if g then g:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MPrisonV6"
ScreenGui.ResetOnSpawn  = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder  = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local WIN_W, WIN_H = 356, 574

-- Ambient glow
local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(0, WIN_W+32, 0, WIN_H+32)
Glow.Position = UDim2.new(0.5, -(WIN_W/2)-16, 0.5, -(WIN_H/2)-16)
Glow.BackgroundColor3 = C.accentGlow
Glow.BackgroundTransparency = 0.78
Glow.BorderSizePixel = 0; Glow.ZIndex = 1; Glow.Parent = ScreenGui; Cor(Glow, 22)

-- Drop shadow
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(0, WIN_W+12, 0, WIN_H+12)
Shadow.Position = UDim2.new(0.5, -(WIN_W/2)-6, 0.5, -(WIN_H/2)+7)
Shadow.BackgroundColor3 = Color3.new(0,0,0)
Shadow.BackgroundTransparency = 0.44
Shadow.BorderSizePixel = 0; Shadow.ZIndex = 1; Shadow.Parent = ScreenGui; Cor(Shadow, 18)

-- Main window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
Main.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.ZIndex = 2; Main.Parent = ScreenGui
Cor(Main, 14); Str(Main, C.accentDim, 1.5, 0.12)

-- Top accent gradient
local TGrad = Instance.new("Frame")
TGrad.Size = UDim2.new(1,0,0,70); TGrad.BackgroundColor3 = C.accent
TGrad.BackgroundTransparency = 0.93; TGrad.BorderSizePixel = 0; TGrad.ZIndex = 3; TGrad.Parent = Main
local tg = Instance.new("UIGradient"); tg.Rotation = 90
tg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}
tg.Parent = TGrad

-- ── HEADER ──
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,62); Header.BackgroundColor3 = C.bg2
Header.BorderSizePixel = 0; Header.ZIndex = 4; Header.Parent = Main; Cor(Header, 14)
-- flatten bottom of header
local HF = Instance.new("Frame"); HF.Size = UDim2.new(1,0,0,14); HF.Position = UDim2.new(0,0,1,-14)
HF.BackgroundColor3 = C.bg2; HF.BorderSizePixel = 0; HF.ZIndex = 4; HF.Parent = Header
-- header gradient
local hg = Instance.new("UIGradient")
hg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(20,48,28)),ColorSequenceKeypoint.new(1,C.bg)}
hg.Rotation = 90; hg.Parent = Header
-- top accent stripe
local Stripe = Instance.new("Frame"); Stripe.Size = UDim2.new(1,0,0,2)
Stripe.BackgroundColor3 = C.accent; Stripe.BackgroundTransparency = 0.22
Stripe.BorderSizePixel = 0; Stripe.ZIndex = 6; Stripe.Parent = Header; Cor(Stripe, 14)

-- badge
local Badge = Instance.new("Frame"); Badge.Size = UDim2.new(0,44,0,44); Badge.Position = UDim2.new(0,12,0.5,-22)
Badge.BackgroundColor3 = C.accentDim; Badge.BorderSizePixel = 0; Badge.ZIndex = 5; Badge.Parent = Header
Cor(Badge, 11); Str(Badge, C.accent, 1, 0.42)
local BIco = Instance.new("TextLabel"); BIco.Size = UDim2.new(1,0,1,0); BIco.BackgroundTransparency = 1
BIco.Text = "🔒"; BIco.TextSize = 22; BIco.Font = Enum.Font.GothamBold; BIco.ZIndex = 6; BIco.Parent = Badge

local TitleL = Instance.new("TextLabel"); TitleL.Size = UDim2.new(1,-148,0,22); TitleL.Position = UDim2.new(0,64,0,8)
TitleL.BackgroundTransparency = 1; TitleL.Font = Enum.Font.GothamBold; TitleL.TextColor3 = C.accent; TitleL.TextSize = 14
TitleL.TextXAlignment = Enum.TextXAlignment.Left; TitleL.Text = "MY PRISON  ULTIMATE HUB"; TitleL.ZIndex = 5; TitleL.Parent = Header

local SubL = Instance.new("TextLabel"); SubL.Size = UDim2.new(1,-148,0,14); SubL.Position = UDim2.new(0,64,0,35)
SubL.BackgroundTransparency = 1; SubL.Font = Enum.Font.Gotham; SubL.TextColor3 = C.textDim; SubL.TextSize = 10
SubL.TextXAlignment = Enum.TextXAlignment.Left; SubL.Text = "v6.1  ·  Delta Mobile  ·  RightShift = toggle"
SubL.ZIndex = 5; SubL.Parent = Header

-- header buttons
local BtnF = Instance.new("Frame"); BtnF.Size = UDim2.new(0,66,0,28); BtnF.Position = UDim2.new(1,-76,0.5,-14)
BtnF.BackgroundTransparency = 1; BtnF.ZIndex = 5; BtnF.Parent = Header
local blist = Instance.new("UIListLayout"); blist.FillDirection = Enum.FillDirection.Horizontal
blist.Padding = UDim.new(0,5); blist.HorizontalAlignment = Enum.HorizontalAlignment.Right
blist.VerticalAlignment = Enum.VerticalAlignment.Center; blist.Parent = BtnF

local function MkHBtn(txt, bg)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(0,28,0,28); b.BackgroundColor3 = bg or C.accentDim
    b.Font = Enum.Font.GothamBold; b.TextColor3 = C.text; b.TextSize = 14; b.Text = txt
    b.BorderSizePixel = 0; b.ZIndex = 6; b.Parent = BtnF; Cor(b, 7)
    b.MouseEnter:Connect(function() Tw(b,{BackgroundTransparency=0.3},0.1) end)
    b.MouseLeave:Connect(function() Tw(b,{BackgroundTransparency=0},0.1)   end)
    return b
end
local MinBtn   = MkHBtn("─", C.accentDim)
local CloseBtn = MkHBtn("✕", C.redDim)

-- ── TAB BAR ──
local TAB_H = 40
local TabBar = Instance.new("Frame"); TabBar.Size = UDim2.new(1,0,0,TAB_H); TabBar.Position = UDim2.new(0,0,0,62)
TabBar.BackgroundColor3 = C.bg2; TabBar.BorderSizePixel = 0; TabBar.ZIndex = 4; TabBar.Parent = Main
local TabSep = Instance.new("Frame"); TabSep.Size = UDim2.new(1,0,0,1); TabSep.Position = UDim2.new(0,0,1,-1)
TabSep.BackgroundColor3 = C.accentDim; TabSep.BackgroundTransparency = 0.4; TabSep.BorderSizePixel = 0; TabSep.ZIndex = 5; TabSep.Parent = TabBar
local TL = Instance.new("UIListLayout"); TL.FillDirection = Enum.FillDirection.Horizontal
TL.HorizontalAlignment = Enum.HorizontalAlignment.Center; TL.VerticalAlignment = Enum.VerticalAlignment.Center
TL.Padding = UDim.new(0,3); TL.Parent = TabBar; Pad(TabBar,5,5,0,0)

-- ── PAGE CONTAINER ──
local HDRH = 62 + TAB_H
local Pages = Instance.new("Frame"); Pages.Size = UDim2.new(1,0,1,-HDRH); Pages.Position = UDim2.new(0,0,0,HDRH)
Pages.BackgroundTransparency = 1; Pages.ClipsDescendants = true; Pages.ZIndex = 3; Pages.Parent = Main

-- ── NOTIFICATION LAYER ──
local NGui = Instance.new("ScreenGui"); NGui.Name = "MPV6N"; NGui.ResetOnSpawn = false
NGui.DisplayOrder = 1000; NGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local NH = Instance.new("Frame"); NH.Size = UDim2.new(0,330,1,-20); NH.Position = UDim2.new(0.5,-165,0,10)
NH.BackgroundTransparency = 1; NH.BorderSizePixel = 0; NH.Parent = NGui
local NLL = Instance.new("UIListLayout"); NLL.VerticalAlignment = Enum.VerticalAlignment.Top
NLL.Padding = UDim.new(0,5); NLL.Parent = NH

local function Notify(msg, col, icon)
    col = col or C.accent; icon = icon or "i"
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,0,50); bg.BackgroundColor3 = C.bg2
    bg.BackgroundTransparency = 1; bg.BorderSizePixel = 0; bg.ClipsDescendants = true; bg.Parent = NH
    Cor(bg,10); Str(bg,col,1,0.38)
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(0,3,1,0); bar.BackgroundColor3 = col
    bar.BorderSizePixel = 0; bar.ZIndex = 2; bar.Parent = bg; Cor(bar,2)
    local ic = Instance.new("TextLabel"); ic.Size = UDim2.new(0,38,1,0); ic.Position = UDim2.new(0,8,0,0)
    ic.BackgroundTransparency = 1; ic.Text = icon; ic.TextSize = 20; ic.Font = Enum.Font.GothamBold
    ic.TextColor3 = col; ic.ZIndex = 2; ic.Parent = bg
    local ml = Instance.new("TextLabel"); ml.Size = UDim2.new(1,-52,1,0); ml.Position = UDim2.new(0,50,0,0)
    ml.BackgroundTransparency = 1; ml.Font = Enum.Font.GothamMedium; ml.TextColor3 = C.text; ml.TextSize = 12
    ml.TextXAlignment = Enum.TextXAlignment.Left; ml.TextWrapped = true; ml.Text = msg; ml.ZIndex = 2; ml.Parent = bg
    Tw(bg, {BackgroundTransparency=0.04}, 0.25)
    task.delay(3.5, function()
        if bg and bg.Parent then
            Tw(bg, {BackgroundTransparency=1}, 0.3)
            task.delay(0.35, function() if bg and bg.Parent then bg:Destroy() end end)
        end
    end)
end

-- ── COMPONENT BUILDERS ──
local function MkPage(name)
    local p = Instance.new("ScrollingFrame"); p.Name = name; p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1; p.BorderSizePixel = 0; p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = C.accentDim; p.CanvasSize = UDim2.new(0,0,0,0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y; p.Visible = false; p.ZIndex = 4; p.Parent = Pages
    Lst(p, 6); Pad(p, 10, 10, 8, 14); return p
end

local function MkSec(parent, txt)
    local w = Instance.new("Frame"); w.Size = UDim2.new(1,0,0,22); w.BackgroundTransparency = 1; w.ZIndex = 5; w.Parent = parent
    local line = Instance.new("Frame"); line.Size = UDim2.new(1,0,0,1); line.Position = UDim2.new(0,0,0.5,0)
    line.BackgroundColor3 = C.sep; line.BorderSizePixel = 0; line.ZIndex = 5; line.Parent = w
    local pill = Instance.new("Frame"); pill.Size = UDim2.new(0,0,1,0); pill.AutomaticSize = Enum.AutomaticSize.X
    pill.BackgroundColor3 = C.bg; pill.BorderSizePixel = 0; pill.ZIndex = 6; pill.Parent = w
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(0,0,1,0); l.AutomaticSize = Enum.AutomaticSize.X
    l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamBold; l.TextColor3 = C.accent; l.TextSize = 9
    l.Text = "  " .. txt:upper() .. "  "; l.ZIndex = 7; l.Parent = pill
end

local function MkCard(parent, lines, border)
    local card = Instance.new("Frame"); card.BackgroundColor3 = C.bgCard; card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y; card.Size = UDim2.new(1,0,0,0); card.ZIndex = 5; card.Parent = parent
    Cor(card, 8); Str(card, border or C.sep, 1, 0.28); Pad(card, 11, 11, 8, 10); Lst(card, 4)
    for _, line in ipairs(lines) do
        local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,0,0,0); l.AutomaticSize = Enum.AutomaticSize.Y
        l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.TextColor3 = C.textMid; l.TextSize = 11
        l.TextWrapped = true; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = line; l.ZIndex = 6; l.Parent = card
    end
    return card
end

local function MkStatusCard(parent)
    local card = Instance.new("Frame"); card.Size = UDim2.new(1,0,0,56); card.BackgroundColor3 = Color3.fromRGB(12,22,15)
    card.BorderSizePixel = 0; card.ZIndex = 5; card.Parent = parent; Cor(card, 10); Str(card, C.accentDim, 1, 0.12)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(18,46,26)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,16,12))}
    g.Rotation = 90; g.Parent = card
    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0,8,0,8); dot.Position = UDim2.new(0,14,0.5,-4)
    dot.BackgroundColor3 = C.accent; dot.BorderSizePixel = 0; dot.ZIndex = 6; dot.Parent = card; Cor(dot, 4)
    task.spawn(function()
        while card.Parent do
            Tw(dot,{BackgroundTransparency=0.8},0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut); task.wait(0.9)
            Tw(dot,{BackgroundTransparency=0},  0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut); task.wait(0.9)
        end
    end)
    local ml = Instance.new("TextLabel"); ml.Size = UDim2.new(1,-32,0,19); ml.Position = UDim2.new(0,28,0,7)
    ml.BackgroundTransparency = 1; ml.Font = Enum.Font.GothamBold; ml.TextColor3 = C.accent; ml.TextSize = 11
    ml.TextXAlignment = Enum.TextXAlignment.Left; ml.Text = "Script Active  ·  Delta Mobile Compatible"; ml.ZIndex = 6; ml.Parent = card
    local mLbl = Instance.new("TextLabel"); mLbl.Size = UDim2.new(1,-32,0,14); mLbl.Position = UDim2.new(0,28,0,30)
    mLbl.BackgroundTransparency = 1; mLbl.Font = Enum.Font.Gotham; mLbl.TextColor3 = C.gold; mLbl.TextSize = 10
    mLbl.TextXAlignment = Enum.TextXAlignment.Left; mLbl.Text = "Money: $--"; mLbl.ZIndex = 6; mLbl.Parent = card
    task.spawn(function()
        while card.Parent do
            mLbl.Text = "Money: $"..GetMoney().."  ·  Scan: "..string.format("%.1f",State.ScanRateRaw/10).."s"
            task.wait(1)
        end
    end)
    return card
end

local function MkToggle(parent, icon, label, desc, stateKey, color)
    color = color or C.accent
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,66); row.BackgroundColor3 = C.bg3
    row.BorderSizePixel = 0; row.ZIndex = 5; row.Parent = parent; Cor(row, 10)
    local rs = Str(row, C.accentOff, 1, 0.14)
    local iw = Instance.new("Frame"); iw.Size = UDim2.new(0,44,0,44); iw.Position = UDim2.new(0,10,0.5,-22)
    iw.BackgroundColor3 = C.bg2; iw.BorderSizePixel = 0; iw.ZIndex = 6; iw.Parent = row; Cor(iw, 11); Str(iw,C.sep,1,0)
    local il = Instance.new("TextLabel"); il.Size = UDim2.new(1,0,1,0); il.BackgroundTransparency = 1
    il.Text = icon; il.TextSize = 22; il.Font = Enum.Font.GothamBold; il.ZIndex = 7; il.Parent = iw
    local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1,-122,0,20); nl.Position = UDim2.new(0,62,0,12)
    nl.BackgroundTransparency = 1; nl.Font = Enum.Font.GothamBold; nl.TextColor3 = C.text; nl.TextSize = 13
    nl.TextXAlignment = Enum.TextXAlignment.Left; nl.Text = label; nl.ZIndex = 6; nl.Parent = row
    local dl = Instance.new("TextLabel"); dl.Size = UDim2.new(1,-122,0,26); dl.Position = UDim2.new(0,62,0,34)
    dl.BackgroundTransparency = 1; dl.Font = Enum.Font.Gotham; dl.TextColor3 = C.textDim; dl.TextSize = 10
    dl.TextXAlignment = Enum.TextXAlignment.Left; dl.TextWrapped = true; dl.Text = desc; dl.ZIndex = 6; dl.Parent = row
    local pill = Instance.new("Frame"); pill.Size = UDim2.new(0,48,0,26); pill.Position = UDim2.new(1,-60,0.5,-13)
    pill.BackgroundColor3 = C.accentOff; pill.BorderSizePixel = 0; pill.ZIndex = 6; pill.Parent = row; Cor(pill, 13)
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,20,0,20); knob.Position = UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3 = C.knobOff; knob.BorderSizePixel = 0; knob.ZIndex = 7; knob.Parent = pill; Cor(knob, 10)
    local function Refresh()
        local on = State[stateKey]
        Tw(pill, {BackgroundColor3 = on and color or C.accentOff}, 0.18)
        Tw(knob, {Position = on and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}, 0.18)
        Tw(knob, {BackgroundColor3 = on and C.knobOn or C.knobOff}, 0.18)
        Tw(rs,   {Color = on and color or C.accentOff}, 0.18)
    end
    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1
    hit.Text = ""; hit.ZIndex = 8; hit.Parent = row
    hit.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]; Refresh()
        Notify(label .. (State[stateKey] and "  ON" or "  OFF"), State[stateKey] and color or C.textDim, icon)
    end)
    hit.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=C.bgHover},0.12) end)
    hit.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=C.bg3},   0.12) end)
    Refresh(); return row
end

local function MkSlider(parent, icon, label, desc, stateKey, minV, maxV, step)
    step = step or 1
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,74); row.BackgroundColor3 = C.bg3
    row.BorderSizePixel = 0; row.ZIndex = 5; row.Parent = parent; Cor(row, 10); Str(row, C.sep, 1, 0.1)
    local iw = Instance.new("Frame"); iw.Size = UDim2.new(0,44,0,44); iw.Position = UDim2.new(0,10,0,8)
    iw.BackgroundColor3 = C.bg2; iw.BorderSizePixel = 0; iw.ZIndex = 6; iw.Parent = row; Cor(iw,11); Str(iw,C.sep,1,0)
    local il = Instance.new("TextLabel"); il.Size = UDim2.new(1,0,1,0); il.BackgroundTransparency = 1
    il.Text = icon; il.TextSize = 22; il.Font = Enum.Font.GothamBold; il.ZIndex = 7; il.Parent = iw
    local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1,-124,0,18); nl.Position = UDim2.new(0,62,0,10)
    nl.BackgroundTransparency = 1; nl.Font = Enum.Font.GothamBold; nl.TextColor3 = C.text; nl.TextSize = 13
    nl.TextXAlignment = Enum.TextXAlignment.Left; nl.Text = label; nl.ZIndex = 6; nl.Parent = row
    local vl = Instance.new("TextLabel"); vl.Size = UDim2.new(0,58,0,18); vl.Position = UDim2.new(1,-66,0,10)
    vl.BackgroundTransparency = 1; vl.Font = Enum.Font.GothamBold; vl.TextColor3 = C.accent; vl.TextSize = 13
    vl.TextXAlignment = Enum.TextXAlignment.Right; vl.ZIndex = 6; vl.Parent = row
    local dl = Instance.new("TextLabel"); dl.Size = UDim2.new(1,-122,0,14); dl.Position = UDim2.new(0,62,0,30)
    dl.BackgroundTransparency = 1; dl.Font = Enum.Font.Gotham; dl.TextColor3 = C.textDim; dl.TextSize = 10
    dl.TextXAlignment = Enum.TextXAlignment.Left; dl.Text = desc; dl.ZIndex = 6; dl.Parent = row
    local track = Instance.new("Frame"); track.Size = UDim2.new(1,-20,0,6); track.Position = UDim2.new(0,10,0,59)
    track.BackgroundColor3 = C.accentOff; track.BorderSizePixel = 0; track.ZIndex = 6; track.Parent = row; Cor(track, 3)
    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0; fill.ZIndex = 7; fill.Parent = track; Cor(fill, 3)
    local handle = Instance.new("Frame"); handle.Size = UDim2.new(0,14,0,14); handle.Position = UDim2.new(0,-7,0.5,-7)
    handle.BackgroundColor3 = C.knobOn; handle.BorderSizePixel = 0; handle.ZIndex = 8; handle.Parent = track
    Cor(handle,7); Str(handle,C.accent,1.5,0.18)
    local function SetVal(v)
        v = math.clamp(math.round(v/step)*step, minV, maxV)
        State[stateKey] = v
        local pct = (v-minV)/(maxV-minV)
        vl.Text = stateKey=="ScanRateRaw" and string.format("%.1fs",v/10)
               or stateKey=="ArrestRadius" and tostring(v).."st"
               or tostring(v)
        Tw(fill,   {Size=UDim2.new(pct,0,1,0)},         0.1)
        Tw(handle, {Position=UDim2.new(pct,-7,0.5,-7)}, 0.1)
    end
    SetVal(State[stateKey])
    local dragging = false
    local ht = Instance.new("TextButton"); ht.Size = UDim2.new(1,0,1,0); ht.BackgroundTransparency = 1
    ht.Text = ""; ht.ZIndex = 9; ht.Parent = track
    ht.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    ht.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            SetVal(minV + pct*(maxV-minV))
        end
    end)
    return row
end

local function MkBtn(parent, icon, label, desc, color, onClick)
    color = color or C.accent
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,56); row.BackgroundColor3 = C.bg3
    row.BorderSizePixel = 0; row.ZIndex = 5; row.Parent = parent; Cor(row, 10); Str(row, color, 1, 0.48)
    local iw = Instance.new("Frame"); iw.Size = UDim2.new(0,40,0,40); iw.Position = UDim2.new(0,9,0.5,-20)
    iw.BackgroundColor3 = C.bg2; iw.BorderSizePixel = 0; iw.ZIndex = 6; iw.Parent = row; Cor(iw,10)
    local il = Instance.new("TextLabel"); il.Size = UDim2.new(1,0,1,0); il.BackgroundTransparency = 1
    il.Text = icon; il.TextSize = 20; il.Font = Enum.Font.GothamBold; il.ZIndex = 7; il.Parent = iw
    local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1,-114,0,21); nl.Position = UDim2.new(0,57,0,9)
    nl.BackgroundTransparency = 1; nl.Font = Enum.Font.GothamBold; nl.TextColor3 = color; nl.TextSize = 13
    nl.TextXAlignment = Enum.TextXAlignment.Left; nl.Text = label; nl.ZIndex = 6; nl.Parent = row
    local dl = Instance.new("TextLabel"); dl.Size = UDim2.new(1,-114,0,16); dl.Position = UDim2.new(0,57,0,32)
    dl.BackgroundTransparency = 1; dl.Font = Enum.Font.Gotham; dl.TextColor3 = C.textDim; dl.TextSize = 10
    dl.TextXAlignment = Enum.TextXAlignment.Left; dl.Text = desc; dl.ZIndex = 6; dl.Parent = row
    local arr = Instance.new("TextLabel"); arr.Size = UDim2.new(0,22,1,0); arr.Position = UDim2.new(1,-28,0,0)
    arr.BackgroundTransparency = 1; arr.Font = Enum.Font.GothamBold; arr.TextColor3 = color; arr.TextSize = 18
    arr.Text = ">"; arr.ZIndex = 6; arr.Parent = row
    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1
    hit.Text = ""; hit.ZIndex = 8; hit.Parent = row
    hit.MouseButton1Click:Connect(function()
        Tw(row,{BackgroundColor3=color},0.08); task.delay(0.16,function() Tw(row,{BackgroundColor3=C.bg3},0.22) end)
        onClick()
    end)
    hit.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=C.bgHover},0.12) end)
    hit.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=C.bg3},   0.12) end)
    return row
end

-- ── BUILD TABS ──
local TAB_DEFS = {
    {name="Main",  icon="🏛"},
    {name="Guards",icon="👮"},
    {name="Staff", icon="🧹"},
    {name="Build", icon="🏗"},
    {name="Shop",  icon="🛒"},
    {name="Codes", icon="🎁"},
}
local pageFrames, tabBtns = {}, {}
for _, def in ipairs(TAB_DEFS) do
    pageFrames[def.name] = MkPage(def.name)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(0,51,0,32); b.BackgroundColor3 = C.bg3
    b.Font = Enum.Font.GothamBold; b.TextColor3 = C.textDim; b.TextSize = 8
    b.Text = def.icon.."\n"..def.name:upper(); b.BorderSizePixel = 0; b.ZIndex = 5; b.Parent = TabBar; Cor(b,7)
    tabBtns[def.name] = b
end

local function SwitchTab(name)
    for n, pg in pairs(pageFrames) do pg.Visible = (n==name) end
    for n, b  in pairs(tabBtns)   do
        local a = (n==name)
        Tw(b, {BackgroundColor3 = a and C.accentDim or C.bg3},   0.15)
        Tw(b, {TextColor3       = a and C.accent    or C.textDim}, 0.15)
    end
end
for name, b in pairs(tabBtns) do b.MouseButton1Click:Connect(function() SwitchTab(name) end) end

-- ═══════════════════════════════════════
-- POPULATE PAGES
-- ═══════════════════════════════════════

-- MAIN
local mp = pageFrames["Main"]
MkStatusCard(mp)
MkSec(mp, "Quick Toggles")
MkToggle(mp,"🧹","Auto Clean",           "Teleports to trash/mess, fires prompts",          "AutoClean",        C.accent)
MkToggle(mp,"⛏", "Auto Fill Tunnels",   "Finds + fills escape holes in your tycoon",       "AutoFillTunnels",  C.orange)
MkToggle(mp,"🚔","Auto Arrest",          "Caches criminal NPCs, teleports + arrests",       "AutoArrest",       C.blue)
MkToggle(mp,"🏪","Auto Buy Items",       "Buys essentials when you have enough cash",       "AutoBuy",          C.gold)
MkToggle(mp,"👷","Auto Hire Workers",    "Hires guards/chefs/janitors when affordable",     "AutoHire",         C.purple)
MkSec(mp, "Game Info")
MkCard(mp,{
    "My Prison by Windburst  ·  ID: 10118504428",
    "Build and manage your own prison tycoon",
    "Arrest criminals in Crime City streets to fill prison",
    "Keep prisoners happy: food, beds, sports, showers",
    "Max income ~$1,000/min with 100 happy prisoners",
    "Use Build tab for 4 one-click build templates",
}, C.accentDim)

-- GUARDS
local gp = pageFrames["Guards"]
MkSec(gp, "Guard Automation")
MkToggle(gp,"🚔","Auto Arrest Criminal",     "NPC cache + radius check + alive check",     "AutoArrest",    C.blue)
MkToggle(gp,"🔥","Auto Extinguish Fire",     "Snapshot scan for fires + teleport + fire",  "AutoExtinguish",C.red)
MkToggle(gp,"🚫","Auto Confiscate Contraband","Finds shivs/drugs, teleports + confiscates", "AutoContraband",C.orange)
MkSec(gp, "Arrest Settings")
MkSlider(gp,"📏","Arrest Radius","Studs · teleports inside this range to arrest","ArrestRadius",8,120,4)
MkSec(gp, "How Arrest Works")
MkCard(gp,{
    "1. Builds a cache of criminal NPC models every 5s",
    "2. For each NPC: checks it's alive (Humanoid.Health > 0)",
    "3. Teleports to just inside the arrest radius",
    "4. Fires every ProximityPrompt on the NPC model",
    "5. Fires arrest remotes: Arrest, ArrestCriminal, Handcuff",
    "6. Criminal NPCs = models in Workspace named Criminal etc.",
    "7. Also checks Wanted/IsCriminal Value + Attributes",
}, C.blueDim)

-- STAFF
local sp = pageFrames["Staff"]
MkSec(sp, "Staff Automation")
MkToggle(sp,"🧹","Auto Clean",           "Removes trash/mess/laundry in your tycoon",      "AutoClean",        C.accent)
MkToggle(sp,"⛏", "Auto Fill Tunnels",   "Fills escape tunnels flagged by guards",          "AutoFillTunnels",  C.orange)
MkToggle(sp,"🍽","Auto Feed Prisoners",  "Restocks buffets and food stations",              "AutoFeed",         C.blue)
MkSec(sp, "Scan Rate")
MkSlider(sp,"⏱","Scan Rate","How often the automation loop fires  (lower = faster)","ScanRateRaw",5,50,1)
MkSec(sp, "Worker Costs  (from wiki)")
MkCard(sp,{
    "Guard:      $100 hire · $5/hr  · 1 per 5 prisoners",
    "Chef:       $100 hire · $8/hr  · needs oven+sink+fridge",
    "Janitor:    $500 hire · $20/hr · cleans all trash",
    "Repairman:  $550 hire · $15/hr · fills tunnels",
    "Nurse:      $1,000   · heals sick prisoners (research req)",
    "Dog:        $750     · finds tunnels (research req)",
}, C.orangeDim)

-- BUILD
local bp = pageFrames["Build"]
MkSec(bp, "One-Click Build Templates")
MkCard(bp,{
    "Pick a template to auto-buy + auto-hire everything.",
    "Script checks your money first and shows what you need.",
    "Hit STOP at any time to cancel mid-build.",
}, C.accentDim)

for _, tmpl in ipairs(TEMPLATES) do
    local card = Instance.new("Frame"); card.BackgroundColor3 = C.bgCard; card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y; card.Size = UDim2.new(1,0,0,0); card.ZIndex = 5; card.Parent = bp
    Cor(card,9); Str(card,C.goldDim,1,0.18); Pad(card,10,10,9,10)
    local inner = Instance.new("Frame"); inner.AutomaticSize = Enum.AutomaticSize.Y; inner.Size = UDim2.new(1,0,0,0)
    inner.BackgroundTransparency = 1; inner.ZIndex = 6; inner.Parent = card; Lst(inner,5)
    -- header row
    local hrow = Instance.new("Frame"); hrow.Size = UDim2.new(1,0,0,38); hrow.BackgroundTransparency = 1; hrow.ZIndex = 7; hrow.Parent = inner
    local ico = Instance.new("TextLabel"); ico.Size = UDim2.new(0,28,1,0); ico.BackgroundTransparency = 1; ico.Text = tmpl.icon; ico.TextSize = 21; ico.Font = Enum.Font.GothamBold; ico.ZIndex = 8; ico.Parent = hrow
    local tnm = Instance.new("TextLabel"); tnm.Size = UDim2.new(1,-92,0,20); tnm.Position = UDim2.new(0,32,0,0); tnm.BackgroundTransparency = 1; tnm.Font = Enum.Font.GothamBold; tnm.TextColor3 = C.gold; tnm.TextSize = 13; tnm.TextXAlignment = Enum.TextXAlignment.Left; tnm.Text = tmpl.name; tnm.ZIndex = 8; tnm.Parent = hrow
    local costL = Instance.new("TextLabel"); costL.Size = UDim2.new(0,78,0,20); costL.Position = UDim2.new(1,-80,0,2); costL.BackgroundTransparency = 1; costL.Font = Enum.Font.GothamBold; costL.TextColor3 = C.accent; costL.TextSize = 13; costL.TextXAlignment = Enum.TextXAlignment.Right; costL.Text = "$"..tmpl.cost; costL.ZIndex = 8; costL.Parent = hrow
    local tdc = Instance.new("TextLabel"); tdc.Size = UDim2.new(1,-32,0,14); tdc.Position = UDim2.new(0,32,0,24); tdc.BackgroundTransparency = 1; tdc.Font = Enum.Font.Gotham; tdc.TextColor3 = C.textMid; tdc.TextSize = 10; tdc.TextXAlignment = Enum.TextXAlignment.Left; tdc.Text = tmpl.desc; tdc.ZIndex = 8; tdc.Parent = hrow
    -- progress label
    local pLbl = Instance.new("TextLabel"); pLbl.Size = UDim2.new(1,0,0,14); pLbl.BackgroundTransparency = 1
    pLbl.Font = Enum.Font.Gotham; pLbl.TextColor3 = C.accent; pLbl.TextSize = 10
    pLbl.TextXAlignment = Enum.TextXAlignment.Left; pLbl.Text = ""; pLbl.ZIndex = 7; pLbl.Parent = inner
    -- buttons
    local brow = Instance.new("Frame"); brow.Size = UDim2.new(1,0,0,30); brow.BackgroundTransparency = 1; brow.ZIndex = 7; brow.Parent = inner
    local bls = Instance.new("UIListLayout"); bls.FillDirection = Enum.FillDirection.Horizontal; bls.Padding = UDim.new(0,6); bls.Parent = brow
    local function mkSB(txt,col,tc)
        local b = Instance.new("TextButton"); b.Size = UDim2.new(0.5,-3,1,0); b.BackgroundColor3 = col
        b.Font = Enum.Font.GothamBold; b.TextColor3 = tc or C.bg; b.TextSize = 11; b.Text = txt
        b.BorderSizePixel = 0; b.ZIndex = 8; b.Parent = brow; Cor(b,7); return b
    end
    local buildB = mkSB("BUILD  "..tmpl.icon, C.gold, C.bg)
    local stopB  = mkSB("STOP  ✕",            C.redDim,  C.red)
    local capturedTmpl = tmpl
    local capturedLbl  = pLbl
    buildB.MouseButton1Click:Connect(function()
        if State.BuildRunning then Notify("Already building! Stop first.",C.red,"⚠"); return end
        Notify("Starting: "..capturedTmpl.name, C.gold, capturedTmpl.icon)
        task.spawn(function()
            RunBuildTemplate(capturedTmpl, function(txt)
                if capturedLbl and capturedLbl.Parent then capturedLbl.Text = txt end
                if txt == "COMPLETE!"          then Notify(capturedTmpl.name.." COMPLETE!", C.accent,"✅")
                elseif txt:find("NEED",1,true) then Notify(txt, C.red,"💰") end
            end)
        end)
    end)
    stopB.MouseButton1Click:Connect(function()
        State.BuildRunning = false
        if capturedLbl and capturedLbl.Parent then capturedLbl.Text = "Stopped." end
        task.delay(1.5, function() if capturedLbl and capturedLbl.Parent then capturedLbl.Text = "" end end)
        Notify("Build stopped", C.textDim,"✕")
    end)
end

MkSec(bp, "Manual Worker Hire")
for _, w in ipairs(WORKERS) do
    MkBtn(bp, w.icon, "Hire "..w.name, "Cost $"..w.cost.."  ·  "..w.desc, C.purple, function()
        local m = GetMoney()
        if m < w.cost then Notify("Need $"..(w.cost-m).." more to hire "..w.name, C.red,"💰"); return end
        TryHireWorker(w.name); Notify("Hired "..w.name.."!", C.purple, w.icon)
    end)
end

-- SHOP
local shp = pageFrames["Shop"]
MkSec(shp, "Auto Purchase")
MkToggle(shp,"🏪","Auto Buy Items",    "Continuously buys items when affordable","AutoBuy",  C.gold)
MkToggle(shp,"👷","Auto Hire Workers", "Continuously hires workers when affordable","AutoHire",C.purple)
MkSec(shp, "Manual Item Buy")
for _, item in ipairs(ITEMS) do
    MkBtn(shp, item.icon, item.name, "$"..item.cost.."  ·  "..item.desc, C.gold, function()
        local m = GetMoney()
        if m < item.cost then Notify("Need $"..(item.cost-m).." more for "..item.name, C.red,"💰"); return end
        TryBuyItem(item.name); Notify("Bought "..item.name.."!", C.gold, item.icon)
    end)
end

-- CODES
local cp = pageFrames["Codes"]
MkSec(cp, "Active Codes  (March 2026)")
MkCard(cp,{
    "Source: robloxden.com  ·  5 active codes found",
    "Codes give free Cash to spend on your prison.",
    "Click REDEEM ALL or individual codes below.",
}, C.accentDim)
MkBtn(cp,"🎁","REDEEM ALL 5 CODES","Tries all active codes in sequence",C.accent,function()
    Notify("Redeeming all codes...",C.accent,"🎁")
    task.spawn(function()
        for _, info in ipairs(CODES) do
            RedeemCode(info.code)
            Notify("Tried: "..info.code.."  ("..info.reward..")", C.textMid,"🎟")
            task.wait(0.9)
        end
        Notify("All 5 codes attempted!", C.accent,"✅")
    end)
end)
MkSec(cp, "Individual Codes")
for _, info in ipairs(CODES) do
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,50); row.BackgroundColor3 = C.bgCard
    row.BorderSizePixel = 0; row.ZIndex = 5; row.Parent = cp; Cor(row,9); Str(row,C.accentDim,1,0.28)
    local cL = Instance.new("TextLabel"); cL.Size = UDim2.new(1,-110,0,20); cL.Position = UDim2.new(0,12,0,6)
    cL.BackgroundTransparency = 1; cL.Font = Enum.Font.GothamBold; cL.TextColor3 = C.text; cL.TextSize = 13
    cL.TextXAlignment = Enum.TextXAlignment.Left; cL.Text = info.code; cL.ZIndex = 6; cL.Parent = row
    local rL = Instance.new("TextLabel"); rL.Size = UDim2.new(1,-110,0,14); rL.Position = UDim2.new(0,12,0,28)
    rL.BackgroundTransparency = 1; rL.Font = Enum.Font.Gotham; rL.TextColor3 = C.gold; rL.TextSize = 10
    rL.TextXAlignment = Enum.TextXAlignment.Left; rL.Text = "Reward: "..info.reward; rL.ZIndex = 6; rL.Parent = row
    local badge = Instance.new("Frame"); badge.Size = UDim2.new(0,56,0,19); badge.Position = UDim2.new(1,-66,0,6)
    badge.BackgroundColor3 = C.accentDim; badge.BorderSizePixel = 0; badge.ZIndex = 6; badge.Parent = row; Cor(badge,5)
    local bL = Instance.new("TextLabel"); bL.Size = UDim2.new(1,0,1,0); bL.BackgroundTransparency = 1
    bL.Font = Enum.Font.GothamBold; bL.TextColor3 = C.accent; bL.TextSize = 9; bL.Text = "ACTIVE"; bL.ZIndex = 7; bL.Parent = badge
    local rdmB = Instance.new("TextButton"); rdmB.Size = UDim2.new(0,56,0,18); rdmB.Position = UDim2.new(1,-66,0,27)
    rdmB.BackgroundColor3 = C.accentDim; rdmB.Font = Enum.Font.GothamBold; rdmB.TextColor3 = C.accent; rdmB.TextSize = 9
    rdmB.Text = "REDEEM"; rdmB.BorderSizePixel = 0; rdmB.ZIndex = 7; rdmB.Parent = row; Cor(rdmB,5)
    local captInf = info
    rdmB.MouseButton1Click:Connect(function()
        RedeemCode(captInf.code)
        Notify("Redeemed: "..captInf.code.."  ("..captInf.reward..")", C.accent,"🎁")
    end)
    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,-124,1,0); hit.BackgroundTransparency = 1
    hit.Text = ""; hit.ZIndex = 8; hit.Parent = row
    hit.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=C.bgHover},0.12) end)
    hit.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=C.bgCard}, 0.12) end)
end

-- ═══════════════════════════════════════
-- DRAG
-- ═══════════════════════════════════════
local dragging, dragStart, winStart = false, nil, nil
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; winStart = Main.Position
    end
end)
Header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                  or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        local nx = winStart.X.Offset + d.X
        local ny = winStart.Y.Offset + d.Y
        Main.Position   = UDim2.new(winStart.X.Scale, nx,    winStart.Y.Scale, ny)
        Glow.Position   = UDim2.new(winStart.X.Scale, nx-16, winStart.Y.Scale, ny-16)
        Shadow.Position = UDim2.new(winStart.X.Scale, nx-6,  winStart.Y.Scale, ny+7)
    end
end)

-- ═══════════════════════════════════════
-- MINIMISE
-- ═══════════════════════════════════════
MinBtn.MouseButton1Click:Connect(function()
    State.Minimized = not State.Minimized
    if State.Minimized then
        Tw(Main,  {Size=UDim2.new(0,WIN_W,0,62)},    0.3,Enum.EasingStyle.Back)
        Tw(Glow,  {Size=UDim2.new(0,WIN_W+32,0,94)}, 0.3,Enum.EasingStyle.Back)
        Tw(Shadow,{Size=UDim2.new(0,WIN_W+12,0,74)}, 0.3,Enum.EasingStyle.Back)
        MinBtn.Text = "+"
    else
        Tw(Main,  {Size=UDim2.new(0,WIN_W,0,WIN_H)},    0.35,Enum.EasingStyle.Back)
        Tw(Glow,  {Size=UDim2.new(0,WIN_W+32,0,WIN_H+32)},0.35,Enum.EasingStyle.Back)
        Tw(Shadow,{Size=UDim2.new(0,WIN_W+12,0,WIN_H+12)},0.35,Enum.EasingStyle.Back)
        MinBtn.Text = "─"
    end
end)

-- ═══════════════════════════════════════
-- CLOSE
-- ═══════════════════════════════════════
CloseBtn.MouseButton1Click:Connect(function()
    State.GuiOpen = false
    Tw(Main,  {Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.28,Enum.EasingStyle.Back)
    Tw(Glow,  {BackgroundTransparency=1},0.28)
    Tw(Shadow,{BackgroundTransparency=1},0.28)
    task.delay(0.32, function()
        if Main   then Main.Visible   = false end
        if Glow   then Glow.Visible   = false end
        if Shadow then Shadow.Visible = false end
    end)
    Notify("GUI closed  ·  RightShift to reopen", C.textDim,"✕")
end)

-- ═══════════════════════════════════════
-- KEYBIND  RightShift
-- ═══════════════════════════════════════
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        State.GuiOpen = not State.GuiOpen
        if State.GuiOpen then
            Main.Visible = true; Glow.Visible = true; Shadow.Visible = true
            State.Minimized = false; MinBtn.Text = "─"
            Main.Size = UDim2.new(0,WIN_W,0,0)
            Tw(Main,  {Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0},0.4,Enum.EasingStyle.Back)
            Tw(Glow,  {BackgroundTransparency=0.78},0.4)
            Tw(Shadow,{BackgroundTransparency=0.44},0.4)
        else
            Tw(Main,  {Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.28,Enum.EasingStyle.Back)
            Tw(Glow,  {BackgroundTransparency=1},0.28)
            Tw(Shadow,{BackgroundTransparency=1},0.28)
            task.delay(0.32,function()
                if Main   then Main.Visible   = false end
                if Glow   then Glow.Visible   = false end
                if Shadow then Shadow.Visible = false end
            end)
        end
    end
end)

-- ═══════════════════════════════════════
-- ENTRY ANIMATION
-- ═══════════════════════════════════════
SwitchTab("Main")
Main.Position   = UDim2.new(0.5, -WIN_W/2,    -0.35, 0)
Glow.Position   = UDim2.new(0.5, -WIN_W/2-16, -0.35, -16)
Shadow.Position = UDim2.new(0.5, -WIN_W/2-6,  -0.35, 7)
Tw(Main,  {Position=UDim2.new(0.5,-WIN_W/2,    0.5,-WIN_H/2)},   0.75,Enum.EasingStyle.Back)
Tw(Glow,  {Position=UDim2.new(0.5,-WIN_W/2-16, 0.5,-WIN_H/2-16)},0.75,Enum.EasingStyle.Back)
Tw(Shadow,{Position=UDim2.new(0.5,-WIN_W/2-6,  0.5,-WIN_H/2+7)}, 0.75,Enum.EasingStyle.Back)
task.delay(0.9,  function() Notify("My Prison Ultimate Hub v6.1 loaded!", C.accent,"🔒") end)
task.delay(1.6,  function() Notify("5 active codes ready in the Codes tab", C.gold,"🎁") end)
task.delay(2.3,  function() Notify("4 build templates ready in the Build tab", C.purple,"🏗") end)
print("[MyPrison v6.1]  Loaded OK  ·  RightShift = toggle GUI")
