--[[
    WaveService.luau
    Manages wave progression, enemy spawning intervals, and rift activity.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local WaveConfig = require(ReplicatedStorage.Shared.Config.WaveConfig)
local EnemySpawner = require(ServerScriptService.Systems.EnemySpawner)

local Net = ReplicatedStorage:WaitForChild("Net")
local WaveUpdate = Net:WaitForChild("WaveUpdate")

local WaveService = {
    CurrentWave = 0,
    IsWaveActive = false,
    EnemiesRemaining = 0,
    AllWavesComplete = false,
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
        if not self.AllWavesComplete then
            self.AllWavesComplete = true
            print("[WaveService] All waves completed! Victory!")
            WaveUpdate:FireAllClients({Wave = self.CurrentWave - 1, Phase = "Victory"})
        end
        return
    end
    
    print("[WaveService] Intermission for Wave " .. self.CurrentWave)
    WaveUpdate:FireAllClients({Wave = self.CurrentWave, Phase = "Intermission"})
    task.wait(WaveConfig.IntermissionTime)
    
    print("[WaveService] Starting Wave " .. self.CurrentWave)
    WaveUpdate:FireAllClients({Wave = self.CurrentWave, Phase = "Active"})
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
            local enemyModel = EnemySpawner:Spawn(enemyType)

            -- Count this enemy's death toward wave completion
            if enemyModel then
                local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Died:Connect(function()
                        self:OnEnemyDefeated()
                    end)
                end
            end
            
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
