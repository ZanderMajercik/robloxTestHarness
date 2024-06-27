local LoadObbyFunctions = {}

local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local TagFunctions = require(game:GetService("ReplicatedStorage").TagFunctions)

local function createBlockPart(blockPartName, blockPartInfo)
    local part = Instance.new(blockPartInfo["type"])
    part.Name = blockPartName
    part.Anchored = true
    part.Shape = Enum.PartType.Block
    print(blockPartInfo["tags"])
    if blockPartInfo["type"] == "SpawnLocation" then
        part.Color = Color3.new(0, 1, 0)
    elseif blockPartInfo["tags"][1] == "KillBlock" then
        part.Color = Color3.new(1, 0, 0)
    elseif blockPartInfo["tags"][1] == "Goal" then
        part.Color = Color3.new(0,0,1)
    else
        part.Color = Color3.new(0.5, 0.5, 0.5)
    end
    for idx, t in blockPartInfo["tags"] do
        CollectionService:AddTag(part, t)
        if t == "KillBlock" then
            TagFunctions[t](part)
        end
    end
    part.Parent = workspace -- Put the part into the Workspace

    -- NOTE: The JSON files store (X, Y, Z). The vertical axis in Roblox is the Y-axis.
    part.Position = Vector3.new(blockPartInfo["position"][1], -blockPartInfo["position"][3], blockPartInfo["position"][2])
    part.Size = Vector3.new(blockPartInfo["size"][1], blockPartInfo["size"][3], blockPartInfo["size"][2])
end

local function parseObbyJSON(json_url)
    response = HttpService:GetAsync(json_url)
    data = HttpService:JSONDecode(response)
    -- Parses blocks from obby JSON
    for blockPartName, blockPartInfo in pairs(data) do
        createBlockPart(blockPartName, blockPartInfo)
    end
end

function LoadObbyFunctions.createObbyFromJson(url, obbyName)
    local jsonFilename = string.format('%s.json', obbyName)
    local response = HttpService:RequestAsync({
        Url = url, -- This website helps debug HTTP requests
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json", -- When sending JSON, set this!
        },
        Body = HttpService:JSONEncode({ filename = jsonFilename }),
    })
    print(response)
    -- data = HttpService:JSONDecode(response)
    data = HttpService:JSONDecode(response["Body"])
    print(data)
    -- Parses blocks from obby JSON
    for blockPartName, blockPartInfo in pairs(data) do
        createBlockPart(blockPartName, blockPartInfo)
    end
end


local zUpFrame = CFrame.fromMatrix(
	Vector3.new(0,0,0),
	Vector3.new(1, 0, 0),
	Vector3.new(0, 0, 1),
	Vector3.new(0, 1, 0)
)

local function convertToZUp(v)
	return zUpFrame * v
end


function LoadObbyFunctions.createJsonFromObby(url, obbyName)
    local obbyJson = {}
    for idx, p in workspace:FindFirstChild(obbyName):GetChildren() do
        local posZUp = convertToZUp(p.Position)
        local sizeZUp = convertToZUp(p.Size)
        obbyJson[p.Name .. tostring(idx)] = {
            position = {posZUp.X, posZUp.Y, posZUp.Z},
            size = {sizeZUp.X, sizeZUp.Y, sizeZUp.Z},
            tags = CollectionService:GetTags(p), --Assume only one tag for now.
            type = p.ClassName
        }
    end
    HttpService:PostAsync(url, HttpService:JSONEncode(obbyJson))
end

return LoadObbyFunctions