--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local DamageEvent = ReplicatedStorage:FindFirstChild("DamageEvent") or Instance.new("RemoteEvent")
DamageEvent.Name = "DamageEvent"
DamageEvent.Parent = ReplicatedStorage

local CombatEngine = {}

-- Utility to get target from raycast
local function GetRaycastTarget(origin: Vector3, direction: Vector3, ignore: {Instance})
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = ignore
	params.FilterType = Enum.RaycastFilterType.Exclude
	return workspace:Raycast(origin, direction * 100, params)
end

function CombatEngine.ApplyDamage(caster: Player, targetHumanoid: Humanoid, damage: number, spellName: string)
	targetHumanoid:TakeDamage(damage)
	DamageEvent:FireClient(caster, targetHumanoid.Parent, damage, targetHumanoid.Health, targetHumanoid.MaxHealth)

	-- Exp gain on hit
	local DataManager = require(script.Parent.DataManager)
	DataManager.AddExp(caster, 10)
end

function CombatEngine.CastSpell(caster: Player, spell: any, origin: Vector3, direction: Vector3, damage: number)
	if spell.Archetype == "Projectile" then
		CombatEngine.HandleProjectile(caster, spell, origin, direction, damage)
	elseif spell.Archetype == "GroundAOE" then
		CombatEngine.HandleGroundAOE(caster, spell, origin, direction, damage)
	elseif spell.Archetype == "Zone" then
		CombatEngine.HandleZone(caster, spell, origin, direction, damage)
	elseif spell.Archetype == "Buff" then
		CombatEngine.HandleBuff(caster, spell, origin, direction, damage)
	end
end

function CombatEngine.HandleProjectile(caster: Player, spell: any, origin: Vector3, direction: Vector3, damage: number)
	local result = GetRaycastTarget(origin, direction, {caster.Character})
	if result then
		local humanoid = result.Instance.Parent:FindFirstChild("Humanoid") or result.Instance.Parent.Parent:FindFirstChild("Humanoid")
		if humanoid then
			CombatEngine.ApplyDamage(caster, humanoid, damage, spell.Name)
		end
	end
end

function CombatEngine.HandleGroundAOE(caster: Player, spell: any, origin: Vector3, direction: Vector3, damage: number)
	-- Target ground location
	local result = GetRaycastTarget(origin, direction, {caster.Character})
	local targetPos = result and result.Position or (origin + direction * 20)

	task.delay(spell.Delay or 1, function()
		local overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = {caster.Character}
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude

		local parts = workspace:GetPartBoundsInRadius(targetPos, spell.Radius or 10, overlapParams)
		local hitHumanoids = {}
		for _, part in ipairs(parts) do
			local hum = part.Parent:FindFirstChild("Humanoid")
			if hum and not hitHumanoids[hum] then
				hitHumanoids[hum] = true
				CombatEngine.ApplyDamage(caster, hum, damage, spell.Name)

				-- Special Ice Freeze behavior
				if spell.Element == "Ice" then
					hum.WalkSpeed = math.max(4, hum.WalkSpeed * 0.3)
					task.delay(3, function()
						hum.WalkSpeed = 16 -- Reset (should ideally restore original)
					end)
				end
			end
		end
	end)
end

function CombatEngine.HandleZone(caster: Player, spell: any, origin: Vector3, direction: Vector3, damage: number)
	local result = GetRaycastTarget(origin, direction, {caster.Character})
	local targetPos = result and result.Position or (origin + direction * 15)

	local duration = spell.Duration or 5
	local startTime = os.clock()

	task.spawn(function()
		while os.clock() - startTime < duration do
			local overlapParams = OverlapParams.new()
			overlapParams.FilterDescendantsInstances = {caster.Character}
			overlapParams.FilterType = Enum.RaycastFilterType.Exclude

			local parts = workspace:GetPartBoundsInRadius(targetPos, spell.Radius or 10, overlapParams)
			local hitHumanoids = {}
			for _, part in ipairs(parts) do
				local hum = part.Parent:FindFirstChild("Humanoid")
				if hum and not hitHumanoids[hum] then
					hitHumanoids[hum] = true
					CombatEngine.ApplyDamage(caster, hum, damage, spell.Name)
				end
			end
			task.wait(1) -- Tick rate
		end
	end)
end

function CombatEngine.HandleBuff(caster: Player, spell: any, origin: Vector3, direction: Vector3, damage: number)
	local result = GetRaycastTarget(origin, direction, {caster.Character})
	if result then
		local char = result.Instance.Parent
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(char)
			if targetPlayer and targetPlayer.Team == caster.Team then
				-- Buff Ally
				print("Buffing ally: ", targetPlayer.Name)
				-- Logic for resonance/stability boost
			else
				-- Smite Enemy
				CombatEngine.ApplyDamage(caster, hum, damage, spell.Name)
			end
		end
	end
end

return CombatEngine
