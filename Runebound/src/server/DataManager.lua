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
	StatPoints = 0,
	Inventory = {},
	SkillTree = {},
	FirstJoinElement = nil
}

function DataManager.LoadData(player: Player)
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(tostring(player.UserId))
	end)

	if success and data then
		-- Ensure new fields from DEFAULT_DATA are present
		for k, v in pairs(DEFAULT_DATA) do
			if data[k] == nil then
				data[k] = v
			end
		end
		sessionData[player.UserId] = data
		DataManager.SyncAttributes(player)
	else
		sessionData[player.UserId] = table.clone(DEFAULT_DATA)

		-- Random assignment of starter element
		local elements = {"Fire", "Water", "Earth", "Air"}
		sessionData[player.UserId].FirstJoinElement = elements[math.random(1, #elements)]
		DataManager.SyncAttributes(player)
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
		DataManager.SyncAttributes(player)
	end
end

function DataManager.SyncAttributes(player: Player)
	local data = sessionData[player.UserId]
	if data then
		player:SetAttribute("Mana", data.Mana)
		player:SetAttribute("MaxMana", data.MaxMana)
		player:SetAttribute("Level", data.Level)
		player:SetAttribute("Exp", data.Exp)
		player:SetAttribute("StatPoints", data.StatPoints)
		player:SetAttribute("Stability", data.Stability)
		player:SetAttribute("Resonance", data.Resonance)
		player:SetAttribute("Element", data.FirstJoinElement or "None")
	end
end

function DataManager.AddExp(player: Player, amount: number)
	DataManager.UpdatePlayerData(player, function(d)
		d.Exp += amount
		local needed = d.Level * 100
		while d.Exp >= needed do
			d.Exp -= needed
			d.Level += 1
			d.StatPoints += 5
			needed = d.Level * 100
		end
		return d
	end)
end

function DataManager.AllocateStat(player: Player, stat: string)
	DataManager.UpdatePlayerData(player, function(d)
		if d.StatPoints > 0 then
			if stat == "Resonance" then
				d.Resonance += 1
				d.StatPoints -= 1
			elseif stat == "Stability" then
				d.Stability += 1
				d.StatPoints -= 1
			end
		end
		return d
	end)
end

return DataManager
