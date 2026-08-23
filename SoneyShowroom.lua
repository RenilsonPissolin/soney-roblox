-- SoneyShowroom (LocalScript)
-- Colocar em: StarterGui > SoneyShowroom
-- Cutscene de apresentação da Soney dentro do Roblox

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoneyShowroomGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ─── OVERLAY ESCURO ────────────────────────────────────────────

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.3
overlay.BorderSizePixel = 0
overlay.Visible = false
overlay.Parent = screenGui

-- ─── PAINEL DA SONEY ───────────────────────────────────────────

local mainFrame = Instance.new("Frame")
mainFrame.Name = "SoneyPanel"
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 50, 100)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

-- ─── CANTO SUPERIOR DIREITO (efeito televisão) ─────────────────

local tvGlow = Instance.new("Frame")
tvGlow.Name = "TvGlow"
tvGlow.Size = UDim2.new(0, 120, 0, 120)
tvGlow.Position = UDim2.new(1, -140, 0, 20)
tvGlow.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
tvGlow.BackgroundTransparency = 0.95
tvGlow.BorderSizePixel = 0
tvGlow.Parent = mainFrame

local tvGlowCorner = Instance.new("UICorner")
tvGlowCorner.CornerRadius = UDim.new(0, 60)
tvGlowCorner.Parent = tvGlow

-- ─── AVATAR DA SONEY (ícone) ───────────────────────────────────

local soneyIcon = Instance.new("ImageLabel")
soneyIcon.Name = "SoneyIcon"
soneyIcon.Size = UDim2.new(0, 80, 0, 80)
soneyIcon.Position = UDim2.new(0, 30, 0, 25)
soneyIcon.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
soneyIcon.BackgroundTransparency = 0.3
soneyIcon.BorderSizePixel = 0
soneyIcon.Parent = mainFrame

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 40)
iconCorner.Parent = soneyIcon

-- Placeholder: se tiver uma imagem, coloca aqui
-- soneyIcon.Image = "rbxassetid://SUA_IMAGEM_SONEY"

-- ─── NOME DA SONEY ─────────────────────────────────────────────

local soneyName = Instance.new("TextLabel")
soneyName.Name = "SoneyName"
soneyName.Size = UDim2.new(0, 200, 0, 25)
soneyName.Position = UDim2.new(0, 120, 0, 30)
soneyName.BackgroundTransparency = 1
soneyName.Text = "🎬 SONEY"
soneyName.TextColor3 = Color3.fromRGB(255, 50, 100)
soneyName.TextSize = 22
soneyName.Font = Enum.Font.GothamBold
soneyName.TextXAlignment = Enum.TextXAlignment.Left
soneyName.Parent = mainFrame

local soneyTitle = Instance.new("TextLabel")
soneyTitle.Name = "SoneyTitle"
soneyTitle.Size = UDim2.new(0, 200, 0, 20)
soneyTitle.Position = UDim2.new(0, 120, 0, 55)
soneyTitle.BackgroundTransparency = 1
soneyTitle.Text = "Diretora · Showrunner · IA"
soneyTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
soneyTitle.TextSize = 13
soneyTitle.Font = Enum.Font.Gotham
soneyTitle.TextXAlignment = Enum.TextXAlignment.Left
soneyTitle.Parent = mainFrame

-- ─── LINHA DIVISÓRIA ───────────────────────────────────────────

local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.Size = UDim2.new(1, -60, 0, 1)
divider.Position = UDim2.new(0, 30, 0, 115)
divider.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
divider.BackgroundTransparency = 0.6
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- ─── CAIXA DE DIÁLOGO ──────────────────────────────────────────

local dialogBox = Instance.new("Frame")
dialogBox.Name = "DialogBox"
dialogBox.Size = UDim2.new(1, -60, 0, 150)
dialogBox.Position = UDim2.new(0, 30, 0, 130)
dialogBox.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
dialogBox.BackgroundTransparency = 0.2
dialogBox.BorderSizePixel = 0
dialogBox.ClipsDescendants = true
dialogBox.Parent = mainFrame

local dialogCorner = Instance.new("UICorner")
dialogCorner.CornerRadius = UDim.new(0, 12)
dialogCorner.Parent = dialogBox

-- Indicador "gravando"
local recordingDot = Instance.new("Frame")
recordingDot.Name = "RecordingDot"
recordingDot.Size = UDim2.new(0, 8, 0, 8)
recordingDot.Position = UDim2.new(0, 12, 0, 12)
recordingDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
recordingDot.BorderSizePixel = 0
recordingDot.Parent = dialogBox

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(0, 4)
dotCorner.Parent = recordingDot

-- Texto do diálogo
local dialogText = Instance.new("TextLabel")
dialogText.Name = "DialogText"
dialogText.Size = UDim2.new(1, -30, 1, -30)
dialogText.Position = UDim2.new(0, 15, 0, 15)
dialogText.BackgroundTransparency = 1
dialogText.Text = ""
dialogText.TextColor3 = Color3.fromRGB(230, 230, 255)
dialogText.TextSize = 16
dialogText.Font = Enum.Font.Gotham
dialogText.TextWrapped = true
dialogText.TextXAlignment = Enum.TextXAlignment.Left
dialogText.TextYAlignment = Enum.TextYAlignment.Top
dialogText.RichText = true
dialogText.Parent = dialogBox

-- ─── BOTÃO DE AÇÃO ─────────────────────────────────────────────

local actionButton = Instance.new("TextButton")
actionButton.Name = "ActionButton"
actionButton.Size = UDim2.new(0, 200, 0, 45)
actionButton.Position = UDim2.new(0.5, -100, 1, -70)
actionButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
actionButton.BackgroundTransparency = 0.15
actionButton.BorderSizePixel = 0
actionButton.Text = "▶ CONTINUAR"
actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
actionButton.TextSize = 16
actionButton.Font = Enum.Font.GothamBold
actionButton.Visible = false
actionButton.Parent = mainFrame

local actionCorner = Instance.new("UICorner")
actionCorner.CornerRadius = UDim.new(0, 12)
actionCorner.Parent = actionButton

-- ─── SISTEMA DE DIÁLOGO ────────────────────────────────────────

local dialogLines = {}
local currentLine = 0
local isTyping = false
local typingConnection = nil

-- Recebe as falas
function showSoneyDialog(lines)
    overlay.Visible = true
    mainFrame.Visible = true
    currentLine = 0
    dialogLines = lines
    actionButton.Visible = true
    actionButton.Text = "▶ PRÓXIMO"
    nextLine()
end

function nextLine()
    if currentLine >= #dialogLines then
        -- Fim do diálogo
        actionButton.Text = "🎬 IR PARA VOTAÇÃO"
        actionButton.MouseButton1Click:Connect(function()
            closeSoneyDialog()
            -- Abre o painel de votação
            if _G.SoneyOpenVote then
                _G.SoneyOpenVote()
            end
        end)
        return
    end
    
    currentLine += 1
    local line = dialogLines[currentLine]
    
    -- Efeito de digitação
    if typingConnection then
        typingConnection:Disconnect()
    end
    
    dialogText.Text = ""
    local fullText = line.text or ""
    local charIndex = 0
    local typeSpeed = line.speed or 0.03
    
    isTyping = true
    actionButton.Text = "⏳"
    actionButton.Visible = false
    
    typingConnection = game:GetService("RunService").Stepped:Connect(function()
        if charIndex < #fullText then
            charIndex += 1
            dialogText.Text = string.sub(fullText, 1, charIndex)
        else
            typingConnection:Disconnect()
            isTyping = false
            actionButton.Visible = true
            if currentLine >= #dialogLines then
                actionButton.Text = "🎬 IR PARA VOTAÇÃO"
            else
                actionButton.Text = "▶ PRÓXIMO"
            end
        end
    end)
end

function closeSoneyDialog()
    if typingConnection then
        typingConnection:Disconnect()
    end
    mainFrame.Visible = false
    overlay.Visible = false
    actionButton.MouseButton1Click:Disconnect()
end

-- Botão de ação
actionButton.MouseButton1Click:Connect(function()
    if isTyping then
        -- Pular digitação
        if typingConnection then
            typingConnection:Disconnect()
        end
        isTyping = false
        local line = dialogLines[currentLine]
        dialogText.Text = line.text or ""
        actionButton.Visible = true
        if currentLine >= #dialogLines then
            actionButton.Text = "🎬 IR PARA VOTAÇÃO"
        else
            actionButton.Text = "▶ PRÓXIMO"
        end
    else
        nextLine()
    end
end)

-- ─── FUNÇÃO PÚBLICA PARA ABRIR A SONEY ─────────────────────────

function _G.SoneyShowDialog(customLines)
    local lines = customLines or {
        { text = "🎬 Olá, jogador! Eu sou a SONEY.", speed = 0.04 },
        { text = "Sou a diretora de cinema digital deste universo. Cada escolha sua muda a história.", speed = 0.03 },
        { text = "Aqui, você não é só um espectador — você é o ROTEIRISTA.", speed = 0.03 },
        { text = "Cada voto decide o destino dos personagens. Cada episódio é seu.", speed = 0.03 },
        { text = "O Último Andar está prestes a começar... e você já tem uma decisão a tomar.", speed = 0.035 },
        { text = "Clara está diante de uma porta trancada no 13º andar. O que ela deve fazer?", speed = 0.035 },
        { text = "Abra a porta e descubra a verdade... ou finja que não viu nada e vá embora.", speed = 0.035 },
        { text = "A escolha é sua. VOTE AGORA. 🎬🔥", speed = 0.05 },
    }
    showSoneyDialog(lines)
end

-- Evento para abrir quando o jogador entrar
player:WaitForChild("PlayerGui")
task.wait(3)

-- Mostra a Soney automaticamente na primeira vez
local hasSeenSoney = false
local soneyData = player:FindFirstChild("SoneyFirstTime")
if not soneyData then
    hasSeenSoney = true
    local value = Instance.new("BoolValue")
    value.Name = "SoneyFirstTime"
    value.Parent = player
end

if hasSeenSoney then
    _G.SoneyShowDialog()
end

-- Conexão com o RemoteEvent para chamar de qualquer lugar
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")
notifyEvent.OnClientEvent:Connect(function(data)
    if data and data.title == "SHOW_SONEY" then
        _G.SoneyShowDialog(data.lines)
    end
end)

print("✅ [SoneyShowroom] Soney pronta para aparecer! 🎬")