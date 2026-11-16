--// Servisler

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera



--// Ayarlar & Durumlar (Toggle Değişkenleri)

local Settings = {

    MenuKey = Enum.KeyCode.Insert,       -- Menüyü açıp kapatma (INS)

    ESPKey = Enum.KeyCode.P,            -- ESP'yi açıp kapatma (P)

    FlyKey = Enum.KeyCode.F,            -- Süzülme/Uçuş modunu açıp kapatma (F)

    AutoAimButton = Enum.UserInputType.MouseButton2, -- Sağ Tık (Auto-Aim)

   

    MenuOpened = true,                  -- Menü durumu

    ESPEnabled = true,                  -- ESP durumu

    FlyEnabled = false,                 -- Uçuş/Süzülme durumu

    AimPart = "Head",                   -- Hedef bölge (Kafa)

    FOV = 150,                          -- Görüş açısı yarıçapı

    FlySpeed = 50                       -- Uçuş hızı

}



--// Uçuş (Fly) İçin Fizik Değişkenleri

local bodyVelocity = nil

local bodyGyro = nil



local function ToggleFly(state)

    local character = LocalPlayer.Character

    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = character.HumanoidRootPart



    if state then

        bodyVelocity = Instance.new("BodyVelocity")

        bodyVelocity.Velocity = Vector3.new(0, 0, 0)

        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

        bodyVelocity.Parent = rootPart



        bodyGyro = Instance.new("BodyGyro")

        bodyGyro.CFrame = rootPart.CFrame

        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

        bodyGyro.Parent = rootPart

       

        print("Süzülme / Uçuş Modu: Aktif")

    else

        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end

        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end

        print("Süzülme / Uçuş Modu: Devre Dışı")

    end

end



--// ESP Highlight Yönetimi

local function SetupESP(player)

    if player == LocalPlayer then return end

   

    local function applyHighlight(character)

        if not character:FindFirstChild("ESPHighlight") then

            local highlight = Instance.new("Highlight")

            highlight.Name = "ESPHighlight"

            highlight.Adornee = character

            highlight.FillColor = Color3.fromRGB(255, 0, 0)

            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

            highlight.FillTransparency = 0.5

            highlight.Parent = character

            highlight.Enabled = Settings.ESPEnabled

        end

    end

   

    player.CharacterAdded:Connect(applyHighlight)

    if player.Character then

        applyHighlight(player.Character)

    end

end



for _, player in ipairs(Players:GetPlayers()) do

    SetupESP(player)

end

Players.PlayerAdded:Connect(SetupESP)



--// Tuş Atamaları ve Kontroller (InputBegan)

UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if input.KeyCode == Settings.MenuKey then

        Settings.MenuOpened = not Settings.MenuOpened

        print("Menü Durumu:", Settings.MenuOpened and "Açık" or "Kapalı")

       

    elseif input.KeyCode == Settings.ESPKey then

        Settings.ESPEnabled = not Settings.ESPEnabled

        print("ESP Durumu:", Settings.ESPEnabled and "Aktif" or "Devre Dışı")

       

        for _, player in ipairs(Players:GetPlayers()) do

            if player.Character and player.Character:FindFirstChild("ESPHighlight") then

                player.Character.ESPHighlight.Enabled = Settings.ESPEnabled

            end

        end

       

    elseif input.KeyCode == Settings.FlyKey then

        Settings.FlyEnabled = not Settings.FlyEnabled

        ToggleFly(Settings.FlyEnabled)

    end

end)



--// Ekran Merkezine En Yakın Oyuncuyu Bulma

local function GetClosestPlayer()

    local closestPlayer = nil

    local shortestDistance = Settings.FOV



    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.AimPart) then

            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 then

                local targetPart = player.Character[Settings.AimPart]

                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

               

                if onScreen then

                    local mouseLocation = UserInputService:GetMouseLocation()

                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude

                   

                    if distance < shortestDistance then

                        shortestDistance = distance

                        closestPlayer = player

                    end

                end

            end

        end

    end

   

    return closestPlayer

end



--// Ana Döngü (RenderStepped: Auto-Aim ve Fly Güncellemeleri)

RunService.RenderStepped:Connect(function()

    -- 1. Sağ Tık Auto-Aim Mantığı

    if UserInputService:IsMouseButtonPressed(Settings.AutoAimButton) then

        local target = GetClosestPlayer()

        if target and target.Character and target.Character:FindFirstChild(Settings.AimPart) then

            local targetPos = target.Character[Settings.AimPart].Position

            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)

        end

    end



    -- 2. F Tuşu Uçuş/Süzülme Hareket Mantığı

    if Settings.FlyEnabled then

        local character = LocalPlayer.Character

        if character and character:FindFirstChild("HumanoidRootPart") and bodyVelocity and bodyGyro then

            local rootPart = character.HumanoidRootPart

            local moveDirection = Vector3.new(0, 0, 0)

           

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then

                moveDirection = moveDirection + Camera.CFrame.LookVector

            end

            if UserInputService:IsKeyDown(Enum.KeyCode.S) then

                moveDirection = moveDirection - Camera.CFrame.LookVector

            end

            if UserInputService:IsKeyDown(Enum.KeyCode.A) then

                moveDirection = moveDirection - Camera.CFrame.RightVector

            end

            if UserInputService:IsKeyDown(Enum.KeyCode.D) then

                moveDirection = moveDirection + Camera.CFrame.RightVector

            end

           

            bodyVelocity.Velocity = moveDirection * Settings.FlySpeed

            bodyGyro.CFrame = Camera.CFrame

        end

    end

end)
