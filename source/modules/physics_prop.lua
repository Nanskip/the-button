local physics_prop = {}

physics_prop.create = function(self, config)
    local defaultConfig = {
        pos = Number3(0, 0, 0),
        scale = Number3(1, 1, 1),
        rot = Rotation(0, 0, 0),
        interact = function(_)
            debug.log("Interacted with " .. tostring(_))
        end,
        mesh = models.paper[1] -- just a placeholder
    }

    local cfg = {0}
    for k, v in pairs(defaultConfig) do
        if config[k] ~= nil then
            cfg[k] = config[k]
        else
            cfg[k] = v
        end
    end

    -- create object to handle physics
    local object = Object()
    object.Physics = PhysicsMode.Dynamic

    -- create mesh
    local mesh = cfg.mesh:Copy()
    mesh:SetParent(object)
    mesh.Physics = PhysicsMode.Disabled

    -- create debug icon
end