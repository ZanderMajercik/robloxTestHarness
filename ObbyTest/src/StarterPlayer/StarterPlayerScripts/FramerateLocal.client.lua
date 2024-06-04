local TARGET_FRAMERATE = 1
local rs = game:GetService("ReplicatedStorage")
local rf = rs:WaitForChild("RemoteFunction")

--settings().Studio.ScriptTimeoutLength = -1
--settings().Studio.ScriptTimeoutLength = -1
--local success = false
function getAction()
    rf:InvokeServer()
    --success = false
	--wait(1)
	--print("Working?")
    --rf:InvokeServer()
    --print("Waiting On server")

    --task.spawn(function()
    -- repeat 
    --     game:GetService("RunService").RenderStepped:Wait()
    --     game:GetService("RunService").Heartbeat:Wait()
    --     success = rf:InvokeServer()
    -- until success
    --end)

	--repeat until success 
    --t0 + 1/TARGET_FRAMERATE < tick()
	--repeat until success
end

game:GetService("RunService").RenderStepped:Connect(getAction)