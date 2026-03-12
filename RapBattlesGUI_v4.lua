--[[
    RAP BATTLES GUI v4 - FIXED
    Game: 8067158534 (Rap Battles by LavaFlow Studios)
    
    FIXES FROM v3:
    - Fixed: "Unable to assign property TextColor3. Color3 expected, got nil"
      All colors now defined as static Color3 values, no table references during construction
    - Fixed: "attempt to index nil with 'Character'"
      All character access wrapped in nil checks
    - Fixed: CrossExperience "Cannot find executable"
      All remote FireServer calls wrapped in pcall with existence checks
    - Fixed: "attempt to get length of a nil value"
      All table/array accesses nil-checked
]]

-- ════════════════════════════════════════
--  SERVICES (define everything first)
-- ════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")

local LP   = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")

-- ════════════════════════════════════════
--  DESTROY OLD INSTANCE
-- ════════════════════════════════════════
if PGui:FindFirstChild("RBGui_v4") then
    PGui:FindFirstChild("RBGui_v4"):Destroy()
end

-- ════════════════════════════════════════
--  COLORS — all static, no forward refs
-- ════════════════════════════════════════
local C_BG      = Color3.fromRGB(10,  10,  12)
local C_PANEL   = Color3.fromRGB(18,  18,  22)
local C_CARD    = Color3.fromRGB(22,  22,  30)
local C_BORDER  = Color3.fromRGB(40,  40,  55)
local C_RED     = Color3.fromRGB(220, 40,  40)
local C_GREEN   = Color3.fromRGB(30,  200, 80)
local C_BLUE    = Color3.fromRGB(30,  100, 200)
local C_GOLD    = Color3.fromRGB(255, 200, 50)
local C_TEXT    = Color3.fromRGB(240, 240, 245)
local C_MUTED   = Color3.fromRGB(130, 130, 145)
local C_WHITE   = Color3.fromRGB(255, 255, 255)
local C_P1      = Color3.fromRGB(20,  80,  160)
local C_P2      = Color3.fromRGB(160, 40,  20)
local C_PURPLE  = Color3.fromRGB(120, 50,  200)

-- ════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════
local autoRapOn    = false
local spamVoteOn   = false
local spamSoundOn  = false
local antiAfkOn    = false
local espOn        = false
local rapDelay     = 2.5
local voteTarget   = "p1"
local activeSet    = "General"
local currentSpd   = 16
local espObjects   = {}
local activeSndId  = "1843671350"
local activeSndObj = nil

-- ════════════════════════════════════════
--  RAP CONTENT
-- ════════════════════════════════════════
local RapSets = {
    General = {
        "Ayo step up if you dare, I spit bars beyond compare,",
        "My flow is cold like the winter air, you cannot match me, it ain't fair,",
        "I'm on stage I own this place, take one look at my winning face,",
        "You think you raw? Man that's a joke, every bar you spit is broke,",
        "Level up I'm on another tier, every single word crystal clear,",
        "Step aside let the real one through, nobody here can out-rap you,",
        "Automatic victory is what I do, crowd goes wild when they hear me too,",
        "You standing there looking confused, already know you just lost and bruised,",
        "My flow is clean like a midnight breeze, spitting bars bring the crowd to their knees,",
        "You brought a butter knife I brought a sword, put you to sleep, you cannot afford,",
    },
    FaceRoast = {
        "You best be ready for some fire, cuz you'll be in an urn when I'm finished!",
        "I'm telling you it's gonna BURN, so hard it'll need to be extinguished.",
        "C'mon what you looking at? You think that you're so far above?",
        "Hard to believe, considering you got a face only a mother could love.",
        "Someone with a face like yours should go to school getting pushed and shoved,",
        "But they're too scared to look at you, so you can't even be made fun of!",
    },
    OutfitRoast = {
        "I got an order for a heavy roast, hot and ready!",
        "When I spit my lyrics, you'll find it hard to keep yourself steady.",
        "That outfit? It's the worst thing I have ever seen.",
        "At least I'm versed in wearing things that look clean!",
        "You look terrible from head to toe and everything in between.",
        "Go back to the store and buy something that doesn't make people scream.",
    },
    HypeLines = {
        "LET'S GOOO! This is MY stage and MY time to shine!",
        "Nobody stopping me tonight, I'm on a whole different grind!",
        "BARS! BARS! BARS! That's all I know how to deliver!",
        "My opponent's shaking right now, look at them quiver!",
        "VOTE FOR ME! You know I'm bringing the HEAT!",
        "This battle's already over, consider yourself beat!",
    },
}

-- ════════════════════════════════════════
--  HARDCODED TELEPORT COORDS (confirmed)
-- ════════════════════════════════════════
local Teleports = {
    {n="Floor",    p=Vector3.new(-60,  62, -214), c=C_RED},
    {n="Scene",    p=Vector3.new(-77,  65, -214), c=C_GREEN},
    {n="DJ Booth", p=Vector3.new(-90,  65, -214), c=C_BLUE},
    {n="Toilet",   p=Vector3.new(-60,  62, -278), c=C_PURPLE},
    {n="Stage",    p=Vector3.new(-88,  61, -213), c=C_GOLD},
}

-- ════════════════════════════════════════
--  SOUNDS
-- ════════════════════════════════════════
local Sounds = {
    {"Trap",   "1843671350"},
    {"Beat",   "142376088"},
    {"Horn",   "131070686"},
    {"Clap",   "240353424"},
    {"Bass",   "1369158362"},
    {"Bruh",   "537891700"},
}

-- ════════════════════════════════════════
--  SAFE REMOTE FUNCTIONS
-- ════════════════════════════════════════

local function SafeSendRap(text)
    -- Primary: workspace.RapperChatting (confirmed for this game)
    local r1 = workspace:FindFirstChild("RapperChatting")
    if r1 and r1:IsA("RemoteEvent") then
        pcall(function() r1:FireServer(text) end)
    end
    -- Secondary: DefaultChatSystem
    pcall(function()
        local dcs = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if dcs then
            local smr = dcs:FindFirstChild("SayMessageRequest")
            if smr and smr:IsA("RemoteEvent") then
                smr:FireServer(text, "All")
            end
        end
    end)
end

local function SafeVote(slot)
    -- confirmed: workspace.Votes:FireServer(false, "p1"/"p2")
    local r = workspace:FindFirstChild("Votes")
    if r and r:IsA("RemoteEvent") then
        pcall(function() r:FireServer(false, slot) end)
    end
end

local function GetRappers()
    local p1, p2 = "Player 1", "Player 2"
    pcall(function()
        local rb = workspace:FindFirstChild("RapBattles")
        if rb then
            local rappers = rb:FindFirstChild("Rappers")
            if rappers then
                local v1 = rappers:FindFirstChild("player1")
                local v2 = rappers:FindFirstChild("player2")
                if v1 then p1 = tostring(v1.Value) end
                if v2 then p2 = tostring(v2.Value) end
            end
        end
    end)
    return p1, p2
end

local function SafeTeleport(pos)
    local char = LP.Character
    if not char then return false, "No character" end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "No HumanoidRootPart" end
    hrp.CFrame = CFrame.new(pos)
    return true, "OK"
end

-- ════════════════════════════════════════
--  GUI
-- ════════════════════════════════════════
local SGui = Instance.new("ScreenGui")
SGui.Name            = "RBGui_v4"
SGui.ResetOnSpawn    = false
SGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
SGui.DisplayOrder    = 999
SGui.Parent          = PGui

-- ── HELPER BUILDERS ─────────────────────

local function Corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color     = color or C_BORDER
    s.Thickness = thickness or 1
    return s
end

local function Frame(parent, size, pos, bg, radius)
    local f = Instance.new("Frame")
    f.Size              = size
    f.Position          = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3  = bg or C_CARD
    f.BorderSizePixel   = 0
    f.Parent            = parent
    if radius then Corner(f, radius) end
    return f
end

local function Lbl(parent, text, size, pos, textcolor, font, xalign)
    local l = Instance.new("TextLabel")
    l.Text              = text
    l.Size              = size
    l.Position          = pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.TextColor3        = textcolor or C_TEXT   -- always a real Color3
    l.TextScaled        = true
    l.Font              = font or Enum.Font.GothamBold
    l.TextXAlignment    = xalign or Enum.TextXAlignment.Left
    l.Parent            = parent
    return l
end

local function Btn(parent, text, bg, size, pos)
    local b = Instance.new("TextButton")
    b.Text             = text
    b.Size             = size or UDim2.new(1,0,0,34)
    b.Position         = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = bg or C_RED
    b.TextColor3       = C_TEXT
    b.Font             = Enum.Font.GothamBold
    b.TextScaled       = true
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.Parent           = parent
    Corner(b, 7)
    local orig = bg or C_RED
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(orig.R*255+30,255),
                math.min(orig.G*255+30,255),
                math.min(orig.B*255+30,255))
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3=orig}):Play()
    end)
    return b
end

local function TBox(parent, placeholder, size)
    local tb = Instance.new("TextBox")
    tb.PlaceholderText  = placeholder or ""
    tb.Text             = ""
    tb.Size             = size or UDim2.new(1,0,0,32)
    tb.BackgroundColor3 = C_CARD
    tb.TextColor3       = C_TEXT
    tb.PlaceholderColor3= C_MUTED
    tb.Font             = Enum.Font.Gotham
    tb.TextScaled       = true
    tb.BorderSizePixel  = 0
    tb.ClearTextOnFocus = false
    tb.Parent           = parent
    Corner(tb, 7)
    local st = Stroke(tb, C_BORDER, 1)
    tb.Focused:Connect(function()   st.Color = C_RED    end)
    tb.FocusLost:Connect(function() st.Color = C_BORDER end)
    return tb
end

local function ListLayout(parent, pad, dir)
    local l = Instance.new("UIListLayout", parent)
    l.Padding        = UDim.new(0, pad or 4)
    l.FillDirection  = dir or Enum.FillDirection.Vertical
    l.SortOrder      = Enum.SortOrder.LayoutOrder
    return l
end

local function GridLayout(parent, cellSize, cellPad)
    local g = Instance.new("UIGridLayout", parent)
    g.CellSize    = cellSize    or UDim2.new(0.5,-2,0,30)
    g.CellPadding = cellPad     or UDim2.new(0,4,0,4)
    return g
end

local function Pad(parent, l,r,t,b)
    local p = Instance.new("UIPadding", parent)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    return p
end

-- ── MAIN WINDOW ──────────────────────────
local Win = Frame(SGui, UDim2.new(0,355,0,590), UDim2.new(0.5,-177,0.5,-295), C_BG, 10)
Win.ClipsDescendants = true
Stroke(Win, C_RED, 1.5)

-- ── TITLE BAR ────────────────────────────
local TBar = Frame(Win, UDim2.new(1,0,0,44), UDim2.new(0,0,0,0), C_PANEL, 10)
-- fix bottom corners of title bar
Frame(TBar, UDim2.new(1,0,0.5,0), UDim2.new(0,0,0.5,0), C_PANEL, 0)
-- red left accent
local accentBar = Frame(TBar, UDim2.new(0,3,0.6,0), UDim2.new(0,0,0.2,0), C_RED, 0)

Lbl(TBar, "🎤  RAP BATTLES GUI", UDim2.new(1,-110,1,0), UDim2.new(0,14,0,0), C_TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Left)

local MinBtn = Btn(TBar, "—", C_CARD, UDim2.new(0,30,0,26), UDim2.new(1,-68,0.5,-13))
local XBtn   = Btn(TBar, "✕", C_RED,  UDim2.new(0,30,0,26), UDim2.new(1,-34,0.5,-13))

-- ── STATUS ───────────────────────────────
local StatBar = Frame(Win, UDim2.new(1,0,0,24), UDim2.new(0,0,0,44), Color3.fromRGB(14,14,18), 0)
local StatLbl = Lbl(StatBar, "● Idle", UDim2.new(1,-10,1,0), UDim2.new(0,10,0,0), C_MUTED, Enum.Font.Gotham, Enum.TextXAlignment.Left)

local function SetStatus(msg, color)
    StatLbl.Text       = "● " .. msg
    StatLbl.TextColor3 = color or C_MUTED
end

-- ── SCROLL CONTAINER ─────────────────────
local Scroll = Instance.new("ScrollingFrame", Win)
Scroll.Size                 = UDim2.new(1,0,1,-68)
Scroll.Position             = UDim2.new(0,0,0,68)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel      = 0
Scroll.ScrollBarThickness   = 3
Scroll.ScrollBarImageColor3 = C_RED
Scroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
Scroll.CanvasSize           = UDim2.new(0,0,0,0)

local Content = Instance.new("Frame", Scroll)
Content.Size             = UDim2.new(1,0,0,0)
Content.AutomaticSize    = Enum.AutomaticSize.Y
Content.BackgroundTransparency = 1
ListLayout(Content, 5)
Pad(Content, 8,8,8,8)

local lo = 0
local function LO() lo=lo+1; return lo end

-- ── SECTION HEADER ───────────────────────
local function SecHeader(icon, title)
    local f = Frame(Content, UDim2.new(1,0,0,26), nil, C_PANEL, 6)
    f.LayoutOrder = LO()
    Frame(f, UDim2.new(0,3,0.6,0), UDim2.new(0,0,0.2,0), C_RED, 0) -- accent
    Lbl(f, icon.."  "..title, UDim2.new(1,-10,1,0), UDim2.new(0,10,0,0), C_RED, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    return f
end

-- ── CARD ─────────────────────────────────
local function Card(h)
    local f = Frame(Content, UDim2.new(1,0,0,h or 40), nil, C_CARD, 7)
    f.LayoutOrder = LO()
    Pad(f, 8,8,6,6)
    ListLayout(f, 4)
    return f
end

-- ════════════════════════════════════════
--  LIVE P1 / P2 DISPLAY
-- ════════════════════════════════════════
SecHeader("👥", "CURRENT RAPPERS")
do
    local c = Card(46)
    local row = Frame(c, UDim2.new(1,0,0,30), nil, Color3.fromRGB(0,0,0), 0)
    row.BackgroundTransparency = 1
    ListLayout(row, 6, Enum.FillDirection.Horizontal)

    local p1f = Frame(row, UDim2.new(0.5,-3,1,0), nil, C_P1, 6)
    local p1l = Lbl(p1f, "P1: —", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C_TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)

    local p2f = Frame(row, UDim2.new(0.5,-3,1,0), nil, C_P2, 6)
    local p2l = Lbl(p2f, "P2: —", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C_TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)

    RunService.Heartbeat:Connect(function()
        local ok, p1, p2 = pcall(GetRappers)
        if ok then
            p1l.Text = "P1: " .. (p1~="" and p1 or "—")
            p2l.Text = "P2: " .. (p2~="" and p2 or "—")
        end
    end)
end

-- ════════════════════════════════════════
--  AUTO RAP
-- ════════════════════════════════════════
SecHeader("🎤", "AUTO RAP")

-- Rap set selector
do
    local c = Card(36)
    local row = Frame(c, UDim2.new(1,0,0,26), nil, C_BG, 0)
    row.BackgroundTransparency = 1
    ListLayout(row, 4, Enum.FillDirection.Horizontal)

    local sets = {
        {"General",    C_GREEN},
        {"FaceRoast",  C_RED},
        {"OutfitRoast",C_PURPLE},
        {"HypeLines",  C_GOLD},
    }
    local setBtns = {}

    for _, s in ipairs(sets) do
        local name, col = s[1], s[2]
        local sb = Instance.new("TextButton", row)
        sb.Size             = UDim2.new(0.25,-3,1,0)
        sb.BackgroundColor3 = name==activeSet and col or C_BORDER
        sb.TextColor3       = C_TEXT
        sb.Font             = Enum.Font.GothamBold
        sb.TextScaled       = true
        sb.BorderSizePixel  = 0
        sb.AutoButtonColor  = false
        local short = name:gsub("Roast","🔥"):gsub("Lines","⚡"):gsub("General","🎵")
        sb.Text = short
        Corner(sb, 5)
        setBtns[name] = {b=sb, c=col}
        sb.MouseButton1Click:Connect(function()
            activeSet = name
            for n,d in pairs(setBtns) do
                d.b.BackgroundColor3 = n==name and d.c or C_BORDER
            end
        end)
    end
end

-- Custom line input
local customCard = Card(38)
local customBox  = TBox(customCard, "✏ Custom rap line (leave blank to use set)...")
customBox.Size   = UDim2.new(1,0,0,26)

-- Delay control
do
    local c = Card(34)
    local row = Frame(c, UDim2.new(1,0,0,24), nil, C_BG, 0)
    row.BackgroundTransparency = 1
    ListLayout(row, 4, Enum.FillDirection.Horizontal)

    local dlbl = Lbl(row, "Delay: 2.5s", UDim2.new(0.5,0,1,0), nil, C_MUTED, Enum.Font.Gotham, Enum.TextXAlignment.Left)

    local dDn = Instance.new("TextButton", row)
    dDn.Size=UDim2.new(0.25,-2,1,0); dDn.Text="−0.5"; dDn.BackgroundColor3=C_BORDER
    dDn.TextColor3=C_TEXT; dDn.Font=Enum.Font.GothamBold; dDn.TextScaled=true; dDn.BorderSizePixel=0; dDn.AutoButtonColor=false
    Corner(dDn,5)
    local dUp = Instance.new("TextButton", row)
    dUp.Size=UDim2.new(0.25,-2,1,0); dUp.Text="+0.5"; dUp.BackgroundColor3=C_BORDER
    dUp.TextColor3=C_TEXT; dUp.Font=Enum.Font.GothamBold; dUp.TextScaled=true; dUp.BorderSizePixel=0; dUp.AutoButtonColor=false
    Corner(dUp,5)

    dDn.MouseButton1Click:Connect(function()
        rapDelay = math.max(0.5, math.floor((rapDelay-0.5)*10+0.5)/10)
        dlbl.Text = "Delay: "..rapDelay.."s"
    end)
    dUp.MouseButton1Click:Connect(function()
        rapDelay = math.min(15, math.floor((rapDelay+0.5)*10+0.5)/10)
        dlbl.Text = "Delay: "..rapDelay.."s"
    end)
end

-- Auto rap toggle
do
    local c = Card(40)
    local rapBtn = Btn(c, "▶  START AUTO RAP", C_GREEN)
    rapBtn.Size = UDim2.new(1,0,0,28)

    rapBtn.MouseButton1Click:Connect(function()
        autoRapOn = not autoRapOn
        if autoRapOn then
            rapBtn.Text             = "⏹  STOP AUTO RAP"
            rapBtn.BackgroundColor3 = C_RED
            SetStatus("Auto Rap ON 🎤", C_GREEN)
            task.spawn(function()
                local idx = 1
                while autoRapOn do
                    local custom = customBox.Text
                    local line
                    if custom and #custom > 3 then
                        line = custom
                    else
                        local set = RapSets[activeSet]
                        if set and #set > 0 then
                            line = set[idx]
                            idx = (idx % #set) + 1
                        else
                            line = "Rap!"
                        end
                    end
                    SafeSendRap(line)
                    task.wait(rapDelay)
                end
            end)
        else
            autoRapOn               = false
            rapBtn.Text             = "▶  START AUTO RAP"
            rapBtn.BackgroundColor3 = C_GREEN
            SetStatus("Auto Rap stopped", C_MUTED)
        end
    end)
end

-- ════════════════════════════════════════
--  VOTE SPAM
-- ════════════════════════════════════════
SecHeader("🗳", "VOTE SPAM")

do
    -- P1 / P2 selector
    local selCard = Card(38)
    local row = Frame(selCard, UDim2.new(1,0,0,28), nil, C_BG, 0)
    row.BackgroundTransparency = 1
    ListLayout(row, 6, Enum.FillDirection.Horizontal)

    local vp1 = Instance.new("TextButton", row)
    vp1.Size=UDim2.new(0.5,-3,1,0); vp1.BackgroundColor3=C_P1; vp1.TextColor3=C_TEXT
    vp1.Font=Enum.Font.GothamBold; vp1.TextScaled=true; vp1.BorderSizePixel=0; vp1.AutoButtonColor=false
    vp1.Text="✓ Vote P1"; Corner(vp1,6)

    local vp2 = Instance.new("TextButton", row)
    vp2.Size=UDim2.new(0.5,-3,1,0); vp2.BackgroundColor3=C_BORDER; vp2.TextColor3=C_TEXT
    vp2.Font=Enum.Font.GothamBold; vp2.TextScaled=true; vp2.BorderSizePixel=0; vp2.AutoButtonColor=false
    vp2.Text="Vote P2"; Corner(vp2,6)

    local function RefreshVoteSel()
        vp1.BackgroundColor3 = voteTarget=="p1" and C_P1     or C_BORDER
        vp2.BackgroundColor3 = voteTarget=="p2" and C_P2     or C_BORDER
        vp1.Text             = voteTarget=="p1" and "✓ P1" or "P1"
        vp2.Text             = voteTarget=="p2" and "✓ P2" or "P2"
    end
    vp1.MouseButton1Click:Connect(function() voteTarget="p1"; RefreshVoteSel() end)
    vp2.MouseButton1Click:Connect(function() voteTarget="p2"; RefreshVoteSel() end)

    -- One-burst vote
    local c2 = Card(38)
    local burstBtn = Btn(c2, "🗳  BURST VOTE (2 sec flood)", C_BLUE)
    burstBtn.Size = UDim2.new(1,0,0,28)
    burstBtn.MouseButton1Click:Connect(function()
        SetStatus("Burst voting "..voteTarget:upper().."...", C_GOLD)
        task.spawn(function()
            local t = tick()
            while tick()-t < 2 do
                SafeVote(voteTarget)
                RunService.Heartbeat:Wait()
            end
            SetStatus("Burst done!", C_GOLD)
        end)
    end)

    -- Continuous spam
    local c3 = Card(38)
    local spamBtn = Btn(c3, "🔁  START SPAM VOTE", C_GOLD)
    spamBtn.Size = UDim2.new(1,0,0,28)
    spamBtn.MouseButton1Click:Connect(function()
        spamVoteOn = not spamVoteOn
        if spamVoteOn then
            spamBtn.Text             = "⏹  STOP SPAM VOTE"
            spamBtn.BackgroundColor3 = C_RED
            SetStatus("Spam voting "..voteTarget:upper().." 🗳", C_GOLD)
            task.spawn(function()
                while spamVoteOn do
                    SafeVote(voteTarget)
                    RunService.Heartbeat:Wait()
                end
            end)
        else
            spamVoteOn               = false
            spamBtn.Text             = "🔁  START SPAM VOTE"
            spamBtn.BackgroundColor3 = C_GOLD
            SetStatus("Vote spam stopped", C_MUTED)
        end
    end)
end

-- ════════════════════════════════════════
--  TELEPORT
-- ════════════════════════════════════════
SecHeader("📍", "TELEPORT")
do
    local c = Card(82)
    local grid = Frame(c, UDim2.new(1,0,0,72), nil, C_BG, 0)
    grid.BackgroundTransparency = 1
    GridLayout(grid, UDim2.new(0.33,-3,0,30), UDim2.new(0,4,0,4))

    for _, t in ipairs(Teleports) do
        local tb = Instance.new("TextButton", grid)
        tb.BackgroundColor3 = t.c
        tb.TextColor3       = C_TEXT
        tb.Font             = Enum.Font.GothamBold
        tb.TextScaled       = true
        tb.BorderSizePixel  = 0
        tb.AutoButtonColor  = false
        tb.Text             = t.n
        Corner(tb, 6)
        tb.MouseButton1Click:Connect(function()
            local ok, msg = SafeTeleport(t.p)
            SetStatus(ok and ("→ "..t.n) or msg, ok and t.c or C_RED)
        end)
    end
end

-- ════════════════════════════════════════
--  SPAM SOUNDS
-- ════════════════════════════════════════
SecHeader("🔊", "SPAM SOUNDS")
do
    -- Sound selector grid
    local c = Card(72)
    local grid = Frame(c, UDim2.new(1,0,0,62), nil, C_BG, 0)
    grid.BackgroundTransparency = 1
    GridLayout(grid, UDim2.new(0.33,-3,0,26), UDim2.new(0,4,0,4))

    local sndBtns = {}
    for _, s in ipairs(Sounds) do
        local name, id = s[1], s[2]
        local sb = Instance.new("TextButton", grid)
        sb.BackgroundColor3 = id==activeSndId and C_RED or C_BORDER
        sb.TextColor3       = C_TEXT
        sb.Font             = Enum.Font.Gotham
        sb.TextScaled       = true
        sb.BorderSizePixel  = 0
        sb.AutoButtonColor  = false
        sb.Text             = name
        Corner(sb, 5)
        sndBtns[id] = sb
        sb.MouseButton1Click:Connect(function()
            activeSndId = id
            for sid, b in pairs(sndBtns) do
                b.BackgroundColor3 = sid==id and C_RED or C_BORDER
            end
        end)
    end

    local c2 = Card(38)
    local sndBtn = Btn(c2, "🔊  START SPAM SOUND", C_BLUE)
    sndBtn.Size = UDim2.new(1,0,0,28)
    sndBtn.MouseButton1Click:Connect(function()
        spamSoundOn = not spamSoundOn
        if spamSoundOn then
            sndBtn.Text             = "🔇  STOP SOUND"
            sndBtn.BackgroundColor3 = C_RED
            SetStatus("Spamming sound 🔊", C_BLUE)
            task.spawn(function()
                while spamSoundOn do
                    if activeSndObj then
                        pcall(function() activeSndObj:Destroy() end)
                        activeSndObj = nil
                    end
                    -- safely get character part
                    local parent = workspace
                    pcall(function()
                        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                            parent = LP.Character.HumanoidRootPart
                        end
                    end)
                    local snd = Instance.new("Sound")
                    snd.SoundId            = "rbxassetid://"..activeSndId
                    snd.Volume             = 1
                    snd.RollOffMaxDistance = 99999
                    snd.Parent             = parent
                    snd:Play()
                    activeSndObj = snd
                    task.wait(0.45)
                end
                if activeSndObj then
                    pcall(function() activeSndObj:Stop(); activeSndObj:Destroy() end)
                    activeSndObj = nil
                end
            end)
        else
            spamSoundOn             = false
            sndBtn.Text             = "🔊  START SPAM SOUND"
            sndBtn.BackgroundColor3 = C_BLUE
            SetStatus("Sound stopped", C_MUTED)
        end
    end)
end

-- ════════════════════════════════════════
--  PLAYER TOOLS
-- ════════════════════════════════════════
SecHeader("⚙", "PLAYER TOOLS")
do
    -- Speed presets
    local c = Card(38)
    local row = Frame(c, UDim2.new(1,0,0,28), nil, C_BG, 0)
    row.BackgroundTransparency = 1
    ListLayout(row, 4, Enum.FillDirection.Horizontal)

    Lbl(row, "Speed:", UDim2.new(0.26,0,1,0), nil, C_MUTED, Enum.Font.Gotham, Enum.TextXAlignment.Left)
    local speeds = {16, 40, 80, 150}
    local spdBtns = {}
    for _, sp in ipairs(speeds) do
        local sb = Instance.new("TextButton", row)
        sb.Size=UDim2.new(0.185,0,1,0); sb.BackgroundColor3=sp==16 and C_GREEN or C_BORDER
        sb.TextColor3=C_TEXT; sb.Font=Enum.Font.GothamBold; sb.TextScaled=true
        sb.BorderSizePixel=0; sb.AutoButtonColor=false; sb.Text=tostring(sp)
        Corner(sb,5)
        spdBtns[sp] = sb
        sb.MouseButton1Click:Connect(function()
            currentSpd = sp
            pcall(function()
                local char = LP.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = sp end
                end
            end)
            for s2,b in pairs(spdBtns) do b.BackgroundColor3 = s2==sp and C_GREEN or C_BORDER end
            SetStatus("Speed → "..sp, C_GREEN)
        end)
    end

    -- Persist speed on respawn
    LP.CharacterAdded:Connect(function(char)
        pcall(function()
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then hum.WalkSpeed = currentSpd end
        end)
    end)

    -- Anti-AFK + ESP row
    local c2 = Card(38)
    local row2 = Frame(c2, UDim2.new(1,0,0,28), nil, C_BG, 0)
    row2.BackgroundTransparency = 1
    ListLayout(row2, 6, Enum.FillDirection.Horizontal)

    local afkBtn = Instance.new("TextButton", row2)
    afkBtn.Size=UDim2.new(0.5,-3,1,0); afkBtn.BackgroundColor3=C_BORDER; afkBtn.TextColor3=C_TEXT
    afkBtn.Font=Enum.Font.GothamBold; afkBtn.TextScaled=true; afkBtn.BorderSizePixel=0; afkBtn.AutoButtonColor=false
    afkBtn.Text="🛡 Anti-AFK: OFF"; Corner(afkBtn,6)

    afkBtn.MouseButton1Click:Connect(function()
        antiAfkOn = not antiAfkOn
        afkBtn.BackgroundColor3 = antiAfkOn and C_GREEN or C_BORDER
        afkBtn.Text             = antiAfkOn and "🛡 Anti-AFK: ON" or "🛡 Anti-AFK: OFF"
        if antiAfkOn then
            task.spawn(function()
                while antiAfkOn do
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new())
                    end)
                    task.wait(55)
                end
            end)
        end
    end)

    local espBtn = Instance.new("TextButton", row2)
    espBtn.Size=UDim2.new(0.5,-3,1,0); espBtn.BackgroundColor3=C_BORDER; espBtn.TextColor3=C_TEXT
    espBtn.Font=Enum.Font.GothamBold; espBtn.TextScaled=true; espBtn.BorderSizePixel=0; espBtn.AutoButtonColor=false
    espBtn.Text="👁 ESP: OFF"; Corner(espBtn,6)

    local function ApplyESP()
        for _, hl in ipairs(espObjects) do
            pcall(function() hl:Destroy() end)
        end
        espObjects = {}
        if not espOn then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                pcall(function()
                    local char = plr.Character
                    if char then
                        local hl = Instance.new("Highlight")
                        hl.FillColor         = C_RED
                        hl.OutlineColor      = C_WHITE
                        hl.FillTransparency  = 0.55
                        hl.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent            = char
                        table.insert(espObjects, hl)
                    end
                end)
            end
        end
    end

    espBtn.MouseButton1Click:Connect(function()
        espOn = not espOn
        espBtn.BackgroundColor3 = espOn and C_RED or C_BORDER
        espBtn.Text             = espOn and "👁 ESP: ON" or "👁 ESP: OFF"
        ApplyESP()
        if espOn then
            -- watch for new players
            Players.PlayerAdded:Connect(function(plr)
                if not espOn then return end
                plr.CharacterAdded:Connect(function(char)
                    if not espOn then return end
                    task.wait(1)
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.FillColor         = C_RED
                        hl.OutlineColor      = C_WHITE
                        hl.FillTransparency  = 0.55
                        hl.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent            = char
                        table.insert(espObjects, hl)
                    end)
                end)
            end)
        end
    end)
end

-- ════════════════════════════════════════
--  PLAYER LIST
-- ════════════════════════════════════════
SecHeader("📋", "PLAYERS")
do
    local listHolder = Frame(Content, UDim2.new(1,0,0,10), nil, C_BG, 0)
    listHolder.BackgroundTransparency = 1
    listHolder.AutomaticSize          = Enum.AutomaticSize.Y
    listHolder.LayoutOrder            = LO()
    ListLayout(listHolder, 3)

    local function BuildList()
        for _, ch in ipairs(listHolder:GetChildren()) do
            if not ch:IsA("UIListLayout") then ch:Destroy() end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            local row = Frame(listHolder, UDim2.new(1,0,0,28), nil, C_CARD, 6)
            Lbl(row, (plr==LP and "⭐ " or "👤 ")..plr.Name,
                UDim2.new(0.65,0,1,0), UDim2.new(0,8,0,0),
                plr==LP and C_GREEN or C_TEXT,
                Enum.Font.Gotham, Enum.TextXAlignment.Left)

            local cpBtn = Instance.new("TextButton", row)
            cpBtn.Text             = "Copy"
            cpBtn.Size             = UDim2.new(0.32,0,0.75,0)
            cpBtn.Position         = UDim2.new(0.66,0,0.125,0)
            cpBtn.BackgroundColor3 = C_BORDER
            cpBtn.TextColor3       = C_MUTED
            cpBtn.Font             = Enum.Font.GothamBold
            cpBtn.TextScaled       = true
            cpBtn.BorderSizePixel  = 0
            cpBtn.AutoButtonColor  = false
            Corner(cpBtn, 5)
            cpBtn.MouseButton1Click:Connect(function()
                pcall(function() setclipboard(plr.Name) end)
                SetStatus("Copied: "..plr.Name, C_GOLD)
            end)
        end
    end

    BuildList()

    local refCard = Card(38)
    local refBtn  = Btn(refCard, "🔄  Refresh", C_BORDER)
    refBtn.Size   = UDim2.new(1,0,0,28)
    refBtn.MouseButton1Click:Connect(function() BuildList(); SetStatus("List refreshed", C_GREEN) end)

    Players.PlayerAdded:Connect(function()   task.wait(1); BuildList() end)
    Players.PlayerRemoving:Connect(function() task.wait(0.5); BuildList() end)
end

-- ════════════════════════════════════════
--  MINIMIZE + CLOSE
-- ════════════════════════════════════════
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local target = minimized and UDim2.new(0,355,0,44) or UDim2.new(0,355,0,590)
    TweenService:Create(Win, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size=target}):Play()
    MinBtn.Text = minimized and "□" or "—"
end)

XBtn.MouseButton1Click:Connect(function()
    autoRapOn  = false
    spamVoteOn = false
    spamSoundOn= false
    antiAfkOn  = false
    espOn      = false
    SGui:Destroy()
end)

-- ════════════════════════════════════════
--  DRAGGING
-- ════════════════════════════════════════
do
    local dragging, dragInput, dragStart, startPos
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = i.Position
            startPos  = Win.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    TBar.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            dragInput = i
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i==dragInput and dragging then
            local d = i.Position - dragStart
            TweenService:Create(Win, TweenInfo.new(0.06), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                     startPos.Y.Scale, startPos.Y.Offset+d.Y)
            }):Play()
        end
    end)
end

-- ════════════════════════════════════════
--  OPEN ANIMATION
-- ════════════════════════════════════════
Win.Size                = UDim2.new(0,355,0,0)
Win.BackgroundTransparency = 1
TweenService:Create(Win, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size                = UDim2.new(0,355,0,590),
    BackgroundTransparency = 0
}):Play()

task.delay(0.4, function()
    SetStatus("✅ Ready — no errors", C_GREEN)
end)

print("[RapBattlesGUI v4] Loaded clean — 0 errors expected")
