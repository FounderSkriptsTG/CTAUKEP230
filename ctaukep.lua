-- UNIVERSAL SMART AIM | CTAUKEP230
-- Aim only when enemy is visible + inside FOV circle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer

-- ===== SETTINGS =====
local AIM = false
local FOV = 120

-- ===== DRAWING CIRCLE =====
local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.NumSides = 100
circle.Color = Color3.fromRGB(0,255,0)
circle.Filled = false
circle.Visible = true
circle.Radius = FOV

-- ===== GUI =====
pcall(function()
    LP.PlayerGui:FindFirstChild("CTAUKEP230_AIM"):Destroy()
end)

local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "CTAUKEP230_AIM"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(280, 240)
frame.Position = UDim2.fromScale(0.05, 0.3)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,28)
title.Text = "SMART AIM | CTAUKEP230"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

local function button(txt,y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,32)
    b.Position = UDim2.fromOffset(10,y)
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local aimBtn = button("AIM: OFF",40)
local hideBtn = button("HIDE UI",190)

-- ===== SLIDER =====
local sliderBG = Instance.new("Frame", frame)
sliderBG.Position = UDim2.fromOffset(10,90)
sliderBG.Size = UDim2.new(1,-20,0,10)
sliderBG.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", sliderBG)

local slider = Instance.new("Frame", sliderBG)
slider.Size = UDim2.fromScale(0.5,1)
slider.BackgroundColor3 = Color3.fromRGB(0,200,0)
Instance.new("UICorner", slider)

local fovLabel = Instance.new("TextLabel", frame)
fovLabel.Position = UDim2.fromOffset(10,105)
fovLabel.Size = UDim2.new(1,-20,0,25)
fovLabel.Text = "FOV: "..FOV
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.BackgroundTransparency = 1
fovLabel.TextScaled = true

-- ===== BUTTON LOGIC =====
aimBtn.MouseButton1Click:Connect(function()
    AIM = not AIM
    aimBtn.Text = "AIM: "..(AIM and "ON" or "OFF")
end)

hideBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ===== SLIDER LOGIC =====
local dragging = false

sliderBG.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local mouseX = UIS:GetMouseLocation().X
        local x = math.clamp(
            (mouseX - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X,
            0,1
        )
        slider.Size = UDim2.fromScale(x,1)
        FOV = math.floor(50 + (250 * x))
        circle.Radius = FOV
        fovLabel.Text = "FOV: "..FOV
    end
end)

-- ===== VISIBILITY CHECK =====
local function isVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LP.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, params)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return false
end

-- ===== FIND TARGET =====
local function getTarget()
    local closest, dist = nil, math.huge
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 and isVisible(hrp) then
                local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
                if visible then
                    local mouse = UIS:GetMouseLocation()
                    local d = (Vector2.new(pos.X,pos.Y) - mouse).Magnitude
                    if d < FOV and d < dist then
                        dist = d
                        closest = hrp
                    end
                end
            end
        end
    end
    return closest
end

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    local mouse = UIS:GetMouseLocation()
    circle.Position = Vector2.new(mouse.X, mouse.Y)

    if AIM then
        local target = getTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, target.Position),
                0.15
            )
        end
    end
end)

print("[CTAUKEP230] Smart Aim Loaded")
