--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatsController = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local AllocateStatEvent = ReplicatedStorage:FindFirstChild("AllocateStatEvent") or Instance.new("RemoteEvent")
AllocateStatEvent.Name = "AllocateStatEvent"
AllocateStatEvent.Parent = ReplicatedStorage

local statsGui: ScreenGui
local mainFrame: Frame
local resonanceLabel: TextLabel
local stabilityLabel: TextLabel
local pointsLabel: TextLabel

function StatsController.Init()
	statsGui = Instance.new("ScreenGui")
	statsGui.Name = "StatsUI"
	statsGui.Parent = PlayerGui

	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "OpenStats"
	toggleButton.Size = UDim2.new(0, 100, 0, 30)
	toggleButton.Position = UDim2.new(0, 20, 1, -160)
	toggleButton.Text = "SKILLS/STATS"
	toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.Parent = statsGui

	mainFrame = Instance.new("Frame")
	mainFrame.Name = "StatsFrame"
	mainFrame.Size = UDim2.new(0, 300, 0, 250)
	mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
	mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	mainFrame.Visible = false
	mainFrame.Parent = statsGui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Text = "CHARACTER STATS"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.BackgroundTransparency = 1
	title.Parent = mainFrame

	pointsLabel = Instance.new("TextLabel")
	pointsLabel.Size = UDim2.new(1, 0, 0, 30)
	pointsLabel.Position = UDim2.new(0, 0, 0, 40)
	pointsLabel.Text = "Stat Points: 0"
	pointsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	pointsLabel.BackgroundTransparency = 1
	pointsLabel.Parent = mainFrame

	resonanceLabel = Instance.new("TextLabel")
	resonanceLabel.Size = UDim2.new(0, 150, 0, 30)
	resonanceLabel.Position = UDim2.new(0, 20, 0, 80)
	resonanceLabel.Text = "Resonance: 10"
	resonanceLabel.TextColor3 = Color3.new(1, 1, 1)
	resonanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	resonanceLabel.BackgroundTransparency = 1
	resonanceLabel.Parent = mainFrame

	local resButton = Instance.new("TextButton")
	resButton.Size = UDim2.new(0, 30, 0, 30)
	resButton.Position = UDim2.new(0, 180, 0, 80)
	resButton.Text = "+"
	resButton.Parent = mainFrame
	resButton.MouseButton1Click:Connect(function()
		AllocateStatEvent:FireServer("Resonance")
	end)

	stabilityLabel = Instance.new("TextLabel")
	stabilityLabel.Size = UDim2.new(0, 150, 0, 30)
	stabilityLabel.Position = UDim2.new(0, 20, 0, 120)
	stabilityLabel.Text = "Stability: 10"
	stabilityLabel.TextColor3 = Color3.new(1, 1, 1)
	stabilityLabel.TextXAlignment = Enum.TextXAlignment.Left
	stabilityLabel.BackgroundTransparency = 1
	stabilityLabel.Parent = mainFrame

	local stabButton = Instance.new("TextButton")
	stabButton.Size = UDim2.new(0, 30, 0, 30)
	stabButton.Position = UDim2.new(0, 180, 0, 120)
	stabButton.Text = "+"
	stabButton.Parent = mainFrame
	stabButton.MouseButton1Click:Connect(function()
		AllocateStatEvent:FireServer("Stability")
	end)

	toggleButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = not mainFrame.Visible
	end)

	-- Sync Listeners
	Player:GetAttributeChangedSignal("StatPoints"):Connect(StatsController.Refresh)
	Player:GetAttributeChangedSignal("Resonance"):Connect(StatsController.Refresh)
	Player:GetAttributeChangedSignal("Stability"):Connect(StatsController.Refresh)

	StatsController.Refresh()
end

function StatsController.Refresh()
	pointsLabel.Text = "Stat Points: " .. (Player:GetAttribute("StatPoints") or 0)
	resonanceLabel.Text = "Resonance: " .. (Player:GetAttribute("Resonance") or 10)
	stabilityLabel.Text = "Stability: " .. (Player:GetAttribute("Stability") or 10)
end

return StatsController
