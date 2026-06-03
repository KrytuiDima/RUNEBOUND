--!strict
local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore("RuneboundPlayerData_v1")

local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Types"))

local DataManager = {}
local sessionData: {[number]: Types.PlayerData} = {}

local DEFAULT_DATA: Types.PlayerData = {
	Level = 1,
	Exp = 0,
	Mana = 100,
	MaxMana = 100,
	Stability = 10,
	Resonance = 10,
	Inventory = {},
	SkillTree = {},
	FirstJoinElement = nil
}

function DataManager.LoadData(player: Player)
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(tostring(player.UserId))
	end)

	if success and data then
		sessionData[player.UserId] = data
	else
		sessionData[player.UserId] = table.clone(DEFAULT_DATA)

		-- Random assignment of starter element
		local elements = {"Fire", "Water", "Earth", "Air"}
		sessionData[player.UserId].FirstJoinElement = elements[math.random(1, #elements)]
	end
end

function DataManager.SaveData(player: Player)
	if sessionData[player.UserId] then
		pcall(function()
			PlayerDataStore:SetAsync(tostring(player.UserId), sessionData[player.UserId])
		end)
	end
end

function DataManager.GetPlayerData(player: Player): Types.PlayerData?
	return sessionData[player.UserId]
end

function DataManager.UpdatePlayerData(player: Player, callback: (Types.PlayerData) -> Types.PlayerData)
	if sessionData[player.UserId] then
		sessionData[player.UserId] = callback(sessionData[player.UserId])
	end
end

return DataManager
