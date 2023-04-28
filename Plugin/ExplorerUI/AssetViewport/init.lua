--[[
	TODO:
	More efficient filter algorithm
	Cache thumbnail icons for objects
]]

--!nonstrict
local PluginAction = game:GetService("PluginAction")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local InstanceAdder = require(script.InstanceAdder)
local ObjectPlacer = require(script.Parent.ObjectPlacer)
local AssetsViewport
local RightClickMenu = require(script.Parent.RightClickMenu)

local GridViewport = require(script.Viewport.Grid)
local ListViewport = require(script.Viewport.List)



local ButtonColors = {
	Selected = Color3.fromRGB(11, 90, 175),
	Highlight = Color3.fromRGB(66,66,66),
	Default = Color3.fromRGB(46,46,46),
	SpecialSelected = Color3.fromRGB(35, 175, 14)
}

local module = {
	ViewportMode = "Grid",
	InsertModeEnabled = false,
	Connections = {},
	ShowingInExplorer = {}

}
local CopySelection = nil

function module:init(data)
	ObjectPlacer:Init(data.Plugin)
	InstanceAdder:Init(data.Frame)
	--[[
	InstanceAdder.OnInstanceClicked:Connect(function(instanceName)
		InstanceAdder:Hide()
		if self.CurrentlySelected then
			Instance.new(instanceName).Parent = self.CurrentlySelected.Object
		end
	end)
	]]

	self.Plugin = data.Plugin
	self.DirectoryChangedObject = Instance.new("BindableEvent")
	self.DirectoryChanged = self.DirectoryChangedObject.Event

	self.frame = data.Frame
	self.InputFrame = data.Frame.InputFrame
	self.ViewportMode = "Grid"

	self.GridViewport = GridViewport.new({
		InputFrame = self.InputFrame,
		Frame = self.frame.AssetsViewport,
		Directory = game,
		Plugin = self.Plugin
	})
	self.ListViewport = ListViewport.new({
		InputFrame = self.InputFrame,
		Frame = self.frame.ListViewport,
		Directory = game,
		Plugin = self.Plugin
	})
	self.CurrentViewport = self.GridViewport

	self.GridViewport.ButtonCreated:Connect(function(btn)
		self:ButtonCreated(btn, self.GridViewport)
	end)
	self.ListViewport.ButtonCreated:Connect(function(btn)
		self:ButtonCreated(btn, self.ListViewport)
	end)

	self.FilterTextbox = self.frame:FindFirstChild("FilterTextbox", true)
	AssetsViewport = self.frame.AssetsViewport

	--Move all data to self
	for i,v in pairs(data) do
		self[i] = v
	end

	self:render()

	self.FilterTextbox.Changed:connect(function(property)
		if property == "Text" then
			self.ListViewport:SetFilterText(self.FilterTextbox.Text)
			self.GridViewport:SetFilterText(self.FilterTextbox.Text)
			--self:render()
		end
	end)

	self.MainFrame = self.frame

	--Input detection for frame
	self.InputFrame.InputBegan:connect(function(input:InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
			InstanceAdder:Hide()
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ==Enum.KeyCode.Tab then

		end
	end)
	self.InputFrame.InputEnded:connect(function(input:InputObject)
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ==Enum.KeyCode.Tab then

		end
	end)
end

function module:ToggleSideBySide(toggle)
	self.SideBySideEnabled = toggle
	if toggle == true then
		self.ListViewport:UpdateDirectory(game)
		self.MainFrame.AssetsViewport.Size = UDim2.new(1, -350, 1, -65)
		self.MainFrame.ListViewport.Size = UDim2.new(0, 350, 1, -65)
		self.MainFrame.ViewportResize.Position = UDim2.new(0, 350, 0, 35)
		self.MainFrame.ViewportResize.Visible = true
	else
		self.MainFrame.AssetsViewport.Size = UDim2.new(1, 0, 1, -65)
		self.MainFrame.ListViewport.Size = UDim2.new(1, 0, 1, -65)
		self.MainFrame.ViewportResize.Visible = false
	end
	self:render()
end

function module:ToggleStampMode(toggle)
	module.StampModeEnabled = toggle

	if self.CurrentlySelected == nil then return end

	if self.StampModeEnabled then
		self.CurrentlySelected:SetButtonColor(ButtonColors.SpecialSelected)
		ObjectPlacer:SetObjectToPlace(self.CurrentlySelected.Object)
	else
		self.CurrentlySelected:SetButtonColor(ButtonColors.Selected)
		ObjectPlacer:SetObjectToPlace(nil)
	end
end


function module:ToggleInsertMode(toggle)
	module.InsertModeEnabled = toggle
end

function module:ButtonCreated(button, viewport)
	local object = button.Object
	local m = self

	button.OnSelected:Connect(function()
		if m.SideBySideEnabled then
			if (viewport == self.ListViewport) then
				module:UpdateDirectory(button.Object)
			end
		end

		m.CurrentlySelected = button
		if self.StampModeEnabled then
			ObjectPlacer:SetObjectToPlace(m.CurrentlySelected.Object)
			button:SetButtonColor(ButtonColors.SpecialSelected)
		end
	end)

	button.MouseButton2Click:Connect(function()
		local object = button.Object

		RightClickMenu:Display(object, function(action:PluginAction)
			if not action then return end
			local action = action.Text
			if action == "Duplicate" then
				local obj = object:Clone()
				obj.Parent = object.Parent
			elseif action == "Rename" then
				button:TriggerRenaming()
			elseif action == "Delete" then
				ChangeHistoryService:SetWaypoint("Deleting")
				object.Parent = nil
				ChangeHistoryService:SetWaypoint("Delete")
			elseif action == "Paste Into" then
				local cop = CopySelection:Clone()
				ChangeHistoryService:SetWaypoint("Pasting")
				cop.Parent = object
				ChangeHistoryService:SetWaypoint("Paste Into")
			elseif action == "Copy" then
				CopySelection = object:Clone()
			elseif action == "Go Into" then
				--self:UpdateDirectory(object)
			elseif action == "Open" then
				self.Plugin:OpenScript(object)
			elseif action == "Insert Object..." then
				InstanceAdder:Display(button.Button.AbsolutePosition + Vector2.new(10, 30), object)
			end
		end, CopySelection ~= nil)
	end)

	button.MouseButton3Click:Connect(function()
		if object.ClassName ~= "Workspace" and (object:IsA("BasePart") or object:IsA("Model")) then
			ChangeHistoryService:SetWaypoint("Creating Part")
			local clone = object:Clone()
			local pos = game.Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -15)
			if clone:IsA("BasePart") then
				clone.Locked = false
			end
			for i,v in pairs(clone:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Locked = false
				end
			end
			clone:PivotTo(CFrame.new(pos.Position))
			clone.Parent = workspace
			Selection:Set({clone})
			ChangeHistoryService:SetWaypoint("Create Part")
		elseif object:IsA("Script") then
			self.Plugin:OpenScript(object)
		else
			self:UpdateDirectory(object)
		end
	end)

	button.MouseButton1DoubleClick:Connect(function()
		if m.SideBySideEnabled then
			if button.Type == "ListViewButton" then
				if object:IsA("Script") or object:IsA("ModuleScript") or object:IsA("LocalScript") then
					self.Plugin:OpenScript(object)
					return
				end
			end
		end
		if self.InsertModeEnabled == false then
			if #object:GetChildren() > 0 then
				self:UpdateDirectory(object)
			end
			return
		end
		if object.ClassName ~= "Workspace" and (object:IsA("BasePart") or object:IsA("Model")) then
			ChangeHistoryService:SetWaypoint("Creating Part")
			local clone = object:Clone()
			local pos = game.Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -15)
			if clone:IsA("BasePart") then
				clone.Locked = false
			end
			for i,v in pairs(clone:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Locked = false
				end
			end
			clone:PivotTo(CFrame.new(pos.Position))
			clone.Parent = workspace
			Selection:Set({clone})
			ChangeHistoryService:SetWaypoint("Create Part")
		elseif object:IsA("Script") or object:IsA("ModuleScript") or object:IsA("LocalScript") then
			self.Plugin:OpenScript(object)
		else
			self:UpdateDirectory(object)
		end
	end)
end

function module:UpdateDirectory(directory)
	script.Directory.Value = directory
	-- Setting filter re-renders the viewports
	self.FilterTextbox.Text = ""
	self.Directory = directory
	-- Updating directory re-renders the viewports
	self.GridViewport:UpdateDirectory(directory)
	if not self.SideBySideEnabled then
		self.ListViewport:UpdateDirectory(directory)
	end

	self.DirectoryChangedObject:Fire(directory)
	--self:render()
end


function module:ForceRender()
	self.ListViewport.Rendered = false
	self.GridViewport.Rendered = false
	self:render()
end
function module:render()
	if self.SideBySideEnabled then
		self.ListViewport:Show()
		self.GridViewport:Show()
	else
		if self.ViewportMode == "List" then
			self.ListViewport:Show()
			self.GridViewport:Hide()
		else
			self.ListViewport:Hide()
			self.GridViewport:Show()
		end
	end
end

function module:EnableListView()
	if not self.SideBySideEnabled then
		self.ViewportMode = "List"
		self.CurrentViewport = self.ListViewport
	end
	self:render()
end

function module:EnableGridView()
	if not self.SideBySideEnabled then
		self.ViewportMode = "Grid"
		self.CurrentViewport = self.GridViewport
	end

	self:render()
end

return module
