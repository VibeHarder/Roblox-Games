--[[
    ShopUI.luau
    Handles the graphical shop interface and purchase requests.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)

local ShopUI = {}

function ShopUI:Initialize()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local hud = playerGui:WaitForChild("PastelHUD")
    
    local shopFrame = Instance.new("Frame")
    shopFrame.Name = "ShopFrame"
    shopFrame.Size = UDim2.new(0, 500, 0, 400)
    shopFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    shopFrame.BackgroundColor3 = Color3.fromHex("#FDFD96") -- Pastel Yellow
    shopFrame.Visible = false
    shopFrame.Parent = hud
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = shopFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "PASTEL SHOP"
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 32
    title.TextColor3 = Color3.fromHex("#77DD77") -- Pastel Green
    title.Parent = shopFrame

    -- Simple list for items (in a real game, this would be a ScrollingFrame)
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Parent = shopFrame
    
    -- Interaction to open shop (e.g., pressing 'B')
    game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.B then
            shopFrame.Visible = not shopFrame.Visible
        end
    end)
    
    print("[ShopUI] Shop Initialized. Press 'B' to toggle.")
end

return ShopUI
