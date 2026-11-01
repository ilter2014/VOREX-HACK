-- [[ VOREX HACK - Speed Hub, NoClip, Air Jump + Vercel Auto-Update ]] --
local CURRENT_VERSION = "0.0.1" -- Sürümü artırdığında burayı da güncellemeyi unutma!
local UPDATE_CHECK_URL = "https://vorex-hack.vercel.app/fifasuperfootballversion.json"
local SCRIPT_SOURCE_URL = "https://vorex-hack.vercel.app/fifasuperfootball.lua"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

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
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
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
titleLabel.Text = "VOREX HACK v" .. CURRENT_VERSION .. " [INS - Paneli Gizler]"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 11
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Durum Değişkenleri
local currentSpeed = 16
local isSpeedEnabled = false
local isNoClipEnabled = false
local isAirJumpEnabled = false
local activeConnections = {}

-- 1. Hız Butonu
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -20, 0, 35)
speedBtn.Position = UDim2.new(0, 10, 0, 45)
speedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Text = "Hiz (16): KAPALI"
speedBtn.TextSize = 13
speedBtn.Font = Enum.Font.SourceSansBold
speedBtn.Parent = mainFrame

-- Hız Kutusu (Textbox)
local speedTextBox = Instance.new("TextBox")
speedTextBox.Size = UDim2.new(1, -20, 0, 30)
speedTextBox.Position = UDim2.new(0, 10, 0, 85)
speedTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
speedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedTextBox.PlaceholderText = "Hiz Gir (16 - 500)"
speedTextBox.Text = tostring(currentSpeed)
speedTextBox.TextSize = 12
speedTextBox.Font = Enum.Font.SourceSans
speedTextBox.Parent = mainFrame

-- 2. NoClip Butonu
local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(1, -20, 0, 35)
noclipBtn.Position = UDim2.new(0, 10, 0, 125)
noclipBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.Text = "NoClip (Duvar Gecis): KAPALI"
noclipBtn.TextSize = 13
noclipBtn.Font = Enum.Font.SourceSansBold
noclipBtn.Parent = mainFrame

-- 3. Air Jump Butonu
local airJumpBtn = Instance.new("TextButton")
airJumpBtn.Size = UDim2.new(1, -20, 0, 35)
airJumpBtn.Position = UDim2.new(0, 10, 0, 165)
airJumpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
airJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
airJumpBtn.Text = "Air Jump (Havada Ziplama): KAPALI"
airJumpBtn.TextSize = 13
airJumpBtn.Font = Enum.Font.SourceSansBold
airJumpBtn.Parent = mainFrame

-- Kapatma (Unload) Butonu
local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, -20, 0, 30)
unloadBtn.Position = UDim2.new(0, 10, 0, 210)
unloadBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.Text = "Kapat / Kaldir"
unloadBtn.TextSize = 12
unloadBtn.Font = Enum.Font.SourceSansBold
unloadBtn.Parent = mainFrame

-- INS Tuşu ile Paneli Gizleme / Açma
local insertConn = UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.Insert and not gp then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
table.insert(activeConnections, insertConn)

-- Vercel Otomatik Güncelleme Kontrolü
task.spawn(function()
    local success, response = pcall(function()
        return game:HttpGet(UPDATE_CHECK_URL)
    end)
    if success and response then
        pcall(function()
            local data = HttpService:JSONDecode(response)
            if data and data.Version then
                if data.Version ~= CURRENT_VERSION then
                    local newScript = game:HttpGet(SCRIPT_SOURCE_URL)
                    if newScript then
                        task.spawn(function()
                            loadstring(newScript)()
                        end)
                        return
                    end
                end
            end
        end)
    end
end)

-- Hız Ayar Mantığı (Min 16, Max 500)
speedTextBox.FocusLost:Connect(function()
    local val = tonumber(speedTextBox.Text)
    if val then
        currentSpeed = math.clamp(val, 16, 500)
        speedTextBox.Text = tostring(currentSpeed)
        if isSpeedEnabled then
            speedBtn.Text = "Hiz ("..currentSpeed.."): ACIK"
        end
    else
        speedTextBox.Text = tostring(currentSpeed)
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    isSpeedEnabled = not isSpeedEnabled
    speedBtn.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
    speedBtn.Text = isSpeedEnabled and ("Hiz ("..currentSpeed.."): ACIK") or ("Hiz ("..currentSpeed.."): KAPALI")
end)

noclipBtn.MouseButton1Click:Connect(function()
    isNoClipEnabled = not isNoClipEnabled
    noclipBtn.BackgroundColor3 = isNoClipEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
    noclipBtn.Text = isNoClipEnabled and "NoClip (Duvar Gecis): ACIK" or "NoClip (Duvar Gecis): KAPALI"
end)

airJumpBtn.MouseButton1Click:Connect(function()
    isAirJumpEnabled = not isAirJumpEnabled
    airJumpBtn.BackgroundColor3 = isAirJumpEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
    airJumpBtn.Text = isAirJumpEnabled and "Air Jump (Havada Ziplama): ACIK" or "Air Jump (Havada Ziplama): KAPALI"
end)

-- Havada Zıplama Tetikleyicisi (Air Jump)
local jumpConn = UserInputService.JumpRequest:Connect(function()
    if isAirJumpEnabled then
        local char = localPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(activeConnections, jumpConn)

-- Ana Döngü (RenderStepped - Hız ve NoClip Uygulaması)
local renderConn = RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    if char then
        -- Hız Uygulaması
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if isSpeedEnabled then
                humanoid.WalkSpeed = currentSpeed
            else
                humanoid.WalkSpeed = 16 -- Normal varsayılan hız
            end
        end

        -- NoClip Uygulaması (Açıksa duvar içinden geçer, kapalıysa eski haline döner)
        if isNoClipEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        else
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)
table.insert(activeConnections, renderConn)

-- Arayüzü Tamamen Kaldırma ve Her Şeyi İlk Haline Döndürme (Unload)
unloadBtn.MouseButton1Click:Connect(function()
    -- Bağlantıları ve döngüleri durdur
    for _, conn in ipairs(activeConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end

    -- Karakteri ilk haline sıfırla (Hız ve Çarpışmalar)
    local char = localPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    -- Arayüzü yok et
    if screenGui then
        screenGui:Destroy()
    end
end)
