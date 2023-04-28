local ThumbnailSetter = require(script.Parent.Parent.ThumbnailSetter)
local gridViewportObject = script.GridViewportObject
local ViewportObject = require(script.Parent)
local GridViewportObject = {
	Type = "GridViewButton"
}
GridViewportObject.__index = GridViewportObject
setmetatable(GridViewportObject, ViewportObject)

function GridViewportObject.new(referenceObject, parent, inputFrame)
	local new = ViewportObject.new(referenceObject)
	setmetatable(new, GridViewportObject)
	
	new.InputFrame = inputFrame
	new.MainFrame = gridViewportObject:Clone()
	new.Button = new.MainFrame.Main
	new.MainFrame.Parent = parent
	
	new:CheckChildButton()
	
	new.ChildRemovedConnection = referenceObject.ChildRemoved:Connect(function(child)
		--new.ChildrenRendered = false
		new:CheckChildButton()
	end)
	new.ChildAddedConnection = referenceObject.ChildAdded:Connect(function(child)
		new:CheckChildButton()
	end)
	
	new:SetName()
	new:CreateButtonEvents()
	
	new:RenderThumbnail(new.RenderGridViewThumbnails)
	return new
end

function GridViewportObject:CheckChildButton()
	if #self.Object:GetChildren() > 0 then
		self.MainFrame.ChildrenMarker.Visible = true
	else
		self.MainFrame.ChildrenMarker.Visible = false
	end
end

function GridViewportObject:SetButtonColor(Color)
	self.Button.BackgroundColor3 = Color
end

function GridViewportObject:Destroy()
	for i,v in pairs(self) do
		local t = typeof(v)
		--[[print(i)
		print(v)
		print(t)]]
		if t == "RBXScriptConnection" then
			v:Disconnect()
		elseif t == "table" then
			if v.ClassName == "Signal" then
				v:Destroy()
			end
		end
		--print("---------------")
	end
	
	self.MainFrame:Destroy()
	self = nil
end

return GridViewportObject
