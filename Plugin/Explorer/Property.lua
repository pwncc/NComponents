local NexusObject = require(script.Parent.Parent.NexusObject)
local Property = NexusObject:Extend()
Property:SetClassName("Property")

function Property:__new(Header, PropertyName, PropertyValue)
    self.Header = Header
    self.Name = PropertyName
    self.Value = PropertyValue
    self.Type = typeof(PropertyValue)
end

function Property:CreateUI()
    self.UI = script.Parent.Parent.UIComps.Property:Clone() -- Updated UI reference
    self.UI.Parent = self.Header.UI.Properties -- Set the parent for the UI
    
    -- Set up UI components
    self.UI.PropertyName.Text = self.Name
    self.UI.PropertyValue.Text = tostring(self.Value)
    
    -- Connect property value change event
    self.UI.PropertyValue.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            self:UpdateValue(self.UI.PropertyValue.Text)
        end
    end)
end

function Property:UpdateValue(newValue)
    local isValid = false

    if self.Type == "number" then
        local numValue = tonumber(newValue)
        if numValue ~= nil then
            newValue = numValue
            isValid = true
        end
    elseif self.Type == "boolean" then
        if newValue:lower() == "true" or newValue:lower() == "false" then
            newValue = newValue:lower() == "true"
            isValid = true
        end
    elseif self.Type == "string" then
        isValid = true
    end

    if isValid then
        self.Value = newValue
        self.Header.Component:PropertyChanged(self.Name, newValue)
    else
        self.UI.PropertyValue.Text = tostring(self.Value) -- Revert to the original value if the input is invalid
    end
end

return Property