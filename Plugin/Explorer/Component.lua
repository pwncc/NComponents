local NexusObject = require(script.Parent.Parent.NexusObject)
local PluginUtils = require(script.Parent.Parent.PluginUtils)
local Header = require(script.Parent.Header)

local Component = NexusObject:Extend()
Component:SetClassName("Component")

function Component:__new(Explorer, ComponentName, SettingsModule )
    self.UI = script.Parent.Parent.UIComps.Component:Clone()
    self.UI.Parent = Explorer.UI.Components

    self.Explorer = Explorer
    self.ComponentName = ComponentName;
    self.RealComponent = PluginUtils.GetComponentByName(ComponentName) :: ModuleScript
    self.Plugin = Explorer.Plugin
    self.AttachedModule = SettingsModule
    self.Component = loadstring(self.RealComponent.Source)()

    self.UI.TopBar.ComponentName.Text = ComponentName

    self.ComponentFields = self.Component:_getFields()

    self:CreateHeader()
end

function Component:CreateHeader()
    local newHeader = Header.new(self)
end

function Component:PropertyChanged(PropertyName, Value)
    self.ComponentFields[PropertyName] = Value
    self:UpdateSettings()
end

function Component:UpdateSettings()
    local ModuleSettings = self.AttachedModule
    local lua = "local ComponentSettings = {}"
    lua ..= "\nComponentSettings.ComponentName = "..PluginUtils.ValueToString(self.Component.ClassName).." -- ClassName used by ComponentService. Do not modify\n"

    for FieldName,Value in pairs(self.ComponentFields) do
        lua ..= "ComponentSettings."..FieldName.. " = "..PluginUtils.ValueToString(Value).."\n"
    end

    lua ..= "\nreturn ComponentSettings"

    ModuleSettings.Source = lua
    ModuleSettings:SetAttribute("Component", true)
end


return Component