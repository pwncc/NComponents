local Selection = game:GetService("Selection")
_G.UserInputService = game:GetService("UserInputService")

local ExplorerUI = require(script.Parent.ExplorerUI)
local PropertiesModule = require(script.Parent.Properties)

-- Explorer
local explorerFrame = script.Parent.ExplorerFrame
ExplorerUI:init(explorerFrame, plugin)

local explorerInterface = plugin:CreateDockWidgetPluginGui(
    "ExplorerPlus",
    DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Float,
        true,
        true,
        400,
        500,
        300,
        300
    )
)

explorerInterface.Title = "Explorer"
explorerFrame.Parent = explorerInterface
explorerInterface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling



-- Properties
local propertiesToolbar = plugin:CreateToolbar("NComponents")
local explorerButton = propertiesToolbar:CreateButton("Explorer", "NComponents Explorer window (by SamTheMagician)", "rbxassetid://8493959982")
local propertiesButton = propertiesToolbar:CreateButton("Properties", "The properties window for NComponents", "rbxassetid://13044194710", "CompProperties")

local propertiesWidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, true, 300, 100)
local propertiesWindow = plugin:CreateDockWidgetPluginGui("NComponents", propertiesWidgetInfo) :: DockWidgetPluginGui
propertiesWindow.Title = "NComponent Properties"
propertiesWindow.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

propertiesButton.Click:Connect(function()
    propertiesWindow.Enabled = not propertiesWindow.Enabled
end)


explorerButton.Click:Connect(function()
    explorerInterface.Enabled = not explorerInterface.Enabled
    explorerButton:SetActive(explorerInterface.Enabled)
end)

explorerInterface.Changed:Connect(function()
    explorerButton:SetActive(explorerInterface.Enabled)
end)

local Properties = PropertiesModule.new(plugin, propertiesWindow)