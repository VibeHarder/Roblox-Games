--[[
    SoundController.luau
    Handles the playback of sound effects for weapons and game events.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SoundController = {
    _sounds = {}
}

-- Asset IDs for placeholder sounds (using standard Roblox sounds)
local SOUND_ASSETS = {
    ["BubblePop"] = "rbxassetid://192451451",  -- Pop sound
    ["PrismHum"] = "rbxassetid://233096417",   -- Power up/energy sound
    ["WandFire"] = "rbxassetid://1163152648",  -- Magic zap
}

function SoundController:Start()
    print("[SoundController] Starting...")
    self:InitializeSounds()
    
    local Net = ReplicatedStorage:WaitForChild("Net")
    local WeaponFireRemote = Net:WaitForChild("WeaponFire")
    
    -- Listen for weapon fire to play sounds
    WeaponFireRemote.OnClientEvent:Connect(function(firer, weaponName, targetPos)
        self:PlayWeaponSound(weaponName, firer.Character and firer.Character.PrimaryPart)
    end)
end

function SoundController:InitializeSounds()
    local folder = Instance.new("Folder")
    folder.Name = "WeaponSounds"
    folder.Parent = SoundService

    for name, id in pairs(SOUND_ASSETS) do
        local sound = Instance.new("Sound")
        sound.Name = name
        sound.SoundId = id
        sound.Volume = 0.5
        sound.Parent = folder
        self._sounds[name] = sound
    end
end

function SoundController:PlayWeaponSound(weaponName, sourcePart)
    local soundName = "WandFire"
    
    if weaponName == "Bubble Blaster" then
        soundName = "BubblePop"
    elseif weaponName == "Prism Staff" then
        soundName = "PrismHum"
    end
    
    local originalSound = self._sounds[soundName]
    if originalSound then
        local soundClone = originalSound:Clone()
        
        -- If sourcePart is provided, make it 3D
        if sourcePart then
            soundClone.Parent = sourcePart
            soundClone.RollOffMaxDistance = 100
        else
            soundClone.Parent = SoundService
        end
        
        soundClone:Play()
        soundClone.Ended:Connect(function()
            soundClone:Destroy()
        end)
    end
end

return SoundController
