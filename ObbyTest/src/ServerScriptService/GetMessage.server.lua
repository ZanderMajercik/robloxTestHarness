local rs = game:GetService("ReplicatedStorage")
local msgRe = rs:WaitForChild("MsgReceived")

local httpSrv = game:GetService("HttpService")


local function decodeWrapper(stringtodecode)
	return httpSrv:JSONDecode(stringtodecode)
end

local function pingLocalServer(player)
	while true do
		local url = "http://localhost:5000/index.json"
		local response = httpSrv:GetAsync(url)
		local b, data = pcall(decodeWrapper, response)
		if b then
			--print("data = ", data)
			--local str = tostring(data.key)
			msgRe:FireClient(player, data)
		else
			print("Can't decode")
		end
		data = {
			testing = true
		}
		httpSrv:PostAsync(url, httpSrv:JSONEncode(data), Enum.HttpContentType.ApplicationJson, false)
	end

end

--The event that will trigger the http server pinging
game.Players.PlayerAdded:Connect(pingLocalServer)