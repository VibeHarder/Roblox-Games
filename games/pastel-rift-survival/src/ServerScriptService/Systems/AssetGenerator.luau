--[[
    AssetGenerator.luau
    This script runs on the server to programmatically build the visual assets
    since we are in a code-only environment. In Studio, these would be models.
]]

local AssetGenerator = {}

function AssetGenerator:GenerateAll()
    self:CreatePastelCoreModel()
    self:CreateEnemyTemplates()
end

function AssetGenerator:CreatePastelCoreModel()
    local coreModel = Instance.new("Model")
    coreModel.Name = "PastelCore"
    
    local crystal = Instance.new("Part")
    crystal.Name = "Crystal"
    crystal.Size = Vector3.new(4, 8, 4)
    crystal.Shape = Enum.PartType.Ball -- Simplified for code; would be a Mesh in Studio
    crystal.Color = Color3.fromHex("#FFD1DC")
    crystal.Material = Enum.Material.Neon
    crystal.Anchored = true
    crystal.Position = Vector3.new(0, 4, 0)
    crystal.Parent = coreModel
    
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(10, 1, 10)
    base.Color = Color3.fromHex("#B2E2F2")
    base.Material = Enum.Material.SmoothPlastic
    base.Anchored = true
    base.Position = Vector3.new(0, 0.5, 0)
    base.Parent = coreModel
    
    coreModel.PrimaryPart = crystal
    coreModel.Parent = workspace
    print("[AssetGenerator] Created Pastel Core Model")
end

function AssetGenerator:CreateEnemyTemplates()
    local folder = Instance.new("Folder")
    folder.Name = "EnemyTemplates"
    folder.Parent = game:GetService("ServerStorage")
    
    -- Glitch Enemy
    local glitch = Instance.new("Model")
    glitch.Name = "Glitch"
    local body = Instance.new("Part")
    body.Size = Vector3.new(2, 2, 2)
    body.Color = Color3.fromHex("#E0BBE4") -- Pastel Purple
    body.Material = Enum.Material.Neon
    body.Parent = glitch
    glitch.PrimaryPart = body
    glitch.Parent = folder
    
    -- Pastel Crawler
    local crawler = Instance.new("Model")
    crawler.Name = "PastelCrawler"
    local cBody = Instance.new("Part")
    cBody.Size = Vector3.new(3, 1, 3)
    cBody.Color = Color3.fromHex("#FFFFD1") -- Pastel Yellow
    cBody.Material = Enum.Material.SmoothPlastic
    cBody.Parent = crawler
    crawler.PrimaryPart = cBody
    crawler.Parent = folder
    
    print("[AssetGenerator] Created Enemy Templates in ServerStorage")
end

return AssetGenerator
