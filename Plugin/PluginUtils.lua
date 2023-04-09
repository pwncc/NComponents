local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ComponentService = require(ReplicatedStorage.Component.ComponentService)
local PluginUtils = {}

PluginUtils.AllComponents = {}
PluginUtils.ComponentsByName = {}

-- Helper function to convert a table into a constructor string
local function tableToConstructorString(tbl)
    local str = "{"
    for k, v in pairs(tbl) do
        str = str .. "[" .. tostring(k) .. "] = " .. valueToConstructorString(v) .. ","
    end
    str = str .. "}"
    return str
end

-- Helper function to convert a value into a constructor string
function PluginUtils.ValueToString(value)
    local valueType = typeof(value)
    if valueType == "string" then
        return '"' .. value .. '"'
    elseif valueType == "number" then
        return tostring(value)
    elseif valueType == "Instance" then
        return "game:GetService('" .. value:GetService().Name .. "')" .. ":FindFirstChild('" .. value.Name .. "')"
    elseif valueType == "Vector3" then
        return "Vector3.new(" .. value.X .. ", " .. value.Y .. ", " .. value.Z .. ")"
    elseif valueType == "CFrame" then
        return "CFrame.new(" .. value:GetComponents() .. ")"
    elseif valueType == "UDim" then
        return "UDim.new(" .. value.Scale .. ", " .. value.Offset .. ")"
    elseif valueType == "UDim2" then
        return "UDim2.new(" .. value.X.Scale .. ", " .. value.X.Offset .. ", " .. value.Y.Scale .. ", " .. value.Y.Offset .. ")"
    elseif valueType == "Color3" then
        return "Color3.new(" .. value.r .. ", " .. value.g .. ", " .. value.b .. ")"
    elseif valueType == "BrickColor" then
        return "BrickColor.new('" .. tostring(value) .. "')"
    elseif valueType == "EnumItem" then
        return "Enum." .. tostring(value.EnumType) .. "." .. value.Name
    elseif valueType == "table" then
        return tableToConstructorString(value)
    elseif valueType == "boolean" then
        return value and "true" or "false"
    else
        error("Cannot convert value of type " .. valueType .. " to constructor string.")
    end
end


function PluginUtils.getComponents()
    local Components = {}
    for _, Folder in pairs(ComponentService.ComponentFolders) do
		assert(Folder, "Folder does not exist! Check your configuration")

		local Instances = ComponentService.CheckDescendants and Folder:GetDescendants() or Folder:GetChildren()

		for _, Module in pairs(Instances) do
			if not Module:IsA("ModuleScript") then continue end

			table.insert(Components, Module)
            PluginUtils.ComponentsByName[Module.Name] = Module
		end
	end
    PluginUtils.AllComponents = Components
    return Components
end

function PluginUtils.GetComponentByName(ComponentName)
    PluginUtils.getComponents()
    return PluginUtils.ComponentsByName[ComponentName]
end

function PluginUtils.GetComponentsOnParts(Object)
    PluginUtils.getComponents()
    local CompsOnPart = {}

    for i, v in pairs(Object:GetChildren()) do
        if not v:IsA("ModuleScript") then continue end
		if not v:GetAttribute("Component") then continue end

        table.insert(CompsOnPart, v)
    end

    return CompsOnPart
end

function PluginUtils.AddComponentToPart(ComponentName, objectToAddTo)
    local ModuleSettings = Instance.new("ModuleScript", objectToAddTo)
    local Component = loadstring(PluginUtils.GetComponentByName(ComponentName).Source)()
    assert(Component, "No such component exists: " .. ComponentName)

    local lua = "local ComponentSettings = {}"
    lua ..= "\nComponentSettings.ComponentName = "..PluginUtils.ValueToString(Component.ClassName).." -- ClassName used by ComponentService. Do not modify\n"

    for FieldName,Value in pairs(Component:_getFields()) do
        lua ..= "ComponentSettings."..FieldName.. " = "..PluginUtils.ValueToString(Value).."\n"
    end

    lua ..= "\nreturn ComponentSettings"

    ModuleSettings.Source = lua
    ModuleSettings.Name = ComponentName
    ModuleSettings:SetAttribute("Component", true)
end

return PluginUtils