-- [[ VOREX HUSSVALLEY HACK ]] --
local CURRENT_VERSION = "0.0.1"
local _env = (typeof(getgenv) == "function" and getgenv()) or _G
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

-- KALICI HAFIZA (State Persistence)
_env._vorexhack_PersistentState = _env._vorexhack_PersistentState or {
    speed = 50,
    isSpeedOn = false,
    savedKey = Enum.KeyCode.P
}
local state = _env._vorexhack_PersistentState

if _env._vorexhack_LoadedData then
    pcall(function()
        if _env._vorexhack_LoadedData.Cleanup then
            _env._vorexhack_LoadedData.Cleanup()
        end
    end)
    _env._vorexhack_LoadedData = nil
end

local function MainScript()
    local activeConnections = {}
    local currentSpeed = state.speed
    local isSpeedEnabled = state.isSpeedOn
    local selectedKey = state.savedKey
    local isListeningForKey = false

    local function SyncState()
        state.speed = currentSpeed
        state.isSpeedOn = isSpeedEnabled
        state.savedKey = selectedKey
    end

    -- GUI Oluşturma
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VorexSpeedHub"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local successGui = pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not successGui then
        screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    end

    -- Ana Pencere
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 260, 0, 210)
    mainFrame.Position = UDim2.new(0.5, -130, 0.5, -105)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    -- Başlık
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "VOREX SPEED v" .. CURRENT_VERSION .. " [INS]"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Kontroller Alanı
    local leftContainer = Instance.new("Frame")
    leftContainer.Size = UDim2.new(1, -20, 1, -45)
    leftContainer.Position = UDim2.new(0, 10, 0, 40)
    leftContainer.BackgroundTransparency = 1
    leftContainer.Parent = mainFrame

    local speedToggleButton = Instance.new("TextButton")
    speedToggleButton.Size = UDim2.new(1, 0, 0, 35)
    speedToggleButton.Position = UDim2.new(0, 0, 0, 0)
    speedToggleButton.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
    speedToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggleButton.Text = isSpeedEnabled and ("Speed Fly ("..currentSpeed.."): ON") or ("Speed Fly ("..currentSpeed.."): OFF")
    speedToggleButton.TextSize = 13
    speedToggleButton.Font = Enum.Font.SourceSansBold
    speedToggleButton.Parent = leftContainer

    local speedTextBox = Instance.new("TextBox")
    speedTextBox.Size = UDim2.new(1, 0, 0, 35)
    speedTextBox.Position = UDim2.new(0, 0, 0, 45)
    speedTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    speedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedTextBox.PlaceholderText = "Hiz Degeri (Max 50)"
    speedTextBox.Text = tostring(currentSpeed)
    speedTextBox.TextSize = 13
    speedTextBox.Font = Enum.Font.SourceSans
    speedTextBox.Parent = leftContainer

    local setKeyBtn = Instance.new("TextButton")
    setKeyBtn.Size = UDim2.new(1, 0, 0, 35)
    setKeyBtn.Position = UDim2.new(0, 0, 0, 90)
    setKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    setKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setKeyBtn.Text = "Hiz Acma Tusu: " .. selectedKey.Name
    setKeyBtn.TextSize = 12
    setKeyBtn.Font = Enum.Font.SourceSansBold
    setKeyBtn.Parent = leftContainer

    local unloadButton = Instance.new("TextButton")
    unloadButton.Size = UDim2.new(1, 0, 0, 35)
    unloadButton.Position = UDim2.new(0, 0, 0, 135)
    unloadButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    unloadButton.Text = "Unload Hub"
    unloadButton.TextSize = 13
    unloadButton.Font = Enum.Font.SourceSansBold
    unloadButton.Parent = leftContainer

    -- Toggle Eventleri
    speedToggleButton.MouseButton1Click:Connect(function()
        isSpeedEnabled = not isSpeedEnabled
        speedToggleButton.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
        speedToggleButton.Text = isSpeedEnabled and ("Speed Fly ("..currentSpeed.."): ON") or ("Speed Fly ("..currentSpeed.."): OFF")
        SyncState()
    end)

    speedTextBox.FocusLost:Connect(function()
        local v = tonumber(speedTextBox.Text)
        if v then
            currentSpeed = math.clamp(v, 16, 50)
            speedTextBox.Text = tostring(currentSpeed)
            if isSpeedEnabled then
                speedToggleButton.Text = "Speed Fly ("..currentSpeed.."): ON"
            end
            SyncState()
        else
            speedTextBox.Text = tostring(currentSpeed)
        end
    end)

    setKeyBtn.MouseButton1Click:Connect(function()
        isListeningForKey = true
        setKeyBtn.Text = "Tusa Bas..."
    end)

    local function UnloadHub()
        for _, conn in ipairs(activeConnections) do
            if conn and typeof(conn.Disconnect) == "function" then
                pcall(function() conn:Disconnect() end)
            end
        end
        if screenGui then
            pcall(function() screenGui:Destroy() end)
        end
        _env._vorexhack_LoadedData = nil
        print("[VorexSpeed]: Temizlendi.")
    end

    unloadButton.MouseButton1Click:Connect(UnloadHub)

    local insertConn = UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.Insert and not gp then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    table.insert(activeConnections, insertConn)

    local inputConn = UserInputService.InputBegan:Connect(function(input, gp)
        if isListeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
            selectedKey = input.KeyCode
            setKeyBtn.Text = "Hiz Acma Tusu: " .. input.KeyCode.Name
            isListeningForKey = false
            SyncState()
            return
        end
        if input.KeyCode == selectedKey and not gp then
            isSpeedEnabled = not isSpeedEnabled
            speedToggleButton.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
            speedToggleButton.Text = isSpeedEnabled and ("Speed Fly ("..currentSpeed.."): ON") or ("Speed Fly ("..currentSpeed.."): OFF")
            SyncState()
        end
    end)
    table.insert(activeConnections, inputConn)

    -- Ana Döngü (RenderStepped)
    local heartbeatConn = RunService.RenderStepped:Connect(function(dt)
        local char = localPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera

        if humanoid and rootPart then
            if isSpeedEnabled then
                humanoid.PlatformStand = true
                local camCF = camera.CFrame
                local moveDir = Vector3.new()

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end

                moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit
                end

                rootPart.Velocity = moveDir * currentSpeed + Vector3.new(0, 2, 0)
                rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z))
            else
                if humanoid.PlatformStand then
                    humanoid.PlatformStand = false
                end
            end
        end
    end)
    table.insert(activeConnections, heartbeatConn)

    _env._vorexhack_LoadedData = {
        Cleanup = UnloadHub
    }
end

MainScript()
