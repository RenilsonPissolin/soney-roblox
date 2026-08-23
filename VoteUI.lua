-- VoteUI (LocalScript)
-- Colocar em: StarterGui > VoteUI
-- Interface interativa de votação para os dramas Soney

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local EpisodeService = require(ReplicatedStorage:WaitForChild("EpisodeService"))
local notifyEvent = ReplicatedStorage:WaitForChild("SoneyNotifyEvent")

-- ─── Criação da GUI ─────────────────────────────────────────────

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoneyVoteGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ─── Botão Flutuante ────────────────────────────────────────────

local voteButton = Instance.new("ImageButton")
voteButton.Name = "VoteButton"
voteButton.Size = UDim2.new(0, 60, 0, 60)
voteButton.Position = UDim2.new(0.5, -30, 1, -90)
voteButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
voteButton.BackgroundTransparency = 0.1
voteButton.BorderSizePixel = 0
voteButton.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 30)
btnCorner.Parent = voteButton

local btnLabel = Instance.new("TextLabel")
btnLabel.Name = "BtnLabel"
btnLabel.Size = UDim2.new(1, 0, 1, 0)
btnLabel.BackgroundTransparency = 1
btnLabel.Text = "🎬"
btnLabel.TextSize = 28
btnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLabel.Font = Enum.Font.GothamBold
btnLabel.Parent = voteButton

-- Sombra do botão
local btnShadow = Instance.new("ImageLabel")
btnShadow.Name = "BtnShadow"
btnShadow.Size = UDim2.new(1, 10, 1, 10)
btnShadow.Position = UDim2.new(0, -5, 0, -5)
btnShadow.BackgroundTransparency = 1
btnShadow.Image = "rbxassetid://6015897843"
btnShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
btnShadow.ImageTransparency = 0.8
btnShadow.Parent = voteButton

-- Tooltip
local tooltip = Instance.new("TextLabel")
tooltip.Name = "Tooltip"
tooltip.Size = UDim2.new(0, 140, 0, 30)
tooltip.Position = UDim2.new(0, -70, 0, -40)
tooltip.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
tooltip.BackgroundTransparency = 0.2
tooltip.Text = "🎭 Votar no Drama!"
tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
tooltip.TextSize = 13
tooltip.Font = Enum.Font.Gotham
tooltip.TextWrapped = true
tooltip.BorderSizePixel = 0
tooltip.Visible = false
tooltip.Parent = voteButton

local tooltipCorner = Instance.new("UICorner")
tooltipCorner.CornerRadius = UDim.new(0, 8)
tooltipCorner.Parent = tooltip

-- ─── Painel de Votação ──────────────────────────────────────────

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
mainFrame.BackgroundTransparency = 0.08
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Borda sutil
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 50, 100)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.6
mainStroke.Parent = mainFrame

-- Overlay de fundo
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0
overlay.Visible = false
overlay.ZIndex = 0
overlay.Parent = screenGui

-- ─── Header ─────────────────────────────────────────────────────

local headerFrame = Instance.new("Frame")
headerFrame.Name = "HeaderFrame"
headerFrame.Size = UDim2.new(1, -30, 0, 50)
headerFrame.Position = UDim2.new(0, 15, 0, 15)
headerFrame.BackgroundTransparency = 1
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

local headerIcon = Instance.new("TextLabel")
headerIcon.Name = "HeaderIcon"
headerIcon.Size = UDim2.new(0, 40, 0, 40)
headerIcon.BackgroundTransparency = 1
headerIcon.Text = "🎭"
headerIcon.TextSize = 30
headerIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
headerIcon.Font = Enum.Font.GothamBold
headerIcon.Parent = headerFrame

local headerTitle = Instance.new("TextLabel")
headerTitle.Name = "HeaderTitle"
headerTitle.Size = UDim2.new(1, -50, 0, 25)
headerTitle.Position = UDim2.new(0, 50, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "VOTE NO DRAMA"
headerTitle.TextColor3 = Color3.fromRGB(255, 50, 100)
headerTitle.TextSize = 18
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = headerFrame

local headerSubtitle = Instance.new("TextLabel")
headerSubtitle.Name = "HeaderSubtitle"
headerSubtitle.Size = UDim2.new(1, -50, 0, 20)
headerSubtitle.Position = UDim2.new(0, 50, 0, 24)
headerSubtitle.BackgroundTransparency = 1
headerSubtitle.Text = "Decida o rumo da história!"
headerSubtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
headerSubtitle.TextSize = 13
headerSubtitle.Font = Enum.Font.Gotham
headerSubtitle.TextXAlignment = Enum.TextXAlignment.Left
headerSubtitle.Parent = headerFrame

-- Botão fechar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
closeButton.BackgroundTransparency = 0.5
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = headerFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- ─── Conteúdo do Episódio ───────────────────────────────────────

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -30, 1, -120)
contentFrame.Position = UDim2.new(0, 15, 0, 75)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local episodeTitle = Instance.new("TextLabel")
episodeTitle.Name = "EpisodeTitle"
episodeTitle.Size = UDim2.new(1, 0, 0, 30)
episodeTitle.BackgroundTransparency = 1
episodeTitle.Text = "Episódio 1"
episodeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
episodeTitle.TextSize = 20
episodeTitle.Font = Enum.Font.GothamBold
episodeTitle.TextXAlignment = Enum.TextXAlignment.Left
episodeTitle.Parent = contentFrame

local episodeHook = Instance.new("TextLabel")
episodeHook.Name = "EpisodeHook"
episodeHook.Size = UDim2.new(1, 0, 0, 50)
episodeHook.Position = UDim2.new(0, 0, 0, 35)
episodeHook.BackgroundTransparency = 1
episodeHook.Text = "Carregando..."
episodeHook.TextColor3 = Color3.fromRGB(200, 200, 220)
episodeHook.TextSize = 15
episodeHook.Font = Enum.Font.Gotham
episodeHook.TextWrapped = true
episodeHook.TextXAlignment = Enum.TextXAlignment.Left
episodeHook.TextYAlignment = Enum.TextYAlignment.Top
episodeHook.Parent = contentFrame

-- ─── Botões de Escolha ──────────────────────────────────────────

local choicesFrame = Instance.new("Frame")
choicesFrame.Name = "ChoicesFrame"
choicesFrame.Size = UDim2.new(1, 0, 0, 180)
choicesFrame.Position = UDim2.new(0, 0, 0, 95)
choicesFrame.BackgroundTransparency = 1
choicesFrame.BorderSizePixel = 0
choicesFrame.Parent = contentFrame

-- Botão A
local choiceA = Instance.new("TextButton")
choiceA.Name = "ChoiceA"
choiceA.Size = UDim2.new(1, 0, 0, 75)
choiceA.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
choiceA.BackgroundTransparency = 0.2
choiceA.BorderSizePixel = 0
choiceA.Text = ""
choiceA.Parent = choicesFrame

local choiceACorner = Instance.new("UICorner")
choiceACorner.CornerRadius = UDim.new(0, 12)
choiceACorner.Parent = choiceA

local choiceALabel = Instance.new("TextLabel")
choiceALabel.Name = "Label"
choiceALabel.Size = UDim2.new(1, -20, 1, 0)
choiceALabel.Position = UDim2.new(0, 15, 0, 0)
choiceALabel.BackgroundTransparency = 1
choiceALabel.Text = "A) Opção A"
choiceALabel.TextColor3 = Color3.fromRGB(255, 255, 255)
choiceALabel.TextSize = 16
choiceALabel.Font = Enum.Font.GothamBold
choiceALabel.TextXAlignment = Enum.TextXAlignment.Left
choiceALabel.TextWrapped = true
choiceALabel.Parent = choiceA

-- Barra de resultado A
local resultBarA = Instance.new("Frame")
resultBarA.Name = "ResultBar"
resultBarA.Size = UDim2.new(0, 0, 0, 6)
resultBarA.Position = UDim2.new(0, 15, 1, -12)
resultBarA.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
resultBarA.BorderSizePixel = 0
resultBarA.Visible = false
resultBarA.Parent = choiceA

local resultBarACorner = Instance.new("UICorner")
resultBarACorner.CornerRadius = UDim.new(0, 3)
resultBarACorner.Parent = resultBarA

local resultALabel = Instance.new("TextLabel")
resultALabel.Name = "ResultLabel"
resultALabel.Size = UDim2.new(0, 50, 0, 20)
resultALabel.Position = UDim2.new(1, -60, 0, 0)
resultALabel.BackgroundTransparency = 1
resultALabel.Text = "0%"
resultALabel.TextColor3 = Color3.fromRGB(255, 255, 255)
resultALabel.TextSize = 14
resultALabel.Font = Enum.Font.GothamBold
resultALabel.TextXAlignment = Enum.TextXAlignment.Right
resultALabel.Visible = false
resultALabel.Parent = choiceA

-- Botão B
local choiceB = Instance.new("TextButton")
choiceB.Name = "ChoiceB"
choiceB.Size = UDim2.new(1, 0, 0, 75)
choiceB.Position = UDim2.new(0, 0, 0, 90)
choiceB.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
choiceB.BackgroundTransparency = 0.2
choiceB.BorderSizePixel = 0
choiceB.Text = ""
choiceB.Parent = choicesFrame

local choiceBCorner = Instance.new("UICorner")
choiceBCorner.CornerRadius = UDim.new(0, 12)
choiceBCorner.Parent = choiceB

local choiceBLabel = Instance.new("TextLabel")
choiceBLabel.Name = "Label"
choiceBLabel.Size = UDim2.new(1, -20, 1, 0)
choiceBLabel.Position = UDim2.new(0, 15, 0, 0)
choiceBLabel.BackgroundTransparency = 1
choiceBLabel.Text = "B) Opção B"
choiceBLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
choiceBLabel.TextSize = 16
choiceBLabel.Font = Enum.Font.GothamBold
choiceBLabel.TextXAlignment = Enum.TextXAlignment.Left
choiceBLabel.TextWrapped = true
choiceBLabel.Parent = choiceB

-- Barra de resultado B
local resultBarB = Instance.new("Frame")
resultBarB.Name = "ResultBar"
resultBarB.Size = UDim2.new(0, 0, 0, 6)
resultBarB.Position = UDim2.new(0, 15, 1, -12)
resultBarB.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
resultBarB.BorderSizePixel = 0
resultBarB.Visible = false
resultBarB.Parent = choiceB

local resultBarBCorner = Instance.new("UICorner")
resultBarBCorner.CornerRadius = UDim.new(0, 3)
resultBarBCorner.Parent = resultBarB

local resultBLabel = Instance.new("TextLabel")
resultBLabel.Name = "ResultLabel"
resultBLabel.Size = UDim2.new(0, 50, 0, 20)
resultBLabel.Position = UDim2.new(1, -60, 0, 0)
resultBLabel.BackgroundTransparency = 1
resultBLabel.Text = "0%"
resultBLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
resultBLabel.TextSize = 14
resultBLabel.Font = Enum.Font.GothamBold
resultBLabel.TextXAlignment = Enum.TextXAlignment.Right
resultBLabel.Visible = false
resultBLabel.Parent = choiceB

-- ─── Loading / Status ───────────────────────────────────────────

local loadingLabel = Instance.new("TextLabel")
loadingLabel.Name = "LoadingLabel"
loadingLabel.Size = UDim2.new(1, 0, 0, 30)
loadingLabel.Position = UDim2.new(0, 0, 0, 100)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Text = "⏳ Carregando episódio..."
loadingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
loadingLabel.TextSize = 14
loadingLabel.Font = Enum.Font.Gotham
loadingLabel.Visible = false
loadingLabel.Parent = contentFrame

-- ─── Estados ────────────────────────────────────────────────────

local STATE = {
    IDLE = 1,
    LOADING = 2,
    READY = 3,
    VOTED = 4,
    ERROR = 5
}
local currentState = STATE.IDLE
local hasVoted = false
local currentEpisode = nil

-- ─── Animações ──────────────────────────────────────────────────

function animateIn(frame)
    frame.Visible = true
    frame.BackgroundTransparency = 0.1
    frame.Position = UDim2.new(0.5, -200, 0.5, -250)
    
    local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.08
    })
    tween:Play()
end

function animateOut(frame, callback)
    local tween = TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })
    tween.Completed:Connect(function()
        frame.Visible = false
        if callback then callback() end
    end)
    tween:Play()
end

function pulseButton(button)
    local tween = TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
        Size = UDim2.new(0, button.Size.X.Offset + 5, 0, button.Size.Y.Offset + 5)
    })
    local tween2 = TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
        Size = UDim2.new(0, button.Size.X.Offset - 5, 0, button.Size.Y.Offset - 5)
    })
    tween.Completed:Connect(function()
        tween2:Play()
    end)
    tween:Play()
end

-- ─── Carregar Episódio ──────────────────────────────────────────

function loadEpisode()
    currentState = STATE.LOADING
    loadingLabel.Visible = true
    loadingLabel.Text = "⏳ Carregando episódio..."
    choiceA.Visible = false
    choiceB.Visible = false
    
    task.spawn(function()
        local success, episode = EpisodeService.getCurrentEpisode()
        loadingLabel.Visible = false
        
        if success and episode then
            currentEpisode = episode
            displayEpisode(episode)
        else
            -- Fallback: usa o episódio placeholder que o EpisodeService retorna
            currentEpisode = episode
            displayEpisode(episode)
        end
    end)
end

function displayEpisode(episode)
    if not episode then return end
    
    local epNum = episode.number or episode.id or 1
    local epTitle = episode.title or "Episódio " .. tostring(epNum)
    local epHook = episode.hook or "O que você faria?"
    local choices = episode.choices or {
        { id = "A", text = "Sim" },
        { id = "B", text = "Não" }
    }
    
    episodeTitle.Text = "📺 " .. epTitle
    episodeHook.Text = "\"" .. epHook .. "\""
    
    -- Configura os botões de escolha
    if #choices >= 1 then
        choiceA.Visible = true
        choiceALabel.Text = "A) " .. (choices[1].text or "Opção A")
        choiceA.ClipsDescendants = true
        choiceA.UserData = choices[1].id or "A"
    end
    if #choices >= 2 then
        choiceB.Visible = true
        choiceBLabel.Text = "B) " .. (choices[2].text or "Opção B")
        choiceB.ClipsDescendants = true
        choiceB.UserData = choices[2].id or "B"
    end
    
    currentState = STATE.READY
end

-- ─── Votar ──────────────────────────────────────────────────────

function castVote(choice)
    if hasVoted then return end
    if currentState ~= STATE.READY then return end
    
    currentState = STATE.VOTED
    hasVoted = true
    loadingLabel.Visible = true
    loadingLabel.Text = "⏳ Enviando seu voto..."
    
    choiceA.Visible = false
    choiceB.Visible = false
    
    task.spawn(function()
        local success, result = EpisodeService.submitVote(player, choice)
        loadingLabel.Visible = false
        
        if success and result then
            showVoteResult(choice, result)
            notifyEvent:FireClient(player, {
                title = "🗳️ Voto Registrado!",
                message = "Você escolheu " .. choice .. "! +25 Coins!",
                duration = 4
            })
        else
            -- Se falhou, tenta modo local
            showVoteResult(choice, nil)
            notifyEvent:FireClient(player, {
                title = "🗳️ Voto Registrado!",
                message = "Você escolheu " .. choice .. "!",
                duration = 3
            })
        end
    end)
end

function showVoteResult(chosen, resultData)
    -- Mostra os resultados
    local total = 0
    local votesA = 0
    local votesB = 0
    
    if resultData and resultData.results then
        total = resultData.results.total_votes or 0
        votesA = resultData.results.option_a or 0
        votesB = resultData.results.option_b or 0
    else
        -- Resultados simulados
        total = 10
        votesA = chosen == "A" and 6 or 4
        votesB = chosen == "B" and 6 or 4
    end
    
    local pctA = total > 0 and (votesA / total * 100) or 0
    local pctB = total > 0 and (votesB / total * 100) or 0
    
    -- Configura botões como resultados
    choiceA.Visible = true
    choiceA.BackgroundColor3 = chosen == "A" and Color3.fromRGB(255, 80, 130) or Color3.fromRGB(60, 60, 80)
    choiceALabel.Text = "A) " .. tostring(votesA) .. " votos"
    
    resultBarA.Visible = true
    resultBarA.Size = UDim2.new(0, math.max(10, pctA * 3.5), 0, 6)
    resultALabel.Visible = true
    resultALabel.Text = string.format("%.0f%%", pctA)
    resultALabel.Position = UDim2.new(1, -60, 0, 0)
    
    choiceB.Visible = true
    choiceB.BackgroundColor3 = chosen == "B" and Color3.fromRGB(80, 130, 255) or Color3.fromRGB(60, 60, 80)
    choiceBLabel.Text = "B) " .. tostring(votesB) .. " votos"
    
    resultBarB.Visible = true
    resultBarB.Size = UDim2.new(0, math.max(10, pctB * 3.5), 0, 6)
    resultBLabel.Visible = true
    resultBLabel.Text = string.format("%.0f%%", pctB)
    resultBLabel.Position = UDim2.new(1, -60, 0, 0)
    
    episodeHook.Text = "🗳️ Votação encerrada!\nTotal: " .. tostring(total) .. " votos"
    
    currentState = STATE.VOTED
end

-- ─── Eventos ────────────────────────────────────────────────────

-- Abrir/fechar painel
voteButton.MouseButton1Click:Connect(function()
    if mainFrame.Visible then
        mainFrame.Visible = false
        overlay.Visible = false
        voteButton.Size = UDim2.new(0, 60, 0, 60)
        voteButton.Position = UDim2.new(0.5, -30, 1, -90)
    else
        overlay.Visible = true
        mainFrame.Visible = true
        animateIn(mainFrame)
        loadEpisode()
    end
end)

-- Hover no botão
voteButton.MouseEnter:Connect(function()
    tooltip.Visible = true
    local tween = TweenService:Create(voteButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 65, 0, 65),
        Position = UDim2.new(0.5, -32.5, 1, -95)
    })
    tween:Play()
end)

voteButton.MouseLeave:Connect(function()
    tooltip.Visible = false
    local tween = TweenService:Create(voteButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0.5, -30, 1, -90)
    })
    tween:Play()
end)

-- Fechar
closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    overlay.Visible = false
end)

overlay.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainFrame.Visible = false
        overlay.Visible = false
    end
end)

-- Escolhas
choiceA.MouseButton1Click:Connect(function()
    if hasVoted then return end
    pulseButton(choiceA)
    castVote(choiceA.UserData)
end)

choiceB.MouseButton1Click:Connect(function()
    if hasVoted then return end
    pulseButton(choiceB)
    castVote(choiceB.UserData)
end)

-- Tecla V para abrir
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.V then
        if mainFrame.Visible then
            mainFrame.Visible = false
            overlay.Visible = false
        else
            overlay.Visible = true
            mainFrame.Visible = true
            animateIn(mainFrame)
            loadEpisode()
        end
    end
end)

-- Listener para notificações de novo episódio
notifyEvent.OnClientEvent:Connect(function(data)
    if data.title == "NOVO_EPISODIO" then
        -- Limpa cache e recarrega
        EpisodeService.clearCache()
        hasVoted = false
        currentState = STATE.IDLE
        
        -- Pisca o botão pra chamar atenção
        local pulse = TweenService:Create(voteButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 70, 0, 70)
        })
        local pulseBack = TweenService:Create(voteButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 60, 0, 60)
        })
        pulse.Completed:Connect(function()
            pulseBack:Play()
        end)
        pulse:Play()
    end
end)

print("✅ [VoteUI] Sistema de votação carregado! Pressione V para votar.")