-- SoneyCutsceneHandler (Script)
-- Colocar em: ServerScriptService > SoneyCutsceneHandler
-- Dispara a aparição da Soney para os jogadores

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

-- Falas da Soney para cada momento do jogo

local SONEY_LINES = {
    welcome = {
        { text = "🎬 Olá, jogador! Eu sou a SONEY.", speed = 0.04 },
        { text = "Sou a diretora de cinema digital deste universo. Cada escolha sua muda a história.", speed = 0.03 },
        { text = "Aqui, você não é só um espectador — você é o ROTEIRISTA.", speed = 0.03 },
        { text = "Cada voto decide o destino dos personagens. Cada episódio é seu.", speed = 0.03 },
        { text = "O Último Andar está prestes a começar... e você já tem uma decisão a tomar.", speed = 0.035 },
        { text = "Clara está diante de uma porta trancada no 13º andar. O que ela deve fazer?", speed = 0.035 },
        { text = "Abra a porta e descubra a verdade... ou finja que não viu nada e vá embora.", speed = 0.035 },
        { text = "A escolha é sua. VOTE AGORA. 🎬🔥", speed = 0.05 },
    },
    new_episode = {
        { text = "🎬 ATENÇÃO, JOGADORES!", speed = 0.04 },
        { text = "Um novo capítulo de O Último Andar está no ar.", speed = 0.035 },
        { text = "O que Clara fará agora? O destino dela está em suas mãos.", speed = 0.035 },
        { text = "Votem agora e decidam o próximo passo da história! 🗳️", speed = 0.04 },
    },
    vote_result = {
        { text = "🎬 A votação terminou!", speed = 0.04 },
        { text = "A maioria escolheu... {CHOICE}", speed = 0.045 },
        { text = "E isso mudará TUDO. Preparem-se para o próximo episódio. 🔥", speed = 0.04 },
    },
    milestone = {
        { text = "🎬 INCRÍVEL!", speed = 0.05 },
        { text = "{COUNT} jogadores já votaram nesta história!", speed = 0.04 },
        { text = "Vocês estão construindo algo gigante aqui. Obrigado por fazerem parte disso. 🫶", speed = 0.035 },
    }
}

-- Mostra a Soney para um jogador específico
function showSoneyToPlayer(player, scene, customLines)
    if not player or not player.Parent then return end
    
    local lines = customLines or SONEY_LINES[scene] or SONEY_LINES.welcome
    
    task.wait(1)
    notifyEvent:FireClient(player, {
        title = "SHOW_SONEY",
        lines = lines
    })
end

-- Mostra a Soney para todos os jogadores online
function showSoneyToAll(scene, customLines)
    local lines = customLines or SONEY_LINES[scene] or SONEY_LINES.new_episode
    
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            showSoneyToPlayer(player, scene, customLines)
        end)
    end
end

-- Mostra na primeira vez que o jogador entra
Players.PlayerAdded:Connect(function(player)
    -- Espera o jogador carregar
    player:WaitForChild("PlayerGui")
    task.wait(2)
    
    -- Só mostra na primeira vez
    local soneyData = player:FindFirstChild("SoneyFirstTime")
    if not soneyData then
        local value = Instance.new("BoolValue")
        value.Name = "SoneyFirstTime"
        value.Parent = player
        
        task.wait(1)
        showSoneyToPlayer(player, "welcome")
    end
end)

-- Expõe para outros scripts
_G.SoneyShowToPlayer = showSoneyToPlayer
_G.SoneyShowToAll = showSoneyToAll
_G.SoneyLines = SONEY_LINES

print("✅ [SoneyCutsceneHandler] Soney pronta para aparecer! 🎬")