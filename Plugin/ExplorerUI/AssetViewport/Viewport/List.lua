--[[
	Events
	- OnButtonSelect
		Returns: ListViewportObject
	- 
]]

local ListViewportObject = require(script.Parent.Parent.ViewportObject.ListViewportObject)
local InstanceAdder = require(script.Parent.Parent.InstanceAdder)
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local Viewport = require(script.Parent)
local List = {}
List.__index = List
setmetatable(List, Viewport)

function List.new(data)
	local new = Viewport.new(data)
	setmetatable(new, List)
	
	new.InputFrame = data.InputFrame
	new.renderCall = 0
	new.Rendered = false
	new.Frame = data.Frame
	new:UpdateDirectory(data.Directory)
	
	new.ChildrenOpen = {}
	
	return new
end

function List:render()
	if  self.Rendered then return end 
	self.Rendered = true
	self.renderCall += math.random(-2, 2) + 1
	local currentRenderCall = self.renderCall
	local objectsToDisplay = self:GetObjectsToDisplay()

	self:ClearViewport()

	self.CurrentlySelected = nil

	if self.Connections.ChildAddedDirectory then
		self.Connections.ChildAddedDirectory:Disconnect()
	end

	self.Connections.ChildAddedDirectory = self.Directory.ChildAdded:connect(function(child)
		-- If the object is not in the explorer, don't show it
		if not self:ObjectInExplorer(child) then
			local objectButton = self:CreateObjectButton(child, self.Frame, self.InputFrame)
		end
	end)
	
	spawn(function()
		for i,object in ipairs(objectsToDisplay) do
			local objectButton = self:CreateObjectButton(object, self.Frame, self.InputFrame)
			if i % 250 == 0 then -- helps with the lag (render 500 elements, then pause, then continue)
				wait()
			end
			if i % 500 == 0 then -- helps with the lag (render 500 elements, then pause, then continue)
				wait(0.05)
			end
			if currentRenderCall ~= self.renderCall then break end
		end
	end)
end

function List:ObjectButtonEvents(UIObject)
	local childrenButton = UIObject.MainFrame:FindFirstChild("ChildrenButton", true)
	local childrenFrame = UIObject.MainFrame:FindFirstChild("ChildrenFrame", true)
	local button = UIObject.Button
	local object = UIObject.Object
	
	UIObject.AddInstanceButtonClicked:Connect(function(pos)
		InstanceAdder:Display(pos, UIObject.Object)
	end)

	UIObject.OnSelected:Connect(function()
		self:SelectButton(UIObject)
	end)

	object.Changed:Connect(function(prop)
		if prop ~= "Parent" then return end
		-- If the object is no longer in the current directory, delete the button
		if prop == "Parent" and object.Parent == nil then
			self.ShowingInExplorer[UIObject] = nil
			UIObject:Destroy()
			return
		end
		if object.Parent ~= self.Directory then -- and not (self:ObjectPartOfFilter(object) and object:IsDescendantOf(self.Directory)) then
			self.ShowingInExplorer[UIObject] = nil
			UIObject:Destroy()
		end
	end)
end

function List:CreateObjectButton(object:Instance, parent, inputFrame)
	local UIObject
	local list = self
	
	UIObject = ListViewportObject.new(object, parent, inputFrame)
	
	UIObject.ChildAdded:connect(function(child)
		wait() -- Weird bug where I have to add this for the new child to be visible. probably because the child hasn't been fully parented yet
		list:CreateObjectButton(child, UIObject.ChildrenFrame, inputFrame)
		--UIObject:DisplayChildren()
	end)
	
	UIObject.OnHideChildren:Connect(function()
		self.ChildrenOpen[UIObject.Object] = nil
		UIObject.ChildrenRendered = false
		self:ClearViewport(UIObject.ChildrenFrame)
	end)
	
	UIObject.OnDisplayChildren:Connect(function()
		self.ChildrenOpen[UIObject.Object] = true
		self:ClearViewport(UIObject.ChildrenFrame)
		UIObject.ChildrenRendered = true

		for i, child in ipairs(UIObject.Object:GetChildren()) do --mod:GetObjectsToDisplay(self.Object)) do
			local objectButton = self:CreateObjectButton(child, UIObject.ChildrenFrame, inputFrame)
			if i % 500 == 0 then -- helps with the lag (render 500 elements, then pause, then continue)
				wait()
			end
		end
	end)
	
	self:ObjectButtonEvents(UIObject)
	self.ShowingInExplorer[object] = UIObject
	--TODO: FIX JANKY BAD MEMORY LEAKY WEAKY CHILDRENOPEN TABLE
	if self.ChildrenOpen[UIObject.Object] then
		UIObject:DisplayChildren()
	end
	
	self.ButtonCreated:Fire(UIObject)
	return UIObject
end

return List
