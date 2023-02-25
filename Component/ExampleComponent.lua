local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NComponent = require(ReplicatedStorage.Component.Component)

local Example = NComponent:Extend()

function Example:__new()
    print(NComponent.In)
end

return Example