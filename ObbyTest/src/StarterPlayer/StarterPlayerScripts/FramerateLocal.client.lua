local TARGET_FRAMERATE = 10
local rs = game:GetService("ReplicatedStorage")
local rf = rs:WaitForChild("RemoteFunction")

--settings().Studio.ScriptTimeoutLength = -1
--settings().Studio.ScriptTimeoutLength = -1
--local success = false
function getAction()
    local doAction = true
    local response = rf:InvokeServer(doAction)
    --success = false
	--wait(1)
	--print("Working?")
    --rf:InvokeServer()
    --print("Waiting On server")

    --task.spawn(function()
    -- repeat 
    --     game:GetService("RunService").Heartbeat:Wait()
    --     success = rf:InvokeServer()
    -- until success
    --end)
    --game:GetService("RunService").RenderStepped:Wait()

	--repeat until success 
    --t0 + 1/TARGET_FRAMERATE < tick()
	--repeat until success
end

function triggerObs()
    local doAction = false
    local response = rf:InvokeServer(doAction)
end


--game:GetService("RunService"):BindToRenderStep("Send Observations", Enum.RenderPriority.First.Value - 1, triggerObs)
--game:GetService("RunService"):BindToRenderStep("Get Action", Enum.RenderPriority.Input.Value - 1, getAction)

-- TODO: restore
game:GetService("RunService").RenderStepped:Connect(getAction)
game:GetService("RunService").RenderStepped:Connect(triggerObs)

-- Framerate limit so HTTPS can keep up.
while true do
    game:GetService("RunService").RenderStepped:Wait()
    t0 = tick()
    game:GetService("RunService").Heartbeat:Wait()
    repeat until t0 + 1/TARGET_FRAMERATE < tick()
end