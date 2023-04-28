local module = {}


function module:CreatePluginMenu(object, displayPasteInto)
	if self.pluginMenu then
		self.pluginMenu:Clear()
	end
	
	for i,v in pairs(self.PluginActions) do
		if object:IsA(i) then
			for i,m in pairs(v) do
				self.pluginMenu:AddAction(m)
			end
			self.pluginMenu:AddSeparator()
			break
		end
	end
	
	for i,v in pairs(self.DefaultPluginActions) do
		if not displayPasteInto and v.Text == "Paste Into" then
			continue
		end
		self.pluginMenu:AddAction(v)
	end
	self.pluginMenu:AddSeparator()
	self.pluginMenu:AddAction(self.PluginActions.Other.InsertObject)
end

function module:Display(object, callback, displayPasteInto)
	self:CreatePluginMenu(object, displayPasteInto)
	callback(self.pluginMenu:ShowAsync())
end

function module:Init(plugin)
	self.plugin = plugin

	local pluginMenu = self.plugin:CreatePluginMenu(math.random(), "Context Menu")
	pluginMenu.Name = "Explorer+ Context Menu"
	
	local openAction = pluginMenu:AddNewAction("Open", "Open")
	self.PluginActions = {
		Script = {
			openAction
		},
		ModuleScript = {
			openAction
		},
		LocalScript = {
			openAction
		},
		Other = {
			InsertObject = pluginMenu:AddNewAction("InsertObject", "Insert Object...")
		}
	}
	
	self.DefaultPluginActions = {
		pluginMenu:AddNewAction("Cut", "Cut", ""),
		pluginMenu:AddNewAction("Copy", "Copy", ""),
		pluginMenu:AddNewAction("Paste Into", "Paste Into", ""),
		pluginMenu:AddNewAction("Duplicate", "Duplicate", ""),
		pluginMenu:AddNewAction("Delete", "Delete", ""),
		pluginMenu:AddNewAction("Rename", "Rename", "")
	}
	self.pluginMenu = pluginMenu
end

return module
