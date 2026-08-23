-- EnemyPatrol (Script) — INIMIGOS PATRULHANDO (Drone / Fera Mutante)
-- Substitui o RoboPatrol para funcionar como inimigo

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

local body = script.Parent:WaitForChild("Body")
local light = script.Parent:WaitForChild("PointLight")
local aggroRange = script.Parent:FindFirstChild("AggroRange") or 20
local attackRange = script.Parent:FindFirstChild("AttackRange") or 5
local damage = script.Parent:FindFirstChild("Damage") or 10

-- Configurações do inimigo
local nome = script.Parent.Name
local numero = tonumber(nome:match("%d+")) or 1
local rotaNome = "RotaInimigo" .. numero
local rotaFolder = workspace:FindFirstChild(rotaNome)

local waypoints = {}
if rotaFolder then
    for _, child in ipairs(rotaFolder:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(waypoints, child)
        end
    end
end

local SPEED = 5 + (numero % 5)
local currentWP = 1
local active = true
local isChasing = false

-- Efeito de luz vermelha (inimigo)
task.spawn(function()
    while active do
        for i = 1, 6 do
            light.Color = Color3.fromRGB(255, 50 - (i * 5), 50 - (i * 5))
            light.Brightness = 2 + (i * 0.5)
            task.wait(0.1)
        end
        for i = 6, 1, -1 do
            light.Color = Color3.fromRGB(255, 50 - (i * 5), 50 - (i * 5))
            light.Brightness = 2 + (i * 0.5)
            task.wait(0.1)
        end
    end
end)

-- Pathfinding principal
local function moveTo(target)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 4,
        AgentCanJump = false,
        WaypointSpacing = 3
    })
    
    local success, err = pcall(function()
        path:ComputeAsync(body.Position, target.Position)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypointsPath = path:GetWaypoints()
        for _, wp in ipairs(waypointsPath) do
            if not active or isChasing == false then break end
            body.CFrame = CFrame.lookAt(body.Position, wp.Position)
            local tween = TweenService:Create(body, TweenInfo.new(
                (body.Position - wp.Position).Magnitude / SPEED,
                Enum.EasingStyle.Linear
            ), { Position = wp.Position })
            tween:Play()
            tween.Completed:Wait()
        end
    else
        -- Fallback: move direto
        local dist = (body.Position - target.Position).Magnitude
        if dist < 1 then return end
        body.CFrame = CFrame.lookAt(body.Position, target.Position)
        local tween = TweenService:Create(body, TweenInfo.new(dist / SPEED, Enum.EasingStyle.Linear), {
            Position = target.Position
        })
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Patrulha normal
local function patrol()
    if #waypoints == 0 then return end
    isChasing = false
    while active and not isChasing do
        local target = waypoints[currentWP]
        if not target then currentWP = 1; target = waypoints[1] end
        moveTo(target)
        task.wait(0.5)
        currentWP = currentWP + 1
        if currentWP > #waypoints then currentWP = 1 end
    end
end

-- Perseguir jogador
local function chasePlayer(player)
    isChasing = true
    while active and isChasing do
        local char = player.Character
        if not char then break end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then break end
        
        local dist = (body.Position - hrp.Position).Magnitude
        
        if dist > aggroRange then
            isChasing = false
            break
        end
        
        if dist <= attackRange then
            -- Ataca o jogador
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:TakeDamage(damage)
            end
            task.wait(1)
        else
            moveTo(hrp)
        end
        task.wait(0.5)
    end
    isChasing = false
    task.spawn(patrol)
end

-- Detector de jogadores
task.spawn(function()
    while active do
        task.wait(1.5)
        if isChasing then continue end
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (body.Position - hrp.Position).Magnitude
                    if dist < aggroRange then
                        if not isChasing then
                            task.spawn(function() chasePlayer(player) end)
                        end
                        break
                    end
                end
            end
        end
    end
end)

-- Iniciar
if #waypoints > 0 then
    print("⚠️ " .. nome .. " patrulhando! (" .. #waypoints .. " pontos)")
    task.spawn(patrol)
else
    warn("⚠️ " .. nome .. " sem waypoints. Crie RotaInimigo" .. numero)
end