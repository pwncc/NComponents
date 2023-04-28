local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NComponent = require(ReplicatedStorage.Component.Component)

local TestTool = NComponent:Extend()

TestTool:SetClassName("TestTool")
TestTool.DormancyWhiteList = {workspace}

TestTool:SetHeader("Options")
TestTool.Velocity = 5

function TestTool:__new()
    local Tool = self.InstanceObject :: Tool

    Tool.Activated:Connect(function()
        local part = Instance.new("Part", workspace)
        part.Size = Vector3.new(0.2, 0.2, 0.2)
        part.Shape = Enum.PartType.Ball
        part.CFrame = Tool.Handle.CFrame
        part.AssemblyLinearVelocity = Tool.Handle.CFrame.LookVector * self.Velocity
    end)
end

return TestTool