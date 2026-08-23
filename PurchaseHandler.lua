-- PurchaseHandler (Script)
-- Colocar em: ServerScriptService > PurchaseHandler

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("ConfigModule"))

-- Acessa o cache e a função do LeaderstatsSystem
local processedReceipts = _G.SoneyProcessedReceipts or {}
local awardCoins = _G.SoneyAwardCoins

local function processReceipt(receiptInfo)
    if processedReceipts[receiptInfo.PurchaseId] then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
    
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    
    local productId = receiptInfo.ProductId
    local awardCoins = _G.SoneyAwardCoins
    
    -- Tabela de produtos
    local products = {
        [3708120760] = 100,   -- 100 Coins
        [3708120761] = 500,   -- 500 Coins
        [3708120762] = 2000,  -- 2000 Coins
        [3708120763] = 10000, -- 10000 Coins
        [3708120770] = 0,     -- VIP Mensal (gamepass)
        [3708120771] = 0,     -- Voto Duplo (gamepass)
        [3708120772] = 0,     -- Episódios Secretos (gamepass)
        [3708120773] = 0,     -- Pacote Completo (gamepass)
    }
    
    local coins = products[productId]
    if coins and coins > 0 and awardCoins then
        awardCoins(player, coins, "purchase")
        processedReceipts[receiptInfo.PurchaseId] = true
        print("💰 [Soney] " .. player.Name .. " comprou " .. tostring(coins) .. " coins!")
        return Enum.ProductPurchaseDecision.PurchaseGranted
    elseif coins == 0 then
        -- Gamepass - ativa benefício
        if productId == 3708120770 then
            _G.SoneyActivatePass and _G.SoneyActivatePass(player)
        end
        processedReceipts[receiptInfo.PurchaseId] = true
        print("🎮 [Soney] " .. player.Name .. " comprou gamepass " .. tostring(productId))
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
    
    return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = processReceipt

print("✅ [Soney] PurchaseHandler inicializado!")