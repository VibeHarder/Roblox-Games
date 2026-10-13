local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")
local Systems = ServerScriptService:WaitForChild("Systems")

print("[Server] Pastel Rift Survival Initializing...")

-- Initialize Systems
local PastelCore = require(Systems.PastelCore)
PastelCore:Initialize()

-- Initialize Services
local PlayerDataService = require(Services.PlayerDataService)
local WaveService = require(Services.WaveService)
local CombatService = require(Services.CombatService)

PlayerDataService:Start()
WaveService:Start()
CombatService:Start()

print("[Server] Pastel Rift Survival Ready!")
