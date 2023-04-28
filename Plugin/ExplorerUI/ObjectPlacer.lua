local UserInputService = game:GetService("UserInputService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local module = {
	ObjectToPlace = nil,
	PreviewObject = nil
}

local CS = game:GetService("CollectionService")
local rotation = 0
local plugin
local AutoGrid = false

local mouseIsDown = false
local originalPivot = nil
local ViewportFrame = nil

function module:Init(plug)
	plugin = plug
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Archivable = false
	ViewportFrame = Instance.new("ViewportFrame")
	ViewportFrame.CurrentCamera = workspace.CurrentCamera
	ViewportFrame.Parent = ScreenGui
	ViewportFrame.Size = UDim2.new(1, 0, 1, 0)
	ViewportFrame.BackgroundTransparency = 1
	ViewportFrame.LightDirection = Vector3.new(1, 1, 1)
	--ViewportFrame.Ambient = Color3.fromRGB(45, 255, 30)
	ViewportFrame.ImageColor3 = Color3.fromRGB(45, 255, 30)
	ViewportFrame.ImageTransparency = 0.5
	ScreenGui.Parent = game:GetService("CoreGui")
end

function module:ToggleAutoGrid(value)
	AutoGrid = value
end

function MovePartToModel(part)
	local model = Instance.new("Model")
	if part:IsA("BasePart") then
		part.Locked = true
	end
	for i,v in pairs(part:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = true
		end
	end
	part.Parent = model
	return model
end

function MoveOutOfModel(model)
	local pp = model:GetChildren()[1]
	pp.Parent = workspace
	model:Destroy()
	if pp:IsA("BasePart") then
		pp.Locked = false
	end

	for i,v in pairs(pp:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = false
		end
	end
	return pp
end

function module:ResetPreviewObject()
	local model = MovePartToModel(module.ObjectToPlace:Clone())
	module.PreviewObject = model
	module.PreviewObject.Parent = ViewportFrame
	CS:AddTag(module.PreviewObject, "PreviewObject")
end

function module:SetObjectToPlace(object)
	if object == nil then
		if module.PreviewObject ~= nil then
			module.PreviewObject:Destroy()
		end
		if module.ObjectToPlace ~= nil then
			module.ObjectToPlace:Destroy()
		end
		module.PreviewObject = nil
	else
		if module.PreviewObject ~= nil then
			module.PreviewObject:Destroy()
		end
		if module.ObjectToPlace ~= nil then
			module.ObjectToPlace:Destroy()
		end
		module.ObjectToPlace = object:Clone()
		
		module:ResetPreviewObject()
	end
end


UserInputService.InputBegan:Connect(function(input:InputObject)
	if module.ObjectToPlace == nil then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if module.ObjectToPlace~= nil and module.PreviewObject ~= nil then
			mouseIsDown = true
			originalPivot = module.PreviewObject:GetPivot()
		end
	elseif input.UserInputType == Enum.UserInputType.Keyboard then
		if module.PreviewObject ~= nil and input.KeyCode == Enum.KeyCode.R then
			rotation += math.pi / 2
			UpdatePreview()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input:InputObject)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouseIsDown = false
		if module.PreviewObject == nil then return end
		ChangeHistoryService:SetWaypoint("Creating Part")
		local object = module.PreviewObject:Clone()
		MoveOutOfModel(object)
		ChangeHistoryService:SetWaypoint("Create Part")
	end
end)

function GetRayPosition()
	local camera = workspace.CurrentCamera
	local unitRay = camera:ScreenPointToRay(UserInputService:GetMouseLocation().X,UserInputService:GetMouseLocation().Y)
	local ray = Ray.new(unitRay.Origin, unitRay.Direction * 500000)
	local Hit, Position = game.Workspace:FindPartOnRayWithIgnoreList(ray, CS:GetTagged("PreviewObject"))
	return Position
end

function UpdatePreview()
	plugin:Activate(true)
	local Position = GetRayPosition()
	local part = module.PreviewObject
	local size = part:GetExtentsSize()
	local pos = part:GetPivot().Position
	local grid = Vector3.new(plugin.GridSize, plugin.GridSize, plugin.GridSize)
	if AutoGrid then
		grid = Vector3.new(size.X, plugin.GridSize, size.Z)
	end
	
	if mouseIsDown then
		pos = (originalPivot).Position
		--part:PivotTo(CFrame.new( pos + Vector3.new(size.X/2, 0, 0), Vector3.new(Position.X, pos.Y, Position.Z)) * CFrame.Angles(0, rotation, 0) *CFrame.new(size.X/2,0,0))
		part:PivotTo(CFrame.new( pos, Vector3.new(Position.X, pos.Y, Position.Z)) * CFrame.Angles(0, rotation, 0))
	else
		Position = Vector3.new(math.round(Position.X / grid.X) * grid.X, Position.Y, math.round(Position.Z / grid.Z) * grid.Z)
		part:PivotTo(CFrame.new(Position + Vector3.new(0, size.Y/2, 0) )* CFrame.Angles(0, rotation, 0))
	end
	
end

UserInputService.InputChanged:Connect(function(input:InputObject)
	if module.PreviewObject == nil then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		UpdatePreview()
	end
end)

return module
