--[[
    CombatController.luau
    Handles local player input, weapon firing visuals, and effects for Bubble Blaster and Prism Staff.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)

local CombatController = {
    CurrentWeapon = "Pastel Wand",
    LastFireTime = 0,
}

function CombatController:Start()
    print("[CombatController] Starting...")
    
    local Net = ReplicatedStorage:WaitForChild("Net")
    local WeaponFireRemote = Net:WaitForChild("WeaponFire")
    
    -- Input Listener
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Fire()
        end
    end)
    
    -- Visual Replication Listener
    WeaponFireRemote.OnClientEvent:Connect(function(firer, weaponName, targetPos)
        if firer ~= Players.LocalPlayer then
            self:PlayFireEffect(firer, weaponName, targetPos)
        end
    end)
end

function CombatController:Fire()
    local weaponConfig = self:GetWeaponConfig(self.CurrentWeapon)
    if not weaponConfig then return end
    
    local now = os.clock()
    if now - self.LastFireTime < weaponConfig.BaseCooldown then return end
    self.LastFireTime = now
    
    -- Get target position (Mouse hit)
    local mouse = Players.LocalPlayer:GetMouse()
    local targetPos = mouse.Hit.p
    
    -- Fire to server
    local Net = ReplicatedStorage:WaitForChild("Net")
    Net.WeaponFire:FireServer(self.CurrentWeapon, targetPos)
    
    -- Play local effect immediately for responsiveness
    self:PlayFireEffect(Players.LocalPlayer, self.CurrentWeapon, targetPos)
end

function CombatController:GetWeaponConfig(name)
    for _, w in ipairs(UpgradeConfig.Weapons) do
        if w.Name == name then return w end
    end
    return nil
end

function CombatController:PlayFireEffect(firer, weaponName, targetPos)
    local character = firer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local startPos = character.HumanoidRootPart.Position
    
    if weaponName == "Bubble Blaster" then
        self:CreateBubbleEffect(startPos, targetPos)
    elseif weaponName == "Prism Staff" then
        self:CreatePrismEffect(startPos, targetPos)
    else
        self:CreateDefaultEffect(startPos, targetPos)
    end
end

function CombatController:CreateBubbleEffect(start, target)
    local bubble = Instance.new("Part")
    bubble.Shape = Enum.PartType.Ball
    bubble.Size = Vector3.new(1, 1, 1)
    bubble.Color = Color3.fromHex("#B2E2F2")
    bubble.Material = Enum.Material.Glass
    bubble.Transparency = 0.5
    bubble.CanCollide = false
    bubble.Anchored = false
    bubble.Position = start
    bubble.Parent = workspace
    
    local velocity = (target - start).Unit * 50
    bubble.Velocity = velocity
    
    local bodyForce = Instance.new("BodyForce")
    bodyForce.Force = Vector3.new(0, bubble:GetMass() * workspace.Gravity * 0.8, 0) -- Floatiness
    bodyForce.Parent = bubble
    
    task.delay(2, function() bubble:Destroy() end)
end

function CombatController:CreatePrismEffect(start, target)
    local beam = Instance.new("Part")
    local dist = (target - start).Magnitude
    beam.Size = Vector3.new(0.2, 0.2, dist)
    beam.CFrame = CFrame.new(start:Lerp(target, 0.5), target)
    beam.Color = Color3.fromHex("#E0BBE4")
    beam.Material = Enum.Material.Neon
    beam.Anchored = true
    beam.CanCollide = false
    beam.Parent = workspace
    
    task.spawn(function()
        for i = 0, 1, 0.1 do
            beam.Transparency = i
            task.wait(0.02)
        end
        beam:Destroy()
    end)
end

function CombatController:CreateDefaultEffect(start, target)
    local p = Instance.new("Part")
    p.Size = Vector3.new(0.5, 0.5, 0.5)
    p.Color = Color3.fromHex("#FFD1DC")
    p.Material = Enum.Material.Neon
    p.Anchored = true
    p.CanCollide = false
    p.CFrame = CFrame.new(start)
    p.Parent = workspace
    
    game:GetService("TweenService"):Create(p, TweenInfo.new(0.2), {Position = target}):Play()
    task.delay(0.2, function() p:Destroy() end)
end

return CombatController
