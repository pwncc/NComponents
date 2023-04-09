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
    self.CurrentComponents = {}
    self.CurrentHeaders = {}

    self.AddComponentButton.MouseButton1Click:Connect(function()
        self.ComponentAdder:Toggle(true)
    end)

    self.ComponentsList = self.UI.Components
    Selection.SelectionChanged:Connect(function(...) self:newObjectSelected(Selection:Get()[1]) end)
end

function Explorer:newObjectSelected(object)
    for i, v in pairs(self.CurrentComponents) do
        v:Dispose() -- Dispose of all the components currently in the list. Otherwise they would duplicate every time we selected a new object.
    end

    self.SelectedObject = object
    self.SelectedObjectComps = PluginUtils.GetComponentsOnParts(object)
    
    if self.SelectedObjectComps == nil then
        warn("No components on this object!")
        return
    end

    for i, v in pairs(self.SelectedObjectComps) do
        local componentInstance = Component.new(self, v.Name, v) -- Pass necessary arguments to the constructor
        table.insert(self.CurrentComponents, componentInstance)
    end

    -- Filter functionality
    self:filterProperties(self.UI.TopBar.Searchbar.Frame.FilterTextbox.Text)
    self.UI.TopBar.Searchbar.Frame.FilterTextbox:GetPropertyChangedSignal("Text"):Connect(function()
        self:filterProperties(self.UI.TopBar.Searchbar.Frame.FilterTextbox.Text)
    end)
end

-- Filter the properties if there is text in the filter bar
function Explorer:filterProperties(filterText)
    for _, header in ipairs(self.CurrentHeaders) do
        header:filterProperties(filterText)
    end
end

function Explorer:addHeader(headerInstance)
    table.insert(self.CurrentHeaders, headerInstance)
end

return Explorer