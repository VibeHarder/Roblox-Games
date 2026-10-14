--[[
    PlayerDataService.luau
    Owns the authoritative in-memory player data and pushes it to clients.
    Coins, unlocked weapons, the equipped weapon and upgrade levels all live
    here; clients never decide these values themselves.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local Net = ReplicatedStorage:WaitForChild("Net")
local DataUpdateRemote = Net:FindFirstChild("DataUpdate") or Instance.new("RemoteEvent", Net)
DataUpdateRemote.Name = "DataUpdate"

-- Clients can miss the initial broadcast, so they are able to pull the
-- current state on demand instead of waiting for the next change.
local RequestDataRemote = Net:FindFirstChild("RequestData") or Instance.new("RemoteFunction", Net)
RequestDataRemote.Name = "RequestData"

local DEFAULT_WEAPON = "Pastel Wand"

local PlayerDataService = {
    _cache = {}
}

local function newPlayerData()
    return {
        Coins = GameConfig.Economy.StartingCoins,
        Shards = GameConfig.Economy.StartingShards,
        UnlockedWeapons = { [DEFAULT_WEAPON] = true },
        EquippedWeapon = DEFAULT_WEAPON,
        PermanentUpgrades = {},
    }
end

function PlayerDataService:Start()
    Players.PlayerAdded:Connect(function(player)
        self._cache[player.UserId] = newPlayerData()
        self:UpdateClient(player)
    end)

    -- Players who joined before this service started still need data.
    for _, player in ipairs(Players:GetPlayers()) do
        if not self._cache[player.UserId] then
            self._cache[player.UserId] = newPlayerData()
            self:UpdateClient(player)
        end
    end

    Players.PlayerRemoving:Connect(function(player)
        self._cache[player.UserId] = nil
    end)

    RequestDataRemote.OnServerInvoke = function(player)
        local data = self._cache[player.UserId]
        if not data then
            data = newPlayerData()
            self._cache[player.UserId] = data
        end
        return data
    end
end

function PlayerDataService:GetPlayerData(player)
    return self._cache[player.UserId]
end

function PlayerDataService:UpdateClient(player)
    local data = self._cache[player.UserId]
    if data then
        DataUpdateRemote:FireClient(player, data)
    end
end

return PlayerDataService
