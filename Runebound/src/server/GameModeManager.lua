--!strict
local DataManager = require(script.Parent.DataManager)

local GameModeManager = {}

type Duel = {
	Player1: Player,
	Player2: Player,
	Wager: {[string]: number},
	Status: "Pending" | "Active" | "Finished",
	StartTime: number
}

local activeDuels: {Duel} = {}

function GameModeManager.InitiateDuel(p1: Player, p2: Player, wager: {[string]: number})
	local data1 = DataManager.GetPlayerData(p1)
	local data2 = DataManager.GetPlayerData(p2)

	if not data1 or not data2 then return end

	-- Verify Wager
	for item, amount in pairs(wager) do
		if (data1.Inventory[item] or 0) < amount or (data2.Inventory[item] or 0) < amount then
			warn("Insufficient resources for wager")
			return
		end
	end

	-- Lock items in escrow (simplified)
	DataManager.UpdatePlayerData(p1, function(d)
		for item, amount in pairs(wager) do d.Inventory[item] -= amount end
		return d
	end)
	DataManager.UpdatePlayerData(p2, function(d)
		for item, amount in pairs(wager) do d.Inventory[item] -= amount end
		return d
	end)

	local duel: Duel = {
		Player1 = p1,
		Player2 = p2,
		Wager = wager,
		Status = "Active",
		StartTime = os.clock()
	}

	table.insert(activeDuels, duel)

	-- Spawn Boundary Wall
	local wall = Instance.new("Part")
	wall.Name = "DuelBoundary"
	wall.Shape = Enum.PartType.Ball
	wall.Size = Vector3.new(50, 50, 50)
	wall.Position = p1.Character.PrimaryPart.Position:Lerp(p2.Character.PrimaryPart.Position, 0.5)
	wall.Transparency = 0.8
	wall.CanCollide = true
	wall.Anchored = true
	wall.Parent = workspace

	-- Monitor Health
	task.spawn(function()
		while duel.Status == "Active" do
			local h1 = p1.Character:FindFirstChild("Humanoid")
			local h2 = p2.Character:FindFirstChild("Humanoid")

			if h1 and h1.Health <= 0 then
				GameModeManager.EndDuel(duel, p2)
				break
			elseif h2 and h2.Health <= 0 then
				GameModeManager.EndDuel(duel, p1)
				break
			end
			task.wait(1)
		end
		wall:Destroy()
	end)
end

function GameModeManager.EndDuel(duel: Duel, winner: Player)
	duel.Status = "Finished"

	-- Award items to winner
	DataManager.UpdatePlayerData(winner, function(d)
		for item, amount in pairs(duel.Wager) do
			d.Inventory[item] = (d.Inventory[item] or 0) + (amount * 2)
		end
		return d
	end)

	print("Duel ended. Winner:", winner.Name)
end

return GameModeManager
