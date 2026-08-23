-- NexusHUD (LocalScript) — Interface do Nexus
-- Colocar em: StarterGui > NexusHUD

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local bcEvent = ReplicatedStorage:WaitForChild("BCEvent")

-- ─── CRIAR GUI ─────────────────────────────────────────────────

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NexusHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Painel de Bio-Créditos (canto superior direito)
local bcPanel = Instance.new("Frame")
bcPanel.Name = "BCPanel"
bcPanel.Size = UDim2.new(0, 200, 0, 50)
bcPanel.Position = UDim2.new(1, -220, 0, 10)
bcPanel.BackgroundColor3 = Color3.fromRGB(5, 5, 20)
bcPanel.BackgroundTransparency = 0.2
bcPanel.BorderSizePixel = 0
bcPanel.Parent = screenGui

local bcCorner = Instance.new("UICorner")
bcCorner.CornerRadius = UDim.new(0, 10)
bcCorner.Parent = bcPanel

local bcStroke = Instance.new("UIStroke")
bcStroke.Color = Color3.fromRGB(0, 200, 255)
bcStroke.Thickness = 1.5
bcStroke.Transparency = 0.5
bcStroke.Parent = bcPanel

-- Ícone BC
local bcIcon = Instance.new("TextLabel")
bcIcon.Size = UDim2.new(0, 30, 0, 30)
bcIcon.Position = UDim2.new(0, 10, 0, 10)
bcIcon.BackgroundTransparency = 1
bcIcon.Text = "💎"
bcIcon.TextSize = 20
bcIcon.Parent = bcPanel

-- Label "Bio-Créditos"
local bcLabel = Instance.new("TextLabel")
bcLabel.Size = UDim2.new(0, 100, 0, 15)
bcLabel.Position = UDim2.new(0, 45, 0, 5)
bcLabel.BackgroundTransparency = 1
bcLabel.Text = "BIO-CRÉDITOS"
bcLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
bcLabel.TextSize = 10
bcLabel.Font = Enum.Font.GothamBold
bcLabel.TextXAlignment = Enum.TextXAlignment.Left
bcLabel.Parent = bcPanel

-- Valor dos BCs
local bcValue = Instance.new("TextLabel")
bcValue.Name = "BCValue"
bcValue.Size = UDim2.new(0, 100, 0, 20)
bcValue.Position = UDim2.new(0, 45, 0, 20)
bcValue.BackgroundTransparency = 1
bcValue.Text = "0"
bcValue.TextColor3 = Color3.fromRGB(255, 255, 255)
bcValue.TextSize = 16
bcValue.Font = Enum.Font.GothamBold
bcValue.TextXAlignment = Enum.TextXAlignment.Left
bcValue.Parent = bcPanel

-- ─── ATUALIZAR BC NA TELA ──────────────────────────────────────

local function updateBCDisplay()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local bc = leaderstats:FindFirstChild("BioCreditos")
        if bc then
            bcValue.Text = tostring(bc.Value)
        end
        local nivel = leaderstats:FindFirstChild("Nivel")
        if nivel then
            -- Opcional: mostrar nível no painel
        end
    end
end

-- Atualiza quando o leaderstats mudar
local function onLeaderstatsChanged()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local bc = leaderstats:FindFirstChild("BioCreditos")
        if bc then
            bc.Changed:Connect(function()
                bcValue.Text = tostring(bc.Value)
            end)
        end
    end
end

player:WaitForChild("leaderstats")
onLeaderstatsChanged()
updateBCDisplay()

-- ─── NOTIFICAÇÃO DE EVENTO ─────────────────────────────────────

local notifyEvent = ReplicatedStorage:FindFirstChild("SoneyNotifyEvent")
if notifyEvent then
    notifyEvent.OnClientEvent:Connect(function(data)
        if data.title == "SHOW_SONEY" then
            -- Abre o diálogo da Soney (se existir)
            if _G.SoneyShowDialog then
                _G.SoneyShowDialog(data.lines)
            end
        end
    end)
end

print("✅ [NexusHUD] Interface carregada!")