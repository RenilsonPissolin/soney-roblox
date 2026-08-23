-- ConfigModule (ModuleScript) — VERSÃO COMPLETA COM MONETIZAÇÃO
-- Colocar em: ReplicatedStorage > ConfigModule

local Config = {
    -- ─── PRODUTOS ───────────────────────────────────────────────
    PRODUCTS = {
        -- Coins (moeda do jogo)
        COINS_100 = { id = 3708120760, coins = 100, robux = 5, name = "100 Coins" },
        COINS_500 = { id = 3708120761, coins = 500, robux = 25, name = "500 Coins" },
        COINS_2000 = { id = 3708120762, coins = 2000, robux = 100, name = "2000 Coins" },
        COINS_10000 = { id = 3708120763, coins = 10000, robux = 500, name = "10000 Coins" },
        
        -- Gamepasses
        VIP_MENSAL = { id = 3708120770, robux = 50, name = "VIP Mensal" },
        VOTO_DUPLO = { id = 3708120771, robux = 30, name = "Voto Duplo" },
        EPISODIOS_EXCLUSIVOS = { id = 3708120772, robux = 75, name = "Episódios Secretos" },
        PACOTE_COMPLETO = { id = 3708120773, robux = 150, name = "Pacote Completo" },
    },
    
    -- ─── RECOMPENSAS ────────────────────────────────────────────
    REWARDS = {
        WELCOME_BONUS = 100,
        VOTE_REWARD = 25,
        DAILY_LOGIN = 50,
        STREAK_BONUS = {  -- bônus por dias consecutivos
            [3] = 100,
            [7] = 300,
            [14] = 800,
            [30] = 3000,
        },
        TOP_VOTER_WEEKLY = 500,
        SEASON_PASS_COST = 200,
    },

    -- ─── SONEY API ──────────────────────────────────────────────
    SONEY_API_URL = "https://soney-backend.onrender.com",
    API_TIMEOUT = 5,
    
    -- ─── LIMITES ────────────────────────────────────────────────
    MAX_COINS = 999999,
    DAILY_COIN_LIMIT = 2000,
    VOTE_COOLDOWN = 30,
    
    -- ─── SEASON ─────────────────────────────────────────────────
    SEASON = {
        current = 1,
        name = "O Último Andar",
        episodes = 15,
        start_date = "2026-08-15",
        end_date = "2026-09-15",
    }
}

return Config