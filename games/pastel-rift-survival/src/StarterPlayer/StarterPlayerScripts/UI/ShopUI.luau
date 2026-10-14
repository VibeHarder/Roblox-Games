--[[
    ShopUI.luau
    Builds the Pastel Shop, sends purchase and equip requests through the
    ShopPurchase RemoteFunction, and renders the server's authoritative
    player data (coins, owned weapons, equipped weapon, upgrade levels).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)

local FONT = Enum.Font.FredokaOne

local COLORS = {
    Panel = Color3.fromHex("#FDFD96"),
    Section = Color3.fromHex("#77DD77"),
    Row = Color3.fromHex("#FFFDF5"),
    Buy = Color3.fromHex("#77DD77"),
    Equip = Color3.fromHex("#89CFF0"),
    Owned = Color3.fromHex("#C9C9C9"),
    Text = Color3.fromHex("#3A3A3A"),
    Subtle = Color3.fromHex("#7A7A7A"),
    Error = Color3.fromHex("#E36A6A"),
    Coins = Color3.fromHex("#C98A00"),
}

local ShopUI = {
    Frame = nil,
    List = nil,
    CoinsLabel = nil,
    StatusLabel = nil,
    _rows = {},
    _data = nil,
    _statusToken = 0,
}

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function addLabel(parent, props)
    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Font = FONT
    text.TextColor3 = COLORS.Text
    text.TextXAlignment = Enum.TextXAlignment.Left
    for key, value in pairs(props) do
        text[key] = value
    end
    text.Parent = parent
    return text
end

local function addButton(parent, props)
    local button = Instance.new("TextButton")
    button.AutoButtonColor = true
    button.Font = FONT
    button.TextSize = 16
    button.TextColor3 = Color3.new(1, 1, 1)
    for key, value in pairs(props) do
        button[key] = value
    end
    button.Parent = parent
    addCorner(button, 8)
    return button
end

function ShopUI:Initialize()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local hud = playerGui:WaitForChild("PastelHUD")

    local net = ReplicatedStorage:WaitForChild("Net")
    self._shopPurchase = net:WaitForChild("ShopPurchase")
    self._dataUpdate = net:WaitForChild("DataUpdate")
    self._requestData = net:WaitForChild("RequestData")

    self:BuildFrame(hud)
    self:BuildRows()
    self:BindEvents()

    -- Pull the current state immediately so the first open is already correct,
    -- even if the initial DataUpdate broadcast was missed.
    self:RequestLatestData()
    self:Refresh()

    print("[ShopUI] Shop initialized. Press B to toggle.")
end

function ShopUI:BuildFrame(hud)
    local frame = Instance.new("Frame")
    frame.Name = "ShopFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.new(0, 560, 0, 440)
    frame.BackgroundColor3 = COLORS.Panel
    frame.Visible = false
    frame.Active = true
    frame.ZIndex = 10
    frame.Parent = hud
    addCorner(frame, 16)

    addLabel(frame, {
        Name = "Title",
        Text = "PASTEL SHOP",
        TextSize = 30,
        TextColor3 = COLORS.Section,
        Size = UDim2.new(0, 300, 0, 38),
        Position = UDim2.new(0, 22, 0, 14),
    })

    local coins = addLabel(frame, {
        Name = "Coins",
        Text = "COINS: --",
        TextSize = 20,
        TextColor3 = COLORS.Coins,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(0, 240, 0, 38),
        Position = UDim2.new(1, -262, 0, 14),
    })

    addLabel(frame, {
        Name = "Hint",
        Text = "Press B to close",
        TextSize = 14,
        TextColor3 = COLORS.Subtle,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(0, 240, 0, 18),
        Position = UDim2.new(1, -262, 0, 50),
    })

    local list = Instance.new("ScrollingFrame")
    list.Name = "Items"
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.Position = UDim2.new(0, 22, 0, 78)
    list.Size = UDim2.new(1, -44, 1, -148)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollBarThickness = 6
    list.ScrollBarImageColor3 = COLORS.Section
    list.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    local status = addLabel(frame, {
        Name = "Status",
        Text = "",
        TextSize = 15,
        Size = UDim2.new(1, -44, 0, 22),
        Position = UDim2.new(0, 22, 1, -36),
    })

    self.Frame = frame
    self.List = list
    self.CoinsLabel = coins
    self.StatusLabel = status
end

function ShopUI:BuildRows()
    self._rows = {}

    local function addSection(title, layoutOrder)
        addLabel(self.List, {
            Name = "Section",
            Text = title,
            TextSize = 18,
            TextColor3 = COLORS.Section,
            Size = UDim2.new(1, 0, 0, 26),
            LayoutOrder = layoutOrder,
        })
    end

    local function addRow(category, id, name, description, layoutOrder)
        local row = Instance.new("Frame")
        row.Name = category .. "_" .. name
        row.BackgroundColor3 = COLORS.Row
        row.Size = UDim2.new(1, 0, 0, 64)
        row.LayoutOrder = layoutOrder
        row.Parent = self.List
        addCorner(row, 10)

        addLabel(row, {
            Name = "Name",
            Text = name,
            TextSize = 18,
            Size = UDim2.new(1, -170, 0, 22),
            Position = UDim2.new(0, 14, 0, 8),
        })

        addLabel(row, {
            Name = "Description",
            Text = description,
            TextSize = 13,
            TextColor3 = COLORS.Subtle,
            Size = UDim2.new(1, -170, 0, 18),
            Position = UDim2.new(0, 14, 0, 30),
        })

        local detail = addLabel(row, {
            Name = "Detail",
            Text = "",
            TextSize = 13,
            TextColor3 = COLORS.Subtle,
            Size = UDim2.new(1, -170, 0, 16),
            Position = UDim2.new(0, 14, 0, 46),
        })

        local action = addButton(row, {
            Name = "Action",
            Text = "BUY",
            Size = UDim2.new(0, 128, 0, 38),
            Position = UDim2.new(1, -142, 0.5, -19),
        })

        action.Activated:Connect(function()
            self:OnAction(category, id)
        end)

        table.insert(self._rows, {
            Category = category,
            Id = id,
            Detail = detail,
            Button = action,
        })
    end

    addSection("WEAPONS", 99)
    local weaponOrder = 100
    for _, weapon in ipairs(UpgradeConfig.Weapons) do
        weaponOrder += 1
        addRow("Weapon", weapon.Name, weapon.Name, weapon.Description, weaponOrder)
    end

    addSection("CORE UPGRADES", 199)
    local upgradeOrder = 200
    for _, upgrade in ipairs(UpgradeConfig.Upgrades) do
        upgradeOrder += 1
        addRow("Upgrade", upgrade.Id, upgrade.Name, upgrade.Description, upgradeOrder)
    end
end

function ShopUI:BindEvents()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.B then
            self:Toggle()
        end
    end)

    self._dataUpdate.OnClientEvent:Connect(function(data)
        self._data = data
        self:Refresh()
    end)
end

function ShopUI:Toggle()
    self.Frame.Visible = not self.Frame.Visible
    if self.Frame.Visible then
        self:RequestLatestData()
        self:Refresh()
    end
end

function ShopUI:RequestLatestData()
    local ok, data = pcall(function()
        return self._requestData:InvokeServer()
    end)
    if ok and data then
        self._data = data
    end
end

function ShopUI:Refresh()
    local data = self._data
    if not data then return end

    self.CoinsLabel.Text = "COINS: " .. tostring(data.Coins)

    for _, row in ipairs(self._rows) do
        local button = row.Button

        if row.Category == "Weapon" then
            local weapon = UpgradeConfig.GetWeapon(row.Id)
            local owned = data.UnlockedWeapons and data.UnlockedWeapons[row.Id]
            local equipped = data.EquippedWeapon == row.Id

            row.Detail.Text = string.format(
                "Damage %d   |   Cooldown %.1fs",
                weapon.BaseDamage,
                weapon.BaseCooldown
            )

            if equipped then
                button.Text = "EQUIPPED"
                button.BackgroundColor3 = COLORS.Owned
            elseif owned then
                button.Text = "EQUIP"
                button.BackgroundColor3 = COLORS.Equip
            else
                button.Text = "BUY " .. tostring(weapon.Cost)
                button.BackgroundColor3 = COLORS.Buy
            end
        else
            local upgrade = UpgradeConfig.GetUpgrade(row.Id)
            local level = (data.PermanentUpgrades and data.PermanentUpgrades[row.Id]) or 0
            local cost = upgrade.BaseCost * (level + 1)

            row.Detail.Text = string.format("Level %d   |   Next costs %d Coins", level, cost)
            button.Text = "BUY " .. tostring(cost)
            button.BackgroundColor3 = COLORS.Buy
        end
    end
end

function ShopUI:OnAction(category, id)
    local data = self._data

    -- Clicking an owned weapon equips it instead of trying to buy it again.
    local requestCategory = category
    if category == "Weapon" and data and data.UnlockedWeapons and data.UnlockedWeapons[id] then
        requestCategory = "Equip"
    end

    local ok, success, message = pcall(function()
        return self._shopPurchase:InvokeServer(requestCategory, id)
    end)

    if not ok then
        self:SetStatus("Request failed: " .. tostring(success), COLORS.Error)
        return
    end

    if success then
        self:SetStatus(tostring(message), COLORS.Section)
    else
        self:SetStatus(tostring(message), COLORS.Error)
    end
end

function ShopUI:SetStatus(text, color)
    self._statusToken += 1
    local token = self._statusToken

    self.StatusLabel.Text = text
    self.StatusLabel.TextColor3 = color or COLORS.Text

    task.delay(3, function()
        if self._statusToken == token then
            self.StatusLabel.Text = ""
        end
    end)
end

return ShopUI
