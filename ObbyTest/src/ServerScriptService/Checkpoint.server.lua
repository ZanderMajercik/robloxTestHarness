local CollectionService = game:GetService("CollectionService")

local TagFunctions = require(game:GetService("ServerStorage").TagFunctions)

-- TODO: Hack to set the endwall (named "ss") as a checkpoint
-- so we log a success even if the agent overshoots.
for i, level in workspace:GetChildren() do
	if string.find(level.Name, "Level") then
		TagFunctions["Checkpoint"](level.ss, true)
	end
end

for i, checkpoint in CollectionService:GetTagged("Checkpoint") do
	TagFunctions["Checkpoint"](checkpoint, false)
end