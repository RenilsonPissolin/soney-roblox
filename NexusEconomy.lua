-- NexusEconomy (Script) — Economia do Nexus: Bio-Créditos + DataStore
-- Colocar em: ServerScriptService > NexusEconomy

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DataStore (automático quando publicado)
local bcStore = DataStoreService:GetDataStore("BioCreditosData")

-- Eventos
local bcEvent = Instance.new("RemoteEvent")
bcEvent.Name = "BCEvent"
bcEvent.Parent = ReplicatedStorage

local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

-- Dados dos jogadores
local playerData = {}

-- ─── SALVAR / CARREGAR ─────────────────────────────────────────

local function loadPlayer(player)
    local userId = tostring(player.UserId)
    local success, data = pcall(function()
        return bcStore:GetAsync(userId)
    end)
    
    if success and data then
        playerData[userId] = data
    else
        playerData[userId] = {
            bc = 100,  -- Bio-Créditos iniciais
            nivel = 1,
            ferramenta = "Pá Oxidada",
            reliquias = 0,
            lastDaily = "",
            titulo = "Forasteiro"
        }
    end
    
    -- Cria leaderstats
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    local bc = Instance.new("IntValue")
    bc.Name = "BioCreditos"
    bc.Value = playerData[userId].bc
    bc.Parent = leaderstats
    
    local nivel = Instance.new("IntValue")
    nivel.Name = "Nivel"
    nivel.Value = playerData[userId].nivel
    nivel.Parent = leaderstats
    
    local ferramenta = Instance.new("StringValue")
    ferramenta.Name = "Ferramenta"
    ferramenta.Value = playerData[userId].ferramenta
    ferramenta.Parent = leaderstats
    
    print("📦 [Nexus] " .. player.Name .. " carregado — " .. playerData[userId].bc .. " BC")
end

local function savePlayer(userId)
    if playerData[userId] then
        pcall(function()
            bcStore:SetAsync(userId, playerData[userId])
        end)
    end
end

-- ─── FUNÇÕES PÚBLICAS ──────────────────────────────────────────

function addBC(player, amount, reason)
    local userId = tostring(player.UserId)
    if not playerData[userId] then return false end
    
    playerData[userId].bc = playerData[userId].bc + amount
    
    -- Atualiza leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local bc = leaderstats:FindFirstChild("BioCreditos")
        if bc then bc.Value = playerData[userId].bc end
    end
    
    notifyEvent:FireClient(player, {
        title = "💰 +" .. amount .. " BC",
        message = reason or "Bio-Créditos recebidos!",
        duration = 3
    })
    
    return true
end

function removeBC(player, amount, reason)
    local userId = tostring(player.UserId)
    if not playerData[userId] then return false end
    if playerData[userId].bc < amount then return false end
    
    playerData[userId].bc = playerData[userId].bc - amount
    
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local bc = leaderstats:FindFirstChild("BioCreditos")
        if bc then bc.Value = playerData[userId].bc end
    end
    
    return true
end

-- ─── ZONA DE VENDA (Bônus ao entrar no Nexus) ─────────────────

function bonusZonaVenda(player)
    local bonus = 5
    addBC(player, bonus, "Bônus de escaneamento no Nexus!")
    print("🔵 [Nexus] " .. player.Name .. " recebeu " .. bonus .. " BC na Zona de Venda")
end

-- ─── RELÍQUIA INTERATIVA ───────────────────────────────────────

local relicCooldowns = {}

function coletarReliquia(player, relicId)
    local userId = tostring(player.UserId)
    local now = os.time()
    
    -- Cooldown de 30 segundos por relíquia
    if relicCooldowns[relicId] and (now - relicCooldowns[relicId]) < 30 then
        return false, "Aguarde " .. (30 - (now - relicCooldowns[relicId])) .. "s"
    end
    
    relicCooldowns[relicId] = now
    playerData[userId].reliquias = (playerData[userId].reliquias or 0) + 1
    
    local bonus = 10 + math.random(1, 5)
    addBC(player, bonus, "Relíquia coletada!")
    return true, bonus
end

-- ─── EASTER EGG — SÃO PAULO ────────────────────────────────────

function dailyEasterEgg(player)
    local userId = tostring(player.UserId)
    local today = os.date("%Y-%m-%d")
    
    if playerData[userId].lastDaily == today then
        return false, "Você já pegou sua recompensa diária hoje!"
    end
    
    playerData[userId].lastDaily = today
    playerData[userId].titulo = "Explorador de São Paulo"
    
    addBC(player, 50, "🏛️ Recompensa diária — Estátua de São Paulo!")
    notifyEvent:FireClient(player, {
        title = "🏛️ EASTER EGG ENCONTRADO!",
        message = "Título: Explorador de São Paulo! +50 BC",
        duration = 5
    })
    
    return true
end

-- ─── EVENTOS ───────────────────────────────────────────────────

bcEvent.OnServerEvent:Connect(function(player, action, ...)
    if action == "coletarReliquia" then
        local relicId = ...
        local success, result = coletarReliquia(player, relicId)
        bcEvent:FireClient(player, "relicResult", success, result)
    elseif action == "dailyEasterEgg" then
        local success, msg = dailyEasterEgg(player)
        bcEvent:FireClient(player, "dailyResult", success, msg)
    elseif action == "zonaVenda" then
        bonusZonaVenda(player)
    end
end)

-- ─── JOGADOR ENTRA / SAI ───────────────────────────────────────

Players.PlayerAdded:Connect(loadPlayer)

Players.PlayerRemoving:Connect(function(player)
    local userId = tostring(player.UserId)
    savePlayer(userId)
end)

-- Salvamento periódico (a cada 5 minutos)
task.spawn(function()
    while true do
        task.wait(300)
        for userId in pairs(playerData) do
            savePlayer(userId)
        end
        print("💾 [Nexus] Dados salvos automaticamente")
    end
end)

-- Funções globais
_G.NexusAddBC = addBC
_G.NexusRemoveBC = removeBC
_G.NexusGetData = function(player)
    return playerData[tostring(player.UserId)]
end

print("✅ [NexusEconomy] Sistema de Bio-Créditos ativo!")