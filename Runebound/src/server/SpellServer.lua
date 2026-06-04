--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SpellRegistry = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SpellRegistry"))
local DataManager = require(script.Parent.DataManager)
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))
local CombatEngine = require(script.Parent.CombatEngine)

local SpellServer = {}
local sandboxPlayers: {[number]: boolean} = {}

local CastSpellEvent = ReplicatedStorage:FindFirstChild("CastSpellEvent") or Instance.new("RemoteEvent")
CastSpellEvent.Name = "CastSpellEvent"
CastSpellEvent.Parent = ReplicatedStorage

local SandboxEvent = ReplicatedStorage:FindFirstChild("SandboxEvent") or Instance.new("RemoteEvent")
SandboxEvent.Name = "SandboxEvent"
SandboxEvent.Parent = ReplicatedStorage

local AllocateStatEvent = ReplicatedStorage:FindFirstChild("AllocateStatEvent") or Instance.new("RemoteEvent")
AllocateStatEvent.Name = "AllocateStatEvent"
AllocateStatEvent.Parent = ReplicatedStorage

local SpendSkillPointEvent = ReplicatedStorage:FindFirstChild("SpendSkillPointEvent") or Instance.new("RemoteEvent")
SpendSkillPointEvent.Name = "SpendSkillPointEvent"
SpendSkillPointEvent.Parent = ReplicatedStorage

local VFXEvent = ReplicatedStorage:FindFirstChild("VFXEvent") or Instance.new("RemoteEvent")
VFXEvent.Name = "VFXEvent"
VFXEvent.Parent = ReplicatedStorage

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

SandboxEvent.OnServerEvent:Connect(function(player: Player, enabled: boolean)
	sandboxPlayers[player.UserId] = enabled
end)

AllocateStatEvent.OnServerEvent:Connect(function(player: Player, stat: string)
	DataManager.AllocateStat(player, stat)
end)

SpendSkillPointEvent.OnServerEvent:Connect(function(player: Player, statName: string)
	DataManager.SpendSkillPoint(player, statName)
end)

CastSpellEvent.OnServerEvent:Connect(function(player: Player, combo: {string}, points: {Types.Point})
	local isSandbox = sandboxPlayers[player.UserId] or false
	local data = DataManager.GetPlayerData(player)
	if not data then return end

	local isValid, accuracy = true, 1.0
	if not isSandbox then
		local threshold = 0.7 - (data.Stability / 100)
		-- Note: ValidateGesture currently doesn't take threshold, we should update it or use it here
		isValid, accuracy = ValidateGesture(player, points)
		-- Simple implementation: if accuracy < threshold, it's invalid
		if accuracy < threshold then
			isValid = false
		end
	end

	if not isValid then
		warn("Suspicious activity detected from player:", player.Name)
		return
	end

	local spell = SpellRegistry.GetSpellBySymbols(combo)
	if spell then
		local manaCost = spell.ManaCost
		local resonanceBonus = 0
		local damageMultiplier = 1.0

		-- Wand Buffs
		if data.EquippedWand == "ApprenticeWand" then
			resonanceBonus = 10
			manaCost = math.max(0, manaCost - 1)
		elseif data.EquippedWand == "ArchmageWand" then
			resonanceBonus = 50
			damageMultiplier = 1.2
		end

		if isSandbox or data.Mana >= manaCost then
			-- Deduct Mana
			if not isSandbox then
				DataManager.UpdatePlayerData(player, function(d)
					d.Mana -= manaCost
					return d
				end)
			end

			-- Calculate Damage
			local effectiveResonance = data.Resonance + resonanceBonus
			local finalDamage = spell.BaseDamage * (accuracy ^ 2) * (1 + (effectiveResonance / 100)) * damageMultiplier

			-- Add stability bonus to accuracy if needed
			if accuracy < 1 then
				accuracy = math.min(1, accuracy + (data.Stability / 500))
			end

			-- Execute Spell in Combat Engine
			local character = player.Character
			if character and character.PrimaryPart then
				local origin = character.PrimaryPart.Position
				local direction = character.PrimaryPart.CFrame.LookVector
				CombatEngine.CastSpell(player, spell, origin, direction, finalDamage)

				-- Replication to all clients
				VFXEvent:FireAllClients(spell.Name, origin, direction)
			end
		end
	end
end)

return SpellServer
