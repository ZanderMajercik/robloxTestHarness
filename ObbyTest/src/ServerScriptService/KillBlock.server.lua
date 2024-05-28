--VSCode: Collect and process hit detection for all kill blocks.
local CollectionService = game:GetService("CollectionService")

for i, block in CollectionService:GetTagged("KillBlock") do
	block.Touched:connect(function(hit)
		if hit and hit.Parent and (hit.Parent:FindFirstChild("Humanoid") or hit.Parent:FindFirstChild("NPCHumanoid")) then
			if hit.Parent:FindFirstChild("Humanoid") then
				hit.Parent.Humanoid.Health = 0
			else
				hit.Parent.NPCHumanoid.Health = 0
			end
		end
	end)
end