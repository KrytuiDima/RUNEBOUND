--!strict
local Types = require(script.Parent.Types)

local CraftingRecipes = {}

CraftingRecipes.WandRecipes = {
	{
		Ingredients = {["OakWood"] = 2, ["ManaCrystal"] = 1},
		Result = "ApprenticeWand",
		LevelRequired = 1
	},
	{
		Ingredients = {["ElderWood"] = 2, ["PureEssence"] = 5},
		Result = "ArchmageWand",
		LevelRequired = 50
	}
} :: {Types.Recipe}

CraftingRecipes.EnchantingStones = {
	{
		Ingredients = {["Ruby"] = 1, ["FireEssence"] = 10},
		Result = "FireStone",
		LevelRequired = 10
	},
	{
		Ingredients = {["Sapphire"] = 1, ["WaterEssence"] = 10},
		Result = "WaterStone",
		LevelRequired = 10
	}
} :: {Types.Recipe}

return CraftingRecipes
