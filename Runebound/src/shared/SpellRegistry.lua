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
			Symbols = {SYMBOLS[1], SYMBOLS[(j % #SYMBOLS) + 1]}
		})
	end
end

-- Specialty Spells
registerSpell({
	ID = "Firebolt",
	Name = "Firebolt",
	Description = "Classic firebolt.",
	BaseDamage = 15,
	ManaCost = 10,
	Element = "Fire",
	Tier = 1,
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
