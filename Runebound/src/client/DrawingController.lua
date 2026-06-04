--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GestureRecognizer = require(script.Parent.GestureRecognizer)
local VFXManager = require(script.Parent.VFXManager)
local HUDController = require(script.Parent.HUDController)
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local DrawingController = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local CastSpellEvent = ReplicatedStorage:WaitForChild("CastSpellEvent")
local VFXEvent = ReplicatedStorage:WaitForChild("VFXEvent")

local currentPoints: {Types.Point} = {}
local allPointsInCombo: {Types.Point} = {}
local currentCombo: {string} = {}
local comboTimeoutTask: thread?
local isDrawing = false
local canvasGui: ScreenGui
local canvasFrame: Frame

function DrawingController.Init()
	HUDController.Init()

	-- Create UI
	canvasGui = Instance.new("ScreenGui")
	canvasGui.Name = "DrawingCanvas"
	canvasGui.IgnoreGuiInset = true
	canvasGui.Parent = PlayerGui

	canvasFrame = Instance.new("Frame")
	canvasFrame.Size = UDim2.fromScale(1, 1)
	canvasFrame.BackgroundTransparency = 1
	canvasFrame.Parent = canvasGui

	-- VFX Listener
	VFXEvent.OnClientEvent:Connect(function(spellName, origin, direction)
		VFXManager.PlaySpellEffect(spellName, origin, direction)
	end)

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
		table.insert(currentCombo, gesture)
		for _, p in ipairs(currentPoints) do
			table.insert(allPointsInCombo, p)
		end

	-- Flash color based on recognition
	local flashColor = Color3.fromRGB(0, 255, 255) -- Default Arcane/Mana
	-- In the future, match color to element

		for _, child in ipairs(canvasFrame:GetChildren()) do
			if child:IsA("Frame") then
			local originalColor = child.BackgroundColor3
			child.BackgroundColor3 = Color3.new(1, 1, 1)
			task.delay(0.1, function()
				if child and child.Parent then
					child.BackgroundColor3 = flashColor
				end
			end)
			end
		end

	HUDController.UpdateCombo(currentCombo)

		-- Reset timeout
		if comboTimeoutTask then
			task.cancel(comboTimeoutTask)
		end

		comboTimeoutTask = task.delay(1.5, function()
			DrawingController.SubmitCombo()
		end)
	else
		canvasFrame:ClearAllChildren()
	end
end

function DrawingController.SubmitCombo()
	if #currentCombo > 0 then
		CastSpellEvent:FireServer(currentCombo, allPointsInCombo)
		currentCombo = {}
		allPointsInCombo = {}
		HUDController.UpdateCombo({})
	end
	canvasFrame:ClearAllChildren()
end

return DrawingController
