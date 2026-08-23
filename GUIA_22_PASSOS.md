# 🎯 GUIA DEFINITIVO — 22 SCRIPTS PASSO A PASSO
## Siga a ordem abaixo. Cada passo tem: LOCAL → TIPO → CÓDIGO

---

# 📦 REPLICATEDSTORAGE (6 itens)

---

## 🔴 PASSO 1 de 22 — ConfigModule

**Local:** `ReplicatedStorage` → **Criar:** `ModuleScript` → **Renomear:** `ConfigModule`

```lua
local Config = {
    PRODUCTS = {
        COINS_100 = { id = 3708120760, coins = 100, robux = 5 },
        COINS_500 = { id = 3708120761, coins = 500, robux = 25 },
        COINS_2000 = { id = 3708120762, coins = 2000, robux = 100 },
        COINS_10000 = { id = 3708120763, coins = 10000, robux = 500 },
        VIP_MENSAL = { id = 3708120770, robux = 50 },
        RADAR = { id = 3708120780, robux = 50 },
        MOTO = { id = 3708120781, robux = 75 },
        PET = { id = 3708120782, robux = 100 },
        HOLO = { id = 3708120783, robux = 150 },
    },
    REWARDS = { WELCOME_BONUS = 100, VOTE_REWARD = 25, DAILY_LOGIN = 50 },
    SONEY_API_URL = "https://soney-backend.onrender.com",
    API_TIMEOUT = 5,
    MAX_COINS = 999999,
    DAILY_COIN_LIMIT = 2000,
    SEASON = { current = 1, name = "O Último Andar", episodes = 15 }
}
return Config
```

---

## 🔴 PASSO 2 de 22 — SoneyAPIBridge

**Local:** `ReplicatedStorage` → **Criar:** `ModuleScript` → **Renomear:** `SoneyAPIBridge`

```lua
local HttpService = game:GetService("HttpService")
local Config = require(script.Parent:WaitForChild("ConfigModule"))
local SoneyAPI = {}

function SoneyAPI.syncPlayer(player, amount, reason)
    local data = { userId = player.UserId, userName = player.Name, coinsEarned = amount, reason = reason }
    local s, r = pcall(function()
        return HttpService:PostAsync(Config.SONEY_API_URL .. "/sync", HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson, false, Config.API_TIMEOUT)
    end)
    if s then return true, HttpService:JSONDecode(r) end
    return false, nil
end

function SoneyAPI.getLatestEpisode()
    local s, r = pcall(function()
        return HttpService:GetAsync(Config.SONEY_API_URL .. "/episode/latest", false, Config.API_TIMEOUT)
    end)
    if s then return true, HttpService:JSONDecode(r) end
    return false, nil
end

function SoneyAPI.submitVote(player, episodeId, choice)
    local data = { userId = player.UserId, userName = player.Name, episodeId = episodeId, choice = choice }
    local s, r = pcall(function()
        return HttpService:PostAsync(Config.SONEY_API_URL .. "/vote", HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson, false, Config.API_TIMEOUT)
    end)
    if s then return true, HttpService:JSONDecode(r) end
    return false, nil
end
return SoneyAPI
```

---

## 🔴 PASSO 3 de 22 — EpisodeService

**Local:** `ReplicatedStorage` → **Criar:** `ModuleScript` → **Renomear:** `EpisodeService`

```lua
local SoneyAPI = require(script.Parent:WaitForChild("SoneyAPIBridge"))
local EpisodeService = {}
local currentEpisode = nil; local lastFetch = 0; local CACHE = 30

function EpisodeService.getCurrentEpisode()
    if currentEpisode and (os.time() - lastFetch) < CACHE then return true, currentEpisode end
    local s, d = SoneyAPI.getLatestEpisode()
    if s and d then currentEpisode = d.episode or d; lastFetch = os.time(); return true, currentEpisode end
    return false, { id = "ep-1", number = 1, title = "O Primeiro Episódio", hook = "O segredo que mudou tudo...", choices = {{id="A",text="Revelar a verdade"},{id="B",text="Guardar o segredo"}} }
end

function EpisodeService.submitVote(player, choice)
    if not currentEpisode then local _, e = EpisodeService.getCurrentEpisode(); currentEpisode = e end
    local s, r = SoneyAPI.submitVote(player, currentEpisode.id or 1, choice)
    if s then lastFetch = 0; return true, r end
    return false, nil
end
function EpisodeService.clearCache() currentEpisode = nil; lastFetch = 0 end
return EpisodeService
```

---

## 🔴 PASSO 4 de 22 — SoneyNotifyEvent

**Local:** `ReplicatedStorage` → **Criar:** `RemoteEvent` → **Renomear:** `SoneyNotifyEvent`

*Apenas criar o RemoteEvent, não colar código*

---

## 🔴 PASSO 5 de 22 — BCEvent

**Local:** `ReplicatedStorage` → **Criar:** `RemoteEvent` → **Renomear:** `BCEvent`

*Apenas criar o RemoteEvent, não colar código*

---

## 🔴 PASSO 6 de 22 — ToolEvent

**Local:** `ReplicatedStorage` → **Criar:** `RemoteEvent` → **Renomear:** `ToolEvent`

*Apenas criar o RemoteEvent, não colar código*

---

# 📦 SERVERScriptService (8 scripts)

---

## 🟢 PASSO 7 de 22 — LeaderstatsSystem

**Local:** `ServerScriptService` → **Criar:** `Script` → **Renomear:** `LeaderstatsSystem`

```lua
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage:WaitForChild("ConfigModule"))
local SoneyAPI = require(ReplicatedStorage:WaitForChild("SoneyAPIBridge"))
local processedReceipts = {}; local dailyCoins = {}

local function setup(player)
    local ls = Instance.new("Folder"); ls.Name = "leaderstats"; ls.Parent = player
    local c = Instance.new("IntValue"); c.Name = "Coins"; c.Value = Config.REWARDS.WELCOME_BONUS; c.Parent = ls
    local ev = Instance.new("IntValue"); ev.Name = "EpisodesWatched"; ev.Value = 0; ev.Parent = ls
    local vc = Instance.new("IntValue"); vc.Name = "VotesCast"; vc.Value = 0; vc.Parent = ls
    print("🎬 " .. player.Name .. " entrou com " .. Config.REWARDS.WELCOME_BONUS .. " coins")
end

local function awardCoins(player, amount, reason)
    local ls = player:FindFirstChild("leaderstats"); if not ls then return false end
    local c = ls:FindFirstChild("Coins"); if not c then return false end
    local today = os.date("%Y-%m-%d")
    if not dailyCoins[player.UserId] then dailyCoins[player.UserId] = {} end
    if not dailyCoins[player.UserId][today] then dailyCoins[player.UserId][today] = 0 end
    if dailyCoins[player.UserId][today] + amount > Config.DAILY_COIN_LIMIT then return false end
    c.Value = math.min(c.Value + amount, Config.MAX_COINS)
    dailyCoins[player.UserId][today] = dailyCoins[player.UserId][today] + amount
    task.spawn(function() SoneyAPI.syncPlayer(player, amount, reason) end)
    return true
end
_G.SoneyAwardCoins = awardCoins; _G.SoneyProcessedReceipts = processedReceipts
Players.PlayerAdded:Connect(setup)
print("✅ LeaderstatsSystem")
```

---

## 🟢 PASSO 8 de 22 — NexusEconomy

**Local:** `ServerScriptService` → **Criar:** `Script` → **Renomear:** `NexusEconomy`

```lua
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bcStore = DataStoreService:GetDataStore("BioCreditosData")
local bcEvent = ReplicatedStorage:WaitForChild("BCEvent")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
local playerData = {}

local function loadPlayer(player)
    local uid = tostring(player.UserId)
    local s, d = pcall(function() return bcStore:GetAsync(uid) end)
    if s and d then playerData[uid] = d
    else playerData[uid] = { bc = 100, nivel = 1, ferramenta = "Pá Oxidada", reliquias = 0, lastDaily = "", titulo = "Forasteiro" } end
    local ls = Instance.new("Folder"); ls.Name = "leaderstats"; ls.Parent = player
    local bc = Instance.new("IntValue"); bc.Name = "BioCreditos"; bc.Value = playerData[uid].bc; bc.Parent = ls
    local nv = Instance.new("IntValue"); nv.Name = "Nivel"; nv.Value = playerData[uid].nivel; nv.Parent = ls
    local ft = Instance.new("StringValue"); ft.Name = "Ferramenta"; ft.Value = playerData[uid].ferramenta; ft.Parent = ls
    print("📦 " .. player.Name .. " — " .. playerData[uid].bc .. " BC")
end

local function savePlayer(uid) if playerData[uid] then pcall(function() bcStore:SetAsync(uid, playerData[uid]) end) end end

function addBC(player, amount, reason)
    local uid = tostring(player.UserId); if not playerData[uid] then return false end
    playerData[uid].bc = playerData[uid].bc + amount
    local ls = player:FindFirstChild("leaderstats")
    if ls then local bc = ls:FindFirstChild("BioCreditos"); if bc then bc.Value = playerData[uid].bc end end
    if notifyEvent then notifyEvent:FireClient(player, {title="💰 +"..amount.." BC", message=reason or "Bio-Créditos", duration=3}) end
    return true
end

function removeBC(player, amount)
    local uid = tostring(player.UserId); if not playerData[uid] or playerData[uid].bc < amount then return false end
    playerData[uid].bc = playerData[uid].bc - amount
    local ls = player:FindFirstChild("leaderstats")
    if ls then local bc = ls:FindFirstChild("BioCreditos"); if bc then bc.Value = playerData[uid].bc end end
    return true
end

bcEvent.OnServerEvent:Connect(function(player, action, ...)
    if action == "coletarReliquia" then
        local bonus = 10 + math.random(1,5)
        addBC(player, bonus, "Relíquia coletada!")
        bcEvent:FireClient(player, "relicResult", true, bonus)
    elseif action == "dailyEasterEgg" then
        local uid = tostring(player.UserId); local today = os.date("%Y-%m-%d")
        if playerData[uid].lastDaily == today then bcEvent:FireClient(player, "dailyResult", false, "Já pegou hoje!"); return end
        playerData[uid].lastDaily = today; playerData[uid].titulo = "Explorador de São Paulo"
        addBC(player, 50, "🏛️ Easter Egg São Paulo!")
        notifyEvent:FireClient(player, {title="🏛️ EASTER EGG!", message="Título: Explorador de São Paulo! +50 BC", duration=5})
        bcEvent:FireClient(player, "dailyResult", true, "Recompensa recebida!")
    end
end)

Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(p) savePlayer(tostring(p.UserId)) end)
task.spawn(function() while true do task.wait(300); for uid in pairs(playerData) do savePlayer(uid) end; print("💾 Auto-save") end end)
_G.NexusAddBC = addBC; _G.NexusRemoveBC = removeBC; _G.NexusGetData = function(p) return playerData[tostring(p.UserId)] end
print("✅ NexusEconomy")
```

---

## 🟢 PASSO 9 de 22 — FerramentasMineracao

**Local:** `ServerScriptService` → **Criar:** `Script` → **Renomear:** `FerramentasMineracao`

```lua
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
local toolEvent = Instance.new("RemoteEvent"); toolEvent.Name = "ToolEvent"; toolEvent.Parent = ReplicatedStorage

local FERRAMENTAS = {
    {nome="Pá Oxidada", nivel=1, dano=5, bc=0},
    {nome="Martelo de Ferro", nivel=2, dano=10, bc=200},
    {nome="Picareta de Bronze", nivel=3, dano=20, bc=500},
    {nome="Furadeira de Plasma", nivel=4, dano=40, bc=1500},
    {nome="Lança-Chamas Iônico", nivel=5, dano=80, bc=4000},
    {nome="Destruidor Quântico", nivel=6, dano=150, bc=10000},
}

function getFerramenta(player)
    local data = _G.NexusGetData and _G.NexusGetData(player)
    if not data then return FERRAMENTAS[1] end
    for _, f in ipairs(FERRAMENTAS) do if f.nome == data.ferramenta then return f end end
    return FERRAMENTAS[1]
end

toolEvent.OnServerEvent:Connect(function(player, action)
    if action == "upgrade" then
        local data = _G.NexusGetData and _G.NexusGetData(player)
        if not data then toolEvent:FireClient(player, "upgradeResult", false, "Erro"); return end
        local atual = getFerramenta(player)
        if atual.nivel >= #FERRAMENTAS then toolEvent:FireClient(player, "upgradeResult", false, "Máximo!"); return end
        local prox = FERRAMENTAS[atual.nivel + 1]
        if data.bc < prox.bc then toolEvent:FireClient(player, "upgradeResult", false, "BC insuficiente"); return end
        _G.NexusRemoveBC(player, prox.bc); data.ferramenta = prox.nome
        local ls = player:FindFirstChild("leaderstats")
        if ls then local f = ls:FindFirstChild("Ferramenta"); if f then f.Value = prox.nome end end
        notifyEvent:FireClient(player, {title="🔧 UPGRADE!", message=prox.nome.." — Dano: "..prox.dano, duration=5})
        toolEvent:FireClient(player, "upgradeResult", true, prox.nome)
    elseif action == "getInfo" then
        toolEvent:FireClient(player, "toolInfo", getFerramenta(player))
    end
end)
_G.NexusGetFerramenta = getFerramenta
print("✅ FerramentasMineracao")
```

---

## 🟢 PASSO 10 de 22 — NexusMonetizacao

**Local:** `ServerScriptService` → **Criar:** `Script` → **Renomear:** `NexusMonetizacao`

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

local GAMEPASSES = {
    radar = {id=3708120780, name="Radar Térmico", desc="Veja inimigos no mapa"},
    moto = {id=3708120781, name="Moto de Exploração", desc="2x mais rápido"},
    pet = {id=3708120782, name="Pet Robótico", desc="Colete automático"},
    holo = {id=3708120783, name="Holo-Estande", desc="Destaque sua loja"},
}
local playerGP = {}

Players.PlayerAdded:Connect(function(p)
    local uid = tostring(p.UserId); playerGP[uid] = {}
    task.wait(3)
    for _, gp in pairs(GAMEPASSES) do
        local ok = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(p.UserId, gp.id) end)
        if ok then playerGP[uid][gp.id] = true; notifyEvent:FireClient(p, {title="🎮 "..gp.name, message=gp.desc, duration=4}) end
    end
end)

local processed = _G.SoneyProcessedReceipts or {}
local function processReceipt(r)
    if processed[r.PurchaseId] then return Enum.ProductPurchaseDecision.PurchaseGranted end
    local p = Players:GetPlayerByUserId(r.PlayerId); if not p then return Enum.ProductPurchaseDecision.NotProcessedYet end
    for _, gp in pairs(GAMEPASSES) do
        if r.ProductId == gp.id then
            local uid = tostring(p.UserId); if not playerGP[uid] then playerGP[uid] = {} end
            playerGP[uid][gp.id] = true; processed[r.PurchaseId] = true
            notifyEvent:FireClient(p, {title="🎉 "..gp.name, message=gp.desc, duration=5})
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end
    local bcPacks = {[3708120760]=100,[3708120761]=500,[3708120762]=2000,[3708120763]=10000}
    local bc = bcPacks[r.ProductId]
    if bc and _G.NexusAddBC then _G.NexusAddBC(p, bc, "Pacote BC"); processed[r.PurchaseId] = true; return Enum.ProductPurchaseDecision.PurchaseGranted end
    return Enum.ProductPurchaseDecision.NotProcessedYet
end
MarketplaceService.ProcessReceipt = processReceipt
_G.NexusHasGamepass = function(p, id) return playerGP[tostring(p.UserId)] and playerGP[tostring(p.UserId)][id] end
print("✅ NexusMonetizacao")
```

---

## 🟢 PASSO 11 de 22 — PurchaseHandler

**Local:** `ServerScriptService` → **Criar:** `Script` → **Renomear:** `PurchaseHandler`

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("ConfigModule"))
local processed = _G.SoneyProcessedReceipts or {}
local function processReceipt(r)
    if processed[r.PurchaseId] then return Enum.ProductPurchaseDecision.PurchaseGranted end
    local p = Players:GetPlayerByUserId(r.PlayerId); if not p then return Enum.ProductPurchaseDecision.NotProcessedYet end
    local products = {[3708120760]=100,[3708120761]=500,[3708120762]=2000,[3708120763]=10000}
    local coins = products[r.ProductId]
    if coins and _G.SoneyAwardCoins then _G.SoneyAwardCoins(p, coins, "purchase"); processed[r.PurchaseId] = true; return Enum.ProductPurchaseDecision.PurchaseGranted end
    return Enum.ProductPurchaseDecision.NotProcessedYet
end
MarketplaceService.ProcessReceipt = processReceipt
print("✅ PurchaseHandler")
```

---

## 🟢 PASSO 12 de 22 — VoteHandler

**Local:** `ServerScriptService` → **Criar:** `Script` → **Renomear:** `VoteHandler`

```lua
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoneyAPI = require(ReplicatedStorage:WaitForChild("SoneyAPIBridge"))
local voteEvent = Instance.new("RemoteEvent"); voteEvent.Name = "SoneyVoteEvent"; voteEvent.Parent = ReplicatedStorage
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
local playerVotes = {}; local VOTE_COOLDOWN = 60; local VOTE_REWARD = 25

local function processVote(player, episodeId, choice)
    if not player or not player.Parent then return false, "Inválido" end
    if choice ~= "A" and choice ~= "B" then return false, "Use A ou B" end
    local uid = tostring(player.UserId); local last = playerVotes[uid]
    if last and last.episodeId == episodeId then return false, "Já votou neste episódio!" end
    if last and os.time() - last.timestamp < VOTE_COOLDOWN then return false, "Aguarde "..(VOTE_COOLDOWN-(os.time()-last.timestamp)).."s" end
    playerVotes[uid] = {episodeId=episodeId, choice=choice, timestamp=os.time()}
    local ls = player:FindFirstChild("leaderstats")
    if ls then local vc = ls:FindFirstChild("VotesCast"); if vc then vc.Value = vc.Value + 1 end end
    if _G.SoneyAwardCoins then _G.SoneyAwardCoins(player, VOTE_REWARD, "vote") end
    task.spawn(function() SoneyAPI.submitVote(player, episodeId, choice) end)
    notifyEvent:FireClient(player, {title="🗳️ Voto Registrado!", message="+"..VOTE_REWARD.." Coins!", duration=4})
    return true, nil
end
voteEvent.OnServerEvent:Connect(function(p, action, ...)
    if action == "vote" then local e,c = ...; local s,m = processVote(p,e,c); voteEvent:FireClient(p,"voteResult",s,m) end
end)
print("✅ VoteHandler")
```

---

## 🟢 PASSO 13 de 22 — UINotifier

**Local:** `ServerScriptService` → **Criar:** `Script` → **Renomear:** `UINotifier`

```lua
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
function notifyPlayer(player, title, message, duration)
    if not player or not player.Parent then return end
    task.spawn(function() notifyEvent:FireClient(player, {title=title or "🎬 Soney", message=message or "", duration=duration or 4}) end)
end
Players.PlayerAdded:Connect(function(p) task.wait(2); notifyPlayer(p, "🎬 Bem-vindo!", "Você recebeu coins de boas-vindas!", 6) end)
_G.SoneyNotify = notifyPlayer
print("✅ UINotifier")
```

---

## 🟢 PASSO 14 de 22 — SoneyCutsceneHandler

**Local:** `ServerScriptService` → **Criar:** `Script` → **Renomear:** `SoneyCutsceneHandler`

```lua
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
local SONEY_LINES = {
    welcome = {
        {text="🎬 Olá! Eu sou a SONEY.", speed=0.04},
        {text="Sou a diretora de cinema digital deste universo.", speed=0.03},
        {text="Cada escolha sua muda a história.", speed=0.03},
        {text="Você não é só espectador — você é o ROTEIRISTA.", speed=0.03},
        {text="Aperte V para votar no rumo da história! 🎬🔥", speed=0.05},
    }
}
function showSoney(p, scene, custom)
    if not p or not p.Parent then return end
    local lines = custom or SONEY_LINES[scene] or SONEY_LINES.welcome
    task.wait(1); notifyEvent:FireClient(p, {title="SHOW_SONEY", lines=lines})
end
Players.PlayerAdded:Connect(function(p)
    p:WaitForChild("PlayerGui"); task.wait(2)
    if not p:FindFirstChild("SoneyFirstTime") then
        local v = Instance.new("BoolValue"); v.Name = "SoneyFirstTime"; v.Parent = p; task.wait(1); showSoney(p, "welcome")
    end
end)
_G.SoneyShowToPlayer = showSoney
print("✅ SoneyCutsceneHandler")
```

---

# 📦 STARTERGUI (4 LocalScripts)

---

## 🟠 PASSO 15 de 22 — NexusHUD

**Local:** `StarterGui` → **Criar:** `LocalScript` → **Renomear:** `NexusHUD`

```lua
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local sg = Instance.new("ScreenGui"); sg.Name = "NexusHUD"; sg.ResetOnSpawn = false; sg.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame"); panel.Size = UDim2.new(0,200,0,50); panel.Position = UDim2.new(1,-220,0,10)
panel.BackgroundColor3 = Color3.fromRGB(5,5,20); panel.BackgroundTransparency = 0.2; panel.BorderSizePixel = 0; panel.Parent = sg
local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,10); c.Parent = panel
local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(0,200,255); s.Thickness = 1.5; s.Transparency = 0.5; s.Parent = panel

local icon = Instance.new("TextLabel"); icon.Size = UDim2.new(0,30,0,30); icon.Position = UDim2.new(0,10,0,10)
icon.BackgroundTransparency = 1; icon.Text = "💎"; icon.TextSize = 20; icon.Parent = panel

local label = Instance.new("TextLabel"); label.Size = UDim2.new(0,100,0,15); label.Position = UDim2.new(0,45,0,5)
label.BackgroundTransparency = 1; label.Text = "BIO-CRÉDITOS"; label.TextColor3 = Color3.fromRGB(0,200,255); label.TextSize = 10; label.Font = Enum.Font.GothamBold; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = panel

local valor = Instance.new("TextLabel"); valor.Name = "BCValue"; valor.Size = UDim2.new(0,100,0,20); valor.Position = UDim2.new(0,45,0,20)
valor.BackgroundTransparency = 1; valor.Text = "0"; valor.TextColor3 = Color3.fromRGB(255,255,255); valor.TextSize = 16; valor.Font = Enum.Font.GothamBold; valor.TextXAlignment = Enum.TextXAlignment.Left; valor.Parent = panel

local function update()
    local ls = player:FindFirstChild("leaderstats")
    if ls then local bc = ls:FindFirstChild("BioCreditos"); if bc then valor.Text = tostring(bc.Value)
        bc.Changed:Connect(function() valor.Text = tostring(bc.Value) end) end end
end
player:WaitForChild("leaderstats"); update()
print("✅ NexusHUD")
```

---

## 🟠 PASSO 16 de 22 — SoneyClientUI

**Local:** `StarterGui` → **Criar:** `LocalScript` → **Renomear:** `SoneyClientUI`

```lua
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService"); local player = Players.LocalPlayer
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
local sg = Instance.new("ScreenGui"); sg.Name = "SoneyNotificationGui"; sg.ResetOnSpawn = false; sg.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame"); frame.Size = UDim2.new(0,350,0,80); frame.Position = UDim2.new(0.5,-175,0,-100)
frame.BackgroundColor3 = Color3.fromRGB(10,10,25); frame.BackgroundTransparency = 0.15; frame.BorderSizePixel = 0; frame.Parent = sg
local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,12); c.Parent = frame
local title = Instance.new("TextLabel"); title.Size = UDim2.new(1,-20,0,25); title.Position = UDim2.new(0,10,0,8)
title.BackgroundTransparency = 1; title.TextColor3 = Color3.fromRGB(255,50,100); title.Font = Enum.Font.GothamBold; title.TextSize = 16; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = frame
local msg = Instance.new("TextLabel"); msg.Size = UDim2.new(1,-20,0,40); msg.Position = UDim2.new(0,10,0,35)
msg.BackgroundTransparency = 1; msg.TextColor3 = Color3.fromRGB(255,255,255); msg.TextSize = 14; msg.Font = Enum.Font.Gotham; msg.TextWrapped = true; msg.TextXAlignment = Enum.TextXAlignment.Left; msg.Parent = frame

function showNotification(t, m, d)
    title.Text = t; msg.Text = m; frame.Position = UDim2.new(0.5,-175,0,-100); frame.BackgroundTransparency = 0.15
    local e = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position=UDim2.new(0.5,-175,0,30), BackgroundTransparency=0.05}); e:Play()
    task.wait(d or 4)
    local x = TweenService:Create(frame, TweenInfo.new(0.3), {Position=UDim2.new(0.5,-175,0,-100), BackgroundTransparency=0.15}); x:Play()
end
notifyEvent.OnClientEvent:Connect(function(d) showNotification(d.title, d.message, d.duration) end)
print("✅ SoneyClientUI")
```

---

## 🟠 PASSO 17 de 22 — VoteUI

**Local:** `StarterGui` → **Criar:** `LocalScript` → **Renomear:** `VoteUI`

```lua
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService"); local UIS = game:GetService("UserInputService"); local player = Players.LocalPlayer
local EpisodeService = require(ReplicatedStorage:WaitForChild("EpisodeService"))
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
local sg = Instance.new("ScreenGui"); sg.Name = "SoneyVoteGui"; sg.ResetOnSpawn = false; sg.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("ImageButton"); btn.Size = UDim2.new(0,60,0,60); btn.Position = UDim2.new(0.5,-30,1,-90)
btn.BackgroundColor3 = Color3.fromRGB(255,50,100); btn.BackgroundTransparency = 0.1; btn.BorderSizePixel = 0; btn.Parent = sg
local btnc = Instance.new("UICorner"); btnc.CornerRadius = UDim.new(0,30); btnc.Parent = btn
local btnl = Instance.new("TextLabel"); btnl.Size = UDim2.new(1,0,1,0); btnl.BackgroundTransparency = 1; btnl.Text = "🎬"; btnl.TextSize = 28; btnl.Font = Enum.Font.GothamBold; btnl.Parent = btn

local overlay = Instance.new("Frame"); overlay.Size = UDim2.new(1,0,1,0); overlay.BackgroundColor3 = Color3.fromRGB(0,0,0); overlay.BackgroundTransparency = 0.5; overlay.BorderSizePixel = 0; overlay.Visible = false; overlay.Parent = sg
local main = Instance.new("Frame"); main.Size = UDim2.new(0,400,0,460); main.Position = UDim2.new(0.5,-200,0.5,-230)
main.BackgroundColor3 = Color3.fromRGB(10,10,25); main.BackgroundTransparency = 0.08; main.BorderSizePixel = 0; main.Visible = false; main.Parent = sg
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0,16); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(255,50,100); ms.Thickness = 1.5; ms.Transparency = 0.6; ms.Parent = main

local h = Instance.new("TextLabel"); h.Size = UDim2.new(1,-30,0,25); h.Position = UDim2.new(0,15,0,15)
h.BackgroundTransparency = 1; h.Text = "🎭 VOTE NO DRAMA"; h.TextColor3 = Color3.fromRGB(255,50,100); h.TextSize = 18; h.Font = Enum.Font.GothamBold; h.Parent = main
local hs = Instance.new("TextLabel"); hs.Size = UDim2.new(1,-30,0,20); hs.Position = UDim2.new(0,15,0,40)
hs.BackgroundTransparency = 1; hs.Text = "Decida o rumo da história!"; hs.TextColor3 = Color3.fromRGB(200,200,220); hs.TextSize = 13; hs.Font = Enum.Font.Gotham; hs.Parent = main
local close = Instance.new("TextButton"); close.Size = UDim2.new(0,30,0,30); close.Position = UDim2.new(1,-40,0,12)
close.BackgroundColor3 = Color3.fromRGB(255,50,100); close.BackgroundTransparency = 0.5; close.BorderSizePixel = 0; close.Text = "✕"; close.TextColor3 = Color3.fromRGB(255,255,255); close.TextSize = 16; close.Font = Enum.Font.GothamBold; close.Parent = main
local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,8); cc.Parent = close

local epTitle = Instance.new("TextLabel"); epTitle.Size = UDim2.new(1,-30,0,30); epTitle.Position = UDim2.new(0,15,0,70)
epTitle.BackgroundTransparency = 1; epTitle.Text = "Carregando..."; epTitle.TextColor3 = Color3.fromRGB(255,255,255); epTitle.TextSize = 20; epTitle.Font = Enum.Font.GothamBold; epTitle.TextXAlignment = Enum.TextXAlignment.Left; epTitle.Parent = main
local epHook = Instance.new("TextLabel"); epHook.Size = UDim2.new(1,-30,0,60); epHook.Position = UDim2.new(0,15,0,105)
epHook.BackgroundTransparency = 1; epHook.Text = ""; epHook.TextColor3 = Color3.fromRGB(200,200,220); epHook.TextSize = 15; epHook.Font = Enum.Font.Gotham; epHook.TextWrapped = true; epHook.TextXAlignment = Enum.TextXAlignment.Left; epHook.TextYAlignment = Enum.TextYAlignment.Top; epHook.Parent = main

local choiceA = Instance.new("TextButton"); choiceA.Size = UDim2.new(1,-30,0,65); choiceA.Position = UDim2.new(0,15,0,175)
choiceA.BackgroundColor3 = Color3.fromRGB(255,50,100); choiceA.BackgroundTransparency = 0.2; choiceA.BorderSizePixel = 0; choiceA.Text = ""; choiceA.Parent = main
local aCorner = Instance.new("UICorner"); aCorner.CornerRadius = UDim.new(0,12); aCorner.Parent = choiceA
local aLabel = Instance.new("TextLabel"); aLabel.Size = UDim2.new(1,-20,1,0); aLabel.Position = UDim2.new(0,15,0,0)
aLabel.BackgroundTransparency = 1; aLabel.Text = "A) Opção A"; aLabel.TextColor3 = Color3.fromRGB(255,255,255); aLabel.TextSize = 16; aLabel.Font = Enum.Font.GothamBold; aLabel.TextXAlignment = Enum.TextXAlignment.Left; aLabel.TextWrapped = true; aLabel.Parent = choiceA

local choiceB = Instance.new("TextButton"); choiceB.Size = UDim2.new(1,-30,0,65); choiceB.Position = UDim2.new(0,15,0,255)
choiceB.BackgroundColor3 = Color3.fromRGB(50,100,255); choiceB.BackgroundTransparency = 0.2; choiceB.BorderSizePixel = 0; choiceB.Text = ""; choiceB.Parent = main
local bCorner = Instance.new("UICorner"); bCorner.CornerRadius = UDim.new(0,12); bCorner.Parent = choiceB
local bLabel = Instance.new("TextLabel"); bLabel.Size = UDim2.new(1,-20,1,0); bLabel.Position = UDim2.new(0,15,0,0)
bLabel.BackgroundTransparency = 1; bLabel.Text = "B) Opção B"; bLabel.TextColor3 = Color3.fromRGB(255,255,255); bLabel.TextSize = 16; bLabel.Font = Enum.Font.GothamBold; bLabel.TextXAlignment = Enum.TextXAlignment.Left; bLabel.TextWrapped = true; bLabel.Parent = choiceB

local loading = Instance.new("TextLabel"); loading.Size = UDim2.new(1,-30,0,30); loading.Position = UDim2.new(0,15,0,340)
loading.BackgroundTransparency = 1; loading.Text = "⏳ Carregando..."; loading.TextColor3 = Color3.fromRGB(200,200,200); loading.TextSize = 14; loading.Font = Enum.Font.Gotham; loading.Visible = false; loading.Parent = main

local hasVoted = false; local currentEpisode = nil
function loadEpisode()
    loading.Visible = true; loading.Text = "⏳ Carregando..."; choiceA.Visible = false; choiceB.Visible = false
    task.spawn(function()
        local s, ep = EpisodeService.getCurrentEpisode()
        loading.Visible = false
        if ep then
            currentEpisode = ep; epTitle.Text = "📺 "..(ep.title or "Episódio"); epHook.Text = '"'..(ep.hook or "")..'"'
            local choices = ep.choices or {{id="A",text="Sim"},{id="B",text="Não"}}
            choiceA.Visible = true; aLabel.Text = "A) "..choices[1].text; choiceA.UserData = choices[1].id
            choiceB.Visible = true; bLabel.Text = "B) "..choices[2].text; choiceB.UserData = choices[2].id
        end
    end)
end
function castVote(choice)
    if hasVoted then return end; hasVoted = true; loading.Visible = true; loading.Text = "⏳ Enviando..."; choiceA.Visible = false; choiceB.Visible = false
    task.spawn(function()
        local s, r = EpisodeService.submitVote(player, choice)
        loading.Visible = false; choiceA.Visible = true; choiceB.Visible = true
        choiceA.BackgroundColor3 = Color3.fromRGB(60,60,80); choiceB.BackgroundColor3 = Color3.fromRGB(60,60,80)
        if choice == "A" then choiceA.BackgroundColor3 = Color3.fromRGB(255,80,130) else choiceB.BackgroundColor3 = Color3.fromRGB(80,130,255) end
        epHook.Text = "🗳️ Voto registrado! Obrigado!"
    end)
end
btn.MouseButton1Click:Connect(function()
    if main.Visible then main.Visible = false; overlay.Visible = false else overlay.Visible = true; main.Visible = true; loadEpisode() end
end)
close.MouseButton1Click:Connect(function() main.Visible = false; overlay.Visible = false end)
overlay.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then main.Visible = false; overlay.Visible = false end end)
choiceA.MouseButton1Click:Connect(function() if not hasVoted then castVote(choiceA.UserData) end end)
choiceB.MouseButton1Click:Connect(function() if not hasVoted then castVote(choiceB.UserData) end end)
UIS.InputBegan:Connect(function(i, gp) if gp then return end; if i.KeyCode == Enum.KeyCode.V then
    if main.Visible then main.Visible = false; overlay.Visible = false else overlay.Visible = true; main.Visible = true; loadEpisode() end end end)
_G.SoneyOpenVote = function() overlay.Visible = true; main.Visible = true; loadEpisode() end
print("✅ VoteUI — Pressione V para votar")
```

---

## 🟠 PASSO 18 de 22 — SoneyShowroom

**Local:** `StarterGui` → **Criar:** `LocalScript` → **Renomear:** `SoneyShowroom`

```lua
local Players = game:GetService("Players"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService"); local player = Players.LocalPlayer
local sg = Instance.new("ScreenGui"); sg.Name = "SoneyShowroomGui"; sg.ResetOnSpawn = false; sg.Parent = player:WaitForChild("PlayerGui")

local overlay = Instance.new("Frame"); overlay.Size = UDim2.new(1,0,1,0); overlay.BackgroundColor3 = Color3.fromRGB(0,0,0); overlay.BackgroundTransparency = 0.3; overlay.BorderSizePixel = 0; overlay.Visible = false; overlay.Parent = sg
local main = Instance.new("Frame"); main.Size = UDim2.new(0,500,0,360); main.Position = UDim2.new(0.5,-250,0.5,-180)
main.BackgroundColor3 = Color3.fromRGB(5,5,20); main.BackgroundTransparency = 0.1; main.BorderSizePixel = 0; main.Visible = false; main.ClipsDescendants = true; main.Parent = sg
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0,20); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(255,50,100); ms.Thickness = 2; ms.Transparency = 0.4; ms.Parent = main

local icon = Instance.new("Frame"); icon.Size = UDim2.new(0,70,0,70); icon.Position = UDim2.new(0,25,0,20)
icon.BackgroundColor3 = Color3.fromRGB(255,50,100); icon.BackgroundTransparency = 0.3; icon.BorderSizePixel = 0; icon.Parent = main
local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(0,35); ic.Parent = icon
local it = Instance.new("TextLabel"); it.Size = UDim2.new(1,0,1,0); it.BackgroundTransparency = 1; it.Text = "🎬"; it.TextSize = 35; it.Font = Enum.Font.GothamBold; it.Parent = icon

local name = Instance.new("TextLabel"); name.Size = UDim2.new(0,200,0,25); name.Position = UDim2.new(0,110,0,25)
name.BackgroundTransparency = 1; name.Text = "🎬 SONEY"; name.TextColor3 = Color3.fromRGB(255,50,100); name.TextSize = 22; name.Font = Enum.Font.GothamBold; name.TextXAlignment = Enum.TextXAlignment.Left; name.Parent = main
local subtitle = Instance.new("TextLabel"); subtitle.Size = UDim2.new(0,200,0,20); subtitle.Position = UDim2.new(0,110,0,50)
subtitle.BackgroundTransparency = 1; subtitle.Text = "Diretora · Showrunner · IA"; subtitle.TextColor3 = Color3.fromRGB(200,200,220); subtitle.TextSize = 13; subtitle.Font = Enum.Font.Gotham; subtitle.TextXAlignment = Enum.TextXAlignment.Left; subtitle.Parent = main

local div = Instance.new("Frame"); div.Size = UDim2.new(1,-50,0,1); div.Position = UDim2.new(0,25,0,105)
div.BackgroundColor3 = Color3.fromRGB(255,50,100); div.BackgroundTransparency = 0.6; div.BorderSizePixel = 0; div.Parent = main

local dialog = Instance.new("Frame"); dialog.Size = UDim2.new(1,-50,0,130); dialog.Position = UDim2.new(0,25,0,120)
dialog.BackgroundColor3 = Color3.fromRGB(15,15,35); dialog.BackgroundTransparency = 0.2; dialog.BorderSizePixel = 0; dialog.ClipsDescendants = true; dialog.Parent = main
local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0,12); dc.Parent = dialog
local dt = Instance.new("TextLabel"); dt.Size = UDim2.new(1,-30,1,-30); dt.Position = UDim2.new(0,15,0,15)
dt.BackgroundTransparency = 1; dt.Text = ""; dt.TextColor3 = Color3.fromRGB(230,230,255); dt.TextSize = 16; dt.Font = Enum.Font.Gotham; dt.TextWrapped = true; dt.TextXAlignment = Enum.TextXAlignment.Left; dt.TextYAlignment = Enum.TextYAlignment.Top; dt.RichText = true; dt.Parent = dialog

local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0,200,0,45); btn.Position = UDim2.new(0.5,-100,1,-65)
btn.BackgroundColor3 = Color3.fromRGB(255,50,100); btn.BackgroundTransparency = 0.15; btn.BorderSizePixel = 0; btn.Text = "▶ CONTINUAR"; btn.TextColor3 = Color3.fromRGB(255,255,255); btn.TextSize = 16; btn.Font = Enum.Font.GothamBold; btn.Visible = false; btn.Parent = main
local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,12); bc.Parent = btn

local lines = {}; local currentLine = 0; local isTyping = false; local typingConn = nil
function showDialog(l)
    overlay.Visible = true; main.Visible = true; currentLine = 0; lines = l; btn.Visible = true; btn.Text = "▶ PRÓXIMO"; nextLine()
end
function nextLine()
    if currentLine >= #lines then btn.Text = "🎬 IR PARA VOTAÇÃO"; btn.MouseButton1Click:Connect(function() main.Visible = false; overlay.Visible = false; if _G.SoneyOpenVote then _G.SoneyOpenVote() end end); return end
    currentLine += 1; local line = lines[currentLine]
    if typingConn then typingConn:Disconnect() end; dt.Text = ""; local fullText = line.text or ""; local ci = 0; local speed = line.speed or 0.03; isTyping = true; btn.Text = "⏳"; btn.Visible = false
    typingConn = game:GetService("RunService").Stepped:Connect(function()
        if ci < #fullText then ci += 1; dt.Text = string.sub(fullText, 1, ci) else typingConn:Disconnect(); isTyping = false; btn.Visible = true; btn.Text = currentLine >= #lines and "🎬 IR PARA VOTAÇÃO" or "▶ PRÓXIMO" end
    end)
end
btn.MouseButton1Click:Connect(function()
    if isTyping then if typingConn then typingConn:Disconnect() end; isTyping = false; dt.Text = lines[currentLine].text or ""; btn.Visible = true; btn.Text = currentLine >= #lines and "🎬 IR PARA VOTAÇÃO" or "▶ PRÓXIMO"
    else nextLine() end
end)
function _G.SoneyShowDialog(custom)
    showDialog(custom or {{text="🎬 Olá! Eu sou a SONEY.", speed=0.04},{text="Cada escolha sua muda a história.", speed=0.03},{text="Aperte V para votar! 🎬🔥", speed=0.05}})
end
task.wait(3)
if not player:FindFirstChild("SoneyFirstTime") then local v = Instance.new("BoolValue"); v.Name = "SoneyFirstTime"; v.Parent = player; _G.SoneyShowDialog() end
print("✅ SoneyShowroom")
```

---

# 📦 WORKSPACE (4 scripts)

---

## 🗺️ PASSO 19 de 22 — BossTitan

**Montar o modelo no Workspace primeiro:**

1. **Workspace** → **Model** → renomear para **TitanEsmeralda**
2. Dentro de TitanEsmeralda:
   - **Part** → renomear para **Core** → `Size: 10,20,10` → `Color: RGB(0,100,50)` → `Anchored: true`
   - **Part** → renomear para **HealthBar** → `Size: 20,2,1` → `Color: RGB(0,255,0)` → acima do Core
   - Criar **5 Parts**: **Bulbo1**, **Bulbo2**, **Bulbo3**, **Bulbo4**, **Bulbo5**
     - `Size: 2,2,2` → `Color: RGB(0,255,100)` → `Material: Neon`
     - Posicionar em círculo ao redor do Core
3. Dentro de **TitanEsmeralda** → **Script** → renomear para **BossTitan** → colar:

```lua
local Players = game:GetService("Players"); local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
local boss = script.Parent; local core = boss:WaitForChild("Core")
local currentPhase = 1; local active = true; local playersInFight = {}
local bulbs = {}; for i = 1, 5 do local b = boss:FindFirstChild("Bulbo"..i); if b then table.insert(bulbs, b) end end
local PHASES = {
    {fase=1, hp=4000, reward=50, item="Fragmento de Cristal"},
    {fase=2, hp=3000, reward=100, item="Gema Mutante"},
    {fase=3, hp=2000, reward=200, item="Núcleo de Titã"},
    {fase=4, hp=1000, reward=350, item="Essência Verde"},
    {fase=5, hp=0, reward=1000, item="ITENS LENDÁRIOS 💎"},
}
function advancePhase()
    if currentPhase > 5 then return end; local phase = PHASES[currentPhase]
    for _, p in ipairs(Players:GetPlayers()) do notifyEvent:FireClient(p, {title="🌿 FASE "..currentPhase.." — "..phase.item, message=phase.reward.." BC liberados!", duration=5}) end
    for _, p in ipairs(playersInFight) do if _G.NexusAddBC then _G.NexusAddBC(p, phase.reward, "Fase "..currentPhase) end end
    currentPhase = currentPhase + 1
    if currentPhase > 5 then
        for _, p in ipairs(Players:GetPlayers()) do notifyEvent:FireClient(p, {title="🏆 TITÃ DERROTADO!", message="Tesouro liberado!", duration=8}) end
        boss:Destroy()
    end
end
for i, bulb in ipairs(bulbs) do
    local hp = Instance.new("IntValue"); hp.Name = "BulboHP"; hp.Value = 1000; hp.Parent = bulb
    bulb.Touched:Connect(function(hit)
        if not active then return end; local char = hit.Parent; if not char then return end
        local p = Players:GetPlayerFromCharacter(char); if not p then return end
        if not table.find(playersInFight, p) then table.insert(playersInFight, p) end
        local bh = bulb:FindFirstChild("BulboHP")
        if bh then bh.Value = bh.Value - 10; if bh.Value <= 0 then
            local t = TweenService:Create(bulb, TweenInfo.new(0.5), {Transparency=1}); t:Play(); bulb:Destroy(); advancePhase() end end
    end)
end
task.spawn(function()
    while active do task.wait(5+math.random(0,3))
        for _, p in ipairs(Players:GetPlayers()) do
            local c = p.Character; if c then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp and (core.Position - hrp.Position).Magnitude < 30 then
                    local atk = TweenService:Create(core, TweenInfo.new(0.3), {Color=Color3.fromRGB(0,255,100)}); atk:Play(); task.wait(0.3)
                    for _, p2 in ipairs(Players:GetPlayers()) do
                        local c2 = p2.Character; if c2 then
                            local h = c2:FindFirstChild("Humanoid")
                            if h and (core.Position - c2:FindFirstChild("HumanoidRootPart").Position).Magnitude < 30 then h:TakeDamage(15) end end end
                    local rst = TweenService:Create(core, TweenInfo.new(0.3), {Color=Color3.fromRGB(0,100,50)}); rst:Play() end end end end)
task.spawn(function() while true do task.wait(3600); if not boss.Parent then local nb = boss:Clone(); nb.Parent = workspace; nb:FindFirstChild("Core").Position = Vector3.new(0,50,0); print("🌿 Boss renasceu!") end end end)
print("🌿 BossTitan ativo — 5 fases!")
```

---

## 🗺️ PASSO 20 de 22 — EnemyPatrol

**Montar o modelo base primeiro:**

1. **Workspace** → **Model** → renomear para **InimigoBase**
2. Dentro de InimigoBase:
   - **Part** → renomear para **Body** → `Size: 2,3,2` → `Color: RGB(255,50,50)` → `Anchored: true`
   - **Part** → renomear para **Head** → `Size: 1,1,1` → `Color: RGB(255,0,0)` → Y=2
   - **PointLight** → `Color: RGB(255,0,0)` → `Range: 10`
3. Dentro de **InimigoBase** → **Script** → renomear para **EnemyPatrol** → colar:

```lua
local Players = game:GetService("Players"); local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local body = script.Parent:WaitForChild("Body"); local light = script.Parent:WaitForChild("PointLight")
local nome = script.Parent.Name; local num = tonumber(nome:match("%d+")) or 1
local rotaFolder = workspace:FindFirstChild("RotaInimigo"..num)
local waypoints = {}; if rotaFolder then for _, c in ipairs(rotaFolder:GetChildren()) do if c:IsA("BasePart") then table.insert(waypoints, c) end end end
local SPEED = 5+(num%5); local currentWP = 1; local active = true; local isChasing = false
task.spawn(function()
    while active do
        for i=1,6 do light.Color = Color3.fromRGB(255,50-(i*5),50-(i*5)); light.Brightness = 2+(i*0.5); task.wait(0.1) end
        for i=6,1,-1 do light.Color = Color3.fromRGB(255,50-(i*5),50-(i*5)); light.Brightness = 2+(i*0.5); task.wait(0.1) end end end)
local function moveTo(target)
    local path = PathfindingService:CreatePath({AgentRadius=2,AgentHeight=4,AgentCanJump=false,WaypointSpacing=3})
    local s, e = pcall(function() path:ComputeAsync(body.Position, target.Position) end)
    if s and path.Status == Enum.PathStatus.Success then
        for _, wp in ipairs(path:GetWaypoints()) do
            if not active or not isChasing then break end
            body.CFrame = CFrame.lookAt(body.Position, wp.Position)
            local t = TweenService:Create(body, TweenInfo.new((body.Position-wp.Position).Magnitude/SPEED, Enum.EasingStyle.Linear), {Position=wp.Position})
            t:Play(); t.Completed:Wait() end
    else
        local dist = (body.Position-target.Position).Magnitude; if dist<1 then return end
        body.CFrame = CFrame.lookAt(body.Position, target.Position)
        local t = TweenService:Create(body, TweenInfo.new(dist/SPEED, Enum.EasingStyle.Linear), {Position=target.Position})
        t:Play(); t.Completed:Wait() end end
local function patrol()
    if #waypoints==0 then return end; isChasing = false
    while active and not isChasing do
        local t = waypoints[currentWP]; if not t then currentWP=1; t=waypoints[1] end
        moveTo(t); task.wait(0.5); currentWP = currentWP+1; if currentWP>#waypoints then currentWP=1 end end end
local function chasePlayer(p)
    isChasing = true
    while active and isChasing do
        local c = p.Character; if not c then break end; local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then break end
        local dist = (body.Position-hrp.Position).Magnitude
        if dist>20 then isChasing=false; break end
        if dist<=5 then local h = c:FindFirstChild("Humanoid"); if h then h:TakeDamage(10) end; task.wait(1) else moveTo(hrp) end
        task.wait(0.5) end
    isChasing = false; task.spawn(patrol) end
task.spawn(function()
    while active do task.wait(1.5); if isChasing then continue end
        for _, p in ipairs(Players:GetPlayers()) do
            local c = p.Character; if c then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp and (body.Position-hrp.Position).Magnitude<20 then
                    if not isChasing then task.spawn(function() chasePlayer(p) end) end; break end end end end end)
if #waypoints>0 then print("⚠️ "..nome.." patrulhando!"); task.spawn(patrol) else warn("⚠️ "..nome.." sem waypoints") end
```

**Depois de criar o InimigoBase:**
4. Duplica ele **12 vezes** → renomeia para **Inimigo1** até **Inimigo12**
5. Cria pastas **RotaInimigo1** até **RotaInimigo12** no Workspace
6. Dentro de cada pasta, coloca **3-5 Parts** invisíveis como waypoints
7. Posiciona cada inimigo no início da sua rota

---

## 🗺️ PASSO 21 de 22 — ReliquiaInterativa

**Montar a relíquia modelo:**

1. **Workspace** → **Folder** → renomear para **Reliquias**
2. Dentro de Reliquias:
   - **Part** → renomear para **Reliquia1** → `Size: 1,1,1` → `Color: RGB(255,200,50)` → `Material: Neon`
   - **ProximityPrompt** → `HoldDuration: 0` → `MaxActivationDistance: 5` → `KeyboardKeyCode: E` → `ActionText: "Coletar Relíquia"`
   - **Script** → colar:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bcEvent = ReplicatedStorage:WaitForChild("BCEvent")
local prompt = script.Parent:WaitForChild("ProximityPrompt"); local part = script.Parent; local RESPAWN = 30
prompt.Triggered:Connect(function(player)
    prompt.Enabled = false; part.Transparency = 0.8; part.CanCollide = false
    bcEvent:FireServer("coletarReliquia", script.Parent.Name)
    task.wait(RESPAWN); part.Transparency = 0; part.CanCollide = true; prompt.Enabled = true
end)
```

3. Duplica **Reliquia1** de 15 a 20 vezes → renomeia **Reliquia2...Reliquia20**
4. Espalha pelo mapa

---

## 🗺️ PASSO 22 de 22 — ZonaDeVenda + EasterEgg

**Zona de Venda:**
1. **Workspace** → **Part** → renomear para **ZonaDeVenda** → `Size: 10,0.5,10` → `Color: RGB(0,200,255)` → `Transparency: 0.5`
2. Dentro de ZonaDeVenda → **Script** → colar:

```lua
script.Parent.Touched:Connect(function(hit)
    local p = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
    if p then local e = game:GetService("ReplicatedStorage"):FindFirstChild("BCEvent"); if e then e:FireClient(p, "zonaVenda") end end
end)
```

**Easter Egg São Paulo:**
1. **Workspace** → **Model** → renomear para **EstatuaSP**
2. Dentro:
   - **Part** → `Size: 5,8,3` → `Color: RGB(100,100,100)` → `Material: Concrete`
   - **ProximityPrompt** → `ActionText: "Examinar Estátua"`
   - **Script** → colar:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bcEvent = ReplicatedStorage:WaitForChild("BCEvent")
local prompt = script.Parent:WaitForChild("ProximityPrompt")
prompt.Triggered:Connect(function(player) bcEvent:FireServer("dailyEasterEgg") end)
```

---

# ✅ RESUMO — 22 PASSOS CONCLUÍDOS

| # | Local | Tipo | Nome |
|:-:|-------|:----:|------|
| 1 | ReplicatedStorage | ModuleScript | ConfigModule |
| 2 | ReplicatedStorage | ModuleScript | SoneyAPIBridge |
| 3 | ReplicatedStorage | ModuleScript | EpisodeService |
| 4 | ReplicatedStorage | RemoteEvent | SoneyNotifyEvent |
| 5 | ReplicatedStorage | RemoteEvent | BCEvent |
| 6 | ReplicatedStorage | RemoteEvent | ToolEvent |
| 7 | ServerScriptService | Script | LeaderstatsSystem |
| 8 | ServerScriptService | Script | NexusEconomy |
| 9 | ServerScriptService | Script | FerramentasMineracao |
| 10 | ServerScriptService | Script | NexusMonetizacao |
| 11 | ServerScriptService | Script | PurchaseHandler |
| 12 | ServerScriptService | Script | VoteHandler |
| 13 | ServerScriptService | Script | UINotifier |
| 14 | ServerScriptService | Script | SoneyCutsceneHandler |
| 15 | StarterGui | LocalScript | NexusHUD |
| 16 | StarterGui | LocalScript | SoneyClientUI |
| 17 | StarterGui | LocalScript | VoteUI |
| 18 | StarterGui | LocalScript | SoneyShowroom |
| 19 | Workspace | Script (dentro do Model) | BossTitan |
| 20 | Workspace | Script (dentro do Model) | EnemyPatrol |
| 21 | Workspace | Script (dentro da Part) | ReliquiaInterativa |
| 22 | Workspace | Script (ZonaDeVenda + EstatuaSP) | ZonaVenda + EasterEgg |

**Agora é só seguir os 22 passos em ordem!** 🚀🔥