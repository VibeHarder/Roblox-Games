local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Ensure Remotes Exist
local Net = ReplicatedStorage:FindFirstChild("Net") or Instance.new("Folder", ReplicatedStorage)
Net.Name = "Net"
local function getRemote(name, class)
    local r = Net:FindFirstChild(name)
    if not r then
        r = Instance.new(class)
        r.Name = name
        r.Parent = Net
    end
    return r
end
getRemote("CoreUpdate", "RemoteEvent")
getRemote("WaveUpdate", "RemoteEvent")
getRemote("WeaponFire", "RemoteEvent")

local Services = ServerScriptService:WaitForChild("Services")
local Systems = ServerScriptService:WaitForChild("Systems")

print("[Server] Pastel Rift Survival Initializing...")

-- Initialize Systems
local AssetGenerator = require(Systems.AssetGenerator)
AssetGenerator:GenerateAll()

local PastelCore = require(Systems.PastelCore)
PastelCore:Initialize()

-- Initialize Services
local PlayerDataService = require(Services.PlayerDataService)
local WaveService = require(Services.WaveService)
local CombatService = require(Services.CombatService)
local EconomyService = require(Services.EconomyService)
local WeaponService = require(Services.WeaponService)

PlayerDataService:Start()
WaveService:Start()
EconomyService:Start()
WeaponService:Start()
-- CombatService placeholder initialization
-- CombatService:Start()

print("[Server] Pastel Rift Survival Ready!")
