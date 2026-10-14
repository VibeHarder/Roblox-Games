local GameConfig = {
    PastelCore = {
        MaxHealth = 5000,
        RepairAmount = 500,
        RepairCost = 50, -- Rift Shards
    },
    
    Player = {
        MaxHealth = 100,
        WalkSpeed = 16,
        JumpPower = 50,
        DownedTimer = 30, -- Seconds
        ReviveTime = 5, -- Seconds
    },
    
    Economy = {
        StartingCoins = 100,
        StartingShards = 0,
    }
}

return GameConfig
