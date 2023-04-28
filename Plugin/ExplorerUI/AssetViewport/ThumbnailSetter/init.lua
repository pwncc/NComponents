local module = {}

local ViewportFrameGetter = require(script.ViewportFrameGetter)

local cache = {}

local icons = {
	Image=8493965127,
	Accessory=8493964556,
	Actor=8493964465,
	AlignOrientation=8493964371,
	AlignPosition=8493964272,
	Animation=8493964172,
	Animator=8493964172,
	AnimationController=8493964172,
	ArcHandles=8493964082,
	Attachment=8493963953,
	Backpack=8493963861,
	StarterPack=8493963861,
	BallSocketConstraint=8493963745,
	BasePart=8493963619,
	Part=8493963619,
	Beam=8493963482,
	BillboardGui=8493963298,
	BindableEvent=8493963123,
	BindableFunction=8493962999,
	BodyMover=8493962901,
	Bone=8493962812,
	BoxHandleAdornment=8493962714,
	Camera=8493962573,
	ChatService=8493962464,
	Chat=8493962464,
	ClickDetector=8493962381,
	ConeHandleAdornment=8493962299,
	Configuration=8493962208,
	CylinderHandleAdornment=8493962142,
	CylindricalConstraint=8493962055,
	Debris=8493961943,
	Decal=8493961803,
	Dialog=8493961719,
	DialogChoice=8493961660,
	Explosion=8493960579,
	FaceControls=8493960473,
	Fire=8493960345,
	Flag=8493960249,
	FlagStand=8493960158,
	Folder=8493960030,
	ForceField=8493959889,
	Frame=8493959790,
	ScrollingFrame=8493959790,
	Handles=8493959711,
	Hat=8493959565,
	Accoutrement=8493959565,
	Highlight=8493959460,
	HingeConstraint=8493959359,
	Hopperbin=8493959232,
	Humanoid=8493959101,
	HumanoidDescription=8493958905,
	ImageButton=8493958690,
	ViewportFrame=8493958690,
	ImageHandleAdornment=8493958497,
	ImageLabel=8493958317,
	Joint=8493957951,
	Lighting=8493957774,
	Light=8493957774,
	LinearVelocity=8493957596,
	LineForce=8493957454,
	LineHandleAdornment=8493957343,
	LocalizationService=8493957234,
	LocalizationTable=8493957098,
	LocalScript=8493956857,
	MaterialsService=8493956731,
	MaterialVariant=8493956602,
	Mesh=8493956442,
	BlockMesh=8493956442,
	CharacterMesh=8493956442,
	SpecialMesh=8493956442,
	MeshPart=8493956332,
	Model=8493956218,
	ModuleScript=8493956113,
	Motor6D=8493955962,
	NegateOperation=8493955837,
	NetworkClient=8493955646,
	NetworkReplicator=8493955445,
	NetworkServer=8493955346,
	NoCollisionConstraint=8493955225,
	PackageLink=8493955106,
	Pants=8493954970,
	ParticleEmitter=8493954867,
	PathfindingModifier=8493954701,
	PlaneConstraint=8493954551,
	Player=8493954427,
	Players=8494177522,
	PlayerScripts=8493954103,
	StarterPlayerScripts=8493954103,
	StarterCharacterScripts=8493954103,
	PostEffect=8493953989,
	PrismaticConstraint=8493953885,
	ProximityPrompt=8493953775,
	RemoteEvent=8493953661,
	RemoteFunction=8493953523,
	ReplicatedStorage=8493953379,
	ReplicatedFirst=8493953379,
	RodConstraint=8493953238,
	RopeConstraint=8493953105,
	ScreenGui=8493952983,
	Script=8493952898,
	Seat=8493952803,
	SelectionBox=8493952720,
	SelectionSphere=8493952720,
	SelectionLasso=8493952612,
	ServerScriptService=8493952492,
	ServerStorage=8493952390,
	Shirt=8493952248,
	Sky=8493952073,
	Smoke=8493951889,
	Sound=8493951708,
	SoundGroup=8493951469,
	SphereHandleAdornment=8493950976,
	SpringConstraint=8493950881,
	Torque=8493949430,
	AngularVelocity=8493949430,
	TorsionSpringConstraint=8493949238,
	Trail=8493949106,
	UniversalConstraint=8493948899,
	VectorForce=8493948722,
	VideoFrame=8493948653,
	WeldConstraint=8493948550,
	undefined=8492695355,
	WrapTarget=8493948093,
	WrapTargetAlt=8493948003,
	SoundEffect=8493912953,
	SoundService=8493912860,
	Sparkles=8493912732,
	SpawnLocation=8493912656,
	StarterGui=8493950774,
	StarterPlayer=8493950627,
	SurfaceSelection=8493912190,
	Team=8493912040,
	Teams=8493911881,
	Terrain=8493911731,
	TestService=8493911573,
	TextButton=8493911407,
	TextLabel=8493911235,
	Texture=8493911131,
	SurfaceAppearance=8493911131,
	Tool=8493911048,
	UIComponent=8493910963,
	ValueBase=8493910805,
	Workspace=8493910652,
	Instance=8493958120,
}


local exemptions = {
	BasePart = 1,
	MeshPart = 1,
	Model = 1
}

function module:FindThumbnail(object)
	local icon = icons[object.ClassName]
	if icon == nil then
		for i,v in pairs(icons) do
			if object:IsA(i) then
				icons[object.ClassName] = v
				icon = v
				break
			end
		end
	end
	return icon
end

function module:render(frame, object, createViewport)
	if createViewport == nil then
		createViewport = false
	end

	local folderImageFrame = frame.FolderImage
	local itemNameLabel = frame.ItemName

	local itemType = object.ClassName
	local iconId = self:FindThumbnail(object)
	local exemption = exemptions[itemType]
	
	if object then
		if iconId ~= nil and (not createViewport or not exemption) then
			--viewportFrame.Visible = false
			folderImageFrame.Visible = true
			folderImageFrame.Image = string.format("rbxthumb://type=Asset&id=%s&w=150&h=150", iconId) --"http://www.roblox.com/asset/?id=" .. iconId
		elseif createViewport then
			if object == nil or (object:IsA("MeshPart") or object:IsA("BasePart") or object.ClassName == "Model" or object:IsA("Folder")) then
				spawn(function()
					folderImageFrame.Visible = false
					if cache[object] then
						cache[object]:Clone().Parent = frame
					else
						local viewportFrame = ViewportFrameGetter:GetViewport(object)
						viewportFrame.Parent = frame
						viewportFrame.Size = UDim2.new(1,0,1,0)
						viewportFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
						viewportFrame.BackgroundTransparency = 1
						cache[object] = viewportFrame:Clone()
						object.Changed:connect(function()
							if object.Parent == nil then
								cache[object] = nil
							end
						end)
					end

				end)
			end
		end
		itemNameLabel.Text = object.Name
		frame.Name = object.Name
	end
end


return module
