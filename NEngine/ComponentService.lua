--[=[
	Handles all the components and setup

	@class ComponentService
]=]


local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Component = require(script.Parent.Component)

local IsServer = RunService:IsServer()

--CONSTANTS
local COMPONENT_BASE_NAME = IsServer and "SC" or "CC"

--SERVICE
local ComponentService = {}

--CONFIG

ComponentService.CheckDescendants = true;
ComponentService.ComponentFolders = {
	--Add your component folders here. EX: game.ReplicatedStorage.src.Components
	game.ReplicatedStorage.Common
}


--[=[
	Whether the service should check descendants for all the folders in ComponentFolders.
	When false, the service will check for children instead.

	default = [true]()
	@prop CheckDescendants bool
	@within ComponentService
	@tag Configuration
]=]

--[=[
	A table with all the 

	default = [true]()
	@prop ComponentFolders table
	@within ComponentService
	@tag Configuration
]=]


--[=[
	A dictionary of all components existant in the world indexed by their type
	@prop ComponentsByType table
	@within ComponentService
	@readonly
]=]
ComponentService.ComponentsByType = {}

--[=[
	A dictionary of all components existant in the world indexed by their ID
	@prop ComponentsByID table
	@within ComponentService
	@readonly
]=]
ComponentService.ComponentsByID = {}

--[=[
	A dictionary of all components attached to an instance
	@prop ComponentsByInstance table
	@within ComponentService
	@readonly
]=]
ComponentService.ComponentsByInstance = {}

--[=[
	A dictionary of all components attached to an instance, sorted by their type
	@prop ComponentsByInstanceType table
	@within ComponentService
	@readonly
]=]
ComponentService.ComponentsByInstanceType = {}

--[=[
	Holds all the components, indexed by their names.
	This is automatically filled when [InitializeGame](/api/ComponentService#InitializeGame) is called.
	@private
	@prop _componentTypes table
	@within ComponentService
]=]
ComponentService._componentTypes = {} :: table

--[=[
	Initializes the game. This should be called on both client and server, if you use the server for Components.
	You can optionally provide your own Component Folders, if you're not using the configuration.
	@param ComponentFolders table? -- A list of components that the service should load. These can later be used to create components using [InitializeGame](/api/ComponentService#AddComponent) or [InitializeGame](/api/ComponentService#GetComponent)
]=]
function ComponentService.InitializeGame(ComponentFolders: table?)
	ComponentFolders = ComponentFolders or ComponentService.ComponentFolders

	assert(ComponentFolders, "ComponentFolders is nil! Make sure you have a valid Configuration or are passing valid component folders in the paramters")
	assert(#ComponentFolders > 0, "There are no component folders. Make sure you have a valid Configuration or are passing valid component folders in the parameters")

	for _, Folder in pairs(ComponentFolders) do
		assert(Folder, "Folder does not exist! Check your configuration")

		local Instances = ComponentService.CheckDescendants and Folder:GetDescendants() or Folder:GetChildren()

		for _, Module in pairs(Instances) do
			if not Module:IsA("ModuleScript") then continue end

			local newComp = require(Module) :: Component.Component
			assert(ComponentService._componentTypes[newComp.ClassName] == nil, "Component with name ".. newComp.ClassName .. "Already exists. Make sure you do not have duplicate components")
			
			ComponentService._componentTypes[newComp.ClassName] = newComp
		end
	end

	game.DescendantAdded:Connect(ComponentService._gameObjectAdded)
	ComponentService._scanGame()
end

--[=[
	Adds a new component to the Object.

	@param ... any -- Any parameters that you want to pass into the Components constructor [(__new)](/api/Component#__new)
	@return Component
]=]
function ComponentService.AddComponent(ComponentName : string, InstanceObject : Instance, ... : any)
	return ComponentService._instantiate(ComponentName, InstanceObject, {}, ...)
end

--[=[
	Gets a component attached to the Object.
	@return Component
]=]
function ComponentService.GetComponent(ComponentName : string, InstanceObject : Instance)
	if not ComponentService.ComponentsByInstanceType[InstanceObject] or 
		not ComponentService.ComponentsByInstanceType[InstanceObject][ComponentName] then
		return nil
	end

	return ComponentService.ComponentsByInstanceType[InstanceObject][1]
end

--[=[
	Gets all components attached to the Object of type <string>ComponentName.
	ComponentName should be the [ClassName](/api/Component#ClassName) of the component
	@return Component
]=]
function ComponentService.GetComponentsOfType(ComponentName : string, InstanceObject : Instance)
	if not ComponentService.ComponentsByInstanceType[InstanceObject] or 
		not ComponentService.ComponentsByInstanceType[InstanceObject][ComponentName] then
		return nil
	end

	return ComponentService.ComponentsByInstanceType[InstanceObject]
end

--[=[
	Gets all components attached to the Object.
	@return {Component}
]=]
function ComponentService.GetComponents(InstanceObject : Instance)
	return ComponentService.ComponentsByInstance[InstanceObject]
end

--[=[
	Gets all components of type ComponentName.
	ComponentName should be the [ClassName](/api/Component#ClassName) of the component
	@return {Component}
]=]
function ComponentService.FindComponentsOfType(ComponentName : string)
	return ComponentService.ComponentsByType[ComponentName]
end


--PRIVATE GAME HANDLING

function ComponentService._scanGame()
	for _, v : ModuleScript in pairs(game:GetDescendants()) do
		if not v:IsA("ModuleScript") then continue end
		if not v:GetAttribute("Component") then continue end

		local Settings = require(v)
		ComponentService._instantiate(Settings.ComponentName, v.Parent, Settings)
	end
end

--[=[
	Instantiates a new Component.
	@private
	@return Component
]=]
function ComponentService._instantiate(ComponentName : string, InstanceObject : Instance, Settings : table, ... : any)
	assert(ComponentService._componentTypes[ComponentName], "No component of type " ..ComponentName.. " exists")

	local newComponent = ComponentService._componentTypes[ComponentName]

	--If the object is dormant then go to instantiateStatic
	if newComponent.Dormant then
		ComponentService._instantiateStatic(ComponentName, InstanceObject, Settings)
	else
		ComponentService._registerComponent(newComponent, InstanceObject, ...)
		newComponent.new(...)
		newComponent.Initialized = true;
	end

	return newComponent
end

--[=[
	Instantiates a new Component without constructing it.
	Used for static Components attached to existing objects.
	@private
	@return Component
]=]
function ComponentService._instantiateStatic(ComponentName : string, InstanceObject : Instance, ComponentSettings : table)

	local newComponent : Component.Component = ComponentService._componentTypes[ComponentName].__newNoCtor(InstanceObject)

	--Set our component's settings correctly
	ComponentSettings["ComponentName"] = nil
	newComponent["_fromStatic"] = true
	
	for i, v in pairs(ComponentSettings) do
		newComponent[i] = v
	end

	local function checkDormancyWhitelist()
		--Check if we are a descendant of an a whitelisted ancestor. If so we can instantiate immediately.
		for _, v in pairs(newComponent.DormancyWhiteList) do
			if not newComponent._isDormant then
				return
			end

			if InstanceObject:IsDescendantOf(v) then
				ComponentService._registerComponent(newComponent, InstanceObject)
				newComponent:__new()

				newComponent._isDormant = false
				newComponent.Initialized = true
				return true
			end
		end
	end

	if not checkDormancyWhitelist() then
		local AncestryConnection
		AncestryConnection = InstanceObject.AncestryChanged:Connect(function()
			local isGood = checkDormancyWhitelist()
			if isGood then
				AncestryConnection:Disconnect()
				checkDormancyWhitelist = nil
			end
		end)
	end
	return newComponent
end

function ComponentService._registerComponent(ComponentToReg : Component.Component, InstanceObject : Instance)
	if not ComponentService.ComponentsByInstance[InstanceObject] then
		ComponentService.ComponentsByInstance[InstanceObject] = {}
		ComponentService.ComponentsByInstanceType[InstanceObject] = {}
	end

	if not ComponentService.ComponentsByInstanceType[InstanceObject][ComponentToReg.ClassName] then
		ComponentService.ComponentsByInstanceType[InstanceObject][ComponentToReg.ClassName] = {}
	end

	if not ComponentService.ComponentsByType[ComponentToReg.ClassName] then
		ComponentService.ComponentsByType[ComponentToReg.ClassName] = {}
	end

	ComponentService.ComponentsByID[ComponentToReg.ID] = Component
	table.insert(ComponentService.ComponentsByInstance[InstanceObject], ComponentToReg)
	table.insert(ComponentService.ComponentsByInstanceType[InstanceObject][ComponentToReg.ClassName], ComponentToReg)
	table.insert(ComponentService.ComponentsByType[ComponentToReg.ClassName], ComponentToReg)

end

function ComponentService._componentDestroyed(ID)
	local Component = ComponentService.ComponentsDict[ID]
	assert(Component, "Attempting to destroy a component that does not exist. Cannot dispose properly, connections might stay")

	Component.Dispose()
	ComponentService.ComponentsDict[ID] = nil;
end

--[=[
	Fired when an instance is added to the game.
	This is used to create components on newly created objects.
	@private
]=]
function ComponentService._gameObjectAdded(Object : Instance)
	if not Object:IsA("ModuleScript") then return end
	if not Object:GetAttribute("Component") then return end

	local Settings = require(Object)
	ComponentService._instantiate(Settings.ComponentName, Object.Parent, Settings)
end

return ComponentService;