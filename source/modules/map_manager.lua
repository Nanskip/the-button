local map_manager = {}

map_manager.init = function(self)
    debug.log("Map Manager initialized.")

    self:createMap()
end

map_manager.createMap = function(self)
    debug.log("Map Manager: creating map.")

    self.map = Object()
    local scale_multiplier = 20

    local floor_table = self:getFloors()

    for key, value in ipairs(floor_table) do
        local floor = Quad()
        floor.Size = Number2(128, 128)
        floor.Image = {data = textures.floor_concrete, filtering = false}
        floor.Position = value.pos * 20
        floor.Rotation = value.rot
        floor.Scale = scale_multiplier/128
        floor.Shadow = true
        floor:SetParent(self.map)
    end

    local wall_table = self:getWalls()

    for key, value in ipairs(wall_table) do
        local wall = Quad()
        wall.Size = Number2(128, 128)
        wall.Image = {data = textures.wall_concrete, filtering = false}
        wall.Position = value.pos * 20
        wall.Rotation = value.rot
        wall.Scale = scale_multiplier/128
        wall.Shadow = true
        wall:SetParent(self.map)
    end

    self.map:SetParent(World)

    debug.log("Map Manager: map created.")
end

map_manager.getFloors = function()
    local floor_table = {
        {
            pos = Number3(0, 0, 0),
            rot = Rotation(math.pi/2, 0, 0),
        },
        {
            pos = Number3(1, 0, 0),
            rot = Rotation(math.pi/2, 0, 0),
        },
        {
            pos = Number3(0, 0, 1),
            rot = Rotation(math.pi/2, 0, 0),
        },
        {
            pos = Number3(1, 0, 1),
            rot = Rotation(math.pi/2, 0, 0),
        },
        {
            pos = Number3(2, 0, 1),
            rot = Rotation(math.pi/2, 0, 0),
        },
        {
            pos = Number3(2, 0, 2),
            rot = Rotation(math.pi/2, 0, 0),
        },
        {
            pos = Number3(1, 0, 2),
            rot = Rotation(math.pi/2, 0, 0),
        },
        {
            pos = Number3(2, 0, 0),
            rot = Rotation(math.pi/2, 0, 0),
        },
        {
            pos = Number3(0, 0, 2),
            rot = Rotation(math.pi/2, 0, 0),
        },
    }

    return floor_table
end

map_manager.getWalls = function()
    local wall_table = {
        {
            pos = Number3(0, 0, 0),
            rot = Rotation(0, 0, 0),
        },
        {
            pos = Number3(1, 0, 0),
            rot = Rotation(0, 0, 0),
        },
        {
            pos = Number3(2, 0, 0),
            rot = Rotation(0, 0, 0),
        },
        {
            pos = Number3(0, 0, 3),
            rot = Rotation(0, 0, 0),
        },
        {
            pos = Number3(1, 0, 3),
            rot = Rotation(0, 0, 0),
        },
        {
            pos = Number3(2, 0, 3),
            rot = Rotation(0, 0, 0),
        },
        {
            pos = Number3(0, 0, 0),
            rot = Rotation(0, -math.pi/2, 0),
        },
        {
            pos = Number3(0, 0, 1),
            rot = Rotation(0, -math.pi/2, 0),
        },
        {
            pos = Number3(0, 0, 2),
            rot = Rotation(0, -math.pi/2, 0),
        },
        {
            pos = Number3(3, 0, 0),
            rot = Rotation(0, -math.pi/2, 0),
        },
        {
            pos = Number3(3, 0, 1),
            rot = Rotation(0, -math.pi/2, 0),
        },
        {
            pos = Number3(3, 0, 2),
            rot = Rotation(0, -math.pi/2, 0),
        },
    }

    return wall_table
end