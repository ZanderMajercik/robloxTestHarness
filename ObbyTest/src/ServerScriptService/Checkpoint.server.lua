--VSCode: Collect and process hit detection for all kill blocks.
local CollectionService = game:GetService("CollectionService")


local function killFunc(hit)
	if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)

		-- For now, checkpoint kills you
		-- TODO: implement a counter that tracks success rate when you leave it running.
		hit.Parent.Humanoid.Health = 0


		--TODO: restore, logic to create new checkpoint data, will re-enable when testing full game.
		--local checkpointData = game.ServerStorage:FindFirstChild("CheckpointData")
		--if not checkpointData then
		--	checkpointData = Instance.new("Model", game.ServerStorage)
		--	checkpointData.Name = "CheckpointData"
		--end

		--local checkpoint = checkpointData:FindFirstChild(tostring(player.userId))
		--if not checkpoint then
		--	checkpoint = Instance.new("ObjectValue", checkpointData)
		--	checkpoint.Name = tostring(player.userId)
		--
		--	player.CharacterAdded:connect(function(character)
		--		wait()
		--		character:WaitForChild("HumanoidRootPart").CFrame = game.ServerStorage.CheckpointData[tostring(player.userId)].Value.CFrame + Vector3.new(0, 4, 0)
		--	end)
		--end
		--
		--checkpoint.Value = spawn
	end
end

workspace.SimpleLevel.ss.Touched:connect(killFunc)

for i, spawnPart in CollectionService:GetTagged("Checkpoint") do
	spawnPart.Touched:connect(killFunc)
end