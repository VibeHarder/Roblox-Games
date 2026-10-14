local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Controllers = script.Parent:WaitForChild("Controllers")
local UI = script.Parent:WaitForChild("UI")

print("[Client] Pastel Rift Survival Initializing...")

-- Initialize Controllers
local UIController = require(Controllers.UIController)
local CombatController = require(Controllers.CombatController)
local SoundController = require(Controllers.SoundController)

UIController:Start()
CombatController:Start()
SoundController:Start()

-- The shop is built on top of the HUD created by UIController, so it must
-- be initialized afterwards.
local ShopUI = require(UI.ShopUI)
ShopUI:Initialize()

print("[Client] Pastel Rift Survival Ready!")
