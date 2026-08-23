-- SoneyAPIBridge (ModuleScript)
-- Colocar em: ReplicatedStorage > SoneyAPIBridge

local HttpService = game:GetService("HttpService")
local Config = require(script.Parent:WaitForChild("ConfigModule"))

local SoneyAPI = {}

function SoneyAPI.syncPlayer(player, amount, reason)
    local data = {
        userId = player.UserId,
        userName = player.Name,
        displayName = player.DisplayName,
        coinsEarned = amount,
        reason = reason or "earned",
        timestamp = DateTime.now():ToIsoDate(),
        gameVersion = "1.0.0"
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            Config.SONEY_API_URL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson,
            false,
            Config.API_TIMEOUT
        )
    end)

    if success then
        local decoded = HttpService:JSONDecode(response)
        return true, decoded
    else
        warn("⚠️ [SoneyAPI] Falha na comunicação: " .. tostring(response))
        return false, nil
    end
end

function SoneyAPI.getPlayerStory(player)
    local url = Config.SONEY_API_URL .. "/story/" .. player.UserId
    
    local success, response = pcall(function()
        return HttpService:GetAsync(url, false, Config.API_TIMEOUT)
    end)
    
    if success then
        return true, HttpService:JSONDecode(response)
    else
        return false, nil
    end
end

function SoneyAPI.getLatestEpisode()
    local url = Config.SONEY_API_URL .. "/episode/latest"
    
    local success, response = pcall(function()
        return HttpService:GetAsync(url, false, Config.API_TIMEOUT)
    end)
    
    if success then
        local decoded = HttpService:JSONDecode(response)
        return true, decoded
    else
        warn("⚠️ [SoneyAPI] Falha ao buscar episódio: " .. tostring(response))
        return false, nil
    end
end

function SoneyAPI.submitVote(player, episodeId, choice)
    local data = {
        userId = player.UserId,
        episodeId = episodeId,
        choice = choice
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            Config.SONEY_API_URL .. "/vote",
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson,
            false,
            Config.API_TIMEOUT
        )
    end)
    
    if success then
        return true, HttpService:JSONDecode(response)
    else
        return false, nil
    end
end

return SoneyAPI