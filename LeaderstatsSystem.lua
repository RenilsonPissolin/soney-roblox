-- LeaderstatsSystem (Script)
-- Colocar em: ServerScriptService > LeaderstatsSystem

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("ConfigModule"))
local SoneyAPI = require(ReplicatedStorage:WaitForChild("SoneyAPIBridge"))

-- Cache de receipts processados (anti-duplicata)
local processedReceipts = {}
local dailyCoinsTracker = {}

-- Cria leaderstats pro jogador
local function setupLeaderstats(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = Config.WELCOME_BONUS
    coins.Parent = leaderstats
    
    -- Métrica de engajamento
    local episodesWatched = Instance.new("IntValue")
    episodesWatched.Name = "EpisodesWatched"
    episodesWatched.Value = 0
    episodesWatched.Parent = leaderstats
    
    local votesCast = Instance.new("IntValue")
    votesCast.Name = "VotesCast"
    votesCast.Value = 0
    votesCast.Parent = leaderstats
    
    print("🎬 [Soney] " .. player.Name .. " entrou no universo Soney com " .. Config.WELCOME_BONUS .. " coins!")
end

-- Função pública pra adicionar moedas
local function awardCoins(player, amount, reason)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return false end
    
    local coins = leaderstats:FindFirstChild("Coins")
    if not coins then return false end
    
    -- Verifica limite diário
    local today = os.date("%Y-%m-%d")
    if not dailyCoinsTracker[player.UserId] then
        dailyCoinsTracker[player.UserId] = {}
    end
    if not dailyCoinsTracker[player.UserId][today] then
        dailyCoinsTracker[player.UserId][today] = 0
    end
    
    if dailyCoinsTracker[player.UserId][today] + amount > Config.DAILY_COIN_LIMIT then
        warn("⚠️ [Soney] " .. player.Name .. " atingiu o limite diário de coins!")
        return false
    end
    
    -- Aplica o ganho
    local newValue = math.min(coins.Value + amount, Config.MAX_COINS)
    coins.Value = newValue
    dailyCoinsTracker[player.UserId][today] = dailyCoinsTracker[player.UserId][today] + amount
    
    -- Sincroniza com a API (assíncrono)
    task.spawn(function()
        SoneyAPI.syncPlayer(player, amount, reason)
    end)
    
    return true
end

-- Expõe globalmente
_G.SoneyAwardCoins = awardCoins
_G.SoneyProcessedReceipts = processedReceipts

-- Inicialização
Players.PlayerAdded:Connect(setupLeaderstats)

print("✅ [Soney] LeaderstatsSystem inicializado!")