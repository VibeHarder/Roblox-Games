--[[
    PastelCore.luau
    Handles the central objective's health, damage, and repairs.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local PastelCore = {
    Health = 0,
    MaxHealth = 0,
    IsDestroyed = false,
}

local Remotes = ReplicatedStorage:WaitForChild("Net")
-- Note: In a full implementation, the server bootstrap would create these remotes
local CoreUpdateRemote = Remotes:FindFirstChild("CoreUpdate") 

function PastelCore:Initialize()
    self.MaxHealth = GameConfig.PastelCore.MaxHealth
    self.Health = self.MaxHealth
    self.IsDestroyed = false
    
    print("[PastelCore] Initialized with " .. self.MaxHealth .. " HP")
end

function PastelCore:TakeDamage(amount)
    if self.IsDestroyed then return end
    
    self.Health = math.max(0, self.Health - amount)
    print("[PastelCore] Health: " .. self.Health .. "/" .. self.MaxHealth)
    
    self:NotifyClients()
    
    if self.Health <= 0 then
        self:Destroy()
    end
end

function PastelCore:Repair(amount)
    if self.IsDestroyed then return end
    
    self.Health = math.min(self.MaxHealth, self.Health + amount)
    print("[PastelCore] Repaired! Health: " .. self.Health .. "/" .. self.MaxHealth)
    
    self:NotifyClients()
end

function PastelCore:Destroy()
    self.IsDestroyed = true
    print("[PastelCore] THE CORE HAS BEEN DESTROYED! GAME OVER.")
    -- Trigger Game Over logic here
end

function PastelCore:NotifyClients()
    if CoreUpdateRemote then
        CoreUpdateRemote:FireAllClients({
            Health = self.Health,
            MaxHealth = self.MaxHealth,
            IsDestroyed = self.IsDestroyed
        })
    end
end

return PastelCore
