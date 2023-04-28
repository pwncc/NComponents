local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DoubleFlare = require(ReplicatedStorage.Common.FlareEffect):Extend()

DoubleFlare:SetClassName("DoubleFlare")

DoubleFlare.test = "hi"

return DoubleFlare