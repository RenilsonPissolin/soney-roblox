-- UINotifier (Script)
-- Colocar em: ServerScriptService > UINotifier

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cria evento remoto para comunicação com o cliente
local notifyEvent = Instance.new("RemoteEvent")
notifyEvent.Name = "SoneyNotifyEvent"
notifyEvent.Parent = ReplicatedStorage

-- Função para enviar notificação a um jogador
function notifyPlayer(player, title, message, duration)
    if not player or not player.Parent then return end
    
    task.spawn(function()
        notifyEvent:FireClient(player, {
            title = title or "🎬 Soney",
            message = message or "",
            duration = duration or 4
        })
    end)
end

-- Notificação de boas-vindas
local function onPlayerAdded(player)
    task.wait(2)
    notifyPlayer(player, "🎬 Bem-vindo ao Universo Soney!", 
        "Você recebeu coins de boas-vindas!\nAssista episódios, vote e ganhe mais!", 6)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Expõe função globalmente
_G.SoneyNotify = notifyPlayer

print("✅ [Soney] UINotifier inicializado!")