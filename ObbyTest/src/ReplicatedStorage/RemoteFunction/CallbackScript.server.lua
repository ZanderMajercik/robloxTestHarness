local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get reference to remote function instance
local remoteFunction = ReplicatedStorage:FindFirstChildOfClass("RemoteFunction")

-- Callback function
local function printOnServer()
	wait(10)
	print("ServerPrintCalled")
end

-- Set function as remote function's callback
remoteFunction.OnServerInvoke = printOnServer