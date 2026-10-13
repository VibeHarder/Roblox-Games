--[[
    UIController.luau
    Manages the HUD and connects it to server-side updates.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local UIController = {
    HUD = nil,
}

function UIController:Start()
    print("[UIController] Starting...")
    self:CreateHUD()
    self:ConnectToNet()
end

function UIController:CreateHUD()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PastelHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main Container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -40, 1, -40)
    container.Position = UDim2.new(0, 20, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    -- Wave Display (Top Center)
    local waveLabel = Instance.new("TextLabel")
    waveLabel.Name = "WaveLabel"
    waveLabel.Size = UDim2.new(0, 200, 0, 50)
    waveLabel.Position = UDim2.new(0.5, -100, 0, 0)
    waveLabel.BackgroundColor3 = Color3.fromHex("#FFD1DC") -- Pastel Pink
    waveLabel.Text = "WAITING FOR WAVE"
    waveLabel.Font = Enum.Font.FredokaOne
    waveLabel.TextSize = 24
    waveLabel.TextColor3 = Color3.new(1, 1, 1)
    waveLabel.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = waveLabel
    
    -- Core Health Bar (Bottom Center)
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Name = "HealthBarBg"
    healthBarBg.Size = UDim2.new(0, 400, 0, 30)
    healthBarBg.Position = UDim2.new(0.5, -200, 1, -40)
    healthBarBg.BackgroundColor3 = Color3.fromHex("#B2E2F2") -- Pastel Blue
    healthBarBg.Parent = container
    
    local healthBarFill = Instance.new("Frame")
    healthBarFill.Name = "Fill"
    healthBarFill.Size = UDim2.new(1, 0, 1, 0)
    healthBarFill.BackgroundColor3 = Color3.fromHex("#FFB7B2") -- Soft Red
    healthBarFill.Parent = healthBarBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 8)
    fillCorner.Parent = healthBarFill
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 8)
    bgCorner.Parent = healthBarBg
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "Label"
    healthLabel.Size = UDim2.new(1, 0, 1, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "CORE HEALTH: 100%"
    healthLabel.Font = Enum.Font.FredokaOne
    healthLabel.TextColor3 = Color3.new(1, 1, 1)
    healthLabel.TextSize = 18
    healthLabel.Parent = healthBarBg

    self.HUD = {
        WaveLabel = waveLabel,
        HealthBarFill = healthBarFill,
        HealthLabel = healthLabel
    }
end

function UIController:ConnectToNet()
    local Remotes = ReplicatedStorage:WaitForChild("Net")
    local CoreUpdate = Remotes:WaitForChild("CoreUpdate")
    local WaveUpdate = Remotes:WaitForChild("WaveUpdate")
    
    CoreUpdate.OnClientEvent:Connect(function(data)
        local percent = math.clamp(data.Health / data.MaxHealth, 0, 1)
        self.HUD.HealthBarFill:TweenSize(UDim2.new(percent, 0, 1, 0), "Out", "Quad", 0.3, true)
        self.HUD.HealthLabel.Text = string.format("CORE HEALTH: %d%%", math.floor(percent * 100))
        
        if data.IsDestroyed then
            self.HUD.HealthLabel.Text = "CORE DESTROYED"
            self.HUD.HealthLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    WaveUpdate.OnClientEvent:Connect(function(data)
        self.HUD.WaveLabel.Text = "WAVE " .. tostring(data.Wave)
        if data.Phase == "Intermission" then
            self.HUD.WaveLabel.Text = "INTERMISSION"
        end
    end)
end

return UIController
