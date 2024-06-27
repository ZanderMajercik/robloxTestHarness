--VSCode: Collect and process hit detection for all kill blocks.
local CollectionService = game:GetService("CollectionService")
local TagFunctions = require(game:GetService("ServerStorage").TagFunctions)

local CHARACTER_HIP_HEIGHT = 3.025

for i, block in CollectionService:GetTagged("KillBlock") do
    -- Don't override color on existing model.
    TagFunctions["KillBlock"](block, false)
end