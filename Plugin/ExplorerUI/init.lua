local assets
local module = {}
local AssetsViewport = require(script.AssetViewport)
local RightClickMenu = require(script.RightClickMenu)
local ObjectPlacer = require(script.ObjectPlacer)
local UserInputService = game:GetService("UserInputService")
local Stack = require(script.Stack)
local ViewportResize= require(script.ViewportResize)
local SettingsMenu = require(script.SettingsMenu)
local ViewportObject = require(script.AssetViewport.ViewportObject)

local frame = nil
local DirectoryTextLabel = nil

function GetDirectoryText()
	return AssetsViewport.Directory.Name
	--return AssetsViewport.Directory.Parent.Name --string.gsub(AssetsViewport.Directory:GetFullName(), "%.", " / ")
end

function UpdateDirectoryLabel()
	DirectoryTextLabel.Text = GetDirectoryText()
end

UserInputService.InputBegan:Connect(function(input:InputObject)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.T then
			local ToggleZoom = frame:FindFirstChild("ToggleInsertMode", true)
			ToggleZoom:SetAttribute("Value", not ToggleZoom:GetAttribute("Value"))
		end
	end
end)

local CurrentDirectory
local DirectoryStack = Stack.new()
function module:init(frameRef, plugin)
	frame = frameRef
	
	CurrentDirectory = game
	local str = plugin:GetSetting(game.GameId .. "Directory")
	DirectoryStack:push(CurrentDirectory)
	RightClickMenu:Init(plugin)
	
	ViewportResize:init(frame, function(bol)
		if bol then
			plugin:GetMouse().Icon = "rbxasset://SystemCursors/SizeEW"
		else
			plugin:GetMouse().Icon = "rbxasset://SystemCursors/Arrow"
		end
	end)
	
	AssetsViewport:init({
		Directory = CurrentDirectory,
		Frame = frameRef,
		Plugin = plugin
	})
	
	AssetsViewport.DirectoryChanged:Connect(function()
		DirectoryStack:push(CurrentDirectory)
		CurrentDirectory = AssetsViewport.Directory
		plugin:SetSetting(game.GameId .. "Directory", CurrentDirectory:GetFullName())
		UpdateDirectoryLabel()
	end)
	
	DirectoryTextLabel = frame:FindFirstChild("DirectoryLabel", true)
	
	UpdateDirectoryLabel()
	
	
	-- Load the saved directory
	if str ~= nil then
		local p = game
		for i,v in pairs(string.split(str, ".")) do
			if p:FindFirstChild(v) ~= nil then
				p = p[v]
				AssetsViewport:UpdateDirectory(p)
				wait()
			end
		end
	end
	
	
	frame:FindFirstChild("DirectoryBackButton", true).MouseButton1Click:connect(function()
		local CurrentDirectory = DirectoryStack:pop()
		if CurrentDirectory == nil and AssetsViewport.Directory.Parent ~= nil then
			CurrentDirectory = AssetsViewport.Directory.Parent
		elseif AssetsViewport.Directory.Parent == nil then
			return
		end
		AssetsViewport:UpdateDirectory(CurrentDirectory)
		DirectoryStack:pop() -- get rid of new directoy that was stacked
		--AssetsViewport:UpdateDirectory(AssetsViewport.Directory.Parent)
	end)
	
	local UIGridLayout = frame:FindFirstChild("UIGridLayout", true)
	
	local ToggleAutoGrid = frame:FindFirstChild("ToggleAutoGrid", true)
	ToggleAutoGrid:GetAttributeChangedSignal("Value"):Connect(function(val)
		local value = ToggleAutoGrid:GetAttribute("Value")
		ObjectPlacer:ToggleAutoGrid(value)
	end)

	local ToggleStampMode = frame:FindFirstChild("ToggleStampMode", true)
	local ToggleInsertMode = frame:FindFirstChild("ToggleInsertMode", true)
	local viewportZoomSave = plugin:GetSetting("ViewportZoom")
	if viewportZoomSave == nil then
		viewportZoomSave = 0.5
	end
	
	ToggleStampMode:GetAttributeChangedSignal("Value"):Connect(function(val)
		local value = ToggleStampMode:GetAttribute("Value")
		AssetsViewport:ToggleStampMode(value)
		if val == true then
			plugin:Activate(true)
		else
			plugin:Activate(false)
			plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new(0,0,0,0))
		end
	end)
	
	ToggleInsertMode:GetAttributeChangedSignal("Value"):Connect(function(val)
		local value = ToggleInsertMode:GetAttribute("Value")
		AssetsViewport:ToggleInsertMode(value)
	end)
	
	local viewportZoom = frame:FindFirstChild("ViewportZoom", true)
	viewportZoom:SetAttribute("Value", viewportZoomSave)
	UIGridLayout.CellSize = UDim2.new(0, 40 + viewportZoomSave*100, 0, 40+ viewportZoomSave*100, 0)
	viewportZoom:GetAttributeChangedSignal("Value"):Connect(function(val)
		val = viewportZoom:GetAttribute("Value")
		plugin:SetSetting("ViewportZoom", val) 
		local val = viewportZoom:GetAttribute("Value")
		if val <= 0.01 and AssetsViewport.ViewportMode == "Grid" then
			AssetsViewport:EnableListView()
		elseif val > 0.01 and AssetsViewport.ViewportMode == "List" then
			AssetsViewport:EnableGridView()
		end
		UIGridLayout.CellSize = UDim2.new(0, 40 + val*100, 0, 40+ val*100, 0)
	end)

	SettingsMenu.SettingChanged:Connect(function(setting, value)
		if setting == "SideBySideEnabled" then
			AssetsViewport:ToggleSideBySide(value)
		elseif setting == "LazyLoad" then
			ViewportObject:ToggleLazyLoading(value)
		elseif setting == "RenderListViewThumbnails" then
			ViewportObject:ToggleListThumbnailRendering(value)
			AssetsViewport:ForceRender()
		elseif setting == "RenderGridViewThumbnails" then
			ViewportObject:ToggleGridThumbnailRendering(value)
			AssetsViewport:ForceRender()
		end
	end)
	SettingsMenu:Init(frame, plugin)
end

return module
