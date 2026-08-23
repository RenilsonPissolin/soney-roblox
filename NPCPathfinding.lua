-- NPCPathfinding (Script) — Sem HologramBody
-- Colocar dentro do Model SoneyNPC no Workspace

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local npc = script.Parent
local prompt = npc:WaitForChild("ProximityPrompt")

-- Pega a primeira parte do modelo (qualquer parte serve como referência)
local primaryPart = npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")
if not primaryPart then
    warn("⚠️ [NPC] Nenhuma parte encontrada no modelo! Crie uma Part dentro de SoneyNPC.")
    return
end

-- ─── CONFIGURAÇÃO ──────────────────────────────────────────────

local PATROL_SPEED = 6
local FOLLOW_RANGE = 15
local STOP_FOLLOW_RANGE = 25
local WAYPOINT_WAIT = 3

-- Busca waypoints
local waypoints = {}
local wpFolder = workspace:FindFirstChild("SoneyWaypoints")
if wpFolder then
    for _, child in ipairs(wpFolder:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(waypoints, child)
        end
    end
end

local currentWaypoint = 1
local currentTarget = nil  -- "patrol", "follow", "interact"

-- ─── MOVER ─────────────────────────────────────────────────────

local function moveTo(targetPos)
    if not primaryPart then return end
    
    local dist = (primaryPart.Position - targetPos).Magnitude
    if dist < 1 then return end
    
    -- Olha na direção
    primaryPart.CFrame = CFrame.lookAt(primaryPart.Position, targetPos)
    
    -- Move
    local tween = TweenService:Create(primaryPart, TweenInfo.new(
        dist / PATROL_SPEED, Enum.EasingStyle.Linear
    ), {
        Position = Vector3.new(targetPos.X, primaryPart.Position.Y, targetPos.Z)
    })
    tween:Play()
    tween.Completed:Wait()
end

-- ─── PATRULHA ──────────────────────────────────────────────────

local function patrol()
    if #waypoints == 0 then
        warn("⚠️ [NPC] Crie waypoints em Workspace > SoneyWaypoints")
        return
    end
    
    currentTarget = "patrol"
    print("🚶 [NPC] Iniciando patrulha com " .. #waypoints .. " waypoints")
    
    while currentTarget == "patrol" do
        local target = waypoints[currentWaypoint]
        if not target then
            currentWaypoint = 1
            target = waypoints[1]
        end
        
        moveTo(target.Position)
        task.wait(WAYPOINT_WAIT)
        
        currentWaypoint += 1
        if currentWaypoint > #waypoints then
            currentWaypoint = 1
        end
        
        checkForPlayers()
    end
end

-- ─── SEGUIR JOGADOR ────────────────────────────────────────────

local function checkForPlayers()
    if currentTarget ~= "patrol" or not primaryPart then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (primaryPart.Position - hrp.Position).Magnitude
                if dist < FOLLOW_RANGE then
                    currentTarget = "follow"
                    task.spawn(function() followPlayer(player) end)
                    return
                end
            end
        end
    end
end

local function followPlayer(targetPlayer)
    print("👣 [NPC] Seguindo " .. targetPlayer.Name)
    
    while currentTarget == "follow" and primaryPart do
        local char = targetPlayer.Character
        if not char then break end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then break end
        
        local dist = (primaryPart.Position - hrp.Position).Magnitude
        
        if dist > STOP_FOLLOW_RANGE then
            currentTarget = "patrol"
            break
        end
        
        if dist > 5 then
            moveTo(hrp.Position)
        end
        
        task.wait(1)
    end
    
    if currentTarget == "patrol" then
        task.spawn(patrol)
    end
end

-- ─── VERIFICAR JOGADORES ───────────────────────────────────────

task.spawn(function()
    while true do
        task.wait(3)
        checkForPlayers()
    end
end)

-- ─── INTERAÇÃO ─────────────────────────────────────────────────

prompt.Triggered:Connect(function(player)
    currentTarget = "interact"
    
    -- Olha para o jogador
    if primaryPart then
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                primaryPart.CFrame = CFrame.lookAt(primaryPart.Position, hrp.Position)
            end
        end
    end
    
    -- Dispara a Soney
    local notifyEvent = game:GetService("ReplicatedStorage"):FindFirstChild("SoneyNotifyEvent")
    if notifyEvent then
        notifyEvent:FireClient(player, {
            title = "SHOW_SONEY",
            lines = {
                { text = "🎬 Olá! Eu sou a SONEY.", speed = 0.04 },
                { text = "Aperte V para votar!", speed = 0.035 },
            }
        })
    end
    
    task.wait(5)
    currentTarget = "patrol"
    task.spawn(patrol)
end)

-- ─── INICIAR ───────────────────────────────────────────────────

if #waypoints > 0 then
    print("✅ [NPC] Soney patrol ativo!")
    task.spawn(patrol)
else
    print("⏸️ [NPC] Sem waypoints. Crie em Workspace > SoneyWaypoints")
end