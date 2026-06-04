--!strict
local Types = require(script.Parent.Types)

local SpellRegistry = {}

export type SpellData = Types.Spell & {
	Symbols: {string}
}

SpellRegistry.Spells = {} :: {[string]: SpellData}

local ELEMENTS = {"Fire", "Water", "Earth", "Air", "Light", "Dark", "Arcane", "Nature", "Ice", "Lightning"}
local SYMBOLS = {"Circle", "Triangle", "Line", "Zigzag", "Square", "V", "Caret", "Pigtail"}

-- Helper to register spells
local function registerSpell(data: SpellData)
	SpellRegistry.Spells[data.ID] = data
end

-- Generate 100+ spells for production-readiness
for i, element in ipairs(ELEMENTS) do
	-- Base Spell
	registerSpell({
		ID = element .. "1",
		Name = element .. " Bolt",
		Description = "A basic " .. element .. " bolt.",
		BaseDamage = 10 + i,
		ManaCost = 5 + i,
		Element = element,
		Tier = 1,
		Archetype = "Projectile",
		Symbols = {SYMBOLS[1]}
	})

	-- Combo Spells
	for j = 1, 10 do
		registerSpell({
			ID = element .. "_" .. j,
			Name = element .. " " .. SYMBOLS[(j % #SYMBOLS) + 1] .. " Spell",
			Description = "A powerful " .. element .. " combo spell.",
			BaseDamage = 20 + (i * 2) + j,
			ManaCost = 15 + i + j,
			Element = element,
			Tier = 2,
			Archetype = "Projectile",
			Symbols = {SYMBOLS[1], SYMBOLS[(j % #SYMBOLS) + 1]}
		})
	end
end

-- Specialty Spells
-- Specialty Spells & Standalone Gestures
registerSpell({
	ID = "InfernoBall",
	Name = "Inferno Ball",
	Description = "A large ball of fire.",
	BaseDamage = 25,
	ManaCost = 15,
	Element = "Fire",
	Tier = 1,
	Archetype = "Projectile",
	Symbols = {"Circle"}
})

registerSpell({
	ID = "ManaBolt",
	Name = "Mana Bolt",
	Description = "A quick bolt of pure mana.",
	BaseDamage = 10,
	ManaCost = 5,
	Element = "Arcane",
	Tier = 1,
	Archetype = "Projectile",
	Symbols = {"Line"}
})

registerSpell({
	ID = "Lightning",
	Name = "LightningStrike",
	Description = "A sharp strike of lightning.",
	BaseDamage = 30,
	ManaCost = 20,
	Element = "Lightning",
	Tier = 1,
	Archetype = "Projectile",
	Symbols = {"Zigzag"}
})

-- Advanced Mechanics Spells
registerSpell({
	ID = "IceFreeze",
	Name = "Ice Freeze",
	Description = "Freezes targets in an area after a delay.",
	BaseDamage = 10,
	ManaCost = 25,
	Element = "Ice",
	Tier = 2,
	Archetype = "GroundAOE",
	Radius = 15,
	Delay = 1.5,
	Symbols = {"Circle", "Circle"}
})

registerSpell({
	ID = "IcicleRain",
	Name = "Icicle Rain",
	Description = "Rains icicles in a zone, dealing damage over time.",
	BaseDamage = 5, -- per tick
	ManaCost = 30,
	Element = "Ice",
	Tier = 2,
	Archetype = "Zone",
	Radius = 20,
	Duration = 5,
	Symbols = {"Zigzag", "Line"}
})

registerSpell({
	ID = "PoisonPuddle",
	Name = "Poison Puddle",
	Description = "Creates a lingering poison zone.",
	BaseDamage = 8, -- per tick
	ManaCost = 20,
	Element = "Nature",
	Tier = 2,
	Archetype = "Zone",
	Radius = 12,
	Duration = 8,
	Symbols = {"Circle", "Zigzag"}
})

registerSpell({
	ID = "HolySmite",
	Name = "Holy Smite",
	Description = "Smites an enemy or heals/buffs an ally.",
	BaseDamage = 40,
	ManaCost = 25,
	Element = "Light",
	Tier = 2,
	Archetype = "Buff", -- Uses Buff archetype for dual targeting logic
	Symbols = {"Caret", "Line"}
})

registerSpell({
	ID = "Firebolt",
	Name = "Firebolt",
	Description = "Classic firebolt.",
	BaseDamage = 15,
	ManaCost = 10,
	Element = "Fire",
	Tier = 1,
	Archetype = "Projectile",
	Symbols = {"Circle", "Line"}
})

function SpellRegistry.GetSpellBySymbols(symbols: {string}): SpellData?
	local symbolString = table.concat(symbols, ",")
	for _, spell in pairs(SpellRegistry.Spells) do
		if table.concat(spell.Symbols, ",") == symbolString then
			return spell
		end
	end
	return nil
end

function SpellRegistry.GetSpellByID(id: string): SpellData?
	return SpellRegistry.Spells[id]
end

return SpellRegistry
