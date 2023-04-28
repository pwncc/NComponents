local module = {}

--local objectReference = script.Parent:WaitForChild("Object")

local fov = 1
local defaultLook = Vector3.new(-0.5, -0.4, -0.5)
local cameraBase = Instance.new("Camera")
--local viewportFrame = script.Parent.ViewportFrame
--local folderImageFrame = script.Parent.FolderImage
--local itemNameTextLabel = script.Parent.ItemName

cameraBase.FieldOfView = fov


local function isVisual(object, isRoot)
	if not isRoot then
		return (object:IsA("BasePart") or
			object:IsA("Decal") or
			object:IsA("Texture") or
			object:IsA("Model") or
			object:IsA("DataModelMesh") or
			object:IsA("SurfaceAppearance")
		)
	else
		return object:IsA("BasePart") or
			object:IsA("Model")
	end
end

local function prepareForThumbnail(object, _isRoot)
	local _isRoot = _isRoot == nil

	for _, child in next, object:GetChildren() do
		prepareForThumbnail(child, false)
	end

	if not isVisual(object, _isRoot) then
		local children = object:GetChildren()
		if #children == 0 and not _isRoot then
			object:Destroy()
			return
		end

		local model = Instance.new("Model")
		for _, child in next, children do
			child.Parent = model
		end
		model.Name = object.Name
		model.Parent = object.Parent
		object:Destroy()

		return model
	end

	return object
end

function GetModelAABBFast(model)
	local originalPrimaryPart = model.PrimaryPart
	local fakeCenter = Instance.new("Part")
	fakeCenter.Size = Vector3.new(0, 0, 0)
	local center, extents
	if originalPrimaryPart then
		fakeCenter.CFrame = CFrame.new(originalPrimaryPart.Position)
		fakeCenter.Parent = model
		model.PrimaryPart = fakeCenter
		center = model:GetModelCFrame().p
		extents = model:GetExtentsSize()
		model.PrimaryPart = originalPrimaryPart
	else
		local calcCenter = model:GetModelCFrame()
		fakeCenter.CFrame = CFrame.new(calcCenter.p)
		fakeCenter.Parent = model
		model.PrimaryPart = fakeCenter
		center = model:GetModelCFrame().p
		extents = model:GetExtentsSize()
		model.PrimaryPart = nil
	end

	fakeCenter:Destroy()
	local min, max = center-extents/2, center+extents/2

	return min, max
end

function GetPartAABB(obj)
	local abs = math.abs

	local cf = obj.CFrame -- this causes a LuaBridge invocation + heap allocation to create CFrame object - expensive! - but no way around it. we need the cframe
	local size = obj.Size -- this causes a LuaBridge invocation + heap allocation to create Vector3 object - expensive! - but no way around it
	local sx, sy, sz = size.X, size.Y, size.Z -- this causes 3 Lua->C++ invocations

	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components() -- this causes 1 Lua->C++ invocations and gets all components of cframe in one go, with no allocations

	-- https://zeuxcg.org/2010/10/17/aabb-from-obb-with-component-wise-abs/
	local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz) -- this requires 3 Lua->C++ invocations to call abs, but no hash lookups since we cached abs value above; otherwise this is just a bunch of local ops
	local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz) -- same
	local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz) -- same

	-- just a bunch of local ops
	local minx = x - wsx
	local miny = y - wsy
	local minz = z - wsz

	local maxx = x + wsx
	local maxy = y + wsy
	local maxz = z + wsz

	local minv, maxv = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	return minv, maxv
end

local function moveObjectToCenter(object)
	if #object:GetChildren() == 0 and object:IsA("Model") then
		return
	end

	if object:IsA("Model") then
		local min, max = GetModelAABBFast(object)
		local boundingBox = Instance.new("Part")
		boundingBox.Size = max-min
		boundingBox.CFrame = CFrame.new((min+max)/2)
		local originalPrimaryPart = object.PrimaryPart
		object.PrimaryPart = boundingBox
		object:SetPrimaryPartCFrame(CFrame.new())
		object.PrimaryPart = originalPrimaryPart
	else
		object.CFrame = object.CFrame - object.Position
	end
end

local function GetZoomOffset(fov, aspectRatio, targetSize, percentOfScreen)
	local x, y, z = targetSize.x, targetSize.y, targetSize.Z
	local maxSize = math.sqrt(x^2 + y^2 + z^2)
	local heightFactor = math.tan(math.rad(fov)/2)
	local widthFactor = aspectRatio*heightFactor

	local depth = 0.5*maxSize/(percentOfScreen.x*widthFactor)
	local depthTwo = 0.5*maxSize/(percentOfScreen.y*heightFactor)

	return math.max(depth, depthTwo)+maxSize/2
end

local thumbCache = {}
setmetatable(thumbCache, { __mode = "k" })

local function getThumbEntry(object, fromCache)
	local thumbEntry = thumbCache[object]
	if thumbEntry == nil or fromCache == false then
		local ok, err = pcall(function()
			local copy = object:Clone()
			copy = prepareForThumbnail(copy)
			moveObjectToCenter(copy)
			local min, max
			if copy:IsA("Model") then
				min, max = GetModelAABBFast(copy)
			else
				min, max = GetPartAABB(copy)
			end

			local dist = GetZoomOffset(fov, 1, (max-min), Vector2.new(1, 1))

			thumbEntry = { copy, dist }
			thumbCache[object] = thumbEntry
		end)

		if not ok then
			thumbEntry = { Instance.new("Model"), 0 }
			thumbCache[object] = thumbEntry			
		end
	end

	return thumbEntry
end

local dist = nil
local objectClone = nil
local cam = nil
local yRotation = 5

local icons = {
	Folder = "8493342277"
}

function module:GetViewport(object)
	local viewportFrame = Instance.new("ViewportFrame")
	assert(object == nil or (object:IsA("BasePart") or object.ClassName == "Model" or object:IsA("Folder")))

	if object then
		if object:IsA("Folder") then
			viewportFrame.Visible = false
		else
			viewportFrame.Visible = true
			local thumbEntry = getThumbEntry(object, false)
			local objectClone, dist = thumbEntry[1]:Clone(), thumbEntry[2]
			dist = dist
			local cam = cameraBase:Clone()
			local look = CFrame.Angles(0, yRotation or 0, 0):vectorToWorldSpace(defaultLook)
			cam.CFrame = CFrame.new(Vector3.new(), look) * CFrame.new(0, 0, dist)

			objectClone.Parent = viewportFrame
			cam.Parent = viewportFrame
			viewportFrame.CurrentCamera = cam
			objectClone, cam = objectClone, cam
		end
	end
	
	return viewportFrame
end

--[[
function ObjectThumbnail:willUnmount()
	if self.objectClone then
		self.objectClone:Destroy()
		self.cam:Destroy()
	end
end
]]
--[[
function Update()
	local newObject = objectReference.Value
	local oldObject = objectClone
	--local newObject, oldObject = newProps.object, oldProps.object
	if newObject ~= oldObject then
		if newObject ~= nil then
			if objectClone then
				objectClone:Destroy()
				objectClone = nil
			end


			local thumbEntry = getThumbEntry(newObject)
			local objectClone, dist = thumbEntry[1]:Clone(), thumbEntry[2]
			dist = dist
			objectClone.Parent = viewportFrame

			local cam = cam
			if not cam then
				cam = cameraBase:Clone()
				cam = cam
			end
			local look = CFrame.Angles(0, yRotation or 0, 0):vectorToWorldSpace(defaultLook)
			cam.CFrame = CFrame.new(Vector3.new(), look) * CFrame.new(0, 0, dist)
			cam.Parent = viewportFrame
			objectClone = objectClone
		else
			if objectClone then
				objectClone:Destroy()
				objectClone = nil
			end
		end
	end

	--[[
	if oldProps.yRotation ~= newProps.yRotation then
		local cam = self.cam
		local look = CFrame.Angles(0, newProps.yRotation or 0, 0):vectorToWorldSpace(defaultLook)
		cam.CFrame = CFrame.new(Vector3.new(), look) * CFrame.new(0, 0, self.dist)
	end
	
end
]]

return module
