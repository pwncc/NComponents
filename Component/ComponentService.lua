--[=[
	Handles all the components and setup

	@class ComponentService
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

--[=[
	Holds all the components, indexed by their names.
	This is automatically filled when [InitializeGame](/api/ComponentService#InitializeGame) is called.
	@readonly
	@prop _componentTypes table
	@within ComponentService
]=]
ComponentService._componentTypes = {} :: table

--[=[
	Initializes the game. This should be called on both client and server, if you use the server for Components.

	@param Components table -- A list of components that the service should load. These can later be used to create components using [InitializeGame](/api/ComponentService#AddComponent) or [InitializeGame](/api/ComponentService#GetComponent)
]=]
function ComponentService.InitializeGame(Components : table)
    game.DescendantAdded:Connect(ComponentService._gameObjectAdded)
end

--[=[
	Adds a new component to the Object.
	@return Component
]=]
function ComponentService.AddComponent(ComponentName : string, Object : Instance)

end

--[=[
	Gets a component attached to the Object.
	@return Component
]=]
function ComponentService.GetComponent(ComponentName : string, Object : Instance)

end

--[=[
	Gets all components attached to the Object of type <string>ComponentName.
	ComponentName should be the [ClassName](/api/Component#ClassName) of the component
	@return Component
]=]
function ComponentService.GetComponentsOfType(ComponentName : string, Object : Instance)

end

function ComponentService.GetComponents(Object : Instance)

end

function ComponentService.FindObjectsOfType(ComponentName : string)

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