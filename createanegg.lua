-- [[ VOREX HACK - CoreGui / PlayerGui Fix Entegre Edilmiş Sürüm ]] --
local CURRENT_VERSION = "0.0.4"
local UPDATE_CHECK_URL = "https://vorex-hack.vercel.app/createaneggversion.json"
local UPDATE_BASE_URL = "https://vorex-hack.vercel.app"
local SCRIPT_SOURCE_URL = "https://vorex-hack.vercel.app/createanegg.lua"

local _env = (typeof(getgenv) == "function" and getgenv()) or _G
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
if not localPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    localPlayer = Players.LocalPlayer
end

-- KALICI HAFIZA (State Persistence)
_env._vorexhack_PersistentState = _env._vorexhack_PersistentState or {
    speed = 50,
    isSpeedOn = false,
    isEspOn = false,
    isEggConfirmOn = true,
    isKillAuraOn = false,
    isInvisibleOn = false,
    isAutoPickOn = false,
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


-- ============================================================
-- KALICI OYUN & FPS OPTİMİZASYON SİSTEMİ (Kapanamaz / Always Active)
-- ============================================================
local function ApplyPermanentOptimization()

-- ============================================================
-- GRAFİK & DOKU GERİ YÜKLEME SİSTEMİ (Unload Sırasında Çalışır)
-- ============================================================
local function RestoreOptimization()
    pcall(function()
        if _env._vorexhack_OptimizationConnection then
            pcall(function() _env._vorexhack_OptimizationConnection:Disconnect() end)
            _env._vorexhack_OptimizationConnection = nil
        end

        local renderSettings = settings():GetService("RenderSettings")
        if renderSettings then
            pcall(function() renderSettings.QualityLevel = Enum.QualityLevel.Automatic end)
        end

        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = true
            end
        end

        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0.15
            terrain.WaterWaveSpeed = 10
            terrain.WaterReflectance = 1
            terrain.WaterTransparency = 1
            pcall(function() terrain.Decoration = true end)
        end

        for _, inst in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if inst:IsA("BasePart") then
                    inst.CastShadow = true
                    inst.Material = Enum.Material.Plastic
                elseif inst:IsA("Decal") or inst:IsA("Texture") then
                    inst.Transparency = 0
                elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
                    inst.Enabled = true
                end
            end)
        end
    end)
end

    pcall(function()
        if setfpscap and typeof(setfpscap) == "function" then
            pcall(function() setfpscap(999) end)
        end
        local renderSettings = settings():GetService("RenderSettings")
        if renderSettings then
            pcall(function() renderSettings.QualityLevel = Enum.QualityLevel.Level01 end)
        end

        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        pcall(function() Lighting.Technology = Enum.Technology.Compatibility end)

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end

        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            pcall(function() terrain.Decoration = false end)
        end

        local function optimizeInstance(inst)
            pcall(function()
                if inst:IsA("BasePart") then
                    inst.CastShadow = false
                    inst.Reflectance = 0
                    inst.Material = Enum.Material.SmoothPlastic
                elseif inst:IsA("Decal") or inst:IsA("Texture") then
                    inst.Transparency = 1
                elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
                    inst.Enabled = false
                end
            end)
        end

        for _, desc in ipairs(Workspace:GetDescendants()) do
            optimizeInstance(desc)
        end

        if _env._vorexhack_OptimizationConnection then
            pcall(function() _env._vorexhack_OptimizationConnection:Disconnect() end)
        end
        _env._vorexhack_OptimizationConnection = Workspace.DescendantAdded:Connect(function(inst)
            optimizeInstance(inst)
        end)
    end)
end

-- Kalıcı optimizasyonu başlat
ApplyPermanentOptimization()

-- ============================================================
-- GRAFİK & DOKU GERİ YÜKLEME SİSTEMİ (Unload Sırasında Çalışır)
-- ============================================================
local function RestoreOptimization()
    pcall(function()
        if _env._vorexhack_OptimizationConnection then
            pcall(function() _env._vorexhack_OptimizationConnection:Disconnect() end)
            _env._vorexhack_OptimizationConnection = nil
        end

        local renderSettings = settings():GetService("RenderSettings")
        if renderSettings then
            pcall(function() renderSettings.QualityLevel = Enum.QualityLevel.Automatic end)
        end

        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = true
            end
        end

        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0.15
            terrain.WaterWaveSpeed = 10
            terrain.WaterReflectance = 1
            terrain.WaterTransparency = 1
            pcall(function() terrain.Decoration = true end)
        end

        for _, inst in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if inst:IsA("BasePart") then
                    inst.CastShadow = true
                    inst.Material = Enum.Material.Plastic
                elseif inst:IsA("Decal") or inst:IsA("Texture") then
                    inst.Transparency = 0
                elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
                    inst.Enabled = true
                end
            end)
        end
    end)
end


-- Periyodik Bellek Temizliği (Garbage Collection)
task.spawn(function()
    while true do
        task.wait(45)
        pcall(function() collectgarbage("collect") end)
    end
end)

local function MainScript()
    local consoleHolder = nil
    local function LogToConsole(msg)
        pcall(function()
            if consoleHolder then
                local logItem = Instance.new("TextLabel")
                logItem.Size = UDim2.new(1, -10, 0, 18)
                logItem.BackgroundTransparency = 1
                logItem.TextColor3 = Color3.fromRGB(50, 255, 50)
                logItem.TextSize = 11
                logItem.Font = Enum.Font.Code
                logItem.Text = tostring(msg)
                logItem.TextXAlignment = Enum.TextXAlignment.Left
                logItem.Parent = consoleHolder
                if #consoleHolder:GetChildren() > 100 then
                    local oldest = consoleHolder:GetChildren()[1]
                    if oldest and oldest:IsA("TextLabel") then oldest:Destroy() end
                end
                consoleHolder.CanvasPosition = Vector2.new(0, consoleHolder.AbsoluteCanvasSize.Y)
            end
        end)
        print("[VOREX HACK]: " .. tostring(msg))
    end
    local activeConnections = {}
    local currentSpeed = state.speed
    local isSpeedEnabled = state.isSpeedOn
    local isEspEnabled = state.isEspOn
    local isHumanEggConfirmEnabled = state.isEggConfirmOn
    local isKillAuraEnabled = state.isKillAuraOn
    local isInvisibleEnabled = state.isInvisibleOn or false
    local isAutoPickEnabled = state.isAutoPickOn or false
    local eggHighlights = {}
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
    local lastAuraAttack = 0

    local function SyncState()
        state.speed = currentSpeed
        state.isSpeedOn = isSpeedEnabled
        state.isEspOn = isEspEnabled
        state.isEggConfirmOn = isHumanEggConfirmEnabled
        state.isKillAuraOn = isKillAuraEnabled
        state.isInvisibleOn = isInvisibleEnabled
        state.isAutoPickOn = isAutoPickEnabled
        state.savedKey = selectedKey
    end

    -- Orijinal part verisi kaydi
    local _origPartData = {}

    local function setInvisibility(enable)
        pcall(function()
            local char = localPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")

            -- Yontem 1: Scale sifir yap (100% server replicate, herkes gorur)
            if hum then
                local scales = {"BodyDepthScale","BodyHeightScale","BodyWidthScale","HeadScale"}
                for _, sn in ipairs(scales) do
                    local sv = hum:FindFirstChild(sn)
                    if sv then
                        if enable then
                            _origPartData["sc_"..sn] = sv.Value
                            sv.Value = 0.01
                        else
                            sv.Value = _origPartData["sc_"..sn] or 1
                        end
                    end
                end
            end

            -- Yontem 2: Rengi gokyuzu rengiyle ayni yap (kamuflaj)
            local SKY = Color3.fromRGB(178, 212, 238)
            for _, item in ipairs(char:GetDescendants()) do
                pcall(function()
                    if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
                        if enable then
                            _origPartData[item] = {c=item.Color, t=item.Transparency, m=item.Material}
                            item.Color = SKY
                            item.Transparency = 0.98
                            item.Material = Enum.Material.SmoothPlastic
                        else
                            local d = _origPartData[item]
                            if d then item.Color=d.c; item.Transparency=d.t; item.Material=d.m end
                        end
                    elseif item:IsA("Decal") or item:IsA("Texture") then
                        if enable then
                            _origPartData["d"..tostring(item)] = item.Transparency
                            item.Transparency = 1
                        else
                            item.Transparency = _origPartData["d"..tostring(item)] or 0
                        end
                    end
                end)
            end
        end)
    end

    -- Otomatik Başlangıç Konumu Al & Anti-AFK
    task.spawn(function()
        task.wait(1)
        pcall(function()
            local char = localPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                targetPosition = char.HumanoidRootPart.Position
            end
        end)
        
        local vu = game:GetService("VirtualUser")
        local afkConn = localPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        table.insert(activeConnections, afkConn)
    end)


    -- ============================================================
    -- ANTI-CHEAT BYPASS SİSTEMİ (En Güçlü Koruma & Kick Engelleyici)
    -- ============================================================
    local function InstallAntiCheatBypass()
        pcall(function()
            if typeof(hookmetamethod) == "function" and typeof(newcclosure) == "function" then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if not checkcaller() and (method == "Kick" or method == "kick") then
                        pcall(function() LogToConsole("[Anti-Cheat Bypass] Kick girişimi engellendi!") end)
                        return nil
                    end
                    return oldNamecall(self, ...)
                end))
            end

            -- Anti-Crash Safe
            pcall(function()
                -- Safe error absorbing
            end)
        end)
    end
    InstallAntiCheatBypass()

    -- ============================================================
    -- "FAKE AN EGG" GERÇEK/SAHTE YUMURTA DEDEKTÖRÜ & ESP
    -- ============================================================
    local function updateEggAndFakeDetection()
        if not isEspEnabled then return end
        pcall(function()
            local myChar = localPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local currentEggs = {}

            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") or (obj:IsA("Model") and (obj.Name:lower():find("egg") or obj.Name:lower():find("yumurta"))) then
                    local targetModel = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
                    if targetModel and targetModel ~= myChar and not currentEggs[targetModel] then
                        local isPlayerChar = Players:GetPlayerFromCharacter(targetModel)
                            or (targetModel:FindFirstChildOfClass("Humanoid") and targetModel:FindFirstChild("HumanoidRootPart"))
                        
                        local primaryPart = targetModel.PrimaryPart or targetModel:FindFirstChild("HumanoidRootPart") or targetModel:FindFirstChildWhichIsA("BasePart")
                        if primaryPart then
                            currentEggs[targetModel] = true
                            if not eggHighlights[targetModel] then
                                local hl = Instance.new("Highlight")
                                hl.Name = "VorexEggHighlight"
                                hl.Adornee = targetModel
                                hl.FillTransparency = 0.4
                                hl.OutlineTransparency = 0
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                                local bb = Instance.new("BillboardGui")
                                bb.Name = "VorexEggBB"
                                bb.Size = UDim2.fromOffset(220, 50)
                                bb.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
                                bb.AlwaysOnTop = true
                                bb.Adornee = primaryPart

                                local lbl = Instance.new("TextLabel")
                                lbl.Size = UDim2.fromScale(1, 1)
                                lbl.BackgroundTransparency = 1
                                lbl.TextSize = 15
                                lbl.Font = Enum.Font.GothamBold
                                lbl.RichText = true
                                lbl.Parent = bb

                                if isPlayerChar then
                                    hl.FillColor = Color3.fromRGB(255, 30, 30)
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                                    lbl.TextColor3 = Color3.fromRGB(255, 70, 70)
                                    lbl.Text = "⚠️ [SAHTE EGG - OYUNCU!]"
                                else
                                    hl.FillColor = Color3.fromRGB(40, 255, 120)
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    lbl.TextColor3 = Color3.fromRGB(120, 255, 150)
                                    lbl.Text = "✨ [GERÇEK YUMURTA]"
                                end

                                hl.Parent = targetModel
                                bb.Parent = targetModel
                                eggHighlights[targetModel] = { Highlight = hl, Billboard = bb, Label = lbl, IsFake = isPlayerChar }
                            else
                                local data = eggHighlights[targetModel]
                                if data and data.Label and myRoot then
                                    local dist = math.floor((myRoot.Position - primaryPart.Position).Magnitude)
                                    if data.IsFake then
                                        data.Label.Text = string.format("⚠️ <b>[SAHTE EGG - OYUNCU!]</b>\n%s (%d studs)", targetModel.Name, dist)
                                    else
                                        data.Label.Text = string.format("✨ <b>[GERÇEK YUMURTA]</b>\n%s (%d studs)", targetModel.Name, dist)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            for model, data in pairs(eggHighlights) do
                if not currentEggs[model] or not model.Parent then
                    pcall(function()
                        if data.Highlight then data.Highlight:Destroy() end
                        if data.Billboard then data.Billboard:Destroy() end
                    end)
                    eggHighlights[model] = nil
                end
            end
        end)
    end

    
    -- ============================================================
    -- AKILLI ENGEL GÖRME & YOL BULMA SİSTEMİ (Raycast & Pathfinding)
    -- ============================================================
    local lastJumpTick = 0
    local function SmartWalkWithObstacleAvoidance(targetPos, speed)
        local char = localPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart or not targetPos then return end

        humanoid.PlatformStand = false
        humanoid.WalkSpeed = speed or 28

        local currentPos = rootPart.Position
        local lookVector = rootPart.CFrame.LookVector
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude

        -- Önü kontrol eden 2 kademeli Raycast sensörü (Duvar, çit ve kapı kontrolü)
        local headRay = Workspace:Raycast(currentPos + Vector3.new(0, 1.5, 0), lookVector * 5, rayParams)
        local footRay = Workspace:Raycast(currentPos - Vector3.new(0, 1, 0), lookVector * 4.5, rayParams)

        local currentTime = tick()
        if (headRay or footRay) and (currentTime - lastJumpTick > 0.8) then
            lastJumpTick = currentTime
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            humanoid.Jump = true
        end

        -- Pathfinding ile akıllı dolaşım
        pcall(function()
            local path = PathfindingService:CreatePath({
                AgentRadius = 2.5,
                AgentHeight = 5,
                AgentCanJump = true,
                WaypointSpacing = 3
            })
            path:ComputeAsync(currentPos, targetPos)

            if path.Status == Enum.PathStatus.Success then
                local waypoints = path:GetWaypoints()
                if #waypoints > 1 then
                    local nextPoint = waypoints[2]
                    if nextPoint.Action == Enum.PathWaypointAction.Jump and (currentTime - lastJumpTick > 0.8) then
                        lastJumpTick = currentTime
                        humanoid.Jump = true
                    end
                    humanoid:MoveTo(nextPoint.Position)
                    return
                end
            end

            -- Eğer Pathfinding hesaplanamazsa raycast tabanlı akıllı sapma
            local dir = (targetPos - currentPos).Unit
            if headRay then
                -- Duvar varsa sağa/sola hafif kırarak yön değiştir
                dir = (rootPart.CFrame.RightVector * 0.9 + dir).Unit
            end
            humanoid:MoveTo(currentPos + dir * 6)
        end)
    end

    -- ============================================================
    -- GERÇEK KLAVYE TAKLİDİ (Anti-Packet Exploit / Base Scanner Bypass)
    -- ============================================================
    local isStealingInProgress = false
    local function SafeKeyboardInteract(prompt)
        if isStealingInProgress or not prompt or not prompt.Parent then return end
        isStealingInProgress = true

        task.spawn(function()
            pcall(function()
                local key = prompt.KeyboardKeyCode or Enum.KeyCode.E
                local duration = prompt.HoldDuration
                local requiredHold = duration > 0 and (duration + 0.12) or 0.15

                LogToConsole(string.format("[SafeSteal] Base koruması bypass ediliyor: %s tuşuna basılıyor...", key.Name))

                -- Karakteri prompt'a çevir (Doğal insan davranışı)
                local char = localPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                local promptPart = prompt.Parent:IsA("BasePart") and prompt.Parent or (prompt.Parent:IsA("Model") and prompt.Parent.PrimaryPart)
                if rootPart and promptPart then
                    rootPart.CFrame = CFrame.lookAt(rootPart.Position, Vector3.new(promptPart.Position.X, rootPart.Position.Y, promptPart.Position.Z))
                end

                -- 1. Gerçek Donanım Tuş Basımı (VirtualInputManager & InputHoldBegin)
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                pcall(function() prompt:InputHoldBegin() end)

                -- 2. Sunucunun şüpheli paket kontrolünü aşmak için tam hold süresi kadar bekle
                local elapsed = 0
                while elapsed < requiredHold and prompt and prompt.Parent do
                    task.wait(0.05)
                    elapsed = elapsed + 0.05
                end

                -- 3. Tuşu bırak
                pcall(function() prompt:InputHoldEnd() end)
                VirtualInputManager:SendKeyEvent(false, key, false, game)

                LogToConsole("[SafeSteal] Paket onaylandı! Yumurta başarıyla çalındı.")
            end)

            task.wait(0.3)
            isStealingInProgress = false
        end)
    end

-- ============================================================
    -- OTOMATİK GÜVENLİ YUMURTA TOPLAMA & ÇALMA (Safe Keyboard Pick)
    -- ============================================================
    local lastPickTick = 0
    local function autoPickNearbyEggs()
        if not isAutoPickEnabled or isStealingInProgress then return end
        local currentTime = tick()
        if currentTime - lastPickTick < 0.3 then return end
        lastPickTick = currentTime

        pcall(function()
            local myChar = localPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end

            local closestPrompt = nil
            local minPromptDist = 15

            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    local model = prompt:FindFirstAncestorOfClass("Model")
                    local isFake = model and (Players:GetPlayerFromCharacter(model) or model:FindFirstChildOfClass("Humanoid"))

                    -- İnsan Egg Koruması açıksa sahte oyuncu yumurtalarına dokunma
                    if not (isHumanEggConfirmEnabled and isFake) then
                        local promptPart = prompt.Parent:IsA("BasePart") and prompt.Parent or (model and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")))
                        if promptPart then
                            local dist = (promptPart.Position - myRoot.Position).Magnitude
                            if dist <= (prompt.MaxActivationDistance + 5) and dist < minPromptDist then
                                minPromptDist = dist
                                closestPrompt = prompt
                            end
                        end
                    end
                end
            end

            if closestPrompt then
                SafeKeyboardInteract(closestPrompt)
            end
        end)
    end

    -- GUI Oluşturma (Evrensel Executor & CoreGui / gethui / PlayerGui Garantisi)
    -- Eski açık GUI varsa temizle
    pcall(function()
        if typeof(gethui) == "function" and gethui() and gethui():FindFirstChild("VorexSafeAutoWalkHub") then
            gethui():FindFirstChild("VorexSafeAutoWalkHub"):Destroy()
        end
        local pg = localPlayer:FindFirstChildOfClass("PlayerGui")
        if pg and pg:FindFirstChild("VorexSafeAutoWalkHub") then
            pg:FindFirstChild("VorexSafeAutoWalkHub"):Destroy()
        end
    end)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VorexSafeAutoWalkHub"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local guiParent = nil
    -- 1. gethui (Delta, Fluxus, Wave, Arceus X, Codex, Solara)
    if typeof(gethui) == "function" then
        pcall(function()
            local h = gethui()
            if h then
                screenGui.Parent = h
                guiParent = h
            end
        end)
    end

    -- 2. syn.protect_gui
    if not guiParent and typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
        pcall(function()
            syn.protect_gui(screenGui)
            screenGui.Parent = game:GetService("CoreGui")
            guiParent = game:GetService("CoreGui")
        end)
    end

    -- 3. CoreGui (Safe pcall)
    if not guiParent then
        pcall(function()
            local core = game:GetService("CoreGui")
            if core then
                screenGui.Parent = core
                guiParent = core
            end
        end)
    end

    -- 4. PlayerGui (Garantili Çözüm)
    if not guiParent or not screenGui.Parent then
        local pGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 10)
        if pGui then
            screenGui.Parent = pGui
            guiParent = pGui
        end
    end

    -- Respawn koruması
    localPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if screenGui and not screenGui.Parent and guiParent then
            pcall(function() screenGui.Parent = guiParent end)
        end
    end)

    -- Ana Pencere
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 1110, 0, 520)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = true
    mainFrame.Parent = screenGui

    -- Ekranda Yüzen Aç/Kapat Butonu (Mobil & Klavyede Insert Olmayanlar İçin)
    local floatingToggleBtn = Instance.new("TextButton")
    floatingToggleBtn.Name = "VorexFloatingToggle"
    floatingToggleBtn.Size = UDim2.new(0, 95, 0, 30)
    floatingToggleBtn.Position = UDim2.new(0, 15, 0.5, -15)
    floatingToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    floatingToggleBtn.TextColor3 = Color3.fromRGB(80, 255, 120)
    floatingToggleBtn.Text = "⚡ VOREX"
    floatingToggleBtn.TextSize = 13
    floatingToggleBtn.Font = Enum.Font.SourceSansBold
    floatingToggleBtn.Active = true
    floatingToggleBtn.Draggable = true
    floatingToggleBtn.Parent = screenGui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(0, 6)
    floatCorner.Parent = floatingToggleBtn

    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.fromRGB(80, 255, 120)
    floatStroke.Thickness = 1.2
    floatStroke.Parent = floatingToggleBtn

    floatingToggleBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame

    -- Başlık
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "VOREX HACK v" .. CURRENT_VERSION .. " | FAKE AN EGG EDITION (Anti-Cheat Bypass) [INS - Aç/Kapat]"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleLabel

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
    
    local cBtnCorner = Instance.new("UICorner")
    cBtnCorner.CornerRadius = UDim.new(0, 4)
    cBtnCorner.Parent = toggleConsoleBtn

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
    
    local tBtnCorner = Instance.new("UICorner")
    tBtnCorner.CornerRadius = UDim.new(0, 4)
    tBtnCorner.Parent = toggleTargetBtn

    -- 1. SOL PANEL (Kontroller)
    local leftContainer = Instance.new("Frame")
    leftContainer.Size = UDim2.new(0, 250, 1, -45)
    leftContainer.Position = UDim2.new(0, 10, 0, 40)
    leftContainer.BackgroundTransparency = 1
    leftContainer.Parent = mainFrame

    local function applyCorner(obj)
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(0, 6)
        cr.Parent = obj
    end

    local speedToggleButton = Instance.new("TextButton")
    speedToggleButton.Size = UDim2.new(1, 0, 0, 28)
    speedToggleButton.Position = UDim2.new(0, 0, 0, 0)
    speedToggleButton.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
    speedToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggleButton.Text = isSpeedEnabled and ("Speed Fly ("..currentSpeed.."): ON") or ("Speed Fly ("..currentSpeed.."): OFF")
    speedToggleButton.TextSize = 12
    speedToggleButton.Font = Enum.Font.SourceSansBold
    speedToggleButton.Parent = leftContainer
    applyCorner(speedToggleButton)

    local killAuraToggleButton = Instance.new("TextButton")
    killAuraToggleButton.Size = UDim2.new(1, 0, 0, 28)
    killAuraToggleButton.Position = UDim2.new(0, 0, 0, 32)
    killAuraToggleButton.BackgroundColor3 = isKillAuraEnabled and Color3.fromRGB(150, 60, 40) or Color3.fromRGB(50, 50, 50)
    killAuraToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraToggleButton.Text = isKillAuraEnabled and "Smart KillAura (15 Stud): ON" or "Smart KillAura (15 Stud): OFF"
    killAuraToggleButton.TextSize = 11
    killAuraToggleButton.Font = Enum.Font.SourceSansBold
    killAuraToggleButton.Parent = leftContainer
    applyCorner(killAuraToggleButton)

    local espToggleButton = Instance.new("TextButton")
    espToggleButton.Size = UDim2.new(1, 0, 0, 28)
    espToggleButton.Position = UDim2.new(0, 0, 0, 64)
    espToggleButton.BackgroundColor3 = isEspEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
    espToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espToggleButton.Text = isEspEnabled and "ESP (Sadece Oyuncular): ON" or "ESP (Sadece Oyuncular): OFF"
    espToggleButton.TextSize = 11
    espToggleButton.Font = Enum.Font.SourceSansBold
    espToggleButton.Parent = leftContainer
    applyCorner(espToggleButton)

    local confirmEggBtn = Instance.new("TextButton")
    confirmEggBtn.Size = UDim2.new(1, 0, 0, 28)
    confirmEggBtn.Position = UDim2.new(0, 0, 0, 96)
    confirmEggBtn.BackgroundColor3 = isHumanEggConfirmEnabled and Color3.fromRGB(40, 110, 80) or Color3.fromRGB(90, 40, 40)
    confirmEggBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmEggBtn.Text = isHumanEggConfirmEnabled and "İnsan Egg Koruması: ON" or "İnsan Egg Koruması: OFF"
    confirmEggBtn.TextSize = 11
    confirmEggBtn.Font = Enum.Font.SourceSansBold
    confirmEggBtn.Parent = leftContainer
    applyCorner(confirmEggBtn)

    local autoPickBtn = Instance.new("TextButton")
    autoPickBtn.Size = UDim2.new(1, 0, 0, 28)
    autoPickBtn.Position = UDim2.new(0, 0, 0, 128)
    autoPickBtn.BackgroundColor3 = isAutoPickEnabled and Color3.fromRGB(160, 100, 30) or Color3.fromRGB(50, 50, 50)
    autoPickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoPickBtn.Text = isAutoPickEnabled and "Oto Yumurta Al: ON" or "Oto Yumurta Al: OFF"
    autoPickBtn.TextSize = 11
    autoPickBtn.Font = Enum.Font.SourceSansBold
    autoPickBtn.Parent = leftContainer
    applyCorner(autoPickBtn)

    local speedTextBox = Instance.new("TextBox")
    speedTextBox.Size = UDim2.new(1, 0, 0, 28)
    speedTextBox.Position = UDim2.new(0, 0, 0, 160)
    speedTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    speedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedTextBox.PlaceholderText = "Hız Değeri (Max 75)"
    speedTextBox.Text = tostring(currentSpeed)
    speedTextBox.TextSize = 12
    speedTextBox.Font = Enum.Font.SourceSans
    speedTextBox.Parent = leftContainer
    applyCorner(speedTextBox)

    local setPosBtn = Instance.new("TextButton")
    setPosBtn.Size = UDim2.new(0.6, 0, 0, 28)
    setPosBtn.Position = UDim2.new(0, 0, 0, 192)
    setPosBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
    setPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setPosBtn.Text = "Konum Al: OK"
    setPosBtn.TextSize = 11
    setPosBtn.Font = Enum.Font.SourceSansBold
    setPosBtn.Parent = leftContainer
    applyCorner(setPosBtn)

    local setKeyBtn = Instance.new("TextButton")
    setKeyBtn.Size = UDim2.new(0.37, 0, 0, 28)
    setKeyBtn.Position = UDim2.new(0.63, 0, 0, 192)
    setKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    setKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setKeyBtn.Text = "Tuş: " .. selectedKey.Name
    setKeyBtn.TextSize = 11
    setKeyBtn.Font = Enum.Font.SourceSansBold
    setKeyBtn.Parent = leftContainer
    applyCorner(setKeyBtn)

    local invisibleToggleButton = Instance.new("TextButton")
    invisibleToggleButton.Size = UDim2.new(1, 0, 0, 28)
    invisibleToggleButton.Position = UDim2.new(0, 0, 0, 224)
    invisibleToggleButton.BackgroundColor3 = isInvisibleEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
    invisibleToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    invisibleToggleButton.Text = isInvisibleEnabled and "Görünmezlik: ON" or "Görünmezlik: OFF"
    invisibleToggleButton.TextSize = 11
    invisibleToggleButton.Font = Enum.Font.SourceSansBold
    invisibleToggleButton.Parent = leftContainer
    applyCorner(invisibleToggleButton)

    local antiCheatStatus = Instance.new("TextLabel")
    antiCheatStatus.Size = UDim2.new(1, 0, 0, 24)
    antiCheatStatus.Position = UDim2.new(0, 0, 0, 256)
    antiCheatStatus.BackgroundColor3 = Color3.fromRGB(25, 45, 30)
    antiCheatStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
    antiCheatStatus.Text = "🛡️ Anti-Cheat Bypass: AKTİF"
    antiCheatStatus.TextSize = 11
    antiCheatStatus.Font = Enum.Font.SourceSansBold
    antiCheatStatus.Parent = leftContainer
    applyCorner(antiCheatStatus)

    local unloadButton = Instance.new("TextButton")
    unloadButton.Size = UDim2.new(1, 0, 0, 28)
    unloadButton.Position = UDim2.new(0, 0, 0, 284)
    unloadButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    unloadButton.Text = "Unload Hub"
    unloadButton.TextSize = 12
    unloadButton.Font = Enum.Font.SourceSansBold
    unloadButton.Parent = leftContainer
    applyCorner(unloadButton)

    -- 2. ORTA PANEL (Oyuncu Listesi)
    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(0, 260, 1, -45)
    targetFrame.Position = UDim2.new(0, 265, 0, 40)
    targetFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    targetFrame.BorderSizePixel = 0
    targetFrame.Parent = mainFrame
    applyCorner(targetFrame)

    local targetTitle = Instance.new("TextLabel")
    targetTitle.Size = UDim2.new(1, 0, 0, 25)
    targetTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    targetTitle.Text = "Oyuncu Hedefleri"
    targetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetTitle.TextSize = 12
    targetTitle.Font = Enum.Font.SourceSansBold
    targetTitle.Parent = targetFrame
    applyCorner(targetTitle)

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
    applyCorner(consoleHolder)

    local consoleLayout = Instance.new("UIListLayout")
    consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    consoleLayout.Padding = UDim.new(0, 2)
    consoleLayout.Parent = consoleHolder

    -- LogToConsole zaten tanimlandi, consoleHolder baglandi
    

    LogToConsole("-- [VOREX HACK v" .. CURRENT_VERSION .. " | GUI FIX Aktif] --")

    -- Güncelleme Kontrolü (https://vorex-hack.vercel.app/)
    local function CheckForUpdates()
        task.spawn(function()
            pcall(function()
                local fetcher = (typeof(getgenv) == "function" and getgenv().request)
                    or (syn and syn.request)
                    or (http and http.request)
                    or http_request
                    or request

                local responseText = nil
                if fetcher then
                    local res = fetcher({Url = "https://vorex-hack.vercel.app/createaneggversion.json", Method = "GET"})
                    if res and res.Body then
                        responseText = res.Body
                    else
                        local fallback = fetcher({Url = "https://vorex-hack.vercel.app/", Method = "GET"})
                        if fallback and fallback.Body then
                            responseText = fallback.Body
                        end
                    end
                elseif game.HttpGet then
                    pcall(function()
                        responseText = game:HttpGet("https://vorex-hack.vercel.app/createaneggversion.json")
                    end)
                    if not responseText then
                        pcall(function()
                            responseText = game:HttpGet("https://vorex-hack.vercel.app/")
                        end)
                    end
                end

                -- Sürüm karşılaştırma fonksiyonu (GitHub sürümü daha yüksekse güncelle)
                local function isVersionNewer(remoteVer, currentVer)
                    local function parseVer(v)
                        local parts = {}
                        for num in tostring(v):gmatch("%d+") do
                            table.insert(parts, tonumber(num) or 0)
                        end
                        while #parts < 3 do table.insert(parts, 0) end
                        return parts
                    end
                    local r = parseVer(remoteVer)
                    local c = parseVer(currentVer)
                    for i = 1, math.max(#r, #c) do
                        local rNum = r[i] or 0
                        local cNum = c[i] or 0
                        if rNum > cNum then return true end
                        if rNum < cNum then return false end
                    end
                    return false
                end

                if responseText and #responseText > 0 then
                    local decoded = nil
                    pcall(function() decoded = HttpService:JSONDecode(responseText) end)
                    local serverVer = decoded and (decoded.Version or decoded.version)
                    if serverVer then
                        if isVersionNewer(serverVer, CURRENT_VERSION) then
                            LogToConsole(string.format("[Güncelleme] GitHub'da yeni sürüm bulundu: v%s (Mevcut: v%s)! Güncelleniyor...", serverVer, CURRENT_VERSION))
                            LogToConsole("[Güncelleme] Yeni betik indiriliyor: " .. SCRIPT_SOURCE_URL)
                            local success, newScript = pcall(function()
                                return (game.HttpGet and game:HttpGet(SCRIPT_SOURCE_URL))
                            end)
                            if success and newScript and #newScript > 50 then
                                LogToConsole("[Güncelleme] Yeni sürüm başarıyla yüklendi!")
                                task.spawn(function()
                                    loadstring(newScript)()
                                end)
                                return
                            end
                        else
                            LogToConsole(string.format("[Güncelleme] Sürümünüz güncel (Mevcut: v%s | GitHub: v%s). Güncelleme gerekmiyor.", CURRENT_VERSION, serverVer))
                        end
                    else
                        LogToConsole("[Güncelleme] Sunucu bağlantısı sağlandı: https://vorex-hack.vercel.app/")
                    end
                else
                    LogToConsole("[Güncelleme] vorex-hack.vercel.app kontrol edildi.")
                end
            end)
        end)
    end

    CheckForUpdates()
    task.spawn(function()
        while true do
            task.wait(300)
            CheckForUpdates()
        end
    end)


    -- Toggle Eventleri
    killAuraToggleButton.MouseButton1Click:Connect(function()
        isKillAuraEnabled = not isKillAuraEnabled
        killAuraToggleButton.BackgroundColor3 = isKillAuraEnabled and Color3.fromRGB(150, 60, 40) or Color3.fromRGB(50, 50, 50)
        killAuraToggleButton.Text = isKillAuraEnabled and "Smart KillAura (15 Stud): ON" or "Smart KillAura (15 Stud): OFF"
        SyncState()
        if isKillAuraEnabled then
            LogToConsole("[KillAura] Aktif Edildi.")
            task.spawn(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                task.wait(0.15)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            end)
        else
            LogToConsole("[KillAura] Kapatıldı.")
        end
    end)

    autoPickBtn.MouseButton1Click:Connect(function()
        isAutoPickEnabled = not isAutoPickEnabled
        autoPickBtn.Text = isAutoPickEnabled and "Oto Yumurta Al: ON" or "Oto Yumurta Al: OFF"
        autoPickBtn.BackgroundColor3 = isAutoPickEnabled and Color3.fromRGB(160, 100, 30) or Color3.fromRGB(50, 50, 50)
        SyncState()
        LogToConsole("[AutoPick] Otomatik Yumurta Toplama: " .. (isAutoPickEnabled and "AÇIK" or "KAPALI"))
    end)

    confirmEggBtn.MouseButton1Click:Connect(function()
        isHumanEggConfirmEnabled = not isHumanEggConfirmEnabled
        confirmEggBtn.Text = isHumanEggConfirmEnabled and "İnsan Egg Onayı: ON" or "İnsan Egg Onayı: OFF"
        confirmEggBtn.BackgroundColor3 = isHumanEggConfirmEnabled and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(80, 40, 40)
        SyncState()
        LogToConsole("[Ayar] İnsan Egg Onayı: " .. tostring(isHumanEggConfirmEnabled))
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
        espToggleButton.Text = isEspEnabled and "ESP (Sadece Oyuncular): ON" or "ESP (Sadece Oyuncular): OFF"
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
            for _, data in pairs(eggHighlights) do
                if data then
                    pcall(function()
                        if data.Highlight then data.Highlight:Destroy() end
                        if data.Billboard then data.Billboard:Destroy() end
                    end)
                end
            end
            eggHighlights = {}
        end
    end)

    invisibleToggleButton.MouseButton1Click:Connect(function()
        isInvisibleEnabled = not isInvisibleEnabled
        invisibleToggleButton.BackgroundColor3 = isInvisibleEnabled and Color3.fromRGB(40, 120, 50) or Color3.fromRGB(50, 50, 50)
        invisibleToggleButton.Text = isInvisibleEnabled and "Görünmezlik (Transp 1): ON" or "Görünmezlik: OFF"
        SyncState()
        setInvisibility(isInvisibleEnabled)
        LogToConsole("[Görünmezlik] " .. (isInvisibleEnabled and "Karakter şeffaflığı 1 yapıldı (Görünmez)." or "Görünürlük normale döndü (Transp 0)."))
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
        toggleConsoleBtn.Text = isConsoleVisible and "Console: AÇIK" or "Console: KAPALI"
        toggleConsoleBtn.BackgroundColor3 = isConsoleVisible and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(100, 50, 50)
        UpdateLayoutSizes()
    end)

    toggleTargetBtn.MouseButton1Click:Connect(function()
        isTargetPanelVisible = not isTargetPanelVisible
        toggleTargetBtn.Text = isTargetPanelVisible and "Hedefler: AÇIK" or "Hedefler: KAPALI"
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
                            applyCorner(row)

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

                            local goBtn = Instance.new("TextButton")
                            goBtn.Size = UDim2.new(0.22, 0, 0.8, 0)
                            goBtn.Position = UDim2.new(0.51, 0, 0.1, 0)
                            goBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
                            goBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            goBtn.Text = "Git"
                            goBtn.TextSize = 10
                            goBtn.Font = Enum.Font.SourceSansBold
                            goBtn.Parent = row
                            applyCorner(goBtn)
                            
                            goBtn.MouseButton1Click:Connect(function()
                                local myChar = localPlayer.Character
                                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                                    -- Saldırı kilitlenmesini iptal et (Sadece barışçıl ışınlanma)
                                    isTrackingPlayer = false
                                    selectedTargetCharacter = nil
                                    -- KillAura'nın anında saldırmasını önlemek için 3 saniye barış süresi koy
                                    lastAuraAttack = tick() + 3
                                    
                                    -- Oyuncunun tam üstüne değil, 6 stud arkasına/yanına güvenli ışınlan
                                    myChar.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 1, 6)
                                    LogToConsole(string.format("[Git] %s yanına ışınlanıldı (Saldırı kapalı).", player.DisplayName))
                                end
                            end)

                            local attackBtn = Instance.new("TextButton")
                            attackBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
                            attackBtn.Position = UDim2.new(0.74, 0, 0.1, 0)
                            local isThisLocked = (isTrackingPlayer and selectedTargetCharacter == char)
                            attackBtn.BackgroundColor3 = isThisLocked and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(140, 50, 150)
                            attackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            attackBtn.Text = isThisLocked and "İptal" or "Saldır"
                            attackBtn.TextSize = 10
                            attackBtn.Font = Enum.Font.SourceSansBold
                            attackBtn.Parent = row
                            applyCorner(attackBtn)

                            attackBtn.MouseButton1Click:Connect(function()
                                if isTrackingPlayer and selectedTargetCharacter == char then
                                    isTrackingPlayer = false
                                    selectedTargetCharacter = nil
                                    LogToConsole("[TargetLock] Saldırı emri iptal edildi.")
                                    attackBtn.BackgroundColor3 = Color3.fromRGB(140, 50, 150)
                                    attackBtn.Text = "Saldır"
                                else
                                    selectedTargetCharacter = char
                                    selectedTargetName = player.DisplayName
                                    isTrackingPlayer = true
                                    LogToConsole(string.format("[TargetLock] [%s] kilitlenildi!", selectedTargetName))
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
        pcall(function() setInvisibility(false) end)
        pcall(RestoreOptimization)
        pcall(function()
            local char = localPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
                hum.WalkSpeed = 16
            end
        end)
        for _, conn in ipairs(activeConnections) do
            if conn and typeof(conn.Disconnect) == "function" then
                pcall(function() conn:Disconnect() end)
            end
        end
        if screenGui then
            pcall(function() screenGui:Destroy() end)
        end
        _env._vorexhack_LoadedData = nil
        print("[VorexHack]: Hub kaldırıldı. Tüm grafikler, dokular ve ayarlar başarıyla geri yüklendi.")
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
            setPosBtn.Text = "Konum Alındı!"
            LogToConsole("[AutoWalk] Hedef konum kaydedildi.")
        end
    end)

    setKeyBtn.MouseButton1Click:Connect(function()
        isListeningForKey = true
        setKeyBtn.Text = "Tuşa Bas..."
    end)

    local inputConn = UserInputService.InputBegan:Connect(function(input, gp)
        if isListeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
            selectedKey = input.KeyCode
            setKeyBtn.Text = "Tuş: " .. input.KeyCode.Name
            isListeningForKey = false
            SyncState()
            return
        end
    
        if input.KeyCode == selectedKey and not gp then
            isAutoWalking = not isAutoWalking
            LogToConsole(string.format("[Dönme/AutoWalk] %s (Tuş: %s)", isAutoWalking and "Aktif" or "Kapatıldı", selectedKey.Name))
        end
    end)
    table.insert(activeConnections, inputConn)

    -- Ana Döngü (RenderStepped)
    local serverAngle = 0
    local radius = 12.5
    local syncTimer = 0
    local espTimer = 0
    local charAddedConn = localPlayer.CharacterAdded:Connect(function(newChar)
        if isInvisibleEnabled then
            task.wait(0.5)
            setInvisibility(true)
        end
    end)
    table.insert(activeConnections, charAddedConn)

    -- Gorunmezlik: Heartbeat ile her tick Transparency enforce (Sunucuya replicate olur)
    -- Invis enforce: Scale sifir kalsin (game reset ederse geri sifirla)
    local _invisEnforceTimer = 0
    local invisHbConn = RunService.Heartbeat:Connect(function(dt)
        if not isInvisibleEnabled then return end
        _invisEnforceTimer = _invisEnforceTimer + dt
        if _invisEnforceTimer < 0.5 then return end  -- Her 0.5 saniyede bir yeniden uygula
        _invisEnforceTimer = 0
        local c = localPlayer.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            local scales = {"BodyDepthScale","BodyHeightScale","BodyWidthScale","HeadScale"}
            for _, sn in ipairs(scales) do
                local sv = hum:FindFirstChild(sn)
                if sv and sv.Value > 0.02 then
                    sv.Value = 0.01  -- Oyun resetlerse tekrar sifirla
                end
            end
        end
        local SKY = Color3.fromRGB(178, 212, 238)
        for _, v in ipairs(c:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    if v.Color ~= SKY then v.Color = SKY end
                    if v.Transparency < 0.97 then v.Transparency = 0.98 end
                end
            end)
        end
    end)
    table.insert(activeConnections, invisHbConn)

    local heartbeatConn = RunService.RenderStepped:Connect(function(dt)
        local char = localPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera

        if humanoid and rootPart then
            -- P Tusuna Basinca Donme & Hedef Konuma Donme (AutoWalk/Spin)
            if isAutoWalking then
                if targetPosition then
                    local currentPos = rootPart.Position
                    local flatTarget = Vector3.new(targetPosition.X, currentPos.Y, targetPosition.Z)
                    local dist = (flatTarget - currentPos).Magnitude
                    if dist > 4 then
                        SmartWalkWithObstacleAvoidance(flatTarget, math.max(currentSpeed, 35))
                    else
                        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(16), 0)
                    end
                else
                    rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(16), 0)
                end
            end
            if isInvisibleEnabled and char then
                for _, item in ipairs(char:GetDescendants()) do
                    if item:IsA("BasePart") then
                        if item.Name ~= "HumanoidRootPart" and item.Transparency ~= 1 then
                            item.Transparency = 1
                        end
                        -- LocalTransparencyModifier kaldirildi: Transparency = 1 server'a replicate olur (herkes gorur)
                    elseif (item:IsA("Decal") or item:IsA("Texture")) and item.Transparency ~= 1 then
                        item.Transparency = 1
                    end
                end
            end
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

            -- Predictive Player Tracking & Target Lock
            if isTrackingPlayer and selectedTargetCharacter and selectedTargetCharacter.Parent and char and humanoid then
                pcall(function()
                    local targetRoot = selectedTargetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = selectedTargetCharacter:FindFirstChildOfClass("Humanoid")
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and myRoot then
                        local predictedPos = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * 0.1)
                        local currentPos = myRoot.Position
                        local flatTarget = Vector3.new(predictedPos.X, currentPos.Y, predictedPos.Z)
                        local distance = (flatTarget - currentPos).Magnitude

                        if distance > 3.5 then
                            isSpeedEnabled = false
                            SmartWalkWithObstacleAvoidance(flatTarget, 40)
                        else
                            rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(predictedPos + Vector3.new(0, 0.2, 0)), 0.3)
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
                        LogToConsole("[TargetLock] Hedef ortadan kayboldu.")
                    end
                end)
            end

            espTimer = espTimer + dt
            if espTimer >= 0.1 then
                espTimer = 0
                if isEspEnabled then
                    pcall(updatePlayerEsp)
                end
            end
            pcall(autoPickNearbyEggs)
        end
    end)
    table.insert(activeConnections, heartbeatConn)

    unloadButton.MouseButton1Click:Connect(UnloadHub)
    _env._vorexhack_LoadedData = { Cleanup = UnloadHub }
end

local success, err = pcall(MainScript)
if not success then
    warn("[VOREX HACK FATAL ERROR]: " .. tostring(err))
    -- Acil durum ekrana hata bildirme
    pcall(function()
        local fallbackGui = Instance.new("ScreenGui")
        fallbackGui.Name = "VorexErrorGui"
        fallbackGui.ResetOnSpawn = false
        local parent = (typeof(gethui) == "function" and gethui()) or localPlayer:FindFirstChildOfClass("PlayerGui")
        if parent then fallbackGui.Parent = parent end
        local errLabel = Instance.new("TextLabel")
        errLabel.Size = UDim2.new(0, 400, 0, 80)
        errLabel.Position = UDim2.new(0.5, -200, 0, 50)
        errLabel.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
        errLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        errLabel.Text = "[VOREX HACK HATASI]:\n" .. tostring(err)
        errLabel.TextSize = 12
        errLabel.Parent = fallbackGui
    end)
end