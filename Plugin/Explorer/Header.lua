local NexusObject = require(script.Parent.Parent.NexusObject)
local Property = require(script.Parent.Property)

local Header = NexusObject:Extend()
Header:SetClassName("Header")

function Header:__new(Component)
    self.Component = Component
    self.UI = script.Parent.Parent.UIComps.Header:Clone() -- Updated UI reference
    self.UI.Parent = Component.UI.Headers
    print(Component.ComponentFields)    
    for PropertyName, PropertyValue in pairs(Component.ComponentFields) do
        local propertyInstance = Property.new(self, PropertyName, Component.ComponentFields[PropertyName])
        propertyInstance:CreateUI() -- Create UI for each property
    end
end

return Header