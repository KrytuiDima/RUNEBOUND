--!strict
local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Types"))

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
