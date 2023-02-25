local Menu = plugin:CreatePluginMenu(math.random(), "NComponents", "")
local addComponentButton = Menu:AddNewAction(math.random(), "Add Component")

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 300, 100)
local addComponentWindow = plugin:CreateDockWidgetPluginGui("Add Component", widgetInfo)
script.Frame:Clone().Parent = addComponentWindow

local ComponentService = require(game:GetService("ReplicatedStorage").Component.ComponentService)

addComponentButton.Triggered:Connect(function()
    addComponentWindow.Enabled = true
end)

