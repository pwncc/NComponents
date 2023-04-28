local NexusObject = require(script.Parent.Parent.NexusObject)
local Property = require(script.Parent.Property)

local Header = NexusObject:Extend()
Header:SetClassName("Header")

function Header:__new(Component, headerName, headerless)
    headerless = headerless or false
    self.Component = Component
    self.UI = script.Parent.Parent.UIComps.Header:Clone() -- Updated UI reference
    self.UI.Parent = Component.UI.Headers
    self.UI.TopBar.HeaderName.Text = headerName -- Set header name
    self.PropertyInstances = {} -- New table to store property instances

    local headerProperties = Component.Component._headers[headerName]
    for _, PropertyName in pairs(headerProperties) do
        if not Component.ComponentFields[PropertyName] then
            continue
        end
        local propValue = Component.LoadedSettings[PropertyName] or Component.ComponentFields[PropertyName]
        local propertyInstance = Property.new(self, PropertyName, propValue)
        table.insert(self.PropertyInstances, propertyInstance) -- Store property instances
        propertyInstance:CreateUI() -- Create UI for each property
    end

    self.Component.Properties:addHeader(self)
end

-- New function to filter properties
function Header:filterProperties(filterText)
    for _, property in ipairs(self.PropertyInstances) do
        if property.Name:lower():find(filterText:lower()) then
            property.UI.Visible = true
        else
            property.UI.Visible = false
        end
    end
end

return Header