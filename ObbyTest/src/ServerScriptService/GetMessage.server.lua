local rs = game:GetService("ReplicatedStorage")
local msgRe = rs:WaitForChild("MsgReceived")
local RunService = game:GetService("RunService")

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

local function postObservations()
	print("POST OBS")
	local url = "http://localhost:5000/index.json"
	local obs = {
		testing = true
	}
	httpSrv:PostAsync(url, httpSrv:JSONEncode(obs), Enum.HttpContentType.ApplicationJson, false)
end

local function setupLocalServer(player)
	firstPlayer = player
	print("Reached Render Bind")
	--This should connect to the render loop
	--TODO: figure out how to order these.
	RunService.Heartbeat:Connect(postObservations)
	RunService.Heartbeat:Connect(getInput)
	--Bind the http functions to the render loop
	-- ONLY callable from client code.
	--RunService:BindToRenderStep("Send Observations", Enum.RenderPriority.First.Value - 1, postObservations)
	--RunService:BindToRenderStep("Get Action", Enum.RenderPriority.Input.Value - 1, getInput)
end

--The event that will trigger the http server pinging
game.Players.PlayerAdded:Connect(setupLocalServer)