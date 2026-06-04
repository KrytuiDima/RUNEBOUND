--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpellRegistry = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SpellRegistry"))

local SpellbookController = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local bookGui: ScreenGui
local bookFrame: Frame
local scrollFrame: ScrollingFrame

function SpellbookController.Init()
	bookGui = Instance.new("ScreenGui")
	bookGui.Name = "SpellbookUI"
	bookGui.Parent = PlayerGui

	local toggleButton = Instance.new("ImageButton")
	toggleButton.Name = "OpenSpellbook"
	toggleButton.Size = UDim2.new(0, 50, 0, 50)
	toggleButton.Position = UDim2.new(0, 20, 1, -120)
	toggleButton.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
	toggleButton.Image = "rbxassetid://6031280992"
	toggleButton.Parent = bookGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = toggleButton

	bookFrame = Instance.new("Frame")
	bookFrame.Name = "MainFrame"
	bookFrame.Size = UDim2.new(0, 400, 0, 500)
	bookFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
	bookFrame.BackgroundColor3 = Color3.fromRGB(45, 30, 15)
	bookFrame.BorderSizePixel = 4
	bookFrame.BorderColor3 = Color3.fromRGB(255, 200, 100)
	bookFrame.Visible = false
	bookFrame.Parent = bookGui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Text = "ANCIENT RUNEBOOK"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.Font = Enum.Font.Antique
	title.TextSize = 28
	title.BackgroundTransparency = 1
	title.Parent = bookFrame

	scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -40, 1, -80)
	scrollFrame.Position = UDim2.new(0, 20, 0, 60)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = bookFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scrollFrame

	toggleButton.MouseButton1Click:Connect(function()
		bookFrame.Visible = not bookFrame.Visible
		if bookFrame.Visible then
			SpellbookController.Refresh()
		end
	end)

	SpellbookController.Refresh()
end

function SpellbookController.Refresh()
	scrollFrame:ClearAllChildren()
	Instance.new("UIListLayout").Parent = scrollFrame -- Re-add layout
	scrollFrame.UIListLayout.Padding = UDim.new(0, 10)

	-- Sort spells by Tier then Name
	local sortedSpells = {}
	for id, data in pairs(SpellRegistry.Spells) do
		table.insert(sortedSpells, data)
	end
	table.sort(sortedSpells, function(a, b)
		if a.Tier ~= b.Tier then return a.Tier < b.Tier end
		return a.Name < b.Name
	end)

	for _, spell in ipairs(sortedSpells) do
		local entry = Instance.new("Frame")
		entry.Size = UDim2.new(1, 0, 0, 60)
		entry.BackgroundColor3 = Color3.fromRGB(60, 45, 30)
		entry.Parent = scrollFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -10, 0, 20)
		nameLabel.Position = UDim2.fromOffset(5, 5)
		nameLabel.Text = spell.Name .. " (Tier " .. spell.Tier .. ")"
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 16
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.BackgroundTransparency = 1
		nameLabel.Parent = entry

		local comboText = table.concat(spell.Symbols, " + ")
		local comboLabel = Instance.new("TextLabel")
		comboLabel.Size = UDim2.new(1, -10, 0, 20)
		comboLabel.Position = UDim2.fromOffset(5, 30)
		comboLabel.Text = "Rune: " .. comboText
		comboLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
		comboLabel.Font = Enum.Font.Code
		comboLabel.TextSize = 14
		comboLabel.TextXAlignment = Enum.TextXAlignment.Left
		comboLabel.BackgroundTransparency = 1
		comboLabel.Parent = entry

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = entry
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #sortedSpells * 70)
end

return SpellbookController
