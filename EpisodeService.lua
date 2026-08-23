-- EpisodeService (ModuleScript)
-- Colocar em: ReplicatedStorage > EpisodeService
-- Gerencia episódios e resultados de votação

local SoneyAPI = require(script.Parent:WaitForChild("SoneyAPIBridge"))

local EpisodeService = {}

-- Cache local do episódio atual
local currentEpisode = nil
local lastFetchTime = 0
local CACHE_DURATION = 30  -- segundos

function EpisodeService.getCurrentEpisode()
    -- Usa cache se ainda estiver válido
    if currentEpisode and (os.time() - lastFetchTime) < CACHE_DURATION then
        return true, currentEpisode
    end
    
    local success, data = SoneyAPI.getLatestEpisode()
    if success and data then
        currentEpisode = data.episode or data
        lastFetchTime = os.time()
        return true, currentEpisode
    end
    
    -- Fallback: episódio placeholder
    return false, {
        id = "ep-1",
        number = 1,
        title = "O Primeiro Episódio",
        hook = "O segredo que mudou tudo...",
        choices = {
            { id = "A", text = "Revelar a verdade" },
            { id = "B", text = "Guardar o segredo" }
        }
    }
end

function EpisodeService.submitVote(player, choice)
    if not currentEpisode then
        local _, ep = EpisodeService.getCurrentEpisode()
        currentEpisode = ep
    end
    
    local episodeId = currentEpisode.id or currentEpisode.number or 1
    local success, result = SoneyAPI.submitVote(player, episodeId, choice)
    
    if success then
        -- Invalida o cache para recarregar resultados
        lastFetchTime = 0
        return true, result
    end
    
    return false, nil
end

function EpisodeService.getVoteResults()
    if not currentEpisode then
        EpisodeService.getCurrentEpisode()
    end
    return currentEpisode
end

function EpisodeService.clearCache()
    currentEpisode = nil
    lastFetchTime = 0
end

return EpisodeService