-- [[ vorex-hack - Single Tap FPS Hub + Vercel Auto-Update ]] --
local CURRENT_VERSION = "1.0.0"
local UPDATE_CHECK_URL = "https://vorex-hack.vercel.app/single-tap-FPSversion.json"
local SCRIPT_SOURCE_URL = "https://vorex-hack.vercel.app/single-tap-FPS.lua"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local localPlayer = Players.LocalPlayer

-- Durum Değişkenleri
local isEspEnabled = false
local isAimbotEnabled = false
local isWallhackAttackEnabled = false -- Duvar Arkası Vurma
local playerHighlights = {}
local lastAttackTick = 0

-- GUI Oluşturma
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VorexFPSHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not screenGui.Parent then
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

-- Ana Pencere
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Başlık
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Vorex FPS v" .. CURRENT_VERSION .. " [INS: Gizle]"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Buton Oluşturucu Yardımcısı
local function createButton(posY, defaultText)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = defaultText
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = mainFrame
    return btn
end

local espBtn = createButton(45, "ESP & Wallhack: KAPALI")
local aimbotBtn = createButton(85, "Aimbot (Kafa Kilidi): KAPALI")
local wallhackAttackBtn = createButton(125, "Duvar Arkası Vurma: KAPALI")
local unloadBtn = createButton(165, "Hub'ı Kapat (Unload)")

local function Log(msg)
    print("[VorexFPS]: " .. msg)
end

-- Vercel Otomatik Güncelleme Sistemi
task.spawn(function()
    Log("Güncelleme kontrol ediliyor...")
    local success, response = pcall(function()
        return game:HttpGet(UPDATE_CHECK_URL)
    end)
    if success and response then
        pcall(function()
            local data = HttpService:JSONDecode(response)
            if data and data.Version and data.Version ~= CURRENT_VERSION then
                Log("🔄 Yeni sürüm bulundu: v" .. data.Version .. ". İndiriliyor...")
                local newScript = game:HttpGet(SCRIPT_SOURCE_URL)
                if newScript then
                    Log("✅ Güncelleme uygulanıyor...")
                    task.spawn(function() loadstring(newScript)() end)
                    screenGui:Destroy()
                end
            else
                Log("✔️ Sürüm güncel (v" .. CURRENT_VERSION .. ").")
            end
        end)
    else
        Log("⚠️ Güncelleme sunucusuna bağlanılamadı.")
    end
end)

-- Tuş ile Paneli Gizleme/Açma (INSERT)
UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.Insert and not gp then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- ESP & Wallhack Fonksiyonu
espBtn.MouseButton1Click:Connect(function()
    isEspEnabled = not isEspEnabled
    espBtn.BackgroundColor3 = isEspEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(45, 45, 55)
    espBtn.Text = isEspEnabled and "ESP & Wallhack: AÇIK" or "ESP & Wallhack: KAPALI"
    
    if not isEspEnabled then
        for _, data in pairs(playerHighlights) do
            if data then
                pcall(function()
                    data.Highlight:Destroy()
                    data.Billboard:Destroy()
                end)
            end
        end
        playerHighlights = {}
    end
end)

-- Aimbot Toggle
aimbotBtn.MouseButton1Click:Connect(function()
    isAimbotEnabled = not isAimbotEnabled
    aimbotBtn.BackgroundColor3 = isAimbotEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(45, 45, 55)
    aimbotBtn.Text = isAimbotEnabled and "Aimbot (Kafa Kilidi): AÇIK" or "Aimbot (Kafa Kilidi): KAPALI"
end)

-- Duvar Arkası Vurma Toggle
wallhackAttackBtn.MouseButton1Click:Connect(function()
    isWallhackAttackEnabled = not isWallhackAttackEnabled
    wallhackAttackBtn.BackgroundColor3 = isWallhackAttackEnabled and Color3.fromRGB(150, 60, 40) or Color3.fromRGB(45, 45, 55)
    wallhackAttackBtn.Text = isWallhackAttackEnabled and "Duvar Arkası Vurma: AÇIK" or "Duvar Arkası Vurma: KAPALI"
end)

-- Hub'ı Temizleme
unloadBtn.MouseButton1Click:Connect(function()
    for _, data in pairs(playerHighlights) do
        pcall(function() data.Highlight:Destroy(); data.Billboard:Destroy() end)
    end
    screenGui:Destroy()
    Log("Hub kapatıldı ve temizlendi.")
end)

-- Ana Döngü (RenderStepped)
RunService.RenderStepped:Connect(function(dt)
    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera

    -- 1. ESP & Wallhack (AlwaysOnTop ile duvar arkasından görünürlük)
    if isEspEnabled then
        local currentPlayers = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                local root = character:FindFirstChild("HumanoidRootPart")
                if head and root then
                    currentPlayers[player] = true
                    if not playerHighlights[player] then
                        local highlight = Instance.new("Highlight")
                        highlight.Adornee = character
                        highlight.FillTransparency = 1
                        highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = character

                        local billboard = Instance.new("BillboardGui")
                        billboard.Size = UDim2.fromOffset(200, 50)
                        billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Adornee = head
                        billboard.Parent = character

                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.fromScale(1, 1)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextStrokeTransparency = 0.2
                        label.TextSize = 14
                        label.Font = Enum.Font.GothamBold
                        label.Parent = billboard

                        playerHighlights[player] = { Highlight = highlight, Billboard = billboard, Label = label }
                    else
                        local data = playerHighlights[player]
                        if data.Label and myRoot then
                            local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                            data.Label.Text = string.format("%s (%d studs)", player.DisplayName, dist)
                        end
                    end
                end
            end
        end
        for player, data in pairs(playerHighlights) do
            if not currentPlayers[player] then
                pcall(function() data.Highlight:Destroy(); data.Billboard:Destroy() end)
                playerHighlights[player] = nil
            end
        end
    end

    -- 2. Aimbot (Kamerayı en yakın hedef kafasına sabitleme)
    if isAimbotEnabled and myRoot then
        local closestTarget = nil
        local shortestDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local head = player.Character:FindFirstChild("Head")
                if hum and hum.Health > 0 and head then
                    local dist = (head.Position - myRoot.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestTarget = head
                    end
                end
            end
        end
        if closestTarget and camera then
            camera.CFrame = CFrame.new(camera.CFrame.Position, closestTarget.Position)
        end
    end

    -- 3. Duvar Arkası Vurma (Mesafe Taramalı Atış Simülasyonu)
    if isWallhackAttackEnabled and myRoot then
        local currentTime = tick()
        if currentTime - lastAttackTick >= 0.2 then
            lastAttackTick = currentTime
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                        if targetRoot and targetHum and targetHum.Health > 0 then
                            local dist = (targetRoot.Position - myRoot.Position).Magnitude
                            if dist <= 25 then
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.02)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)
