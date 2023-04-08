local Explorer = require(script.Parent.Explorer)
local Selection = game:GetService("Selection")

local ToolBar = plugin:CreateToolbar("NComponents")
local TBButton = ToolBar:CreateButton("Properties", "The properties window for NComponents", "CompProperties")

local Menu = plugin:CreatePluginMenu(math.random(), "NComponents")
Menu.Name = "Components"

local addComponentButton = Menu:AddNewAction(math.random(), "Add Component")

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, true, 300, 100)
local PropertiesWindow = plugin:CreateDockWidgetPluginGui("NComponents", widgetInfo) :: DockWidgetPluginGui
PropertiesWindow.Title = "NComponent Properties"
PropertiesWindow.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Explorer = Explorer.new(plugin, PropertiesWindow)

