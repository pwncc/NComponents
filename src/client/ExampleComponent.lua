local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NComponent = require(ReplicatedStorage.Component.Component)

local Example = NComponent:Extend()

Example:SetClassName("Example")
Example.Dormant = true
Example.Test = "hi"
Example.Vec = Vector3.new(1, 12, 0)

function Example:__new()
    print(self.Test)
end

return Example