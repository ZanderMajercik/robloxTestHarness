
--- From https://www.youtube.com/watch?v=Sc6toYU0yiQ

local NPC = script.Parent
local debounce = false

function FindPlayer(Position)
	local List = game.Workspace:GetChildren()
	local Torso = nil
	local Distance = 50
	local HumanoidRootPart = nil
	local Humanoid = nil
	local Player = nil

	for i = 1, #List do
		Player = List[i]
		if (Player.ClassName == "Model") and (Player ~= script.Parent) then
			HumanoidRootPart = Player:FindFirstChild("HumanoidRootPart")
			Humanoid = Player:FindFirstChild("Humanoid")
			if (HumanoidRootPart ~= nil) and (Humanoid ~= nil) and (Humanoid.Health > 0) then
				if (HumanoidRootPart.Position - Position).Magnitude < Distance then
					Torso = HumanoidRootPart
					Distance = (HumanoidRootPart.Position - Position).Magnitude
				end
			end
		end
	end
	return Torso
end

function findClosestPart(Position)
	local target = nil
	for _, p in game.Workspace.ObbyStructure:GetChildren() do
		if p:IsA("Part") then
			print("found part")
			local distance = 50
			if (p.Position - Position).Magnitude < distance then
				target = p
				distance = (p.Position - Position).Magnitude
			end
		else
			print("No part")
		end
	end
	return target
end

--function saveHighScore(score)
--	print("High score: "..tostring(score))
--	local file,err = io.open("high_score.txt",'w')
--	if file then
--		file:write(tostring(score))
--		file:close()
--	else
--		print("error:", err) -- not so hard?
--	end
--end

--saveHighScore("test")

while true do
	wait(1)
	--local Target = FindPlayer(script.Parent.HumanoidRootPart.Position)
	local Target = findClosestPart(script.Parent.HumanoidRootPart.Position)
	if Target ~= nil then
		print("Found")
		script.Parent.NPCHumanoid:MoveTo(Target.Position, Target)
	else
		print("Not Found")
	end
	--script.Parent.NPCHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end