local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local NexusObject = require(script.Parent.Parent.NexusObject)
local PluginUtils = require(script.Parent.Parent.PluginUtils) -- Replace with the path to your PluginUtils
local ComponentService = require(ReplicatedStorage.Component.ComponentService)
local ComponentAdder = NexusObject:Extend()
ComponentAdder:SetClassName("ComponentAdder")

function ComponentAdder:__new(plugin, Explorer)
    self.plugin = plugin
    self.Explorer = Explorer

    self.ComponentListUI = script.Parent.Parent.AdderFrame:Clone() -- Replace with the path to your UI
    self.ComponentButtonTemplate = script.Parent.Parent.UIComps.ComponentAdd
    
    self.FilterBar = self.ComponentListUI.TopBar.Searchbar.Frame.FilterTextbox -- Assuming the filter bar is named "FilterBar" in the UI

    self:populateComponentList()
    self:createPluginUI()
    self:setupFilterBar()
end

function ComponentAdder:populateComponentList(filterText)
    filterText = filterText or ""
    self:ClearComponentList()

    for _, component in ipairs(PluginUtils.getComponents()) do
        if component.Name:lower():find(filterText:lower()) then
            local button = self.ComponentButtonTemplate:Clone()
            button.Name = component.Name
            button.ComponentName.Text = component.Name
            button.Parent = self.ComponentListUI.Components
            
            button.Button.MouseButton1Click:Connect(function()
                self:addComponentToSelectedPart(component.Name)
            end)
        end
    end
end

function ComponentAdder:addComponentToSelectedPart(componentName)
    local selectedPart = game:GetService("Selection"):Get()[1]
    
    if not selectedPart then
        warn("No part selected!")
        return
    end
    
    -- Add the component to the part with default settings
    PluginUtils.AddComponentToPart(componentName, selectedPart)
    self:Toggle(false)
end

function ComponentAdder:createPluginUI()
    local PLUGIN_NAME = "Add Component"
    local PLUGIN_ID = "NComponentsAdder"


    local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 300, 150, 150)
    self.widget = self.plugin:CreateDockWidgetPluginGui(PLUGIN_ID, widgetInfo) :: DockWidgetPluginGui
    self.widget.Title = PLUGIN_NAME
    self.widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

   -- Get the Mouse object
   local mouse = self.plugin:GetMouse() :: PluginMouse

   -- Listen for mouse click events
   UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
       if not self.widget.Enabled then return end
       if gameProcessedEvent then return end

       -- Check if the input is a mouse button click
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
           local mousePos = Vector2.new(mouse.X, mouse.Y)
           local topLeft = self.widget.AbsolutePosition
           local bottomRight = self.widget.AbsolutePosition + self.widget.AbsoluteSize

           -- Check if the click is outside the widget
            if not (mousePos.X >= topLeft.X and mousePos.X <= bottomRight.X and mousePos.Y >= topLeft.Y and mousePos.Y <= bottomRight.Y) then
                self.widget.Enabled = false
            end
       end
   end)
    self.ComponentListUI.Parent = self.widget
end

function ComponentAdder:Toggle(bool)
    self.widget.Enabled = bool
end

function ComponentAdder:setupFilterBar()
    self.FilterBar:GetPropertyChangedSignal("Text"):Connect(function()
        self:populateComponentList(self.FilterBar.Text)
    end)
end

function ComponentAdder:ClearComponentList()
    for i, v in pairs(self.ComponentListUI.Components:GetChildren()) do
        if v:IsA("Frame") then
            v:Destroy()
        end
    end
end

return ComponentAdder
