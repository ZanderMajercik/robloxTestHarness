
local LoadObbyFunctions = require(script.Parent.LoadObbyFunctions)

-- -- Parse the data in the JSON file.
local portNumber = 8000
local reqName = "get_obby_json"
url = string.format("http://localhost:%d/%s", portNumber, reqName)

local obbyName = 'zigzag_jump'

-- parseObbyJSON(json_url)
LoadObbyFunctions.createObbyFromJson(url, obbyName)