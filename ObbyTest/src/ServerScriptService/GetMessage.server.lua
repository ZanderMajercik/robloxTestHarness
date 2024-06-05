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
	--print("GET INPUT")
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


local function getAABB()
	local pMin = Vector3.new(100,100,100)
	local pMax = Vector3.new(-100,-100,-100)
	for i, wall in CollectionService:GetTagged("Bounds") do
		local pos = wall.CFrame.Position
		pMin = pMin:Min(Vector3.new(pos.X, pos.Y - wall.Size.Y * 0.5, pos.Z))
		pMax = pMax:Max(Vector3.new(pos.X, pos.Y + wall.Size.Y * 0.5, pos.Z))
	end
	
	-- Convert to Z up before JSON.
	local pMinZUp = convertToZUp(pMin)
	local pMaxZUp = convertToZUp(pMax)

	return { 
		{pMinZUp.X, pMinZUp.Y, pMinZUp.Z},
		{pMaxZUp.X, pMaxZUp.Y, pMaxZUp.Z}
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
        lavaObs[i] = {orientationZUp.X, orientationZUp.Y, orientationZUp.Z, sizeZUp.X, sizeZUp.Y, sizeZUp.Z}
    end
    return lavaObs
end

local function postObservations()
	--print("POST OBS")
	local url = "http://localhost:5000/index.json"

	local AABB = getAABB()
	local posZUp = convertToZUp(firstPlayer.Character:FindFirstChild("HumanoidRootPart").Position)
    local goalPosZUp = convertToZUp(goalPosition())
	--Collect the player centric observations.
	local obs = {
		roomAABB = AABB,
		playerPos = {posZUp.X, posZUp.Y, posZUp.Z},
        goalPos = {goalPosZUp.X, goalPosZUp.Y, goalPosZUp.Z},
        lava = lavaObservations()
	}
	httpSrv:PostAsync(url, httpSrv:JSONEncode(obs), Enum.HttpContentType.ApplicationJson, false)
end

rf.OnServerInvoke = getInput


local function setupLocalServer(player)
	firstPlayer = player
	print("Reached Render Bind")
	--This should connect to the render loop
	--TODO: figure out how to order these.
	RunService.Heartbeat:Connect(postObservations)
	--RunService.Heartbeat:Connect(getInput)


	--Bind the http functions to the render loop
	-- ONLY callable from client code.
	--RunService:BindToRenderStep("Send Observations", Enum.RenderPriority.First.Value - 1, postObservations)
	--RunService:BindToRenderStep("Get Action", Enum.RenderPriority.Input.Value - 1, getInput)
end

--The event that will trigger the http server pinging
game.Players.PlayerAdded:Connect(setupLocalServer)