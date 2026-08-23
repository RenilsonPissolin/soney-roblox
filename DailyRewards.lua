-- DailyRewards (Script)
-- Colocar em: ServerScriptService > DailyRewards
-- Sistema de recompensas diárias + streak

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Config = require(ReplicatedStorage:WaitForChild("ConfigModule"))

local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
local awardCoins = _G.SoneyAwardCoins

-- DataStore para salvar progresso (substituir por DataStore quando publicado)
local playerData = {}  -- userId -> { lastLogin, streak, totalLogins }

-- Recompensa por dia de streak
local STREAK_REWARDS = {
    1,    -- dia 1: 50 coins
    2,    -- dia 2: 50 coins
    3,    -- dia 3: 100 coins + bônus
    4,    -- dia 4: 50 coins
    5,    -- dia 5: 50 coins
    6,    -- dia 6: 50 coins
    7,    -- dia 7: 300 coins + bônus grande
}

local function getDayReward(streakDay)
    local idx = ((streakDay - 1) % 7) + 1
    local base = STREAK_REWARDS[idx] or 50
    local bonus = 0
    
    -- Bônus especial nos dias 3 e 7
    if idx == 3 then
        bonus = 50  -- bônus extra
    elseif idx == 7 then
        bonus = 200  -- bônus grande
    end
    
    return base + bonus, idx
end

function claimDailyReward(player)
    local userId = tostring(player.UserId)
    local today = os.date("%Y-%m-%d")
    
    if not playerData[userId] then
        playerData[userId] = { lastLogin = "", streak = 0, totalLogins = 0 }
    end
    
    local data = playerData[userId]
    
    -- Verifica se já pegou hoje
    if data.lastLogin == today then
        return false, "Você já pegou sua recompensa hoje!"
    end
    
    local yesterday = os.date("%Y-%m-%d", os.time() - 86400)
    
    -- Verifica streak
    if data.lastLogin == yesterday then
        data.streak += 1
    else
        data.streak = 1  -- resetou a streak
    end
    
    data.lastLogin = today
    data.totalLogins += 1
    
    -- Calcula recompensa
    local reward, dayIdx = getDayReward(data.streak)
    local bonus = (dayIdx == 3 and 50) or (dayIdx == 7 and 200) or 0
    
    -- Dá os coins
    if awardCoins then
        awardCoins(player, reward, "daily_login")
    end
    
    -- Notifica
    local streakMsg = "🔥 Streak: " .. tostring(data.streak) .. " dias!"
    local bonusMsg = bonus > 0 and " +" .. tostring(bonus) .. " bônus!" or ""
    
    notifyEvent:FireClient(player, {
        title = "🎁 Recompensa Diária!",
        message = "+" .. tostring(reward) .. " Coins!" .. bonusMsg .. "\n" .. streakMsg,
        duration = 5
    })
    
    print("📅 [Daily] " .. player.Name .. " - Dia " .. tostring(data.streak) .. " (+" .. tostring(reward) .. ")")
    
    return true, {
        streak = data.streak,
        reward = reward,
        bonus = bonus,
        totalLogins = data.totalLogins
    }
end

function getPlayerStreak(player)
    local userId = tostring(player.UserId)
    if not playerData[userId] then
        return 0
    end
    return playerData[userId].streak or 0
end

-- Conexão com o Evento
local rewardEvent = Instance.new("RemoteEvent")
rewardEvent.Name = "SoneyRewardEvent"
rewardEvent.Parent = ReplicatedStorage

rewardEvent.OnServerEvent:Connect(function(player, action)
    if action == "claimDaily" then
        local success, result = claimDailyReward(player)
        rewardEvent:FireClient(player, "dailyResult", success, result)
    elseif action == "getStreak" then
        local streak = getPlayerStreak(player)
        rewardEvent:FireClient(player, "streakInfo", streak)
    end
end)

-- Função pública
_G.SoneyClaimDaily = claimDailyReward
_G.SoneyGetStreak = getPlayerStreak

print("✅ [DailyRewards] Sistema de recompensas diárias ativo!")