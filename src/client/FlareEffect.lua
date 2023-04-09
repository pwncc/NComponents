local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NComponent = require(ReplicatedStorage.Component.Component)

local FlareEffect = NComponent:Extend()

FlareEffect:SetClassName("FlareEffect")

FlareEffect:SetHeader("Range values")
FlareEffect.Max = 180
FlareEffect.Min = 90

FlareEffect:SetHeader("Do nothing values")
FlareEffect.DoNothing = 1

FlareEffect.EffectBB = game.ReplicatedStorage.BillboardGui
FlareEffect.PartToShine = script.Parent

FlareEffect:HideField("EffectBB")
FlareEffect:HideField("PartToShine")

print(FlareEffect._headers)

function Angle(vectorA, vectorB)
	return math.acos(vectorA:Dot(vectorB))
end

function FlareEffect:__new()
    self.Billboard = self.EffectBB:Clone()
    self.Billboard.Parent = self.InstanceObject
	self.Enabled = true;
    self.FlashPart = self.InstanceObject
	self:SetUp()
end

function FlareEffect:UpdateDistance()
	local q : BillboardGui;
	local Angle = math.deg(Angle(self.FlashPart.CFrame.LookVector, (self.FlashPart.CFrame.p -  workspace.CurrentCamera.CFrame.Position).Unit))
	Angle -= 90
	if(Angle < 0 ) then
		self.Billboard.Size = UDim2.fromScale(0,0)
		return -- Too low!
	end
	local Times = Angle/90
	self.Billboard.Size = UDim2.fromScale(8*Times, 8*Times);
	self.Billboard.StudsOffsetWorldSpace = Vector3.new(0,0, -0.8*Times)
end

function FlareEffect:Tick(dt)
	if self.Enabled == false then
		self.Billboard.Size = UDim2.fromScale(0,0)
		return;
	end
	self:UpdateDistance()
end

function FlareEffect:SetUp()
	game["Run Service"].Heartbeat:Connect(function(dt) self:Tick(dt) end)
end

function FlareEffect:Toggle(State)
	if State == self.Enabled then
		return
	end

	if State == nil then
		State = not self.Enabled
	end

	self.Enabled = State
end

return FlareEffect