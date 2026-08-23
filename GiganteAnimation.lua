-- GiganteAnimation (Script) — Soney Gigante Multi-Andar
-- Colocar dentro de SoneyGigante

local hologram = script.Parent:WaitForChild("HologramBody")
local light = script.Parent:WaitForChild("PointLight")
local sound = script.Parent:WaitForChild("Sound")
local prompt = script.Parent:WaitForChild("ProximityPrompt")

-- Pulsação épica
task.spawn(function()
    while true do
        for i = 1, 20 do
            light.Brightness = 5 + (i * 0.5)
            hologram.Transparency = 0.5 - (i * 0.01)
            task.wait(0.05)
        end
        for i = 20, 1, -1 do
            light.Brightness = 5 + (i * 0.5)
            hologram.Transparency = 0.5 - (i * 0.01)
            task.wait(0.05)
        end
    end
end)

-- Flutuação
task.spawn(function()
    local origY = hologram.Position.Y
    while true do
        local up = game:GetService("TweenService"):Create(hologram, TweenInfo.new(3, Enum.EasingStyle.Sine), {
            Position = Vector3.new(hologram.Position.X, origY + 1, hologram.Position.Z)
        })
        up:Play(); up.Completed:Wait()
        local down = game:GetService("TweenService"):Create(hologram, TweenInfo.new(3, Enum.EasingStyle.Sine), {
            Position = Vector3.new(hologram.Position.X, origY, hologram.Position.Z)
        })
        down:Play(); down.Completed:Wait()
    end
end)

-- Interação
prompt.Triggered:Connect(function(player)
    local notifyEvent = game:GetService("ReplicatedStorage"):FindFirstChild("SoneyNotifyEvent")
    if notifyEvent then
        notifyEvent:FireClient(player, {
            title = "SHOW_SONEY",
            lines = {
                { text = "🎬 BEM-VINDO AO UNIVERSO SONEY!", speed = 0.05 },
                { text = "Este prédio tem vários andares.", speed = 0.04 },
                { text = "Meus 12 robôs estão espalhados por todos eles.", speed = 0.035 },
                { text = "Encontre cada um e descubra mensagens secretas.", speed = 0.035 },
                { text = "Aperte V para votar no rumo da história!", speed = 0.04 },
                { text = "O 13º andar espera por você... 🎬🔥", speed = 0.04 },
            }
        })
    end
end)

print("✅ Soney Gigante ativa — 12 robôs no mapa!")