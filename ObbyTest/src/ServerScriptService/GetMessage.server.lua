local rs = game:GetService("ReplicatedStorage")
local msgRe = rs:WaitForChild("MsgReceived")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local rf = rs:WaitForChild("RemoteFunction")

local httpSrv = game:GetService("HttpService")

local re = rs:WaitForChild("SendObservations")


local function decodeWrapper(stringtodecode)
	return httpSrv:JSONDecode(stringtodecode)
end

-- Helpful debugging functions.
local DebugHelpers = require(rs.DebugHelpers)

local firstPlayer = nil

--local outstandingRequests = 1
--local MAX_OUTSTANDING = 1

local frameCounter = 0
local MAX_FRAMES = 15
local totalSend = 0
local url = "http://localhost:5000/index.json"

local secondsPerHTTPRequest = 60 / 500

local zUpFrame = CFrame.fromMatrix(
	Vector3.new(0,0,0),
	Vector3.new(-1, 0, 0),
	Vector3.new(0, 0, 1),
	Vector3.new(0, 1, 0)
)

local function convertToZUp(v)
	return zUpFrame * v
end

local function lidarObservations()
    local numLidarSamples = 30
    local maxDist = 200
    local origin = firstPlayer.Character:FindFirstChild("HumanoidRootPart").Position
    local lidarObs = {}

    local params = RaycastParams.new()
    -- Prevent self-intersection by filtering the player model.
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {firstPlayer.Character}
    for i = 0, numLidarSamples, 1 do
        -- TODO: madrona starts the raycast offset by pi/2 but roblox doesn't need this factor
        -- to make the observations match.
        local theta = 2 * math.pi * (i / numLidarSamples) + math.pi * 0.5
        -- Direction encodes ray distance.
        --Account for Roblox coordinate system.
        local direction = Vector3.new(-math.cos(theta), 0, math.sin(theta)) * maxDist
        local rayResult = workspace:Raycast(origin, direction, params)
        lidarObs[i] = {rayResult.Distance, rayResult.Instance.Name}
    end
    return lidarObs
end


local function getAABB()
	local pMin = Vector3.new(100,100,100)
	local pMax = Vector3.new(-100,-100,-100)
	for i, wall in CollectionService:GetTagged("Bounds") do
        if wall:IsDescendantOf(workspace) then
            local pos = convertToZUp(wall.CFrame.Position)
            pMin = pMin:Min(Vector3.new(pos.X, pos.Y, pos.Z - wall.Size.Y * 0.5))
            pMax = pMax:Max(Vector3.new(pos.X, pos.Y, pos.Z + wall.Size.Y * 0.5))
        end
	end
	
	return { 
		{pMin.X, pMin.Y, pMin.Z},
		{pMax.X, pMax.Y, pMax.Z}
	}
end

local function goalPosition()
    for i, goal in CollectionService:GetTagged("Goal") do
        if goal:IsDescendantOf(workspace) then
            return goal.CFrame.Position 
        end
    end
end

local function lavaObservations()
    DebugHelpers:print("GETTING LAVA")
    local lavaObs = {}
    local idx = 1
    for i, lava in CollectionService:GetTagged("KillBlock") do
        if lava:IsDescendantOf(workspace) then
            DebugHelpers:print("found lava")
            local orientationZUp = convertToZUp(lava.Position)
            local sizeZUp = convertToZUp(lava.Size)
            lavaObs[idx] = {orientationZUp.X, orientationZUp.Y, orientationZUp.Z,
            math.abs(sizeZUp.X) * 0.5, math.abs(sizeZUp.Y) * 0.5, math.abs(sizeZUp.Z) * 0.5}
            idx += 1
        end
    end
    return lavaObs
end

local httpDelta = secondsPerHTTPRequest
local function postObservations(delta)
    --frameCounter = (frameCounter + 1) % MAX_FRAMES
    --if frameCounter ~= 0 then
    --    return
    --end
    --DebugHelpers:print("delta (POST)", httpDelta)
    httpDelta -= delta
    if httpDelta > 0 then
        return
    end
    httpDelta = secondsPerHTTPRequest
    totalSend += 1
	local AABB = getAABB()
	local posZUp = convertToZUp(firstPlayer.Character:FindFirstChild("HumanoidRootPart").Position)
    local goalPosZUp = convertToZUp(goalPosition())

    local lObs = lavaObservations()
    DebugHelpers:print(lObs)
	--Collect the player centric observations.
	local obs = {
		roomAABB = AABB,
		playerPos = {posZUp.X, posZUp.Y, posZUp.Z},
        goalPos = {goalPosZUp.X, goalPosZUp.Y, goalPosZUp.Z},
        lava = lObs,
        --lidar = lidarObservations(),
        obsTime = tick() --Profile
	}
	local response = httpSrv:PostAsync(url, httpSrv:JSONEncode(obs), Enum.HttpContentType.ApplicationJson, false)
    DebugHelpers:print("TOTAL SEND (POST): ", totalSend, time(), delta)
    local b, data =  pcall(decodeWrapper, response)
    --DebugHelpers:print("Delay: ", tick() - data["obsTime"])
    if b then
    	--DebugHelpers:print("data = ", data)
    	--local str = tostring(data.key)
    	msgRe:FireClient(firstPlayer, data)
        return true
    else
    	DebugHelpers:print("Can't decode")
    end
    --dataLatch = data
    return false
end


local function serverRequest(player, delta)
        postObservations(delta)
end


rf.OnServerInvoke = serverRequest


local function setupLocalServer(player)
	firstPlayer = player
	DebugHelpers:print("Reached Render Bind")
	--This should connect to the render loop
	--TODO: figure out how to order these.
    -- TODO: was heartbeat
	--RunService.Heartbeat:Connect(postObservations)
	--RunService.Heartbeat:Connect(getInput)


	--Bind the http functions to the render loop
	-- ONLY callable from client code.
	--RunService:BindToRenderStep("Send Observations", Enum.RenderPriority.First.Value - 1, postObservations)
	--RunService:BindToRenderStep("Get Action", Enum.RenderPriority.Input.Value - 1, getInput)
end

re.OnServerEvent:Connect(serverRequest)
--The event that will trigger the http server pinging
game.Players.PlayerAdded:Connect(setupLocalServer)