--[[
    AI RAP GENERATOR - Rap Battles (8067158534)
    - Describe the opponent's avatar
    - Claude AI writes the rap lines
    - Auto-sends them in game one by one
]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")

-- Clean up old
if PGui:FindFirstChild("AIRapGUI") then PGui.AIRapGUI:Destroy() end

-- ─────────────────────────────────────
--  SAY FUNCTION (both confirmed remotes)
-- ─────────────────────────────────────
local function Say(msg)
    pcall(function() game.Workspace.RapperChatting:FireServer(msg) end)
    pcall(function()
        game.ReplicatedStorage.DefaultChatSystemChatEvents
            .SayMessageRequest:FireServer(msg, "All")
    end)
end

-- ─────────────────────────────────────
--  AI RAP GENERATOR via Anthropic API
-- ─────────────────────────────────────
local HttpService = game:GetService("HttpService")

local function GenerateRap(description, numLines, callback)
    -- Uses syn.request / http.request (executor HTTP)
    local requestFunc = syn and syn.request
        or (http and http.request)
        or (request)
        or nil

    if not requestFunc then
        callback(nil, "Your executor doesn't support HTTP requests (syn.request). Try Synapse X, KRNL or Fluxus.")
        return
    end

    local prompt = string.format(
        "You are a savage Roblox rap battle roaster. " ..
        "Write exactly %d short rap lines roasting this Roblox avatar: %s\n\n" ..
        "Rules:\n" ..
        "- Each line on its own line\n" ..
        "- Keep each line under 100 characters\n" ..
        "- Make it funny and roast-focused on the description\n" ..
        "- No numbering, no bullet points, just the lines\n" ..
        "- Use Roblox slang and references\n" ..
        "- Rhyme where possible\n" ..
        "Output ONLY the %d rap lines, nothing else.",
        numLines, description, numLines
    )

    local body = HttpService:JSONEncode({
        model = "claude-sonnet-4-20250514",
        max_tokens = 600,
        messages = {
            { role = "user", content = prompt }
        }
    })

    task.spawn(function()
        local ok, res = pcall(function()
            return requestFunc({
                Url = "https://api.anthropic.com/v1/messages",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["anthropic-version"] = "2023-06-01",
                },
                Body = body
            })
        end)

        if not ok then
            callback(nil, "Request failed: " .. tostring(res))
            return
        end

        local decoded = pcall(function() res = HttpService:JSONDecode(res.Body) end)
        if res and res.content and res.content[1] and res.content[1].text then
            local text = res.content[1].text
            -- Split into lines
            local lines = {}
            for line in text:gmatch("[^\n]+") do
                line = line:match("^%s*(.-)%s*$") -- trim
                if #line > 2 then
                    table.insert(lines, line)
                end
            end
            callback(lines, nil)
        else
            callback(nil, "Bad API response. Check executor HTTP support.")
        end
    end)
end

-- ─────────────────────────────────────
--  GUI
-- ─────────────────────────────────────
local SGui = Instance.new("ScreenGui")
SGui.Name = "AIRapGUI"
SGui.ResetOnSpawn = false
SGui.DisplayOrder = 999
SGui.Parent = PGui

-- Main window
local Win = Instance.new("Frame")
Win.Size = UDim2.new(0, 380, 0, 420)
Win.Position = UDim2.new(0.5, -190, 0.5, -210)
Win.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Win.BorderSizePixel = 0
Win.Parent = SGui
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 10)
local ws = Instance.new("UIStroke", Win)
ws.Color = Color3.fromRGB(220, 40, 40); ws.Thickness = 1.5

-- Title bar
local TBar = Instance.new("Frame")
TBar.Size = UDim2.new(1, 0, 0, 44)
TBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TBar.BorderSizePixel = 0
TBar.Parent = Win
Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 10)
Instance.new("Frame", TBar).Size = UDim2.new(1,0,0.5,0) -- corner fix
local tbfix = TBar:FindFirstChildOfClass("Frame")
tbfix.Position = UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3 = Color3.fromRGB(18,18,24)
tbfix.BorderSizePixel = 0

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Text = "🎤  AI RAP GENERATOR"
TitleLbl.Size = UDim2.new(1, -50, 1, 0)
TitleLbl.Position = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextScaled = true
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TBar

local XBtn = Instance.new("TextButton")
XBtn.Text = "✕"
XBtn.Size = UDim2.new(0, 30, 0, 26)
XBtn.Position = UDim2.new(1, -36, 0.5, -13)
XBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
XBtn.TextColor3 = Color3.fromRGB(255,255,255)
XBtn.Font = Enum.Font.GothamBold
XBtn.TextScaled = true
XBtn.BorderSizePixel = 0
XBtn.Parent = TBar
Instance.new("UICorner", XBtn).CornerRadius = UDim.new(0, 6)
XBtn.MouseButton1Click:Connect(function() SGui:Destroy() end)

-- Content area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -54)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = Win
local CList = Instance.new("UIListLayout", Content)
CList.Padding = UDim.new(0, 8)

-- Label helper
local function MakeLbl(parent, text, height, color)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.Size = UDim2.new(1, 0, 0, height)
    l.BackgroundTransparency = 1
    l.TextColor3 = color or Color3.fromRGB(160, 160, 175)
    l.Font = Enum.Font.GothamBold
    l.TextScaled = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

-- Status label
local StatusLbl = MakeLbl(Content, "Describe the opponent avatar below ↓", 22, Color3.fromRGB(120,120,140))

-- Description box
MakeLbl(Content, "👾  Avatar Description", 20, Color3.fromRGB(220,40,40))
local DescBox = Instance.new("TextBox")
DescBox.PlaceholderText = "e.g. noob with bacon hair, free shirt, no accessories"
DescBox.Text = ""
DescBox.Size = UDim2.new(1, 0, 0, 70)
DescBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
DescBox.TextColor3 = Color3.fromRGB(240, 240, 245)
DescBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 100)
DescBox.Font = Enum.Font.Gotham
DescBox.TextScaled = true
DescBox.TextWrapped = true
DescBox.MultiLine = true
DescBox.BorderSizePixel = 0
DescBox.ClearTextOnFocus = false
DescBox.Parent = Content
Instance.new("UICorner", DescBox).CornerRadius = UDim.new(0, 7)
local dbs = Instance.new("UIStroke", DescBox)
dbs.Color = Color3.fromRGB(40,40,55); dbs.Thickness = 1
DescBox.Focused:Connect(function()    dbs.Color = Color3.fromRGB(220,40,40) end)
DescBox.FocusLost:Connect(function()  dbs.Color = Color3.fromRGB(40,40,55)  end)

-- Number of lines row
MakeLbl(Content, "📝  Number of Rap Lines", 20, Color3.fromRGB(220,40,40))
local linesRow = Instance.new("Frame")
linesRow.Size = UDim2.new(1, 0, 0, 34)
linesRow.BackgroundTransparency = 1
linesRow.Parent = Content
local linesRL = Instance.new("UIListLayout", linesRow)
linesRL.FillDirection = Enum.FillDirection.Horizontal
linesRL.Padding = UDim.new(0, 6)

local numLines = 7
local numOptions = {4, 5, 6, 7, 8, 10, 12}
local numBtns = {}
for _, n in ipairs(numOptions) do
    local nb = Instance.new("TextButton")
    nb.Text = tostring(n)
    nb.Size = UDim2.new(0, 40, 1, 0)
    nb.BackgroundColor3 = n == numLines and Color3.fromRGB(220,40,40) or Color3.fromRGB(30,30,42)
    nb.TextColor3 = Color3.fromRGB(255,255,255)
    nb.Font = Enum.Font.GothamBold
    nb.TextScaled = true
    nb.BorderSizePixel = 0
    nb.AutoButtonColor = false
    nb.Parent = linesRow
    Instance.new("UICorner", nb).CornerRadius = UDim.new(0, 6)
    numBtns[n] = nb
    nb.MouseButton1Click:Connect(function()
        numLines = n
        for k, b in pairs(numBtns) do
            b.BackgroundColor3 = k==n and Color3.fromRGB(220,40,40) or Color3.fromRGB(30,30,42)
        end
    end)
end

-- Delay row
MakeLbl(Content, "⏱  Delay Between Lines", 20, Color3.fromRGB(220,40,40))
local delayRow = Instance.new("Frame")
delayRow.Size = UDim2.new(1, 0, 0, 34)
delayRow.BackgroundTransparency = 1
delayRow.Parent = Content
local delRL = Instance.new("UIListLayout", delayRow)
delRL.FillDirection = Enum.FillDirection.Horizontal
delRL.Padding = UDim.new(0, 6)

local lineDelay = 2
local delayOptions = {1, 1.5, 2, 2.5, 3}
local delayBtns = {}
for _, d in ipairs(delayOptions) do
    local db = Instance.new("TextButton")
    db.Text = d.."s"
    db.Size = UDim2.new(0, 48, 1, 0)
    db.BackgroundColor3 = d == lineDelay and Color3.fromRGB(220,40,40) or Color3.fromRGB(30,30,42)
    db.TextColor3 = Color3.fromRGB(255,255,255)
    db.Font = Enum.Font.GothamBold
    db.TextScaled = true
    db.BorderSizePixel = 0
    db.AutoButtonColor = false
    db.Parent = delayRow
    Instance.new("UICorner", db).CornerRadius = UDim.new(0, 6)
    delayBtns[d] = db
    db.MouseButton1Click:Connect(function()
        lineDelay = d
        for k, b in pairs(delayBtns) do
            b.BackgroundColor3 = k==d and Color3.fromRGB(220,40,40) or Color3.fromRGB(30,30,42)
        end
    end)
end

-- Generate + Rap button
local GenBtn = Instance.new("TextButton")
GenBtn.Text = "🤖  GENERATE & RAP"
GenBtn.Size = UDim2.new(1, 0, 0, 42)
GenBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
GenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GenBtn.Font = Enum.Font.GothamBold
GenBtn.TextScaled = true
GenBtn.BorderSizePixel = 0
GenBtn.AutoButtonColor = false
GenBtn.Parent = Content
Instance.new("UICorner", GenBtn).CornerRadius = UDim.new(0, 8)

local rapping = false

GenBtn.MouseButton1Click:Connect(function()
    if rapping then return end

    local desc = DescBox.Text
    if not desc or #desc < 3 then
        StatusLbl.Text = "⚠ Enter an avatar description first!"
        StatusLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end

    rapping = true
    GenBtn.Text = "⏳  Generating..."
    GenBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    StatusLbl.Text = "🤖 AI is writing your rap..."
    StatusLbl.TextColor3 = Color3.fromRGB(100, 180, 255)

    GenerateRap(desc, numLines, function(lines, err)
        if err or not lines then
            StatusLbl.Text = "❌ " .. (err or "Unknown error")
            StatusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
            GenBtn.Text = "🤖  GENERATE & RAP"
            GenBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
            rapping = false
            return
        end

        StatusLbl.Text = "🎤 Rapping " .. #lines .. " lines..."
        StatusLbl.TextColor3 = Color3.fromRGB(30, 200, 80)
        GenBtn.Text = "🎤 Rapping..."

        task.spawn(function()
            for i, line in ipairs(lines) do
                Say(line)
                StatusLbl.Text = "🎤 Line " .. i .. "/" .. #lines .. ": " .. line:sub(1,30) .. "..."
                task.wait(lineDelay)
            end
            StatusLbl.Text = "✅ Done! Generate another rap below."
            StatusLbl.TextColor3 = Color3.fromRGB(30, 200, 80)
            GenBtn.Text = "🤖  GENERATE & RAP"
            GenBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
            rapping = false
        end)
    end)
end)

-- ─────────────────────────────────────
--  DRAGGING
-- ─────────────────────────────────────
local dragging, dragInput, dragStart, startPos
TBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = Win.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TBar.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
end)
UserInputService.InputChanged:Connect(function(i)
    if i == dragInput and dragging then
        local d = i.Position - dragStart
        Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                  startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Open animation
Win.Size = UDim2.new(0, 380, 0, 0)
Win.BackgroundTransparency = 1
TweenService:Create(Win, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 380, 0, 420),
    BackgroundTransparency = 0
}):Play()

print("[AI Rap Generator] Loaded!")
