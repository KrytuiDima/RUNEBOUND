--!strict
local TweenService = game:GetService("TweenService")

local VFXManager = {}

function VFXManager.PlaySpellEffect(spellName: string, position: Vector3, direction: Vector3)
	-- Placeholder for complex particle systems
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.5
	part.Color = Color3.new(1, 0.5, 0)
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

return VFXManager
