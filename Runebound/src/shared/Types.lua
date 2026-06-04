--!strict

export type Point = {
	x: number,
	y: number,
	t: number,
}

export type SpellArchetype = "Projectile" | "GroundAOE" | "Zone" | "Buff"

export type Spell = {
	ID: string,
	Name: string,
	Description: string,
	BaseDamage: number,
	ManaCost: number,
	Element: string,
	Tier: number,
	Archetype: SpellArchetype,
	Radius: number?,
	Duration: number?,
	Delay: number?,
}

export type PlayerData = {
	Level: number,
	Exp: number,
	Mana: number,
	MaxMana: number,
	Stability: number,
	Resonance: number,
	StatPoints: number, -- For raw stat points
	SkillPoints: number, -- For the skill tree upgrades
	Inventory: {[string]: number},
	SkillTree: {[string]: number},
	FirstJoinElement: string?,
	EquippedWand: string?,
}

export type Recipe = {
	Ingredients: {[string]: number},
	Result: string,
	LevelRequired: number?,
}

return {}
