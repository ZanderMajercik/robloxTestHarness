local TARGET_FRAMERATE = 10
local rs = game:GetService("ReplicatedStorage")
local rf = rs:WaitForChild("RemoteFunction")

--settings().Studio.ScriptTimeoutLength = -1
--settings().Studio.ScriptTimeoutLength = -1
--local success = false

function getAction(delta)
        local response = rf:InvokeServer(true, delta)
        -- --math.max(outstandingRequests - 1, 0)
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

function triggerObs(delta)
        local response = rf:InvokeServer(false, delta)
         --math.min(outstandingRequests + 1, MAX_OUTSTANDING)
end

function moveCamera()
    local cameraCFrame = CFrame.new(1.621, 27.285, 14.887) * CFrame.Angles(math.rad(-90), 0, math.rad(90))
    workspace.CurrentCamera.CFrame = cameraCFrame
end


--game:GetService("RunService"):BindToRenderStep("Send Observations", Enum.RenderPriority.Last.Value - 1, triggerObs)
--game:GetService("RunService"):BindToRenderStep("Get Action", Enum.RenderPriority.First.Value - 1, getAction)


game:GetService("RunService").RenderStepped:Connect(moveCamera)

--game:GetService("RunService").RenderStepped:Connect(getAction)
game:GetService("RunService").RenderStepped:Connect(triggerObs)

-- Exact sync through client events.
--wait(5)
--rf:InvokeServer(true)

-- Framerate limit so HTTPS can keep up.
--while true do
--    game:GetService("RunService").RenderStepped:Wait()
--    t0 = tick()
--    game:GetService("RunService").Heartbeat:Wait()
--    repeat until t0 + 1/TARGET_FRAMERATE < tick()
--end