-- haha open source
local me = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager") or game:FindFirstDescendant("VirtualInputManager")
local platform = game:GetService("UserInputService"):GetPlatform()
local pre_sim = rs.PreSimulation
local stepped = rs.RenderStepped
local balls = workspace.Balls
local alive = workspace.Alive
local Parried = false

local function check_alive(plr)
    if alive:FindFirstChild(plr.Name) then 
        return true 
    end
end

local function get_ball()
    for _, Ball in ipairs(workspace.Balls:GetChildren()) do
        if Ball:GetAttribute("realBall") then
            return Ball
        end
    end
end

local function reset_connection()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

local function click_parry_button()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
end

local function auto_gameplay(bool)
    if bool then
        if me.Character.Humanoid ~= nil then
            local me_char = me.Character
            local me_hrp = me_char.HumanoidRootPart
            if check_alive(me) then
                for i, ball in next, balls:GetChildren() do
                    if ball then
                        if me_char and me_hrp then
                            me_hrp.CFrame = CFrame.new(me_hrp.Position, ball.Position)
                            if me_char:FindFirstChild("Highlight") then
                                me_hrp.CFrame = ball.CFrame * CFrame.new(0, 0, (ball.Velocity).Magnitude * -0.5)
                                click_parry_button()
                            end
                        end
                    end
                end
            end
        else
            wait()
        end
    end
end

local function auto_parry(bool)
    if bool then
        if me.Character.Humanoid ~= nil then
            local me_char = me.Character
            local me_hrp = me_char.HumanoidRootPart
            if check_alive(me) then
                for i, ball in next, balls:GetChildren() do
                    if ball then
                        local Speed = ball.zoomies.VectorVelocity.Magnitude
                        local Distance = (me_hrp.Position - ball.Position).Magnitude
                        if me_char and me_hrp then
                            if ball:GetAttribute("target") == me.Name and not Parried and Distance / Speed <= 0.55 then
                                click_parry_button()
                                stepped:Wait()
                                Parried = true
                                Cooldown = tick()
                                if (tick() - Cooldown) >= 1 then
                                    Parried = false
                                end
                            end
                        end
                    end
                end
            end
        else
            wait()
        end
    end
end

workspace.Balls.ChildAdded:Connect(function()
    local Ball = get_ball()
    if not Ball then return end
    reset_connection()
    Connection = Ball:GetAttributeChangedSignal("target"):Connect(function()
        Parried = false
    end)
end)

local l = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/turtle"))()
local w = l:Window("main")

w:Toggle("auto parry", false, function(e) 
    boolean = e
    while pre_sim:Wait() and boolean do
        auto_parry(boolean)
    end
end)

w:Toggle("auto parry + gameplay", false, function(e) 
    boolean = e
    while pre_sim:Wait() and boolean do
        auto_gameplay(boolean)
    end
end)
