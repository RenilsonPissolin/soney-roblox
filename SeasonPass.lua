-- SeasonPass (Script)
-- Colocar em: ServerScriptService > SeasonPass
-- Sistema de temporada com recompensas por votos

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("ConfigModule"))
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

local awardCoins = _G.SoneyAwardCoins

-- Progresso dos jogadores na temporada
local seasonProgress = {}  -- userId -> { votes, claimedTiers, hasPass }

-- Recompensas por tier (nível de votos na temporada)
local SEASON_TIERS = {
    { tier = 1,  votes = 1,   reward = 50,  name = "Iniciante 🎬" },
    { tier = 2,  votes = 3,   reward = 100, name = "Espectador 📺" },
    { tier = 3,  votes = 5,   reward = 200, name = "Fã 🎭" },
    { tier = 4,  votes = 10,  reward = 350, name = "Crítico 🎯" },
    { tier = 5,  votes = 15,  reward = 500, name = "Votante 🗳️" },
    { tier = 6,  votes = 25,  reward = 800, name = "Influenciador 📢" },
    { tier = 7,  votes = 40,  reward = 1200,name = "Diretor 🎬" },
    { tier = 8,  votes = 60,  reward = 2000,name = "Showrunner 👑" },
    { tier = 9,  votes = 100, reward = 5000,name = "Lenda 🔥" },
}

-- Recompensas VIP (para quem comprou o passe)
local VIP_TIERS = {
    { tier = 1,  votes = 1,   reward = 100,  exclusive = "Episódio Secreto 1" },
    { tier = 3,  votes = 5,   reward = 300,  exclusive = "Avatar Especial" },
    { tier = 5,  votes = 15,  reward = 700,  exclusive = "Episódio Secreto 2" },
    { tier = 7,  votes = 40,  reward = 1500, exclusive = "Título Showrunner" },
    { tier = 9,  votes = 100, reward = 5000, exclusive = "Nome nos Créditos" },
}

function getSeasonProgress(player)
    local userId = tostring(player.UserId)
    if not seasonProgress[userId] then
        seasonProgress[userId] = { votes = 0, claimedTiers = {}, hasPass = false }
    end
    return seasonProgress[userId]
end

function addVoteToSeason(player)
    local data = getSeasonProgress(player)
    data.votes += 1
    checkAndAwardTiers(player, data)
end

function checkAndAwardTiers(player, data)
    -- Verifica tiers gratuitos
    for _, tier in ipairs(SEASON_TIERS) do
        if data.votes >= tier.votes and not data.claimedTiers[tier.tier] then
            data.claimedTiers[tier.tier] = true
            if awardCoins then
                awardCoins(player, tier.reward, "season_reward")
            end
            notifyEvent:FireClient(player, {
                title = "🏆 Season Pass!",
                message = "Tier " .. tostring(tier.tier) .. ": " .. tier.name .. "\n+" .. tostring(tier.reward) .. " Coins!",
                duration = 5
            })
        end
    end
    
    -- Verifica tiers VIP
    if data.hasPass then
        for _, tier in ipairs(VIP_TIERS) do
            if data.votes >= tier.votes and not data.claimedTiers["vip_" .. tostring(tier.tier)] then
                data.claimedTiers["vip_" .. tostring(tier.tier)] = true
                if awardCoins then
                    awardCoins(player, tier.reward, "season_vip_reward")
                end
                notifyEvent:FireClient(player, {
                    title = "👑 VIP Bonus!",
                    message = tier.exclusive .. "\n+" .. tostring(tier.reward) .. " Coins!",
                    duration = 5
                })
            end
        end
    end
end

function activateSeasonPass(player)
    local data = getSeasonProgress(player)
    data.hasPass = true
    checkAndAwardTiers(player, data)
    notifyEvent:FireClient(player, {
        title = "👑 Season Pass Ativado!",
        message = "Recompensas VIP desbloqueadas! Vote mais para ganhar prêmios exclusivos!",
        duration = 5
    })
end

-- Evento
local seasonEvent = Instance.new("RemoteEvent")
seasonEvent.Name = "SoneySeasonEvent"
seasonEvent.Parent = ReplicatedStorage

seasonEvent.OnServerEvent:Connect(function(player, action, ...)
    if action == "getProgress" then
        local data = getSeasonProgress(player)
        seasonEvent:FireClient(player, "progress", data)
    elseif action == "activatePass" then
        activateSeasonPass(player)
        seasonEvent:FireClient(player, "passActivated", true)
    end
end)

-- Hook no sistema de votos existente
-- Quando alguém vota, adiciona à temporada
local originalVoteProcess = _G.SoneyOnVote
_G.SoneyOnVote = function(player, episodeId, choice)
    addVoteToSeason(player)
    if originalVoteProcess then
        originalVoteProcess(player, episodeId, choice)
    end
end

_G.SoneyAddVoteToSeason = addVoteToSeason
_G.SoneyActivatePass = activateSeasonPass

print("✅ [SeasonPass] Temporada " .. tostring(Config.SEASON.current) .. " ativa!")