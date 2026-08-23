-- FerramentasMineracao (Script) — Sistema de ferramentas de escavação
-- Colocar em: ServerScriptService > FerramentasMineracao

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

-- ─── FERRAMENTAS DISPONÍVEIS ────────────────────────────────────

local FERRAMENTAS = {
    { nome = "Pá Oxidada",     nivel = 1, dano = 5,  alcance = 5,  bc = 0 },
    { nome = "Martelo de Ferro", nivel = 2, dano = 10, alcance = 6,  bc = 200 },
    { nome = "Picareta de Bronze", nivel = 3, dano = 20, alcance = 7,  bc = 500 },
    { nome = "Furadeira de Plasma", nivel = 4, dano = 40, alcance = 8,  bc = 1500 },
    { nome = "Lança-Chamas Iônico", nivel = 5, dano = 80, alcance = 10, bc = 4000 },
    { nome = "Destruidor Quântico", nivel = 6, dano = 150, alcance = 12, bc = 10000 },
}

function getFerramenta(player)
    local data = _G.NexusGetData and _G.NexusGetData(player)
    if not data then return FERRAMENTAS[1] end
    
    for _, f in ipairs(FERRAMENTAS) do
        if f.nome == data.ferramenta then
            return f
        end
    end
    return FERRAMENTAS[1]
end

function upgradeFerramenta(player)
    local data = _G.NexusGetData and _G.NexusGetData(player)
    if not data then return false, "Erro ao carregar dados" end
    
    local atual = getFerramenta(player)
    local proximoNivel = atual.nivel + 1
    if proximoNivel > #FERRAMENTAS then
        return false, "Você já está no nível máximo!"
    end
    
    local proxima = FERRAMENTAS[proximoNivel]
    local custo = proxima.bc
    
    if data.bc < custo then
        return false, "Você precisa de " .. custo .. " BC. Tem apenas " .. data.bc
    end
    
    -- Remove BC e atualiza ferramenta
    _G.NexusRemoveBC(player, custo, "Upgrade: " .. proxima.nome)
    data.ferramenta = proxima.nome
    
    -- Atualiza leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local f = leaderstats:FindFirstChild("Ferramenta")
        if f then f.Value = proxima.nome end
    end
    
    notifyEvent:FireClient(player, {
        title = "🔧 FERRAMENTA UPGRADED!",
        message = proxima.nome .. " — Dano: " .. proxima.dano,
        duration = 5
    })
    
    return true, proxima.nome
end

-- Evento
local toolEvent = Instance.new("RemoteEvent")
toolEvent.Name = "ToolEvent"
toolEvent.Parent = ReplicatedStorage

toolEvent.OnServerEvent:Connect(function(player, action)
    if action == "upgrade" then
        local success, msg = upgradeFerramenta(player)
        toolEvent:FireClient(player, "upgradeResult", success, msg)
    elseif action == "getInfo" then
        local f = getFerramenta(player)
        toolEvent:FireClient(player, "toolInfo", f)
    end
end)

_G.NexusGetFerramenta = getFerramenta

print("✅ [Ferramentas] Sistema de mineração ativo!")