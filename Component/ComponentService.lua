--[=[
    Handles all the components and setup

	@class Components
]=]


local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local IsServer = RunService:IsServer()

--CONSTANTS
local COMPONENT_BASE_NAME = IsServer and "SC" or "CC"

--SERVICE
local ComponentService = {}

ComponentService.ComponentsDict = {}

ComponentService._componentTypes = {}


--[=[
	@class 
	@param componentClass ComponentClass
	@return Component?

	Retrieves another component instance bound to the same
	Roblox instance.

--]=]

function ComponentService.InitializeGame()
    game.DescendantAdded:Connect(ComponentService._gameObjectAdded)


end

function ComponentService.AddComponent(ComponentName, Object)

end

function ComponentService.GetComponent(ComponentName, Object)

end

function ComponentService.GetComponents(ComponentName, Object)

end

function ComponentService.FindObjectOfType(ComponentName)

end


--PRIVATE GAME HANDLING

function ComponentService._registerComponent(Component)
    Component.ID = HttpService:GenerateGUID();

    ComponentService.ComponentsDict[Component.ID] = Component
end

function ComponentService._componentDestroyed(ID)
    local Component = ComponentService.ComponentsDict[ID]
    assert(Component, "Attempting to destroy a component that does not exist. Cannot dispose properly, connections might stay")

    Component.Dispose()
    ComponentService.ComponentsDict[ID] = nil;
end

function ComponentService._gameObjectAdded(Object : Instance)
    if not Object:IsA("Configuration") or not Object.Name:find(COMPONENT_BASE_NAME) then return end
    local ComponentName = Object.Name


end

--PLUGIN STUFF

return ComponentService;