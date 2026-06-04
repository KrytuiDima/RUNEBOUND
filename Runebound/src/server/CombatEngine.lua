--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local DamageEvent = ReplicatedStorage:FindFirstChild("DamageEvent") or Instance.new("RemoteEvent")
DamageEvent.Name = "DamageEvent"
DamageEvent.Parent = ReplicatedStorage

local CombatEngine = {}

function CombatEngine.CastSpell(caster: Player, spell: any, origin: Vector3, direction: Vector3, damage: number)
	-- Use Raycasting for immediate hits or projectiles
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {caster.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local raycastResult = workspace:Raycast(origin, direction * 100, raycastParams)

	if raycastResult then
		local hitInstance = raycastResult.Instance
		local humanoid = hitInstance.Parent:FindFirstChild("Humanoid") or hitInstance.Parent.Parent:FindFirstChild("Humanoid")

		if humanoid then
			humanoid:TakeDamage(damage)
			print(caster.Name .. " hit " .. humanoid.Parent.Name .. " for " .. damage .. " damage with " .. spell.Name)

			-- Fire damage event for UI
			DamageEvent:FireClient(caster, humanoid.Parent, damage, humanoid.Health, humanoid.MaxHealth)
		end
	end

	-- Spatial partitioning check for AOE
	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = {caster.Character}
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude

	local partsInRange = workspace:GetPartBoundsInRadius(origin + direction * 5, 10, overlapParams)
	for _, part in ipairs(partsInRange) do
		-- Handle AOE damage logic here
	end
end

return CombatEngine
