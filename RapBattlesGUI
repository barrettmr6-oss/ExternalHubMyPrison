-- FlowForge v4 | Free AI Rap Generator | Longer Bars | Categories | Grammar Mode
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local Players,TweenService,UserInputService,HttpService =
    game:GetService("Players"),game:GetService("TweenService"),
    game:GetService("UserInputService"),game:GetService("HttpService")
local LP   = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")
if PGui:FindFirstChild("FlowForgeGUI") then PGui.FlowForgeGUI:Destroy() end

-- ─── PALETTE ─────────────────────────────────────────────────────────────────
local C = {
    BG0=Color3.fromRGB(6,6,10),    BG1=Color3.fromRGB(12,11,19),
    BG2=Color3.fromRGB(18,16,30),  BG3=Color3.fromRGB(26,23,42),
    BG4=Color3.fromRGB(34,30,56),  BG5=Color3.fromRGB(42,37,68),
    BORDER=Color3.fromRGB(38,33,60),  BORDER2=Color3.fromRGB(62,54,98),
    ACC1=Color3.fromRGB(140,74,255),  ACC2=Color3.fromRGB(76,168,255),
    ACC3=Color3.fromRGB(255,82,162),  GOLD=Color3.fromRGB(255,198,58),
    TXT0=Color3.fromRGB(238,232,255), TXT1=Color3.fromRGB(162,152,198),
    TXT2=Color3.fromRGB(86,76,126),
    GREEN=Color3.fromRGB(58,228,138), RED=Color3.fromRGB(255,72,72),
    YELLOW=Color3.fromRGB(255,208,58),BLUE=Color3.fromRGB(76,168,255),
}

-- ─── PROVIDERS ───────────────────────────────────────────────────────────────
local PROVIDERS = {
    {name="SambaNova", url="https://api.sambanova.ai/v1/chat/completions",
     model="Meta-Llama-3.3-70B-Instruct", hint="Free key at cloud.sambanova.ai/apis"},
    {name="OpenAI",    url="https://api.openai.com/v1/chat/completions",
     model="gpt-4o-mini", hint="Key at platform.openai.com/api-keys"},
    {name="Custom",    url="", model="", hint="Any OpenAI-compatible API endpoint"},
}

-- ─── CATEGORIES ──────────────────────────────────────────────────────────────
local CATEGORIES = {
    {name="🔥 Savage",
     instr="Be absolutely brutal and merciless. Zero mercy. Go for the jugular on every line. Make it sting bad."},
    {name="😂 Comedy",
     instr="Make every line hilarious. Punchlines, absurd comparisons, mocking observations. They should laugh AND feel roasted."},
    {name="🎮 Roblox",
     instr="Every line must reference Roblox heavily: Robux, noobs, ODers, Bacon Hair, free models, game names, ban, lag, catalog, R6, admin, exploiters, UGC."},
    {name="👗 Fashion",
     instr="Focus entirely on roasting their avatar outfit, accessories, hair, face, colors, body. Mock every single fashion choice."},
    {name="💀 Dark",
     instr="Go dark and existential. Mock their entire existence, their future, their choices. Edgy but rap-battle appropriate."},
    {name="🤓 Lyrical",
     instr="Use clever wordplay, internal rhymes, multisyllabic rhymes, and sophisticated vocabulary. Show off skill while roasting."},
    {name="🌊 Diss",
     instr="Classic hip-hop diss track. Reference their flaws repeatedly, dismiss their skills, claim total superiority, end every bar hard."},
    {name="🎭 Story",
     instr="Tell a mocking story about this person across the bars. Build a narrative arc from intro to devastating punchline finale."},
}

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function Tw(o,t,p,s,d)
    s=s or Enum.EasingStyle.Quint; d=d or Enum.EasingDirection.Out
    TweenService:Create(o,TweenInfo.new(t,s,d),p):Play()
end
local function Corner(p,r)
    local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 8)
end
local function Stroke(p,col,th)
    local s=Instance.new("UIStroke",p); s.Color=col; s.Thickness=th or 1; return s
end
local function Grad(p,c0,c1,a)
    local g=Instance.new("UIGradient",p)
    g.Color=ColorSequence.new(c0,c1); g.Rotation=a or 90; return g
end
local function Lbl(parent,props)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.TextScaled=true
    for k,v in pairs(props) do l[k]=v end; l.Parent=parent; return l
end
local function Btn(parent,props)
    local b=Instance.new("TextButton"); b.BackgroundTransparency=0
    b.AutoButtonColor=false; b.BorderSizePixel=0; b.TextScaled=true
    for k,v in pairs(props) do b[k]=v end; b.Parent=parent; return b
end
local function MkFrame(parent,props)
    local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.BorderSizePixel=0
    for k,v in pairs(props) do f[k]=v end; f.Parent=parent; return f
end
local function HoverBtn(b,norm,hov)
    b.MouseEnter:Connect(function() Tw(b,0.12,{BackgroundColor3=hov}) end)
    b.MouseLeave:Connect(function() Tw(b,0.12,{BackgroundColor3=norm}) end)
end
local function SecLbl(s,txt,lo)
    return Lbl(s,{Text=txt,Size=UDim2.new(1,0,0,16),Font=Enum.Font.GothamBold,
        TextColor3=C.TXT1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12,LayoutOrder=lo or 2})
end

-- ─── PROMPT BUILDER ──────────────────────────────────────────────────────────
local function BuildPrompt(desc, nCouplets, catInstr, useGrammar, intensity)
    local grammarLine = useGrammar
        and "Use proper grammar, capitalization, and punctuation on every line."
        or  "Write in raw street style: all lowercase, minimal punctuation, heavy slang, flow over grammar."
    local intensityMap = {
        Mild="Keep it playful — light roasting, still funny.",
        Medium="Real burns. Turn up the heat on every bar.",
        Hard="Maximum aggression. Every bar hits like a punch to the face.",
        NUCLEAR="ABSOLUTE OBLITERATION. The most savage, ruthless, devastating bars ever written. Leave nothing standing.",
    }
    local intensityLine = intensityMap[intensity] or intensityMap.Hard

    return string.format([[
You are the greatest Roblox rap battle ghostwriter of all time. Your bars are long, detailed, devastating, and packed with personality.

AVATAR TO ROAST: %s

STYLE: %s

INTENSITY: %s

GRAMMAR RULE: %s

YOUR TASK: Write EXACTLY %d rap COUPLETS roasting this avatar.
A couplet = 2 lines where the last word of line 1 and last word of line 2 RHYME.

CRITICAL OUTPUT FORMAT — FOLLOW THIS EXACTLY OR YOU FAIL:
- Print ONLY the rap lines. No title. No "Here are your bars". No intro. No explanations. No numbering.
- Separate each couplet with exactly ONE blank line.
- Every single line MUST be 70 to 130 characters long. SHORT LINES ARE FORBIDDEN.
- Every couplet MUST rhyme (end words rhyme between line 1 and line 2).
- Reference the avatar description specifically on EVERY couplet — mention their look directly.
- Use these Roblox references liberally: Robux, noob, ODer, Bacon Hair, free model, default avatar, ban hammer, lag, catalog, UGC, Bloxburg, Adopt Me, R6, R15, free shirt, guest.
- Each couplet must be MORE devastating than the previous — escalate intensity.
- The FINAL couplet is the hardest KO punchline of them all — save the best for last.
- NEVER repeat the same rhyme sound twice across all couplets.

Begin writing the %d couplets now. Output NOTHING except the couplets:]], desc, catInstr, intensityLine, grammarLine, nCouplets, nCouplets)
end

-- ─── API CALL ────────────────────────────────────────────────────────────────
local function GenerateRap(url, key, model, prompt, callback)
    local req = (syn and syn.request) or (http and http.request) or request or nil
    if not req then
        callback(nil, "No HTTP support in your executor. Try Synapse X, KRNL, or Fluxus.")
        return
    end
    if not key or #key < 4 then
        callback(nil, "API key is too short or missing.")
        return
    end
    if not url or #url < 10 then
        callback(nil, "API endpoint URL is missing or invalid.")
        return
    end
    if not model or #model < 2 then
        callback(nil, "Model name is required.")
        return
    end

    local encOk, body = pcall(function()
        return HttpService:JSONEncode({
            model       = model,
            max_tokens  = 1600,
            temperature = 0.92,
            messages    = {
                {role="system", content="You are the greatest Roblox rap battle ghostwriter. Output ONLY raw rap couplets — zero preamble, zero commentary, zero explanations. Just bars."},
                {role="user",   content=prompt},
            }
        })
    end)
    if not encOk then
        callback(nil, "Failed to build request: "..tostring(body))
        return
    end

    task.spawn(function()
        local reqOk, res = pcall(function()
            return req({
                Url    = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"]  = "application/json",
                    ["Authorization"] = "Bearer "..tostring(key),
                },
                Body = body,
            })
        end)

        if not reqOk then
            callback(nil, "Request failed: "..tostring(res))
            return
        end
        if not res then
            callback(nil, "No response from API.")
            return
        end

        local decoded
        local decOk = pcall(function()
            decoded = HttpService:JSONDecode(tostring(res.Body or ""))
        end)
        if not decOk or type(decoded) ~= "table" then
            local raw = tostring(res.Body or ""):sub(1, 150)
            callback(nil, "Could not parse response. Got: "..raw)
            return
        end

        if decoded.error then
            local msg = tostring(decoded.error.message or decoded.error.type or "API error")
            callback(nil, "API error: "..msg)
            return
        end

        local text = decoded.choices
            and decoded.choices[1]
            and decoded.choices[1].message
            and decoded.choices[1].message.content
        if not text or tostring(text) == "" then
            callback(nil, "Model returned empty content. Try a different model or key.")
            return
        end
        text = tostring(text)

        -- Strip <think> reasoning blocks
        text = text:gsub("<think>.-</think>", "")
        text = text:gsub("</?[Tt]hink>", "")

        -- Strip common preamble patterns
        local preambles = {
            "^[Hh]ere [Aa]re[^\n]*\n+",
            "^[Ss]ure[%!%,%.]*[^\n]*\n+",
            "^[Oo]kay[%!%,%.]*[^\n]*\n+",
            "^[Aa]lright[%!%,%.]*[^\n]*\n+",
            "^[Gg]ot it[%!%,%.]*[^\n]*\n+",
            "^[Rr]ap [Bb]ars?[^\n]*\n+",
            "^[Cc]ouplets?[^\n]*\n+",
            "^%*%*[^\n]*%*%*\n+",
        }
        for _, pat in ipairs(preambles) do
            text = text:gsub(pat, "")
        end
        text = text:match("^%s*(.-)%s*$") or text

        -- Parse into lines with couplet break tokens
        local lines = {}
        local prevWasContent = false
        for ln in (text.."\n"):gmatch("([^\n]*)\n") do
            local tr = ln:match("^%s*(.-)%s*$") or ""
            -- Strip bullets / numbering
            tr = tr:gsub("^%d+[%.%)%:%)%-%–]%s*", "")
            tr = tr:gsub("^[%-%*•►▸]%s*", "")
            tr = tr:gsub("^%*%*(.-)%*%*$", "%1") -- strip **bold**
            tr = tr:match("^%s*(.-)%s*$") or tr
            if #tr > 4 then
                table.insert(lines, tr)
                prevWasContent = true
            elseif prevWasContent then
                table.insert(lines, "---BREAK---")
                prevWasContent = false
            end
        end
        -- Clean trailing breaks
        while #lines > 0 and lines[#lines] == "---BREAK---" do
            table.remove(lines)
        end

        if #lines == 0 then
            callback(nil, "Parsed response but found no rap lines. Try again.")
            return
        end

        callback(lines, nil)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  BUILD GUI
-- ═══════════════════════════════════════════════════════════════════════════════
local SGui = Instance.new("ScreenGui")
SGui.Name = "FlowForgeGUI"; SGui.ResetOnSpawn = false
SGui.DisplayOrder = 999; SGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SGui.Parent = PGui

local WIN_W, WIN_H = 470, 630

local Backdrop = Instance.new("Frame")
Backdrop.Size = UDim2.new(1,0,1,0); Backdrop.BackgroundColor3 = Color3.new(0,0,0)
Backdrop.BackgroundTransparency = 1; Backdrop.BorderSizePixel = 0
Backdrop.ZIndex = 1; Backdrop.Parent = SGui

local Win = Instance.new("Frame")
Win.Size = UDim2.new(0,WIN_W,0,WIN_H)
Win.Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
Win.BackgroundColor3 = C.BG1; Win.BorderSizePixel = 0
Win.ZIndex = 10; Win.ClipsDescendants = true; Win.Parent = SGui
Corner(Win,14); Stroke(Win,C.BORDER2,1)

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1,0,0,3); TopLine.BackgroundColor3 = C.ACC1
TopLine.BorderSizePixel = 0; TopLine.ZIndex = 15; TopLine.Parent = Win
Grad(TopLine, C.ACC3, C.ACC2, 0)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,58); Header.BackgroundColor3 = C.BG0
Header.BorderSizePixel = 0; Header.ZIndex = 11; Header.Parent = Win
Corner(Header, 14)
local hf = Instance.new("Frame", Header)
hf.Size = UDim2.new(1,0,0,14); hf.Position = UDim2.new(0,0,1,-14)
hf.BackgroundColor3 = C.BG0; hf.BorderSizePixel = 0; hf.ZIndex = 11

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0,36,0,36); Logo.Position = UDim2.new(0,12,0.5,-18)
Logo.BackgroundColor3 = C.ACC1; Logo.BorderSizePixel = 0
Logo.ZIndex = 12; Logo.Parent = Header
Corner(Logo,10); Grad(Logo,C.ACC3,C.ACC1,130)
Lbl(Logo,{Text="⚡",Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,TextColor3=C.TXT0,ZIndex=13})

Lbl(Header,{Text="FLOWFORGE",Size=UDim2.new(1,-120,0,26),
    Position=UDim2.new(0,56,0,7),Font=Enum.Font.GothamBold,TextColor3=C.TXT0,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12})
Lbl(Header,{Text="Free AI Rap Battle Generator  •  v4",
    Size=UDim2.new(1,-120,0,15),Position=UDim2.new(0,56,0,35),
    Font=Enum.Font.Gotham,TextColor3=C.TXT2,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12})

local XBtn = Btn(Header,{Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-40,0.5,-14),
    BackgroundColor3=C.BG2,TextColor3=C.TXT1,Text="✕",Font=Enum.Font.GothamBold,ZIndex=13})
Corner(XBtn,7); Stroke(XBtn,C.BORDER,1); HoverBtn(XBtn,C.BG2,C.RED)
XBtn.MouseButton1Click:Connect(function()
    Tw(Win,0.18,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1})
    Tw(Backdrop,0.18,{BackgroundTransparency=1})
    task.delay(0.22, function() SGui:Destroy() end)
end)

-- Body scroll
local Body = Instance.new("ScrollingFrame")
Body.Size = UDim2.new(1,0,1,-62); Body.Position = UDim2.new(0,0,0,62)
Body.BackgroundTransparency = 1; Body.BorderSizePixel = 0
Body.ScrollBarThickness = 3; Body.ScrollBarImageColor3 = C.ACC1
Body.CanvasSize = UDim2.new(0,0,0,0); Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.ZIndex = 11; Body.Parent = Win
local BL = Instance.new("UIListLayout",Body)
BL.Padding = UDim.new(0,8); BL.SortOrder = Enum.SortOrder.LayoutOrder
local BP = Instance.new("UIPadding",Body)
BP.PaddingLeft=UDim.new(0,12); BP.PaddingRight=UDim.new(0,12)
BP.PaddingTop=UDim.new(0,12);  BP.PaddingBottom=UDim.new(0,18)

-- Section builder
local function Section(title, icon, order)
    local s = Instance.new("Frame"); s.Size = UDim2.new(1,0,0,0)
    s.AutomaticSize = Enum.AutomaticSize.Y; s.BackgroundColor3 = C.BG2
    s.BorderSizePixel = 0; s.LayoutOrder = order; s.Parent = Body
    Corner(s,10); Stroke(s,C.BORDER,1)
    local sl = Instance.new("UIListLayout",s); sl.Padding = UDim.new(0,6)
    local sp = Instance.new("UIPadding",s)
    sp.PaddingLeft=UDim.new(0,10); sp.PaddingRight=UDim.new(0,10)
    sp.PaddingTop=UDim.new(0,8);   sp.PaddingBottom=UDim.new(0,10)
    Lbl(s,{Text=icon.."  "..title,Size=UDim2.new(1,0,0,18),Font=Enum.Font.GothamBold,
        TextColor3=C.TXT2,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12,LayoutOrder=0})
    local div = Instance.new("Frame",s); div.Size = UDim2.new(1,0,0,1)
    div.BackgroundColor3 = C.BORDER; div.BorderSizePixel = 0; div.LayoutOrder = 1
    return s
end

-- Input box builder
local function InputBox(parent, ph, h, order, multi)
    local w = Instance.new("Frame"); w.Size = UDim2.new(1,0,0,h)
    w.BackgroundColor3 = C.BG0; w.BorderSizePixel = 0
    w.LayoutOrder = order; w.Parent = parent; Corner(w,8)
    local sk = Stroke(w,C.BORDER,1)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(1,-16,1,-8); b.Position = UDim2.new(0,8,0,4)
    b.BackgroundTransparency = 1; b.TextColor3 = C.TXT0; b.PlaceholderColor3 = C.TXT2
    b.PlaceholderText = ph; b.Font = Enum.Font.Gotham; b.TextScaled = true
    b.TextWrapped = true; b.MultiLine = multi or false
    b.ClearTextOnFocus = false; b.BorderSizePixel = 0; b.ZIndex = 13; b.Parent = w
    b.Focused:Connect(function() Tw(sk,0.15,{Color=C.ACC1,Thickness=1.5}); Tw(w,0.15,{BackgroundColor3=C.BG1}) end)
    b.FocusLost:Connect(function() Tw(sk,0.15,{Color=C.BORDER,Thickness=1}); Tw(w,0.15,{BackgroundColor3=C.BG0}) end)
    return b, w
end

-- Chip row builder
local function ChipRow(parent, opts, default, order)
    local row = MkFrame(parent,{Size=UDim2.new(1,0,0,30),LayoutOrder=order})
    local rl = Instance.new("UIListLayout",row)
    rl.FillDirection = Enum.FillDirection.Horizontal; rl.Padding = UDim.new(0,5)
    rl.VerticalAlignment = Enum.VerticalAlignment.Center
    local sel = default; local btns = {}
    for _,v in ipairs(opts) do
        local b = Btn(row,{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
            BackgroundColor3=v==default and C.ACC1 or C.BG4,
            TextColor3=v==default and C.TXT0 or C.TXT2,
            Text="  "..tostring(v).."  ",Font=Enum.Font.GothamBold,ZIndex=13})
        Corner(b,7); btns[v] = b
        b.MouseButton1Click:Connect(function()
            sel = v
            for k, btn in pairs(btns) do
                Tw(btn,0.1,{BackgroundColor3=k==v and C.ACC1 or C.BG4,
                            TextColor3=k==v and C.TXT0 or C.TXT2})
            end
        end)
    end
    return row, function() return sel end
end

-- Toggle switch builder
local function ToggleSwitch(parent, offLabel, onLabel, order, initState)
    local state = initState or false
    local wrap = MkFrame(parent,{Size=UDim2.new(1,0,0,32),LayoutOrder=order})
    local wl = Instance.new("UIListLayout",wrap)
    wl.FillDirection = Enum.FillDirection.Horizontal
    wl.VerticalAlignment = Enum.VerticalAlignment.Center
    wl.Padding = UDim.new(0,10)

    local textLbl = Lbl(wrap,{Text=state and onLabel or offLabel,
        Size=UDim2.new(1,-62,1,0),Font=Enum.Font.GothamBold,
        TextColor3=state and C.TXT0 or C.TXT2,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0,50,0,26); track.BorderSizePixel = 0; track.ZIndex = 13
    track.BackgroundColor3 = state and C.ACC1 or C.BG4; track.Parent = wrap
    Corner(track,13)

    local thumb = Instance.new("Frame",track)
    thumb.Size = UDim2.new(0,20,0,20); thumb.BorderSizePixel = 0; thumb.ZIndex = 14
    thumb.BackgroundColor3 = C.TXT0
    thumb.Position = state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
    Corner(thumb,10)

    local hitbox = Btn(track,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=15})
    hitbox.MouseButton1Click:Connect(function()
        state = not state
        Tw(track,0.15,{BackgroundColor3=state and C.ACC1 or C.BG4})
        Tw(thumb,0.15,{Position=state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)})
        textLbl.Text = state and onLabel or offLabel
        Tw(textLbl,0.1,{TextColor3=state and C.TXT0 or C.TXT2})
    end)

    return wrap, function() return state end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  SECTION 1 — PROVIDER & KEY
-- ═══════════════════════════════════════════════════════════════════════════
local S1 = Section("Provider & API Key","🔑",1)

local provRow = MkFrame(S1,{Size=UDim2.new(1,0,0,30),LayoutOrder=2})
local prl = Instance.new("UIListLayout",provRow)
prl.FillDirection = Enum.FillDirection.Horizontal; prl.Padding = UDim.new(0,5)

local selProv = 1; local provBtns = {}
for i, p in ipairs(PROVIDERS) do
    local b = Btn(provRow,{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=i==1 and C.ACC1 or C.BG4,
        TextColor3=i==1 and C.TXT0 or C.TXT2,
        Text="  "..p.name.."  ",Font=Enum.Font.GothamBold,ZIndex=13})
    Corner(b,7); provBtns[i] = b
end

local ProvHint = Lbl(S1,{Text="ⓘ  "..PROVIDERS[1].hint,Size=UDim2.new(1,0,0,14),
    Font=Enum.Font.Gotham,TextColor3=C.BLUE,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,LayoutOrder=3})

local ApiBox, ApiWrap = InputBox(S1,"Paste your API key...",38,4)
ApiBox.TextTransparency = 0.5

local keyRow = MkFrame(S1,{Size=UDim2.new(1,0,0,24),LayoutOrder=5})
local krl = Instance.new("UIListLayout",keyRow)
krl.FillDirection = Enum.FillDirection.Horizontal; krl.Padding = UDim.new(0,6)
krl.VerticalAlignment = Enum.VerticalAlignment.Center
Lbl(keyRow,{Text="Key only sent to your chosen provider — never stored",
    Size=UDim2.new(1,-80,1,0),Font=Enum.Font.Gotham,TextColor3=C.TXT2,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})
local ShowKeyBtn = Btn(keyRow,{Size=UDim2.new(0,74,1,0),BackgroundColor3=C.BG4,
    TextColor3=C.TXT1,Text="👁 Show",Font=Enum.Font.GothamBold,ZIndex=13})
Corner(ShowKeyBtn,6)
local keyVis = false
ShowKeyBtn.MouseButton1Click:Connect(function()
    keyVis = not keyVis
    ApiBox.TextTransparency = keyVis and 0 or 0.5
    ShowKeyBtn.Text = keyVis and "🙈 Hide" or "👁 Show"
end)

SecLbl(S1,"Model",6)
local ModelBox, _ = InputBox(S1,"e.g. Meta-Llama-3.3-70B-Instruct",34,7)
ModelBox.Text = PROVIDERS[1].model

local UrlSectionLbl = SecLbl(S1,"Custom API Endpoint URL",8)
local UrlBox, _ = InputBox(S1,"https://api.example.com/v1/chat/completions",34,9)
UrlSectionLbl.Visible = false; UrlBox.Parent.Visible = false

for i, _ in ipairs(PROVIDERS) do
    provBtns[i].MouseButton1Click:Connect(function()
        selProv = i
        local p = PROVIDERS[i]
        for k, b in pairs(provBtns) do
            Tw(b,0.1,{BackgroundColor3=k==i and C.ACC1 or C.BG4,
                      TextColor3=k==i and C.TXT0 or C.TXT2})
        end
        if p.model ~= "" then ModelBox.Text = p.model end
        ProvHint.Text = "ⓘ  "..p.hint
        local isCustom = (i == #PROVIDERS)
        UrlSectionLbl.Visible = isCustom; UrlBox.Parent.Visible = isCustom
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  SECTION 2 — DESCRIPTION
-- ═══════════════════════════════════════════════════════════════════════════
local S2 = Section("Avatar Description","👾",2)
SecLbl(S2,"Describe their avatar — more detail = harder bars",2)
local DescBox, _ = InputBox(S2,
    "e.g. Bacon Hair, free shirt, blue pants, no accessories, default face, looks like they joined yesterday...",
    82,3,true)
local charLbl = Lbl(S2,{Text="0 / 300",Size=UDim2.new(1,0,0,14),Font=Enum.Font.Gotham,
    TextColor3=C.TXT2,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=13,LayoutOrder=4})
DescBox:GetPropertyChangedSignal("Text"):Connect(function()
    local n = math.min(#DescBox.Text, 300)
    charLbl.Text = n.." / 300"
    charLbl.TextColor3 = n > 260 and C.YELLOW or C.TXT2
    if #DescBox.Text > 300 then DescBox.Text = DescBox.Text:sub(1,300) end
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  SECTION 3 — CATEGORY
-- ═══════════════════════════════════════════════════════════════════════════
local S3 = Section("Rap Category","🎭",3)
SecLbl(S3,"Choose your roast style",2)

local CatGrid = Instance.new("Frame")
CatGrid.Size = UDim2.new(1,0,0,0); CatGrid.AutomaticSize = Enum.AutomaticSize.Y
CatGrid.BackgroundTransparency = 1; CatGrid.BorderSizePixel = 0
CatGrid.LayoutOrder = 3; CatGrid.Parent = S3
local CatGL = Instance.new("UIGridLayout",CatGrid)
CatGL.CellSize = UDim2.new(0.5,-4,0,34); CatGL.CellPaddingSize = UDim2.new(0,6,0,6)
CatGL.SortOrder = Enum.SortOrder.LayoutOrder

local selCat = 1; local catBtns = {}
for i, cat in ipairs(CATEGORIES) do
    local b = Btn(CatGrid,{BackgroundColor3=i==1 and C.ACC1 or C.BG4,
        TextColor3=i==1 and C.TXT0 or C.TXT2,
        Text=cat.name,Font=Enum.Font.GothamBold,ZIndex=13,LayoutOrder=i})
    Corner(b,8); catBtns[i] = b
    b.MouseButton1Click:Connect(function()
        selCat = i
        for k, btn in pairs(catBtns) do
            Tw(btn,0.1,{BackgroundColor3=k==i and C.ACC1 or C.BG4,
                        TextColor3=k==i and C.TXT0 or C.TXT2})
        end
        CatDescLbl.Text = "✦  "..CATEGORIES[i].instr
    end)
end

local CatDescLbl = Lbl(S3,{Text="✦  "..CATEGORIES[1].instr,
    Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
    Font=Enum.Font.Gotham,TextColor3=C.GOLD,TextWrapped=true,
    TextScaled=false,TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,LayoutOrder=4})

-- ═══════════════════════════════════════════════════════════════════════════
--  SECTION 4 — SETTINGS
-- ═══════════════════════════════════════════════════════════════════════════
local S4 = Section("Rap Settings","⚙",4)

SecLbl(S4,"Couplets  (1 couplet = 2 rhyming lines)",2)
local _, getCouplets = ChipRow(S4,{3,4,5,6,8,10},5,3)

SecLbl(S4,"Intensity",4)
local _, getIntensity = ChipRow(S4,{"Mild","Medium","Hard","NUCLEAR"},"Hard",5)

local _, getGrammar = ToggleSwitch(S4,"Street style (no grammar)","✓ Proper grammar",6,false)

-- ═══════════════════════════════════════════════════════════════════════════
--  GENERATE BUTTON
-- ═══════════════════════════════════════════════════════════════════════════
local GenBtn = Btn(Body,{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.ACC1,
    TextColor3=C.TXT0,Text="⚡   GENERATE BARS",Font=Enum.Font.GothamBold,
    LayoutOrder=5,ZIndex=13})
Corner(GenBtn,12); Grad(GenBtn,C.ACC3,C.ACC2,45)
HoverBtn(GenBtn,C.ACC1,Color3.fromRGB(155,90,255))

-- Status bar
local StatWrap = Instance.new("Frame")
StatWrap.Size = UDim2.new(1,0,0,34); StatWrap.BackgroundColor3 = C.BG2
StatWrap.BorderSizePixel = 0; StatWrap.LayoutOrder = 6; StatWrap.Parent = Body
Corner(StatWrap,8); Stroke(StatWrap,C.BORDER,1)
local StatLbl = Lbl(StatWrap,{
    Text="⚡  Pick provider → paste key → describe → generate",
    Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,0),
    Font=Enum.Font.Gotham,TextColor3=C.TXT2,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})

-- Progress bar
local ProgWrap = MkFrame(Body,{Size=UDim2.new(1,0,0,6),LayoutOrder=7})
local ProgTrack = Instance.new("Frame",ProgWrap)
ProgTrack.Size = UDim2.new(1,0,1,0); ProgTrack.BackgroundColor3 = C.BORDER
ProgTrack.BorderSizePixel = 0; Corner(ProgTrack,3)
local ProgFill = Instance.new("Frame",ProgTrack)
ProgFill.Size = UDim2.new(0,0,1,0); ProgFill.BackgroundColor3 = C.ACC1
ProgFill.BorderSizePixel = 0; Corner(ProgFill,3); Grad(ProgFill,C.ACC3,C.ACC2,0)
ProgWrap.Visible = false

-- ═══════════════════════════════════════════════════════════════════════════
--  BARS OUTPUT SECTION
-- ═══════════════════════════════════════════════════════════════════════════
local BarsSection = Instance.new("Frame")
BarsSection.Size = UDim2.new(1,0,0,0); BarsSection.AutomaticSize = Enum.AutomaticSize.Y
BarsSection.BackgroundColor3 = C.BG2; BarsSection.BorderSizePixel = 0
BarsSection.LayoutOrder = 8; BarsSection.Visible = false; BarsSection.Parent = Body
Corner(BarsSection,10); Stroke(BarsSection,C.GREEN,1)

local BarsSL = Instance.new("UIListLayout",BarsSection); BarsSL.Padding = UDim.new(0,6)
local BarsSP = Instance.new("UIPadding",BarsSection)
BarsSP.PaddingLeft=UDim.new(0,10); BarsSP.PaddingRight=UDim.new(0,10)
BarsSP.PaddingTop=UDim.new(0,10);  BarsSP.PaddingBottom=UDim.new(0,10)

-- Bars header
local bHdrRow = MkFrame(BarsSection,{Size=UDim2.new(1,0,0,26),LayoutOrder=0})
local bHdrL = Instance.new("UIListLayout",bHdrRow)
bHdrL.FillDirection = Enum.FillDirection.Horizontal; bHdrL.Padding = UDim.new(0,8)
bHdrL.VerticalAlignment = Enum.VerticalAlignment.Center
Lbl(bHdrRow,{Text="🎤  Your Bars — tap to copy",
    Size=UDim2.new(1,-120,1,0),Font=Enum.Font.GothamBold,
    TextColor3=C.GREEN,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})
local CopyAllBtn = Btn(bHdrRow,{Size=UDim2.new(0,112,1,0),BackgroundColor3=C.BG4,
    TextColor3=C.GREEN,Text="📋 Copy All",Font=Enum.Font.GothamBold,ZIndex=13})
Corner(CopyAllBtn,6); Stroke(CopyAllBtn,C.GREEN,1)
HoverBtn(CopyAllBtn,C.BG4,Color3.fromRGB(20,55,35))

local bDiv = Instance.new("Frame",BarsSection)
bDiv.Size=UDim2.new(1,0,0,1); bDiv.BackgroundColor3=C.BORDER
bDiv.BorderSizePixel=0; bDiv.LayoutOrder=1

local BarsContainer = Instance.new("Frame",BarsSection)
BarsContainer.Size=UDim2.new(1,0,0,0); BarsContainer.AutomaticSize=Enum.AutomaticSize.Y
BarsContainer.BackgroundTransparency=1; BarsContainer.BorderSizePixel=0; BarsContainer.LayoutOrder=2
local BCL = Instance.new("UIListLayout",BarsContainer); BCL.Padding=UDim.new(0,3)

Lbl(BarsSection,{Text="Tap any bar row to copy it  •  Paste into Roblox chat during your battle",
    Size=UDim2.new(1,0,0,14),Font=Enum.Font.Gotham,
    TextColor3=C.TXT2,ZIndex=13,LayoutOrder=3})

-- Clipboard helper (TextBox focus trick — works in most executors)
local CopyBox = Instance.new("TextBox")
CopyBox.Size=UDim2.new(0,1,0,1); CopyBox.Position=UDim2.new(2,0,2,0)
CopyBox.BackgroundTransparency=1; CopyBox.TextTransparency=1
CopyBox.Text=""; CopyBox.ZIndex=1; CopyBox.Parent=SGui

local function CopyToClipboard(txt)
    pcall(function()
        CopyBox.Text = tostring(txt)
        CopyBox:CaptureFocus()
        CopyBox.SelectionStart = 1
        CopyBox.CursorPosition = #CopyBox.Text + 1
    end)
end

-- ── BUILD BAR ROWS ────────────────────────────────────────────────────────────
local allPlainLines = {}

local function BuildBars(lines)
    allPlainLines = {}
    for _, l in ipairs(lines) do
        if l ~= "---BREAK---" then table.insert(allPlainLines, l) end
    end

    -- Clear old children (except UIListLayout)
    for _, ch in ipairs(BarsContainer:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end

    local barNum = 0
    for idx, line in ipairs(lines) do
        if line == "---BREAK---" then
            local sp = Instance.new("Frame",BarsContainer)
            sp.Size=UDim2.new(1,0,0,5); sp.BackgroundTransparency=1
            sp.BorderSizePixel=0; sp.LayoutOrder=idx
        else
            barNum = barNum + 1
            local isOdd = barNum % 2 == 1
            local normBg = isOdd and C.BG3 or C.BG4

            local row = Btn(BarsContainer,{
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=normBg,Text="",ZIndex=13,LayoutOrder=idx})
            Corner(row,7)

            local rowL = Instance.new("UIListLayout",row)
            rowL.FillDirection=Enum.FillDirection.Horizontal
            rowL.VerticalAlignment=Enum.VerticalAlignment.Center
            rowL.Padding=UDim.new(0,6)
            local rowP = Instance.new("UIPadding",row)
            rowP.PaddingLeft=UDim.new(0,8); rowP.PaddingRight=UDim.new(0,8)
            rowP.PaddingTop=UDim.new(0,7);  rowP.PaddingBottom=UDim.new(0,7)

            -- Number / rhyme badge
            local badge = Instance.new("Frame")
            badge.Size=UDim2.new(0,22,0,22); badge.BorderSizePixel=0; badge.ZIndex=14
            badge.BackgroundColor3 = isOdd and C.ACC1 or C.ACC3
            badge.Parent = row; Corner(badge,6)
            Lbl(badge,{Text=isOdd and tostring(math.ceil(barNum/2)) or "♪",
                Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,TextColor3=C.TXT0,ZIndex=15})

            local capLine = tostring(line)
            Lbl(row,{Text=capLine,Size=UDim2.new(1,-76,0,0),AutomaticSize=Enum.AutomaticSize.Y,
                Font=Enum.Font.Gotham,TextColor3=C.TXT0,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextWrapped=true,TextScaled=false,TextSize=12,ZIndex=14})

            local cpyBtn = Btn(row,{Size=UDim2.new(0,36,0,26),
                BackgroundColor3=C.BG5,TextColor3=C.ACC2,
                Text="📋",Font=Enum.Font.GothamBold,TextScaled=true,ZIndex=14})
            Corner(cpyBtn,6)

            row.MouseEnter:Connect(function() Tw(row,0.1,{BackgroundColor3=C.BG5}) end)
            row.MouseLeave:Connect(function() Tw(row,0.1,{BackgroundColor3=normBg}) end)

            local function doCopy()
                CopyToClipboard(capLine)
                cpyBtn.Text = "✅"
                Tw(cpyBtn,0.1,{TextColor3=C.GREEN,BackgroundColor3=Color3.fromRGB(18,48,30)})
                task.delay(1.5,function()
                    if cpyBtn and cpyBtn.Parent then
                        cpyBtn.Text="📋"
                        Tw(cpyBtn,0.12,{TextColor3=C.ACC2,BackgroundColor3=C.BG5})
                    end
                end)
            end
            row.MouseButton1Click:Connect(doCopy)
            cpyBtn.MouseButton1Click:Connect(doCopy)
        end
    end

    -- Copy All
    CopyAllBtn.MouseButton1Click:Connect(function()
        CopyToClipboard(table.concat(allPlainLines,"\n"))
        CopyAllBtn.Text = "✅ Copied!"
        Tw(CopyAllBtn,0.1,{BackgroundColor3=C.GREEN,TextColor3=C.BG0})
        task.delay(1.8,function()
            if CopyAllBtn and CopyAllBtn.Parent then
                CopyAllBtn.Text = "📋 Copy All"
                Tw(CopyAllBtn,0.15,{BackgroundColor3=C.BG4,TextColor3=C.GREEN})
            end
        end)
    end)

    BarsSection.Visible = true
    task.delay(0.15,function()
        if Body and Body.Parent then
            Body.CanvasPosition = Vector2.new(0, Body.AbsoluteCanvasSize.Y)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  GENERATE LOGIC
-- ═══════════════════════════════════════════════════════════════════════════
local busy = false
local function setStatus(txt,col) StatLbl.Text=txt; StatLbl.TextColor3=col or C.TXT2 end

GenBtn.MouseButton1Click:Connect(function()
    if busy then return end

    local prov      = PROVIDERS[selProv]
    local key       = tostring(ApiBox.Text or "")
    local desc      = tostring(DescBox.Text or "")
    local model     = tostring(ModelBox.Text or "")
    local url       = selProv==#PROVIDERS and tostring(UrlBox.Text or "") or prov.url
    local nCouplets = getCouplets()
    local intensity = getIntensity()
    local grammar   = getGrammar()
    local cat       = CATEGORIES[selCat]

    if key=="" or #key<4 then
        setStatus("⚠  Paste your API key first!",C.YELLOW)
        Tw(ApiWrap,0.07,{BackgroundColor3=Color3.fromRGB(55,28,8)})
        task.delay(0.6,function() Tw(ApiWrap,0.3,{BackgroundColor3=C.BG0}) end)
        return
    end
    if desc=="" or #desc<5 then
        setStatus("⚠  Describe the opponent's avatar first!",C.YELLOW); return
    end
    if model=="" or #model<2 then
        setStatus("⚠  Enter a model name in the Model field!",C.YELLOW); return
    end
    if selProv==#PROVIDERS and (url=="" or #url<10) then
        setStatus("⚠  Enter your custom API endpoint URL!",C.YELLOW); return
    end

    busy = true
    BarsSection.Visible = false
    ProgWrap.Visible = true
    Tw(ProgFill,0.8,{Size=UDim2.new(0.4,0,1,0)})
    GenBtn.Text = "⏳  Cooking up bars..."
    Tw(GenBtn,0.1,{BackgroundColor3=C.BG3})
    setStatus("🤖  AI is writing your bars ("..nCouplets.." couplets, "..intensity.." intensity)...",C.BLUE)

    local prompt = BuildPrompt(desc, nCouplets, cat.instr, grammar, intensity)

    GenerateRap(url, key, model, prompt, function(lines, err)
        busy = false
        ProgWrap.Visible = false
        ProgFill.Size = UDim2.new(0,0,1,0)
        GenBtn.Text = "⚡   GENERATE BARS"
        Tw(GenBtn,0.1,{BackgroundColor3=C.ACC1})

        if err or not lines then
            setStatus("❌  "..(err or "Unknown error"),C.RED)
            return
        end

        local lineCount = 0
        for _, l in ipairs(lines) do
            if l ~= "---BREAK---" then lineCount = lineCount + 1 end
        end
        setStatus("✅  "..lineCount.." bars ready — tap any line to copy it!",C.GREEN)
        BuildBars(lines)
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  DRAGGING
-- ═══════════════════════════════════════════════════════════════════════════
local drag, dragInp, dragStart, startPos
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag=true; dragStart=i.Position; startPos=Win.Position
        i.Changed:Connect(function()
            if i.UserInputState==Enum.UserInputState.End then drag=false end
        end)
    end
end)
Header.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement then dragInp=i end
end)
UserInputService.InputChanged:Connect(function(i)
    if i==dragInp and drag then
        local d = i.Position - dragStart
        Win.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                  startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  OPEN ANIMATION
-- ═══════════════════════════════════════════════════════════════════════════
Win.Size = UDim2.new(0,WIN_W,0,0); Win.BackgroundTransparency = 1
Backdrop.BackgroundTransparency = 1
Tw(Backdrop,0.25,{BackgroundTransparency=0.55})
TweenService:Create(Win,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0}):Play()

task.spawn(function()
    while SGui and SGui.Parent do
        Tw(TopLine,2,{BackgroundTransparency=0.4},Enum.EasingStyle.Sine)
        task.wait(2)
        Tw(TopLine,2,{BackgroundTransparency=0},Enum.EasingStyle.Sine)
        task.wait(2)
    end
end)

print("[FlowForge v4] Loaded — Longer bars, 8 categories, grammar toggle, no auto-send 🔥")
