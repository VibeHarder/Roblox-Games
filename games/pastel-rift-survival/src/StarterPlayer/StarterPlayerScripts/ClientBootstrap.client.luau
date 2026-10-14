local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Controllers = script.Parent:WaitForChild("Controllers")
local UI = script.Parent:WaitForChild("UI")

print("[Client] Pastel Rift Survival Initializing...")

-- Initialize Controllers
local InputController = require(Controllers.InputController)
local UIController = require(Controllers.UIController)
local CombatController = require(Controllers.CombatController)
local SoundController = require(Controllers.SoundController)

InputController:Start()
UIController:Start()
CombatController:Start()
SoundController:Start()

print("[Client] Pastel Rift Survival Ready!")
