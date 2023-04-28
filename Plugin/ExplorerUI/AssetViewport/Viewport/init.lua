local Selection = game:GetService("Selection")
local Viewport = {}
Viewport.__index = Viewport

local Signal = require(script.Parent.Signal)

function Viewport.new(data)
	local m = {}
	setmetatable(m, Viewport)
	m.renderCall = 0
	m.ButtonCreated = Signal.new() --m.ButtonCreatedObject.Event
	m.Connections = {}
	
	for i,v in pairs(data) do
		m[i] = v
	end
	
	m.ShowingInExplorer = {} -- The items that have been rendered in the explorer
	
	return m
end

function Viewport:GetFilterText(text)
	return self.FilterText or ""
end

function Viewport:SetFilterText(text)
	--TODO: Render if viewport is visible
	self.Rendered = false
	self.FilterText = string.lower(text)
	if self.Visible then
		self:render()
	end
end

function Viewport:UpdateDirectory(directory)
	if self.Directory == directory then return end -- Prevents re-rendering of directory
	self.Rendered = false
	self.Directory = directory
	if self.Visible then
		self:render()
	end
	--self:render()
end

function Viewport:ObjectPartOfFilter(object)
	local filterText = string.lower(self:GetFilterText())

	return string.lower(object.Name):match(filterText) ~= nil
end

function Viewport:SlowClearViewport(Viewport)
	local viewportToClear = Viewport
	if Viewport == nil then
		viewportToClear = self.Frame
	end
end

function Viewport:ClearViewport(Viewport)
	local viewportToClear = Viewport
	if Viewport == nil then
		viewportToClear = self.Frame
	end
	--[[for i,v in pairs(self.ShowingInExplorer) do
		v:Destroy()
	end]]
	local childrenToDestroy = viewportToClear:GetChildren()
	spawn(function()
		for i,v in pairs(childrenToDestroy) do
			if v:IsA("Frame") then
				v.Parent = nil
			end
		end
		for i,v in pairs(childrenToDestroy) do
			if v:IsA("Frame") then
				v:Destroy()
				wait()
			end
		end
	end)
	self.ShowingInExplorer = {}
end

function Viewport:Hide()

	self.Frame.Visible = false
	self.Visible = false
end

-- TODO: Don't re-render every time show is called
function Viewport:Show()
	if not self.Rendered then
		self:render()
	end
	self.Frame.Visible = true
	self.Visible = true
end

function Viewport:GetObjectsToDisplay(dir)
	local directory = dir or self.Directory
	local filterText = self:GetFilterText()
	local objectsToDo
	if directory == game then
		objectsToDo = {
			game:FindFirstChild("Workspace"),
			game:FindFirstChild("ServerStorage"),
			game:FindFirstChild("StarterGui"),
			game:FindFirstChild("StarterPlayer"),
			game:FindFirstChild("StarterPack"),
			game:FindFirstChild("Teams"),
			game:FindFirstChild("Players"),
			game:FindFirstChild("Chat"),
			game:FindFirstChild("LocalizationService"),
			game:FindFirstChild("ServerScriptService"),
			game:FindFirstChild("TestService"),
			game:FindFirstChild("Lighting"),
			game:FindFirstChild("ReplicatedStorage"),
			game:FindFirstChild("ReplicatedFirst"),
			game:FindFirstChild("SoundService"),
			game:GetService("CoreGui")
		}
	else
		objectsToDo = directory:GetChildren()
	end

	if string.len(filterText) > 0 then -- We want to search all descendants
		local obj = directory:GetDescendants()
		objectsToDo = {}
		for i,v in pairs(obj) do
			--If an objects' parent is BasePart or Model, then we say its part of the parent and isnt separate
			if not v.Parent:IsA("BasePart") and not v.Parent:IsA("Model") and self:ObjectPartOfFilter(v) then
				table.insert(objectsToDo, v)
			end
		end
	end
	return objectsToDo
end

function Viewport:ObjectInExplorer(object)
	return self.ShowingInExplorer[object] == true
end

function Viewport:SelectButton(objectButton)
	if self.CurrentlySelected and self.CurrentlySelected ~= objectButton then
		self.CurrentlySelected:SetSelected(false)
	end
	if objectButton == nil then
		Selection:Set({})
		self.CurrentlySelected = nil
		return
	end
	self.CurrentlySelected = objectButton
	--self.CurrentlySelected:SetSelected(true)
	Selection:Set({objectButton.Object})
end

--[[
function Viewport:SelectButton(objectButton)
	if Viewport.CurrentlySelected then
		Viewport.CurrentlySelected:SetSelected(false)
	end
	if objectButton == nil then
		Selection:Set({})
		Viewport.CurrentlySelected = nil
		return
	end
	Viewport.CurrentlySelected = objectButton
	Viewport.CurrentlySelected:SetSelected(true)

	if self.InsertModeEnabled then
		Viewport.CurrentlySelected:SetButtonColor(ButtonColors.SpecialSelected)
		ObjectPlacer:SetObjectToPlace(objectButton.Object)
	else
		ObjectPlacer:SetObjectToPlace(nil)
	end
	Selection:Set({objectButton.Object})
end
]]

return Viewport
