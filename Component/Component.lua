
local CollectionService = game:GetService("CollectionService")
local NexusObject = require(script.Parent.NexusObject)

--[=[
    Base component class for the component service
    Extended from NexusObject (by NexusAvenger)

    @class Component
]=]
local Component = NexusObject:Extend()

Component:SetClassName("NComponent")

Component.__hiddenFields = {}

export type Component = {
    --Properties.
    class: {[string]: any},
    super: Component?,
    ClassName: string,
    
    InstanceObject: Instance,
    ID: string,


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

    @function SetClassName
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
    @function __new
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
]=]
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
    for i, v in pairs(self) do
        if not typeof(i) == "string" then
            continue
        end

        --Make sure this is not a private field
        if i:sub(1,1) == "_" then
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
        
        fields[i] = v
    end
    return fields
end

return Component :: Component