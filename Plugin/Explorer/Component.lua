local NexusObject = require(script.Parent.Parent.NexusObject)
local PluginUtils = require(script.Parent.Parent.PluginUtils)
local Header = require(script.Parent.Header)

local Component = NexusObject:Extend()
Component:SetClassName("Component")

local function len(t)
    local n = 0

    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

function Component:__new(Explorer, ComponentName, SettingsModule )
    self.UI = script.Parent.Parent.UIComps.Component:Clone()
    self.UI.Parent = Explorer.UI.Components

    self.Explorer = Explorer
    self.ComponentName = ComponentName;
    self.RealComponent = PluginUtils.GetComponentByName(ComponentName) :: ModuleScript
    self.Plugin = Explorer.Plugin
    self.AttachedModule = SettingsModule

    self.Component = loadstring(self.RealComponent.Source)()
    self.LoadedSettings = loadstring(self.AttachedModule.Source)()

    --Remove values that should not be handled by us.
    self.LoadedSettings["ComponentName"] = nil;

    self.UI.TopBar.ComponentName.Text = ComponentName

    self.ComponentFields = self.Component:_getFields()

    self:CreateHeader()
end

function Component:CreateHeader()
    local Comps = {}
    local allPartOfHeader = {}
    if self.Component._headers == nil then
        self.Component._headers = {}
    end
    for i, v in pairs(self.Component._headers) do
        for i2, value in pairs(v) do
            allPartOfHeader[value] = true
        end
    end
    
    if len(allPartOfHeader) < len(self.ComponentFields) then
        self.Component._headers["Unsorted"] = {}
        for i, v in pairs(self.ComponentFields) do 
            if allPartOfHeader[i] == nil then
                table.insert(self.Component._headers["Unsorted"], i)
            end
        end
    end

    for headerName, _ in pairs(self.Component._headers or {}) do
        local newHeader = Header.new(self, headerName)
    end
end

function Component:PropertyChanged(PropertyName, Value)
    self.LoadedSettings[PropertyName] = Value
    self:UpdateSettings()
end

function Component:UpdateSettings()
    local ModuleSettings = self.AttachedModule
    local lua = "local ComponentSettings = {}"
    lua ..= "\nComponentSettings.ComponentName = "..PluginUtils.ValueToString(self.Component.ClassName).." -- ClassName used by ComponentService. Do not modify\n"

    for FieldName,Value in pairs(self.LoadedSettings) do
        lua ..= "ComponentSettings."..FieldName.. " = "..PluginUtils.ValueToString(Value).."\n"
    end

    lua ..= "\nreturn ComponentSettings"

    ModuleSettings.Source = lua
    ModuleSettings:SetAttribute("Component", true)
end

function Component:Dispose()
    self.UI:Destroy()
    self = nil
end


return Component