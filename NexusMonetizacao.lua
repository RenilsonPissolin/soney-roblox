-- NexusMonetizacao (Script) — Gamepasses e Holo-Estandes
-- Colocar em: ServerScriptService > NexusMonetizacao

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

-- ─── GAMEPASSES ────────────────────────────────────────────────

local GAMEPASSES = {
    radar = { id = 3708120780, name = "Radar Térmico",    desc = "Veja inimigos e relíquias no mapa" },
    moto =  { id = 3708120781, name = "Moto de Exploração", desc = "Movimento 2x mais rápido" },
    pet =   { id = 3708120782, name = "Pet Robótico",     desc = "Colete itens automaticamente" },
    holo =  { id = 3708120783, name = "Holo-Estande",     desc = "Destaque sua loja com holograma" },
}

local playerGamepasses = {}

function hasGamepass(player, passId)
    local userId = tostring(player.UserId)
    if playerGamepasses[userId] and playerGamepasses[userId][passId] then
        return true
    end
    return false
end

-- Verifica gamepasses ao entrar
Players.PlayerAdded:Connect(function(player)
    local userId = tostring(player.UserId)
    playerGamepasses[userId] = {}
    
    task.wait(3)
    for _, gp in pairs(GAMEPASSES) do
        local hasPass = pcall(function()
            return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.id)
        end)
        if hasPass then
            playerGamepasses[userId][gp.id] = true
            notifyEvent:FireClient(player, {
                title = "🎮 Gamepass Ativo!",
                message = gp.name .. " — " .. gp.desc,
                duration = 4
            })
        end
    end
end)

-- Processamento de compra
local processedReceipts = _G.SoneyProcessedReceipts or {}

local function processReceipt(receiptInfo)
    if processedReceipts[receiptInfo.PurchaseId] then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
    
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    
    local productId = receiptInfo.ProductId
    
    -- Verifica se é gamepass
    for _, gp in pairs(GAMEPASSES) do
        if productId == gp.id then
            local userId = tostring(player.UserId)
            if not playerGamepasses[userId] then
                playerGamepasses[userId] = {}
            end
            playerGamepasses[userId][gp.id] = true
            processedReceipts[receiptInfo.PurchaseId] = true
            
            notifyEvent:FireClient(player, {
                title = "🎉 " .. gp.name .. " Adquirido!",
                message = gp.desc,
                duration = 5
            })
            
            print("💰 [Nexus] " .. player.Name .. " comprou " .. gp.name)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end
    
    -- Verifica se é pacote de BC
    local bcPackages = {
        [3708120760] = 100,
        [3708120761] = 500,
        [3708120762] = 2000,
        [3708120763] = 10000,
    }
    
    local bcAmount = bcPackages[productId]
    if bcAmount then
        local addBC = _G.NexusAddBC
        if addBC then
            addBC(player, bcAmount, "Pacote de BC adquirido!")
            processedReceipts[receiptInfo.PurchaseId] = true
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end
    
    return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = processReceipt

_G.NexusHasGamepass = hasGamepass

print("✅ [NexusMonetizacao] Sistema de Gamepasses ativo!")