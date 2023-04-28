local Signal = require(script.Parent.AssetViewport.Signal)
local module = {
	SettingChanged = Signal.new()
}
local settingsFrame = nil
local settingsButton = nil
local closeSettingsButton = nil

function module:Init(frame, plugin:Plugin)
	settingsFrame = frame.Settings
	closeSettingsButton = settingsFrame:FindFirstChild("CloseButton", true)
	settingsButton = frame:FindFirstChild("SettingsButton", true)
	
	local options = {
		settingsFrame:FindFirstChild("RenderGridViewThumbnails", true),
		settingsFrame:FindFirstChild("LazyLoad", true),
		settingsFrame:FindFirstChild("RenderListViewThumbnails", true),
		settingsFrame:FindFirstChild("SideBySideEnabled", true)
	}
	
	settingsButton.MouseButton1Click:Connect(function()
		settingsFrame.Visible = true
	end)
	
	closeSettingsButton.MouseButton1Click:Connect(function()
		settingsFrame.Visible = false
	end)
	
	-- Sets default values
	for i,v in pairs(options) do
		local value = plugin:GetSetting(v.Name)
		if value == nil then
			plugin:SetSetting(v.Name, v:GetAttribute("Value"))
		else
			v:SetAttribute("Value", value)
			self.SettingChanged:Fire(v.Name, value)
		end
	end
	
	for i,v:TextButton in pairs(options) do
		v:GetAttributeChangedSignal("Value"):Connect(function()
			local value = v:GetAttribute("Value")
			plugin:SetSetting(v.Name, value)
			self.SettingChanged:Fire(v.Name, value)
		end)
	end
end


return module
