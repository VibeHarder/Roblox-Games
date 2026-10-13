local WaveConfig = {
    IntermissionTime = 15,
    PrepTime = 10,
    
    Waves = {
        [1] = {
            EnemyCount = 10,
            SpawnInterval = 3,
            EnemyTypes = {"GummyGrunt"},
            RiftShardsReward = 50,
            CoinsReward = 20,
        },
        [2] = {
            EnemyCount = 15,
            SpawnInterval = 2.5,
            EnemyTypes = {"GummyGrunt", "SprinkleScout"},
            RiftShardsReward = 75,
            CoinsReward = 30,
        },
        [3] = {
            EnemyCount = 20,
            SpawnInterval = 2,
            EnemyTypes = {"GummyGrunt", "SprinkleScout"},
            RiftShardsReward = 100,
            CoinsReward = 40,
        },
        [4] = {
            EnemyCount = 25,
            SpawnInterval = 1.5,
            EnemyTypes = {"GummyGrunt", "SprinkleScout", "LicoriceBrute"},
            RiftShardsReward = 150,
            CoinsReward = 60,
        },
        [5] = {
            EnemyCount = 1,
            IsElite = true,
            SpawnInterval = 5,
            EnemyTypes = {"EliteBloom"},
            RiftShardsReward = 500,
            CoinsReward = 200,
        }
    }
}

return WaveConfig
