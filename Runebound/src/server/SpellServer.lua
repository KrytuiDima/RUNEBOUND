--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SpellRegistry = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SpellRegistry"))
local DataManager = require(script.Parent.DataManager)
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))
local CombatEngine = require(script.Parent.CombatEngine)

local SpellServer = {}
local CastSpellEvent = Instance.new("RemoteEvent")
CastSpellEvent.Name = "CastSpellEvent"
CastSpellEvent.Parent = ReplicatedStorage

-- Anti-cheat validation
local function ValidateGesture(player: Player, points: {Types.Point}): (boolean, number)
	if #points < 2 then return false, 0 end

	local totalDuration = points[#points].t - points[1].t
	if totalDuration < 0.1 then return false, 0 end -- Too fast, likely a macro

	-- Calculate velocity curve entropy (simplified)
	local velocities = {}
	for i = 2, #points do
		local d = math.sqrt((points[i].x - points[i-1].x)^2 + (points[i].y - points[i-1].y)^2)
		local dt = points[i].t - points[i-1].t
		table.insert(velocities, d / (dt + 0.0001))
	end

	-- Human drawing has variance in velocity
	local mean = 0
	for _, v in ipairs(velocities) do mean += v end
	mean /= #velocities

	local variance = 0
	for _, v in ipairs(velocities) do variance += (v - mean)^2 end
	variance /= #velocities

	if variance < 0.0001 then return false, 0 end -- Too perfect/uniform velocity

	-- Accuracy Score (simulated based on points length and duration)
	local accuracy = math.clamp(1 - (0.1 / totalDuration), 0.5, 1.0)

	return true, accuracy
end

CastSpellEvent.OnServerEvent:Connect(function(player: Player, gestureName: string, points: {Types.Point})
	local isValid, accuracy = ValidateGesture(player, points)
	if not isValid then
		warn("Suspicious activity detected from player:", player.Name)
		return
	end

	local spell = SpellRegistry.GetSpellBySymbols({gestureName})
	if spell then
		local data = DataManager.GetPlayerData(player)
		if data and data.Mana >= spell.ManaCost then
			-- Deduct Mana
			DataManager.UpdatePlayerData(player, function(d)
				d.Mana -= spell.ManaCost
				return d
			end)

			-- Calculate Damage
			local finalDamage = spell.BaseDamage * (accuracy ^ 2) * (1 + (data.Resonance / 100))

			-- Execute Spell in Combat Engine
			local character = player.Character
			if character then
				local origin = character.PrimaryPart.Position
				local direction = character.PrimaryPart.CFrame.LookVector
				CombatEngine.CastSpell(player, spell, origin, direction, finalDamage)
			end
		end
	end
end)

return SpellServer
