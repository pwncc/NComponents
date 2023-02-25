"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[815],{15038:n=>{n.exports=JSON.parse('{"functions":[{"name":"SetClassName","desc":"Sets the classname of this component.\\nYou should always set this to the name of the file so that Intellisense can find it using the RobloxLSP plugin.\\n\\n```lua\\n    local TestComponent = Component:Extend()\\n    TestComponent:SetClassName(\\"TestComponent\\")\\n\\n    print(TestComponent:IsA(\\"TestComponent\\")) -- true\\n```","params":[{"name":"ClassName","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":76,"path":"Component/Component.lua"}},{"name":"__new","desc":"Overiddable constructor.\\n```lua\\nlocal lamp = Component:Extend()\\nfunction lamp:__new(Brightness : Number)\\n    Component.__new(self)\\n    self.Light.Brightness = Brightness\\nend\\n```","params":[{"name":"...","desc":"The parameters you\'ve specified","lua_type":"any"}],"returns":[{"desc":"","lua_type":"Component"}],"function_type":"static","source":{"line":99,"path":"Component/Component.lua"}},{"name":"Extend","desc":"Allows you to extend the class into a new one.\\n```lua\\nlocal lamp = Component:Extend()\\nfunction lamp:Shine()\\n    lamp.LampObject.Enabled = true;\\n    print(\\"oop doop\\")\\nend\\n\\nlocal lamp2 = lamp:Extend()\\n\\nfunction lamp2:Shine()\\n    lamp.Shine(self)\\n    print(\\"Lamp is shining!\\")\\nend\\n\\nlocal l1 = lamp.new()\\nlocal l2 = lamp2.new()\\n\\nl1:Shine()\\n--output: \\n--oop doop\\n\\nl2:Shine()\\n--output:\\n--oop doop\\n--Lamp is shining!\\n\\n```\\nFor more info on NexusObject and how to use it: https://github.com/TheNexusAvenger/Nexus-Instance","params":[],"returns":[],"function_type":"method","source":{"line":131,"path":"Component/Component.lua"}},{"name":"HideField","desc":"Hides a field from the Component creator.\\nWhen creating a new component from the creator plugin, the settings script will not include this field","params":[{"name":"FieldName","desc":"","lua_type":"string"}],"returns":[],"function_type":"method","source":{"line":140,"path":"Component/Component.lua"}},{"name":"ShowField","desc":"Unhides a field from the Component creator.\\nWhen creating a new component from the creator plugin, the settings script will return to including this field\\n\\nNOTE: You do not need to call this on all your fields, fields that are not hidden will automatically be shown","params":[{"name":"FieldName","desc":"","lua_type":"string"}],"returns":[],"function_type":"method","source":{"line":151,"path":"Component/Component.lua"}}],"properties":[{"name":"InstanceObject","desc":"The instance this Component is attached to.","lua_type":"Instance","source":{"line":49,"path":"Component/Component.lua"}},{"name":"ClassName","desc":"The classname of this component.\\nYou should always set this to the name of the file so that Intellisense can find it using the RobloxLSP plugin.\\n\\n#Can be set using [SetClassName](/api/Component#SetClassName)","lua_type":"string","readonly":true,"source":{"line":60,"path":"Component/Component.lua"}},{"name":"ID","desc":"The component\'s unique identifier.\\nThis is used by ComponentService to identify or find the component.","lua_type":"string","source":{"line":84,"path":"Component/Component.lua"}}],"types":[],"name":"Component","desc":"Base component class for the component service\\nExtended from NexusObject (by NexusAvenger)","source":{"line":11,"path":"Component/Component.lua"}}')}}]);