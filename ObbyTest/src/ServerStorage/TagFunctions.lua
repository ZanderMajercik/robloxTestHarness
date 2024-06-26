local rs = game:GetService("ReplicatedStorage")
local TagFunctions = {}

local KILLBLOCK_COLOR = Color3.new(1,0,0)
local CHECKPOINT_COLOR = Color3.new(0,0,1)

-- Does not take "self" as a parameter so that
-- it can be called with TagFunctions["functionName"](block) syntax
function TagFunctions.KillBlock(block, overrideColor)

    if overrideColor then
        -- Set block color. For now, this is cosmetic, the agent doesn't see it.
        block.Color = KILLBLOCK_COLOR
    end

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

local trajectorySuccessEvent = rs:FindFirstChild("SuccessfulTrajectory")
function TagFunctions.Checkpoint(spawnPart, overrideColor)
    if overrideColor then
        spawnPart.Color = CHECKPOINT_COLOR
    end
    --Report a succcessful trajectory and trigger character death.
	spawnPart.Touched:connect(function(hit)
        if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
	    	local player = game.Players:GetPlayerFromCharacter(hit.Parent)

	    	-- Report the successful trajectory
	    	trajectorySuccessEvent:Fire()
	    	hit.Parent.Humanoid.Health = 0
	    end
    end)
end

return TagFunctions