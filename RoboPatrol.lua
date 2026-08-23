-- RoboPatrol (Script) — VERSÃO FINAL COMPLETA
-- Colocar dentro de CADA robô (RoboSoney1 a RoboSoney12)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ─── COMPONENTES DO ROBÔ ───────────────────────────────────────

local body = script.Parent:WaitForChild("Body")
local light = script.Parent:WaitForChild("PointLight")
local prompt = script.Parent:WaitForChild("ProximityPrompt")

-- ─── DESCOBRE QUAL ROBÔ É PELO NOME ───────────────────────────
-- Ex: "RoboSoney1" → numero = 1 → procura "RotaRobo1"

local nome = script.Parent.Name
local numero = tonumber(nome:match("%d+"))
local rotaNome = "RotaRobo" .. numero
local rotaFolder = workspace:FindFirstChild(rotaNome)

-- Carrega os waypoints da rota
local waypoints = {}
if rotaFolder then
    for _, child in ipairs(rotaFolder:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(waypoints, child)
        end
    end
end

-- ─── CONFIGURAÇÃO ──────────────────────────────────────────────
-- Cada robô tem velocidade única baseada no seu número

local SPEED = 3 + (numero % 7)       -- velocidade entre 3 e 9
local currentWP = 1                   -- waypoint atual
local active = true                   -- controle de loop
local isFollowing = false             -- controlando se está seguindo

-- ─── ANIMAÇÃO: PISCA A LUZ ─────────────────────────────────────
-- Cada robô pisca num ritmo diferente

task.spawn(function()
    local delay = (numero % 5) * 0.1
    while active do
        task.wait(delay)
        -- Acende
        for i = 1, 6 do
            light.Brightness = 2 + (i * 0.3)
            task.wait(0.1)
        end
        -- Apaga
        for i = 6, 1, -1 do
            light.Brightness = 2 + (i * 0.3)
            task.wait(0.1)
        end
    end
end)

-- ─── FUNÇÃO: MOVER PARA UM PONTO ───────────────────────────────

local function moveTo(target)
    local dist = (body.Position - target.Position).Magnitude
    if dist < 0.5 then return end
    
    -- Olha na direção do destino
    body.CFrame = CFrame.lookAt(
        body.Position,
        Vector3.new(target.Position.X, body.Position.Y, target.Position.Z)
    )
    
    -- Move suavemente (inclui altura Y para subir/descer andares)
    local tween = TweenService:Create(body, TweenInfo.new(
        dist / SPEED,
        Enum.EasingStyle.Linear
    ), {
        Position = target.Position
    })
    tween:Play()
    tween.Completed:Wait()
end

-- ─── FUNÇÃO: PATRULHA PRINCIPAL ────────────────────────────────

local function patrol()
    if #waypoints == 0 then
        warn("⚠️ " .. nome .. ": Nenhum waypoint encontrado em " .. rotaNome)
        print("Crie waypoints dentro de Workspace > " .. rotaNome)
        return
    end
    
    print("🤖 " .. nome .. " iniciou patrulha — " .. #waypoints .. " pontos, velocidade " .. SPEED)
    
    while active and not isFollowing do
        local target = waypoints[currentWP]
        if not target then
            currentWP = 1
            target = waypoints[1]
        end
        
        moveTo(target)
        task.wait(0.5)
        
        currentWP = currentWP + 1
        if currentWP > #waypoints then
            currentWP = 1  -- volta ao início (loop infinito)
        end
    end
end

-- ─── FUNÇÃO: SEGUIR JOGADOR ────────────────────────────────────

local function followPlayer(player)
    isFollowing = true
    local followTime = 0
    local MAX_FOLLOW_TIME = 8  -- segue por no máximo 8 segundos
    
    while active and followTime < MAX_FOLLOW_TIME do
        local character = player.Character
        if not character then break end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then break end
        
        local dist = (body.Position - hrp.Position).Magnitude
        
        -- Se o jogador ficar muito longe, para de seguir
        if dist > 25 then break end
        
        -- Se estiver um pouco longe, move para perto
        if dist > 3 then
            moveTo(hrp)
        end
        
        followTime = followTime + 0.5
        task.wait(0.5)
    end
    
    isFollowing = false
    -- Volta a patrulhar
    task.spawn(patrol)
end

-- ─── DETECTOR DE JOGADORES PRÓXIMOS ────────────────────────────

task.spawn(function()
    while active do
        task.wait(2)  -- verifica a cada 2 segundos
        
        if isFollowing then continue end
        
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (body.Position - hrp.Position).Magnitude
                    if dist < 10 then  -- jogador chegou perto
                        task.spawn(function()
                            followPlayer(player)
                        end)
                        break
                    end
                end
            end
        end
    end
end)

-- ─── INTERAÇÃO: CADA ROBÔ TEM UMA FALA ÚNICA ──────────────────

prompt.Triggered:Connect(function(player)
    local notifyEvent = game:GetService("ReplicatedStorage"):FindFirstChild("SoneyNotifyEvent")
    if not notifyEvent then return end
    
    -- Mensagem única para cada um dos 12 robôs
    local mensagens = {
        [1] = "Eu sou o olho da Soney no lobby. Nada escapa de mim.",
        [2] = "A Soney Gigante me enviou para te recepcionar neste andar.",
        [3] = "Já votou hoje? Aperte V e faça sua escolha!",
        [4] = "O 13º andar guarda segredos. Você tem coragem?",
        [5] = "Cada voto move a história. Qual é o seu?",
        [6] = "Eu patrulho este andar para garantir que ninguém perca os episódios.",
        [7] = "A Soney está assistindo. Sempre.",
        [8] = "Você sabia que já existem 8 finais diferentes?",
        [9] = "Os robôs da Soney estamos em toda parte. Você nos vê?",
        [10] = "Este andar é meu. Mas a história é sua.",
        [11] = "Faltam poucos votos para o próximo episódio!",
        [12] = "Eu sou o último robô. Se você me encontrou, está no caminho certo.",
    }
    
    local msg = mensagens[numero] or "Eu sou um robô da Soney. Aperte V para votar!"
    
    notifyEvent:FireClient(player, {
        title = "SHOW_SONEY",
        lines = {
            { text = "🤖 " .. nome .. " online!", speed = 0.04 },
            { text = msg, speed = 0.035 },
            { text = "Aperte V para votar no drama!", speed = 0.035 },
        }
    })
end)

-- ─── INICIAR ───────────────────────────────────────────────────

if #waypoints > 0 then
    print("✅ " .. nome .. " patrulhando " .. #waypoints .. " waypoints!")
    task.spawn(patrol)
else
    warn("⚠️ " .. nome .. " sem waypoints. Crie a pasta " .. rotaNome .. " em Workspace.")
end