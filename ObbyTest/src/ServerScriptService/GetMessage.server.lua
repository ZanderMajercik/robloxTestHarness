local rs = game:GetService("ReplicatedStorage")
local msgRe = rs:WaitForChild("MsgReceived")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local rf = rs:WaitForChild("RemoteFunction")

local httpSrv = game:GetService("HttpService")


local function decodeWrapper(stringtodecode)
	return httpSrv:JSONDecode(stringtodecode)
end

local firstPlayer = nil

local dataLatch



local function getInput()
	print("GET INPUT")
    local url = "http://localhost:5000/index.json"
    local response = httpSrv:GetAsync(url)
    local b, data =  pcall(decodeWrapper, response)
    if b then
    	--print("data = ", data)
    	--local str = tostring(data.key)
    	msgRe:FireClient(firstPlayer, data)
        return true
    else
    	print("Can't decode")
    end
    --dataLatch = data
    return false
end

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
		local pos = convertToZUp(wall.CFrame.Position)
		pMin = pMin:Min(Vector3.new(pos.X, pos.Y, pos.Z - wall.Size.Y * 0.5))
		pMax = pMax:Max(Vector3.new(pos.X, pos.Y, pos.Z + wall.Size.Y * 0.5))
	end
	
	return { 
		{pMin.X, pMin.Y, pMin.Z},
		{pMax.X, pMax.Y, pMax.Z}
	}
end

local function goalPosition()
    for i, goal in CollectionService:GetTagged("Goal") do
        return goal.CFrame.Position
    end
end

local function lavaObservations()
    local lavaObs = {}
    for i, lava in CollectionService:GetTagged("KillBlock") do
        local orientationZUp = convertToZUp(lava.Position)
        local sizeZUp = convertToZUp(lava.Size)
        lavaObs[i] = {orientationZUp.X, orientationZUp.Y, orientationZUp.Z, math.abs(sizeZUp.X), math.abs(sizeZUp.Y), math.abs(sizeZUp.Z)}
    end
    return lavaObs
end

local portBase = 5000
local portNumber = 0
local numPorts = 15

local function postObservations()
	print("POST OBS")
    local p = (portNumber + 1) % numPorts
	local url = "http://localhost:" .. tostring(portBase) .. "/index.json"

	local AABB = getAABB()
	local posZUp = convertToZUp(firstPlayer.Character:FindFirstChild("HumanoidRootPart").Position)
    local goalPosZUp = convertToZUp(goalPosition())
	--Collect the player centric observations.
	local obs = {
		roomAABB = AABB,
		playerPos = {posZUp.X, posZUp.Y, posZUp.Z},
        goalPos = {goalPosZUp.X, goalPosZUp.Y, goalPosZUp.Z},
        lava = lavaObservations(),
        -- TODO: restore
        --lidar = lidarObservations(),
        obsTime = tick() --Profile
	}
	httpSrv:PostAsync(url, httpSrv:JSONEncode(obs), Enum.HttpContentType.ApplicationJson, false)
end


local function serverRequest(player, action)
    if action then
        getInput()
    else
        postObservations()
    end
end


rf.OnServerInvoke = serverRequest


local function setupLocalServer(player)
	firstPlayer = player
	print("Reached Render Bind")
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

--The event that will trigger the http server pinging
game.Players.PlayerAdded:Connect(setupLocalServer)