--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GestureRecognizer = require(script.Parent.GestureRecognizer)
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local DrawingController = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local CastSpellEvent = ReplicatedStorage:WaitForChild("CastSpellEvent")

local currentPoints: {Types.Point} = {}
local isDrawing = false
local canvasGui: ScreenGui
local canvasFrame: Frame

function DrawingController.Init()
	-- Create UI
	canvasGui = Instance.new("ScreenGui")
	canvasGui.Name = "DrawingCanvas"
	canvasGui.IgnoreGuiInset = true
	canvasGui.Parent = PlayerGui

	canvasFrame = Instance.new("Frame")
	canvasFrame.Size = UDim2.fromScale(1, 1)
	canvasFrame.BackgroundTransparency = 1
	canvasFrame.Parent = canvasGui

	-- Input Listeners
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDrawing = true
			currentPoints = {}
			DrawingController.AddPoint(input.Position)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDrawing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			DrawingController.AddPoint(input.Position)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if isDrawing and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			isDrawing = false
			DrawingController.FinishDrawing()
		end
	end)
end

function DrawingController.AddPoint(position: Vector3)
	local point: Types.Point = {
		x = position.X,
		y = position.Y,
		t = os.clock()
	}
	table.insert(currentPoints, point)

	-- Visual Feedback
	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(4, 4)
	dot.Position = UDim2.fromOffset(position.X - 2, position.Y - 2)
	dot.BackgroundColor3 = Color3.new(0, 0.8, 1)
	dot.BorderSizePixel = 0
	dot.Parent = canvasFrame

	task.delay(1, function()
		dot:Destroy()
	end)
end

function DrawingController.FinishDrawing()
	if #currentPoints < 5 then
		canvasFrame:ClearAllChildren()
		return
	end

	local vectorPoints: {Vector2} = {}
	for _, p in ipairs(currentPoints) do
		table.insert(vectorPoints, Vector2.new(p.x, p.y))
	end

	local gesture, score = GestureRecognizer.Recognize(vectorPoints)
	print("Recognized Gesture:", gesture, "Score:", score)

	if score > 0.7 then
		-- In a real scenario, we might collect multiple gestures for combo
		CastSpellEvent:FireServer(gesture, currentPoints)
	end

	canvasFrame:ClearAllChildren()
end

return DrawingController
