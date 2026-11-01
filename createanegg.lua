-- [[ VOREX HACK - Smart KillAura, Target Lock & Safe 40-Speed Hub + Vercel Auto-Update ]] --
local CURRENT_VERSION = "0.0.1" -- Sürümü artırdığında burayı da güncellemeyi unutma!
local UPDATE_CHECK_URL = "https://vorex-hack.vercel.app/createaneggversion.json"
local SCRIPT_SOURCE_URL = "https://ilter-hack.vercel.app/createanegg.lua"

local _env = (typeof(getgenv) == "function" and getgenv()) or _G
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer

-- KALICI HAFIZA (State Persistence)
_env._vorexhack_PersistentState = _env._vorexhack_PersistentState or {
    speed = 50,
    isSpeedOn = false,
    isEspOn = false,
    isEggConfirmOn = true,
    isKillAuraOn = false,
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
    local isEspEnabled = state.isEspOn
    local isHumanEggConfirmEnabled = state.isEggConfirmOn
    local isKillAuraEnabled = state.isKillAuraOn
    local isConsoleVisible = true
    local isTargetPanelVisible = true
    local targetPosition = nil
    local isAutoWalking = false
    local selectedKey = state.savedKey
    local isListeningForKey = false
    local selectedTargetCharacter = nil
    local selectedTargetName = "Yok"
    local isTrackingPlayer = false
    local playerHighlights = {}
    local bypassCooldownUntil = 0
    local lastAuraAttack = 0
    local wasSpeedActiveBeforeWalk = false

    local function SyncState()
        state.speed = currentSpeed
        state.isSpeedOn = isSpeedEnabled
        state.isEspOn = isEspEnabled
        state.isEggConfirmOn = isHumanEggConfirmEnabled
        state.isKillAuraOn = isKillAuraEnabled
        state.savedKey = selectedKey
    end

    -- Otomatik Başlangıç Konumu Al
    task.spawn(function()
        task.wait(1)
        pcall(function()
            local char = localPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                targetPosition = char.HumanoidRootPart.Position
            end
        end)
    end)

    -- GUI Oluşturma
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VorexSafeAutoWalkHub"
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
    mainFrame.Size = UDim2.new(0, 1110, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -555, 0.5, -240)
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
    titleLabel.Text = "VOREX HACK v" .. CURRENT_VERSION .. " | THE ULTIMATE ROBLOX EXPERIENCE [INS - Paneli Gizler/Açar]"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Console Kapatma/Açma Butonu
    local toggleConsoleBtn = Instance.new("TextButton")
    toggleConsoleBtn.Size = UDim2.new(0, 120, 0, 25)
    toggleConsoleBtn.Position = UDim2.new(1, -125, 0, 5)
    toggleConsoleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleConsoleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleConsoleBtn.Text = "Console: AÇIK"
    toggleConsoleBtn.TextSize = 11
    toggleConsoleBtn.Font = Enum.Font.SourceSansBold
    toggleConsoleBtn.Parent = mainFrame

    -- Hedef Paneli Kapatma/Açma Butonu
    local toggleTargetBtn = Instance.new("TextButton")
    toggleTargetBtn.Size = UDim2.new(0, 120, 0, 25)
    toggleTargetBtn.Position = UDim2.new(1, -250, 0, 5)
    toggleTargetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleTargetBtn.Text = "Hedefler: AÇIK"
    toggleTargetBtn.TextSize = 11
    toggleTargetBtn.Font = Enum.Font.SourceSansBold
    toggleTargetBtn.Parent = mainFrame

    -- 1. SOL PANEL (Kontroller)
    local leftContainer = Instance.new("Frame")
    leftContainer.Size = UDim2.new(0, 250, 1, -45)
    leftContainer.Position = UDim2.new(0, 10, 0, 40)
    leftContainer.BackgroundTransparency = 1
    leftContainer.Parent = mainFrame

    local speedToggleButton = Instance.new("TextButton")
    speedToggleButton.Size = UDim2.new(1, 0, 0, 30)
    speedToggleButton.Position = UDim2.new(0, 0, 0, 0)
    speedToggleButton.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
    speedToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggleButton.Text = isSpeedEnabled and ("Speed Fly ("..currentSpeed.."): ON") or ("Speed Fly ("..currentSpeed.."): OFF")
    speedToggleButton.TextSize = 13
    speedToggleButton.Font = Enum.Font.SourceSansBold
    speedToggleButton.Parent = leftContainer

    -- KillAura Toggle Butonu
    local killAuraToggleButton = Instance.new("TextButton")
    killAuraToggleButton.Size = UDim2.new(1, 0, 0, 30)
    killAuraToggleButton.Position = UDim2.new(0, 0, 0, 35)
    killAuraToggleButton.BackgroundColor3 = isKillAuraEnabled and Color3.fromRGB(150, 60, 40) or Color3.fromRGB(50, 50, 50)
    killAuraToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraToggleButton.Text = isKillAuraEnabled and "Smart KillAura (15 Stud): ON" or "Smart KillAura (15 Stud): OFF"
    killAuraToggleButton.TextSize = 12
    killAuraToggleButton.Font = Enum.Font.SourceSansBold
    killAuraToggleButton.Parent = leftContainer

    local espToggleButton = Instance.new("TextButton")
    espToggleButton.Size = UDim2.new(1, 0, 0, 30)
    espToggleButton.Position = UDim2.new(0, 0, 0, 70)
    espToggleButton.BackgroundColor3 = isEspEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
    espToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espToggleButton.Text = isEspEnabled and "ESP (Oyuncular & Nick): ON" or "ESP (Oyuncular & Nick): OFF"
    espToggleButton.TextSize = 12
    espToggleButton.Font = Enum.Font.SourceSansBold
    espToggleButton.Parent = leftContainer

    -- İnsan Egg Onayı Ayar Butonu
    local confirmEggBtn = Instance.new("TextButton")
    confirmEggBtn.Size = UDim2.new(1, 0, 0, 30)
    confirmEggBtn.Position = UDim2.new(0, 0, 0, 105)
    confirmEggBtn.BackgroundColor3 = isHumanEggConfirmEnabled and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(80, 40, 40)
    confirmEggBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmEggBtn.Text = isHumanEggConfirmEnabled and "İnsan Egg Onayı: ON" or "İnsan Egg Onayı: OFF"
    confirmEggBtn.TextSize = 12
    confirmEggBtn.Font = Enum.Font.SourceSansBold
    confirmEggBtn.Parent = leftContainer

    local speedTextBox = Instance.new("TextBox")
    speedTextBox.Size = UDim2.new(1, 0, 0, 30)
    speedTextBox.Position = UDim2.new(0, 0, 0, 140)
    speedTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    speedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedTextBox.PlaceholderText = "Hiz Degeri (Max 75)"
    speedTextBox.Text = tostring(currentSpeed)
    speedTextBox.TextSize = 13
    speedTextBox.Font = Enum.Font.SourceSans
    speedTextBox.Parent = leftContainer

    local setPosBtn = Instance.new("TextButton")
    setPosBtn.Size = UDim2.new(0.6, 0, 0, 30)
    setPosBtn.Position = UDim2.new(0, 0, 0, 175)
    setPosBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
    setPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setPosBtn.Text = "Konum Al: OK"
    setPosBtn.TextSize = 11
    setPosBtn.Font = Enum.Font.SourceSansBold
    setPosBtn.Parent = leftContainer

    local setKeyBtn = Instance.new("TextButton")
    setKeyBtn.Size = UDim2.new(0.37, 0, 0, 30)
    setKeyBtn.Position = UDim2.new(0.63, 0, 0, 175)
    setKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    setKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setKeyBtn.Text = "Tus: " .. selectedKey.Name
    setKeyBtn.TextSize = 11
    setKeyBtn.Font = Enum.Font.SourceSansBold
    setKeyBtn.Parent = leftContainer

    local unloadButton = Instance.new("TextButton")
    unloadButton.Size = UDim2.new(1, 0, 0, 30)
    unloadButton.Position = UDim2.new(0, 0, 0, 215)
    unloadButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    unloadButton.Text = "Unload Hub"
    unloadButton.TextSize = 13
    unloadButton.Font = Enum.Font.SourceSansBold
    unloadButton.Parent = leftContainer

    -- 2. ORTA PANEL (Oyuncu Listesi)
    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(0, 260, 1, -45)
    targetFrame.Position = UDim2.new(0, 265, 0, 40)
    targetFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    targetFrame.BorderSizePixel = 0
    targetFrame.Parent = mainFrame

    local targetTitle = Instance.new("TextLabel")
    targetTitle.Size = UDim2.new(1, 0, 0, 25)
    targetTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    targetTitle.Text = "Oyuncu Hedefleri"
    targetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetTitle.TextSize = 12
    targetTitle.Font = Enum.Font.SourceSansBold
    targetTitle.Parent = targetFrame

    local targetScrolling = Instance.new("ScrollingFrame")
    targetScrolling.Size = UDim2.new(1, -10, 1, -35)
    targetScrolling.Position = UDim2.new(0, 5, 0, 30)
    targetScrolling.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    targetScrolling.BorderSizePixel = 0
    targetScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    targetScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    targetScrolling.ScrollBarThickness = 5
    targetScrolling.Parent = targetFrame

    local targetListLayout = Instance.new("UIListLayout")
    targetListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    targetListLayout.Padding = UDim.new(0, 4)
    targetListLayout.Parent = targetScrolling

    -- 3. SAĞ PANEL (Console)
    local consoleHolder = Instance.new("ScrollingFrame")
    consoleHolder.Size = UDim2.new(0, 565, 1, -45)
    consoleHolder.Position = UDim2.new(0, 535, 0, 40)
    consoleHolder.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    consoleHolder.BorderSizePixel = 0
    consoleHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    consoleHolder.ScrollBarThickness = 6
    consoleHolder.Parent = mainFrame

    local consoleLayout = Instance.new("UIListLayout")
    consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    consoleLayout.Padding = UDim.new(0, 2)
    consoleLayout.Parent = consoleHolder

    local function LogToConsole(msg)
        pcall(function()
            local logItem = Instance.new("TextLabel")
            logItem.Size = UDim2.new(1, -10, 0, 18)
            logItem.BackgroundTransparency = 1
            logItem.TextColor3 = Color3.fromRGB(50, 255, 50)
            logItem.TextSize = 11
            logItem.Font = Enum.Font.Code
            logItem.Text = msg
            logItem.TextXAlignment = Enum.TextXAlignment.Left
            logItem.Parent = consoleHolder
            if #consoleHolder:GetChildren() > 100 then
                local oldest = consoleHolder:GetChildren()[1]
                if oldest and oldest:IsA("TextLabel") then
                    oldest:Destroy()
                end
            end
            consoleHolder.CanvasPosition = Vector2.new(0, consoleHolder.AbsoluteCanvasSize.Y)
        end)
    end

    LogToConsole("-- [VOREX HACK v" .. CURRENT_VERSION .. " | NO LIMITS. NO BOUNDARIES. Aktif] --")

    -- Vercel Otomatik Güncelleme Konsol Logları Entegrasyonu
    task.spawn(function()
        LogToConsole("[AutoUpdate] Guncelleme kontrol ediliyor...")
        local success, response = pcall(function()
            return game:HttpGet(UPDATE_CHECK_URL)
        end)
        if success and response then
            pcall(function()
                local data = HttpService:JSONDecode(response)
                if data and data.Version then
                    if data.Version ~= CURRENT_VERSION then
                        LogToConsole("[AutoUpdate] Yeni surum bulundu: v" .. data.Version .. " (Mevcut: v" .. CURRENT_VERSION .. ")")
                        LogToConsole("[AutoUpdate] Yeni betik indiriliyor...")
                        local newScript = game:HttpGet(SCRIPT_SOURCE_URL)
                        if newScript then
                            LogToConsole("[AutoUpdate] Guncelleme basariyla uygulaniyor...")
                            task.spawn(function()
                                loadstring(newScript)()
                            end)
                            return
                        end
                    else
                        LogToConsole("[AutoUpdate] Surum guncel (v" .. CURRENT_VERSION .. ").")
                    end
                end
            end)
        else
            LogToConsole("[AutoUpdate] Guncelleme sunucusuna baglanilamadi.")
        end
    end)

    -- Toggle Eventleri
    killAuraToggleButton.MouseButton1Click:Connect(function()
        isKillAuraEnabled = not isKillAuraEnabled
        killAuraToggleButton.BackgroundColor3 = isKillAuraEnabled and Color3.fromRGB(150, 60, 40) or Color3.fromRGB(50, 50, 50)
        killAuraToggleButton.Text = isKillAuraEnabled and "Smart KillAura (15 Stud): ON" or "Smart KillAura (15 Stud): OFF"
        SyncState()
        if isKillAuraEnabled then
            LogToConsole("[KillAura] Aktif Edildi. 1 tusuna basilarak sopa kusaniliyor...")
            task.spawn(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                task.wait(0.15)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            end)
        else
            LogToConsole("[KillAura] Kapatildi.")
        end
    end)

    confirmEggBtn.MouseButton1Click:Connect(function()
        isHumanEggConfirmEnabled = not isHumanEggConfirmEnabled
        confirmEggBtn.Text = isHumanEggConfirmEnabled and "Insan Egg Onayi: ON" or "Insan Egg Onayi: OFF"
        confirmEggBtn.BackgroundColor3 = isHumanEggConfirmEnabled and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(80, 40, 40)
        SyncState()
        LogToConsole("[Ayar] Insan Egg Onayi: " .. tostring(isHumanEggConfirmEnabled))
    end)

    speedToggleButton.MouseButton1Click:Connect(function()
        isSpeedEnabled = not isSpeedEnabled
        speedToggleButton.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
        speedToggleButton.Text = isSpeedEnabled and ("Speed Fly ("..currentSpeed.."): ON") or ("Speed Fly ("..currentSpeed.."): OFF")
        SyncState()
    end)

    espToggleButton.MouseButton1Click:Connect(function()
        isEspEnabled = not isEspEnabled
        espToggleButton.BackgroundColor3 = isEspEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
        espToggleButton.Text = isEspEnabled and "ESP (Oyuncular & Nick): ON" or "ESP (Oyuncular & Nick): OFF"
        SyncState()
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

    speedTextBox.FocusLost:Connect(function()
        local v = tonumber(speedTextBox.Text)
        if v then
            currentSpeed = math.clamp(v, 16, 75)
            speedTextBox.Text = tostring(currentSpeed)
            if isSpeedEnabled then
                speedToggleButton.Text = "Speed Fly ("..currentSpeed.."): ON"
            end
            SyncState()
        else
            speedTextBox.Text = tostring(currentSpeed)
        end
    end)

    -- Yerleşim Düzenleyici
    local function UpdateLayoutSizes()
        local targetW = isTargetPanelVisible and 270 or 0
        local consoleW = isConsoleVisible and 575 or 0
        if isTargetPanelVisible then
            targetFrame.Visible = true
            targetFrame.Position = UDim2.new(0, 265, 0, 40)
        else
            targetFrame.Visible = false
        end
        if isConsoleVisible then
            consoleHolder.Visible = true
            local consolePosX = isTargetPanelVisible and 535 or 265
            consoleHolder.Position = UDim2.new(0, consolePosX, 0, 40)
        else
            consoleHolder.Visible = false
        end
        local totalWidth = 250 + 20 + targetW + (isTargetPanelVisible and isConsoleVisible and 10 or 0) + consoleW
        mainFrame.Size = UDim2.new(0, math.max(totalWidth, 275), 0, 480)
    end

    toggleConsoleBtn.MouseButton1Click:Connect(function()
        isConsoleVisible = not isConsoleVisible
        toggleConsoleBtn.Text = isConsoleVisible and "Console: ACIK" or "Console: KAPALI"
        toggleConsoleBtn.BackgroundColor3 = isConsoleVisible and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(100, 50, 50)
        UpdateLayoutSizes()
    end)

    toggleTargetBtn.MouseButton1Click:Connect(function()
        isTargetPanelVisible = not isTargetPanelVisible
        toggleTargetBtn.Text = isTargetPanelVisible and "Hedefler: ACIK" or "Hedefler: KAPALI"
        toggleTargetBtn.BackgroundColor3 = isTargetPanelVisible and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(100, 50, 50)
        UpdateLayoutSizes()
    end)

    -- Oyuncu Listesi Döngüsü
    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                if not isTargetPanelVisible then return end
                for _, child in ipairs(targetScrolling:GetChildren()) do
                    if child:IsA("Frame") then
                        child:Destroy()
                    end
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character then
                        local char = player.Character
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local row = Instance.new("Frame")
                            row.Size = UDim2.new(1, 0, 0, 30)
                            row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                            row.BorderSizePixel = 0
                            row.Parent = targetScrolling

                            local nameLbl = Instance.new("TextLabel")
                            nameLbl.Size = UDim2.new(0.5, 0, 1, 0)
                            nameLbl.Position = UDim2.new(0, 5, 0, 0)
                            nameLbl.BackgroundTransparency = 1
                            nameLbl.Text = "- " .. player.DisplayName
                            nameLbl.TextColor3 = Color3.fromRGB(255, 180, 220)
                            nameLbl.TextSize = 11
                            nameLbl.Font = Enum.Font.SourceSansBold
                            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                            nameLbl.Parent = row

                            -- Git Butonu
                            local goBtn = Instance.new("TextButton")
                            goBtn.Size = UDim2.new(0.22, 0, 0.8, 0)
                            goBtn.Position = UDim2.new(0.51, 0, 0.1, 0)
                            goBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
                            goBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            goBtn.Text = "Git"
                            goBtn.TextSize = 10
                            goBtn.Font = Enum.Font.SourceSansBold
                            goBtn.Parent = row
                            goBtn.MouseButton1Click:Connect(function()
                                if isSpeedEnabled then
                                    wasSpeedActiveBeforeWalk = true
                                    isSpeedEnabled = false
                                    speedToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                    speedToggleButton.Text = "Speed Fly ("..currentSpeed.."): OFF"
                                else
                                    wasSpeedActiveBeforeWalk = false
                                end
                                isAutoWalking = false
                                selectedTargetCharacter = char
                                selectedTargetName = player.DisplayName
                                isTrackingPlayer = true
                                LogToConsole("[Hedef] " .. selectedTargetName .. " yanina gidiliyor (Hiz: 40)...")
                            end)

                            -- Saldır Butonu
                            local attackBtn = Instance.new("TextButton")
                            attackBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
                            attackBtn.Position = UDim2.new(0.74, 0, 0.1, 0)
                            local isThisLocked = (isTrackingPlayer and selectedTargetCharacter == char)
                            attackBtn.BackgroundColor3 = isThisLocked and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(140, 50, 150)
                            attackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            attackBtn.Text = isThisLocked and "Iptal" or "Saldir"
                            attackBtn.TextSize = 10
                            attackBtn.Font = Enum.Font.SourceSansBold
                            attackBtn.Parent = row
                            attackBtn.MouseButton1Click:Connect(function()
                                if isTrackingPlayer and selectedTargetCharacter == char then
                                    isTrackingPlayer = false
                                    selectedTargetCharacter = nil
                                    LogToConsole("[TargetLock] Saldiri emri iptal edildi.")
                                    attackBtn.BackgroundColor3 = Color3.fromRGB(140, 50, 150)
                                    attackBtn.Text = "Saldir"
                                    if wasSpeedActiveBeforeWalk then
                                        isSpeedEnabled = true
                                        speedToggleButton.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
                                        speedToggleButton.Text = "Speed Fly ("..currentSpeed.."): ON"
                                        wasSpeedActiveBeforeWalk = false
                                    end
                                else
                                    if isSpeedEnabled then
                                        wasSpeedActiveBeforeWalk = true
                                        isSpeedEnabled = false
                                        speedToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                        speedToggleButton.Text = "Speed Fly ("..currentSpeed.."): OFF"
                                    else
                                        wasSpeedActiveBeforeWalk = false
                                    end
                                    isAutoWalking = false
                                    selectedTargetCharacter = char
                                    selectedTargetName = player.DisplayName
                                    isTrackingPlayer = true
                                    task.spawn(function()
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                                        task.wait(0.15)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                                    end)
                                    LogToConsole(string.format("[TargetLock] [%s] icin SALDIRI emri verildi!", selectedTargetName))
                                end
                            end)
                        end
                    end
                end
            end)
        end
    end)

    -- ESP Güncelleme
    local function updatePlayerEsp()
        if not isEspEnabled then return end
        local currentPlayers = {}
        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                local root = character:FindFirstChild("HumanoidRootPart")
                if head and root then
                    currentPlayers[player] = true
                    if not playerHighlights[player] then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "VorexHackPlayerEsp"
                        highlight.Adornee = character
                        highlight.FillTransparency = 1
                        highlight.OutlineColor = Color3.fromRGB(255, 100, 200)
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = character

                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "BB_Player_" .. player.Name
                        billboard.Size = UDim2.fromOffset(280, 64)
                        billboard.StudsOffsetWorldSpace = Vector3.new(0, 4.2, 0)
                        billboard.AlwaysOnTop = true
                        billboard.LightInfluence = 0
                        billboard.MaxDistance = 1500
                        billboard.Adornee = head
                        billboard.Parent = character

                        local label = Instance.new("TextLabel")
                        label.Name = "PlayerInfo"
                        label.Size = UDim2.fromScale(1, 1)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextStrokeTransparency = 0.15
                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label.TextSize = 20
                        label.Font = Enum.Font.GothamBold
                        label.RichText = true
                        label.Parent = billboard

                        playerHighlights[player] = { Highlight = highlight, Billboard = billboard, Label = label }
                    else
                        local data = playerHighlights[player]
                        if data.Highlight then
                            data.Highlight.Adornee = character
                            data.Highlight.Parent = character
                        end
                        if data.Billboard then
                            data.Billboard.Adornee = head
                            data.Billboard.Parent = character
                        end
                    end
                    local data = playerHighlights[player]
                    if data and data.Label and myRoot then
                        local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                        data.Label.Text = string.format("%s\n@%s - %d studs", player.DisplayName, player.Name, dist)
                    end
                end
            end
        end
        for player, data in pairs(playerHighlights) do
            if not currentPlayers[player] then
                if data then
                    pcall(function()
                        if data.Highlight then data.Highlight:Destroy() end
                        if data.Billboard then data.Billboard:Destroy() end
                    end)
                end
                playerHighlights[player] = nil
            end
        end
    end

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
        print("[VorexHack]: Temizlendi.")
    end

    local insertConn = UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.Insert and not gp then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    table.insert(activeConnections, insertConn)

    setPosBtn.MouseButton1Click:Connect(function()
        local char = localPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            targetPosition = char.HumanoidRootPart.Position
            setPosBtn.Text = "Konum Alindi!"
            LogToConsole("[AutoWalk] Hedef konum kaydedildi.")
        end
    end)

    setKeyBtn.MouseButton1Click:Connect(function()
        isListeningForKey = true
        setKeyBtn.Text = "Tusa Bas..."
    end)

    local inputConn = UserInputService.InputBegan:Connect(function(input, gp)
        if isListeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
            selectedKey = input.KeyCode
            setKeyBtn.Text = "Tus: " .. input.KeyCode.Name
            setKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            isListeningForKey = false
            SyncState()
            return
        end
        if input.KeyCode == selectedKey then
            if targetPosition then
                isAutoWalking = not isAutoWalking
                if isAutoWalking then
                    if isSpeedEnabled then
                        wasSpeedActiveBeforeWalk = true
                        isSpeedEnabled = false
                        speedToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        speedToggleButton.Text = "Speed Fly ("..currentSpeed.."): OFF"
                    else
                        wasSpeedActiveBeforeWalk = false
                    end
                    isTrackingPlayer = false
                    selectedTargetCharacter = nil
                end
                LogToConsole("[AutoWalk] Durum: " .. tostring(isAutoWalking) .. " (Hiz: 40)")
            else
                LogToConsole("[AutoWalk] Once 'Konum Al' tusuna bas!")
            end
        end
    end)
    table.insert(activeConnections, inputConn)

    -- Ana Döngü (RenderStepped)
    local serverAngle = 0
    local radius = 12.5
    local syncTimer = 0
    local heartbeatConn = RunService.RenderStepped:Connect(function(dt)
        local char = localPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera

        if humanoid and rootPart then
            if isSpeedEnabled then
                humanoid.PlatformStand = true
                local camCF = camera and camera.CFrame or CFrame.new()
                local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
                local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
                if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

                local moveVector = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + flatLook end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - flatLook end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - flatRight end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + flatRight end

                if moveVector.Magnitude > 0 then
                    moveVector = moveVector.Unit
                    rootPart.CFrame = rootPart.CFrame + (moveVector * (currentSpeed * dt))
                    serverAngle = serverAngle + (currentSpeed / radius) * dt
                    local fakeOffsetX = math.cos(serverAngle) * radius
                    local fakeOffsetZ = math.sin(serverAngle) * radius
                    syncTimer = syncTimer + dt
                    if syncTimer >= 0.4 then
                        syncTimer = 0
                        pcall(function()
                            rootPart.CFrame = CFrame.new(rootPart.Position.X + (fakeOffsetX * 0.1), rootPart.Position.Y, rootPart.Position.Z + (fakeOffsetZ * 0.1)) * camCF.Rotation
                        end)
                    end
                end
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            else
                humanoid.PlatformStand = false
            end

            -- Smart KillAura
            if isKillAuraEnabled then
                local currentTime = tick()
                if currentTime - lastAuraAttack >= math.random(30, 45) / 100 then
                    pcall(function()
                        local closestTarget = nil
                        local minDst = 16
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= localPlayer and player.Character then
                                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                                    local dist = (targetRoot.Position - rootPart.Position).Magnitude
                                    if dist <= 15 and dist < minDst then
                                        minDst = dist
                                        closestTarget = targetRoot
                                    end
                                end
                            end
                        end
                        if closestTarget then
                            task.spawn(function()
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                                task.wait(0.05)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                            end)
                            local offsetPos = closestTarget.Position
                            rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(offsetPos + Vector3.new(0, 0.5, 0)), 0.25)
                            if minDst <= 5.5 then
                                lastAuraAttack = currentTime
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.03)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end
                        end
                    end)
                end
            end

            -- AutoWalk Mantığı
            if isAutoWalking and targetPosition and char and humanoid then
                pcall(function()
                    if rootPart then
                        local currentPos = rootPart.Position
                        local flatTarget = Vector3.new(targetPosition.X, currentPos.Y, targetPosition.Z)
                        local distance = (flatTarget - currentPos).Magnitude
                        if distance < 5 then
                            isAutoWalking = false
                            humanoid:MoveTo(currentPos)
                            LogToConsole("[AutoWalk] Hedefe ulasildi.")
                            if wasSpeedActiveBeforeWalk then
                                isSpeedEnabled = true
                                speedToggleButton.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
                                speedToggleButton.Text = "Speed Fly ("..currentSpeed.."): ON"
                                wasSpeedActiveBeforeWalk = false
                            end
                        else
                            isSpeedEnabled = false
                            humanoid.WalkSpeed = 40
                            local dir = (flatTarget - currentPos).Unit
                            rootPart.CFrame = rootPart.CFrame + (dir * (40 * dt))
                        end
                    end
                end)
            end

            -- Player Tracking & Target Lock
            if isTrackingPlayer and selectedTargetCharacter and selectedTargetCharacter.Parent and char and humanoid then
                pcall(function()
                    local targetRoot = selectedTargetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = selectedTargetCharacter:FindFirstChildOfClass("Humanoid")
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and myRoot then
                        local targetPos = targetRoot.Position
                        local currentPos = myRoot.Position
                        local flatTarget = Vector3.new(targetPos.X, currentPos.Y, targetPos.Z)
                        local distance = (flatTarget - currentPos).Magnitude

                        task.spawn(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                            task.wait(0.02)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                        end)

                        if distance > 3.5 then
                            isSpeedEnabled = false
                            humanoid.WalkSpeed = 40
                            local dir = (flatTarget - currentPos).Unit
                            rootPart.CFrame = rootPart.CFrame + (dir * (40 * dt))
                        else
                            rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(targetPos + Vector3.new(0, 0.2, 0)), 0.3)
                            local currentTime = tick()
                            if currentTime - lastAuraAttack >= math.random(25, 40) / 100 then
                                lastAuraAttack = currentTime
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.03)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end
                        end
                    else
                        isTrackingPlayer = false
                        selectedTargetCharacter = nil
                        LogToConsole("[TargetLock] Hedef ortadan kayboldu veya oldu.")
                        if wasSpeedActiveBeforeWalk then
                            isSpeedEnabled = true
                            speedToggleButton.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
                            speedToggleButton.Text = "Speed Fly ("..currentSpeed.."): ON"
                            wasSpeedActiveBeforeWalk = false
                        end
                    end
                end)
            elseif isTrackingPlayer and (not selectedTargetCharacter or not selectedTargetCharacter.Parent) then
                isTrackingPlayer = false
                selectedTargetCharacter = nil
                LogToConsole("[TargetLock] Hedef oyuncu oyundan cikti.")
                if wasSpeedActiveBeforeWalk then
                    isSpeedEnabled = true
                    speedToggleButton.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
                    speedToggleButton.Text = "Speed Fly ("..currentSpeed.."): ON"
                    wasSpeedActiveBeforeWalk = false
                end
            end

            if isEspEnabled then
                pcall(updatePlayerEsp)
            end
        end
    end)
    table.insert(activeConnections, heartbeatConn)

    unloadButton.MouseButton1Click:Connect(UnloadHub)
    _env._vorexhack_LoadedData = { Cleanup = UnloadHub }
end

pcall(MainScript)
