
local CollectionService = game:GetService("CollectionService")
local NexusObject = require(script.Parent.NexusObject)

local FIELD_BLACKLIST = {
    ["Dormant"]=1;
    ["__hiddenFields"]=2;
    ["DormancyWhiteList"]=3;
}

--[=[
    Base component class for the component service
    Extended from NexusObject (by NexusAvenger)

    @class Component
]=]


--[=[
    The instance this Component is attached to.

    @prop InstanceObject Instance
    @within Component
]=]

--[=[
    The classname of this component.
    You should always set this to the name of the file so that Intellisense can find it using the RobloxLSP plugin.
    
    #Can be set using [SetClassName](/api/Component#SetClassName)

    @prop ClassName string
    @within Component
    @readonly
]=]

--[=[
    Sets the classname of this component.
    You should always set this to the name of the file so that Intellisense can find it using the RobloxLSP plugin.

    ```lua
        local TestComponent = Component:Extend()
        TestComponent:SetClassName("TestComponent")

        print(TestComponent:IsA("TestComponent")) -- true
    ```

    @method SetClassName
    @param ClassName string
    @within Component
]=]

--[=[
    The component's unique identifier.
    This is used by ComponentService to identify or find the component.

    @prop ID string
    @within Component
]=]

--[=[
    Overiddable constructor.
    ```lua
    local lamp = Component:Extend()
    function lamp:__new(Brightness : Number)
        Component.__new(self)
        self.Light.Brightness = Brightness
    end
    ```
    @method __new
    @param ... any -- The parameters you've specified
    @within Component
    @return Component
]=]

--[=[
    Allows you to extend the class into a new one.
    ```lua
    local lamp = Component:Extend()
    function lamp:Shine()
        lamp.LampObject.Enabled = true;
        print("oop doop")
    end

    local lamp2 = lamp:Extend()

    function lamp2:Shine()
        lamp.Shine(self)
        print("Lamp is shining!")
    end
    
    local l1 = lamp.new()
    local l2 = lamp2.new()

    l1:Shine()
    --output: 
    --oop doop

    l2:Shine()
    --output:
    --oop doop
    --Lamp is shining!

    ```
    For more info on NexusObject and how to use it: https://github.com/TheNexusAvenger/Nexus-Instance
    @method Extend
    @within Component
    @return Component
]=]

local Component = NexusObject:Extend()

Component:SetClassName("NComponent")

--[=[
    All the fields hidden by the HideField function
    @prop __hiddenFields table
    @within Component
    @private
]=]
Component.__hiddenFields = {}


--[=[
    Whether this component should only be used by the server.
    
    Default: [false]()
    @prop IsServerOnly bool
    @within Component
]=]
Component.IsServerOnly = false;

--[=[
    Whether this component should only be used by the client.
    
    Default: [false]()
    @prop IsServerOnly bool
    @within Component
]=]
Component.IsClientOnly = false;

--[=[
    Whether this component should be initialized immediately.
    This is useful if you have a component on an object that is not used.
    Example: A gun in replicatedstorage.
    
    Default: [true]()
    @prop Dormant bool
    @within Component
]=]
Component.Dormant = true;

--[=[
    A whitelist of parents that this component can initialize under.

    
    Default: [{workspace, game.Players, game.ReplicatedFirst}]()
    @prop DormancyWhiteList table
    @within Component
]=]
Component.DormancyWhiteList = {workspace, game.Players, game.ReplicatedFirst}

--[=[
    Whether this object was static

    @readonly
    @prop FromStatic bool
    @within Component
]=]
Component.FromStatic = false;

--[=[
    Whether this object was Initialized

    @readonly
    @prop Initialized bool
    @within Component
]=]
Component.Initialized = false;



export type Component = {
    --Properties.
    class: {[string]: any},
    super: Component?,
    ClassName: string,
    
    InstanceObject: Instance,
    ID: string,

    IsClientOnly: boolean,
    IsServerOnly: boolean,

    Dormant: boolean,
    DormancyWhiteList: table,


    [string]: any,

    --Static methods.
    new: () -> (Component),
    Extend: (self: Component) -> (Component),
    SetClassName: (self: Component, ClassName: string) -> (),

    --Methods.
    IsA: (self: Component, ClassName: string) -> (boolean),

    --Component methods
    HideField: (self: Component, FieldName: string) -> (),
    ShowField: (self: Component, FieldName: string) -> (),
}

function Component:Extend()
    return NexusObject.Extend(self)
end


--[=[
    Hides a field from the Component creator.
    When creating a new component from the creator plugin, the settings script will not include this field
]=]
function Component:HideField(FieldName : string)
    Component.__hiddenFields[FieldName] = true
end


--[=[
    Unhides a field from the Component creator.
    When creating a new component from the creator plugin, the settings script will return to including this field

    NOTE: You do not need to call this on all your fields, fields that are not hidden will automatically be shown
]=]
function Component:ShowField(FieldName : string)
    Component.__hiddenFields[FieldName] = nil
end

function Component:_getFields()
    local fields = {}
    local fieldstocheck = self
	while fieldstocheck ~= nil do
		print(fieldstocheck)
        for i, v in pairs(fieldstocheck) do
            if FIELD_BLACKLIST[i] then
                continue
            end

            if not typeof(i) == "string" then
                continue
            end

            --Make sure it's not apart of 
            if NexusObject[i] or i == "super" then
                continue
            end
            

            --Make sure it's not apart of nexusobject or the super class
            if NexusObject[i] or i == "super" then
                continue
            end

            --Make sure it's not a function, thats not a field :)
            if typeof(v) == "function" then
                continue
            end

            --Make sure it's not a hidden field
            if self.__hiddenFields[i] then
                continue;
            end

            --Dont allow the componentname to be changed or written. This is done internally
            if i == "ComponentName" then
                continue;
            end

            --Exclude the headers
            if i == "_headers" or i ==  "_currentHeader" then
                continue;
            end
            
            fields[i] = v
        end
        fieldstocheck = fieldstocheck.super
    end
    return fields
end


--[=[
    Gets called when the Component gets :Destroy() 'ed.
    You should remove all connections that this component has while getting destroyed so it can be collected by Garbage collection.
    NOTE: This might be done automatically however I'm not sure.
]=]
function Component:InstanceDestroyed()

end

return Component :: Component