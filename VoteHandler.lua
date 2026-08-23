-- VoteHandler (Script)
-- Colocar em: ServerScriptService > VoteHandler
-- Gerencia votos no servidor: recompensa, validação e notificação

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("ConfigModule"))
local SoneyAPI = require(ReplicatedStorage:WaitForChild("SoneyAPIBridge"))

-- Eventos
local voteEvent = Instance.new("RemoteEvent")
voteEvent.Name = "SoneyVoteEvent"
voteEvent.Parent = ReplicatedStorage

local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

-- Controle de votos por jogador
local playerVotes = {}  -- userId -> { episodeId, timestamp }
local VOTE_COOLDOWN = 60  -- segundos entre votos
local VOTE_REWARD = 25    -- coins por voto

-- Valida voto
local function validateVote(player, episodeId, choice)
    -- Verifica jogador
    if not player or not player.Parent then
        return false, "Jogador inválido"
    end
    
    -- Verifica escolha
    if choice ~= "A" and choice ~= "B" then
        return false, "Escolha inválida (use A ou B)"
    end
    
    -- Verifica cooldown
    local userId = tostring(player.UserId)
    local lastVote = playerVotes[userId]
    if lastVote then
        if lastVote.episodeId == episodeId then
            return false, "Você já votou neste episódio!"
        end
        if os.time() - lastVote.timestamp < VOTE_COOLDOWN then
            local remaining = VOTE_COOLDOWN - (os.time() - lastVote.timestamp)
            return false, "Aguarde " .. tostring(remaining) .. "s para votar novamente"
        end
    end
    
    return true, nil
end

-- Processa voto
local function processVote(player, episodeId, choice)
    local valid, errorMsg = validateVote(player, episodeId, choice)
    if not valid then
        return false, errorMsg
    end
    
    local userId = tostring(player.UserId)
    
    -- Registra voto no servidor
    playerVotes[userId] = {
        episodeId = episodeId,
        choice = choice,
        timestamp = os.time()
    }
    
    -- Atualiza leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local votesCast = leaderstats:FindFirstChild("VotesCast")
        if votesCast then
            votesCast.Value = votesCast.Value + 1
        end
    end
    
    -- Dá recompensa em coins
    local coinsReward = VOTE_REWARD
    local awardCoins = _G.SoneyAwardCoins
    if awardCoins then
        awardCoins(player, coinsReward, "vote")
    end
    
    -- Envia para a API (assíncrono)
    task.spawn(function()
        SoneyAPI.submitVote(player, episodeId, choice)
    end)
    
    -- Notifica o jogador
    notifyEvent:FireClient(player, {
        title = "🗳️ Voto Registrado!",
        message = "Você escolheu " .. choice .. "! +" .. tostring(coinsReward) .. " Coins!",
        duration = 4
    })
    
    print("🗳️ [Soney] " .. player.Name .. " votou " .. choice .. " no ep " .. tostring(episodeId))
    
    return true, nil
end

-- Nova votação (novo episódio)
function newEpisodeVote(episodeId, title, hook, choices)
    -- Notifica todos os jogadores online
    for _, player in ipairs(Players:GetPlayers()) do
        notifyEvent:FireClient(player, {
            title = "NOVO_EPISODIO",
            message = "Novo episódio disponível para votação!",
            duration = 5
        })
    end
    
    print("📺 [Soney] Novo episódio " .. tostring(episodeId) .. " disponível para votação!")
end

-- Evento do cliente
voteEvent.OnServerEvent:Connect(function(player, action, ...)
    if action == "vote" then
        local episodeId, choice = ...
        local success, msg = processVote(player, episodeId, choice)
        voteEvent:FireClient(player, "voteResult", success, msg)
    elseif action == "getVoteStatus" then
        local episodeId = ...
        local userId = tostring(player.UserId)
        local hasVoted = playerVotes[userId] and playerVotes[userId].episodeId == episodeId
        voteEvent:FireClient(player, "voteStatus", hasVoted)
    end
end)

-- Inicialização
print("✅ [Soney] VoteHandler inicializado! Recompensa: " .. tostring(VOTE_REWARD) .. " coins/voto")

-- Expõe função para outros scripts
_G.SoneyNewEpisode = newEpisodeVote