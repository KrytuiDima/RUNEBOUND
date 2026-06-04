--!strict
local Players = game:GetService("Players")
local DataManager = require(script.DataManager)
require(script.SpellServer)

Players.PlayerAdded:Connect(function(player)
	DataManager.LoadData(player)

	player.CharacterAdded:Connect(function(character)
		-- Initial setup for character if needed
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	DataManager.SaveData(player)
end)
