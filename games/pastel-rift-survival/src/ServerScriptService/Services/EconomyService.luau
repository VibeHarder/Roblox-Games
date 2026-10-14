--[[
    EconomyService.luau
    Validates every shop request from the client and mutates the player's
    authoritative data. The client only ever sends a category and an
    identifier; all prices, ownership and balances are checked here.
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
        return self:PurchaseWeapon(player, data, id)
    elseif category == "Equip" then
        return self:EquipWeapon(player, data, id)
    elseif category == "Upgrade" then
        return self:PurchaseUpgrade(player, data, id)
    end

    return false, "Invalid category"
end

function EconomyService:PurchaseWeapon(player, data, id)
    local weapon = UpgradeConfig.GetWeapon(id)
    if not weapon then return false, "Invalid weapon" end
    if data.UnlockedWeapons[weapon.Name] then return false, "Already owned" end

    if data.Coins < weapon.Cost then
        return false, "Not enough Coins"
    end

    data.Coins -= weapon.Cost
    data.UnlockedWeapons[weapon.Name] = true
    PlayerDataService:UpdateClient(player)
    return true, ("Purchased %s"):format(weapon.Name)
end

function EconomyService:EquipWeapon(player, data, id)
    local weapon = UpgradeConfig.GetWeapon(id)
    if not weapon then return false, "Invalid weapon" end
    if not data.UnlockedWeapons[weapon.Name] then return false, "Weapon not owned" end
    if data.EquippedWeapon == weapon.Name then return false, "Already equipped" end

    data.EquippedWeapon = weapon.Name
    PlayerDataService:UpdateClient(player)
    return true, ("Equipped %s"):format(weapon.Name)
end

function EconomyService:PurchaseUpgrade(player, data, id)
    local upgrade = UpgradeConfig.GetUpgrade(id)
    if not upgrade then return false, "Invalid upgrade" end

    local level = data.PermanentUpgrades[upgrade.Id] or 0
    local cost = upgrade.BaseCost * (level + 1)

    if data.Coins < cost then
        return false, "Not enough Coins"
    end

    data.Coins -= cost
    data.PermanentUpgrades[upgrade.Id] = level + 1

    -- Apply the upgrade's effect to the shared Pastel Core state.
    if upgrade.Id == "MaxHealth" then
        PastelCore.MaxHealth += upgrade.Increment
        PastelCore:Repair(upgrade.Increment)
    end

    PlayerDataService:UpdateClient(player)
    return true, ("Purchased %s (Lv %d)"):format(upgrade.Name, level + 1)
end

function EconomyService:AddCoins(player, amount)
    local data = PlayerDataService:GetPlayerData(player)
    if data then
        data.Coins += amount
        PlayerDataService:UpdateClient(player)
    end
end

return EconomyService
