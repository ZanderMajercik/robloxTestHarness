local rs = game:GetService("ReplicatedStorage")
local msgRe = rs:WaitForChild("MsgReceived")
local PlayersService = game:GetService("Players")

local re = rs:WaitForChild("SendObservations")


local player = PlayersService.LocalPlayer

local function displayKey(data)
	--Move the character
	--TODO: scope this out based on what key came in.
	local ctrlModule = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))
	local keyboard = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"):WaitForChild("Keyboard"))
	--print(keyboard)
	if ctrlModule then
		-- print(require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule")))
		-- print(keyboard)
		-- print("ACTIONS")
		-- print(data)
		local moveVal = 1


		-- actionJson = {
		-- 	"moveAmount" : 0,
		-- 	"moveAngle" : 0,
		-- 	"jump" : 0
		-- }
		
		-- Translate the move angle to be forward relative.
		local moveAngle = data.moveAngle

		--Non-camera Relative Motion
		local forward = moveAngle == 0 or moveAngle == 1 or moveAngle == 7
		local backward = moveAngle > 2 and moveAngle < 6
		local left = moveAngle > 4
		local right = moveAngle > 0 and moveAngle < 4

		-- Account for no move action
		forward = forward and (data.moveAmount > 0)
		backward = backward and (data.moveAmount > 0)
		left = left and (data.moveAmount > 0)
		right = right and (data.moveAmount > 0)

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
		inputState = (data.jump == 0) and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.jumpRequested = ctrlModule.activeController.jumpEnabled and (inputState == Enum.UserInputState.Begin)

		ctrlModule.activeController:UpdateMovement(inputState)
		--ctrlModule.moveFunction(PlayersService.LocalPlayer, ctrlModule:calculateRawMoveVector(ctrlModule.humanoid, moveVec), false)

		ctrlModule.activeController:UpdateJump()

		--if data == "d" then
		--	ctrlModule.activeController.forwardValue = -1
		--	ctrlModule.activeController:UpdateMovement(Enum.UserInputState.Begin)
		--	--moveVec = Vector3.new(moveVal,0,0)
		--elseif data == "a" then
		--	moveVec = Vector3.new(-moveVal,0,0)
		--elseif data == "w" then
		--	moveVec = Vector3.new(0,0,-moveVal)
		--elseif data == "s" then
		--	moveVec = Vector3.new(0,0,moveVal)
		--elseif data == "space" then
		--	keyboard.updateJumpTest()
		--	ctrlModule.humanoid.Jump = keyboard.isJumping
		--end
		--ctrlModule.activeController.moveVector = moveVec
		--ctrlModule.humanoid.Jump = true
		--ctrlModule.activeControlModule.updateJumpTest()
		--keyboard.UpdateJumpTest()
	else
		print("WHY")
	end
	--local didPass = require(httpController:UpdateJump())
    
    -- TODO: restore for exact sync.
    --re:FireServer(false)
end



msgRe.OnClientEvent:Connect(displayKey)

---while true do
---    game:GetService("RunService").RenderStepped:Wait()
---    game:GetService("RunService").Heartbeat:Wait()
---    if (displayKey(data)) then
---        break
---    end 
---end