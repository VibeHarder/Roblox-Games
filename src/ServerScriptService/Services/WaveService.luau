--[[
    WaveService.luau
    Manages wave progression, enemy spawning intervals, and rift activity.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local WaveConfig = require(ReplicatedStorage.Shared.Config.WaveConfig)
local EnemySpawner = require(ServerScriptService.Systems.EnemySpawner)

local WaveService = {
    CurrentWave = 0,
    IsWaveActive = false,
    EnemiesRemaining = 0,
}

function WaveService:Start()
    print("[WaveService] Service Started")
    task.spawn(function()
        while true do
            if not self.IsWaveActive then
                self:PrepareNextWave()
            end
            task.wait(1)
        end
    end)
end

function WaveService:PrepareNextWave()
    self.CurrentWave += 1
    local config = WaveConfig.Waves[self.CurrentWave]
    
    if not config then
        print("[WaveService] All waves completed! Victory!")
        return
    end
    
    print("[WaveService] Intermission for Wave " .. self.CurrentWave)
    task.wait(WaveConfig.IntermissionTime)
    
    print("[WaveService] Starting Wave " .. self.CurrentWave)
    self:StartWave(config)
end

function WaveService:StartWave(config)
    self.IsWaveActive = true
    self.EnemiesRemaining = config.EnemyCount
    
    task.spawn(function()
        for i = 1, config.EnemyCount do
            if not self.IsWaveActive then break end
            
            -- Pick a random enemy type from the config
            local enemyType = config.EnemyTypes[math.random(1, #config.EnemyTypes)]
            
            -- Spawn the enemy via the EnemySpawner system
            EnemySpawner:Spawn(enemyType)
            
            task.wait(config.SpawnInterval)
        end
    end)
end

function WaveService:OnEnemyDefeated()
    self.EnemiesRemaining -= 1
    
    if self.EnemiesRemaining <= 0 then
        self:EndWave()
    end
end

function WaveService:EndWave()
    print("[WaveService] Wave " .. self.CurrentWave .. " Completed!")
    self.IsWaveActive = false
    -- Distribute rewards here
end

return WaveService
