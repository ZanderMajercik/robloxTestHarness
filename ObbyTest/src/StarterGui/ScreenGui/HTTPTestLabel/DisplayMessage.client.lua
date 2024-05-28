local rs = game:GetService("ReplicatedStorage")
local msgRe = rs:WaitForChild("MsgReceived")
local PlayersService = game:GetService("Players")
local lbl = script.Parent

local player = PlayersService.LocalPlayer

local function displayKey(data)
	lbl.Text = data
	--Move the character
	--TODO: scope this out based on what key came in.
	local ctrlModule = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))
	local keyboard = require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"):WaitForChild("Keyboard"))
	--print(keyboard)
	if ctrlModule then
		print(require(PlayersService.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule")))
		local moveVec = Vector3.new(0,0,0)
		local moveVal = 100
		if data == "d" then
			moveVec = Vector3.new(moveVal,0,0)
		elseif data == "a" then
			moveVec = Vector3.new(-moveVal,0,0)
		elseif data == "w" then
			moveVec = Vector3.new(0,0,-moveVal)
		elseif data == "s" then
			moveVec = Vector3.new(0,0,moveVal)
		elseif data == "space" then
			ctrlModule.humanoid.Jump = true
		end
		ctrlModule.moveFunction(PlayersService.LocalPlayer, ctrlModule:calculateRawMoveVector(ctrlModule.humanoid, moveVec), false)
		--ctrlModule.humanoid.Jump = true
		--ctrlModule.activeControlModule.updateJumpTest()
		--keyboard.UpdateJumpTest()
	else
		print("WHY")
	end
	--local didPass = require(httpController:UpdateJump())
end



msgRe.OnClientEvent:Connect(displayKey)