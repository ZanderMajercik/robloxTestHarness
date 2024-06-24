local CollectionService = game:GetService("CollectionService")
local httpSrv = game:GetService("HttpService")
local rs = game:GetService("ReplicatedStorage")

local baseURL = "http://localhost:5000/"
local currentTrajectory = require(rs.TrajectoryState)

local trajectorySuccessEvent = rs:FindFirstChild("SuccessfulTrajectory")


local function killFunc(hit)
	if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)

		-- Report the successful trajectory
		trajectorySuccessEvent:Fire()
		hit.Parent.Humanoid.Health = 0
        -- if hit.Parent.Humanoid.Health == 0 then
        --     return
        -- end
        --local episode = {
        --    success = true
        --    -- TODO: send observations at full Roblox granularity (not just for every action but for every timestep)
        --}
        ---- Send the successful trajectory information.
        --httpSrv:PostAsync(baseURL .. "reportEpisode", httpSrv:JSONEncode(episode))
		--if hit.Parent.Humanoid.Health > 0 then
		--	currentTrajectory.trajectory.success = true
		--	-- For now, checkpoint kills you
		--	hit.Parent.Humanoid.Health = 0
		--end



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