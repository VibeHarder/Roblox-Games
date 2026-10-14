--[[
    PlayerDataService.luau
    Manages in-memory player data and client synchronization.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Net = ReplicatedStorage:WaitForChild("Net")
local DataUpdateRemote = Net:FindFirstChild("DataUpdate") or Instance.new("RemoteEvent", Net)
DataUpdateRemote.Name = "DataUpdate"

local PlayerDataService = {
    _cache = {}
}

function PlayerDataService:Start()
    Players.PlayerAdded:Connect(function(player)
        self._cache[player.UserId] = {
            Coins = 100,
            UnlockedWeapons = {["Pastel Wand"] = true},
            PermanentUpgrades = {},
        }
        self:UpdateClient(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self._cache[player.UserId] = nil
    end)
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
