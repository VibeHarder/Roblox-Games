--[[
    EnemySpawner.luau
    Handles the physical creation of enemy models in the workspace.
]]

local EnemySpawner = {}

function EnemySpawner:Spawn(enemyType)
    print("[EnemySpawner] Spawning enemy: " .. enemyType)
    
    -- In a full implementation, this would:
    -- 1. Clone a template from ServerStorage
    -- 2. Position it at a Rift location
    -- 3. Parent it to Workspace
    -- 4. Initialize enemy AI
    
    -- Placeholder for visual feedback in console
    local dummyEnemy = Instance.new("Configuration")
    dummyEnemy.Name = "Enemy_" .. enemyType
    dummyEnemy.Parent = workspace
    
    task.delay(10, function()
        dummyEnemy:Destroy()
    end)
end

return EnemySpawner
