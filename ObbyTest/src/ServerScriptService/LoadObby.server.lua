local ServerStorage = game:GetService("ServerStorage")
local LoadObbyFunctions = require(ServerStorage:WaitForChild("LoadObbyFunctions"))
-- local LoadObbyFunctions = ServerStorage.LoadObbyFunctions

-- -- Parse the data in the JSON file.
local portNumber = 8000
local reqName = "get_obby_json"
--local reqName = "receiveJsonDescription"
url = string.format("http://localhost:%d/%s", portNumber, reqName)

local obbyName = "demo"

-- parseObbyJSON(json_url)
LoadObbyFunctions.createObbyFromJson(url, obbyName)
-- LoadObbyFunctions.createJsonFromObby(url, obbyName)