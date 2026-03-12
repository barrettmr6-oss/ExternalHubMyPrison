-- FlowForge v3 | Free AI Rap Generator | Copy & Paste Bars
-- Supports: SambaNova (free) + OpenAI + any OpenAI-compatible API
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local Players,TweenService,UserInputService,HttpService,RunService =
    game:GetService("Players"),game:GetService("TweenService"),
    game:GetService("UserInputService"),game:GetService("HttpService"),
    game:GetService("RunService")
local LP = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")
if PGui:FindFirstChild("FlowForgeGUI") then PGui.FlowForgeGUI:Destroy() end

-- ─── PALETTE ─────────────────────────────────────────────────────────────────
local C = {
    BG0=Color3.fromRGB(6,6,10),    BG1=Color3.fromRGB(12,11,19),
    BG2=Color3.fromRGB(18,16,30),  BG3=Color3.fromRGB(26,23,42),
    BG4=Color3.fromRGB(34,30,56),
    BORDER=Color3.fromRGB(38,33,60),  BORDER2=Color3.fromRGB(62,54,98),
    ACC1=Color3.fromRGB(140,74,255),  ACC2=Color3.fromRGB(76,168,255),
    ACC3=Color3.fromRGB(255,82,162),  GOLD=Color3.fromRGB(255,198,58),
    TXT0=Color3.fromRGB(238,232,255), TXT1=Color3.fromRGB(162,152,198),
    TXT2=Color3.fromRGB(86,76,126),
    GREEN=Color3.fromRGB(58,228,138), RED=Color3.fromRGB(255,72,72),
    YELLOW=Color3.fromRGB(255,208,58),BLUE=Color3.fromRGB(76,168,255),
}

-- ─── PROVIDERS CONFIG ────────────────────────────────────────────────────────
-- Each provider: name, url, default model, models list, hint
local PROVIDERS = {
    {
        name    = "SambaNova (FREE)",
        url     = "https://api.sambanova.ai/v1/chat/completions",
        model   = "Meta-Llama-3.3-70B-Instruct",
        models  = {
            "Meta-Llama-3.3-70B-Instruct",
            "Meta-Llama-3.1-8B-Instruct",
            "Meta-Llama-3.1-405B-Instruct",
            "DeepSeek-V3-0324",
            "DeepSeek-R1-Distill-Llama-70B",
            "Llama-4-Maverick-17B-128E-Instruct",
            "QwQ-32B",
        },
        hint    = "Get free key at cloud.sambanova.ai/apis",
        keypre  = "",
    },
    {
        name    = "OpenAI",
        url     = "https://api.openai.com/v1/chat/completions",
        model   = "gpt-4o-mini",
        models  = {"gpt-4o-mini","gpt-4o","gpt-3.5-turbo"},
        hint    = "Get key at platform.openai.com/api-keys",
        keypre  = "sk-",
    },
    {
        name    = "Custom API",
        url     = "",
        model   = "",
        models  = {},
        hint    = "Enter your OpenAI-compatible endpoint URL",
        keypre  = "",
    },
}

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function Tw(o,t,p,s,d)
    s=s or Enum.EasingStyle.Quint; d=d or Enum.EasingDirection.Out
    TweenService:Create(o,TweenInfo.new(t,s,d),p):Play()
end
local function Corner(p,r) local c=Instance.new("UICorner",p);c.CornerRadius=UDim.new(0,r or 8) end
local function Stroke(p,col,th) local s=Instance.new("UIStroke",p);s.Color=col;s.Thickness=th or 1;return s end
local function Grad(p,c0,c1,a)
    local g=Instance.new("UIGradient",p);g.Color=ColorSequence.new(c0,c1);g.Rotation=a or 90;return g
end
local function Lbl(parent,props)
    local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.TextScaled=true
    for k,v in pairs(props) do l[k]=v end;l.Parent=parent;return l
end
local function Btn(parent,props)
    local b=Instance.new("TextButton");b.BackgroundTransparency=0;b.TextScaled=true
    b.AutoButtonColor=false;b.BorderSizePixel=0
    for k,v in pairs(props) do b[k]=v end;b.Parent=parent;return b
end
local function MkFrame(parent,props)
    local f=Instance.new("Frame");f.BackgroundTransparency=1;f.BorderSizePixel=0
    for k,v in pairs(props) do f[k]=v end;f.Parent=parent;return f
end
local function HoverBtn(b,colNorm,colHov)
    b.MouseEnter:Connect(function() Tw(b,0.12,{BackgroundColor3=colHov}) end)
    b.MouseLeave:Connect(function() Tw(b,0.12,{BackgroundColor3=colNorm}) end)
end

-- ─── API CALL ─────────────────────────────────────────────────────────────────
local function GenerateRap(url, key, model, description, numLines, callback)
    local req=(syn and syn.request)or(http and http.request)or request or nil
    if not req then callback(nil,"Executor HTTP not supported (try Synapse X / KRNL)");return end
    if not key or #key<4 then callback(nil,"API key is too short — check it again");return end
    if not url or #url<10 then callback(nil,"API URL is missing or invalid");return end
    if not model or #model<2 then callback(nil,"Model name is required");return end

    local prompt = string.format(
        "You are the most savage Roblox rap battle roaster alive. "..
        "Write EXACTLY %d rap lines roasting this Roblox avatar: %s\n\n"..
        "STRICT RULES:\n"..
        "- Output ONLY the rap lines — nothing else at all\n"..
        "- Each line on its own line, NO blank lines between them\n"..
        "- Keep every line under 100 characters\n"..
        "- No numbering, no bullet points, no intro, no outro\n"..
        "- Make it funny, savage, roast-focused\n"..
        "- Use Roblox slang and references\n"..
        "- Rhyme where possible\n"..
        "Output the %d lines now:",
        numLines, description, numLines
    )

    local body = HttpService:JSONEncode({
        model       = model,
        max_tokens  = 700,
        temperature = 0.9,
        messages    = {
            {role="system", content="You are a savage Roblox rap battle roaster. Output ONLY raw rap lines with no extra text."},
            {role="user",   content=prompt}
        }
    })

    task.spawn(function()
        local ok, res = pcall(function()
            return req({
                Url    = url,
                Method = "POST",
                Headers= {
                    ["Content-Type"]  = "application/json",
                    ["Authorization"] = "Bearer "..key,
                },
                Body = body
            })
        end)

        if not ok then callback(nil,"HTTP request failed: "..tostring(res));return end

        local decoded
        local decOk = pcall(function() decoded = HttpService:JSONDecode(res.Body) end)
        if not decOk or not decoded then
            callback(nil,"Could not parse API response. Check URL/key.");return
        end

        if decoded.error then
            local msg = decoded.error.message or decoded.error.type or "Unknown API error"
            callback(nil,"API Error: "..msg);return
        end

        local text = decoded.choices
            and decoded.choices[1]
            and decoded.choices[1].message
            and decoded.choices[1].message.content
        if not text then callback(nil,"Empty response from API");return end

        -- Also handle <think>...</think> tags some reasoning models add
        text = text:gsub("<think>.-</think>",""):gsub("</?think>","")
        text = text:match("^%s*(.-)%s*$")

        local lines = {}
        for line in text:gmatch("[^\n]+") do
            line = line:match("^%s*(.-)%s*$")
            -- Strip leading numbers/bullets like "1." "1)" "-" "*"
            line = line:gsub("^%d+[%.%)%:]%s*",""):gsub("^[%-%*•]%s*","")
            if #line > 3 then table.insert(lines, line) end
        end
        if #lines == 0 then callback(nil,"Model returned no lines. Try again.");return end
        callback(lines, nil)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  GUI
-- ═══════════════════════════════════════════════════════════════════════════════
local SGui = Instance.new("ScreenGui")
SGui.Name="FlowForgeGUI";SGui.ResetOnSpawn=false
SGui.DisplayOrder=999;SGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;SGui.Parent=PGui

local WIN_W, WIN_H = 460, 600

-- Backdrop
local Backdrop=Instance.new("Frame")
Backdrop.Size=UDim2.new(1,0,1,0);Backdrop.BackgroundColor3=Color3.new(0,0,0)
Backdrop.BackgroundTransparency=1;Backdrop.BorderSizePixel=0;Backdrop.ZIndex=1;Backdrop.Parent=SGui

-- Window
local Win=Instance.new("Frame")
Win.Size=UDim2.new(0,WIN_W,0,WIN_H)
Win.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
Win.BackgroundColor3=C.BG1;Win.BorderSizePixel=0
Win.ZIndex=10;Win.ClipsDescendants=true;Win.Parent=SGui
Corner(Win,14);Stroke(Win,C.BORDER2,1)

-- Rainbow top accent line
local TopLine=Instance.new("Frame")
TopLine.Size=UDim2.new(1,0,0,3);TopLine.BackgroundColor3=C.ACC1
TopLine.BorderSizePixel=0;TopLine.ZIndex=15;TopLine.Parent=Win
Grad(TopLine,C.ACC3,C.ACC2,0)

-- ─── HEADER ──────────────────────────────────────────────────────────────────
local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,56);Header.BackgroundColor3=C.BG0
Header.BorderSizePixel=0;Header.ZIndex=11;Header.Parent=Win
Corner(Header,14)
-- bottom corner fill
local hf=Instance.new("Frame",Header)
hf.Size=UDim2.new(1,0,0,14);hf.Position=UDim2.new(0,0,1,-14)
hf.BackgroundColor3=C.BG0;hf.BorderSizePixel=0;hf.ZIndex=11

-- Logo
local Logo=Instance.new("Frame")
Logo.Size=UDim2.new(0,34,0,34);Logo.Position=UDim2.new(0,12,0.5,-17)
Logo.BackgroundColor3=C.ACC1;Logo.BorderSizePixel=0;Logo.ZIndex=12;Logo.Parent=Header
Corner(Logo,9);Grad(Logo,C.ACC3,C.ACC1,130)
Lbl(Logo,{Text="⚡",Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,TextColor3=C.TXT0,ZIndex=13})

Lbl(Header,{Text="FLOWFORGE",Size=UDim2.new(1,-120,0,24),Position=UDim2.new(0,54,0,6),
    Font=Enum.Font.GothamBold,TextColor3=C.TXT0,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12})
Lbl(Header,{Text="Free AI Rap Generator  •  Copy & Paste Mode",
    Size=UDim2.new(1,-120,0,16),Position=UDim2.new(0,54,0,32),
    Font=Enum.Font.Gotham,TextColor3=C.TXT2,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12})

-- Close button
local XBtn=Btn(Header,{
    Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-40,0.5,-14),
    BackgroundColor3=C.BG2,TextColor3=C.TXT1,Text="✕",
    Font=Enum.Font.GothamBold,ZIndex=13
})
Corner(XBtn,7);Stroke(XBtn,C.BORDER,1)
HoverBtn(XBtn,C.BG2,C.RED)
XBtn.MouseButton1Click:Connect(function()
    Tw(Win,0.18,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1})
    Tw(Backdrop,0.18,{BackgroundTransparency=1})
    task.delay(0.2,function() SGui:Destroy() end)
end)

-- ─── SCROLLING BODY ──────────────────────────────────────────────────────────
local Body=Instance.new("ScrollingFrame")
Body.Size=UDim2.new(1,0,1,-60);Body.Position=UDim2.new(0,0,0,60)
Body.BackgroundTransparency=1;Body.BorderSizePixel=0
Body.ScrollBarThickness=3;Body.ScrollBarImageColor3=C.ACC1
Body.CanvasSize=UDim2.new(0,0,0,0);Body.AutomaticCanvasSize=Enum.AutomaticSize.Y
Body.ZIndex=11;Body.Parent=Win
local BL=Instance.new("UIListLayout",Body)
BL.Padding=UDim.new(0,8);BL.SortOrder=Enum.SortOrder.LayoutOrder
local BP=Instance.new("UIPadding",Body)
BP.PaddingLeft=UDim.new(0,12);BP.PaddingRight=UDim.new(0,12)
BP.PaddingTop=UDim.new(0,12);BP.PaddingBottom=UDim.new(0,16)

-- ─── SECTION HELPER ──────────────────────────────────────────────────────────
local function Section(title, icon, order)
    local s=Instance.new("Frame");s.Size=UDim2.new(1,0,0,0)
    s.AutomaticSize=Enum.AutomaticSize.Y;s.BackgroundColor3=C.BG2
    s.BorderSizePixel=0;s.LayoutOrder=order;s.Parent=Body
    Corner(s,10);Stroke(s,C.BORDER,1)
    local sl=Instance.new("UIListLayout",s);sl.Padding=UDim.new(0,6)
    local sp=Instance.new("UIPadding",s)
    sp.PaddingLeft=UDim.new(0,10);sp.PaddingRight=UDim.new(0,10)
    sp.PaddingTop=UDim.new(0,8);sp.PaddingBottom=UDim.new(0,10)
    Lbl(s,{Text=icon.."  "..title,Size=UDim2.new(1,0,0,18),
        Font=Enum.Font.GothamBold,TextColor3=C.TXT2,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12,LayoutOrder=0})
    local div=Instance.new("Frame",s);div.Size=UDim2.new(1,0,0,1)
    div.BackgroundColor3=C.BORDER;div.BorderSizePixel=0;div.LayoutOrder=1
    return s
end

-- ─── INPUT BOX HELPER ────────────────────────────────────────────────────────
local function InputBox(parent,ph,h,order,multi)
    local w=Instance.new("Frame");w.Size=UDim2.new(1,0,0,h);w.BackgroundColor3=C.BG0
    w.BorderSizePixel=0;w.LayoutOrder=order;w.Parent=parent;Corner(w,8)
    local sk=Stroke(w,C.BORDER,1)
    local b=Instance.new("TextBox");b.Size=UDim2.new(1,-16,1,-8);b.Position=UDim2.new(0,8,0,4)
    b.BackgroundTransparency=1;b.TextColor3=C.TXT0;b.PlaceholderColor3=C.TXT2
    b.PlaceholderText=ph;b.Font=Enum.Font.Gotham;b.TextScaled=true
    b.TextWrapped=true;b.MultiLine=multi or false;b.ClearTextOnFocus=false
    b.BorderSizePixel=0;b.ZIndex=13;b.Parent=w
    b.Focused:Connect(function() Tw(sk,0.15,{Color=C.ACC1,Thickness=1.5});Tw(w,0.15,{BackgroundColor3=C.BG1}) end)
    b.FocusLost:Connect(function() Tw(sk,0.15,{Color=C.BORDER,Thickness=1});Tw(w,0.15,{BackgroundColor3=C.BG0}) end)
    return b,w,sk
end

-- ─── CHIP ROW HELPER ─────────────────────────────────────────────────────────
local function ChipRow(parent,opts,default,order)
    local row=MkFrame(parent,{Size=UDim2.new(1,0,0,30),LayoutOrder=order})
    local rl=Instance.new("UIListLayout",row)
    rl.FillDirection=Enum.FillDirection.Horizontal;rl.Padding=UDim.new(0,5)
    rl.VerticalAlignment=Enum.VerticalAlignment.Center
    local sel=default;local btns={}
    for _,v in ipairs(opts) do
        local b=Btn(row,{
            Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
            BackgroundColor3=v==default and C.ACC1 or C.BG4,
            TextColor3=v==default and C.TXT0 or C.TXT2,
            Text="  "..tostring(v).."  ",Font=Enum.Font.GothamBold,ZIndex=13
        });Corner(b,7);btns[v]=b
        b.MouseButton1Click:Connect(function()
            sel=v
            for k,btn in pairs(btns) do
                Tw(btn,0.1,{BackgroundColor3=k==v and C.ACC1 or C.BG4,
                    TextColor3=k==v and C.TXT0 or C.TXT2})
            end
        end)
    end
    return row,function() return sel end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  SECTION 1 — PROVIDER
-- ═══════════════════════════════════════════════════════════════════════════
local S1 = Section("Provider & Model","🌐",1)

-- Provider selector buttons
local provRow=MkFrame(S1,{Size=UDim2.new(1,0,0,32),LayoutOrder=2})
local provRL=Instance.new("UIListLayout",provRow)
provRL.FillDirection=Enum.FillDirection.Horizontal;provRL.Padding=UDim.new(0,5)

local selProvider = 1
local provBtns = {}
for i,prov in ipairs(PROVIDERS) do
    local b=Btn(provRow,{
        Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=i==1 and C.ACC1 or C.BG4,
        TextColor3=i==1 and C.TXT0 or C.TXT2,
        Text="  "..prov.name:match("^([^%(]+)"):match("^%s*(.-)%s*$").."  ",
        Font=Enum.Font.GothamBold,ZIndex=13
    });Corner(b,7);provBtns[i]=b
end

-- Model input (text box, pre-filled)
Lbl(S1,{Text="Model",Size=UDim2.new(1,0,0,16),Font=Enum.Font.GothamBold,
    TextColor3=C.TXT1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,LayoutOrder=3})
local ModelBox,_,_ = InputBox(S1,"Model name",34,4)
ModelBox.Text = PROVIDERS[1].model

-- Custom URL (hidden unless Custom API selected)
local UrlLbl=Lbl(S1,{Text="API Endpoint URL",Size=UDim2.new(1,0,0,16),Font=Enum.Font.GothamBold,
    TextColor3=C.TXT1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,LayoutOrder=5})
local UrlBox,_,_ = InputBox(S1,"https://api.example.com/v1/chat/completions",34,6)
UrlLbl.Visible=false;UrlBox.Parent.Visible=false

-- Key hint
local ProvHint=Lbl(S1,{Text="ⓘ  "..PROVIDERS[1].hint,Size=UDim2.new(1,0,0,16),
    Font=Enum.Font.Gotham,TextColor3=C.BLUE,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,LayoutOrder=7})

-- Wire provider buttons
for i,_ in ipairs(PROVIDERS) do
    provBtns[i].MouseButton1Click:Connect(function()
        selProvider=i
        local prov=PROVIDERS[i]
        for k,b in pairs(provBtns) do
            Tw(b,0.1,{BackgroundColor3=k==i and C.ACC1 or C.BG4,TextColor3=k==i and C.TXT0 or C.TXT2})
        end
        if prov.model ~= "" then ModelBox.Text = prov.model end
        local isCustom = i==#PROVIDERS
        UrlLbl.Visible=isCustom;UrlBox.Parent.Visible=isCustom
        ProvHint.Text="ⓘ  "..prov.hint
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  SECTION 2 — API KEY
-- ═══════════════════════════════════════════════════════════════════════════
local S2 = Section("API Key","🔑",2)
local ApiBox,ApiWrap,_ = InputBox(S2,"Paste your API key here...",38,2)
ApiBox.TextTransparency=0.5

local keyRow2=MkFrame(S2,{Size=UDim2.new(1,0,0,24),LayoutOrder=3})
local kr2=Instance.new("UIListLayout",keyRow2)
kr2.FillDirection=Enum.FillDirection.Horizontal;kr2.Padding=UDim.new(0,6)
kr2.VerticalAlignment=Enum.VerticalAlignment.Center

Lbl(keyRow2,{Text="Key is stored locally and never sent anywhere else",
    Size=UDim2.new(1,-80,1,0),Font=Enum.Font.Gotham,TextColor3=C.TXT2,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})

local showKey=false
local ShowBtn=Btn(keyRow2,{
    Size=UDim2.new(0,74,1,0),BackgroundColor3=C.BG4,TextColor3=C.TXT1,
    Text="👁  Show",Font=Enum.Font.GothamBold,ZIndex=13
});Corner(ShowBtn,6)
ShowBtn.MouseButton1Click:Connect(function()
    showKey=not showKey
    ApiBox.TextTransparency=showKey and 0 or 0.5
    ShowBtn.Text=showKey and "🙈 Hide" or "👁  Show"
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  SECTION 3 — DESCRIPTION
-- ═══════════════════════════════════════════════════════════════════════════
local S3 = Section("Avatar Description","👾",3)
local DescBox,_,_ = InputBox(S3,"e.g. noob with bacon hair, free shirt, no accessories...",72,2,true)
local charLbl=Lbl(S3,{Text="0 / 200",Size=UDim2.new(1,0,0,14),Font=Enum.Font.Gotham,
    TextColor3=C.TXT2,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=13,LayoutOrder=3})
DescBox:GetPropertyChangedSignal("Text"):Connect(function()
    local n=math.min(#DescBox.Text,200)
    charLbl.Text=n.." / 200"
    charLbl.TextColor3=n>180 and C.YELLOW or C.TXT2
    if #DescBox.Text>200 then DescBox.Text=DescBox.Text:sub(1,200) end
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  SECTION 4 — SETTINGS
-- ═══════════════════════════════════════════════════════════════════════════
local S4 = Section("Rap Settings","⚙",4)
Lbl(S4,{Text="Lines to generate",Size=UDim2.new(1,0,0,16),Font=Enum.Font.GothamBold,
    TextColor3=C.TXT1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,LayoutOrder=2})
local _,getLinesVal = ChipRow(S4,{4,6,8,10,12,16},8,3)

-- ═══════════════════════════════════════════════════════════════════════════
--  GENERATE BUTTON
-- ═══════════════════════════════════════════════════════════════════════════
local GenBtn=Btn(Body,{
    Size=UDim2.new(1,0,0,50),BackgroundColor3=C.ACC1,TextColor3=C.TXT0,
    Text="⚡   GENERATE BARS",Font=Enum.Font.GothamBold,LayoutOrder=5,ZIndex=13
});Corner(GenBtn,11);Grad(GenBtn,C.ACC3,C.ACC2,45)
HoverBtn(GenBtn,C.ACC1,Color3.fromRGB(155,90,255))

-- Status bar
local StatWrap=Instance.new("Frame")
StatWrap.Size=UDim2.new(1,0,0,32);StatWrap.BackgroundColor3=C.BG2
StatWrap.BorderSizePixel=0;StatWrap.LayoutOrder=6;StatWrap.Parent=Body
Corner(StatWrap,8);Stroke(StatWrap,C.BORDER,1)
local StatLbl=Lbl(StatWrap,{
    Text="⚡  Choose a provider, paste your key, describe the opponent",
    Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,0),
    Font=Enum.Font.Gotham,TextColor3=C.TXT2,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13
})

-- Progress bar
local ProgWrap=MkFrame(Body,{Size=UDim2.new(1,0,0,6),LayoutOrder=7,BackgroundTransparency=1})
local ProgTrack=Instance.new("Frame",ProgWrap)
ProgTrack.Size=UDim2.new(1,0,1,0);ProgTrack.BackgroundColor3=C.BORDER
ProgTrack.BorderSizePixel=0;Corner(ProgTrack,3)
local ProgFill=Instance.new("Frame",ProgTrack)
ProgFill.Size=UDim2.new(0,0,1,0);ProgFill.BackgroundColor3=C.ACC1
ProgFill.BorderSizePixel=0;Corner(ProgFill,3);Grad(ProgFill,C.ACC3,C.ACC2,0)
ProgWrap.Visible=false

-- ═══════════════════════════════════════════════════════════════════════════
--  BARS OUTPUT SECTION (shown after generation)
-- ═══════════════════════════════════════════════════════════════════════════
local BarsSection=Instance.new("Frame")
BarsSection.Size=UDim2.new(1,0,0,0);BarsSection.AutomaticSize=Enum.AutomaticSize.Y
BarsSection.BackgroundColor3=C.BG2;BarsSection.BorderSizePixel=0
BarsSection.LayoutOrder=8;BarsSection.Visible=false;BarsSection.Parent=Body
Corner(BarsSection,10);Stroke(BarsSection,Color3.fromRGB(58,228,138),1)

local BarsSL=Instance.new("UIListLayout",BarsSection);BarsSL.Padding=UDim.new(0,6)
local BarsSP=Instance.new("UIPadding",BarsSection)
BarsSP.PaddingLeft=UDim.new(0,10);BarsSP.PaddingRight=UDim.new(0,10)
BarsSP.PaddingTop=UDim.new(0,10);BarsSP.PaddingBottom=UDim.new(0,10)

-- Header row of bars section
local barsHdrRow=MkFrame(BarsSection,{Size=UDim2.new(1,0,0,24),LayoutOrder=0})
local barsHdrL=Instance.new("UIListLayout",barsHdrRow)
barsHdrL.FillDirection=Enum.FillDirection.Horizontal
barsHdrL.HorizontalAlignment=Enum.HorizontalAlignment.Left
barsHdrL.VerticalAlignment=Enum.VerticalAlignment.Center
barsHdrL.Padding=UDim.new(0,8)

Lbl(barsHdrRow,{Text="🎤  Your Bars — Copy each line below",
    Size=UDim2.new(1,-110,1,0),Font=Enum.Font.GothamBold,
    TextColor3=C.GREEN,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})

-- Copy All button
local CopyAllBtn=Btn(barsHdrRow,{
    Size=UDim2.new(0,100,1,0),BackgroundColor3=C.BG4,TextColor3=C.GREEN,
    Text="📋 Copy All",Font=Enum.Font.GothamBold,ZIndex=13
});Corner(CopyAllBtn,6);Stroke(CopyAllBtn,C.GREEN,1)
HoverBtn(CopyAllBtn,C.BG4,Color3.fromRGB(30,60,40))

local BarsDivider=Instance.new("Frame",BarsSection)
BarsDivider.Size=UDim2.new(1,0,0,1);BarsDivider.BackgroundColor3=C.BORDER
BarsDivider.BorderSizePixel=0;BarsDivider.LayoutOrder=1

-- Container for individual bar rows
local BarsContainer=Instance.new("Frame",BarsSection)
BarsContainer.Size=UDim2.new(1,0,0,0);BarsContainer.AutomaticSize=Enum.AutomaticSize.Y
BarsContainer.BackgroundTransparency=1;BarsContainer.BorderSizePixel=0;BarsContainer.LayoutOrder=2
local BCL=Instance.new("UIListLayout",BarsContainer);BCL.Padding=UDim.new(0,5)

-- Instruction text
Lbl(BarsSection,{
    Text="Tap/click each line to copy it  •  Use in your rap battle!",
    Size=UDim2.new(1,0,0,16),Font=Enum.Font.Gotham,
    TextColor3=C.TXT2,ZIndex=13,LayoutOrder=3
})

-- ─── COPY HELPER ─────────────────────────────────────────────────────────────
-- Roblox doesn't expose clipboard directly; we use the input box trick
local CopyBox = Instance.new("TextBox")
CopyBox.Size=UDim2.new(0,0,0,0);CopyBox.Position=UDim2.new(2,0,2,0)
CopyBox.BackgroundTransparency=1;CopyBox.TextTransparency=1
CopyBox.Text="";CopyBox.ZIndex=1;CopyBox.Parent=SGui

local function CopyText(text)
    CopyBox.Text=text
    CopyBox:CaptureFocus()
    CopyBox:ReleaseFocus(false)
end

-- ─── BUILD BAR ROWS ──────────────────────────────────────────────────────────
local generatedLines = {}

local function BuildBars(lines)
    generatedLines = lines
    -- clear old
    for _,c in ipairs(BarsContainer:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end

    for i, line in ipairs(lines) do
        local row=Btn(BarsContainer,{
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=i%2==0 and C.BG3 or C.BG2,
            TextColor3=C.TXT0,Text="",ZIndex=13,LayoutOrder=i
        });Corner(row,7)

        local rowL=Instance.new("UIListLayout",row)
        rowL.FillDirection=Enum.FillDirection.Horizontal
        rowL.VerticalAlignment=Enum.VerticalAlignment.Center
        rowL.Padding=UDim.new(0,6)
        local rowP=Instance.new("UIPadding",row)
        rowP.PaddingLeft=UDim.new(0,8);rowP.PaddingRight=UDim.new(0,8)
        rowP.PaddingTop=UDim.new(0,6);rowP.PaddingBottom=UDim.new(0,6)

        -- Line number badge
        local numBadge=Instance.new("Frame")
        numBadge.Size=UDim2.new(0,22,0,22);numBadge.BackgroundColor3=C.ACC1
        numBadge.BorderSizePixel=0;numBadge.ZIndex=14;numBadge.Parent=row
        Corner(numBadge,5)
        Lbl(numBadge,{Text=tostring(i),Size=UDim2.new(1,0,1,0),
            Font=Enum.Font.GothamBold,TextColor3=C.TXT0,ZIndex=15})

        -- Line text
        local lineTxt=Lbl(row,{
            Text=line,Size=UDim2.new(1,-76,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            Font=Enum.Font.Gotham,TextColor3=C.TXT0,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true,TextScaled=false,TextSize=13,ZIndex=14
        })

        -- Copy icon button
        local cpyBtn=Btn(row,{
            Size=UDim2.new(0,38,0,26),BackgroundColor3=C.BG4,
            TextColor3=C.ACC2,Text="📋",Font=Enum.Font.GothamBold,
            TextScaled=true,ZIndex=14
        });Corner(cpyBtn,6);Stroke(cpyBtn,C.BORDER2,1)

        -- Hover entire row
        row.MouseEnter:Connect(function() Tw(row,0.1,{BackgroundColor3=C.BG4}) end)
        row.MouseLeave:Connect(function()
            Tw(row,0.1,{BackgroundColor3=i%2==0 and C.BG3 or C.BG2})
        end)

        -- Click row or copy button
        local function doCopy()
            CopyText(line)
            local orig=cpyBtn.TextColor3
            cpyBtn.Text="✅";Tw(cpyBtn,0.1,{TextColor3=C.GREEN})
            task.delay(1.2,function()
                cpyBtn.Text="📋";Tw(cpyBtn,0.1,{TextColor3=C.ACC2})
            end)
        end
        row.MouseButton1Click:Connect(doCopy)
        cpyBtn.MouseButton1Click:Connect(doCopy)
    end

    -- Copy all logic
    CopyAllBtn.MouseButton1Click:Connect(function()
        CopyText(table.concat(lines,"\n"))
        local o=CopyAllBtn.Text
        CopyAllBtn.Text="✅ Copied!";Tw(CopyAllBtn,0.1,{BackgroundColor3=C.GREEN,TextColor3=C.BG0})
        task.delay(1.5,function()
            CopyAllBtn.Text=o;Tw(CopyAllBtn,0.15,{BackgroundColor3=C.BG4,TextColor3=C.GREEN})
        end)
    end)

    BarsSection.Visible=true
    -- Scroll to bars
    task.delay(0.1,function()
        Body.CanvasPosition=Vector2.new(0, Body.AbsoluteCanvasSize.Y)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  GENERATE LOGIC
-- ═══════════════════════════════════════════════════════════════════════════
local busy=false
local function setStatus(txt,col)
    StatLbl.Text=txt;StatLbl.TextColor3=col or C.TXT2
end

GenBtn.MouseButton1Click:Connect(function()
    if busy then return end

    local prov    = PROVIDERS[selProvider]
    local key     = ApiBox.Text
    local desc    = DescBox.Text
    local model   = ModelBox.Text
    local url     = selProvider==#PROVIDERS and UrlBox.Text or prov.url
    local nLines  = getLinesVal()

    if not key or #key<4 then
        setStatus("⚠  Paste your API key first!",C.YELLOW)
        Tw(ApiWrap,0.07,{BackgroundColor3=Color3.fromRGB(55,28,8)})
        task.delay(0.5,function() Tw(ApiWrap,0.3,{BackgroundColor3=C.BG0}) end);return
    end
    if not desc or #desc<3 then
        setStatus("⚠  Describe the opponent's avatar first!",C.YELLOW);return
    end
    if selProvider==#PROVIDERS and (#url<10) then
        setStatus("⚠  Enter your custom API endpoint URL!",C.YELLOW);return
    end
    if not model or #model<2 then
        setStatus("⚠  Enter a model name!",C.YELLOW);return
    end

    busy=true
    BarsSection.Visible=false
    ProgWrap.Visible=true
    Tw(ProgFill,0.6,{Size=UDim2.new(0.3,0,1,0)})
    GenBtn.Text="⏳  Generating bars..."
    Tw(GenBtn,0.1,{BackgroundColor3=C.BG3})
    setStatus("🤖  AI is writing your bars...",C.BLUE)

    GenerateRap(url, key, model, desc, nLines, function(lines, err)
        ProgWrap.Visible=false
        ProgFill.Size=UDim2.new(0,0,1,0)
        GenBtn.Text="⚡   GENERATE BARS"
        Tw(GenBtn,0.1,{BackgroundColor3=C.ACC1})
        busy=false

        if err or not lines then
            setStatus("❌  "..( err or "Unknown error"),C.RED)
            return
        end

        setStatus("✅  "..#lines.." bars generated — click any line to copy!",C.GREEN)
        BuildBars(lines)
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  DRAGGING
-- ═══════════════════════════════════════════════════════════════════════════
local drag,dragInp,dragStart,startPos
Header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true;dragStart=i.Position;startPos=Win.Position
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
        local d=i.Position-dragStart
        Win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                               startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  OPEN ANIMATION
-- ═══════════════════════════════════════════════════════════════════════════
Win.Size=UDim2.new(0,WIN_W,0,0);Win.BackgroundTransparency=1
Backdrop.BackgroundTransparency=1
Tw(Backdrop,0.25,{BackgroundTransparency=0.55})
TweenService:Create(Win,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0}):Play()

-- Breathing top line pulse
task.spawn(function()
    while SGui and SGui.Parent do
        Tw(TopLine,2,{BackgroundTransparency=0.4},Enum.EasingStyle.Sine)
        task.wait(2)
        Tw(TopLine,2,{BackgroundTransparency=0},Enum.EasingStyle.Sine)
        task.wait(2)
    end
end)

print("[FlowForge v3] Ready — Free APIs, Copy & Paste Mode 🎤")
