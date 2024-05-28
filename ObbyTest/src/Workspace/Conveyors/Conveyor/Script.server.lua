local conveyor = script.Parent
conveyor.Velocity = conveyor.CFrame:vectorToWorldSpace(Vector3.new(0, 0, -conveyor.Configuration.Speed.Value))
conveyor.SurfaceGui.Enabled = false