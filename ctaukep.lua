-- ULTRA SNAP AIM | CTAUKEP230 | С ТИМ ЧЕКОМ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ===== SETTINGS =====
local AIM = false
local FOV = 140
local AIM_PART = "Head" -- "Head" или "Body"
local PREDICT = 0.02   -- микро-предикт (чем меньше, тем резче)

-- ===== DRAWING CIRCLE =====
local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.NumSides = 100
circle.Color = Color3.fromRGB(0,255,0)
circle.Filled = false
circle.Visible = true
circle.Radius = FOV

-- ===== GUI CLEAN =====
pcall(function()
    LP.PlayerGui:FindFirstChild("CTAUKEP230_GUI"):Destroy()
end)

local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "CTAUKEP230_GUI"
gui.ResetOnSpawn = false

-- ===== TOGGLE BUTTON =====
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.fromOffset(110,30)
toggle.Position = UDim2.fromScale(0.02,0.5)
toggle.Text = "CTAUKEP230"
toggle.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Active = true
toggle.Draggable = true
Instance.new("UICorner", toggle)

-- ===== MAIN FRAME =====
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220,165)
frame.Position = UDim2.fromScale(0.02,0.6)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Visible = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,22)
title.Text = "ULTRA SNAP AIM"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

local function mkBtn(text,y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,26)
    b.Position = UDim2.fromOffset(10,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    return b
end

local aimBtn = mkBtn("AIM: OFF",26)
local partBtn = mkBtn("TARGET: HEAD",56)

-- ===== SLIDER =====
local sliderBG = Instance.new("Frame", frame)
sliderBG.Position = UDim2.fromOffset(10,96)
sliderBG.Size = UDim2.new(1,-20,0,8)
sliderBG.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", sliderBG)

local slider = Instance.new("Frame", sliderBG)
slider.Size = UDim2.fromScale(0.5,1)
slider.BackgroundColor3 = Color3.fromRGB(0,200,0)
Instance.new("UICorner", slider)

local fovLabel = Instance.new("TextLabel", frame)
fovLabel.Position = UDim2.fromOffset(10,108)
fovLabel.Size = UDim2.new(1,-20,0,20)
fovLabel.Text = "FOV: "..FOV
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.BackgroundTransparency = 1
fovLabel.TextScaled = true

-- ===== UI LOGIC =====
toggle.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

aimBtn.MouseButton1Click:Connect(function()
    AIM = not AIM
    aimBtn.Text = "AIM: "..(AIM and "ON" or "OFF")
end)

partBtn.MouseButton1Click:Connect(function()
    if AIM_PART == "Head" then
        AIM_PART = "Body"
        partBtn.Text = "TARGET: BODY"
    else
        AIM_PART = "Head"
        partBtn.Text = "TARGET: HEAD"
    end
end)

-- ===== SLIDER FIX =====
local dragging = false
sliderBG.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local x = math.clamp((i.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        slider.Size = UDim2.fromScale(x,1)
        FOV = math.floor(60 + 220*x)
        circle.Radius = FOV
        fovLabel.Text = "FOV: "..FOV
    end
end)

-- ===== VISIBILITY =====
local function visible(part)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LP.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local r = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return r and r.Instance:IsDescendantOf(part.Parent)
end

-- ===== TEAM CHECK =====
local function isTeamMate(player)
    -- Проверяем тиму по основным методам
    if LP.Team and player.Team and LP.Team == player.Team then
        return true
    end
    
    -- Проверка по Leaderstats (Kills/Deaths и т.д.)
    local lpStats = LP:FindFirstChild("leaderstats")
    local pStats = player:FindFirstChild("leaderstats")
    if lpStats and pStats then
        local lpKills = lpStats:FindFirstChild("Kills") or lpStats:FindFirstChild("K")
        local pKills = pStats:FindFirstChild("Kills") or pStats:FindFirstChild("K")
        -- Если у обоих есть kills и они в одной команде по цветам или другим признакам
    end
    
    -- Проверка по цветам команды (BrickColor)
    if LP.Character and player.Character then
        local lpTeamColor = LP.Character:FindFirstChild("TeamColor") or LP.Character:FindFirstChild("Head")
        local pTeamColor = player.Character:FindFirstChild("TeamColor") or player.Character:FindFirstChild("Head")
        if lpTeamColor and pTeamColor and lpTeamColor.BrickColor == pTeamColor.BrickColor then
            return true
        end
    end
    
    return false
end

-- ===== TARGET (С ТИМ ЧЕКОМ) =====
local function getTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, dist = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
        -- ✅ ТИМ ЧЕК - НЕ ЦЕЛИТСЯ В СВОИХ
        if p ~= LP and not isTeamMate(p) and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            local head = p.Character:FindFirstChild("Head")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local part = (AIM_PART=="Head" and head) or hrp
            if hum and part and hum.Health > 0 and visible(part) then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                    if d < FOV and d < dist then
                        dist = d
                        best = part
                    end
                end
            end
        end
    end
    return best
end

-- ===== LOOP (ULTRA SNAP) =====
RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if AIM then
        local t = getTarget()
        if t then
            local vel = t.AssemblyLinearVelocity or Vector3.zero
            local targetPos = t.Position + vel * PREDICT
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

print("[CTAUKEP230] Ultra Snap Aim Loaded | ✅ TEAM CHECK ACTIVE")
