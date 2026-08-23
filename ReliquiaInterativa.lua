-- ReliquiaInterativa (Script) — Colocar dentro de CADA relíquia no mapa
-- Funciona com ProximityPrompt: jogador aperta E para coletar

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bcEvent = ReplicatedStorage:WaitForChild("BCEvent")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

local prompt = script.Parent:WaitForChild("ProximityPrompt")
local part = script.Parent

-- Cooldown visual
local RESPAWN_TIME = 30  -- segundos para renascer

prompt.Triggered:Connect(function(player)
    -- Desativa visualmente
    prompt.Enabled = false
    part.Transparency = 0.8
    part.CanCollide = false
    
    -- Envia evento para o servidor
    bcEvent:FireServer("coletarReliquia", script.Parent.Name)
    
    -- Aguarda resposta
    bcEvent.OnClientEvent:Connect(function(action, success, result)
        if action == "relicResult" then
            if success then
                notifyEvent:FireClient(player, {
                    title = "🔮 Relíquia Coletada!",
                    message = "+" .. result .. " Bio-Créditos",
                    duration = 3
                })
            end
        end
    end)
    
    -- Renasce após 30 segundos
    task.wait(RESPAWN_TIME)
    part.Transparency = 0
    part.CanCollide = true
    prompt.Enabled = true
end)