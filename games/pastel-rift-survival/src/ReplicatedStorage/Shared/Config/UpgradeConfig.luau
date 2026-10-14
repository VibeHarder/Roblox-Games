local UpgradeConfig = {
    Weapons = {
        {
            Name = "Pastel Wand",
            Description = "A basic magical wand firing soft energy bolts.",
            BaseDamage = 20,
            BaseCooldown = 0.8,
            Cost = 0, -- Default weapon
        },
        {
            Name = "Bubble Blaster",
            Description = "Fires bubbles that deal moderate damage.",
            BaseDamage = 35,
            BaseCooldown = 1.2,
            Cost = 250, -- Coins
        },
        {
            Name = "Prism Staff",
            Description = "High-powered laser staff.",
            BaseDamage = 60,
            BaseCooldown = 2.0,
            Cost = 750, -- Coins
        }
    },
    
    Upgrades = {
        {
            Id = "MaxHealth",
            Name = "Core Fortification",
            Description = "Increase the Pastel Core's maximum health.",
            BaseCost = 100,
            Increment = 500,
        },
        {
            Id = "RepairEfficiency",
            Name = "Efficient Repairs",
            Description = "Repair more health per click.",
            BaseCost = 150,
            Increment = 100,
        }
    }
}

-- Shared lookup helpers so the client shop and the server economy resolve
-- identifiers the same way. `id` accepts the string identifier, and the
-- 1-based array index is still accepted for backwards compatibility.
function UpgradeConfig.GetWeapon(id)
    if type(id) == "number" then
        return UpgradeConfig.Weapons[id]
    end
    for _, weapon in ipairs(UpgradeConfig.Weapons) do
        if weapon.Name == id then
            return weapon
        end
    end
    return nil
end

function UpgradeConfig.GetUpgrade(id)
    if type(id) == "number" then
        return UpgradeConfig.Upgrades[id]
    end
    for _, upgrade in ipairs(UpgradeConfig.Upgrades) do
        if upgrade.Id == id then
            return upgrade
        end
    end
    return nil
end

return UpgradeConfig
