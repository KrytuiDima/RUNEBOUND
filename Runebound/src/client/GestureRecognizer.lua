--!strict
-- $1 Unistroke Recognizer Implementation in Luau
-- Optimized for Roblox

local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Types"))

local GestureRecognizer = {}

local NUM_POINTS = 64
local SQUARE_SIZE = 250
local ORIGIN = Vector2.new(0, 0)
local PHI = 0.5 * (-1 + math.sqrt(5)) -- Golden Ratio

type Template = {
	Name: string,
	Points: {Vector2}
}

local Templates: {Template} = {}

-- Utility functions
local function Distance(p1: Vector2, p2: Vector2)
	return (p1 - p2).Magnitude
end

local function PathDistance(pts1: {Vector2}, pts2: {Vector2})
	local d = 0
	for i = 1, #pts1 do
		d = d + Distance(pts1[i], pts2[i])
	end
	return d / #pts1
end

local function GetPathLength(points: {Vector2})
	local d = 0
	for i = 2, #points do
		d = d + Distance(points[i - 1], points[i])
	end
	return d
end

local function Resample(points: {Vector2}, n: number)
	local I = GetPathLength(points) / (n - 1)
	local D = 0
	local newPoints = {points[1]}
	local i = 2
	while i <= #points do
		local d = Distance(points[i - 1], points[i])
		if D + d >= I then
			local q = points[i - 1] + ((I - D) / d) * (points[i] - points[i - 1])
			table.insert(newPoints, q)
			table.insert(points, i, q)
			D = 0
		else
			D = D + d
		end
		i = i + 1
	end
	if #newPoints == n - 1 then
		table.insert(newPoints, points[#points])
	end
	return newPoints
end

local function Centroid(points: {Vector2})
	local x, y = 0, 0
	for _, p in ipairs(points) do
		x = x + p.X
		y = y + p.Y
	end
	return Vector2.new(x / #points, y / #points)
end

local function RotateBy(points: {Vector2}, radians: number)
	local c = Centroid(points)
	local cos = math.cos(radians)
	local sin = math.sin(radians)
	local newPoints = {}
	for _, p in ipairs(points) do
		local dx = p.X - c.X
		local dy = p.Y - c.Y
		table.insert(newPoints, Vector2.new(dx * cos - dy * sin + c.X, dx * sin + dy * cos + c.Y))
	end
	return newPoints
end

local function IndicativeAngle(points: {Vector2})
	local c = Centroid(points)
	return math.atan2(c.Y - points[1].Y, c.X - points[1].X)
end

local function ScaleTo(points: {Vector2}, size: number)
	local minX, maxX = math.huge, -math.huge
	local minY, maxY = math.huge, -math.huge
	for _, p in ipairs(points) do
		minX = math.min(minX, p.X)
		maxX = math.max(maxX, p.X)
		minY = math.min(minY, p.Y)
		maxY = math.max(maxY, p.Y)
	end
	local width = maxX - minX
	local height = maxY - minY
	local newPoints = {}
	for _, p in ipairs(points) do
		table.insert(newPoints, Vector2.new(p.X * (size / width), p.Y * (size / height)))
	end
	return newPoints
end

local function TranslateTo(points: {Vector2}, k: Vector2)
	local c = Centroid(points)
	local newPoints = {}
	for _, p in ipairs(points) do
		table.insert(newPoints, p + (k - c))
	end
	return newPoints
end

local function DistanceAtAngle(points: {Vector2}, T: Template, radians: number)
	local newPoints = RotateBy(points, radians)
	return PathDistance(newPoints, T.Points)
end

local function DistanceAtBestAngle(points: {Vector2}, T: Template, a: number, b: number, threshold: number)
	local x1 = PHI * a + (1 - PHI) * b
	local f1 = DistanceAtAngle(points, T, x1)
	local x2 = (1 - PHI) * a + PHI * b
	local f2 = DistanceAtAngle(points, T, x2)
	while math.abs(b - a) > threshold do
		if f1 < f2 then
			b = x2
			x2 = x1
			f2 = f1
			x1 = PHI * a + (1 - PHI) * b
			f1 = DistanceAtAngle(points, T, x1)
		else
			a = x1
			x1 = x2
			f1 = f2
			x2 = (1 - PHI) * a + PHI * b
			f2 = DistanceAtAngle(points, T, x2)
		end
	end
	return math.min(f1, f2)
end

function GestureRecognizer.Normalize(points: {Vector2})
	local pts = Resample(points, NUM_POINTS)
	local radians = IndicativeAngle(pts)
	pts = RotateBy(pts, -radians)
	pts = ScaleTo(pts, SQUARE_SIZE)
	pts = TranslateTo(pts, ORIGIN)
	return pts
end

function GestureRecognizer.AddTemplate(name: string, points: {Vector2})
	table.insert(Templates, {
		Name = name,
		Points = GestureRecognizer.Normalize(points)
	})
end

function GestureRecognizer.Recognize(points: {Vector2})
	local pts = GestureRecognizer.Normalize(points)
	local b = math.huge
	local t = nil
	for _, template in ipairs(Templates) do
		local d = DistanceAtBestAngle(pts, template, -math.rad(45), math.rad(45), math.rad(2))
		if d < b then
			b = d
			t = template
		end
	end
	local score = 1 - b / (0.5 * math.sqrt(SQUARE_SIZE ^ 2 + SQUARE_SIZE ^ 2))
	return t and t.Name or "Unknown", score
end

-- Load Default Templates
GestureRecognizer.AddTemplate("Circle", (function()
	local pts = {}
	for i = 0, 360, 10 do
		table.insert(pts, Vector2.new(math.cos(math.rad(i)), math.sin(math.rad(i))))
	end
	return pts
end)())

GestureRecognizer.AddTemplate("Line", {Vector2.new(0, 0), Vector2.new(100, 0)})
GestureRecognizer.AddTemplate("Triangle", {Vector2.new(0, 100), Vector2.new(50, 0), Vector2.new(100, 100), Vector2.new(0, 100)})
GestureRecognizer.AddTemplate("Zigzag", {Vector2.new(0, 0), Vector2.new(50, 50), Vector2.new(100, 0), Vector2.new(150, 50)})

return GestureRecognizer
