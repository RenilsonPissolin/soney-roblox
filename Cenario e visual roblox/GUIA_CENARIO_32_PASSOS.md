# 🏗️ GUIA DEFINITIVO — CENÁRIO NEXUS COMPLETO
## 58 sub-passos — cada detalhe, cada posição, cada cor

---

# 🟣 PARTE 1 — ILUMINAÇÃO E ATMOSFERA

---

## 🔧 Passo 1 — Configurar o Lighting

**Local:** Explorer → Lighting

**1.1** Clique em **Lighting**
**1.2** No **Properties**, configure exatamente:

| Propriedade | Valor |
|:-----------|:------|
| Ambient | RGB(20, 20, 50) |
| Brightness | 0.3 |
| ColorShift_Bottom | RGB(5, 5, 20) |
| ColorShift_Top | RGB(20, 20, 50) |
| FogColor | RGB(5, 5, 20) |
| FogEnd | 100 |
| FogStart | 5 |
| ClockTime | 0 |
| OutdoorAmbient | RGB(10, 10, 30) |
| TimeOfDay | "00:00:00" |
| GeographicLatitude | 0 |

---

## 🔧 Passo 2 — Adicionar o Céu Estrelado

**Local:** Lighting → botão direito → Insert Object → Sky

**2.1** Renomeie para **CeuNexus**
**2.2** Configure:

| Propriedade | Valor |
|:-----------|:------|
| CelestialBodiesShown | false |
| StarCount | 3000 |
| SunRayCount | 0 |
| MoonAngularSize | 0 |
| SkyboxBk | rbxassetid://159451284 |
| SkyboxDn | rbxassetid://159451284 |
| SkyboxFt | rbxassetid://159451284 |
| SkyboxLf | rbxassetid://159451284 |
| SkyboxRt | rbxassetid://159451284 |
| SkyboxUp | rbxassetid://159451284 |

---

# 🟣 PARTE 2 — O CHÃO DO NEXUS

---

## 🔧 Passo 3 — Chão Principal

**Local:** Workspace → Insert Object → Part

**3.1** Renomeie para **ChaoNexus**
**3.2** Configure no Properties:

| Propriedade | Valor |
|:-----------|:------|
| Size | 120, 1, 120 |
| Position | 0, 0, 0 |
| Color | RGB(10, 10, 30) |
| Material | Neon |
| Anchored | true |
| TopSurface | Smooth |
| BottomSurface | Smooth |
| Shape | Block |

---

## 🔧 Passo 4 — Linhas Neon no Chão (Grid)

**Local:** Dentro de Workspace

**4.1** Crie uma **Part**:
- Renomeie para **LinhaNeon1**
- Size: 120, 0.1, 0.5
- Position: 0, 0.6, 0
- Color: RGB(0, 200, 255)
- Material: Neon
- Anchored: true
- Transparency: 0.3

**4.2** Duplique (Ctrl + D) e renomeie para **LinhaNeon2**
- Altere Rotation: 0, 90, 0
- Position: 0, 0.6, 0 (mesmo lugar, mas rotacionada 90°)

**4.3** Duplique mais 8 vezes, alternando rotações:
- LinhaNeon3: Rotation 45° → Position: 0, 0.6, 0
- LinhaNeon4: Rotation 135° → Position: 0, 0.6, 0
- LinhaNeon5: Rotation 22.5° → Position: 0, 0.6, 0
- LinhaNeon6: Rotation 67.5° → Position: 0, 0.6, 0
- LinhaNeon7: Rotation 112.5° → Position: 0, 0.6, 0
- LinhaNeon8: Rotation 157.5° → Position: 0, 0.6, 0

**Resultado:** Um grid de linhas neon azuis brilhando no chão

---

## 🔧 Passo 5 — Névoa do Chão

**Local:** Workspace

**5.1** Crie uma **Part**:
- Renomeie para **Nevoeiro**
- Size: 100, 0.5, 100
- Position: 0, 0.8, 0
- Color: RGB(0, 200, 255)
- Transparency: 0.95
- Anchored: true
- CanCollide: false

**5.2** Dentro de **Nevoeiro**, insira **ParticleEmitter**:
- Botão direito → Insert Object → ParticleEmitter
- Configure:

| Propriedade | Valor |
|:-----------|:------|
| Rate | 8 |
| Lifetime | 5, 10 |
| Speed | 0.5, 1.5 |
| Color | RGB(0, 200, 255) → RGB(100, 50, 255) |
| Transparency | 0.6, 1 |
| Size | 2, 5 |
| SpreadAngle | 180 |
| VelocityInheritance | 0 |
| Acceleration | 0, 0.1, 0 |
| Drag | 0.5 |
| LockedToPart | false |

---

# 🟣 PARTE 3 — SPAWN E ZONA DE VENDA

---

## 🔧 Passo 6 — Spawn Central

**Local:** Workspace → Insert Object → SpawnLocation

**6.1** Renomeie para **SpawnNexus**
**6.2** Configure:

| Propriedade | Valor |
|:-----------|:------|
| Size | 8, 0.5, 8 |
| Position | 0, 0.5, 0 |
| Color | RGB(0, 200, 255) |
| Material | Neon |
| Neutral | true |
| Duration | 2 |
| AllowTeamChange | true |

**6.3** Dentro de **SpawnNexus**, insira **PointLight**:
- Brightness: 8
- Color: RGB(0, 200, 255)
- Range: 25
- Shadows: true

---

## 🔧 Passo 7 — Zona de Venda

**Local:** Workspace

**7.1** Crie uma **Part**:
- Renomeie para **ZonaDeVenda**
- Size: 12, 0.5, 12
- Position: 0, 0.5, 20
- Color: RGB(0, 200, 255)
- Transparency: 0.4
- Material: Neon
- Anchored: true

**7.2** Dentro de **ZonaDeVenda**, insira **PointLight**:
- Brightness: 5
- Color: RGB(0, 200, 255)
- Range: 15

**7.3** Dentro de **ZonaDeVenda**, insira **Script**:
- Renomeie para **BonusZona**
- Cole o código:

```lua
script.Parent.Touched:Connect(function(hit)
    local p = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
    if p then
        local e = game:GetService("ReplicatedStorage"):FindFirstChild("BCEvent")
        if e then e:FireClient(p, "zonaVenda") end
    end
end)
```

---

# 🟣 PARTE 4 — PRÉDIOS ARRUINADOS

---

## 🔧 Passo 8 — Modelo de Prédio Base (Predio1)

**Local:** Workspace

**8.1** Crie uma **Part**:
- Renomeie para **Predio1**
- Size: 8, 15, 8
- Position: 25, 7.5, 20
- Color: RGB(40, 40, 45)
- Material: Concrete
- Anchored: true
- Shape: Block

---

## 🔧 Passo 9 — Detalhes do Predio1

**9.1** Teto quebrado:
- Crie uma **Part**
- Size: 6, 1, 6
- Position: 25, 15.5, 20
- Color: RGB(50, 50, 55)
- Rotation: 0, 0, 15 (inclinado)
- Anchored: true

**9.2** Musgo na lateral:
- Crie uma **Part**
- Size: 3, 0.2, 3
- Position: 25, 5, 12.5 (na parede lateral)
- Color: RGB(0, 100, 50)
- Material: Grass
- Anchored: true

**9.3** Segunda mancha de musgo:
- Size: 2, 0.2, 2
- Position: 25, 10, 12.5
- Color: RGB(0, 80, 40)
- Material: Grass

**9.4** Janela quebrada 1:
- Size: 1.5, 2, 0.2
- Position: 25, 8, 12.3
- Color: RGB(200, 200, 50)
- Transparency: 0.4
- Anchored: true

**9.5** Janela quebrada 2:
- Size: 1.5, 2, 0.2
- Position: 25, 4, 12.3
- Color: RGB(200, 200, 50)
- Transparency: 0.4
- Anchored: true

---

## 🔧 Passo 10 — Duplicar os Prédios

Selecione **Predio1** + todos os detalhes dentro dele. Ctrl + D para duplicar.

**10.1** **Predio2:**
- Renomeie para Predio2
- Size: 6, 10, 6
- Position: -20, 5, 25
- Refaça os detalhes (teto, musgo, janelas) nas novas posições

**10.2** **Predio3:**
- Size: 10, 20, 10
- Position: 30, 10, -25

**10.3** **Predio4:**
- Size: 8, 25, 8
- Position: -30, 12.5, -20

**10.4** **Predio5:**
- Size: 5, 12, 5
- Position: 40, 6, 5

**10.5** **Predio6:**
- Size: 7, 18, 7
- Position: -40, 9, 10

**10.6** **Predio7:**
- Size: 4, 8, 4
- Position: 15, 4, 40

**10.7** **Predio8:**
- Size: 9, 30, 9
- Position: -15, 15, -40

**10.8** **Predio9:**
- Size: 6, 15, 6
- Position: 50, 7.5, -15

**10.9** **Predio10:**
- Size: 8, 22, 8
- Position: -50, 11, 15

---

## 🔧 Passo 11 — Vegetação nos Prédios

Para cada prédio, adicione:

**11.1** Musgo subindo pela parede:
- 3 a 5 manchas de musgo em alturas diferentes
- Tamanhos variados (1x0.2x1 até 4x0.2x4)
- Cores: RGB(0, 100, 50) e RGB(0, 80, 40)

**11.2** Raízes na base:
- Part cilíndrica: Size: 1, 3, 1, Rotation: 0, 0, 30
- Color: RGB(50, 30, 10), Material: Wood
- Posicionar saindo do chão ao lado do prédio

---

# 🟣 PARTE 5 — VEGETAÇÃO AVULSA

---

## 🔧 Passo 12 — Folder de Vegetação

**Local:** Workspace → Insert Object → Folder
- Renomeie para **Vegetacao**

---

## 🔧 Passo 13 — Musgo no Chão

**13.1** Dentro de **Vegetacao**, crie **Part**:
- Renomeie para **MusgoChao1**
- Size: 5, 0.1, 5
- Position: 10, 0.1, 15
- Color: RGB(0, 100, 50)
- Material: Grass

**13.2** Duplique 10 vezes e espalhe pelo mapa em manchas irregulares

---

## 🔧 Passo 14 — Raízes Gigantes

**14.1** Dentro de **Vegetacao**, crie **Part**:
- Renomeie para **RaizGigante1**
- Size: 1, 6, 1
- Position: 15, 3, 20
- Color: RGB(50, 30, 10)
- Material: Wood
- Rotation: 0, 0, 25 (inclinada)

**14.2** Duplique 5 vezes, altere rotação e posição

---

## 🔧 Passo 15 — Árvores Mortas

**15.1** Dentro de **Vegetacao**:
- Tronco: Part → Size: 0.5, 4, 0.5 → Color: RGB(60, 40, 20) → Material: Wood
- Copa: Part → Size: 3, 1, 3 → Color: RGB(0, 60, 30) → Transparency: 0.3 → Position: Y = 4.5
- Agrupe (Ctrl + G) e renomeie para **Arvore1**

**15.2** Duplique 5 vezes e espalhe

---

# 🟣 PARTE 6 — CARROS ABANDONADOS

---

## 🔧 Passo 16 — Modelo de Carro

**Local:** Workspace

**16.1** Carroceria:
- Part → Size: 2, 1, 4 → Color: RGB(80, 50, 50) → Anchored: true

**16.2** Teto (quebrado):
- Part → Size: 1.8, 0.3, 3.5 → Color: RGB(100, 100, 100) → Transparency: 0.3 → Position: Y = 1.2

**16.3** 4 Rodas (Cylinder):
- Size: 0.5, 0.2, 0.5 → Color: RGB(30, 30, 30)
- Posições: (-0.8, 0.3, -1.5), (0.8, 0.3, -1.5), (-0.8, 0.3, 1.5), (0.8, 0.3, 1.5)

**16.4** Musgo no carro:
- Part → Size: 0.5, 0.1, 0.5 → Color: RGB(0, 100, 50) → Material: Grass → Position: Y = 1.1

**16.5** Agrupe (Ctrl + G) e renomeie para **Carro1**

---

## 🔧 Passo 17 — Duplicar Carros

Duplique **Carro1** 5 vezes e posicione:

| Nome | Posição | Rotação |
|:----|:-------|:-------:|
| Carro2 | -10, 0.5, 30 | 45° |
| Carro3 | 35, 0.5, -15 | 90° |
| Carro4 | -25, 0.5, -30 | 180° |
| Carro5 | 45, 0.5, 25 | 270° |
| Carro6 | -35, 0.5, 5 | 15° |

---

# 🟣 PARTE 7 — TORRE TITÃ

---

## 🔧 Passo 18 — Corpo da Torre

**Local:** Workspace

**18.1** Part → renomeie para **TorreTitan**
- Size: 20, 134, 20
- Position: 0, 67, 0
- Color: RGB(0, 50, 30)
- Material: Concrete
- Anchored: true

---

## 🔧 Passo 19 — Janelas da Torre

Crie **20 Parts** para janelas:
- Size: 1, 1.5, 0.2
- Color: RGB(0, 200, 100)
- Transparency: 0.5
- Anchored: true

Posicione nas laterais da torre:

**Lado direito (X = 10.1):**
- Y = 5, Y = 15, Y = 25, Y = 35, Y = 45
- Y = 55, Y = 65, Y = 75, Y = 85, Y = 95

**Lado esquerdo (X = -10.1):**
- Y = 10, Y = 20, Y = 30, Y = 40, Y = 50
- Y = 60, Y = 70, Y = 80, Y = 90, Y = 100

---

## 🔧 Passo 20 — Musgo na Torre

Crie **10 Parts** de musgo:
- Size: 3, 0.2, 5
- Color: RGB(0, 100, 50)
- Material: Grass

Posicione em alturas variadas da torre:
- Y = 2, Y = 20, Y = 38, Y = 55, Y = 70
- Y = 85, Y = 100, Y = 110, Y = 120, Y = 130

---

## 🔧 Passo 21 — Plataforma do Topo

**21.1** Part → renomeie para **PlataformaTopo**
- Size: 30, 1, 30
- Position: 0, 135, 0
- Color: RGB(0, 100, 50)
- Material: Neon
- Anchored: true

**21.2** PointLight dentro da plataforma:
- Brightness: 10
- Color: RGB(0, 255, 100)
- Range: 60
- Shadows: true

**21.3** Partículas verdes no topo:
- ParticleEmitter dentro da plataforma:
  - Rate: 5
  - Lifetime: 2, 4
  - Color: RGB(0, 255, 100) → RGB(0, 100, 50)
  - Size: 0.5, 1.5
  - Speed: 1, 3

---

## 🔧 Passo 22 — Posicionar o Boss

Mova o modelo **TitanEsmeralda** para:
- Position: 0, 140, 0

(O Core do boss deve ficar flutuando sobre a plataforma)

---

# 🟣 PARTE 8 — RELÍQUIAS

---

## 🔧 Passo 23 — Modelo de Relíquia

**Local:** Workspace → Reliquias

**23.1** Dentro da pasta **Reliquias**, crie:
- Part → renomeie para **Reliquia1**
- Size: 1, 1, 1
- Color: RGB(255, 200, 50)
- Material: Neon
- Anchored: true

**23.2** PointLight:
- Color: RGB(255, 200, 50)
- Range: 5
- Brightness: 2

**23.3** ProximityPrompt:
- HoldDuration: 0
- MaxActivationDistance: 5
- KeyboardKeyCode: E
- ActionText: "Coletar Relíquia"
- ObjectText: "💎 Relíquia"

**23.4** Script → cole:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bcEvent = ReplicatedStorage:WaitForChild("BCEvent")
local prompt = script.Parent:WaitForChild("ProximityPrompt")
local part = script.Parent
local RESPAWN = 30

prompt.Triggered:Connect(function(player)
    prompt.Enabled = false
    part.Transparency = 0.8
    part.CanCollide = false
    bcEvent:FireServer("coletarReliquia", script.Parent.Name)
    task.wait(RESPAWN)
    part.Transparency = 0
    part.CanCollide = true
    prompt.Enabled = true
end)
```

---

## 🔧 Passo 24 — Posições das 20 Relíquias

Duplique **Reliquia1** 19 vezes e posicione:

| # | Posição | Localização |
|:-:|:--------|:------------|
| 1 | 25, 1.5, 20 | Em cima do Predio1 |
| 2 | -20, 1.5, 25 | Em cima do Predio2 |
| 3 | 30, 1.5, -25 | Em cima do Predio3 |
| 4 | -30, 1.5, -20 | Em cima do Predio4 |
| 5 | 40, 1.5, 5 | Em cima do Predio5 |
| 6 | -40, 1.5, 10 | Em cima do Predio6 |
| 7 | 15, 1.5, 40 | Em cima do Predio7 |
| 8 | -15, 1.5, -40 | Em cima do Predio8 |
| 9 | 50, 1.5, -15 | Em cima do Predio9 |
| 10 | -50, 1.5, 15 | Em cima do Predio10 |
| 11 | 0, 1.5, 20 | Perto da Zona de Venda |
| 12 | 0, 1.5, -20 | Lado oposto do spawn |
| 13 | 20, 1.5, 0 | Entrada da torre |
| 14 | -20, 1.5, 0 | Entrada da torre |
| 15 | 5, 1.5, 45 | Escondida em vegetação |
| 16 | -5, 1.5, -45 | Escondida em vegetação |
| 17 | 0, 135, 10 | Plataforma do topo |
| 18 | 0, 135, -10 | Plataforma do topo |
| 19 | 10, 1.5, -30 | Dentro de um carro |
| 20 | -10, 1.5, 35 | Atrás de um prédio |

---

# 🟣 PARTE 9 — ROTAS DOS INIMIGOS

---

## 🔧 Passo 25 — Criar Pastas de Rotas

**Local:** Workspace

Crie **12 pastas** (Folder):
- **RotaInimigo1** até **RotaInimigo12**

---

## 🔧 Passo 26 — Waypoints

Dentro de cada pasta, crie **3 a 5 Parts**:
- Transparency: 1
- Anchored: true
- CanCollide: false
- Size: 2, 0.5, 2

**RotaInimigo1 (Térreo — entre prédios):**
- WP1: 10, 0.5, 10
- WP2: 20, 0.5, 15
- WP3: 15, 0.5, 25
- WP4: 5, 0.5, 20

**RotaInimigo2 (Térreo — perímetro):**
- WP1: 30, 0.5, 0
- WP2: 40, 0.5, 10
- WP3: 35, 0.5, -10

**RotaInimigo3 (Térreo — lado oposto):**
- WP1: -10, 0.5, -10
- WP2: -20, 0.5, -15
- WP3: -15, 0.5, -25

**RotaInimigo4 (Meio da torre — lado A):**
- WP1: 12, 35, 5
- WP2: 12, 35, -5
- WP3: -12, 35, 5

**RotaInimigo5 (Meio da torre — lado B):**
- WP1: -12, 55, 5
- WP2: -12, 55, -5
- WP3: 12, 55, -5

**RotaInimigo6 (Meio da torre — lateral):**
- WP1: 15, 45, 10
- WP2: -15, 45, 10
- WP3: -15, 45, -10

**RotaInimigo7 (Alto da torre):**
- WP1: 12, 75, 5
- WP2: -12, 75, -5
- WP3: 0, 75, 12

**RotaInimigo8 (Alto da torre):**
- WP1: 0, 95, 12
- WP2: 12, 95, 0
- WP3: -12, 95, 0

**RotaInimigo9 (Alto da torre):**
- WP1: 10, 110, 10
- WP2: -10, 110, -10
- WP3: 10, 110, -10

**RotaInimigo10 (Topo — ao redor do boss):**
- WP1: 15, 135, 0
- WP2: 0, 135, 15
- WP3: -15, 135, 0
- WP4: 0, 135, -15

**RotaInimigo11 (Topo — circular):**
- WP1: 10, 135, 10
- WP2: -10, 135, 10
- WP3: -10, 135, -10
- WP4: 10, 135, -10

**RotaInimigo12 (Topo — patrulha interna):**
- WP1: 5, 135, 5
- WP2: -5, 135, 5
- WP3: -5, 135, -5
- WP4: 5, 135, -5

---

# 🟣 PARTE 10 — EASTER EGG SÃO PAULO

---

## 🔧 Passo 27 — Construir a Estátua

**Local:** Workspace → Insert Object → Model
- Renomeie para **EstatuaSP**

**27.1** Corpo da estátua:
- Part → Size: 5, 8, 3 → Color: RGB(100, 100, 100) → Material: Concrete → Anchored: true

**27.2** Base:
- Part → Size: 6, 0.5, 4 → Color: RGB(80, 80, 80) → Anchored: true → Position: Y = -0.3

**27.3** Placa:
- Part → Size: 2, 1, 0.2 → Color: RGB(200, 180, 50) → Material: Neon → Position: Y = 0.5, Z = 1.6

**27.4** ProximityPrompt:
- HoldDuration: 0
- MaxActivationDistance: 5
- KeyboardKeyCode: E
- ActionText: "Examinar Placa"
- ObjectText: "🏛️ Estátua Antiga"

**27.5** Script:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bcEvent = ReplicatedStorage:WaitForChild("BCEvent")
local prompt = script.Parent:WaitForChild("ProximityPrompt")
prompt.Triggered:Connect(function(player)
    bcEvent:FireServer("dailyEasterEgg")
end)
```

---

## 🔧 Passo 28 — Posição Escondida

Posicione **EstatuaSP** em:
- Position: -18, 0, 35
- (Atrás do Predio7, cercado por vegetação)

---

# 🟣 PARTE 11 — POSTES DE LUZ

---

## 🔧 Passo 29 — Modelo de Poste

**Local:** Workspace

**29.1** Haste:
- Part → Size: 0.2, 5, 0.2 → Color: RGB(30, 30, 30) → Anchored: true

**29.2** Lâmpada:
- Part → Size: 0.5, 0.3, 0.5 → Color: RGB(0, 200, 255) → Material: Neon → Anchored: true
- Position: Y = 5.2 (topo da haste)

**29.3** PointLight:
- Brightness: 3
- Color: RGB(0, 200, 255)
- Range: 12

**29.4** Agrupe (Ctrl + G) e renomeie para **PosteLuz1**

---

## 🔧 Passo 30 — Posições dos Postes

Duplique 7 vezes e posicione:

| Poste | Posição |
|:-----|:--------|
| PosteLuz2 | 15, 0, 15 |
| PosteLuz3 | -15, 0, 15 |
| PosteLuz4 | 15, 0, -15 |
| PosteLuz5 | -15, 0, -15 |
| PosteLuz6 | 30, 0, 0 |
| PosteLuz7 | -30, 0, 0 |
| PosteLuz8 | 0, 0, 30 |

---

# 🟣 PARTE 12 — ESTRUTURA FINAL E VERIFICAÇÃO

---

## 🔧 Passo 31 — Estrutura Final no Explorer

```
📦 Workspace
 ┣ 📦 ChaoNexus
 ┣ 📦 LinhaNeon1..8
 ┣ 📦 Nevoeiro
 ┃  ┗ 📦 ParticleEmitter
 ┣ 📦 SpawnNexus
 ┃  ┗ 📦 PointLight
 ┣ 📦 ZonaDeVenda
 ┃  ┣ 📦 PointLight
 ┃  ┗ 📦 BonusZona (Script)
 ┣ 📦 Predio1..10
 ┃  ┣ (teto quebrado, musgo, janelas)
 ┣ 📦 Carro1..6
 ┣ 📦 Vegetacao
 ┃  ┣ 📦 MusgoChao1..10
 ┃  ┣ 📦 RaizGigante1..5
 ┃  ┗ 📦 Arvore1..5
 �� 📦 TorreTitan
 ┣ 📦 PlataformaTopo
 ┃  ┣ 📦 PointLight
 ┃  ┗ 📦 ParticleEmitter
 ┣ 📦 PosteLuz1..8
 ┃  ┣ (haste, lâmpada, PointLight)
 ┣ 📦 TitanEsmeralda
 ┣ 📦 Inimigo1..12
 ┣ 📦 Reliquias
 ┃  ┗ 📦 Reliquia1..20
 ┣ 📦 RotaInimigo1..12
 ┃  ┗ 📦 WP1..5
 ┗ 📦 EstatuaSP
    ┣ (corpo, base, placa)
    ┣ 📦 ProximityPrompt
    ┗ 📦 (Script)
```

---

## 🔧 Passo 32 — Teste Visual

Clique em **Play** e verifique:

| Item | Como testar | Esperado |
|:----|:-----------|:---------|
| 🌃 Iluminação | Olhar o céu | Noite escura com estrelas |
| 🔵 Névoa | Andar no mapa | Névoa azul no chão |
| 💡 Spawn | Nascer no jogo | Luz azul brilhante |
| 🏙️ Prédios | Andar pelo mapa | 10 prédios com musgo |
| 🌿 Vegetação | Olhar as paredes | Musgo, raízes e árvores |
| 🚗 Carros | Andar pelas ruas | 6 carros enferrujados |
| 🏗️ Torre | Olhar o centro | Torre de 67 andares |
| 🟢 Topo | Ir até Y=140 | Luz verde + Boss |
| 💎 Relíquias | Apertar E | Relíquia dourada some |
| 🔴 Inimigos | Chegar perto | Luz vermelha te segue |
| 🏛️ Estátua | Atrás do Predio7 | Placa dourada |
| 💡 Postes | Olhar o mapa | 8 postes de luz neon |

---

**32 passos concluídos! O cenário está completo e idêntico à descrição visual.** 🎮🔥