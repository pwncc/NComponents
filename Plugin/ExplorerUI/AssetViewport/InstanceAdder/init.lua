local Signal = require(script.Parent.Signal)
local UserInputService = game:GetService("UserInputService")
local instangeGui = script.Instance
local InstancesFrame = script.Inserter.Instances
local MainFrame = script.Inserter
local SearchTextBox = MainFrame.TopBar.Search
MainFrame.Visible = false
local ThumbnailSetter = require(script.Parent.ThumbnailSetter)

local module = {
	OnInstanceClicked = Signal.new()
}

local priority = {
	["Script"] = 1,
	["LocalScript"] = 2,
	["Model"] = 3,
	["ModuleScript"] = 4,
	["Folder"] = 4,
}

local objects2 = {
	["3D Interfaces"] = {
		"ClickDetector",
		"Decal",
		"Dialog",
		"DialogChoice",
		"ProximityPrompt",
		"SurfaceAppearance",
		"Texture"
	},
	["Adornments"] = {
		"ArcHandles",
		"BoxHandleAdornment",
		"ConeHandleAdornment",
		"CylinderHandleAdornment",
		"Handles",
		"ImageHandleAdornment",
		"LineHandleAdornment",
		"PathfindingLink",
		"PathfindingModifier",
		"SelectionBox",
		"SelectionSphere",
		"SphereHandleAdornment",
		"SurfaceSelection"
	},
	["Animations"] = {
		"Animation",
		"AnimationController",
		"Animator",
		"Bone",
		"Motor6D"
	},
	["Avatar"] = {
		"Accessory",
		"BodyColors",
		"ForceField",
		"Humanoid",
		"Pants",
		"Shirt",
		"ShirtGraphic"
	},
	["Constraints"] = {
		"AlignOrientation",
		"AlignPosition",
		"AngularVelocity",
		"Attachment",
		"BallSocketConstraint",
		"CylindricalConstraint",
		"HingeConstraint",
		"LinearVelocity",
		"LineForce",
		"NoCollisionConstraint",
		"Plane",
		"PrismaticConstraint",
		"RigidConstraint",
		"RodConstraint",
		"RopeConstraint",
		"SpringConstraint",
		"Torque",
		"TorsionSpringConstraint",
		"UniversalConstraint",
		"VectorForce",
		"WeldConstraint"
	},
	["Effects"] = {
		"Beam",
		"Explosion",
		"Fire",
		"Highlight",
		"ParticleEmitter",
		"Smoke",
		"Sparkles",
		"Trail",
		"WrapLayer",
		"WrapTarget",
	},
	["Environment"] = {
		"Atmosphere",
		"Clouds",
		"Sky"
	},
	["GUI"] = {
		"BillboardGui",
		"Frame",
		"ImageButton",
		"ImageLabel",
		"ScreenGui",
		"ScrollingFrame",
		"SurfaceGui",
		"TextBox",
		"TextButton",
		"TextLabel",
		"UIAspectRatioConstraint",
		"UICorner",
		"UIGradient",
		"UIGridLayout",
		"UIListLayout",
		"UIPadding",
		"UIPageLayout",
		"UIScale",
		"UISizeConstraint",
		"UIStroke",
		"UITableLayout",
		"UITextSizeConstraint",
		"VideoFrame",
		"ViewportFrame",
	},
	["Interaction"] = {
		"Seat",
		"SpawnLocation",
		"Team",
		"Tool",
		"VehicleSeat"
	},
	["Legacy Body Movers"] = {
		"BodyAngularVelocity",
		"BodyForce",
		"BodyGyro",
		"BodyPosition",
		"BodyThrust",
		"BodyVelocity"
	},
	["Lights"] = {
		"PointLight",
		"SpotLight",
		"SurfaceLight"
	},
	["Localization"] = {
		"LocalizationTable"
	},
	["Meshes"] = {
		"BlockMesh",
		"CharacterMesh",
		"SpecialMesh"
	},
	["Parts"] = {
		"CornerWedgePart",
		"MeshPart",
		"Part",
		"TrussPart",
		"WedgePart"
	},
	["Post Processing Effects"] = {
		"BloomEffect",
		"BlurEffect",
		"ColorCorrectionEffect",
		"DepthOfFieldEffect",
		"SunRaysEffect",
	},
	["Scripting"] = {
		"BindableEvent",
		"BindableFunction",
		"LocalScript",
		"ModuleScript",
		"RemoteEvent",
		"RemoteFunction",
		"Script"
	},
	["Sounds"] = {
		"ChorusSoundEffect",
		"CompressorSoundEffect",
		"DistortionSoundEffect",
		"EchoSoundEffect",
		"EqualizerSoundEffect",
		"FlangeSoundEffect",
		"PitchShiftSoundEffect",
		"ReverbSoundEffect",
		"Sound",
		"SoundGroup",
		"TremoloSoundEffect"
	},
	["Uncategorized"] = {
		"Camera",
		"Configuration",
		"Folder",
		"HumanoidDescription",
		"Model",
		"Snap",
		"Weld"
	},
	["Values"] = {
		"BoolValue",
		"BrickColorValue",
		"CFrameValue",
		"Color3Value",
		"IntValue",
		"NumberValue",
		"ObjectValue",
		"RayValue",
		"StringValue",
		"Vector3Value"
	},
	["World"] = {
		"WorldModel"
	}
}

function module:Init(parent)
	local index = 0
	for cat,obj in pairs(objects2) do
		local separator = script.Separator:Clone()
		separator.FrequentlyUsed.Text = cat
		separator.LayoutOrder = index
		separator.Parent = InstancesFrame
		for i,v in pairs(obj) do
			local frameCopy = instangeGui:Clone()
			frameCopy.Name = v
			frameCopy.TextLabel.Text = v
			frameCopy.Image.Image = string.format("rbxthumb://type=Asset&id=%s&w=150&h=150", ThumbnailSetter:FindThumbnail(Instance.new(v)))
			frameCopy.MouseButton1Down:connect(function()
				self.OnInstanceClicked:Fire(v)
				Instance.new(v).Parent = self.ObjectToParentTo
			end)
			frameCopy.LayoutOrder = index
			frameCopy:SetAttribute("OriginalLayoutOrder", index)
			frameCopy.MouseEnter:connect(function()
				frameCopy.Transparency = 0.9
			end)
			frameCopy.MouseLeave:connect(function()
				frameCopy.Transparency = 1
			end)
			frameCopy.Parent = InstancesFrame

			index = index + 1
		end

	end

	SearchTextBox.Changed:Connect(function(prop)
		if prop == "Text" then
			local lowestIndex:TextButton = InstancesFrame:GetChildren()[10]
			for i,v in ipairs(InstancesFrame:GetChildren()) do
				if v:IsA("TextButton") then
					if SearchTextBox.Text == "" then
						v.Visible = true
						v.LayoutOrder = v:GetAttribute("OriginalLayoutOrder")
					elseif string.lower(v.Name):match(string.lower(SearchTextBox.Text)) then
						v.LayoutOrder = i
						v.Visible = true
						if priority[v.Name] then
							v.LayoutOrder = priority[v.Name]
						end
						
						if lowestIndex.LayoutOrder > v.LayoutOrder then
							lowestIndex = v
						end
					else
						v.Visible = false
					end
				elseif v:IsA("Frame") then
					if SearchTextBox.Text == "" then
						v.Visible = true
					else
						v.Visible = false
					end
				end
			end
		end
	end)
	MainFrame.Parent = parent
end

function module:Display(position, parent)
	SearchTextBox:CaptureFocus()
	self.ObjectToParentTo = parent
	MainFrame.Position = UDim2.new(0, position.X, 0, position.Y)
	MainFrame.Visible = true
end

function module:Hide()

	MainFrame.Visible = false
end





return module
