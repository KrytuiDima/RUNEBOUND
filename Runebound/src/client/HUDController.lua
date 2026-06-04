--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local HUDController = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local DamageEvent = ReplicatedStorage:FindFirstChild("DamageEvent") or Instance.new("RemoteEvent")
DamageEvent.Name = "DamageEvent"
DamageEvent.Parent = ReplicatedStorage

local hudGui: ScreenGui
local manaBar: Frame
local manaFill: Frame
local manaText: TextLabel
local elementLabel: TextLabel
local expLabel: TextLabel
local levelLabel: TextLabel
local comboContainer: Frame
local runebookFrame: Frame
local targetFrame: Frame
local targetHealthFill: Frame
local targetNameLabel: TextLabel

local sandboxMode = false

function HUDController.Init()
	hudGui = Instance.new("ScreenGui")
	hudGui.Name = "HUD"
	hudGui.Parent = PlayerGui

	-- Mana Bar
	manaBar = Instance.new("Frame")
	manaBar.Name = "ManaBar"
	manaBar.Size = UDim2.new(0, 200, 0, 20)
	manaBar.Position = UDim2.new(0, 20, 1, -40)
	manaBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	manaBar.BorderSizePixel = 2
	manaBar.Parent = hudGui

	manaFill = Instance.new("Frame")
	manaFill.Name = "Fill"
	manaFill.Size = UDim2.fromScale(1, 1)
	manaFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	manaFill.BorderSizePixel = 0
	manaFill.Parent = manaBar

	manaText = Instance.new("TextLabel")
	manaText.Size = UDim2.fromScale(1, 1)
	manaText.BackgroundTransparency = 1
	manaText.Text = "Mana: 100/100"
	manaText.TextColor3 = Color3.new(1, 1, 1)
	manaText.Font = Enum.Font.GothamBold
	manaText.TextSize = 14
	manaText.Parent = manaBar

	-- Element Label
	elementLabel = Instance.new("TextLabel")
	elementLabel.Size = UDim2.new(0, 200, 0, 20)
	elementLabel.Position = UDim2.new(0, 20, 1, -70)
	elementLabel.BackgroundTransparency = 1
	elementLabel.Text = "Element: None"
	elementLabel.TextColor3 = Color3.new(1, 1, 1)
	elementLabel.TextXAlignment = Enum.TextXAlignment.Left
	elementLabel.Font = Enum.Font.GothamBold
	elementLabel.TextSize = 18
	elementLabel.Parent = hudGui

	-- Exp and Level Labels
	levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(0, 100, 0, 20)
	levelLabel.Position = UDim2.new(0, 20, 0, 20)
	levelLabel.Text = "Lv. 1"
	levelLabel.TextColor3 = Color3.new(1, 1, 1)
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.TextSize = 18
	levelLabel.Parent = hudGui

	expLabel = Instance.new("TextLabel")
	expLabel.Size = UDim2.new(0, 200, 0, 20)
	expLabel.Position = UDim2.new(0, 20, 0, 40)
	expLabel.Text = "EXP: 0/100"
	expLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	expLabel.Font = Enum.Font.Gotham
	expLabel.TextSize = 14
	expLabel.TextXAlignment = Enum.TextXAlignment.Left
	expLabel.Parent = hudGui

	-- Combo Container
	comboContainer = Instance.new("Frame")
	comboContainer.Name = "ComboContainer"
	comboContainer.Size = UDim2.new(0, 400, 0, 40)
	comboContainer.Position = UDim2.new(0.5, -200, 1, -100)
	comboContainer.BackgroundTransparency = 1
	comboContainer.Parent = hudGui

	local comboLayout = Instance.new("UIListLayout")
	comboLayout.FillDirection = Enum.FillDirection.Horizontal
	comboLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	comboLayout.Padding = UDim.new(0, 10)
	comboLayout.Parent = comboContainer

	-- Sandbox Toggle
	local sandboxButton = Instance.new("TextButton")
	sandboxButton.Name = "SandboxToggle"
	sandboxButton.Size = UDim2.new(0, 120, 0, 30)
	sandboxButton.Position = UDim2.new(1, -140, 0, 20)
	sandboxButton.Text = "Sandbox: OFF"
	sandboxButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	sandboxButton.TextColor3 = Color3.new(1, 1, 1)
	sandboxButton.Parent = hudGui

	sandboxButton.MouseButton1Click:Connect(function()
		sandboxMode = not sandboxMode
		sandboxButton.Text = "Sandbox: " .. (sandboxMode and "ON" or "OFF")
		sandboxButton.BackgroundColor3 = sandboxMode and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
		-- Inform server about sandbox mode (for testing purposes only!)
		local SandboxEvent = ReplicatedStorage:FindFirstChild("SandboxEvent") or Instance.new("RemoteEvent")
		SandboxEvent.Name = "SandboxEvent"
		SandboxEvent.Parent = ReplicatedStorage
		SandboxEvent:FireServer(sandboxMode)
	end)

	-- Runebook Toggle removed (Moved to SpellbookController)

	-- Target Bar
	targetFrame = Instance.new("Frame")
	targetFrame.Name = "TargetBar"
	targetFrame.Size = UDim2.new(0, 400, 0, 30)
	targetFrame.Position = UDim2.new(0.5, -200, 0, 20)
	targetFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	targetFrame.Visible = false
	targetFrame.Parent = hudGui

	targetHealthFill = Instance.new("Frame")
	targetHealthFill.Name = "Fill"
	targetHealthFill.Size = UDim2.fromScale(1, 1)
	targetHealthFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	targetHealthFill.BorderSizePixel = 0
	targetHealthFill.Parent = targetFrame

	targetNameLabel = Instance.new("TextLabel")
	targetNameLabel.Size = UDim2.fromScale(1, 1)
	targetNameLabel.BackgroundTransparency = 1
	targetNameLabel.Text = "Target"
	targetNameLabel.TextColor3 = Color3.new(1, 1, 1)
	targetNameLabel.Font = Enum.Font.GothamBold
	targetNameLabel.TextSize = 16
	targetNameLabel.Parent = targetFrame

	-- Damage Number Listener
	DamageEvent.OnClientEvent:Connect(function(target, damage, currentHealth, maxHealth)
		HUDController.ShowDamageNumber(target, damage)
		HUDController.UpdateTargetBar(target.Name, currentHealth, maxHealth)
	end)

	-- Attribute Listeners
	Player:GetAttributeChangedSignal("Mana"):Connect(function()
		HUDController.UpdateMana(Player:GetAttribute("Mana"), Player:GetAttribute("MaxMana"))
	end)
	Player:GetAttributeChangedSignal("Element"):Connect(function()
		HUDController.UpdateElement(Player:GetAttribute("Element"))
	end)
	Player:GetAttributeChangedSignal("Level"):Connect(function()
		levelLabel.Text = "Lv. " .. (Player:GetAttribute("Level") or 1)
	end)
	Player:GetAttributeChangedSignal("Exp"):Connect(function()
		local lv = Player:GetAttribute("Level") or 1
		expLabel.Text = "EXP: " .. (Player:GetAttribute("Exp") or 0) .. "/" .. (lv * 100)
	end)

	-- Initial Sync
	HUDController.UpdateMana(Player:GetAttribute("Mana") or 100, Player:GetAttribute("MaxMana") or 100)
	HUDController.UpdateElement(Player:GetAttribute("Element") or "None")
	levelLabel.Text = "Lv. " .. (Player:GetAttribute("Level") or 1)
	local lv = Player:GetAttribute("Level") or 1
	expLabel.Text = "EXP: " .. (Player:GetAttribute("Exp") or 0) .. "/" .. (lv * 100)
end

function HUDController.UpdateMana(current: number, max: number)
	manaFill.Size = UDim2.fromScale(current / max, 1)
	manaText.Text = "Mana: " .. math.floor(current) .. "/" .. math.floor(max)
end

function HUDController.UpdateElement(element: string)
	elementLabel.Text = "Element: " .. element
end

function HUDController.UpdateCombo(combo: {string})
	comboContainer:ClearAllChildren()
	Instance.new("UIListLayout").Parent = comboContainer -- Re-add layout
	comboContainer.UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	comboContainer.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	comboContainer.UIListLayout.Padding = UDim.new(0, 10)

	for _, gesture in ipairs(combo) do
		local tag = Instance.new("TextLabel")
		tag.Size = UDim2.new(0, 80, 0, 30)
		tag.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
		tag.Text = "[" .. gesture .. "]"
		tag.TextColor3 = Color3.new(1, 1, 1)
		tag.Font = Enum.Font.GothamBold
		tag.TextSize = 14
		tag.Parent = comboContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = tag
	end
end


function HUDController.ShowDamageNumber(target: Model, damage: number)
	local head = target:FindFirstChild("Head")
	if not head then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.Adornee = head
	billboard.StudsOffset = Vector3.new(math.random(-2, 2), 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hudGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = tostring(math.floor(damage))
	label.TextColor3 = Color3.new(1, 0.2, 0.2)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 24
	label.Parent = billboard

	TweenService:Create(billboard, TweenInfo.new(1), {StudsOffset = billboard.StudsOffset + Vector3.new(0, 3, 0)}):Play()
	TweenService:Create(label, TweenInfo.new(1), {TextTransparency = 1}):Play()

	task.delay(1, function()
		billboard:Destroy()
	end)
end

function HUDController.UpdateTargetBar(name: string, health: number, maxHealth: number)
	targetFrame.Visible = true
	targetNameLabel.Text = name
	targetHealthFill:TweenSize(UDim2.fromScale(health / maxHealth, 1), "Out", "Quad", 0.3, true)

	task.delay(5, function()
		if targetNameLabel.Text == name then
			targetFrame.Visible = false
		end
	end)
end

return HUDController
