local Selection = game:GetService("Selection")

local NexusObject = require(script.Parent.NexusObject)
local PluginUtils = require(script.Parent.PluginUtils)
local Component = require(script.Component)
local ComponentAdder = require(script.ComponentAdder)

local Explorer = NexusObject:Extend()

function Explorer:__new(plugin, PluginWindow : DockWidgetPluginGui)
    self.Plugin = plugin
    self.UI = script.Parent.MainFrame:Clone()

    self.UI.Parent = PluginWindow
    self.PluginWindow = PluginWindow

    self.AddComponentButton = self.UI.TopBar.AddButton

    self.ComponentAdder = ComponentAdder.new(plugin)

    self.AddComponentButton.MouseButton1Click:Connect(function()
        self.ComponentAdder:Toggle(true)
    end)

    self.ComponentsList = self.UI.Components
    Selection.SelectionChanged:Connect(function(...) self:newObjectSelected(Selection:Get()[1]) end) -- Changed [0] to [1] for 1-based indexing
end

function Explorer:newObjectSelected(object)
    self.SelectedObject = object
    self.SelectedObjectComps = PluginUtils.GetComponentsOnParts(object)
    
    if self.SelectedObjectComps == nil then
        warn("No components on this object!")
        return
    end

    for i, v in pairs(self.SelectedObjectComps) do
        local componentInstance = Component.new(self, v.Name, v) -- Pass necessary arguments to the constructor
    end
end

function Explorer:displayComponentAdder()

end

return Explorer