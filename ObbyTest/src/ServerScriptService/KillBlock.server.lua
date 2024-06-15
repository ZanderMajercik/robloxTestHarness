--VSCode: Collect and process hit detection for all kill blocks.
local CollectionService = game:GetService("CollectionService")

for i, block in CollectionService:GetTagged("KillBlock") do
	block.Touched:connect(function(hit)
		if hit and hit.Parent and (hit.Parent:FindFirstChild("Humanoid") or hit.Parent:FindFirstChild("NPCHumanoid")) then
			if hit.Parent:FindFirstChild("Humanoid") then
                local pMax = block.Position + block.size * 0.5
                local pMin = block.Position - block.size * 0.5

                local localPos = hit.Parent.HumanoidRootPart.CFrame.Position
                local trueHit = false

                -- Forgive a little bit: check if xz position is within lava bounds.
                local overMin = pMin.X < localPos.X
                local underMax = pMax.X > localPos.X
                trueHit = trueHit or (overMin and underMax) 

                overMin = pMin.Z < localPos.Z
                underMax = pMax.Z > localPos.Z
                trueHit = trueHit or (overMin and underMax) 
                
                if trueHit and localPos.Y <= 3.0004 then
                    print("hit", hit, "position", hit.CFrame)
                    hit.Parent.Humanoid.Health = 0
                end
			else
				hit.Parent.NPCHumanoid.Health = 0
			end
		end
	end)
end