local LoadObbyFunctions = {}

local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local TagFunctions = require(game:GetService("ServerStorage").TagFunctions)

local function createBlockPart(blockPartName, blockPartInfo)
    -- Type is almost always "Part". "SpawnLocation" is the only special case.
    local part = Instance.new(blockPartInfo["type"])
    part.Name = blockPartName
    part.Anchored = true
    part.Shape = Enum.PartType.Block
    part.Color = Color3.new(0.5, 0.5, 0.5) -- Special color will be set by TagFunctions if applicable.

    if blockPartInfo["type"] == "SpawnLocation" then
        part.Color = Color3.new(0, 1, 0)
    end

    for idx, t in blockPartInfo["tags"] do
        -- Tags are used for both agent observations and game logic.
        CollectionService:AddTag(part, t)
        
        -- Associate the touched event with the associate tag function 
        -- (if there is one) and set the color for visualization.
        if TagFunctions[t] then
            TagFunctions[t](part, true)
        end
    end
    -- NOTE: The JSON files store (X, Y, Z). The vertical axis in Roblox is the Y-axis.
    part.Position = Vector3.new(blockPartInfo["position"][1], blockPartInfo["position"][3], blockPartInfo["position"][2])
    part.Size = Vector3.new(blockPartInfo["size"][1], blockPartInfo["size"][3], blockPartInfo["size"][2])

    part.Parent = workspace -- Put the part into the Workspace
end

function LoadObbyFunctions.createObbyFromJson(data)
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