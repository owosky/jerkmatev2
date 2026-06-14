local repo = 'https://raw.githubusercontent.com/smi9/LinoriaLib/refs/heads/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- ==========================================
-- LOAD STANDALONE DRAWING POLYFILL
-- ==========================================
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/smi9/UnnamedCheats/refs/heads/main/drawing.lua"))()
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- VISUALS CONFIGURATION & DATA STORAGE
-- ==========================================
local Settings = {
    ESP = {
        Enabled = false,
        TeamCheck = false,
        VisibleCheck = false,
        SpawnDelay = 0.5,
        MaxDistance = 1000,
        TextFont = 3,
        Highlight = {
            Enabled = false,
            UseTeamColor = false,
            FillColor = Color3.fromRGB(255, 0, 0),
            FillTransparency = 0.5,
            OutlineColor = Color3.fromRGB(255, 255, 255),
            OutlineTransparency = 0
        },
        Boxes = {
            Enabled = false,
            Transparency = 0.2,
            Thickness = 1,
            Fill = false,
            FillTransparency = 0.2,
            GradientLerp = 1,
            GradientColor1 = Color3.fromRGB(255, 255, 255),
            GradientColor2 = Color3.fromRGB(255, 255, 255),
            GradientColor3 = Color3.fromRGB(255, 255, 255),
            GradientRotation = 90,
            GradientMoving = false,
            GradientSpeed = 1
        },
        Healthbar = {
            Enabled = false,
            Transparency = 0.2,
            Thickness = 1,
            GradientLerp = 1,
            GradientColor1 = Color3.fromRGB(0, 255, 0),
            GradientColor2 = Color3.fromRGB(255, 255, 255),
            GradientColor3 = Color3.fromRGB(255, 255, 255),
            GradientRotation = 90
        },
        Skeleton = {
            Enabled = false,
            Transparency = 0.2,
            Thickness = 1,
            GradientLerp = 1,
            GradientColor1 = Color3.fromRGB(255, 255, 255),
            GradientColor2 = Color3.fromRGB(255, 255, 255),
            GradientColor3 = Color3.fromRGB(255, 255, 255),
            GradientRotation = 90,
            GradientMoving = false,
            GradientSpeed = 1
        },
        Names = { Enabled = false, UseDisplayName = true, Size = 13, Color = Color3.fromRGB(255, 255, 255), Transparency = 1 },
        Weapon = { Enabled = false, Size = 13, Color = Color3.fromRGB(200, 200, 200), Transparency = 1 },
        Distance = { Enabled = false, Size = 13, Color = Color3.fromRGB(255, 255, 255), Transparency = 1 }
    },
    SelfChams = {
        Enabled = false,
        Character = true,
        Weapon = true,
        Material = Enum.Material.ForceField,
        CharColor = Color3.fromRGB(0, 255, 255),
        WeaponColor = Color3.fromRGB(255, 0, 0)
    },
    Desync = {
        ShowServerPosition = false,
        ServerPosition = Vector3.new(0, 0, 0),
        ServerCFrame = CFrame.new(),
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 1,
        Radius = 4,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineThickness = 2,
        CharacterClone = false,
        CloneMaterial = Enum.Material.Neon,
        CloneColor = Color3.fromRGB(0, 128, 255),
        CloneTransparency = 0.5,
        Highlight = {
            Enabled = false,
            FillColor = Color3.fromRGB(0, 0, 255),
            FillTransparency = 0.5,
            OutlineColor = Color3.fromRGB(0, 255, 255),
            OutlineTransparency = 0
        }
    },
    FOV = {
        Enabled = false,
        Radius = 100,
        Position = Vector2.new(0, 0),
        Transparency = 0.2,
        Thickness = 1,

        Filled = false,
        FillTransparency = 0.2,
        Sides = 64,
        GradientLerp = 1,
        GradientColor1 = Color3.fromRGB(255, 255, 255),
        GradientColor2 = Color3.fromRGB(255, 255, 255),
        GradientColor3 = Color3.fromRGB(255, 255, 255),
        GradientRotation = 90,
        GradientMoving = false,
        GradientSpeed = 1
    },
    Crosshair = {
        Enabled = false,
        Position = "Center",
        Size = 10,
        Gap = 5,
        Thickness = 1,

        RotationSpeed = 0,
        BounceSpeed = 0,
        BounceAmplitude = 5,
        Colors = { Top = Color3.fromRGB(255, 0, 0), Bottom = Color3.fromRGB(0, 255, 0), Left = Color3.fromRGB(0, 0, 255), Right = Color3.fromRGB(255, 255, 0) },
        Transparency = 1
    }
}

local Drawings = {
    FOV = { Outline = Drawing.new("Circle"), Main = Drawing.new("Circle"), Fill = Drawing.new("Circle") },
    Crosshair = {
        Main = { Top = Drawing.new("Line"), Bottom = Drawing.new("Line"), Left = Drawing.new("Line"), Right = Drawing.new("Line") },
        Outline = { Top = Drawing.new("Line"), Bottom = Drawing.new("Line"), Left = Drawing.new("Line"), Right = Drawing.new("Line") }
    },
    Desync = {
        ServerPositionMain = Drawing.new("Circle"),
        ServerPositionOutline = Drawing.new("Circle"),
        CloneModel = nil,
        Highlight = nil
    },
    Players = {}
}

local R15Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local R6Bones = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"}
}


Drawings.FOV.Outline.ZIndex = 1
Drawings.FOV.Main.ZIndex = 2
Drawings.FOV.Fill.ZIndex = 0

Drawings.Desync.ServerPositionOutline.ZIndex = 1
Drawings.Desync.ServerPositionMain.ZIndex = 2

local Connections = {}

-- ==========================================
-- UI WINDOW CREATION
-- ==========================================
local Window = Library:CreateWindow({
    Title = 'Visuals Hub',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Aim = Window:AddTab('Aim'),
    Visuals = Window:AddTab('Visuals'),
    Desync = Window:AddTab('Desync'),
    HBE = Window:AddTab('HBE'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

-- Initialize Managers Early to Prevent Nil Indexing Crashes
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder('VisualsHub')
SaveManager:SetFolder('VisualsHub/configs')

Settings.Crosshair.Position = "Mouse"

-- ==========================================
-- ALPHA / TRANSPARENCY HELPERS
-- ==========================================
local function GetAlpha(pickerName)
    if Options and Options[pickerName] and Options[pickerName].Transparency then
        return 1 - Options[pickerName].Transparency
    end
    return 1 
end

local function GetHighlightAlpha(pickerName, defaultVal)
    if Options and Options[pickerName] and Options[pickerName].Transparency then
        return Options[pickerName].Transparency
    end
    return defaultVal or 0.5
end

-- ==========================================
-- VISUALS TAB LOGIC
-- ==========================================
local CrosshairGroup = Tabs.Visuals:AddLeftGroupbox('Crosshair')
local SkyboxGroup = Tabs.Visuals:AddLeftGroupbox('Environment') 
local SelfChamsGroup = Tabs.Visuals:AddLeftGroupbox('Self Material (Forcefield)') 

local ESPGroup = Tabs.Visuals:AddRightGroupbox('ESP Settings')
local HighlightGroup = Tabs.Visuals:AddRightGroupbox('Highlights (Chams)')
local TextGroup = Tabs.Visuals:AddRightGroupbox('Text & Fonts')

-- Crosshair Settings
CrosshairGroup:AddToggle('EnableCrosshair', { Text = 'Enable Crosshair', Default = false, Callback = function(v) Settings.Crosshair.Enabled = v end })
CrosshairGroup:AddSlider('CrosshairThickness', { Text = 'Thickness', Default = 1, Min = 1, Max = 5, Rounding = 0, Compact = true, Callback = function(v) Settings.Crosshair.Thickness = v end })

local CHColorsLabel = CrosshairGroup:AddLabel('Crosshair Colors (T/B/L/R)')
CHColorsLabel:AddColorPicker('CrosshairTop', { Default = Color3.fromRGB(255, 0, 0), Transparency = 0, Title = 'Top Color (Master Opacity)', Callback = function(Color) Settings.Crosshair.Colors.Top = Color; Settings.Crosshair.Transparency = GetAlpha('CrosshairTop') end })
CHColorsLabel:AddColorPicker('CrosshairBottom', { Default = Color3.fromRGB(0, 255, 0), Transparency = 0, Title = 'Bottom Color', Callback = function(Color) Settings.Crosshair.Colors.Bottom = Color end })
CHColorsLabel:AddColorPicker('CrosshairLeft', { Default = Color3.fromRGB(0, 0, 255), Transparency = 0, Title = 'Left Color', Callback = function(Color) Settings.Crosshair.Colors.Left = Color end })
CHColorsLabel:AddColorPicker('CrosshairRight', { Default = Color3.fromRGB(255, 255, 0), Transparency = 0, Title = 'Right Color', Callback = function(Color) Settings.Crosshair.Colors.Right = Color end })

CrosshairGroup:AddDropdown('CrosshairPosition', { Values = { 'Mouse', 'Center' }, Default = 1, Multi = false, Text = 'Follow Position', Callback = function(v) Settings.Crosshair.Position = v end })
CrosshairGroup:AddSlider('CrosshairSize', { Text = 'Size', Default = 10, Min = 1, Max = 50, Rounding = 0, Compact = true, Callback = function(v) Settings.Crosshair.Size = v end })
CrosshairGroup:AddSlider('CrosshairGap', { Text = 'Gap', Default = 5, Min = 0, Max = 50, Rounding = 0, Compact = true, Callback = function(v) Settings.Crosshair.Gap = v end })
CrosshairGroup:AddSlider('CrosshairRot', { Text = 'Rotation Speed', Default = 0, Min = 0, Max = 20, Rounding = 1, Compact = true, Callback = function(v) Settings.Crosshair.RotationSpeed = v end })
CrosshairGroup:AddSlider('CrosshairBounce', { Text = 'Bounce Speed', Default = 0, Min = 0, Max = 20, Rounding = 1, Compact = true, Callback = function(v) Settings.Crosshair.BounceAmplitude = v end })

-- Skybox Settings
local customSky = Instance.new("Sky")
customSky.Name = "CustomLinoriaSky"

local SkyboxImages = {
    ["SpongeBob"] = "https://upload.wikimedia.org/wikipedia/commons/7/7a/SpongeBob_SquarePants_character.png",
    ["SpongeBob Sky"] = "https://i.pinimg.com/474x/44/83/70/448370d8b3549c61e7110a365c71ebcb.jpg"
}

local function getSkyboxAsset(name, url)
    local filename = name:gsub("%s+", "_") .. ".png"
    if not isfile(filename) then writefile(filename, game:HttpGet(url)) end
    return getcustomasset(filename)
end

local function applySkybox()
    local selected = Options.SkyboxSelector.Value
    if selected and SkyboxImages[selected] then
        local assetId = getSkyboxAsset(selected, SkyboxImages[selected])
        customSky.SkyboxBk, customSky.SkyboxDn, customSky.SkyboxFt = assetId, assetId, assetId
        customSky.SkyboxLf, customSky.SkyboxRt, customSky.SkyboxUp = assetId, assetId, assetId
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") and obj ~= customSky then obj.Parent = nil end
        end
        customSky.Parent = Lighting
    end
end

table.insert(Connections, Lighting.ChildAdded:Connect(function(child)
    if Toggles.EnableSkybox and Toggles.EnableSkybox.Value and child:IsA("Sky") and child ~= customSky then
        task.wait()
        child.Parent = nil
        applySkybox()
    end
end))

SkyboxGroup:AddToggle('EnableSkybox', { Text = 'Custom Skybox', Default = false, Callback = function(Value) if Value then applySkybox() else customSky.Parent = nil end end }):AddKeyPicker('SkyboxKeybind', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Custom Skybox', NoUI = false })
SkyboxGroup:AddDropdown('SkyboxSelector', { Values = { 'SpongeBob', 'SpongeBob Sky' }, Default = 1, Multi = false, Text = 'Skybox Texture', Callback = function() if Toggles.EnableSkybox.Value then applySkybox() end end })

-- Self Materials (Forcefield)
local SelfChamsToggle = SelfChamsGroup:AddToggle('SelfChamsToggle', { Text = 'Enable Self Forcefield', Default = false, Callback = function(v) Settings.SelfChams.Enabled = v end })
SelfChamsGroup:AddToggle('SelfChamsChar', { Text = 'Apply to Character', Default = true, Callback = function(v) Settings.SelfChams.Character = v end })
SelfChamsGroup:AddToggle('SelfChamsWeap', { Text = 'Apply to Weapon', Default = true, Callback = function(v) Settings.SelfChams.Weapon = v end })
SelfChamsToggle:AddColorPicker('SelfChamsCharColor', { Default = Color3.fromRGB(0, 255, 255), Title = 'Character Color', Callback = function(Color) Settings.SelfChams.CharColor = Color end })
SelfChamsToggle:AddColorPicker('SelfChamsWeapColor', { Default = Color3.fromRGB(255, 0, 0), Title = 'Weapon Color', Callback = function(Color) Settings.SelfChams.WeaponColor = Color end })

-- ESP Controls
ESPGroup:AddToggle('ESPEnabled', { Text = 'Enable ESP', Default = false, Callback = function(v) Settings.ESP.Enabled = v end })
ESPGroup:AddToggle('ESPTeamCheck', { Text = 'Team Check', Default = false, Callback = function(v) Settings.ESP.TeamCheck = v end })
ESPGroup:AddToggle('ESPVisCheck', { Text = 'Visible Check', Default = false, Callback = function(v) Settings.ESP.VisibleCheck = v end })
ESPGroup:AddSlider('ESPMaxDistance', { Text = 'Render Distance', Default = 1000, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) Settings.ESP.MaxDistance = v end })
ESPGroup:AddSlider('ESPSpawnDelay', { Text = 'Spawn Delay (s)', Default = 0.5, Min = 0.0, Max = 3.0, Rounding = 1, Callback = function(v) Settings.ESP.SpawnDelay = v end })
ESPGroup:AddDivider()

local BoxToggle = ESPGroup:AddToggle('ESPBoxes', { Text = 'Draw Boxes', Default = false, Callback = function(v) Settings.ESP.Boxes.Enabled = v end })
BoxToggle:AddColorPicker('BoxGrad1Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 1', Callback = function(Color) Settings.ESP.Boxes.GradientColor1 = Color; Settings.ESP.Boxes.Transparency = GetAlpha('BoxGrad1Color') end })
BoxToggle:AddColorPicker('BoxGrad2Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 2', Callback = function(Color) Settings.ESP.Boxes.GradientColor2 = Color end })
BoxToggle:AddColorPicker('BoxGrad3Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 3', Callback = function(Color) Settings.ESP.Boxes.GradientColor3 = Color end })

ESPGroup:AddSlider('BoxThickness', { Text = 'Box Thickness', Default = 1, Min = 1, Max = 5, Rounding = 0, Compact = true, Callback = function(v) Settings.ESP.Boxes.Thickness = v end })

ESPGroup:AddToggle('ESPBoxesFill', { Text = 'Box Fill', Default = false, Callback = function(v) Settings.ESP.Boxes.Fill = v end })

ESPGroup:AddSlider('BoxGradLerp', { Text = 'Gradient Lerp', Default = 1, Min = 0, Max = 1, Rounding = 2, Compact = true, Callback = function(v) Settings.ESP.Boxes.GradientLerp = v end })
ESPGroup:AddToggle('BoxGradMoving', { Text = 'Moving Rotation', Default = false, Callback = function(v) Settings.ESP.Boxes.GradientMoving = v end })
ESPGroup:AddSlider('BoxGradSpeed', { Text = 'Rotation Speed', Default = 1, Min = 0.1, Max = 10, Rounding = 1, Compact = true, Callback = function(v) Settings.ESP.Boxes.GradientSpeed = v end })
ESPGroup:AddSlider('BoxGradRotation', { Text = 'Gradient Rotation', Default = 90, Min = 0, Max = 360, Rounding = 0, Compact = true, Callback = function(v) Settings.ESP.Boxes.GradientRotation = v end })
ESPGroup:AddDivider()

local ESPHealthToggle = ESPGroup:AddToggle('ESPHealth', { Text = 'Draw Health', Default = false, Callback = function(v) Settings.ESP.Healthbar.Enabled = v end })
ESPHealthToggle:AddColorPicker('HealthGrad1Color', { Default = Color3.fromRGB(0, 255, 0), Transparency = 0.2, Title = 'Gradient Color 1', Callback = function(Color) Settings.ESP.Healthbar.GradientColor1 = Color; Settings.ESP.Healthbar.Transparency = GetAlpha('HealthGrad1Color') end })
ESPHealthToggle:AddColorPicker('HealthGrad2Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 2', Callback = function(Color) Settings.ESP.Healthbar.GradientColor2 = Color end })
ESPHealthToggle:AddColorPicker('HealthGrad3Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 3', Callback = function(Color) Settings.ESP.Healthbar.GradientColor3 = Color end })

ESPGroup:AddSlider('HealthGradLerp', { Text = 'Gradient Lerp', Default = 1, Min = 0, Max = 1, Rounding = 2, Compact = true, Callback = function(v) Settings.ESP.Healthbar.GradientLerp = v end })
ESPGroup:AddSlider('HealthGradRotation', { Text = 'Gradient Rotation', Default = 90, Min = 0, Max = 360, Rounding = 0, Compact = true, Callback = function(v) Settings.ESP.Healthbar.GradientRotation = v end })
ESPGroup:AddDivider()

local ESPSkeletonToggle = ESPGroup:AddToggle('ESPSkeleton', { Text = 'Draw Skeleton', Default = false, Callback = function(v) Settings.ESP.Skeleton.Enabled = v end })
ESPSkeletonToggle:AddColorPicker('SkeletonGrad1Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 1', Callback = function(Color) Settings.ESP.Skeleton.GradientColor1 = Color; Settings.ESP.Skeleton.Transparency = GetAlpha('SkeletonGrad1Color') end })
ESPSkeletonToggle:AddColorPicker('SkeletonGrad2Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 2', Callback = function(Color) Settings.ESP.Skeleton.GradientColor2 = Color end })
ESPSkeletonToggle:AddColorPicker('SkeletonGrad3Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 3', Callback = function(Color) Settings.ESP.Skeleton.GradientColor3 = Color end })

ESPGroup:AddSlider('SkeletonThickness', { Text = 'Skeleton Thickness', Default = 1, Min = 1, Max = 5, Rounding = 0, Compact = true, Callback = function(v) Settings.ESP.Skeleton.Thickness = v end })
ESPGroup:AddSlider('SkeletonGradLerp', { Text = 'Gradient Lerp', Default = 1, Min = 0, Max = 1, Rounding = 2, Compact = true, Callback = function(v) Settings.ESP.Skeleton.GradientLerp = v end })
ESPGroup:AddToggle('SkeletonGradMoving', { Text = 'Moving Rotation', Default = false, Callback = function(v) Settings.ESP.Skeleton.GradientMoving = v end })
ESPGroup:AddSlider('SkeletonGradSpeed', { Text = 'Rotation Speed', Default = 1, Min = 0.1, Max = 10, Rounding = 1, Compact = true, Callback = function(v) Settings.ESP.Skeleton.GradientSpeed = v end })
ESPGroup:AddSlider('SkeletonGradRotation', { Text = 'Gradient Rotation', Default = 90, Min = 0, Max = 360, Rounding = 0, Compact = true, Callback = function(v) Settings.ESP.Skeleton.GradientRotation = v end })
ESPGroup:AddDivider()

ESPGroup:AddDropdown('ESPNameType', { Values = { 'Display Name', 'Username' }, Default = 1, Multi = false, Text = 'Name Display Type', Callback = function(v) Settings.ESP.Names.UseDisplayName = (v == 'Display Name') end })
ESPGroup:AddToggle('ESPName', { Text = 'Draw Name', Default = false, Callback = function(v) Settings.ESP.Names.Enabled = v end }):AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0, Title = 'Name Color', Callback = function(Color) Settings.ESP.Names.Color = Color; Settings.ESP.Names.Transparency = GetAlpha('NameColor') end })
ESPGroup:AddToggle('ESPWeapon', { Text = 'Draw Weapon', Default = false, Callback = function(v) Settings.ESP.Weapon.Enabled = v end }):AddColorPicker('WeaponColor', { Default = Color3.fromRGB(200, 200, 200), Transparency = 0, Title = 'Weapon Color', Callback = function(Color) Settings.ESP.Weapon.Color = Color; Settings.ESP.Weapon.Transparency = GetAlpha('WeaponColor') end })
ESPGroup:AddToggle('ESPDistance', { Text = 'Draw Distance', Default = false, Callback = function(v) Settings.ESP.Distance.Enabled = v end }):AddColorPicker('DistanceColor', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0, Title = 'Distance Color', Callback = function(Color) Settings.ESP.Distance.Color = Color; Settings.ESP.Distance.Transparency = GetAlpha('DistanceColor') end })

-- Highlights (Chams)
local HighlightToggle = HighlightGroup:AddToggle('HighlightToggle', { Text = 'Enable Highlights', Default = false, Callback = function(v) Settings.ESP.Highlight.Enabled = v end })
HighlightToggle:AddColorPicker('HighlightFill', { Default = Color3.fromRGB(255, 0, 0), Title = 'Fill Color', Transparency = 0.5 })
HighlightToggle:AddColorPicker('HighlightOut', { Default = Color3.fromRGB(255, 255, 255), Title = 'Outline Color', Transparency = 0 })

-- Safe Live Updates for ESP Highlights
task.spawn(function()
    repeat task.wait() until Options and Options.HighlightFill
    Options.HighlightFill:OnChanged(function()
        Settings.ESP.Highlight.FillColor = Options.HighlightFill.Value
        Settings.ESP.Highlight.FillTransparency = Options.HighlightFill.Transparency or 0.5
    end)
    Options.HighlightOut:OnChanged(function()
        Settings.ESP.Highlight.OutlineColor = Options.HighlightOut.Value
        Settings.ESP.Highlight.OutlineTransparency = Options.HighlightOut.Transparency or 0
    end)
end)

HighlightGroup:AddToggle('HighlightTeamColor', { Text = 'Use Team Color', Default = false, Callback = function(v) Settings.ESP.Highlight.UseTeamColor = v end })

-- Global Fonts
TextGroup:AddDropdown('TextFontDropdown', {
    Values = { 'UI', 'System', 'Plex', 'Monospace' },
    Default = 4, 
    Multi = false, 
    Text = 'Global ESP Font',
    Callback = function(v)
        local fontMap = { ['UI'] = 0, ['System'] = 1, ['Plex'] = 2, ['Monospace'] = 3 }
        Settings.ESP.TextFont = fontMap[v] or 3
    end
})

-- ==========================================
-- AIM TAB LOGIC
-- ==========================================
local AimGroup = Tabs.Aim:AddLeftGroupbox('Main & Smoothing')
local FOVGroup = Tabs.Aim:AddRightGroupbox('FOV & Checks')

AimGroup:AddToggle('AimAssist', { Text = 'Enable Aim Assist', Default = false }):AddKeyPicker('AimKeybind', { Default = 'None', SyncToggleState = false, Mode = 'Hold', Text = 'Aim Assist Key', NoUI = false })
AimGroup:AddDropdown('AimMethod', { Values = { 'MouseMoverel', 'Camera' }, Default = 1, Multi = false, Text = 'Aim Method' })
AimGroup:AddDropdown('TargetParts', { Values = { 'Head', 'HumanoidRootPart', 'Torso', 'UpperTorso', 'LowerTorso' }, Default = 2, Multi = true, Text = 'Target Parts' })
AimGroup:AddToggle('StickyAim', { Text = 'Sticky Aim', Default = false })
AimGroup:AddDivider()
AimGroup:AddToggle('EnableDistanceComp', { Text = 'Distance Drop Compensation', Default = false })
AimGroup:AddSlider('DistanceMultiplier', { Text = 'Drop Multiplier', Default = 0.05, Min = 0, Max = 1, Rounding = 3, Compact = true })
AimGroup:AddDivider()
AimGroup:AddToggle('EnablePrediction', { Text = 'Enable Prediction', Default = false })
AimGroup:AddSlider('PredictionX', { Text = 'Prediction X', Default = 0.15, Min = 0, Max = 1, Rounding = 3, Compact = true })
AimGroup:AddSlider('PredictionY', { Text = 'Prediction Y', Default = 0.15, Min = 0, Max = 1, Rounding = 3, Compact = true })
AimGroup:AddToggle('EnableSmoothness', { Text = 'Enable Smoothness', Default = false })
AimGroup:AddSlider('SmoothnessAmount', { Text = 'Smoothness Amount', Default = 5, Min = 1, Max = 20, Rounding = 1, Compact = true })

FOVGroup:AddToggle('EnableFOV', { Text = 'Enable FOV Limit', Default = true })

local DrawFOVCircle = FOVGroup:AddToggle('DrawFOVCircle', { Text = 'Draw FOV Circle', Default = false, Callback = function(v) Settings.FOV.Enabled = v end })
DrawFOVCircle:AddColorPicker('FOVGrad1Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 1', Callback = function(Color) Settings.FOV.GradientColor1 = Color; Settings.FOV.Transparency = GetAlpha('FOVGrad1Color') end })
DrawFOVCircle:AddColorPicker('FOVGrad2Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 2', Callback = function(Color) Settings.FOV.GradientColor2 = Color end })
DrawFOVCircle:AddColorPicker('FOVGrad3Color', { Default = Color3.fromRGB(255, 255, 255), Transparency = 0.2, Title = 'Gradient Color 3', Callback = function(Color) Settings.FOV.GradientColor3 = Color end })

local DrawFOVFill = FOVGroup:AddToggle('DrawFOVFill', { Text = 'Draw FOV Fill', Default = false, Callback = function(v) Settings.FOV.Filled = v end })

FOVGroup:AddSlider('FOVRadius', { Text = 'FOV Radius', Default = 100, Min = 10, Max = 800, Rounding = 0, Compact = true, Callback = function(v) Settings.FOV.Radius = v end })
FOVGroup:AddSlider('FOVThickness', { Text = 'FOV Thickness', Default = 1, Min = 1, Max = 5, Rounding = 0, Compact = true, Callback = function(v) Settings.FOV.Thickness = v end })

FOVGroup:AddSlider('FOVGradLerp', { Text = 'Gradient Lerp', Default = 1, Min = 0, Max = 1, Rounding = 2, Compact = true, Callback = function(v) Settings.FOV.GradientLerp = v end })
FOVGroup:AddToggle('FOVGradMoving', { Text = 'Moving Rotation', Default = false, Callback = function(v) Settings.FOV.GradientMoving = v end })
FOVGroup:AddSlider('FOVGradSpeed', { Text = 'Rotation Speed', Default = 1, Min = 0.1, Max = 10, Rounding = 1, Compact = true, Callback = function(v) Settings.FOV.GradientSpeed = v end })
FOVGroup:AddSlider('FOVGradRotation', { Text = 'Gradient Rotation', Default = 90, Min = 0, Max = 360, Rounding = 0, Compact = true, Callback = function(v) Settings.FOV.GradientRotation = v end })
FOVGroup:AddDivider()

FOVGroup:AddToggle('VisibleCheck', { Text = 'Visible Check', Default = true })
FOVGroup:AddToggle('TeamCheck', { Text = 'Team Check', Default = true })
FOVGroup:AddToggle('HealthCheck', { Text = 'Health Check', Default = true })

-- ==========================================
-- DESYNC TAB LOGIC
-- ==========================================
local DesyncGroup = Tabs.Desync:AddLeftGroupbox('Network & Desync')
DesyncGroup:AddToggle('RaknetDesyncEnabled', { Text = 'Enable Raknet Desync', Default = false }):AddKeyPicker('RaknetDesyncKey', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Raknet Desync', NoUI = false })

local OffsetGroup = Tabs.Desync:AddLeftGroupbox('Offset')
OffsetGroup:AddToggle('OffsetEnabled', { Text = 'Enable Offset', Default = false }):AddKeyPicker('OffsetKey', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Offset Bind', NoUI = false })
OffsetGroup:AddToggle('OffsetAntiClip', { Text = 'Anti Clip', Default = true })
OffsetGroup:AddSlider('OffsetXMin', { Text = 'X Min', Default = 0, Min = -50, Max = 50, Rounding = 0 })
OffsetGroup:AddSlider('OffsetXMax', { Text = 'X Max', Default = 0, Min = -50, Max = 50, Rounding = 0 })
OffsetGroup:AddSlider('OffsetYMin', { Text = 'Y Min', Default = 0, Min = -50, Max = 50, Rounding = 0 })
OffsetGroup:AddSlider('OffsetYMax', { Text = 'Y Max', Default = 0, Min = -50, Max = 50, Rounding = 0 })
OffsetGroup:AddSlider('OffsetZMin', { Text = 'Z Min', Default = 0, Min = -50, Max = 50, Rounding = 0 })
OffsetGroup:AddSlider('OffsetZMax', { Text = 'Z Max', Default = 0, Min = -50, Max = 50, Rounding = 0 })
OffsetGroup:AddSlider('OffsetPitch', { Text = 'Pitch', Default = 0, Min = -180, Max = 180, Rounding = 0 })
OffsetGroup:AddSlider('OffsetYaw', { Text = 'Yaw', Default = 0, Min = -180, Max = 180, Rounding = 0 })
OffsetGroup:AddSlider('OffsetRoll', { Text = 'Roll', Default = 0, Min = -180, Max = 180, Rounding = 0 })
OffsetGroup:AddDropdown('OffsetRandAngle', { Values = { 'pitch', 'yaw', 'roll' }, Default = 0, Multi = true, Text = 'Random Angle' })

local VoidGroup = Tabs.Desync:AddLeftGroupbox('Void')
VoidGroup:AddToggle('VoidSpamEnabled', { Text = 'Enable Void Spam', Default = false }):AddKeyPicker('VoidSpamKey', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Void Spam', NoUI = false })
VoidGroup:AddSlider('VoidInTime', { Text = 'Time In Void (s)', Default = 0.1, Min = 0.05, Max = 5.0, Rounding = 2 })
VoidGroup:AddSlider('VoidOutTime', { Text = 'Time Out of Void (s)', Default = 0.5, Min = 0.05, Max = 5.0, Rounding = 2 })

local CSyncGroup = Tabs.Desync:AddRightGroupbox('CSync')
CSyncGroup:AddToggle('CSyncEnabled', { Text = 'Enable CSync', Default = false }):AddKeyPicker('CSyncKey', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'CSync', NoUI = false })
CSyncGroup:AddDropdown('CSyncMode', { Values = { 'Underground', 'Orbit', 'Jitter' }, Default = 1, Multi = false, Text = 'Mode' })

local NonRaknetGroup = Tabs.Desync:AddRightGroupbox('Non-Raknet')
NonRaknetGroup:AddToggle('NonRaknetEnabled', { Text = 'Enable Freeze Position', Default = false }):AddKeyPicker('FreezePosKey', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Freeze Position', NoUI = false })

local VelBreakGroup = Tabs.Desync:AddRightGroupbox('Velocity Breaker')
VelBreakGroup:AddToggle('VelocityBreakerEnabled', { Text = 'Enable Velocity Breaker', Default = false }):AddKeyPicker('VelBreakKey', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Velocity Breaker', NoUI = false })
VelBreakGroup:AddSlider('VelBreakX', { Text = 'Velocity X', Default = 0, Min = -5000, Max = 5000, Rounding = 0 })
VelBreakGroup:AddSlider('VelBreakY', { Text = 'Velocity Y', Default = 0, Min = -5000, Max = 5000, Rounding = 0 })
VelBreakGroup:AddSlider('VelBreakZ', { Text = 'Velocity Z', Default = 0, Min = -5000, Max = 5000, Rounding = 0 })

local VisualizersGroup = Tabs.Desync:AddRightGroupbox('Visualizers')
local ServerPosToggle = VisualizersGroup:AddToggle('ShowServerPos', { Text = 'Show Server Position', Default = false, Callback = function(v) Settings.Desync.ShowServerPosition = v end })
ServerPosToggle:AddColorPicker('ServerPosColor', { Default = Color3.fromRGB(255, 0, 0), Title = 'Color', Transparency = 0, Callback = function(Color) Settings.Desync.Color = Color; Settings.Desync.Transparency = GetAlpha('ServerPosColor') end })
VisualizersGroup:AddSlider('ServerPosRadius', { Text = 'Radius', Default = 4, Min = 1, Max = 15, Rounding = 0, Callback = function(v) Settings.Desync.Radius = v end })

local ServerPosOutToggle = VisualizersGroup:AddToggle('ServerPosOutline', { Text = 'Draw Outline', Default = true, Callback = function(v) Settings.Desync.Outline = v end })
ServerPosOutToggle:AddColorPicker('ServerPosOutColor', { Default = Color3.fromRGB(0, 0, 0), Title = 'Outline Color', Transparency = 0, Callback = function(Color) Settings.Desync.OutlineColor = Color; Settings.Desync.OutlineTransparency = GetAlpha('ServerPosOutColor') end })
VisualizersGroup:AddSlider('ServerPosOutThick', { Text = 'Outline Thickness', Default = 2, Min = 1, Max = 5, Rounding = 0, Callback = function(v) Settings.Desync.OutlineThickness = v end })

VisualizersGroup:AddDivider()
local GhostToggle = VisualizersGroup:AddToggle('DesyncGhostClone', { Text = 'Enable Desync Ghost', Default = false })
GhostToggle:AddColorPicker('GhostColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Ghost Color', Transparency = 0.5 })
VisualizersGroup:AddDropdown('GhostMaterial', { Values = { 'ForceField', 'Neon', 'Plastic', 'SmoothPlastic', 'Glass' }, Default = 1, Multi = false, Text = 'Ghost Material' })

local GhostHLToggle = VisualizersGroup:AddToggle('GhostHighlight', { Text = 'Enable Ghost Highlight', Default = false })
GhostHLToggle:AddColorPicker('GhostHLLine', { Default = Color3.fromRGB(255, 255, 255), Title = 'Outline Color', Transparency = 0 })
GhostHLToggle:AddColorPicker('GhostHLFill', { Default = Color3.fromRGB(255, 0, 0), Title = 'Fill Color', Transparency = 0.5 })

-- Safe Live Updates for Ghost
task.spawn(function()
    repeat task.wait() until Toggles and Toggles.DesyncGhostClone
    Toggles.DesyncGhostClone:OnChanged(function() Settings.Desync.CharacterClone = Toggles.DesyncGhostClone.Value end)
    Options.GhostMaterial:OnChanged(function() local matMap = {['ForceField']=Enum.Material.ForceField,['Neon']=Enum.Material.Neon,['Plastic']=Enum.Material.Plastic,['SmoothPlastic']=Enum.Material.SmoothPlastic,['Glass']=Enum.Material.Glass}; Settings.Desync.CloneMaterial = matMap[Options.GhostMaterial.Value] end)
    Options.GhostColor:OnChanged(function() Settings.Desync.CloneColor = Options.GhostColor.Value; Settings.Desync.CloneTransparency = Options.GhostColor.Transparency or 0.5 end)
    Toggles.GhostHighlight:OnChanged(function() Settings.Desync.Highlight.Enabled = Toggles.GhostHighlight.Value end)
    Options.GhostHLLine:OnChanged(function() Settings.Desync.Highlight.OutlineColor = Options.GhostHLLine.Value; Settings.Desync.Highlight.OutlineTransparency = Options.GhostHLLine.Transparency or 0 end)
    Options.GhostHLFill:OnChanged(function() Settings.Desync.Highlight.FillColor = Options.GhostHLFill.Value; Settings.Desync.Highlight.FillTransparency = Options.GhostHLFill.Transparency or 0.5 end)
end)

-- ==========================================
-- HBE TAB LOGIC (HITBOX EXPANDER)
-- ==========================================
local HBEGroup = Tabs.HBE:AddLeftGroupbox('Hitbox Extender')
local HBEIgnoreGroup = Tabs.HBE:AddRightGroupbox('Ignores')

HBEGroup:AddToggle('HBEToggle', { Text = 'Toggle', Default = false }):AddKeyPicker('HBEToggleBind', { Default = 'End', SyncToggleState = true, Mode = 'Toggle', Text = 'Hitbox Extender', NoUI = false })
HBEGroup:AddToggle('HBECollisions', { Text = 'Collisions', Default = false })
HBEGroup:AddSlider('HBESize', { Text = 'Size', Default = 5, Min = 2, Max = 100, Rounding = 0 })
HBEGroup:AddSlider('HBETransparency', { Text = 'Transparency', Default = 0.5, Min = 0, Max = 1, Rounding = 2 })
HBEGroup:AddInput('HBECustomPartName', { Text = 'Custom Part Name', Default = 'HeadHB' })
HBEGroup:AddDropdown('HBEParts', {
    Text = 'Body Parts',
    AllowNull = true,
    Multi = true,
    Values = { 'Custom Part', 'Head', 'RootPart', 'Torso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg' },
    Default = {'RootPart'}
})

HBEIgnoreGroup:AddToggle('HBEIgnoreTeammates', { Text = 'Ignore Teammates', Default = false })
HBEIgnoreGroup:AddToggle('HBEIgnoreFF', { Text = 'Ignore Forcefielded Players', Default = false })
HBEIgnoreGroup:AddToggle('HBEIgnoreSitting', { Text = 'Ignore Sitting Players', Default = false })
HBEIgnoreGroup:AddToggle('HBEIgnoreSelected', { Text = 'Ignore Selected Players', Default = false })
HBEIgnoreGroup:AddDropdown('HBEIgnorePlayers', { Text = 'Players', SpecialType = 'Player', Multi = true, Default = {} })
HBEIgnoreGroup:AddToggle('HBEIgnoreSelectedTeams', { Text = 'Ignore Selected Teams', Default = false })
HBEIgnoreGroup:AddDropdown('HBEIgnoreTeams', { Text = 'Teams', SpecialType = 'Team', Multi = true, Default = {} })

-- Core HBE Cleanup Memory
local OriginalHitboxProperties = {}
local function DisableHBE()
    for player, parts in pairs(OriginalHitboxProperties) do
        if player and player.Character then
            for part, orig in pairs(parts) do
                if part and part.Parent then
                    if part.Size ~= orig.Size then part.Size = orig.Size end
                    if part.Transparency ~= orig.Transparency then part.Transparency = orig.Transparency end
                    if part.CanCollide ~= orig.CanCollide then part.CanCollide = orig.CanCollide end
                    if part.Massless ~= orig.Massless then part.Massless = orig.Massless end
                end
            end
        end
    end
end

table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
    if OriginalHitboxProperties[player] then
        OriginalHitboxProperties[player] = nil
    end
end))

-- ==========================================
-- MISC TAB LOGIC
-- ==========================================
local MiscGroup = Tabs.Misc:AddLeftGroupbox('Main Misc')
local ServerGroup = Tabs.Misc:AddLeftGroupbox('Server & Utility')
local MovementGroup = Tabs.Misc:AddRightGroupbox('Movement')
local DaHoodGroup = Tabs.Misc:AddRightGroupbox('Da Hood')

MiscGroup:AddToggle('EnableFPSCap', { Text = 'Enable Custom FPS Cap', Default = false, Callback = function(Value) if Value then setfpscap(Options.FPSLimit.Value) else setfpscap(9999) end end })
MiscGroup:AddSlider('FPSLimit', { Text = 'FPS Cap Limit', Default = 60, Min = 15, Max = 360, Rounding = 0, Callback = function(Value) if Toggles.EnableFPSCap.Value then setfpscap(Value) end end })

ServerGroup:AddButton('Copy Join Script', function()
    local joinScript = string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game:GetService('Players').LocalPlayer)", game.PlaceId, game.JobId)
    if setclipboard then setclipboard(joinScript) Library:Notify('Copied join script!', 3) end
end)
ServerGroup:AddButton('Rejoin Current Server', function() Library:Notify('Rejoining server...', 3) pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end) end)

MovementGroup:AddToggle('EnableWalkSpeed', { Text = 'Enable WalkSpeed', Default = false, Callback = function(Value) if not Value then pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end) end end }):AddKeyPicker('WalkSpeedKeybind', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'WalkSpeed', NoUI = false })
MovementGroup:AddSlider('WalkSpeed', { Text = 'WalkSpeed Amount', Default = 50, Min = 16, Max = 300, Rounding = 0 })
MovementGroup:AddDivider()
MovementGroup:AddToggle('EnableCFrameSpeed', { Text = 'Enable CFrame Speed', Default = false }):AddKeyPicker('CFrameSpeedKeybind', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'CFrame Speed', NoUI = false })
MovementGroup:AddSlider('CFrameSpeed', { Text = 'CFrame Speed Amount', Default = 50, Min = 10, Max = 300, Rounding = 0 })
MovementGroup:AddDivider()
MovementGroup:AddToggle('EnableFly', { Text = 'Enable Fly', Default = false, Callback = function(Value) pcall(function() LocalPlayer.Character.Humanoid.PlatformStand = Value end) end }):AddKeyPicker('FlyKeybind', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Fly', NoUI = false })
MovementGroup:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 50, Min = 16, Max = 300, Rounding = 0 })

DaHoodGroup:AddToggle('RapidFire', { Text = 'Enable Rapid Fire', Default = false, Tooltip = 'Modifies gun fire rate by editing upvalues in GunScript' })

-- ==========================================
-- DA HOOD RAPID FIRE LOGIC
-- ==========================================
local OriginalUpvalues = {} 
local RapidFireConnections = {}

local function storeOriginalUpvalues(tool)
    if not tool or not tool:FindFirstChild("GunScript") then return end
    local toolKey = tostring(tool)
    OriginalUpvalues[toolKey] = OriginalUpvalues[toolKey] or {}
    
    for _, v in ipairs(getconnections(tool.Activated)) do
        local func = v.Function
        if func then
            local funcinfo = debug.getinfo(func)
            OriginalUpvalues[toolKey][func] = OriginalUpvalues[toolKey][func] or {}
            
            for i = 1, funcinfo.nups do
                local c, n = debug.getupvalue(func, i)
                if type(c) == "number" then
                    if OriginalUpvalues[toolKey][func][i] == nil then
                        OriginalUpvalues[toolKey][func][i] = c
                    end
                end
            end
        end
    end
end

local function applyRapidFire(tool)
    if not tool or not tool:FindFirstChild("GunScript") then return end
    storeOriginalUpvalues(tool)
    
    for _, v in ipairs(getconnections(tool.Activated)) do
        local func = v.Function
        if func then
            local funcinfo = debug.getinfo(func)
            for i = 1, funcinfo.nups do
                local c, n = debug.getupvalue(func, i)
                if type(c) == "number" then
                    debug.setupvalue(func, i, 1e-100)
                end
            end
        end
    end
end

local function DisableRapidFire()
    for _, conn in ipairs(RapidFireConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    RapidFireConnections = {}
    
    for toolKey, stored in pairs(OriginalUpvalues) do
        for func, upvalues in pairs(stored) do
            for idx, originalValue in pairs(upvalues) do
                pcall(function()
                    debug.setupvalue(func, idx, originalValue)
                end)
            end
        end
    end
    table.clear(OriginalUpvalues)
end

local function onCharacterAddedForRapidFire(character)
    local connection = RunService.Heartbeat:Connect(function()
        if not Toggles.RapidFire.Value then return end
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            applyRapidFire(tool)
        end
    end)
    table.insert(RapidFireConnections, connection)
end

task.spawn(function()
    repeat task.wait() until Toggles and Toggles.RapidFire
    Toggles.RapidFire:OnChanged(function()
        if not Toggles.RapidFire.Value then
            DisableRapidFire()
        else
            if LocalPlayer.Character then
                onCharacterAddedForRapidFire(LocalPlayer.Character)
            end
        end
    end)
end)

table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
    if Toggles and Toggles.RapidFire and Toggles.RapidFire.Value then
        onCharacterAddedForRapidFire(char)
    end
end))

if LocalPlayer.Character and Toggles and Toggles.RapidFire and Toggles.RapidFire.Value then
    onCharacterAddedForRapidFire(LocalPlayer.Character)
end

-- ==========================================
-- UI SETTINGS & LOADERS
-- ==========================================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddToggle('ShowWatermark', { Text = 'Show Watermark', Default = true, Callback = function(Value) Library:SetWatermarkVisibility(Value) end })
MenuGroup:AddToggle('ShowKeybinds', { Text = 'Show Keybinds', Default = true, Callback = function(Value) Library.KeypickerListVisible = Value; Library.KeybindFrame.Visible = Value end })
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

-- ==========================================
-- HELPER FUNCTIONS FOR CUSTOM DRAWING & RENDERING
-- ==========================================
local function IsVisible(targetPart, playerCharacter)
    local rayOrigin = Camera.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = Workspace:Raycast(rayOrigin, targetPart.Position - rayOrigin, raycastParams)
    return result and result.Instance and result.Instance:IsDescendantOf(playerCharacter) or not result
end

local function IsTargetValid(player, part)
    if not player or not part or not player.Character or not part.Parent then return false end
    if Toggles.HealthCheck.Value and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health <= 0 then return false end
    if Toggles.TeamCheck.Value and player.Team == LocalPlayer.Team then return false end
    return true
end

local function GetClosestTarget()
    local closestPlayer, closestPart, shortestDistance = nil, nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            if Toggles.HealthCheck.Value and player.Character.Humanoid.Health <= 0 then continue end
            if Toggles.TeamCheck.Value and player.Team == LocalPlayer.Team then continue end
            for partName, isSelected in pairs(Options.TargetParts.Value) do
                if isSelected then
                    local part = player.Character:FindFirstChild(partName)
                    if part then
                        if Toggles.VisibleCheck.Value and not IsVisible(part, player.Character) then continue end
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if Toggles.EnableFOV.Value and distance > Options.FOVRadius.Value then continue end
                            if distance < shortestDistance then closestPlayer, closestPart, shortestDistance = player, part, distance end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer, closestPart
end

local function GetCrosshairCenter()
    return Settings.Crosshair.Position == "Mouse" and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function LerpColor(c1, c2, alpha)
    return Color3.new(c1.R + (c2.R - c1.R) * alpha, c1.G + (c2.G - c1.G) * alpha, c1.B + (c2.B - c1.B) * alpha)
end

local function CreateLineSet(amount, zIndex)
    local lines = {}
    for i = 1, amount do
        local l = Drawing.new("Line")
        l.ZIndex = zIndex or 2
        lines[i] = l
    end
    return lines
end

local function CreateESPData()
    return {
        Character = nil,
        SpawnTime = 0,
        Highlight = nil,
        Box2D = Drawing.new("Square"),
        Box2DOutline = Drawing.new("Square"),
        BoxFill = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Weapon = Drawing.new("Text"),
        HealthBg = Drawing.new("Square"),
        HealthFg = Drawing.new("Square"),
        SkeletonLines = CreateLineSet(14, 2),
        SkeletonOutlineLines = CreateLineSet(14, 1)
    }
end

local function AddPlayer(player)
    if not Drawings.Players[player] then
        Drawings.Players[player] = CreateESPData()
    end
end

local function RemovePlayer(player)
    if Drawings.Players[player] then
        local d = Drawings.Players[player]
        d.Box2D:Remove()
        d.Box2DOutline:Remove()
        d.BoxFill:Remove()
        d.Name:Remove()
        d.Distance:Remove()
        d.Weapon:Remove()
        d.HealthBg:Remove()
        d.HealthFg:Remove()
        if d.Highlight then d.Highlight:Destroy() end
        for _, tbl in ipairs({d.SkeletonLines, d.SkeletonOutlineLines}) do
            for _, l in ipairs(tbl) do l:Remove() end
        end
        Drawings.Players[player] = nil
    end
end

table.insert(Connections, Players.PlayerAdded:Connect(AddPlayer))
table.insert(Connections, Players.PlayerRemoving:Connect(RemovePlayer))

for _, p in ipairs(Players:GetPlayers()) do AddPlayer(p) end

-- ==========================================
-- VISUALS RENDERING LOOPS
-- ==========================================
local SelfMaterialCache = {}
local function UpdateSelfChams()
    local lpChar = LocalPlayer.Character
    if Settings.SelfChams.Enabled and lpChar then
        for _, part in ipairs(lpChar:GetDescendants()) do
            if part:IsA("BasePart") then
                local isTool = part:FindFirstAncestorOfClass("Tool") ~= nil
                local shouldApply = (isTool and Settings.SelfChams.Weapon) or (not isTool and Settings.SelfChams.Character)

                if shouldApply then
                    if not SelfMaterialCache[part] then
                        SelfMaterialCache[part] = { Material = part.Material, Color = part.Color }
                    end
                    local targetColor = isTool and Settings.SelfChams.WeaponColor or Settings.SelfChams.CharColor

                    if part.Material ~= Settings.SelfChams.Material or part.Color ~= targetColor then
                        part.Material = Settings.SelfChams.Material
                        part.Color = targetColor
                    end
                elseif SelfMaterialCache[part] then
                    part.Material = SelfMaterialCache[part].Material
                    part.Color = SelfMaterialCache[part].Color
                    SelfMaterialCache[part] = nil
                end
            end
        end
    else
        for part, props in pairs(SelfMaterialCache) do
            if part and part.Parent then
                part.Material = props.Material
                part.Color = props.Color
            end
        end
        table.clear(SelfMaterialCache)
    end
end

local function UpdateDesyncVisualizers()
    local lpChar = LocalPlayer.Character
    local desyncSettings = Settings.Desync
    local desyncDrawings = Drawings.Desync
    local sPosMain = desyncDrawings.ServerPositionMain
    local sPosOut = desyncDrawings.ServerPositionOutline

    if desyncSettings.ShowServerPosition then
        local screenPos, onScreen = Camera:WorldToViewportPoint(desyncSettings.ServerPosition)
        if onScreen then
            sPosMain.Visible = true
            sPosMain.Position = Vector2.new(screenPos.X, screenPos.Y)
            sPosMain.Radius = desyncSettings.Radius
            sPosMain.Color = desyncSettings.Color
            sPosMain.Transparency = desyncSettings.Transparency
            sPosMain.Filled = true
            sPosMain.Thickness = 1

            if desyncSettings.Outline then
                sPosOut.Visible = true
                sPosOut.Position = sPosMain.Position
                sPosOut.Radius = desyncSettings.Radius
                sPosOut.Color = desyncSettings.OutlineColor
                sPosOut.Transparency = desyncSettings.Transparency
                sPosOut.Thickness = desyncSettings.OutlineThickness
                sPosOut.Filled = false
            else
                sPosOut.Visible = false
            end
        else
            sPosMain.Visible = false
            sPosOut.Visible = false
        end
    else
        sPosMain.Visible = false
        sPosOut.Visible = false
    end

    -- Ghost Clone
    if desyncSettings.CharacterClone and lpChar and lpChar:FindFirstChild("HumanoidRootPart") then
        local realHRP = lpChar.HumanoidRootPart
        local clone = desyncDrawings.CloneModel

        if not clone or not clone.Parent then
            if clone then clone:Destroy() end
            lpChar.Archivable = true
            clone = lpChar:Clone()
            lpChar.Archivable = false
            desyncDrawings.CloneModel = clone
            clone.Name = "DesyncGhost"

            for _, v in ipairs(clone:GetDescendants()) do
                if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Animator") or v:IsA("AnimationController") then
                    v:Destroy()
                end
            end
            local hum = clone:FindFirstChildOfClass("Humanoid")
            if hum then hum:Destroy() end

            for _, v in ipairs(clone:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Anchored = true
                    v.CanCollide = false
                    v.CanTouch = false
                    v.CanQuery = false
                    v.CastShadow = false
                end
            end
            clone.Parent = Workspace
        end

        local offset = desyncSettings.ServerPosition - realHRP.Position
        for _, clonePart in ipairs(clone:GetDescendants()) do
            if clonePart:IsA("BasePart") then
                local realPart = lpChar:FindFirstChild(clonePart.Name, true)
                if realPart and realPart:IsA("BasePart") then
                    clonePart.CFrame = realPart.CFrame + offset
                    clonePart.Material = desyncSettings.CloneMaterial
                    clonePart.Color = desyncSettings.CloneColor
                    clonePart.Transparency = desyncSettings.CloneTransparency
                end
            end
        end

        if desyncSettings.Highlight.Enabled then
            local hl = desyncDrawings.Highlight
            if not hl then
                hl = Instance.new("Highlight")
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = clone
                desyncDrawings.Highlight = hl
            end
            hl.Adornee = clone
            hl.FillColor = desyncSettings.Highlight.FillColor
            hl.FillTransparency = desyncSettings.Highlight.FillTransparency
            hl.OutlineColor = desyncSettings.Highlight.OutlineColor
            hl.OutlineTransparency = desyncSettings.Highlight.OutlineTransparency
            hl.Enabled = true
        else
            if desyncDrawings.Highlight then desyncDrawings.Highlight.Enabled = false end
        end
    else
        if desyncDrawings.CloneModel then
            desyncDrawings.CloneModel:Destroy()
            desyncDrawings.CloneModel = nil
        end
        if desyncDrawings.Highlight then
            desyncDrawings.Highlight:Destroy()
            desyncDrawings.Highlight = nil
        end
    end
end

local function ApplyGradientToDrawing(drawingObject, color1, color2, color3, lerpValue, rotation, movingRotation, rotationSpeed)
    if not drawingObject then return end
    local frame = drawingObject._frame or drawingObject.__OBJECT
    if not frame then return end
    
    local c1 = color1 or Color3.new(1, 1, 1)
    local c2 = color2 or c1
    local c3 = color3 or c2
    
    local useGradient = (lerpValue and lerpValue > 0)
    
    local finalColor1 = c1
    local finalColor2 = c1
    local finalColor3 = c1
    
    if useGradient then
        finalColor1 = c1
        finalColor2 = c1:Lerp(c2, lerpValue)
        finalColor3 = c1:Lerp(c3, lerpValue)
    end
    
    local finalRotation = rotation or 0
    if movingRotation then
        finalRotation = (tick() * (rotationSpeed or 1) * 360) % 360
    end
    
    local fillGradient = frame:FindFirstChild("_fillGradient")
    if useGradient then
        if not fillGradient then
            fillGradient = Instance.new("UIGradient")
            fillGradient.Name = "_fillGradient"
            fillGradient.Parent = frame
        end
        fillGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, finalColor1),
            ColorSequenceKeypoint.new(0.5, finalColor2),
            ColorSequenceKeypoint.new(1, finalColor3)
        })
        fillGradient.Rotation = finalRotation
        fillGradient.Enabled = true
        
        -- Override frame color to white so it doesn't modulate the gradient colors
        frame.BackgroundColor3 = Color3.new(1, 1, 1)
    else
        if fillGradient then
            fillGradient.Enabled = false
        end
        -- Restore original color from drawing properties
        frame.BackgroundColor3 = drawingObject.Color or c1
    end
    
    local stroke = frame:FindFirstChild("_stroke") or frame:FindFirstChild("_STROKE")
    if stroke then
        local strokeGradient = stroke:FindFirstChild("_strokeGradient")
        if useGradient then
            if not strokeGradient then
                strokeGradient = Instance.new("UIGradient")
                strokeGradient.Name = "_strokeGradient"
                strokeGradient.Parent = stroke
            end
            strokeGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, finalColor1),
                ColorSequenceKeypoint.new(0.5, finalColor2),
                ColorSequenceKeypoint.new(1, finalColor3)
            })
            strokeGradient.Rotation = finalRotation
            strokeGradient.Enabled = true
            
            -- Override stroke color to white
            stroke.Color = Color3.new(1, 1, 1)
        else
            if strokeGradient then
                strokeGradient.Enabled = false
            end
            -- Restore original color from drawing properties
            stroke.Color = drawingObject.Color or c1
        end
    end
end

local function UpdateFOV()
    local fov = Drawings.FOV
    local fovSettings = Settings.FOV
    if fovSettings.Enabled then
        local pos, r = fovSettings.Position, fovSettings.Radius
        
        -- Always draw black outline behind main circle (1.5px bigger, slightly wider radius)
        fov.Outline.Visible = true
        fov.Outline.Position = pos
        fov.Outline.Radius = r + 1.0
        fov.Outline.Color = Color3.fromRGB(0, 0, 0)
        fov.Outline.Transparency = fovSettings.Transparency
        fov.Outline.Thickness = fovSettings.Thickness + 3
        fov.Outline.Filled = false
        fov.Outline.NumSides = fovSettings.Sides
        ApplyGradientToDrawing(fov.Outline, Color3.fromRGB(0, 0, 0), nil, nil, 0, 0, false, 1)

        -- Main outline/line circle
        fov.Main.Visible = true
        fov.Main.Position = pos
        fov.Main.Radius = r
        fov.Main.Color = fovSettings.GradientColor1
        fov.Main.Transparency = fovSettings.Transparency
        fov.Main.Thickness = fovSettings.Thickness
        fov.Main.Filled = false
        fov.Main.NumSides = fovSettings.Sides
        ApplyGradientToDrawing(fov.Main, fovSettings.GradientColor1, fovSettings.GradientColor2, fovSettings.GradientColor3, fovSettings.GradientLerp, fovSettings.GradientRotation, fovSettings.GradientMoving, fovSettings.GradientSpeed)

        if fovSettings.Filled then
            fov.Fill.Visible = true
            fov.Fill.Position = pos
            fov.Fill.Radius = r
            fov.Fill.Color = fovSettings.GradientColor1
            fov.Fill.Transparency = fovSettings.FillTransparency or 0.2
            fov.Fill.Filled = true
            fov.Fill.NumSides = fovSettings.Sides
            ApplyGradientToDrawing(fov.Fill, fovSettings.GradientColor1, fovSettings.GradientColor2, fovSettings.GradientColor3, fovSettings.GradientLerp, fovSettings.GradientRotation, fovSettings.GradientMoving, fovSettings.GradientSpeed)
        else
            fov.Fill.Visible = false
        end
    else
        fov.Main.Visible = false
        fov.Outline.Visible = false
        fov.Fill.Visible = false
    end
end

local function UpdateCrosshair()
    local chMain, chOut = Drawings.Crosshair.Main, Drawings.Crosshair.Outline
    local chSettings = Settings.Crosshair
    local time = tick()
    if chSettings.Enabled then
        local center = GetCrosshairCenter()
        local rot, currentGap = time * chSettings.RotationSpeed, chSettings.Gap
        local mainThick = chSettings.Thickness

        if chSettings.BounceAmplitude > 0 then
            currentGap = currentGap + math.abs(math.sin(time * 5)) * chSettings.BounceAmplitude
        end
        local angles = { Top = rot - math.pi/2, Bottom = rot + math.pi/2, Left = rot + math.pi, Right = rot }

        for peg, line in pairs(chMain) do
            local angle = angles[peg]
            local dir = Vector2.new(math.cos(angle), math.sin(angle))
            local p1, p2 = center + (dir * currentGap), center + (dir * (currentGap + chSettings.Size))

            line.Visible = true
            line.From = p1
            line.To = p2
            line.Color = chSettings.Colors[peg]
            line.Transparency = chSettings.Transparency
            line.Thickness = mainThick
            line.ZIndex = 2

            chOut[peg].Visible = true
            chOut[peg].From = p1 - dir
            chOut[peg].To = p2 + dir
            chOut[peg].Color = Color3.fromRGB(0, 0, 0)
            chOut[peg].Transparency = chSettings.Transparency
            chOut[peg].Thickness = mainThick + 2
            chOut[peg].ZIndex = 1
        end
    else
        for _, l in pairs(chMain) do l.Visible = false end
        for _, l in pairs(chOut) do l.Visible = false end
    end
end

local function UpdateESP()
    local espSettings = Settings.ESP
    for player, data in pairs(Drawings.Players) do
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")

        local shouldRender2D = false

        if character then
            if data.Character ~= character then
                data.Character = character
                data.SpawnTime = tick()
                if data.Highlight then data.Highlight:Destroy() data.Highlight = nil end
            end
        end

        if espSettings.Enabled and player ~= LocalPlayer and rootPart and humanoid and humanoid.Health > 0 then
            local passedTeamCheck = not espSettings.TeamCheck or (player.Team ~= LocalPlayer.Team)
            local passedVisCheck = not espSettings.VisibleCheck or IsVisible(rootPart, character)
            local passedSpawnCheck = (tick() - data.SpawnTime) >= espSettings.SpawnDelay

            if passedTeamCheck and passedVisCheck and passedSpawnCheck then
                -- Highlight
                if espSettings.Highlight.Enabled then
                    if not data.Highlight then
                        data.Highlight = Instance.new("Highlight")
                        data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        data.Highlight.Parent = character
                    end
                    data.Highlight.Adornee = character
                    data.Highlight.FillColor = espSettings.Highlight.UseTeamColor and player.TeamColor.Color or espSettings.Highlight.FillColor
                    data.Highlight.FillTransparency = espSettings.Highlight.FillTransparency
                    data.Highlight.OutlineColor = espSettings.Highlight.UseTeamColor and player.TeamColor.Color or espSettings.Highlight.OutlineColor
                    data.Highlight.OutlineTransparency = espSettings.Highlight.OutlineTransparency
                    data.Highlight.Enabled = true
                else
                    if data.Highlight then data.Highlight.Enabled = false end
                end

                local _, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude

                if onScreen and dist <= espSettings.MaxDistance then
                    shouldRender2D = true
                    local cf, size3D = character:GetBoundingBox()
                    local cornersVectors = {
                        Vector3.new(size3D.X/2, size3D.Y/2, size3D.Z/2), Vector3.new(-size3D.X/2, size3D.Y/2, size3D.Z/2),
                        Vector3.new(-size3D.X/2, -size3D.Y/2, size3D.Z/2), Vector3.new(size3D.X/2, -size3D.Y/2, size3D.Z/2),
                        Vector3.new(size3D.X/2, size3D.Y/2, -size3D.Z/2), Vector3.new(-size3D.X/2, size3D.Y/2, -size3D.Z/2),
                        Vector3.new(-size3D.X/2, -size3D.Y/2, -size3D.Z/2), Vector3.new(size3D.X/2, -size3D.Y/2, -size3D.Z/2)
                    }

                    local c2d = {}
                    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
                    for i, v in ipairs(cornersVectors) do
                        local pt = Camera:WorldToViewportPoint(cf * v)
                        c2d[i] = Vector2.new(pt.X, pt.Y)
                        if pt.X < minX then minX = pt.X end if pt.X > maxX then maxX = pt.X end
                        if pt.Y < minY then minY = pt.Y end if pt.Y > maxY then maxY = pt.Y end
                    end

                    local width, height = maxX - minX, maxY - minY
                    local boxPos, boxSize = Vector2.new(minX, minY), Vector2.new(width, height)

                    -- 1. BOX RENDERER
                    if espSettings.Boxes.Enabled then
                        data.Box2D.Visible = true
                        data.Box2D.Size = boxSize
                        data.Box2D.Position = boxPos
                        data.Box2D.Color = espSettings.Boxes.GradientColor1
                        data.Box2D.Transparency = espSettings.Boxes.Transparency
                        data.Box2D.Thickness = espSettings.Boxes.Thickness
                        data.Box2D.Filled = false
                        data.Box2D.ZIndex = 2
                        ApplyGradientToDrawing(data.Box2D, espSettings.Boxes.GradientColor1, espSettings.Boxes.GradientColor2, espSettings.Boxes.GradientColor3, espSettings.Boxes.GradientLerp, espSettings.Boxes.GradientRotation, espSettings.Boxes.GradientMoving, espSettings.Boxes.GradientSpeed)

                        -- Always draw outline (1.5px black)
                        data.Box2DOutline.Visible = true
                        data.Box2DOutline.Position = boxPos - Vector2.new(1.5, 1.5)
                        data.Box2DOutline.Size = boxSize + Vector2.new(3, 3)
                        data.Box2DOutline.Color = Color3.fromRGB(0, 0, 0)
                        data.Box2DOutline.Transparency = espSettings.Boxes.Transparency
                        data.Box2DOutline.Thickness = 1.5
                        data.Box2DOutline.Filled = false
                        data.Box2DOutline.ZIndex = 1
                        ApplyGradientToDrawing(data.Box2DOutline, Color3.fromRGB(0, 0, 0), nil, nil, 0, 0, false, 1)

                        if espSettings.Boxes.Fill then
                            data.BoxFill.Visible = true
                            data.BoxFill.Size = boxSize
                            data.BoxFill.Position = boxPos
                            data.BoxFill.Color = espSettings.Boxes.GradientColor1
                            data.BoxFill.Transparency = espSettings.Boxes.FillTransparency
                            data.BoxFill.Filled = true
                            data.BoxFill.Thickness = 0
                            data.BoxFill.ZIndex = 0
                            ApplyGradientToDrawing(data.BoxFill, espSettings.Boxes.GradientColor1, espSettings.Boxes.GradientColor2, espSettings.Boxes.GradientColor3, espSettings.Boxes.GradientLerp, espSettings.Boxes.GradientRotation, espSettings.Boxes.GradientMoving, espSettings.Boxes.GradientSpeed)
                        else
                            data.BoxFill.Visible = false
                        end
                    else
                        data.Box2D.Visible = false
                        data.Box2DOutline.Visible = false
                        data.BoxFill.Visible = false
                    end

                    -- 2. HEALTHBAR RENDERER
                    if espSettings.Healthbar.Enabled then
                        local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barWidth = 2
                        local barHeight = height * hpPercent
                        local barX = minX - 5 - barWidth

                        -- Always draw outline background (black, 1.5px bigger)
                        data.HealthBg.Visible = true
                        data.HealthBg.Position = Vector2.new(barX - 1.5, minY - 1.5)
                        data.HealthBg.Size = Vector2.new(barWidth + 3, height + 3)
                        data.HealthBg.Color = Color3.fromRGB(0, 0, 0)
                        data.HealthBg.Transparency = espSettings.Healthbar.Transparency
                        data.HealthBg.Filled = true
                        data.HealthBg.Thickness = 0
                        data.HealthBg.ZIndex = 1
                        ApplyGradientToDrawing(data.HealthBg, Color3.fromRGB(0, 0, 0), nil, nil, 0, 0, false, 1)

                        local baseColor = espSettings.Healthbar.GradientColor1

                        data.HealthFg.Visible = hpPercent > 0
                        data.HealthFg.Position = Vector2.new(barX, minY + height - barHeight)
                        data.HealthFg.Size = Vector2.new(barWidth, barHeight)
                        data.HealthFg.Color = baseColor
                        data.HealthFg.Transparency = espSettings.Healthbar.Transparency
                        data.HealthFg.Filled = true
                        data.HealthFg.Thickness = 0
                        data.HealthFg.ZIndex = 2
                        ApplyGradientToDrawing(data.HealthFg, baseColor, espSettings.Healthbar.GradientColor2, espSettings.Healthbar.GradientColor3, espSettings.Healthbar.GradientLerp, espSettings.Healthbar.GradientRotation, false, 1)
                    else
                        data.HealthBg.Visible = false
                        data.HealthFg.Visible = false
                    end

                    -- 3. SKELETON RENDERER
                    local skeletonSettings = espSettings.Skeleton
                    if skeletonSettings and skeletonSettings.Enabled then
                        local isR15 = (humanoid.RigType == Enum.HumanoidRigType.R15)
                        local boneConnections = isR15 and R15Bones or R6Bones
                        
                        local activeBonesCount = 0
                        for _, connection in ipairs(boneConnections) do
                            local part1 = character:FindFirstChild(connection[1])
                            local part2 = character:FindFirstChild(connection[2])
                            
                            if part1 and part2 then
                                activeBonesCount = activeBonesCount + 1
                                local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                                local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
                                
                                if onScreen1 and onScreen2 then
                                    local line = data.SkeletonLines[activeBonesCount]
                                    local outline = data.SkeletonOutlineLines[activeBonesCount]
                                    
                                    if line and outline then
                                        local p1 = Vector2.new(pos1.X, pos1.Y)
                                        local p2 = Vector2.new(pos2.X, pos2.Y)
                                        
                                        line.Visible = true
                                        line.From = p1
                                        line.To = p2
                                        line.Color = skeletonSettings.GradientColor1
                                        line.Transparency = skeletonSettings.Transparency
                                        line.Thickness = skeletonSettings.Thickness
                                        ApplyGradientToDrawing(line, skeletonSettings.GradientColor1, skeletonSettings.GradientColor2, skeletonSettings.GradientColor3, skeletonSettings.GradientLerp, skeletonSettings.GradientRotation, skeletonSettings.GradientMoving, skeletonSettings.GradientSpeed)
                                        
                                        local dir = (p2 - p1).Magnitude > 0 and (p2 - p1).Unit or Vector2.new(0, 0)
                                        outline.Visible = true
                                        outline.From = p1 - dir * 1.5
                                        outline.To = p2 + dir * 1.5
                                        outline.Color = Color3.fromRGB(0, 0, 0)
                                        outline.Transparency = skeletonSettings.Transparency
                                        outline.Thickness = skeletonSettings.Thickness + 3
                                        ApplyGradientToDrawing(outline, Color3.fromRGB(0, 0, 0), nil, nil, 0, 0, false, 1)
                                    end
                                else
                                    local line = data.SkeletonLines[activeBonesCount]
                                    local outline = data.SkeletonOutlineLines[activeBonesCount]
                                    if line then line.Visible = false end
                                    if outline then outline.Visible = false end
                                end
                            end
                        end
                        
                        -- Hide unused skeleton lines
                        for i = activeBonesCount + 1, 14 do
                            if data.SkeletonLines[i] then data.SkeletonLines[i].Visible = false end
                            if data.SkeletonOutlineLines[i] then data.SkeletonOutlineLines[i].Visible = false end
                        end
                    else
                        for i = 1, 14 do
                            if data.SkeletonLines[i] then data.SkeletonLines[i].Visible = false end
                            if data.SkeletonOutlineLines[i] then data.SkeletonOutlineLines[i].Visible = false end
                        end
                    end

                    -- 4. TEXT RENDERER
                    local currentBottomY = maxY + 2
                    if espSettings.Names.Enabled then
                        data.Name.Visible = true
                        data.Name.Text = espSettings.Names.UseDisplayName and player.DisplayName or player.Name
                        data.Name.Position = Vector2.new(minX + width/2, minY - espSettings.Names.Size - 2)
                        data.Name.Color = espSettings.Names.Color
                        data.Name.Transparency = espSettings.Names.Transparency
                        data.Name.Font = espSettings.TextFont
                        data.Name.Size = espSettings.Names.Size
                        data.Name.Center = true
                        data.Name.Outline = true
                        data.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
                        data.Name.ZIndex = 3
                    else
                        data.Name.Visible = false
                    end

                    if espSettings.Weapon.Enabled then
                        local tool = character:FindFirstChildOfClass("Tool")
                        data.Weapon.Visible = true
                        data.Weapon.Text = tool and tool.Name or "None"
                        data.Weapon.Position = Vector2.new(minX + width/2, currentBottomY)
                        data.Weapon.Color = espSettings.Weapon.Color
                        data.Weapon.Transparency = espSettings.Weapon.Transparency
                        data.Weapon.Font = espSettings.TextFont
                        data.Weapon.Size = espSettings.Weapon.Size
                        data.Weapon.Center = true
                        data.Weapon.Outline = true
                        data.Weapon.OutlineColor = Color3.fromRGB(0, 0, 0)
                        data.Weapon.ZIndex = 3
                        currentBottomY = currentBottomY + espSettings.Weapon.Size
                    else
                        data.Weapon.Visible = false
                    end

                    if espSettings.Distance.Enabled then
                        data.Distance.Visible = true
                        data.Distance.Text = math.floor(dist) .. " Studs"
                        data.Distance.Position = Vector2.new(minX + width/2, currentBottomY)
                        data.Distance.Color = espSettings.Distance.Color
                        data.Distance.Transparency = espSettings.Distance.Transparency
                        data.Distance.Font = espSettings.TextFont
                        data.Distance.Size = espSettings.Distance.Size
                        data.Distance.Center = true
                        data.Distance.Outline = true
                        data.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
                        data.Distance.ZIndex = 3
                    else
                        data.Distance.Visible = false
                    end
                end
            else
                if data.Highlight then data.Highlight.Enabled = false end
            end
        else
            if data.Highlight then data.Highlight.Enabled = false end
        end

        if not shouldRender2D then
            data.Box2D.Visible = false
            data.Box2DOutline.Visible = false
            data.BoxFill.Visible = false
            data.Name.Visible = false
            data.Distance.Visible = false
            data.Weapon.Visible = false
            data.HealthBg.Visible = false
            data.HealthFg.Visible = false
            for i = 1, 14 do
                if data.SkeletonLines[i] then data.SkeletonLines[i].Visible = false end
                if data.SkeletonOutlineLines[i] then data.SkeletonOutlineLines[i].Visible = false end
            end
        end
    end
end

-- ==========================================
-- UNLOAD BUTTON BINDING
-- ==========================================
MenuGroup:AddButton('Unload', function() 
    pcall(function() setfpscap(9999) end)
    pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16; LocalPlayer.Character.Humanoid.PlatformStand = false end)
    
    -- Disable visuals settings to trigger cleanup
    Settings.ESP.Enabled = false
    Settings.FOV.Enabled = false
    Settings.Crosshair.Enabled = false
    Settings.SelfChams.Enabled = false
    Settings.Desync.ShowServerPosition = false
    Settings.Desync.CharacterClone = false
    
    -- Run cleanup loops once to destroy objects
    UpdateSelfChams()
    UpdateDesyncVisualizers()
    UpdateFOV()
    UpdateCrosshair()
    UpdateESP()

    -- Disconnect all script connections
    for _, conn in ipairs(Connections) do
        if conn.Connected then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(Connections)

    -- Unbind render steps
    pcall(function() RunService:UnbindFromRenderStep("DesyncRestore") end)

    -- Clean up player drawings
    for player in pairs(Drawings.Players) do
        RemovePlayer(player)
    end
    
    -- Clean up static drawings
    pcall(function() Drawings.FOV.Outline:Remove() end)
    pcall(function() Drawings.FOV.Main:Remove() end)
    pcall(function() Drawings.FOV.Fill:Remove() end)
    for _, line in pairs(Drawings.Crosshair.Main) do pcall(function() line:Remove() end) end
    for _, line in pairs(Drawings.Crosshair.Outline) do pcall(function() line:Remove() end) end
    pcall(function() Drawings.Desync.ServerPositionMain:Remove() end)
    pcall(function() Drawings.Desync.ServerPositionOutline:Remove() end)
    if Drawings.Desync.CloneModel then pcall(function() Drawings.Desync.CloneModel:Destroy() end) end
    if Drawings.Desync.Highlight then pcall(function() Drawings.Desync.Highlight:Destroy() end) end

    -- Custom skybox cleanup
    pcall(function() customSky:Destroy() end)

    DisableRapidFire()
    DisableHBE()
    if type(raknet) == "table" and raknet.remove_send_hook then pcall(function() raknet.remove_send_hook(rakhook) end) end
    Library:Unload() 
end)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind', 'ShowWatermark', 'ShowKeybinds' })
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

-- ==========================================
-- ENGINE: AIMBOT, DESYNC, RAKNET, HBE & MOVEMENT
-- ==========================================
local Stats = game:GetService("Stats")
local tickTimer, currentTarget, currentTargetPart = 0, nil, nil

-- CFRAME DESYNC ENGINE VARIABLES
local RealCFrame = nil
local RealVelocity = nil
local RealAngularVelocity = nil
local FrozenPosition = nil
local WasDesyncing = false
local voidTimer = 0
local isVoided = false

-- RAKNET HOOKING ENGINE
local isRaknetHooked = false
local FrozenRaknetCFrame = nil

local function rakhook(packet)
    if packet.PacketId == 0x1B then
        local buf = packet.AsBuffer
        buffer.writeu32(buf, 1, 0xFFFFFFFF)
        packet:SetData(buf)
    end
end

task.spawn(function()
    repeat task.wait() until Toggles and Toggles.RaknetDesyncEnabled
    Toggles.RaknetDesyncEnabled:OnChanged(function()
        local enabled = Toggles.RaknetDesyncEnabled.Value
        if type(raknet) == "table" and type(raknet.add_send_hook) == "function" then
            if enabled then
                if not isRaknetHooked then
                    isRaknetHooked = true
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then FrozenRaknetCFrame = hrp.CFrame end
                    raknet.add_send_hook(rakhook)
                    Library:Notify("Raknet Hook Enabled", 2)
                end
            else
                if isRaknetHooked then
                    isRaknetHooked = false
                    raknet.remove_send_hook(rakhook)
                    FrozenRaknetCFrame = nil
                    Library:Notify("Raknet Hook Disabled", 2)
                end
            end
        else
            if enabled then
                Library:Notify("Raknet API is not supported on your executor.", 3)
                Toggles.RaknetDesyncEnabled:SetValue(false)
            end
        end
    end)
end)

local HitboxPartsMap = {
    ['Head'] = {'Head'},
    ['RootPart'] = {'HumanoidRootPart'},
    ['Torso'] = {'UpperTorso', 'LowerTorso', 'Torso'},
    ['Left Arm'] = {'LeftHand', 'LeftLowerArm', 'LeftUpperArm', 'Left Arm'},
    ['Right Arm'] = {'RightHand', 'RightLowerArm', 'RightUpperArm', 'Right Arm'},
    ['Left Leg'] = {'LeftFoot', 'LeftLowerLeg', 'LeftUpperLeg', 'Left Leg'},
    ['Right Leg'] = {'RightFoot', 'RightLowerLeg', 'RightUpperLeg', 'Right Leg'}
}

RunService:BindToRenderStep("DesyncRestore", Enum.RenderPriority.Camera.Value - 10, function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    local isDesyncing = Toggles.NonRaknetEnabled.Value or Toggles.CSyncEnabled.Value or Toggles.OffsetEnabled.Value or Toggles.VoidSpamEnabled.Value or Toggles.VelocityBreakerEnabled.Value
    
    if hrp and RealCFrame then
        if isDesyncing or WasDesyncing then
            hrp.CFrame = RealCFrame
            if RealVelocity then hrp.AssemblyLinearVelocity = RealVelocity end
            if RealAngularVelocity then hrp.AssemblyAngularVelocity = RealAngularVelocity end
        end
    end
    
    WasDesyncing = isDesyncing
end)

table.insert(Connections, RunService.Heartbeat:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- === HBE ENGINE LOGIC ===
    local hbeEnabled = Toggles.HBEToggle and Toggles.HBEToggle.Value
    local hbeSize = Options.HBESize and Options.HBESize.Value or 5
    local hbeTrans = Options.HBETransparency and Options.HBETransparency.Value or 0.5
    local hbeCollide = Toggles.HBECollisions and Toggles.HBECollisions.Value or false
    
    local ignoreTeams = Toggles.HBEIgnoreTeammates and Toggles.HBEIgnoreTeammates.Value or false
    local ignoreFF = Toggles.HBEIgnoreFF and Toggles.HBEIgnoreFF.Value or false
    local ignoreSitting = Toggles.HBEIgnoreSitting and Toggles.HBEIgnoreSitting.Value or false
    local ignoreSelected = Toggles.HBEIgnoreSelected and Toggles.HBEIgnoreSelected.Value or false
    local ignoreTeamsSelected = Toggles.HBEIgnoreSelectedTeams and Toggles.HBEIgnoreSelectedTeams.Value or false

    local targetSize = Vector3.new(hbeSize, hbeSize, hbeSize)

    local selectedParts = {}
    local customPartEnabled = false
    local customPartName = Options.HBECustomPartName and Options.HBECustomPartName.Value or "HeadHB"

    if Options.HBEParts and type(Options.HBEParts.Value) == "table" then
        for key, isSelected in pairs(Options.HBEParts.Value) do
            if isSelected then
                if key == "Custom Part" then
                    customPartEnabled = true
                elseif HitboxPartsMap[key] then
                    for _, realPartName in ipairs(HitboxPartsMap[key]) do
                        selectedParts[realPartName] = true
                    end
                end
            end
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local tChar = player.Character
        local tHum = tChar and tChar:FindFirstChild("Humanoid")
        
        if tChar and tHum then
            local isDead = (tHum.Health <= 0)
            local isTeammate = (player.Team == LocalPlayer.Team)
            local hasFF = tChar:FindFirstChildWhichIsA("ForceField") ~= nil
            local isSitting = tHum.Sit
            local isIgnoredPlayer = ignoreSelected and Options.HBEIgnorePlayers and Options.HBEIgnorePlayers.Value[player.Name]
            
            local isIgnoredTeam = false
            if ignoreTeamsSelected and Options.HBEIgnoreTeams and player.Team then
                isIgnoredTeam = Options.HBEIgnoreTeams.Value[player.Team.Name]
            end

            local shouldIgnore = isDead or (ignoreTeams and isTeammate) or (ignoreFF and hasFF) or (ignoreSitting and isSitting) or isIgnoredPlayer or isIgnoredTeam
            
            OriginalHitboxProperties[player] = OriginalHitboxProperties[player] or {}
            
            for _, part in ipairs(tChar:GetChildren()) do
                if part:IsA("BasePart") then
                    if not OriginalHitboxProperties[player][part] then
                        OriginalHitboxProperties[player][part] = {
                            Size = part.Size,
                            Transparency = part.Transparency,
                            CanCollide = part.CanCollide,
                            Massless = part.Massless
                        }
                    end
                    
                    local orig = OriginalHitboxProperties[player][part]
                    local isTargetPart = selectedParts[part.Name] or (customPartEnabled and part.Name == customPartName)
                    
                    if hbeEnabled and not shouldIgnore and isTargetPart then
                        if part.Size ~= targetSize then part.Size = targetSize end
                        if part.Transparency ~= hbeTrans then part.Transparency = hbeTrans end
                        if part.CanCollide ~= hbeCollide then part.CanCollide = hbeCollide end
                        
                        local targetMassless = (part.Name ~= "HumanoidRootPart")
                        if part.Massless ~= targetMassless then part.Massless = targetMassless end
                    else
                        if part.Size ~= orig.Size then part.Size = orig.Size end
                        if part.Transparency ~= orig.Transparency then part.Transparency = orig.Transparency end
                        if part.CanCollide ~= orig.CanCollide then part.CanCollide = orig.CanCollide end
                        if part.Massless ~= orig.Massless then part.Massless = orig.Massless end
                    end
                end
            end
        end
    end
    -- === END HBE ENGINE LOGIC ===

    -- === DESYNC LOGIC ===
    local isDesyncing = Toggles.NonRaknetEnabled.Value or Toggles.CSyncEnabled.Value or Toggles.OffsetEnabled.Value or Toggles.VoidSpamEnabled.Value or Toggles.VelocityBreakerEnabled.Value
    
    if hrp and isDesyncing then
        RealCFrame = hrp.CFrame
        RealVelocity = hrp.AssemblyLinearVelocity
        RealAngularVelocity = hrp.AssemblyAngularVelocity
        
        local FakeCFrame = RealCFrame
        
        -- Void Spam Timer Logic
        if Toggles.VoidSpamEnabled.Value then
            voidTimer = voidTimer + deltaTime
            if isVoided then
                if voidTimer >= Options.VoidInTime.Value then
                    isVoided = false
                    voidTimer = 0
                end
            else
                if voidTimer >= Options.VoidOutTime.Value then
                    isVoided = true
                    voidTimer = 0
                end
            end
        else
            isVoided = false
            voidTimer = 0
        end
        
        if Toggles.NonRaknetEnabled.Value then
            if not FrozenPosition then FrozenPosition = RealCFrame end
            FakeCFrame = FrozenPosition
        elseif Toggles.VoidSpamEnabled.Value and isVoided then
            FakeCFrame = RealCFrame * CFrame.new(0, -50000, 0)
        else
            FrozenPosition = nil
            if Toggles.CSyncEnabled.Value then
                if Options.CSyncMode.Value == 'Underground' then
                    FakeCFrame = RealCFrame * CFrame.new(0, -15, 0)
                elseif Options.CSyncMode.Value == 'Orbit' then
                    local t = tick() * 3
                    FakeCFrame = RealCFrame * CFrame.new(math.cos(t) * 10, 0, math.sin(t) * 10)
                elseif Options.CSyncMode.Value == 'Jitter' then
                    FakeCFrame = RealCFrame * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
                end
            elseif Toggles.OffsetEnabled.Value then
                local xMin, xMax = Options.OffsetXMin.Value, Options.OffsetXMax.Value
                local yMin, yMax = Options.OffsetYMin.Value, Options.OffsetYMax.Value
                local zMin, zMax = Options.OffsetZMin.Value, Options.OffsetZMax.Value
                
                local x = (xMin == xMax) and xMin or math.random(math.min(xMin, xMax), math.max(xMin, xMax))
                local y = (yMin == yMax) and yMin or math.random(math.min(yMin, yMax), math.max(yMin, yMax))
                local z = (zMin == zMax) and zMin or math.random(math.min(zMin, zMax), math.max(zMin, zMax))
                
                local p = Options.OffsetPitch.Value
                local yw = Options.OffsetYaw.Value
                local r = Options.OffsetRoll.Value
                local randAng = Options.OffsetRandAngle.Value
                
                if type(randAng) == "table" then
                    if randAng['pitch'] then p = math.random(-180, 180) end
                    if randAng['yaw'] then yw = math.random(-180, 180) end
                    if randAng['roll'] then r = math.random(-180, 180) end
                end

                local targetFake = RealCFrame * CFrame.new(x, y, z) * CFrame.Angles(math.rad(p), math.rad(yw), math.rad(r))
                
                if Toggles.OffsetAntiClip.Value then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {char}
                    local hit = Workspace:Raycast(RealCFrame.Position, targetFake.Position - RealCFrame.Position, rayParams)
                    if hit then
                        targetFake = CFrame.new(hit.Position) * CFrame.Angles(math.rad(p), math.rad(yw), math.rad(r))
                    end
                end
                FakeCFrame = targetFake
            end
        end

        hrp.CFrame = FakeCFrame
        
        if Toggles.VelocityBreakerEnabled.Value then
            hrp.AssemblyLinearVelocity = Vector3.new(Options.VelBreakX.Value, Options.VelBreakY.Value, Options.VelBreakZ.Value)
        else
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
        end
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        if Settings.Desync.ShowServerPosition or Settings.Desync.CharacterClone then
            if isRaknetHooked and FrozenRaknetCFrame then
                Settings.Desync.ServerPosition = FrozenRaknetCFrame.Position
                Settings.Desync.ServerCFrame = FrozenRaknetCFrame
            else
                Settings.Desync.ServerPosition = FakeCFrame.Position
                Settings.Desync.ServerCFrame = FakeCFrame
            end
        end
    else
        FrozenPosition = nil
        RealCFrame = nil
        RealVelocity = nil
        RealAngularVelocity = nil
        isVoided = false
        voidTimer = 0
        if (Settings.Desync.ShowServerPosition or Settings.Desync.CharacterClone) and hrp then
            if isRaknetHooked and FrozenRaknetCFrame then
                Settings.Desync.ServerPosition = FrozenRaknetCFrame.Position
                Settings.Desync.ServerCFrame = FrozenRaknetCFrame
            else
                Settings.Desync.ServerPosition = hrp.Position
                Settings.Desync.ServerCFrame = hrp.CFrame
            end
        end
    end
end))

table.insert(Connections, RunService.RenderStepped:Connect(function(deltaTime)
    tickTimer = tickTimer + deltaTime
    if tickTimer >= 0.1 then
        tickTimer = 0
        if Toggles.ShowWatermark.Value then
            Library:SetWatermark(string.format('Visuals Hub | %d FPS | %d ms', math.floor(1 / deltaTime), math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())))
        end
    end

    if Settings.FOV.Enabled or Settings.FOV.Filled then
        Settings.FOV.Position = UserInputService:GetMouseLocation()
    end

    -- Visuals render updates
    UpdateSelfChams()
    UpdateDesyncVisualizers()
    UpdateFOV()
    UpdateCrosshair()
    UpdateESP()

    if Toggles.AimAssist.Value and Options.AimKeybind:GetState() then
        if Toggles.StickyAim.Value then
            if not IsTargetValid(currentTarget, currentTargetPart) then currentTarget, currentTargetPart = GetClosestTarget() end
        else
            currentTarget, currentTargetPart = GetClosestTarget()
        end
        
        if currentTarget and currentTargetPart then
            local isVisibleToShoot = Toggles.VisibleCheck.Value and IsVisible(currentTargetPart, currentTarget.Character) or not Toggles.VisibleCheck.Value
            if isVisibleToShoot then
                local aimPos = currentTargetPart.Position
                if Toggles.EnableDistanceComp.Value then aimPos = aimPos + Vector3.new(0, (Camera.CFrame.Position - currentTargetPart.Position).Magnitude * Options.DistanceMultiplier.Value, 0) end
                if Toggles.EnablePrediction.Value then
                    local vel = currentTargetPart.Velocity
                    aimPos = aimPos + Vector3.new(vel.X * Options.PredictionX.Value, vel.Y * Options.PredictionY.Value, vel.Z * Options.PredictionX.Value)
                end
                local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
                if onScreen then
                    if Options.AimMethod.Value == 'MouseMoverel' then
                        local mousePos = UserInputService:GetMouseLocation()
                        local deltaX, deltaY = (screenPos.X - mousePos.X), (screenPos.Y - mousePos.Y)
                        if Toggles.EnableSmoothness.Value then deltaX, deltaY = deltaX / Options.SmoothnessAmount.Value, deltaY / Options.SmoothnessAmount.Value end
                        if mousemoverel then mousemoverel(deltaX, deltaY) end
                    elseif Options.AimMethod.Value == 'Camera' then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPos)
                        Camera.CFrame = Toggles.EnableSmoothness.Value and Camera.CFrame:Lerp(targetCFrame, 1 / Options.SmoothnessAmount.Value) or targetCFrame
                    end
                end
            end
        end
    else
        currentTarget, currentTargetPart = nil, nil
    end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChild("Humanoid")
    if char and hrp and humanoid then
        if Toggles.EnableFly.Value then
            humanoid.PlatformStand = true hrp.AssemblyLinearVelocity = Vector3.zero
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            hrp.CFrame = hrp.CFrame + (moveDir * (Options.FlySpeed.Value * deltaTime))
        else
            if Toggles.EnableWalkSpeed.Value then humanoid.WalkSpeed = Options.WalkSpeed.Value end
            if Toggles.EnableCFrameSpeed.Value and humanoid.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (Options.CFrameSpeed.Value * deltaTime))
            end
        end
    end
end))
