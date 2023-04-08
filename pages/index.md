# NComponents
NComponents is a unity-like component system for roblox.

With NComponents you can create components as you would in Unity and attach them to Instances (GameObjects)
Components can be added into instances and objects via a Plugin. The ComponentService will automatically create these components on runtime or when the Instance is cloned / added.

## Usage
Creating NComponents can be done with the [Component:Extend()](api/Component#Extend) method
An example Component is:
```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local NComponent = require(ReplicatedStorage.Component.Component)

    local Example = NComponent:Extend()

    function Example:__new()
        print("We just got added to: "..NComponent.InstanceObject)
    end

    return Example
```
