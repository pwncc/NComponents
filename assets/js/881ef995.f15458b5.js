"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[873],{10044:e=>{e.exports=JSON.parse('{"functions":[{"name":"InitializeGame","desc":"Initializes the game. This should be called on both client and server, if you use the server for Components.","params":[{"name":"Components","desc":"A list of components that the service should load. These can later be used to create components using [InitializeGame](/api/ComponentService#AddComponent) or [InitializeGame](/api/ComponentService#GetComponent)","lua_type":"table"}],"returns":[],"function_type":"static","source":{"line":36,"path":"Component/ComponentService.lua"}},{"name":"AddComponent","desc":"Adds a new component to the Object.","params":[{"name":"ComponentName","desc":"","lua_type":"string"},{"name":"Object","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"Component"}],"function_type":"static","source":{"line":44,"path":"Component/ComponentService.lua"}},{"name":"GetComponent","desc":"Gets a component attached to the Object.","params":[{"name":"ComponentName","desc":"","lua_type":"string"},{"name":"Object","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"Component"}],"function_type":"static","source":{"line":52,"path":"Component/ComponentService.lua"}},{"name":"GetComponentsOfType","desc":"Gets all components attached to the Object of type <string>ComponentName.\\nComponentName should be the [ClassName](/api/Component#ClassName) of the component","params":[{"name":"ComponentName","desc":"","lua_type":"string"},{"name":"Object","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"Component"}],"function_type":"static","source":{"line":61,"path":"Component/ComponentService.lua"}}],"properties":[{"name":"_componentTypes","desc":"Holds all the components, indexed by their names.\\nThis is automatically filled when [InitializeGame](/api/ComponentService#InitializeGame) is called.","lua_type":"table","readonly":true,"source":{"line":29,"path":"Component/ComponentService.lua"}}],"types":[],"name":"ComponentService","desc":"Handles all the components and setup","source":{"line":6,"path":"Component/ComponentService.lua"}}')}}]);