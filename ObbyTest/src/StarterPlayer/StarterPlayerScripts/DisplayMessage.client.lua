local rs = game:GetService("ReplicatedStorage")
local rf = rs:WaitForChild("RemoteFunction")
local msgRe = rs:WaitForChild("MsgReceived")
local PlayersService = game:GetService("Players")

local re = rs:WaitForChild("SendObservations")

-- Helpful debugging functions.
local DebugHelpers = require(rs.DebugHelpers)

local player = PlayersService.LocalPlayer

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

    print("character CFrame", tostring(player.Character.HumanoidRootPart.CFrame))

    if action.startPos[1] ~= 0 or action.startPos[2] ~= 0 or action.startPos[3] ~= 0 then
        local newStartPos = convertToZUp(Vector3.new(action.startPos[1], action.startPos[2], action.startPos[3] + 3)) -- TODO: restore
        player.Character.HumanoidRootPart.CFrame = CFrame.new(newStartPos)
        --player.Character:MoveTo(newStartPos)
        DebugHelpers:print("Y-Up start pos:", action.startPos[1], action.startPos[2], action.startPos[3])
    end


    -- print("Action", action)

	-- --Move the character
	-- local ctrlModule = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))
	-- local keyboard = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"):WaitForChild("Keyboard"))
	
    -- if ctrlModule then
	-- 	local moveVal = 1

    --     -- actionJson = {
	-- 	-- 	"moveAmount" : 0,
	-- 	-- 	"moveAngle" : 0,
	-- 	-- 	"jump" : 0
	-- 	-- }
		
	-- 	-- Translate the move angle to be forward relative.
	-- 	local moveAngle = action.moveAngle

	-- 	--Non-camera Relative Motion
	-- 	local forward = moveAngle == 0 or moveAngle == 1 or moveAngle == 7
	-- 	local backward = moveAngle > 2 and moveAngle < 6
	-- 	local left = moveAngle > 4
	-- 	local right = moveAngle > 0 and moveAngle < 4

	-- 	-- Account for no move action
	-- 	forward = forward and (action.moveAmount > 0)
	-- 	backward = backward and (action.moveAmount > 0)
	-- 	left = left and (action.moveAmount > 0)
	-- 	right = right and (action.moveAmount > 0)

	-- 	-- -- Forward motion
	-- 	local inputState = (forward) and Enum.UserInputState.End or Enum.UserInputState.Begin
	-- 	ctrlModule.activeController.forwardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0

	-- 	-- -- Backward motion
	-- 	inputState = (backward) and Enum.UserInputState.End or Enum.UserInputState.Begin
	-- 	ctrlModule.activeController.backwardValue = (inputState == Enum.UserInputState.Begin) and 1 or 0

	-- 	-- Left motion
	-- 	inputState = (left) and Enum.UserInputState.End or Enum.UserInputState.Begin
	-- 	ctrlModule.activeController.leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0

	-- 	-- Right motion
	-- 	inputState = (right) and Enum.UserInputState.End or Enum.UserInputState.Begin
	-- 	ctrlModule.activeController.rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0

	-- 	-- Jump
	-- 	inputState = (action.jump == 0) and Enum.UserInputState.End or Enum.UserInputState.Begin
	-- 	ctrlModule.activeController.jumpRequested = ctrlModule.activeController.jumpEnabled and (inputState == Enum.UserInputState.Begin)

	-- 	ctrlModule.activeController:UpdateMovement(inputState)
	-- 	--ctrlModule.moveFunction(PlayersService.LocalPlayer, ctrlModule:calculateRawMoveVector(ctrlModule.humanoid, moveVec), false)

	-- 	ctrlModule.activeController:UpdateJump()

	-- 	--if data == "d" then
	-- 	--	ctrlModule.activeController.forwardValue = -1
	-- 	--	ctrlModule.activeController:UpdateMovement(Enum.UserInputState.Begin)
	-- 	--	--moveVec = Vector3.new(moveVal,0,0)
	-- 	--elseif data == "a" then
	-- 	--	moveVec = Vector3.new(-moveVal,0,0)
	-- 	--elseif data == "w" then
	-- 	--	moveVec = Vector3.new(0,0,-moveVal)
	-- 	--elseif data == "s" then
	-- 	--	moveVec = Vector3.new(0,0,moveVal)
	-- 	--elseif data == "space" then
	-- 	--	keyboard.updateJumpTest()
	-- 	--	ctrlModule.humanoid.Jump = keyboard.isJumping
	-- 	--end
	-- 	--ctrlModule.activeController.moveVector = moveVec
	-- 	--ctrlModule.humanoid.Jump = true
	-- 	--ctrlModule.activeControlModule.updateJumpTest()
	-- 	--keyboard.UpdateJumpTest()
	-- else
	-- 	print("WHY")
	-- end
	--local didPass = require(httpController:UpdateJump())
    
    -- TODO: restore for exact sync.
    --re:FireServer(false)
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
local function executeTrajectoryAction(delta)
    local idx = math.floor(trajectoryDelta / secondsPerTrajectoryStep)
    if idx >= trajectorySteps - 1 then
        return
    end
    local alpha = trajectoryDelta - (idx * secondsPerTrajectoryStep)
    trajectoryDelta += delta

    -- Assuming the first entry in the trajectory
    -- correctly sets start pos, this will automatically
    -- loop correctly by setting the agent back to where it should go.
    local position = {
        lerp(trajectory[idx + 1].position[1], trajectory[idx + 2].position[1], alpha),
        lerp(trajectory[idx + 1].position[2], trajectory[idx + 2].position[2], alpha),
        lerp(trajectory[idx + 1].position[3], trajectory[idx + 2].position[3], alpha)
    }
    local action = {
        moveAmount = tonumber(trajectory[trajectoryActionIdx].action[1]),
        moveAngle = tonumber(trajectory[trajectoryActionIdx].action[2]),
        jump = tonumber(trajectory[trajectoryActionIdx].action[4]),
        startPos = position, -- TODO: restore, always just set position.
        --(trajectoryActionIdx == 1) and position or {0,0,0},
        kill = (idx == trajectorySteps)
    }
    takeAction(action)
end

local function triggerObs(delta)
    local response = rf:InvokeServer(delta)
end

-- Forwarding function triggered via RemoteEvent on the Roblox Server
-- when data (trajectories or actions) is received from the Python server.

-- TODO: restore
--local triggerObsConnection = game:GetService("RunService").RenderStepped:Connect(triggerObs)

local function receieveActionData(actionSequence)

    if actionSequence.isTrajectory then
        -- TODO: restore
        --triggerObsConnection:Disconnect()
        -- Store trajectory in local variable.
        print(actionSequence)
        trajectory = actionSequence.trajectory
        secondsPerTrajectoryStep = actionSequence.secondsPerTrajectoryStep
        trajectoryDelta = 0 --secondsPerTrajectoryStep
        trajectoryActionIdx = 1
        trajectorySteps = table.getn(trajectory)
        -- Bind trajectory action to renderstepped.
        game:GetService("RunService").Heartbeat:Connect(executeTrajectoryAction)
        return
    end

    -- Take the action from the data
    takeAction(actionSequence)
end

msgRe.OnClientEvent:Connect(receieveActionData)


function moveCamera()
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