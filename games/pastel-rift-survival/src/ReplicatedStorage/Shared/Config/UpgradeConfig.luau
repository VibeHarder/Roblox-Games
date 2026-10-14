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

return UpgradeConfig
