--[[
    EnemyAI.luau
    Handles pathfinding and behavior for corrupted pastel enemies.
]]

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PastelCore = require(ServerScriptService.Systems.PastelCore)

local EnemyAI = {}
EnemyAI.__index = EnemyAI

function EnemyAI.new(model, config)
    local self = setmetatable({}, EnemyAI)
    
    self.Model = model
    self.Humanoid = model:WaitForChild("Humanoid")
    self.RootPart = model:WaitForChild("HumanoidRootPart")
    self.Config = config or {
        Damage = 10,
        AttackRange = 5,
        AttackRate = 1.5,
    }
    
    self.LastAttackTime = 0
    self.Active = true
    
    -- Start behavior loop
    task.spawn(function()
        self:RunBehavior()
    end)
    
    return self
end

function EnemyAI:RunBehavior()
    while self.Active and self.Humanoid.Health > 0 do
        local corePosition = Vector3.new(0, 0, 0) -- Default Core Position
        local corePart = workspace:FindFirstChild("PastelCore") and workspace.PastelCore:FindFirstChild("Crystal")
        if corePart then
            corePosition = corePart.Position
        end
        
        local distanceToCore = (self.RootPart.Position - corePosition).Magnitude
        
        if distanceToCore <= self.Config.AttackRange then
            self:AttackCore()
        else
            self:MoveTo(corePosition)
        end
        
        task.wait(0.5)
    end
end

function EnemyAI:MoveTo(targetPosition)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(self.RootPart.Position, targetPosition)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        -- Move to the second waypoint (first is current position)
        if waypoints[2] then
            self.Humanoid:MoveTo(waypoints[2].Position)
            if waypoints[2].Action == Enum.PathWaypointsAction.Jump then
                self.Humanoid.Jump = true
            end
        end
    else
        -- Fallback: Straight line move if pathfinding fails
        self.Humanoid:MoveTo(targetPosition)
    end
end

function EnemyAI:AttackCore()
    local now = os.clock()
    if now - self.LastAttackTime >= self.Config.AttackRate then
        self.LastAttackTime = now
        
        -- Apply damage to the core
        PastelCore:TakeDamage(self.Config.Damage)
        
        -- Play a simple "lunge" animation or effect
        print("[EnemyAI] Attacking Pastel Core!")
    end
end

function EnemyAI:Stop()
    self.Active = false
end

return EnemyAI
