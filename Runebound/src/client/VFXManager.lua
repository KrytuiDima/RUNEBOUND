--!strict
local TweenService = game:GetService("TweenService")

local VFXManager = {}

local SpellRegistry = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("SpellRegistry"))

function VFXManager.PlaySpellEffect(spellName: string, position: Vector3, direction: Vector3)
	local spell = SpellRegistry.GetSpellByID(spellName) -- Note: we might be sending Name instead of ID in some places, better to use ID
	if not spell then
		-- Fallback to search by Name
		for _, s in pairs(SpellRegistry.Spells) do
			if s.Name == spellName then
				spell = s
				break
			end
		end
	end

	if not spell then return end

	if spell.Archetype == "Projectile" then
		VFXManager.CreateProjectileVFX(spell, position, direction)
	elseif spell.Archetype == "GroundAOE" then
		VFXManager.CreateGroundVFX(spell, position, direction)
	elseif spell.Archetype == "Zone" then
		VFXManager.CreateZoneVFX(spell, position, direction)
	elseif spell.Archetype == "Buff" then
		VFXManager.CreateBuffVFX(spell, position, direction)
	end
end

function VFXManager.CreateProjectileVFX(spell: any, position: Vector3, direction: Vector3)
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.5
	part.Color = spell.Element == "Fire" and Color3.new(1, 0.5, 0) or Color3.new(0, 0.8, 1)
	part.Parent = workspace

	local attachment = Instance.new("Attachment", part)
	local particles = Instance.new("ParticleEmitter", attachment)
	particles.Rate = 100
	particles.Lifetime = NumberRange.new(0.5, 1)
	particles.Speed = NumberRange.new(5, 10)

	local tween = TweenService:Create(part, TweenInfo.new(1), {
		Position = position + direction * 50,
		Transparency = 1
	})

	tween:Play()
	tween.Completed:Connect(function()
		part:Destroy()
	end)
end

function VFXManager.CreateGroundVFX(spell: any, position: Vector3, direction: Vector3)
	-- Raycast to find ground
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(position, direction * 100, params)
	local targetPos = result and result.Position or (position + direction * 20)

	-- Warning Circle
	local ring = Instance.new("Part")
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.2, spell.Radius or 10, spell.Radius or 10)
	ring.Position = targetPos + Vector3.new(0, 0.1, 0)
	ring.Orientation = Vector3.new(0, 0, 90)
	ring.Anchored = true
	ring.CanCollide = false
	ring.Transparency = 0.5
	ring.Color = Color3.fromRGB(255, 100, 100)
	ring.Parent = workspace

	TweenService:Create(ring, TweenInfo.new(spell.Delay or 1), {Transparency = 1, Size = Vector3.new(0.2, 0, 0)}):Play()

	task.delay(spell.Delay or 1, function()
		ring:Destroy()
		-- Explosion VFX
		local blast = Instance.new("Part")
		blast.Shape = Enum.PartType.Ball
		blast.Size = Vector3.new(1, 1, 1)
		blast.Position = targetPos
		blast.Anchored = true
		blast.CanCollide = false
		blast.Color = Color3.fromRGB(200, 240, 255)
		blast.Parent = workspace

		TweenService:Create(blast, TweenInfo.new(0.5), {Size = Vector3.new(20, 20, 20), Transparency = 1}):Play()
		task.delay(0.5, function() blast:Destroy() end)
	end)
end

function VFXManager.CreateZoneVFX(spell: any, position: Vector3, direction: Vector3)
	local params = RaycastParams.new()
	local result = workspace:Raycast(position, direction * 100, params)
	local targetPos = result and result.Position or (position + direction * 15)

	local puddle = Instance.new("Part")
	puddle.Size = Vector3.new(spell.Radius or 12, 0.2, spell.Radius or 12)
	puddle.Position = targetPos
	puddle.Anchored = true
	puddle.CanCollide = false
	puddle.Transparency = 0.4
	puddle.Color = spell.Element == "Nature" and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(150, 200, 255)
	puddle.Parent = workspace

	local particles = Instance.new("ParticleEmitter", puddle)
	particles.Rate = 50
	particles.Speed = NumberRange.new(2, 5)

	task.delay(spell.Duration or 5, function()
		TweenService:Create(puddle, TweenInfo.new(1), {Transparency = 1}):Play()
		task.delay(1, function() puddle:Destroy() end)
	end)
end

function VFXManager.CreateBuffVFX(spell: any, position: Vector3, direction: Vector3)
	-- Simplified beam or flash
	local beam = Instance.new("Part")
	beam.Size = Vector3.new(0.5, 0.5, 100)
	beam.CFrame = CFrame.new(position, position + direction) * CFrame.new(0, 0, -50)
	beam.Anchored = true
	beam.CanCollide = false
	beam.Transparency = 0.5
	beam.Color = Color3.fromRGB(255, 255, 150)
	beam.Parent = workspace

	TweenService:Create(beam, TweenInfo.new(0.3), {Transparency = 1, Size = Vector3.new(0, 0, 100)}):Play()
	task.delay(0.3, function() beam:Destroy() end)
end

return VFXManager
