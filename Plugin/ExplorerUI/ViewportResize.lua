local module = {}

local resizeFrame = script.Parent
local mouseDown = false
local mousePosition = nil
local originalPosition = nil
local ListViewport = nil
local GridViewport = nil

function module:init(MainFrame, SetMouseToResizeCursor)
	resizeFrame = MainFrame.ViewportResize
	ListViewport = MainFrame.ListViewport
	GridViewport = MainFrame.AssetsViewport
	
	resizeFrame.MouseEnter:Connect(function()
		SetMouseToResizeCursor(true)
	end)
	
	resizeFrame.MouseLeave:Connect(function()
		SetMouseToResizeCursor(false)
	end)
	
	resizeFrame.MouseButton1Down:Connect(function(x,y)
		mousePosition = Vector2.new(x, y)
		mouseDown = true
		originalPosition = resizeFrame.Position
	end)


	MainFrame.InputFrame.InputEnded:Connect(function(input:InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			mouseDown = false
		end
	end)

	MainFrame.InputFrame.InputChanged:Connect(function(input:InputObject)
		if mouseDown == false then return end
		resizeFrame.Position = originalPosition + UDim2.new(0, input.Position.X - mousePosition.X, 0, 0)
		ListViewport.Size = UDim2.new(0, resizeFrame.Position.X.Offset, 1, -65)
		GridViewport.Size = UDim2.new(1, -resizeFrame.Position.X.Offset, 1, -65)
	end)
end

return module
