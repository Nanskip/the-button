local map_manager = {}

map_manager.init = function(self)
    debug.log("Map Manager initialized.")

    self.createMap()
end

map_manager.createMap = function()
    debug.log("Map Manager: creating map.")

    self.map = Object()

    local floor_table = {
        {
            pos = Number3(0, 0, 0),
            rot = Rotation(math.pi/2, 0, 0),
        }
    }

    for key, value in ipairs(floor_table) do
        local floor = Quad()
        floor.Image = textures.floor_concrete
        floor.Position = value.pos
        floor.Rotation = value.rot
        floor.Scale = Number3(5, 5, 5)
        floor:SetParent(self.map)
    end

    debug.log("Map Manager: map created.")
end