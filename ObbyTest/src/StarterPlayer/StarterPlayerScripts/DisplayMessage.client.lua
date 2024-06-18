local rs = game:GetService("ReplicatedStorage")
local rf = rs:WaitForChild("RemoteFunction")
local msgRe = rs:WaitForChild("MsgReceived")
local PlayersService = game:GetService("Players")

local re = rs:WaitForChild("SendObservations")

-- Helpful debugging functions.
local DebugHelpers = require(rs.DebugHelpers)

local player = PlayersService.LocalPlayer

local CHARACTER_HIP_HEIGHT = 3.025

local zUpFrame = CFrame.fromMatrix(
	Vector3.new(0,0,0),
	Vector3.new(-1, 0, 0),
	Vector3.new(0, 0, 1),
	Vector3.new(0, 1, 0)
)

local function convertToZUp(v)
	return zUpFrame * v
end

local function takeAction(action)
    if action.kill then
        --Received kill signal from server, meaning end of trajectory replay.
        player.Character.Humanoid.Health = 0
    end

    --DebugHelpers:print("Action", action)
    --DebugHelpers:print("character CFrame", tostring(player.Character.HumanoidRootPart.CFrame))

    if action.startPos[1] ~= 0 or action.startPos[2] ~= 0 or action.startPos[3] ~= 0 then
        local newStartPos = convertToZUp(Vector3.new(action.startPos[1], action.startPos[2], action.startPos[3] + CHARACTER_HIP_HEIGHT))
        player.Character.HumanoidRootPart.CFrame = CFrame.new(newStartPos)
        --player.Character:MoveTo(newStartPos)
        DebugHelpers:print("Y-Up start pos:", action.startPos[1], action.startPos[2], action.startPos[3])
    end


    -- print("Action", action)

	--Move the character
	local ctrlModule = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))
	local keyboard = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"):WaitForChild("Keyboard"))
	
    if ctrlModule then
		local moveVal = 1
		-- Translate the move angle to be forward relative.
		local moveAngle = action.moveAngle

		--Non-camera Relative Motion
		local forward = moveAngle == 0 or moveAngle == 1 or moveAngle == 7
		local backward = moveAngle > 2 and moveAngle < 6
		local left = moveAngle > 4
		local right = moveAngle > 0 and moveAngle < 4

		-- Account for no move action
		forward = forward and (action.moveAmount > 0)
		backward = backward and (action.moveAmount > 0)
		left = left and (action.moveAmount > 0)
		right = right and (action.moveAmount > 0)

		-- -- Forward motion
		local inputState = (forward) and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.forwardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0

		-- -- Backward motion
		inputState = (backward) and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.backwardValue = (inputState == Enum.UserInputState.Begin) and 1 or 0

		-- Left motion
		inputState = (left) and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0

		-- Right motion
		inputState = (right) and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0

		-- Jump
		inputState = (action.jump == 0) and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.jumpRequested = ctrlModule.activeController.jumpEnabled and (inputState == Enum.UserInputState.Begin)

		ctrlModule.activeController:UpdateMovement(inputState)
		ctrlModule.activeController:UpdateJump()
	else
		print("WHY")
	end
end


local function lerp(a, b, alpha)
    return a + (b - a) * alpha
end

-- An array of trajectory steps
local trajectory = {}
local trajectorySteps = 0
-- Sim time between each trajectory step as determined by payload.
local secondsPerTrajectoryStep = -1
local trajectoryActionIdx = -1
local trajectoryDelta = 0

local function setTrajectoryPosition(delta)
    local idx = math.floor(trajectoryDelta / secondsPerTrajectoryStep)
    if idx >= trajectorySteps - 1 then
        DebugHelpers:print("END OF TRAJECTORY")
        local endAction = {
            moveAmount = 0,
            moveAngle = 0,
            jump = 0,
            startPos = {0,0,0},
            kill = false
        }
        takeAction(endAction)
        return
    end
    local alpha = trajectoryDelta - (idx * secondsPerTrajectoryStep)
    trajectoryDelta += delta
    -- Assuming the first entry in the trajectory
    -- correctly sets start pos, this will automatically
    -- loop correctly by setting the agent back to where it should go.
    local actionIdx = idx + 1
    local position = {
        lerp(trajectory[actionIdx].position[1], trajectory[actionIdx + 1].position[1], alpha),
        lerp(trajectory[actionIdx].position[2], trajectory[actionIdx + 1].position[2], alpha),
        lerp(trajectory[actionIdx].position[3], trajectory[actionIdx + 1].position[3], alpha)
    }
    print(position[3])
    local action = {
        moveAmount = 0,
        moveAngle = 0,
        jump = 0,
        startPos = position,
        kill = false
    }
    takeAction(action)
end

local debugStop = false
local function executeTrajectoryAction(delta)
    if debugStop then
        return
    end
    trajectoryDelta -= delta
    print("CFRame:", player.Character.HumanoidRootPart.CFrame)
    if trajectoryDelta >= 0 then
        return
    end
    trajectoryDelta += secondsPerTrajectoryStep

    local position = {
        trajectory[trajectoryActionIdx].position[1],
        trajectory[trajectoryActionIdx].position[2],
        trajectory[trajectoryActionIdx].position[3]
    }
    local action = {
        moveAmount = tonumber(trajectory[trajectoryActionIdx].action[1]),
        moveAngle = tonumber(trajectory[trajectoryActionIdx].action[2]),
        jump = tonumber(trajectory[trajectoryActionIdx].action[4]),
        startPos = (trajectoryActionIdx == 1) and position or {0,0,0},
        kill = (trajectoryActionIdx == trajectorySteps)
    }
    if action.kill then
        debugStop = true
    end
    print("Taking Action: ", trajectoryActionIdx, time())
    takeAction(action)
    trajectoryActionIdx = (trajectoryActionIdx % trajectorySteps) + 1
end

local function triggerObs(delta)
    local response = rf:InvokeServer("postObservations", delta)
end

-- Forwarding function triggered via RemoteEvent on the Roblox Server
-- when data (serverconfig, trajectories, actions) is received from the Python server.
local triggerObsConnection = nil
local function receiveServerData(serverData)
    if serverData.msgType == "Config" then
        if serverData.MODE == "LIVE" then
            -- Start the continuous action/observation loop.
            triggerObsConnection = game:GetService("RunService").RenderStepped:Connect(triggerObs)
        elseif serverData.MODE == "PLAYBACK" then
            -- Stop the continuous action/observation loop if necessary.
            if triggerObsConnection then
                triggerObsConnection:Disconnect()
            end
            rf:InvokeServer("getTrajectory")
        end
    end

    if serverData.msgType == "Trajectory" then
        -- Store trajectory in local variable.
        DebugHelpers:print(serverData)
        trajectory = serverData.trajectory
        secondsPerTrajectoryStep = serverData.secondsPerTrajectoryStep
        trajectoryDelta = secondsPerTrajectoryStep
        trajectoryActionIdx = 1
        trajectorySteps = table.getn(trajectory)
        -- Bind trajectory action to renderstepped.
        if serverData.trajectoryMode == "POSITION_ONLY" then
            -- Playback just the positions (useful for debugging).
            game:GetService("RunService").Heartbeat:Connect(setTrajectoryPosition)
        elseif serverData.trajectoryMode == "ACTION" then
            game:GetService("RunService").Heartbeat:Connect(executeTrajectoryAction)
        else
            -- Normal action playback.
            game:GetService("RunService").Heartbeat:Connect(executeTrajectoryAction)
        end
    end

    if serverData.msgType == "Action" then
        takeAction(serverData)
    end
end

msgRe.OnClientEvent:Connect(receiveServerData)


local function moveCamera()
    -- Hardcoded camera for project figure generation.
    local cameraCFrame = CFrame.new(36.451, 14.86, 49.94) *  CFrame.angles(math.rad(-12.9), math.rad(85.832), 0)
    --CFrame.new(1.621, 27.285, 14.887) * CFrame.Angles(math.rad(-90), 0, math.rad(90))
    workspace.CurrentCamera.CFrame = cameraCFrame
end

--game:GetService("RunService"):BindToRenderStep("Send Observations", Enum.RenderPriority.Last.Value - 1, triggerObs)
--game:GetService("RunService"):BindToRenderStep("Get Action", Enum.RenderPriority.First.Value - 1, getAction)

-- TODO: restore for video recording.
-- Move the camera into observation position.
--game:GetService("RunService").RenderStepped:Connect(moveCamera)