--[[
    ╔══════════════════════════════════════════════════════╗
    ║         EPIC RAP BATTLES GUI  v2.0                   ║
    ║         Game: Rap Battles (8067158534)               ║
    ║         By LavaFlow Studios                          ║
    ║                                                      ║
    ║  FEATURES:                                           ║
    ║   ✅ Auto Rap  (workspace.RapperChatting)            ║
    ║   ✅ Vote Spam  (workspace.Votes p1/p2)              ║
    ║   ✅ Spam Sounds (local + FE)                        ║
    ║   ✅ Teleport   (Stage / Floor / DJ / Toilet)        ║
    ║   ✅ Throw Tomatoes (spam)                           ║
    ║   ✅ Speed Hack                                      ║
    ║   ✅ Anti-AFK                                        ║
    ║   ✅ Player ESP                                      ║
    ║   ✅ Custom Rap Editor                               ║
    ║   ✅ Draggable + Minimizable UI                      ║
    ╚══════════════════════════════════════════════════════╝
]]

-- ══════════════════════════════════
--  SERVICES
-- ══════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local TextChatService  = game:GetService("TextChatService")

local LP  = Players.LocalPlayer
local PG  = LP:WaitForChild("PlayerGui")
local Cam = workspace.CurrentCamera

-- ══════════════════════════════════
--  RAP LINES  (auto-rap content)
-- ══════════════════════════════════
local RapLines = {
    "Ayo step up if you dare, I spit bars beyond compare,",
    "My flow is cold like the winter air, you can't match me, it ain't fair,",
    "Yo I'm on stage and I own this place, take one look at my winning face,",
    "You think you raw? Man that's a joke, every bar you spit is broke,",
    "I'm the king of this rap game scene, sharpest tongue you've ever seen,",
    "Level up I'm on another tier, every word crystal clear,",
    "Step aside let the real one through, nobody here can out-rap dude,",
    "Automatic victory, it's what I do, crowd goes wild when they hear me too,",
    "You standing there looking confused, already know that you just lost and bruised,",
    "My flow is clean like a midnight breeze, got the whole crowd on their knees,",
    "You brought a butter knife I brought a sword, put you to sleep can't afford,",
    "That's the difference between me and you, I stay winning that's what I do,",
    "ROBLOX rap king stepping up right now, everybody bow,",
    "Fire on the beat flames in my throat, while you're still writing notes,",
    "Came here to win and that's a fact, now step back, I'm bringing that,",
}

-- ══════════════════════════════════
--  SOUND IDS  (for spam sounds)
-- ══════════════════════════════════
local Sounds = {
    ["🥁 Trap Beat"]   = "1843671350",
    ["🎵 Hype Beat"]   = "142376088",
    ["📢 Airhorn"]     = "131070686",
    ["👏 Clap"]        = "240353424",
    ["💥 Bass Drop"]   = "1369158362",
    ["🎤 Mic Drop"]    = "148722710",
    ["😂 Bruh"]        = "537891700",
    ["⚡ Ding"]        = "4590662766",
}

-- ══════════════════════════════════
--  STATE
-- ══════════════════════════════════
local State = {
    autoRap      = false,
    spamVote     = false,
    spamVoteTarget = "p1",
    spamSound    = false,
    antiAfk      = false,
    esp          = false,
    selectedSound = "1843671350",
    walkspeed    = 16,
    rapDelay     = 2.0,
    customRap    = "",
    useCustomRap = false,
    espHighlights = {},
    currentSoundObj = nil,
    minimized    = false,
}

-- ══════════════════════════════════
--  CORE REMOTES (game-specific)
-- ══════════════════════════════════
-- RapperChatting: workspace.RapperChatting  (RemoteEvent)
-- Votes:          workspace.Votes           (RemoteEvent) → FireServer(false, "p1"/"p2")
-- Tomato:         scan workspace/RS for tomato remote

local function GetRapRemote()
    return workspace:FindFirstChild("RapperChatting")
end

local function GetVoteRemote()
    return workspace:FindFirstChild("Votes")
end

local function GetTomatoRemote()
    -- Try common names
    for _, name in ipairs({"ThrowTomato","Tomato","TomatoThrow","TomatoEvent","ShootTomato"}) do
        local r = workspace:FindFirstChild(name) or ReplicatedStorage:FindFirstChild(name)
        if r then return r end
    end
    -- Deep scan
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("tomato") then return v end
    end
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("tomato") then return v end
    end
    return nil
end

-- ══════════════════════════════════
--  CHAT FUNCTION
-- ══════════════════════════════════
local function SendRapLine(text)
    -- Primary: game's own RapperChatting remote
    local rapRemote = GetRapRemote()
    if rapRemote and rapRemote:IsA("RemoteEvent") then
        pcall(function() rapRemote:FireServer(text) end)
        return
    end
    -- Fallback: TextChatService (modern Roblox)
    pcall(function()
        local tcs = TextChatService
        if tcs and tcs.TextChannels then
            local general = tcs.TextChannels:FindFirstChild("RBXGeneral")
                or tcs.TextChannels:FindFirstChild("All")
                or tcs.TextChannels:FindFirstChildOfClass("TextChannel")
            if general then general:SendAsync(text) end
        end
    end)
    -- Fallback: legacy chat
    pcall(function()
        local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if ev then
            local say = ev:FindFirstChild("SayMessageRequest")
            if say then say:FireServer(text, "All") end
        end
    end)
end

-- ══════════════════════════════════
--  GUI BUILDER
-- ══════════════════════════════════
-- Destroy any old GUI
if PG:FindFirstChild("EpicRapBattlesGUI") then
    PG:FindFirstChild("EpicRapBattlesGUI"):Destroy()
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "EpicRapBattlesGUI"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder = 999
GUI.Parent = PG

-- ── MAIN WINDOW ──
local Win = Instance.new("Frame")
Win.Name = "Win"
Win.Size = UDim2.new(0, 360, 0, 560)
Win.Position = UDim2.new(0.5, -180, 0.5, -280)
Win.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Win.BorderSizePixel = 0
Win.ClipsDescendants = true
Win.Parent = GUI

Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 10)
local WinStroke = Instance.new("UIStroke", Win)
WinStroke.Color = Color3.fromRGB(30, 215, 96)
WinStroke.Thickness = 1.5

-- ── TITLE BAR ──
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Win
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
-- bottom fix
local TBarFix = Instance.new("Frame")
TBarFix.Size = UDim2.new(1, 0, 0.5, 0)
TBarFix.Position = UDim2.new(0, 0, 0.5, 0)
TBarFix.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TBarFix.BorderSizePixel = 0
TBarFix.Parent = TitleBar

-- Green accent bar
local AccentBar = Instance.new("Frame")
AccentBar.Size = UDim2.new(0, 3, 1, 0)
AccentBar.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
AccentBar.BorderSizePixel = 0
AccentBar.Parent = TitleBar

-- Title text
local TitleLbl = Instance.new("TextLabel")
TitleLbl.Text = "🎤  EPIC RAP BATTLES GUI"
TitleLbl.Size = UDim2.new(1, -90, 1, 0)
TitleLbl.Position = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLbl.TextScaled = true
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "─"
MinBtn.Size = UDim2.new(0, 32, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinBtn.TextColor3 = Color3.white
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextScaled = true
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 32, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.TextColor3 = Color3.white
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ── STATUS BAR ──
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 28)
StatusBar.Position = UDim2.new(0, 0, 0, 44)
StatusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = Win

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Text = "● Idle — Ready"
StatusLbl.Size = UDim2.new(1, -10, 1, 0)
StatusLbl.Position = UDim2.new(0, 10, 0, 0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
StatusLbl.TextScaled = true
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = StatusBar

local function SetStatus(msg, r, g, b)
    StatusLbl.Text = "● " .. msg
    StatusLbl.TextColor3 = Color3.fromRGB(r or 120, g or 120, b or 130)
end

-- ── SCROLLABLE CONTENT ──
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -72)
ScrollFrame.Position = UDim2.new(0, 0, 0, 72)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(30, 215, 96)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = Win

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 4)
ContentList.Parent = ScrollFrame

local ContentPad = Instance.new("UIPadding")
ContentPad.PaddingLeft = UDim.new(0, 8)
ContentPad.PaddingRight = UDim.new(0, 8)
ContentPad.PaddingTop = UDim.new(0, 8)
ContentPad.PaddingBottom = UDim.new(0, 8)
ContentPad.Parent = ScrollFrame

-- ══════════════════════════════════
--  COMPONENT HELPERS
-- ══════════════════════════════════
local function Section(text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    f.BorderSizePixel = 0
    f.Parent = ScrollFrame
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 0.7, 0)
    accent.Position = UDim2.new(0, 0, 0.15, 0)
    accent.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
    accent.BorderSizePixel = 0
    accent.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1, -12, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(30, 215, 96)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    return f
end

local function Btn(text, color, parent)
    color = color or Color3.fromRGB(30, 215, 96)
    parent = parent or ScrollFrame

    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    local origColor = color
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(origColor.R * 255 + 25, 255),
                math.min(origColor.G * 255 + 25, 255),
                math.min(origColor.B * 255 + 25, 255)
            )
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = origColor}):Play()
    end)
    return btn
end

local function SmallBtn(text, color, parent)
    color = color or Color3.fromRGB(40, 40, 55)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0.48, 0, 0, 34)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

local function TextBox(placeholder, parent)
    local tb = Instance.new("TextBox")
    tb.PlaceholderText = placeholder
    tb.Text = ""
    tb.Size = UDim2.new(1, 0, 0, 34)
    tb.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    tb.TextColor3 = Color3.white
    tb.PlaceholderColor3 = Color3.fromRGB(80, 80, 95)
    tb.Font = Enum.Font.Gotham
    tb.TextScaled = true
    tb.BorderSizePixel = 0
    tb.ClearTextOnFocus = false
    tb.Parent = parent
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke", tb)
    stroke.Color = Color3.fromRGB(40, 40, 55)
    stroke.Thickness = 1
    tb.Focused:Connect(function() stroke.Color = Color3.fromRGB(30, 215, 96) end)
    tb.FocusLost:Connect(function() stroke.Color = Color3.fromRGB(40, 40, 55) end)
    return tb
end

local function RowFrame(parent)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local layout = Instance.new("UIListLayout", f)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0.04, 0)
    return f
end

local function ToggleButton(btn, isActive, onColor, offColor)
    onColor = onColor or Color3.fromRGB(30, 215, 96)
    offColor = offColor or Color3.fromRGB(180, 40, 40)
    btn.BackgroundColor3 = isActive and onColor or offColor
end

-- ══════════════════════════════════
--  SECTION: AUTO RAP
-- ══════════════════════════════════
Section("🎤  AUTO RAP")

local AutoRapBtn = Btn("▶  START AUTO RAP", Color3.fromRGB(20, 150, 60))

-- Custom rap input
local CustomRapBox = TextBox("✏ Custom rap line (optional)...", ScrollFrame)
CustomRapBox.Size = UDim2.new(1, 0, 0, 34)

-- Delay row
local DelayRow = Instance.new("Frame")
DelayRow.Size = UDim2.new(1, 0, 0, 28)
DelayRow.BackgroundTransparency = 1
DelayRow.Parent = ScrollFrame

local DelayLbl = Instance.new("TextLabel")
DelayLbl.Text = "Delay between lines: 2.0s"
DelayLbl.Size = UDim2.new(0.6, 0, 1, 0)
DelayLbl.BackgroundTransparency = 1
DelayLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
DelayLbl.TextScaled = true
DelayLbl.Font = Enum.Font.Gotham
DelayLbl.TextXAlignment = Enum.TextXAlignment.Left
DelayLbl.Parent = DelayRow

local DelaySlider = Instance.new("TextButton") -- we'll make a simple +/- control
DelaySlider.Text = "– 0.5s"
DelaySlider.Size = UDim2.new(0.18, 0, 1, 0)
DelaySlider.Position = UDim2.new(0.62, 0, 0, 0)
DelaySlider.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
DelaySlider.TextColor3 = Color3.white
DelaySlider.Font = Enum.Font.GothamBold
DelaySlider.TextScaled = true
DelaySlider.BorderSizePixel = 0
DelaySlider.Parent = DelayRow
Instance.new("UICorner", DelaySlider).CornerRadius = UDim.new(0, 5)

local DelayUp = Instance.new("TextButton")
DelayUp.Text = "+ 0.5s"
DelayUp.Size = UDim2.new(0.18, 0, 1, 0)
DelayUp.Position = UDim2.new(0.82, 0, 0, 0)
DelayUp.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
DelayUp.TextColor3 = Color3.white
DelayUp.Font = Enum.Font.GothamBold
DelayUp.TextScaled = true
DelayUp.BorderSizePixel = 0
DelayUp.Parent = DelayRow
Instance.new("UICorner", DelayUp).CornerRadius = UDim.new(0, 5)

DelaySlider.MouseButton1Click:Connect(function()
    State.rapDelay = math.max(0.5, State.rapDelay - 0.5)
    DelayLbl.Text = "Delay between lines: " .. State.rapDelay .. "s"
end)
DelayUp.MouseButton1Click:Connect(function()
    State.rapDelay = math.min(10, State.rapDelay + 0.5)
    DelayLbl.Text = "Delay between lines: " .. State.rapDelay .. "s"
end)

AutoRapBtn.MouseButton1Click:Connect(function()
    State.autoRap = not State.autoRap
    if State.autoRap then
        AutoRapBtn.Text = "⏹  STOP AUTO RAP"
        AutoRapBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
        SetStatus("Auto Rap ON 🎤", 30, 215, 96)

        local idx = 1
        task.spawn(function()
            while State.autoRap do
                local line
                local custom = CustomRapBox.Text
                if custom and #custom > 3 then
                    line = custom
                else
                    line = RapLines[idx]
                    idx = (idx % #RapLines) + 1
                end
                SendRapLine(line)
                task.wait(State.rapDelay)
            end
        end)
    else
        AutoRapBtn.Text = "▶  START AUTO RAP"
        AutoRapBtn.BackgroundColor3 = Color3.fromRGB(20, 150, 60)
        SetStatus("Auto Rap OFF", 120, 120, 130)
    end
end)

-- ══════════════════════════════════
--  SECTION: VOTE SPAM
-- ══════════════════════════════════
Section("🗳  VOTE SPAM")

-- p1 / p2 selector
local VoteRow = RowFrame(ScrollFrame)
local VoteP1Btn = SmallBtn("Vote P1", Color3.fromRGB(30, 215, 96), VoteRow)
local VoteP2Btn = SmallBtn("Vote P2", Color3.fromRGB(40, 40, 55), VoteRow)

-- highlight selected
local function UpdateVoteHighlight()
    VoteP1Btn.BackgroundColor3 = State.spamVoteTarget == "p1"
        and Color3.fromRGB(30, 215, 96) or Color3.fromRGB(40, 40, 55)
    VoteP2Btn.BackgroundColor3 = State.spamVoteTarget == "p2"
        and Color3.fromRGB(30, 215, 96) or Color3.fromRGB(40, 40, 55)
end

VoteP1Btn.MouseButton1Click:Connect(function()
    State.spamVoteTarget = "p1"
    UpdateVoteHighlight()
end)
VoteP2Btn.MouseButton1Click:Connect(function()
    State.spamVoteTarget = "p2"
    UpdateVoteHighlight()
end)

local SpamVoteBtn = Btn("🗳  START SPAM VOTE", Color3.fromRGB(200, 140, 0))

SpamVoteBtn.MouseButton1Click:Connect(function()
    State.spamVote = not State.spamVote
    if State.spamVote then
        SpamVoteBtn.Text = "⏹  STOP SPAM VOTE"
        SpamVoteBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
        SetStatus("Spam Voting " .. State.spamVoteTarget:upper() .. " 🗳", 255, 200, 50)

        task.spawn(function()
            while State.spamVote do
                local voteRemote = GetVoteRemote()
                if voteRemote and voteRemote:IsA("RemoteEvent") then
                    pcall(function()
                        voteRemote:FireServer(false, State.spamVoteTarget)
                    end)
                else
                    -- fallback: scan for vote remote
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("RemoteEvent") and v.Name:lower():find("vote") then
                            pcall(function() v:FireServer(false, State.spamVoteTarget) end)
                        end
                    end
                end
                task.wait(0.05) -- very fast spam
            end
        end)
    else
        State.spamVote = false
        SpamVoteBtn.Text = "🗳  START SPAM VOTE"
        SpamVoteBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
        SetStatus("Vote spam stopped", 120, 120, 130)
    end
end)

-- ══════════════════════════════════
--  SECTION: SPAM SOUNDS
-- ══════════════════════════════════
Section("🔊  SPAM SOUNDS")

-- Sound grid
local SoundGrid = Instance.new("Frame")
SoundGrid.Size = UDim2.new(1, 0, 0, 76)
SoundGrid.BackgroundTransparency = 1
SoundGrid.Parent = ScrollFrame

local SoundGridLayout = Instance.new("UIGridLayout")
SoundGridLayout.CellSize = UDim2.new(0.24, -3, 0, 34)
SoundGridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
SoundGridLayout.Parent = SoundGrid

for name, id in pairs(Sounds) do
    local sb = Instance.new("TextButton")
    sb.Text = name
    sb.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    sb.TextColor3 = Color3.fromRGB(200, 200, 210)
    sb.Font = Enum.Font.Gotham
    sb.TextScaled = true
    sb.BorderSizePixel = 0
    sb.Parent = SoundGrid
    Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 6)

    sb.MouseButton1Click:Connect(function()
        State.selectedSound = id
        -- reset all
        for _, child in ipairs(SoundGrid:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                child.TextColor3 = Color3.fromRGB(200, 200, 210)
            end
        end
        sb.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
        sb.TextColor3 = Color3.white
        SetStatus("Sound: " .. name, 100, 200, 255)
    end)
end

-- Volume label
local VolLbl = Instance.new("TextLabel")
VolLbl.Text = "Volume: 1.0"
VolLbl.Size = UDim2.new(0.5, 0, 0, 22)
VolLbl.BackgroundTransparency = 1
VolLbl.TextColor3 = Color3.fromRGB(140, 140, 155)
VolLbl.TextScaled = true
VolLbl.Font = Enum.Font.Gotham
VolLbl.TextXAlignment = Enum.TextXAlignment.Left
VolLbl.Parent = ScrollFrame

local SpamSoundBtn = Btn("🔊  START SPAM SOUND", Color3.fromRGB(50, 80, 200))

SpamSoundBtn.MouseButton1Click:Connect(function()
    State.spamSound = not State.spamSound
    if State.spamSound then
        SpamSoundBtn.Text = "🔇  STOP SPAM SOUND"
        SpamSoundBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
        SetStatus("Sound spamming 🔊", 100, 200, 255)

        task.spawn(function()
            while State.spamSound do
                if State.currentSoundObj then
                    pcall(function() State.currentSoundObj:Destroy() end)
                end
                local s = Instance.new("Sound")
                s.SoundId = "rbxassetid://" .. State.selectedSound
                s.Volume = 1
                s.RollOffMaxDistance = 10000
                s.Parent = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") or workspace
                s:Play()
                State.currentSoundObj = s
                task.wait(0.4)
            end
            if State.currentSoundObj then
                pcall(function() State.currentSoundObj:Stop(); State.currentSoundObj:Destroy() end)
                State.currentSoundObj = nil
            end
        end)
    else
        State.spamSound = false
        SpamSoundBtn.Text = "🔊  START SPAM SOUND"
        SpamSoundBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 200)
        SetStatus("Sound spam stopped", 120, 120, 130)
    end
end)

-- ══════════════════════════════════
--  SECTION: TELEPORT
-- ══════════════════════════════════
Section("📍  TELEPORT")

local TpLocations = {
    {name="Stage",    keywords={"stage","platform","rap"}},
    {name="Floor",    keywords={"floor","lobby","main"}},
    {name="DJ Booth", keywords={"dj","djbooth","booth","music"}},
    {name="Toilet",   keywords={"toilet","bathroom","restroom"}},
}

local TpGrid = Instance.new("Frame")
TpGrid.Size = UDim2.new(1, 0, 0, 76)
TpGrid.BackgroundTransparency = 1
TpGrid.Parent = ScrollFrame

local TpGridLayout = Instance.new("UIGridLayout")
TpGridLayout.CellSize = UDim2.new(0.24, -3, 0, 34)
TpGridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
TpGridLayout.Parent = TpGrid

for _, loc in ipairs(TpLocations) do
    local tb = Instance.new("TextButton")
    tb.Text = loc.name
    tb.BackgroundColor3 = Color3.fromRGB(170, 30, 30)
    tb.TextColor3 = Color3.white
    tb.Font = Enum.Font.GothamBold
    tb.TextScaled = true
    tb.BorderSizePixel = 0
    tb.Parent = TpGrid
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)

    tb.MouseButton1Click:Connect(function()
        local char = LP.Character
        if not char then SetStatus("No character!", 255, 80, 80) return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then SetStatus("No HRP!", 255, 80, 80) return end

        SetStatus("Searching for " .. loc.name .. "...", 255, 200, 50)

        for _, kw in ipairs(loc.keywords) do
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find(kw) then
                    local pos
                    if obj:IsA("Model") and obj.PrimaryPart then
                        pos = obj.PrimaryPart.Position + Vector3.new(0, 5, 0)
                    elseif obj:IsA("BasePart") then
                        pos = obj.Position + Vector3.new(0, 5, 0)
                    end
                    if pos then
                        hrp.CFrame = CFrame.new(pos)
                        SetStatus("Teleported → " .. loc.name, 30, 215, 96)
                        return
                    end
                end
            end
        end
        SetStatus("'" .. loc.name .. "' not found in workspace", 255, 100, 80)
    end)
end

-- Custom TP coords
local CustomTpBox = TextBox("Custom CFrame: X, Y, Z", ScrollFrame)
local CustomTpBtn = Btn("⚡  Teleport to Coords", Color3.fromRGB(100, 50, 180))
CustomTpBtn.MouseButton1Click:Connect(function()
    local text = CustomTpBox.Text
    local x, y, z = text:match("(%-?%d+%.?%d*)[,%s]+(%-?%d+%.?%d*)[,%s]+(%-?%d+%.?%d*)")
    if x and y and z then
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
            SetStatus("Teleported to " .. x .. ", " .. y .. ", " .. z, 30, 215, 96)
        end
    else
        SetStatus("Invalid coords! Use: X, Y, Z", 255, 80, 80)
    end
end)

-- ══════════════════════════════════
--  SECTION: TOMATO SPAM
-- ══════════════════════════════════
Section("🍅  TOMATO SPAM")

local TomatoTargetBox = TextBox("Target player name...", ScrollFrame)

local spamTomato = false
local TomatoBtn = Btn("🍅  START SPAM TOMATOES", Color3.fromRGB(200, 60, 30))

TomatoBtn.MouseButton1Click:Connect(function()
    spamTomato = not spamTomato
    if spamTomato then
        TomatoBtn.Text = "⏹  STOP TOMATO SPAM"
        TomatoBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
        SetStatus("Spamming tomatoes 🍅", 255, 100, 50)

        task.spawn(function()
            while spamTomato do
                local targetName = TomatoTargetBox.Text
                local target = targetName ~= "" and Players:FindFirstChild(targetName) or nil
                local tomatoRemote = GetTomatoRemote()

                if tomatoRemote then
                    pcall(function()
                        if target and target.Character then
                            tomatoRemote:FireServer(target.Character)
                        else
                            tomatoRemote:FireServer()
                        end
                    end)
                else
                    -- Try all remotes that might be throw-related
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("RemoteEvent") and (
                            v.Name:lower():find("throw") or
                            v.Name:lower():find("tomato") or
                            v.Name:lower():find("shoot") or
                            v.Name:lower():find("projectile")
                        ) then
                            pcall(function()
                                if target and target.Character then
                                    v:FireServer(target.Character)
                                else
                                    v:FireServer()
                                end
                            end)
                        end
                    end
                end
                task.wait(0.15)
            end
        end)
    else
        spamTomato = false
        TomatoBtn.Text = "🍅  START SPAM TOMATOES"
        TomatoBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 30)
        SetStatus("Tomato spam stopped", 120, 120, 130)
    end
end)

-- ══════════════════════════════════
--  SECTION: PLAYER TOOLS
-- ══════════════════════════════════
Section("⚙  PLAYER TOOLS")

-- Speed
local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, 0, 0, 34)
SpeedRow.BackgroundTransparency = 1
SpeedRow.Parent = ScrollFrame
local SpeedLayout = Instance.new("UIListLayout", SpeedRow)
SpeedLayout.FillDirection = Enum.FillDirection.Horizontal
SpeedLayout.Padding = UDim.new(0, 4)

local SpeedLbl = Instance.new("TextLabel")
SpeedLbl.Text = "Speed: 16"
SpeedLbl.Size = UDim2.new(0.38, 0, 1, 0)
SpeedLbl.BackgroundTransparency = 1
SpeedLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
SpeedLbl.TextScaled = true
SpeedLbl.Font = Enum.Font.Gotham
SpeedLbl.TextXAlignment = Enum.TextXAlignment.Left
SpeedLbl.Parent = SpeedRow

local speeds = {16, 32, 50, 100}
for _, sp in ipairs(speeds) do
    local sb = Instance.new("TextButton")
    sb.Text = tostring(sp)
    sb.Size = UDim2.new(0.14, 0, 1, 0)
    sb.BackgroundColor3 = sp == 16 and Color3.fromRGB(30, 215, 96) or Color3.fromRGB(35, 35, 50)
    sb.TextColor3 = Color3.white
    sb.Font = Enum.Font.GothamBold
    sb.TextScaled = true
    sb.BorderSizePixel = 0
    sb.Parent = SpeedRow
    Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 6)

    sb.MouseButton1Click:Connect(function()
        State.walkspeed = sp
        SpeedLbl.Text = "Speed: " .. sp
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = sp end
        for _, child in ipairs(SpeedRow:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            end
        end
        sb.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
        SetStatus("WalkSpeed → " .. sp, 30, 215, 96)
    end)
end

-- Keep speed on respawn
LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = State.walkspeed
end)

-- ── Anti-AFK + ESP row ──
local ToolRow = RowFrame(ScrollFrame)

local AntiAfkBtn = SmallBtn("🛡 Anti-AFK: OFF", Color3.fromRGB(35, 35, 50), ToolRow)
AntiAfkBtn.MouseButton1Click:Connect(function()
    State.antiAfk = not State.antiAfk
    AntiAfkBtn.Text = State.antiAfk and "🛡 Anti-AFK: ON" or "🛡 Anti-AFK: OFF"
    AntiAfkBtn.BackgroundColor3 = State.antiAfk
        and Color3.fromRGB(30, 215, 96) or Color3.fromRGB(35, 35, 50)
    SetStatus(State.antiAfk and "Anti-AFK enabled" or "Anti-AFK off", 30, 215, 96)

    if State.antiAfk then
        task.spawn(function()
            while State.antiAfk do
                -- Simulate input to prevent idle kick
                local VirtualUser = game:GetService("VirtualUser")
                if VirtualUser then
                    pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
                end
                task.wait(60)
            end
        end)
    end
end)

local EspBtn = SmallBtn("👁 ESP: OFF", Color3.fromRGB(35, 35, 50), ToolRow)
EspBtn.MouseButton1Click:Connect(function()
    State.esp = not State.esp
    EspBtn.Text = State.esp and "👁 ESP: ON" or "👁 ESP: OFF"
    EspBtn.BackgroundColor3 = State.esp
        and Color3.fromRGB(30, 215, 96) or Color3.fromRGB(35, 35, 50)
    SetStatus(State.esp and "ESP ON 👁" or "ESP OFF", 30, 215, 96)

    -- Remove old highlights
    for _, hl in ipairs(State.espHighlights) do
        pcall(function() hl:Destroy() end)
    end
    State.espHighlights = {}

    if State.esp then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(30, 215, 96)
                hl.OutlineColor = Color3.white
                hl.FillTransparency = 0.5
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = plr.Character
                table.insert(State.espHighlights, hl)
            end
        end

        -- Track new players
        Players.PlayerAdded:Connect(function(plr)
            if not State.esp then return end
            plr.CharacterAdded:Connect(function(char)
                if not State.esp then return end
                task.wait(1)
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(30, 215, 96)
                hl.OutlineColor = Color3.white
                hl.FillTransparency = 0.5
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
                table.insert(State.espHighlights, hl)
            end)
        end)
    end
end)

-- ══════════════════════════════════
--  SECTION: PLAYER LIST (vote helper)
-- ══════════════════════════════════
Section("👥  PLAYERS  (click to set vote target)")

local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Size = UDim2.new(1, 0, 0, 10) -- auto-resizes
PlayerListFrame.AutomaticSize = Enum.AutomaticSize.Y
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.Parent = ScrollFrame

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 3)
PlayerListLayout.Parent = PlayerListFrame

local function RefreshPlayerList()
    for _, c in ipairs(PlayerListFrame:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        row.BorderSizePixel = 0
        row.Parent = PlayerListFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Text = (plr == LP and "⭐ " or "👤 ") .. plr.Name
        nameLbl.Size = UDim2.new(0.65, 0, 1, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.TextColor3 = plr == LP and Color3.fromRGB(30, 215, 96) or Color3.white
        nameLbl.TextScaled = true
        nameLbl.Font = Enum.Font.Gotham
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Parent = row
        local namePad = Instance.new("UIPadding", nameLbl)
        namePad.PaddingLeft = UDim.new(0, 8)

        -- Copy name to vote input button
        local copyBtn = Instance.new("TextButton")
        copyBtn.Text = "Set Target"
        copyBtn.Size = UDim2.new(0.33, 0, 0.75, 0)
        copyBtn.Position = UDim2.new(0.65, 0, 0.125, 0)
        copyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        copyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextScaled = true
        copyBtn.BorderSizePixel = 0
        copyBtn.Parent = row
        Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 5)

        copyBtn.MouseButton1Click:Connect(function()
            TomatoTargetBox.Text = plr.Name
            SetStatus("Target set: " .. plr.Name, 255, 200, 50)
        end)
    end
end

RefreshPlayerList()

local RefreshBtn = Btn("🔄  Refresh Player List", Color3.fromRGB(35, 35, 55))
RefreshBtn.MouseButton1Click:Connect(function()
    RefreshPlayerList()
    SetStatus("Player list refreshed", 30, 215, 96)
end)

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

-- ══════════════════════════════════
--  MINIMIZE / CLOSE LOGIC
-- ══════════════════════════════════
local contentVisible = true

MinBtn.MouseButton1Click:Connect(function()
    contentVisible = not contentVisible
    TweenService:Create(Win, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
        Size = contentVisible
            and UDim2.new(0, 360, 0, 560)
            or  UDim2.new(0, 360, 0, 44)
    }):Play()
    MinBtn.Text = contentVisible and "─" or "□"
end)

CloseBtn.MouseButton1Click:Connect(function()
    State.autoRap = false
    State.spamVote = false
    State.spamSound = false
    spamTomato = false
    GUI:Destroy()
end)

-- ══════════════════════════════════
--  DRAGGABLE TITLE BAR
-- ══════════════════════════════════
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Win.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        TweenService:Create(Win, TweenInfo.new(0.05), {
            Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        }):Play()
    end
end)

-- ══════════════════════════════════
--  STARTUP ANIMATION
-- ══════════════════════════════════
Win.Size = UDim2.new(0, 360, 0, 0)
Win.BackgroundTransparency = 1
TweenService:Create(Win, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 360, 0, 560),
    BackgroundTransparency = 0
}):Play()

task.wait(0.4)
SetStatus("✅ GUI Loaded — Game: Rap Battles (8067158534)", 30, 215, 96)
print("[EpicRapBattlesGUI] ✅ Loaded | Game 8067158534 | RapperChatting + Votes remotes targeted")
