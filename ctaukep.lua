-- UNIVERSAL AIM LOCK | CTAUKEP230
-- Works in most Roblox modes (camera-based)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer

-- ===== GUI =====
pcall(function()
    LP.PlayerGui:FindFirstChild("CTAUKEP230_AIM"):Destroy()
end)

local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "CTAUKEP230_AIM"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(260, 200)
frame.Position = UDim2.fromScale(0.05, 0.35)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local function btn(text,y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,32)
    b.Position = UDim2.fromOffset(10,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,28)
title.Text = "UNIVERSAL AIM | CTAUKEP230"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

local aimBtn = btn("AIM: OFF",40)
local fovBtn = btn("FOV: 120",80)
local hideBtn = btn("HIDE UI",140)

-- ===== SETTINGS =====
local AIM = false
local FOV = 120

-- ===== TARGET FIND =====
local function getClosestTarget()
    local closest, dist = nil, math.huge
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local screenPos, visible = Camera:WorldToViewportPoint(hrp.Position)
                if visible then
                    local mousePos = UIS:GetMouseLocation()
                    local d = (Vector2.new(screenPos.X,screenPos.Y) - mousePos).Magnitude
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

-- ===== BUTTONS =====
aimBtn.MouseButton1Click:Connect(function()
    AIM = not AIM
    aimBtn.Text = "AIM: "..(AIM and "ON" or "OFF")
end)

fovBtn.MouseButton1Click:Connect(function()
    if FOV == 120 then FOV = 200
    elseif FOV == 200 then FOV = 80
    else FOV = 120 end
    fovBtn.Text = "FOV: "..FOV
end)

hideBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ===== AIM LOOP =====
RunService.RenderStepped:Connect(function()
    if not AIM then return end
    local target = getClosestTarget()
    if target then
        Camera.CFrame = CFrame.new(
            Camera.CFrame.Position,
            target.Position
        )
    end
end)

print("[CTAUKEP230] Universal Aim Loaded")
