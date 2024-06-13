local TARGET_FRAMERATE = 10
local rs = game:GetService("ReplicatedStorage")
local rf = rs:WaitForChild("RemoteFunction")


function triggerObs(delta)
        local response = rf:InvokeServer(delta)
end

function moveCamera()
    local cameraCFrame = CFrame.new(1.621, 27.285, 14.887) * CFrame.Angles(math.rad(-90), 0, math.rad(90))
    workspace.CurrentCamera.CFrame = cameraCFrame
end


--game:GetService("RunService"):BindToRenderStep("Send Observations", Enum.RenderPriority.Last.Value - 1, triggerObs)
--game:GetService("RunService"):BindToRenderStep("Get Action", Enum.RenderPriority.First.Value - 1, getAction)


-- Move the camera into observation position.
--game:GetService("RunService").RenderStepped:Connect(moveCamera)

game:GetService("RunService").RenderStepped:Connect(triggerObs)