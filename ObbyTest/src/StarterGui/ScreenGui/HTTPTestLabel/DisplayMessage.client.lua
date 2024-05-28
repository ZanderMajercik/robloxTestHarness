local rs = game:GetService("ReplicatedStorage")
local msgRe = rs:WaitForChild("MsgReceived")
local PlayersService = game:GetService("Players")
local lbl = script.Parent

local player = PlayersService.LocalPlayer

--Move function causes walking in the given direction "until stopped"
local moveVec = Vector3.new(0,0,0)

local function displayKey(data)
	lbl.Text = data.space
	--Move the character
	--TODO: scope this out based on what key came in.
	local ctrlModule = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))
	local keyboard = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"):WaitForChild("Keyboard"))
	--print(keyboard)
	if ctrlModule then
		print(require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule")))
		print(keyboard)
		print(data)
		local moveVal = 1

		--Camera Relative Motion

		-- Forward motion
		local inputState = (data.w == "up") and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.forwardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0

		-- Backward motion
		inputState = (data.s == "up") and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.backwardValue = (inputState == Enum.UserInputState.Begin) and 1 or 0

		-- Left motion
		inputState = (data.a == "up") and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0

		-- Right motion
		inputState = (data.d == "up") and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0

		-- Jump
		inputState = (data.space == "up") and Enum.UserInputState.End or Enum.UserInputState.Begin
		ctrlModule.activeController.jumpRequested = ctrlModule.activeController.jumpEnabled and (inputState == Enum.UserInputState.Begin)

		ctrlModule.activeController:UpdateMovement(inputState)
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
		--ctrlModule.moveFunction(PlayersService.LocalPlayer, ctrlModule:calculateRawMoveVector(ctrlModule.humanoid, moveVec), false)
		--ctrlModule.humanoid.Jump = true
		--ctrlModule.activeControlModule.updateJumpTest()
		--keyboard.UpdateJumpTest()
	else
		print("WHY")
	end
	--local didPass = require(httpController:UpdateJump())
end



msgRe.OnClientEvent:Connect(displayKey)