-- SoneyClientUI (LocalScript)
-- Colocar em: StarterGui > SoneyClientUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

-- Cria o frame de notificação
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoneyNotificationGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local notificationFrame = Instance.new("Frame")
notificationFrame.Name = "NotificationFrame"
notificationFrame.Size = UDim2.new(0, 350, 0, 80)
notificationFrame.Position = UDim2.new(0.5, -175, 0, -100)
notificationFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
notificationFrame.BackgroundTransparency = 0.15
notificationFrame.BorderSizePixel = 0
notificationFrame.Parent = screenGui

-- Cantos arredondados
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = notificationFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -20, 0, 25)
titleLabel.Position = UDim2.new(0, 10, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 50, 100)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = notificationFrame

-- Mensagem
local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "MessageLabel"
messageLabel.Size = UDim2.new(1, -20, 0, 40)
messageLabel.Position = UDim2.new(0, 10, 0, 35)
messageLabel.BackgroundTransparency = 1
messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
messageLabel.Font = Enum.Font.Gotham
messageLabel.TextSize = 14
messageLabel.TextWrapped = true
messageLabel.TextXAlignment = Enum.TextXAlignment.Left
messageLabel.Parent = notificationFrame

-- Animação
function showNotification(title, message, duration)
    titleLabel.Text = title
    messageLabel.Text = message
    
    notificationFrame.Position = UDim2.new(0.5, -175, 0, -100)
    notificationFrame.BackgroundTransparency = 0.15
    
    -- Entrada
    local enterTween = TweenService:Create(notificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -175, 0, 30),
        BackgroundTransparency = 0.05
    })
    enterTween:Play()
    
    -- Saída
    task.wait(duration)
    
    local exitTween = TweenService:Create(notificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -175, 0, -100),
        BackgroundTransparency = 0.15
    })
    exitTween:Play()
end

notifyEvent.OnClientEvent:Connect(function(data)
    showNotification(data.title, data.message, data.duration)
end)

print("✅ [Soney] UI do cliente carregada!")