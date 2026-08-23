-- BossTitan (Script) — CHEFE: Titã Esmeralda (5 Fases)
-- Colocar dentro do modelo do chefe em Workspace

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
local bcEvent = ReplicatedStorage:WaitForChild("BCEvent")

-- ─── CONFIGURAÇÃO ──────────────────────────────────────────────

local boss = script.Parent
local core = boss:WaitForChild("Core")            -- Parte central do boss
local healthBar = boss:WaitForChild("HealthBar")   -- Barra de vida visível

local MAX_HEALTH = 5000
local currentHealth = MAX_HEALTH
local currentPhase = 1
local active = true
local playersInFight = {}

-- Bulbos (partes destrutíveis) — 5 fases, cada fase tem 1 bulbo
local bulbs = {}
for i = 1, 5 do
    local bulb = boss:FindFirstChild("Bulbo" .. i)
    if bulb then
        table.insert(bulbs, bulb)
    end
end

-- ─── RECOMPENSAS POR FASE ──────────────────────────────────────

local PHASE_REWARDS = {
    { fase = 1, hp = 4000, recompensa = 50,  item = "Fragmento de Cristal" },
    { fase = 2, hp = 3000, recompensa = 100, item = "Gema Mutante" },
    { fase = 3, hp = 2000, recompensa = 200, item = "Núcleo de Titã" },
    { fase = 4, hp = 1000, recompensa = 350, item = "Essência Verde" },
    { fase = 5, hp = 0,    recompensa = 1000, item = "ITENS LENDÁRIOS 💎" },
}

-- ─── ATUALIZAR VIDA ────────────────────────────────────────────

local function updateHealthBar()
    local percent = currentHealth / MAX_HEALTH
    healthBar.Size = UDim2.new(percent, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(
        255 * (1 - percent),
        50 + (200 * percent),
        50
    )
end

-- ─── AVANÇAR FASE ──────────────────────────────────────────────

local function advancePhase()
    if currentPhase > 5 then return end
    
    local phase = PHASE_REWARDS[currentPhase]
    
    -- Anuncia a fase
    for _, player in ipairs(Players:GetPlayers()) do
        notifyEvent:FireClient(player, {
            title = "🌿 FASE " .. currentPhase .. " — " .. phase.item,
            message = "Bulbo destruído! " .. phase.recompensa .. " BC liberados para todos!",
            duration = 5
        })
    end
    
    -- Dá recompensa para todos no raio
    for _, player in ipairs(playersInFight) do
        local addBC = _G.NexusAddBC
        if addBC then
            addBC(player, phase.recompensa, "Fase " .. currentPhase .. " do Boss!")
        end
    end
    
    currentPhase = currentPhase + 1
    
    if currentPhase > 5 then
        -- Boss derrotado!
        for _, player in ipairs(Players:GetPlayers()) do
            notifyEvent:FireClient(player, {
                title = "🏆 TITÃ ESMERALDA DERROTADO!",
                message = "O tesouro foi liberado! Voltem amanhã para um novo ciclo.",
                duration = 8
            })
        end
        boss:Destroy() -- Remove o boss (renasce depois)
    end
end

-- ─── DETECTAR DANO NOS BULBOS ─────────────────────────────────

for i, bulb in ipairs(bulbs) do
    local hp = Instance.new("IntValue")
    hp.Name = "BulboHP"
    hp.Value = 1000  -- Cada bulbo tem 1000 HP
    hp.Parent = bulb
    
    bulb.Touched:Connect(function(hit)
        if not active then return end
        local character = hit.Parent
        if not character then return end
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end
        
        -- Adiciona jogador à luta
        if not table.find(playersInFight, player) then
            table.insert(playersInFight, player)
        end
        
        -- Dano no bulbo
        local bulboHP = bulb:FindFirstChild("BulboHP")
        if bulboHP then
            bulboHP.Value = bulboHP.Value - 10
            
            if bulboHP.Value <= 0 then
                -- Bulbo destruído!
                local tween = TweenService:Create(bulb, TweenInfo.new(0.5), {
                    Transparency = 1
                })
                tween:Play()
                bulb:Destroy()
                advancePhase()
            end
        end
    end)
end

-- ─── ATAQUE DO BOSS (AOE) ──────────────────────────────────────

task.spawn(function()
    while active do
        task.wait(5 + math.random(0, 3))
        
        -- A cada 5-8 segundos, o boss ataca jogadores próximos
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (core.Position - hrp.Position).Magnitude
                    if dist < 30 then
                        -- Cria um ataque visual (parte do boss brilha)
                        local attackTween = TweenService:Create(core, TweenInfo.new(0.3), {
                            Color = Color3.fromRGB(0, 255, 100)
                        })
                        attackTween:Play()
                        task.wait(0.3)
                        
                        -- Dano nos jogadores próximos
                        for _, p in ipairs(Players:GetPlayers()) do
                            local c = p.Character
                            if c then
                                local h = c:FindFirstChild("Humanoid")
                                if h then
                                    local dist2 = (core.Position - h.Parent:FindFirstChild("HumanoidRootPart").Position).Magnitude
                                    if dist2 < 30 then
                                        h:TakeDamage(15)
                                    end
                                end
                            end
                        end
                        
                        -- Volta ao normal
                        local resetTween = TweenService:Create(core, TweenInfo.new(0.3), {
                            Color = Color3.fromRGB(0, 100, 50)
                        })
                        resetTween:Play()
                    end
                end
            end
        end
    end
end)

-- ─── RENASCER DO BOSS ──────────────────────────────────────────

task.spawn(function()
    while true do
        task.wait(3600)  -- 1 hora
        if not boss.Parent then
            -- O boss foi destruído, recria
            local novoBoss = boss:Clone()
            novoBoss.Parent = workspace
            novoBoss:FindFirstChild("Core").Position = Vector3.new(0, 50, 0)  -- Centro do mapa
            print("🌿 [Boss] Titã Esmeralda renasceu!")
        end
    end
end)

print("🌿 [Boss] Titã Esmeralda ativa — " .. #bulbs .. " bulbos, 5 fases!")