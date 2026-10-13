--[[
    EconomyService.luau
    Handles player currency and shop transactions.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)
local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)
local PastelCore = require(ServerScriptService.Systems.PastelCore)

local Net = ReplicatedStorage:WaitForChild("Net")
local ShopPurchaseRemote = Net:FindFirstChild("ShopPurchase") or Instance.new("RemoteFunction", Net)
ShopPurchaseRemote.Name = "ShopPurchase"

local EconomyService = {}

function EconomyService:Start()
    print("[EconomyService] Starting...")
    
    ShopPurchaseRemote.OnServerInvoke = function(player, category, id)
        return self:ProcessPurchase(player, category, id)
    end
end

function EconomyService:ProcessPurchase(player, category, id)
    local data = PlayerDataService:GetPlayerData(player)
    if not data then return false, "Data not loaded" end
    
    if category == "Weapon" then
        local weaponInfo = UpgradeConfig.Weapons[id]
        if not weaponInfo then return false, "Invalid weapon" end
        if data.UnlockedWeapons[weaponInfo.Name] then return false, "Already owned" end
        
        if data.Coins >= weaponInfo.Cost then
            data.Coins -= weaponInfo.Cost
            data.UnlockedWeapons[weaponInfo.Name] = true
            PlayerDataService:UpdateClient(player)
            return true, "Weapon purchased!"
        else
            return false, "Not enough Coins"
        end
        
    elseif category == "Upgrade" then
        local upgradeInfo = UpgradeConfig.Upgrades[id]
        if not upgradeInfo then return false, "Invalid upgrade" end
        
        local currentLevel = data.PermanentUpgrades[upgradeInfo.Id] or 0
        local cost = upgradeInfo.BaseCost * (currentLevel + 1)
        
        if data.Coins >= cost then
            data.Coins -= cost
            data.PermanentUpgrades[upgradeInfo.Id] = currentLevel + 1
            
            -- Apply upgrade effects
            if upgradeInfo.Id == "MaxHealth" then
                PastelCore.MaxHealth += upgradeInfo.Increment
                PastelCore:Repair(upgradeInfo.Increment)
            end
            
            PlayerDataService:UpdateClient(player)
            return true, "Upgrade successful!"
        else
            return false, "Not enough Coins"
        end
    end
    
    return false, "Invalid category"
end

function EconomyService:AddCoins(player, amount)
    local data = PlayerDataService:GetPlayerData(player)
    if data then
        data.Coins += amount
        PlayerDataService:UpdateClient(player)
    end
end

return EconomyService
