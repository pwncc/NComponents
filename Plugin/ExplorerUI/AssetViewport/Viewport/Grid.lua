local GridViewportObject = require(script.Parent.Parent.ViewportObject.GridViewportObject)
local ThumbnailSetter = require(script.Parent.Parent.ThumbnailSetter)
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local Viewport = require(script.Parent)
local Grid = {}
Grid.__index = Grid
setmetatable(Grid, Viewport)

function Grid.new(data)
	local new = Viewport.new(data)
	setmetatable(new, Grid)
	
	new.InputFrame = data.InputFrame
	new.Rendered = false
	new.renderCall = 0
	new.Frame = data.Frame
	
	return new
end
function Grid:render()
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
	if self.Connections.ChildRemovedDirectory then
		self.Connections.ChildRemovedDirectory:Disconnect()
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

function Grid:CreateObjectButton(object:Instance, parent, inputFrame)
	local lastClickTime = 0
	local UIObject
	local mod = self

	UIObject = GridViewportObject.new(object, parent, inputFrame)

	self.ShowingInExplorer[object] = UIObject
	local button = UIObject.Button
	--ThumbnailSetter:render(button, object, true)
	
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
	
	--[[
	object.Changed:Connect(function()
		-- If the object is no longer in the current directory, delete the button
		if object.Parent ~= self.Directory and not (self:ObjectPartOfFilter(object) and object:IsDescendantOf(self.Directory))
		then
			UIObject:Destroy()
		end
	end)
	]]

	self.ButtonCreated:Fire(UIObject)


	return UIObject
end

return Grid
