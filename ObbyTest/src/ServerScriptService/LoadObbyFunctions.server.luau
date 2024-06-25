local LoadObbyFunctions = {}

local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local function createBlockPart(blockPartName, blockPartInfo)
    local part = Instance.new("Part")
    part.Name = blockPartName
    part.Anchored = true
    part.Shape = Enum.PartType.Block
    if blockPartInfo["type"] == "BlockPartV0" then
        part.Color = Color3.new(1, 1, 1)
    elseif blockPartInfo["type"] == "LavaPartV0" then
        part.Color = Color3.new(1, 0, 0)
    else
        part.Color = Color3.new(0.5, 0.5, 0.5)
    end
    CollectionService:AddTag(part, blockPartInfo["type"])
    part.Parent = workspace -- Put the part into the Workspace

    -- NOTE: The JSON files store (X, Y, Z). The vertical axis in Roblox is the Y-axis.
    part.Position = Vector3.new(blockPartInfo["position"][1], blockPartInfo["position"][3], blockPartInfo["position"][2])
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

return LoadObbyFunctions