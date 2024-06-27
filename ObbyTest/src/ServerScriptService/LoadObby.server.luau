
local LoadObbyFunctions = require(script.Parent.LoadObbyFunctions)

-- -- Parse the data in the JSON file.
local portNumber = 5000
local reqName = "sendJsonDescription"
--local reqName = "receiveJsonDescription"
url = string.format("http://localhost:%d/%s", portNumber, reqName)

local obbyName = "SimpleLevel"

-- parseObbyJSON(json_url)
LoadObbyFunctions.createObbyFromJson(url, obbyName)
--LoadObbyFunctions.createJsonFromObby(url, obbyName)