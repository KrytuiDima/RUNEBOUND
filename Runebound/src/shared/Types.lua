--!strict

export type Point = {
	x: number,
	y: number,
	t: number,
}

export type Spell = {
	ID: string,
	Name: string,
	Description: string,
	BaseDamage: number,
	ManaCost: number,
	Element: string,
	Tier: number,
}

export type PlayerData = {
	Level: number,
	Exp: number,
	Mana: number,
	MaxMana: number,
	Stability: number,
	Resonance: number,
	Inventory: {[string]: number},
	SkillTree: {[string]: number},
	FirstJoinElement: string?,
}

export type Recipe = {
	Ingredients: {[string]: number},
	Result: string,
	LevelRequired: number?,
}

return {}
