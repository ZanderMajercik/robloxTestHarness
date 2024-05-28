local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get reference to remote function instance
local remoteFunction = ReplicatedStorage:FindFirstChildOfClass("RemoteFunction")

wait(10)
while true do
	remoteFunction:InvokeServer()
end