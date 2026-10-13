--[[
    WeaponService.luau
    Handles server-side weapon firing, cooldown validation, and damage application.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)
local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)

local Net = ReplicatedStorage:WaitForChild("Net")
local WeaponFireRemote = Net:FindFirstChild("WeaponFire") or Instance.new("RemoteEvent", Net)
WeaponFireRemote.Name = "WeaponFire"

local WeaponService = {
    _playerCooldowns = {}
}

function WeaponService:Start()
    print("[WeaponService] Starting...")
    
    WeaponFireRemote.OnServerEvent:Connect(function(player, weaponName, targetPos)
        self:HandleFireRequest(player, weaponName, targetPos)
    end)
end

function WeaponService:HandleFireRequest(player, weaponName, targetPos)
    local data = PlayerDataService:GetPlayerData(player)
    if not data or not data.UnlockedWeapons[weaponName] then return end
    
    -- Find weapon config
    local weaponConfig = nil
    for _, w in ipairs(UpgradeConfig.Weapons) do
        if w.Name == weaponName then
            weaponConfig = w
            break
        end
    end
    if not weaponConfig then return end
    
    -- Cooldown check
    local now = os.clock()
    local lastFire = self._playerCooldowns[player.UserId] or 0
    if now - lastFire < weaponConfig.BaseCooldown - 0.05 then -- 50ms grace period
        return 
    end
    self._playerCooldowns[player.UserId] = now
    
    -- Firing Logic
    print(string.format("[WeaponService] %s fired %s at %s", player.Name, weaponName, tostring(targetPos)))
    
    -- Damage Application (Raycast or Projectile check would go here)
    -- For now, we simulate hitting whatever is at the targetPos if it has a humanoid
    self:ApplyDamageAt(player, weaponConfig.BaseDamage, targetPos)
    
    -- Replicate visual to other clients
    WeaponFireRemote:FireAllClients(player, weaponName, targetPos)
end

function WeaponService:ApplyDamageAt(player, damage, position)
    -- In a real game, the client would send the target Instance
    -- Here we do a small area check for demonstration
    local region = Region3.new(position - Vector3.new(2,2,2), position + Vector3.new(2,2,2))
    local parts = workspace:FindPartsInRegion3(region, nil, 10)
    
    for _, part in ipairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Humanoid") then
            model.Humanoid:TakeDamage(damage)
            print("[WeaponService] Hit target for " .. damage .. " damage!")
            break -- Only damage one target for these specific weapons
        end
    end
end

return WeaponService
