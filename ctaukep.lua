-- SNAP CENTER AIM | CTAUKEP230

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ===== SETTINGS =====
local AIM = false
local FOV = 140
local SNAP = true -- резкий аим

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
frame.Size = UDim2.fromOffset(210,135)
frame.Position = UDim2.fromScale(0.02,0.6)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Visible = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,22)
title.Text = "SNAP AIM"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

local aimBtn = Instance.new("TextButton", frame)
aimBtn.Size = UDim2.new(1,-20,0,26)
aimBtn.Position = UDim2.fromOffset(10,26)
aimBtn.Text = "AIM: OFF"
aimBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
aimBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", aimBtn)

-- ===== SLIDER =====
local sliderBG = Instance.new("Frame", frame)
sliderBG.Position = UDim2.fromOffset(10,64)
sliderBG.Size = UDim2.new(1,-20,0,8)
sliderBG.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", sliderBG)

local slider = Instance.new("Frame", sliderBG)
slider.Size = UDim2.fromScale(0.5,1)
slider.BackgroundColor3 = Color3.fromRGB(0,200,0)
Instance.new("UICorner", slider)

local fovLabel = Instance.new("TextLabel", frame)
fovLabel.Position = UDim2.fromOffset(10,75)
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

-- ===== SLIDER FIX =====
local dragging = false

sliderBG.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        local x = math.clamp(
            (i.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X,
            0,1
        )
        slider.Size = UDim2.fromScale(x,1)
        FOV = math.floor(60 + 220*x)
        circle.Radius = FOV
        fovLabel.Text = "FOV: "..FOV
    end
end)

-- ===== VISIBILITY CHECK =====
local function visible(part)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LP.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local r = workspace:Raycast(
        Camera.CFrame.Position,
        part.Position - Camera.CFrame.Position,
        params
    )
    return r and r.Instance:IsDescendantOf(part.Parent)
end

-- ===== TARGET FIND (CENTER FOV) =====
local function getTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, dist = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 and visible(hrp) then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                    if d < FOV and d < dist then
                        dist = d
                        best = hrp
                    end
                end
            end
        end
    end
    return best
end

-- ===== MAIN LOOP (SNAP) =====
RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(
        Camera.ViewportSize.X/2,
        Camera.ViewportSize.Y/2
    )

    if AIM then
        local t = getTarget()
        if t then
            -- мгновенное наведение
            Camera.CFrame = CFrame.new(
                Camera.CFrame.Position,
                t.Position
            )
        end
    end
end)

print("[CTAUKEP230] SNAP Aim Loaded")
