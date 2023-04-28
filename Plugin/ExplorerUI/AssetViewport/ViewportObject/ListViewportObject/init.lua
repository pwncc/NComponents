local ThumbnailSetter = require(script.Parent.Parent.ThumbnailSetter)
local listViewportObject = script.ListViewportObject
local ViewportObject = require(script.Parent)
local ListViewportObject = {
	Type = "ListViewButton"
}
local Signal = require(script.Parent.Parent.Signal)
ListViewportObject.__index = ListViewportObject
setmetatable(ListViewportObject, ViewportObject)

function ListViewportObject.new(referenceObject, parent, inputFrame)
	local new = ViewportObject.new(referenceObject)
	setmetatable(new, ListViewportObject)
	
	new.InputFrame = inputFrame
	new.MainFrame = listViewportObject:Clone()
	
	new.AddInstanceButton = new.MainFrame.Main.AddInstance
	new.Button = new.MainFrame.Main
	new.ChildrenButton = new.MainFrame.Main.ChildrenButton
	new.ChildrenFrame = new.MainFrame.ChildrenFrame
	new.MainFrame.Parent = parent
	new.Selected = false
	
	new.ChildAdded = Signal.new()
	new.OnDisplayChildren = Signal.new()
	new.OnHideChildren = Signal.new()
	new.AddInstanceButtonClicked = Signal.new()
	
	new.AddInstanceButton.MouseButton1Click:Connect(function()
		new.AddInstanceButtonClicked:Fire(new.AddInstanceButton.AbsolutePosition + Vector2.new(0, 30))
	end)
	
	local button = new.Button
	new:NewCreateButtonEvents()
	new:CheckChildButton()
	
	new.ChildRemovedConnection = referenceObject.ChildRemoved:Connect(function(child)
		--new.ChildrenRendered = false
		new:CheckChildButton()
	end)
	new.ChildAddedConnection = referenceObject.ChildAdded:Connect(function(child)
		new:CheckChildButton()
		if new.ChildrenRendered then
			new.ChildAdded:Fire(child)
		end
	end)
	
	new.ChildrenButton.MouseButton1Click:connect(function()
		if new.ChildrenButton.Visual.Rotation == 90 then
			new:DisplayChildren()
		else
			new:HideChildren()
		end
	end)
	
	new.MainFrame.Parent.ChildRemoved:connect(function(obj)
		if obj == new.MainFrame then
			new:Destroy()
		end
	end)
	
	--TODO: Make lazy load support ChildrenFrame
	new:SetName()
	new:RenderThumbnail(new.RenderListViewThumbnails)
	
	return new
end

function ListViewportObject:CheckChildButton()
	if #self.Object:GetChildren() == 0 then
		if self.ChildrenButton:FindFirstChild("Visual") then
			self.ChildrenButton.Visual.Visible = false
		end
		
		self.ChildrenRendered = false
	elseif self.ChildrenButton:FindFirstChild("Visual") and self.ChildrenButton.Visual.Visible == false then
		self.ChildrenButton.Visual.Rotation = 90
		self.ChildrenButton.Visual.Visible = true
	end
end

function ListViewportObject:DisplayChildren()
	self.ChildrenButton.Visual.Rotation = 180
	self.ChildrenFrame.AutomaticSize = Enum.AutomaticSize.XY
	self.ChildrenFrame.Visible = true
	if self.ChildrenRendered then
		return
	end
	self.OnDisplayChildren:Fire()
	

end
function ListViewportObject:HideChildren()
	self.ChildrenButton.Visual.Rotation = 90
	self.ChildrenFrame.AutomaticSize = Enum.AutomaticSize.None
	self.ChildrenFrame.Visible = false
	self.OnHideChildren:Fire()
end

function ListViewportObject:NewCreateButtonEvents()
	self:CreateButtonEvents() -- Call parent CreateButtonEvents
	self.Button.MouseEnter:Connect(function()
		self.AddInstanceButton.Visible = true
		self.Button.Transparency = 0
	end)

	self.Button.MouseLeave:Connect(function()
		self.AddInstanceButton.Visible = false
		if not self.Selected then
			self.Button.Transparency = 1
		end
	end)
end

function ListViewportObject:Destroy()
	--if self.Destroyed == true then return end
	if getmetatable(self)["Destroy"] then
		getmetatable(self):Destroy()
	end

	self.Destroyed = true
	
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
	
	if self.MainFrame then
		self.MainFrame:Destroy()
	end
	
	self = nil
end

return ListViewportObject
