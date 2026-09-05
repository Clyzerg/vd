local Hook = {
    Players = {
        ["Killer"] = {
            Color = Color3.fromRGB(255, 93, 108),
            On = true
        },

        ["Survivor"] = {
            Color = Color3.fromRGB(64, 224, 255),
            On = true
        }
    },

    Objects = {
        ["Generator"] = {
            Color = Color3.fromRGB(210, 87, 255),
            On = true
        },

        ["Gate"] = {
            Color = Color3.fromRGB(255, 255, 255),
            On = true
        },

        ["Pallet"] = {
            Color = Color3.fromRGB(74, 255, 181),
            On = true
        },

        ["Window"] = {
            Color = Color3.fromRGB(74, 255, 181),
            On = true
        },

        ["Hook"] = {
            Color = Color3.fromRGB(132, 255, 169),
            On = true
        }
    },

    NametagOn = true
}

--// =========================================
--// SERVICES
--// =========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

--// =========================================
--// FOLDERS
--// =========================================

local folder = {
    ["Generator"] = workspace.Map,
    ["Gate"] = workspace.Map,
    ["Pallet"] = workspace.Map,
    ["Window"] = workspace,
    ["Hook"] = workspace.Map
}

local espCache = {}
local nametagCache = {}

--// =========================================
--// ESP
--// =========================================

local function ESP(obj, color, category)

    if not obj or not obj.Parent then
        return
    end

    local existing = obj:FindFirstChild("H")

    if existing then
        return
    end

    local h = Instance.new("Highlight")

    h.Name = "H"
    h.Adornee = obj

    h.FillColor = color
    h.OutlineColor = color

    h.FillTransparency = 0.8
    h.OutlineTransparency = 0.3

    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    h.Parent = obj

    espCache[obj] = {
        Highlight = h,
        Category = category
    }
end

--// =========================================
--// REMOVE ESP
--// =========================================

local function removeESP(obj)

    local data = espCache[obj]

    if data then

        if data.Highlight then
            data.Highlight:Destroy()
        end

        espCache[obj] = nil

        return
    end

    if obj then

        local h = obj:FindFirstChild("H")

        if h then
            h:Destroy()
        end
    end
end

--// =========================================
--// REMOVE CATEGORY
--// =========================================

local function removeCategory(category)

    for obj, data in pairs(espCache) do

        if data.Category == category then
            removeESP(obj)
        end
    end
end

--// =========================================
--// GET ROLE
--// =========================================

local function getPlayerRole(player)

    if player.Team then

        local teamName = player.Team.Name:lower()

        if teamName:find("killer") then
            return "Killer"
        end

        if teamName:find("survivor") then
            return "Survivor"
        end
    end

    return "Survivor"
end

--// =========================================
--// PLAYER ESP
--// =========================================

local function updatePlayerESP(player)

    if player == localPlayer then
        return
    end

    local character = player.Character

    if not character then
        return
    end

    local role = getPlayerRole(player)

    local enabled
    local color

    if role == "Killer" then

        enabled = Hook.Players.Killer.On
        color = Hook.Players.Killer.Color

    else

        enabled = Hook.Players.Survivor.On
        color = Hook.Players.Survivor.Color
    end

    local data = espCache[character]

    if enabled then

        if not data then

            ESP(
                character,
                color,
                role
            )

        elseif data.Highlight then

            -- Update color without recreating Highlight
            data.Highlight.FillColor = color
            data.Highlight.OutlineColor = color

        end

    else

        if data then
            removeESP(character)
        end
    end
end

--// =========================================
--// BILLBOARD
--// =========================================

local function createNametag(player)

    if nametagCache[player] then
        return nametagCache[player]
    end

    local character = player.Character

    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    local role = getPlayerRole(player)

    local color

    if role == "Killer" then
        color = Hook.Players.Killer.Color
    else
        color = Hook.Players.Survivor.Color
    end

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "BitchHook"
    billboard.AlwaysOnTop = true

    billboard.Size =
        UDim2.new(0, 120, 0, 30)

    billboard.StudsOffset =
        Vector3.new(0, 0, 0)

    billboard.Adornee = root
    billboard.Parent = root

    local textLabel = Instance.new("TextLabel")

    textLabel.Name = "BitchHook"

    textLabel.Size =
        UDim2.new(1, 0, 1, 0)

    textLabel.BackgroundTransparency = 1

    textLabel.TextColor3 = color

    textLabel.TextStrokeTransparency = 0

    textLabel.TextStrokeColor3 =
        Color3.new(0, 0, 0)

    textLabel.Font =
        Enum.Font.GothamBold

    textLabel.TextSize = 10

    textLabel.TextWrapped = true

    textLabel.Parent = billboard

    nametagCache[player] = {
        Billboard = billboard,
        Label = textLabel,
        Root = root,
        Role = role
    }

    return nametagCache[player]
end

--// =========================================
--// REMOVE NAMETAG
--// =========================================

local function removeNametag(player)

    local data = nametagCache[player]

    if data then

        if data.Billboard then
            data.Billboard:Destroy()
        end

        nametagCache[player] = nil
    end

    -- Safety cleanup for old tag
    if player.Character then

        local root =
            player.Character:FindFirstChild("HumanoidRootPart")

        if root then

            local old =
                root:FindFirstChild("BitchHook")

            if old then
                old:Destroy()
            end
        end
    end
end

--// =========================================
--// UPDATE NAMETAG
--// =========================================

local function updatePlayerNametag(player)

    if player == localPlayer then
        return
    end

    if not Hook.NametagOn then
        return
    end

    local character = player.Character

    if not character then
        removeNametag(player)
        return
    end

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    local role = getPlayerRole(player)

    -- Respect role toggle
    if role == "Killer"
        and not Hook.Players.Killer.On then

        removeNametag(player)
        return
    end

    if role == "Survivor"
        and not Hook.Players.Survivor.On then

        removeNametag(player)
        return
    end

    local data = nametagCache[player]

    -- Create only once
    if not data then

        data = createNametag(player)

        if not data then
            return
        end
    end

    -- Character changed
    if data.Root ~= root then

        data.Root = root

        data.Billboard.Adornee = root

        data.Billboard.Parent = root
    end

    -- Update color only
    local color

    if role == "Killer" then
        color = Hook.Players.Killer.Color
    else
        color = Hook.Players.Survivor.Color
    end

    data.Label.TextColor3 = color
    data.Role = role

    -- Distance
    local myCharacter =
        localPlayer.Character

    if not myCharacter then
        return
    end

    local myRoot =
        myCharacter:FindFirstChild("HumanoidRootPart")

    if not myRoot then
        return
    end

    local distance =
        math.floor(
            (root.Position - myRoot.Position).Magnitude
        )

    -- ONLY update text
    data.Label.Text =
        player.Name ..
        "\n[" ..
        distance ..
        " studs]"
end


local function scanCategory(category)

    local settings =
        Hook.Objects[category]

    if not settings then
        return
    end

    if not settings.On then
        return
    end

    local f =
        folder[category]

    if not f then
        return
    end

    local wantedName = category

    if category == "Pallet" then
        wantedName = "Palletwrong"
    end

    for _, obj in ipairs(f:GetDescendants()) do

        if category == "Hook" then

            if obj.Name == "Hook" then

                local model =
                    obj:FindFirstChild("Model")

                if model then

                    for _, part in
                        ipairs(model:GetDescendants()) do

                        if part:IsA("MeshPart") then

                            ESP(
                                part,
                                Hook.Objects.Hook.Color,
                                "Hook"
                            )
                        end
                    end
                end

                local blood =
                    obj:FindFirstChild(
                        "Cartoony Blood Puddle"
                    )

                if blood then

                    ESP(
                        blood,
                        Hook.Objects.Hook.Color,
                        "Hook"
                    )
                end
            end

        else

            if obj.Name == wantedName then

                ESP(
                    obj,
                    settings.Color,
                    category
                )
            end
        end
    end
end

for category in pairs(Hook.Objects) do
    scanCategory(category)
end

--// =========================================
--// PLAYER SETUP
--// =========================================

local function setupPlayer(player)

    if player == localPlayer then
        return
    end

    player.CharacterAdded:Connect(function()

        -- Wait for HumanoidRootPart
        task.wait(0.3)

        if not player.Character then
            return
        end

        updatePlayerESP(player)

        if Hook.NametagOn then
            updatePlayerNametag(player)
        end
    end)

    player.CharacterRemoving:Connect(function()

        removeNametag(player)

        if player.Character then
            removeESP(player.Character)
        end
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()

        updatePlayerESP(player)

        -- Team changed -> recreate nametag only once
        removeNametag(player)

        if Hook.NametagOn then
            updatePlayerNametag(player)
        end
    end)

    if player.Character then

        updatePlayerESP(player)

        if Hook.NametagOn then
            updatePlayerNametag(player)
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    setupPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)

    removeNametag(player)

    if player.Character then
        removeESP(player.Character)
    end
end)

--// =========================================
--// GUI
--// =========================================

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name = "ESPAdminMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.Parent = PlayerGui

--// =========================================
--// MAIN
--// =========================================

local Main = Instance.new("Frame")

Main.Name = "Main"

Main.Size =
    UDim2.new(0, 280, 0, 450)

Main.Position =
    UDim2.new(0.5, -140, 0.5, -225)

Main.BackgroundColor3 =
    Color3.fromRGB(18, 18, 24)

Main.BorderSizePixel = 0

Main.Parent = ScreenGui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(0, 12)

MainCorner.Parent = Main

--// =========================================
--// STROKE
--// =========================================

local Stroke =
    Instance.new("UIStroke")

Stroke.Color =
    Color3.fromRGB(65, 65, 80)

Stroke.Thickness = 1

Stroke.Parent = Main

--// =========================================
--// TOP BAR
--// =========================================

local TopBar =
    Instance.new("Frame")

TopBar.Size =
    UDim2.new(1, 0, 0, 45)

TopBar.BackgroundColor3 =
    Color3.fromRGB(25, 25, 34)

TopBar.BorderSizePixel = 0

TopBar.Parent = Main

local TopCorner =
    Instance.new("UICorner")

TopCorner.CornerRadius =
    UDim.new(0, 12)

TopCorner.Parent = TopBar

--// =========================================
--// TITLE
--// =========================================

local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.new(1, -90, 1, 0)

Title.Position =
    UDim2.new(0, 15, 0, 0)

Title.BackgroundTransparency = 1

Title.Text = "ESP  MENU"

Title.TextColor3 =
    Color3.fromRGB(255, 255, 255)

Title.TextSize = 16

Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent = TopBar

--// =========================================
--// MINIMIZE
--// =========================================

local Minimize =
    Instance.new("TextButton")

Minimize.Size =
    UDim2.new(0, 35, 0, 35)

Minimize.Position =
    UDim2.new(1, -75, 0, 5)

Minimize.BackgroundColor3 =
    Color3.fromRGB(45, 45, 55)

Minimize.Text = "—"

Minimize.TextColor3 =
    Color3.fromRGB(255, 255, 255)

Minimize.TextSize = 18

Minimize.Font =
    Enum.Font.GothamBold

Minimize.Parent = TopBar

local MinCorner =
    Instance.new("UICorner")

MinCorner.CornerRadius =
    UDim.new(0, 8)

MinCorner.Parent = Minimize

--// =========================================
--// CLOSE
--// =========================================

local Close =
    Instance.new("TextButton")

Close.Size =
    UDim2.new(0, 35, 0, 35)

Close.Position =
    UDim2.new(1, -38, 0, 5)

Close.BackgroundColor3 =
    Color3.fromRGB(180, 55, 65)

Close.Text = "×"

Close.TextColor3 =
    Color3.fromRGB(255, 255, 255)

Close.TextSize = 20

Close.Font =
    Enum.Font.GothamBold

Close.Parent = TopBar

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(0, 8)

CloseCorner.Parent = Close

--// =========================================
--// SCROLL
--// =========================================

local Scroll =
    Instance.new("ScrollingFrame")

Scroll.Size =
    UDim2.new(1, -20, 1, -60)

Scroll.Position =
    UDim2.new(0, 10, 0, 52)

Scroll.BackgroundTransparency = 1

Scroll.BorderSizePixel = 0

Scroll.ScrollBarThickness = 4

Scroll.ScrollBarImageTransparency = 0.3

Scroll.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

Scroll.Parent = Main

local Padding =
    Instance.new("UIPadding")

Padding.PaddingTop =
    UDim.new(0, 5)

Padding.PaddingBottom =
    UDim.new(0, 10)

Padding.Parent = Scroll

local Layout =
    Instance.new("UIListLayout")

Layout.Padding =
    UDim.new(0, 7)

Layout.SortOrder =
    Enum.SortOrder.LayoutOrder

Layout.Parent = Scroll

--// =========================================
--// SECTION
--// =========================================

local function createSection(text)

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(1, 0, 0, 25)

    label.BackgroundTransparency = 1

    label.Text = text

    label.TextColor3 =
        Color3.fromRGB(170, 170, 185)

    label.TextSize = 12

    label.Font =
        Enum.Font.GothamBold

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent = Scroll

    return label
end

--// =========================================
--// TOGGLE
--// =========================================

local buttons = {}

local function createToggle(name, setting, color)

    local button =
        Instance.new("TextButton")

    button.Size =
        UDim2.new(1, -5, 0, 38)

    button.BackgroundColor3 =
        Color3.fromRGB(32, 32, 42)

    button.BorderSizePixel = 0

    button.AutoButtonColor = false

    button.Text = ""

    button.Parent = Scroll

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 8)

    corner.Parent = button

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(1, -75, 1, 0)

    label.Position =
        UDim2.new(0, 12, 0, 0)

    label.BackgroundTransparency = 1

    label.Text = name

    label.TextColor3 =
        Color3.fromRGB(235, 235, 240)

    label.TextSize = 13

    label.Font =
        Enum.Font.GothamMedium

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent = button

    local status =
        Instance.new("TextLabel")

    status.Size =
        UDim2.new(0, 50, 0, 24)

    status.Position =
        UDim2.new(1, -60, 0.5, -12)

    status.BackgroundColor3 = color

    status.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    status.TextSize = 11

    status.Font =
        Enum.Font.GothamBold

    status.Parent = button

    local statusCorner =
        Instance.new("UICorner")

    statusCorner.CornerRadius =
        UDim.new(0, 7)

    statusCorner.Parent = status

    local function update()

        local enabled = false

        if setting == "Nametag" then

            enabled = Hook.NametagOn

        elseif Hook.Players[setting] then

            enabled =
                Hook.Players[setting].On

        elseif Hook.Objects[setting] then

            enabled =
                Hook.Objects[setting].On
        end

        if enabled then

            status.Text = "ON"

            status.BackgroundColor3 = color

        else

            status.Text = "OFF"

            status.BackgroundColor3 =
                Color3.fromRGB(65, 65, 75)
        end
    end

    button.MouseButton1Click:Connect(function()

        --// NAMETAG
        if setting == "Nametag" then

            Hook.NametagOn =
                not Hook.NametagOn

            if not Hook.NametagOn then

                for player in pairs(nametagCache) do
                    removeNametag(player)
                end

            else

                for _, player in
                    ipairs(Players:GetPlayers()) do

                    if player ~= localPlayer then
                        updatePlayerNametag(player)
                    end
                end
            end

        --// PLAYER
        elseif Hook.Players[setting] then

            Hook.Players[setting].On =
                not Hook.Players[setting].On

            for _, player in
                ipairs(Players:GetPlayers()) do

                if player ~= localPlayer then
                    updatePlayerESP(player)
                end
            end

            -- Nametag depends on player toggle
            for _, player in
                ipairs(Players:GetPlayers()) do

                if player ~= localPlayer
                    and Hook.NametagOn then

                    updatePlayerNametag(player)
                end
            end

        --// OBJECT
        elseif Hook.Objects[setting] then

            Hook.Objects[setting].On =
                not Hook.Objects[setting].On

            if Hook.Objects[setting].On then

                -- Scan ONLY this category
                scanCategory(setting)

            else

                -- Remove ONLY this category
                removeCategory(setting)
            end
        end

        update()
    end)

    buttons[setting] = update

    update()

    return button
end

--// =========================================
--// MENU
--// =========================================

createSection("PLAYERS")

createToggle(
    "Killer ESP",
    "Killer",
    Hook.Players.Killer.Color
)

createToggle(
    "Survivor ESP",
    "Survivor",
    Hook.Players.Survivor.Color
)

createToggle(
    "Nametag + Distance",
    "Nametag",
    Color3.fromRGB(255, 190, 70)
)

createSection("OBJECTS")

createToggle(
    "Generator",
    "Generator",
    Hook.Objects.Generator.Color
)

createToggle(
    "Gate",
    "Gate",
    Hook.Objects.Gate.Color
)

createToggle(
    "Pallet",
    "Pallet",
    Hook.Objects.Pallet.Color
)

createToggle(
    "Window",
    "Window",
    Hook.Objects.Window.Color
)

createToggle(
    "Hook",
    "Hook",
    Hook.Objects.Hook.Color
)

--// =========================================
--// MINIMIZE
--// =========================================

local minimized = false

Minimize.MouseButton1Click:Connect(function()

    minimized = not minimized

    Scroll.Visible = not minimized

    if minimized then

        Main.Size =
            UDim2.new(0, 280, 0, 45)

        Minimize.Text = "+"

    else

        Main.Size =
            UDim2.new(0, 280, 0, 450)

        Minimize.Text = "—"
    end
end)

--// =========================================
--// CLOSE
--// =========================================

Close.MouseButton1Click:Connect(function()

    -- Remove nametags
    for player in pairs(nametagCache) do
        removeNametag(player)
    end

    -- Remove all ESP
    for obj in pairs(espCache) do
        removeESP(obj)
    end

    ScreenGui:Destroy()
end)

--// =========================================
--// DRAG
--// =========================================

local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        dragging = true

        dragStart = input.Position
        startPosition = Main.Position
    end
end)

TopBar.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement then

        local delta =
            input.Position - dragStart

        Main.Position =
            UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,

                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
    end
end)

--// =========================================
--// INITIAL PLAYER ESP
--// =========================================

for _, player in ipairs(Players:GetPlayers()) do

    if player ~= localPlayer then

        updatePlayerESP(player)

        if Hook.NametagOn then
            updatePlayerNametag(player)
        end
    end
end

local lastUpdate = 0

RunService.Heartbeat:Connect(function()

    local currentTime = tick()

    if currentTime - lastUpdate < 0.15 then
        return
    end

    lastUpdate = currentTime

    if not Hook.NametagOn then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= localPlayer then
            updatePlayerNametag(player)
        end
    end
end)