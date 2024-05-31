local rs = game:GetService("ReplicatedStorage")
local msgRe = rs:WaitForChild("MsgReceived")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local httpSrv = game:GetService("HttpService")


local function decodeWrapper(stringtodecode)
	return httpSrv:JSONDecode(stringtodecode)
end

local firstPlayer = nil

local function getInput()
	print("GET INPUT")
	local url = "http://localhost:5000/index.json"
	local response = httpSrv:GetAsync(url)
	local b, data =  pcall(decodeWrapper, response)
	if b then
		--print("data = ", data)
		--local str = tostring(data.key)
		msgRe:FireClient(firstPlayer, data)
	else
		print("Can't decode")
	end
end

local function getAABB()
	local pMin = Vector3.new(100,100,100)
	local pMax = Vector3.new(-100,-100,-100)
	for i, wall in CollectionService:GetTagged("Bounds") do
		local pos = wall.CFrame.Position
		pMin = pMin:Min(Vector3.new(pos.X, pos.Y - wall.Size.Y * 0.5, pos.Z))
		pMax = pMax:Max(Vector3.new(pos.X, pos.Y + wall.Size.Y * 0.5, pos.Z))
	end
	return { 
		{pMin.X, pMin.Y, pMin.Z},
		{pMax.X, pMax.Y, pMax.Z}
	}
end

local function postObservations()
	print("POST OBS")
	local url = "http://localhost:5000/index.json"

	wait(1) --TODO: restore
	local AABB = getAABB()
	local pos = firstPlayer.Position
	--Collect the player centric observations.
	local obs = {
		roomAABB = AABB,
		playerPos = {pos.X, pos.Y, pos.Z}
	}
	httpSrv:PostAsync(url, httpSrv:JSONEncode(obs), Enum.HttpContentType.ApplicationJson, false)
end

local function setupLocalServer(player)
	firstPlayer = player
	print("Reached Render Bind")
	--This should connect to the render loop
	--TODO: figure out how to order these.
	RunService.Heartbeat:Connect(postObservations)
	-- TODO: Restore!!!!
	--RunService.Heartbeat:Connect(getInput)


	--Bind the http functions to the render loop
	-- ONLY callable from client code.
	--RunService:BindToRenderStep("Send Observations", Enum.RenderPriority.First.Value - 1, postObservations)
	--RunService:BindToRenderStep("Get Action", Enum.RenderPriority.Input.Value - 1, getInput)
end

--The event that will trigger the http server pinging
game.Players.PlayerAdded:Connect(setupLocalServer)