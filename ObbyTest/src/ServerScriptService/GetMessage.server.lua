local rs = game:GetService("ReplicatedStorage")
local msgRe = rs:WaitForChild("MsgReceived")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local rf = rs:WaitForChild("RemoteFunction")

local httpSrv = game:GetService("HttpService")

local re = rs:WaitForChild("SendObservations")


local function decodeWrapper(stringtodecode)
	return httpSrv:JSONDecode(stringtodecode)
end

-- Helpful debugging functions.
local DebugHelpers = require(rs.DebugHelpers)

local frameCounter = 0
local MAX_FRAMES = 15
local totalSend = 0

local baseURL = "http://localhost:5000/"
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

local function lidarObservations(player)
    local numLidarSamples = 30
    local maxDist = 200
    local origin = player.Character:FindFirstChild("HumanoidRootPart").Position
    local lidarObs = {}

    local params = RaycastParams.new()
    -- Prevent self-intersection by filtering the player model.
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character}
    for i = 0, numLidarSamples, 1 do
        -- TODO: madrona starts the raycast offset by pi/2 but roblox doesn't need this factor
        -- to make the observations match(?)
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
    local lavaObs = {}
    local idx = 1
    for i, lava in CollectionService:GetTagged("KillBlock") do
        if lava:IsDescendantOf(workspace) then
            local orientationZUp = convertToZUp(lava.Position)
            local sizeZUp = convertToZUp(lava.Size)
            lavaObs[idx] = {orientationZUp.X, orientationZUp.Y, orientationZUp.Z,
            math.abs(sizeZUp.X) * 0.5, math.abs(sizeZUp.Y) * 0.5, math.abs(sizeZUp.Z) * 0.5}
            idx += 1
        end
    end
    return lavaObs
end

local serverFunctionTable = {}


serverFunctionTable["getTrajectory"] = function (player)
    -- Get an entire trajectory from the server and send it to the client for playback.
    local response = httpSrv:GetAsync(baseURL .. "requestTrajectory")
    local b, data = pcall(decodeWrapper, response)
    if b then
    	--DebugHelpers:print("data = ", data)
    	--local str = tostring(data.key)
    	msgRe:FireClient(player, data)
        return true
    else
    	DebugHelpers:print("Can't decode")
    end
end

-- Used to track steps remaining
local isAlive = false
local httpDelta = secondsPerHTTPRequest
serverFunctionTable["postObservations"] = function(player, delta)
    httpDelta -= delta
    if httpDelta > 0 then
        return
    end
    httpDelta = secondsPerHTTPRequest
    totalSend += 1
	local AABB = getAABB()
	local posZUp = convertToZUp(player.Character:FindFirstChild("HumanoidRootPart").Position)
    local goalPosZUp = convertToZUp(goalPosition())

    local lObs = lavaObservations()
	--Collect the player centric observations.
	local obs = {
		roomAABB = AABB,
		playerPos = {posZUp.X, posZUp.Y, posZUp.Z},
        goalPos = {goalPosZUp.X, goalPosZUp.Y, goalPosZUp.Z},
        lava = lObs,
        alive = isAlive,
        --lidar = lidarObservations(),
        obsTime = tick() --Profile
	}
	local response = httpSrv:PostAsync(baseURL .. "sendObservations", httpSrv:JSONEncode(obs), Enum.HttpContentType.ApplicationJson, false)
    --DebugHelpers:print("TOTAL SEND (POST): ", totalSend, time(), delta)
    local b, data =  pcall(decodeWrapper, response)
    DebugHelpers:print("Delay: ", tick() - data["obsTime"])
    if b then
    	--DebugHelpers:print("data = ", data)
    	--local str = tostring(data.key)
    	msgRe:FireClient(player, data)
        return true
    else
    	DebugHelpers:print("Can't decode")
    end
    --dataLatch = data
    return false
end

--First argument is always the player triggering the event.
local function serverForward(player, functionName, ...)
    serverFunctionTable[functionName](player, ...)
end

rf.OnServerInvoke = serverForward

local function setupLocalServer(player)

    --Connect functions to signal if the character is alive or dead.
    player.CharacterAdded:Connect(function(character)
        isAlive = true
        character.Humanoid.Died:Connect(function()
			isAlive = false
		end)
    end)

    local setupServer = httpSrv:GetAsync(baseURL .. "setupServer")
    local b, serverSetupData =  pcall(decodeWrapper, setupServer)
    print(serverSetupData)
    if b then
        local level = workspace:FindFirstChild(serverSetupData.LEVEL)
        if not level then
            -- Level is not loaded instead load it from ServerStorage.
            level = ServerStorage:FindFirstChild(serverSetupData.LEVEL)
            if not level then
                local errorMsg = {
                    error = "Level \"" .. serverSetupData.LEVEL .. "\" not found in workspace or ServerStorage."
                }
	            httpSrv:PostAsync(baseURL .. "error", httpSrv:JSONEncode(errorMsg), Enum.HttpContentType.ApplicationJson, false)
                return
            end
            --Move all existing levels back into ServerStorage.
            for idx, child in workspace:GetChildren() do
                local startIdx = string.find(child.Name, "Level")
                if startIdx then
                    child.Parent = ServerStorage
                end
            end
            --Move the requested level into the workspace.
            level.Parent = workspace
        end
        msgRe:FireClient(player, serverSetupData)
    end
end

--re.OnServerEvent:Connect(forwardPostObservations)
--The event that will trigger the http server pinging
game.Players.PlayerAdded:Connect(setupLocalServer)

--TODO: set this based on what the server first returns.
--game.Players.PlayerAdded:Connect(getTrajectory)