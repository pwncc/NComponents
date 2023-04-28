--TODO: Cache buttons so they don't re-render
local ViewportObject = { }
ViewportObject.__index = ViewportObject
local Signal = require(script.Parent.Signal)
local ThumbnailSetter = require(script.Parent.ThumbnailSetter)
local ChangeHistoryService = game:GetService("ChangeHistoryService")

--Global settings
LazyLoadThumbnails = nil
RenderListViewThumbnails = nil
RenderGridViewThumbnails = nil

local ButtonColors = {
	Selected = Color3.fromRGB(11, 90, 175),
	Highlight = Color3.fromRGB(66,66,66),
	Default = Color3.fromRGB(44, 44, 44),
	SpecialSelected = Color3.fromRGB(35, 175, 14)
}

function ViewportObject.new(object)
	local m = {}
	setmetatable(m, ViewportObject)
	m.OriginalParent = object.Parent
	m.Selected = false
	m.MultiSelected = {}
	m.Object = object
	m.OnSelected = Signal.new()
	m.MouseButton3Click = Signal.new()
	
	m.RenderGridViewThumbnails = RenderGridViewThumbnails
	m.RenderListViewThumbnails = RenderListViewThumbnails
	m.LazyLoadThumbnails = LazyLoadThumbnails
	return m
end

function ViewportObject:RenderThumbnail(RenderObject)
	if LazyLoadThumbnails and self.MainFrame.Parent:IsA("ScrollingFrame") then
		if not self:CheckLazyLoad(RenderObject) then
			self.LazyLoadListener = nil
			self.LazyLoadListener = self.MainFrame.Parent.Changed:connect(function(prop)
				if prop == "CanvasPosition" or prop == "AbsoluteWindowSize" or prop == "AbsoluteCanvasSize" then
					self:CheckLazyLoad(RenderObject)
				end
			end)
		end
	else
		ThumbnailSetter:render(self.Button, self.Object, RenderObject)
	end
end

function ViewportObject:CheckLazyLoad(RenderObject)
	local scrollingFrame = self.MainFrame.Parent
	if scrollingFrame.AbsoluteWindowSize.Y+scrollingFrame.CanvasPosition.y+30 > self.MainFrame.AbsolutePosition.Y then
		if self.LazyLoadListener then
			self.LazyLoadListener:Disconnect()
		end
		ThumbnailSetter:render(self.Button, self.Object, RenderObject)
		return true
	end
	return false
end

function ViewportObject:ToggleLazyLoading(toggle)
	LazyLoadThumbnails = toggle
end

function ViewportObject:ToggleGridThumbnailRendering(toggle)
	RenderGridViewThumbnails = toggle
end

function ViewportObject:ToggleListThumbnailRendering(toggle)
	RenderListViewThumbnails = toggle
end

function ViewportObject:SetSelected(selected)
	self.Selected = selected
	if selected then
		self:SetButtonColor(ButtonColors.Selected) 
	else
		self:SetButtonColor(ButtonColors.Default)
	end
	if selected then
		self.OnSelected:Fire()
	end
end

local SpecialOrders = {
	Workspace = 0,
	Players = 1,
	Lighting = 2,
	ReplicatedFirst = 3,
	ReplicatedStorage = 4,
	ServerScriptService = 5,
	ServerStorage = 6,
	StarterGui = 7,
	StarterPack = 8,
	StarterPlayer = 9,
	Camera = 1,
	Terrain = 2,
	Folder = 3,
	Script = 4,
	SpawnLocation = 5,
	LocalScript = 6,
	ModuleScript = 7,
	Model = 8
}

function ViewportObject:SetName()
	local object = self.Object
	local mainFrame = self.MainFrame
	local specialOrder = SpecialOrders[object.ClassName]
	local name = object.Name
	if specialOrder ~= nil then
		name = tostring(specialOrder) .. name
	end
	self.Button.ItemName.Text = object.Name
	mainFrame.Name = name
end

local draggingObject = nil
local hoveringOver = nil
local dragClone:Frame = nil
function ViewportObject:CreateButtonEvents()
	local lastClickTime = 0
	local mouseButtonDown = false
	local originalMouseDownPosition = Vector3.new(0, 0, 0)
	local mouseDelta = Vector3.new(0,0,0)
	
	self.OnDragStart = Signal.new()
	self.OnDragStop = Signal.new()
	self.OnDrag = Signal.new()
	
	self.MouseButton1Down = self.Button.MouseButton1Down
	self.MouseButton2Down = self.Button.MouseButton2Down
	self.MouseButton1Up = self.Button.MouseButton1Up
	self.MouseButton2Up = self.Button.MouseButton2Up
	self.MouseButton1Click = self.Button.MouseButton1Click
	self.MouseButton2Click = self.Button.MouseButton2Click
	self.MouseButton1DoubleClickObject = Instance.new("BindableEvent")
	self.MouseButton1DoubleClick = self.MouseButton1DoubleClickObject.Event
	
	local button = self.Button
	button.MouseEnter:Connect(function()
		hoveringOver = self
		if self.Selected then return end
		button.BackgroundColor3 = ButtonColors.Highlight
	end)

	button.MouseLeave:Connect(function()
		if hoveringOver == self then
			hoveringOver = nil
		end
		if self.Selected then return end
		button.BackgroundColor3 = ButtonColors.Default
	end)
	
	button.MouseButton2Click:Connect(function()
		self:SetSelected(true)
	end)
	
	button.MouseButton1Click:Connect(function()

		self:SetSelected(true)
	end)
	
	button.InputBegan:Connect(function(input:InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton3 then
			self.MouseButton3Click:Fire()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			
			mouseButtonDown = true
			mouseDelta = input.Position
			originalMouseDownPosition = input.Position
			
			if tick() - lastClickTime < 0.3 then
				self.MouseButton1DoubleClickObject:Fire()
			elseif tick() - lastClickTime > 0.3 and tick() - lastClickTime < 0.8 then-- Object renaming
				if self.Selected then
					spawn(function()
						wait(0.5)
						if self.Selected and dragClone == nil then
							self:TriggerRenaming()
						end
					end)
				end
			end

			lastClickTime = tick()
		end
	end)
	
	button.InputEnded:Connect(function(input:InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			mouseButtonDown = false
			if dragClone ~= nil then
				dragClone:Destroy()
				dragClone = nil
				
				--Wrap this in pcall in case the parenting has an error (e.g. trying to move the workspace to another parent)
				local success, error = pcall(function()
					--If hovering over == nil, we assume they're hovering over an empty part of the frame, so we parent to the directory
					if hoveringOver == nil then
						self.Object.Parent = script.Parent.Directory.Value -- Bad, quick way to do it
					end
					if hoveringOver ~= nil and hoveringOver ~= self then
						--TODO: Make a function so we can select the new child
						self.Object.Parent = hoveringOver.Object
						if hoveringOver.DisplayChildren then
							hoveringOver:DisplayChildren()
						end
					end
				end)
			end
		end
	end)
	
	--Listens for the MainFrame to be destroyed so we can properly clean up
	self.MainFrameChangedEvent = self.MainFrame.Changed:Connect(function(prop)
		if prop == "Parent" and self.MainFrame.Parent == nil then
			mouseButtonDown = false
			self:Destroy()
		end
	end)
	
	self.objChangeEvent = self.Object.Changed:Connect(function(prop)
		if prop == "Parent" then
			if self.Object.Parent ~= self.OriginalParent then
				mouseButtonDown = false
				self:Destroy()
			end
		elseif prop == "Name" then
			self:SetName()
		end
	end)
	
	self.InputChangedEvent = self.InputFrame.InputChanged:Connect(function(input:InputObject)
		--print(self.MainFrame)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			-- They must drag 15 pixels before dragging starts
			if mouseButtonDown and (originalMouseDownPosition - input.Position).Magnitude > 15 then
				mouseDelta = input.Position - mouseDelta
				if dragClone == nil then
					mouseDelta = Vector3.new(0,0,0)
					dragClone = self.Button:Clone()
					dragClone.Parent = self.InputFrame
					dragClone.Size = UDim2.new(0, self.Button.AbsoluteSize.X, 0, self.Button.AbsoluteSize.Y)
					dragClone.Position = UDim2.new(0, input.Position.X, 0, input.Position.Y)
					dragClone.Name = "test"
				end
				dragClone.Position = dragClone.Position + UDim2.new(0, mouseDelta.X, 0, mouseDelta.Y)
				mouseDelta = input.Position
			end
		end
	end)
end

function ViewportObject:TriggerRenaming()
	self.Button.ItemNameBox.Visible = true
	self.Button.ItemNameBox.Text = self.Button.ItemName.Text
	self.Button.ItemNameBox.SelectionStart = 0
	self.Button.ItemNameBox:CaptureFocus()
	self.Button.ItemName.Visible = false
	local inputChangedCon
	inputChangedCon = self.Button.ItemNameBox.FocusLost:connect(function(enterPressed)
		inputChangedCon:Disconnect()

		self.Button.ItemNameBox.Visible = false
		self.Button.ItemName.Visible = true

		if enterPressed then
			ChangeHistoryService:SetWaypoint("Renaming")
			self.Object.Name = self.Button.ItemNameBox.Text
			ChangeHistoryService:SetWaypoint("Renaming")
		end
	end)
end

function ViewportObject:SetButtonColor(color)
	if color == ButtonColors.Default then
		self.Button.BackgroundTransparency = 1
	else
		self.Button.BackgroundTransparency = 0
	end
	self.Button.BackgroundColor3 = color
end

return ViewportObject
