script.Parent.Touched:connect(function(hit)
	if hit and hit.Parent and (hit.Parent:FindFirstChild("Humanoid") or hit.Parent:FindFirstChild("NPCHumanoid")) then
		hit.Parent.Humanoid.Health = 0
	end
end)