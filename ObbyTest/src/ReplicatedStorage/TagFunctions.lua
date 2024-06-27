local TagFunctions = {}

function TagFunctions.KillBlock(block)
    print("Block", block)
	block.Touched:connect(function(hit)
		if hit and hit.Parent and (hit.Parent:FindFirstChild("Humanoid") or hit.Parent:FindFirstChild("NPCHumanoid")) then
			if hit.Parent:FindFirstChild("Humanoid") then
                local pMax = block.Position + block.size * 0.5
                local pMin = block.Position - block.size * 0.5

                local localPos = hit.Parent.HumanoidRootPart.CFrame.Position
                local trueHit = false

                -- Slightly more forgiving collision logic.
                local overMin = pMin.X < localPos.X
                local underMax = pMax.X > localPos.X
                trueHit = trueHit or (overMin and underMax) 

                overMin = pMin.Z < localPos.Z
                underMax = pMax.Z > localPos.Z
                trueHit = trueHit or (overMin and underMax) 
                print("hit", hit, "position", hit.CFrame, "localPos", localPos, "hipHeight", hit.parent.Humanoid.HipHeight)
                
                if trueHit then
                    --if trueHit and localPos.Y <= (CHARACTER_HIP_HEIGHT + 0.0004) then
                    hit.Parent.Humanoid.Health = 0
                end
			else
				hit.Parent.NPCHumanoid.Health = 0
			end
		end
    end)
end

return TagFunctions