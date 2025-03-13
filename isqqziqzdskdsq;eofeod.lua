local Library = {}
local mainKeybind = "RightShift"
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Hide UI in CoreGui using gethui
local function gethui()
    return CoreGui
end

-- Create a draggable UI element
local function CreateDrag(gui)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Create a new window
function Library:NewWindow(title)
    local window = {
        CurrentTab = nil
    }

    -- Create the main UI container
    local SolarUI = Instance.new("ScreenGui")
    SolarUI.Name = "SolarUI"
    SolarUI.Parent = gethui()
    SolarUI.ResetOnSpawn = false
    SolarUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 500, 0, 400)
    Main.Position = UDim2.new(0.5, -250, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 0
    Main.ZIndex = 100
    Main.Parent = SolarUI

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 0, 30)
    Title.Position = UDim2.new(0.05, 0, 0.02, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.ZIndex = 101
    Title.Parent = Main

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 450, 0, 30)
    TabContainer.Position = UDim2.new(0.05, 0, 0.1, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ZIndex = 102
    TabContainer.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 10)
    TabLayout.Parent = TabContainer

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(0, 450, 0, 300)
    ContentContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 103
    ContentContainer.Parent = Main

    -- Make the window draggable
    CreateDrag(Main)

    -- Toggle UI visibility with keybind
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[mainKeybind] then
            SolarUI.Enabled = not SolarUI.Enabled
        end
    end)

    -- Add a new tab
    function window:NewTab(tabName)
        local tab = {
            Active = false
        }

        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton"
        TabButton.Size = UDim2.new(0, 100, 0, 30)
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.BorderSizePixel = 0
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.ZIndex = 104
        TabButton.Parent = TabContainer

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "TabContent"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 0
        TabContent.Visible = false
        TabContent.ZIndex = 105
        TabContent.Parent = ContentContainer

        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.Padding = UDim.new(0, 10)
        TabContentLayout.Parent = TabContent

        -- Activate the tab
        function tab:Activate()
            if not tab.Active then
                if window.CurrentTab then
                    window.CurrentTab:Deactivate()
                end
                tab.Active = true
                TabContent.Visible = true
                TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                window.CurrentTab = tab
            end
        end

        -- Deactivate the tab
        function tab:Deactivate()
            if tab.Active then
                tab.Active = false
                TabContent.Visible = false
                TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end

        -- Automatically activate the first tab
        if not window.CurrentTab then
            tab:Activate()
        end

        -- Switch tabs on click
        TabButton.MouseButton1Click:Connect(function()
            tab:Activate()
        end)

        -- Add a toggle button
        function tab:NewToggle(title, default, callback)
            local toggle = {
                State = default
            }

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.ZIndex = 106
            ToggleFrame.Parent = TabContent

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = title
            ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextSize = 14
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.ZIndex = 107
            ToggleLabel.Parent = ToggleFrame

            local ToggleButton = Instance.new("Frame")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Size = UDim2.new(0, 50, 0, 20)
            ToggleButton.Position = UDim2.new(0.8, 0, 0.5, -10)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ToggleButton.ZIndex = 108
            ToggleButton.Parent = ToggleFrame

            local ToggleButtonCorner = Instance.new("UICorner")
            ToggleButtonCorner.CornerRadius = UDim.new(0, 10)
            ToggleButtonCorner.Parent = ToggleButton

            local ToggleKnob = Instance.new("Frame")
            ToggleKnob.Name = "ToggleKnob"
            ToggleKnob.Size = UDim2.new(0, 20, 0, 20)
            ToggleKnob.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            ToggleKnob.ZIndex = 109
            ToggleKnob.Parent = ToggleButton

            local ToggleKnobCorner = Instance.new("UICorner")
            ToggleKnobCorner.CornerRadius = UDim.new(0, 10)
            ToggleKnobCorner.Parent = ToggleKnob

            -- Update toggle state
            local function updateToggle(state)
                toggle.State = state
                if state then
                    TS:Create(ToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0.6, 0, 0, 0)}):Play()
                    TS:Create(ToggleKnob, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
                else
                    TS:Create(ToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 0, 0, 0)}):Play()
                    TS:Create(ToggleKnob, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
                end
                callback(state)
            end

            -- Initialize toggle
            updateToggle(default)

            -- Toggle on click
            ToggleButton.MouseButton1Click:Connect(function()
                updateToggle(not toggle.State)
            end)

            return toggle
        end

        return tab
    end

    return window
end

return Library
