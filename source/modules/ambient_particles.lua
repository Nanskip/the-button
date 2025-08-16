local ambient_particles = {}

ambient_particles.init = function(self)
    debug.log("Ambient Particles initialized.")

    -- settings
    self.count = 300
    self.lifetime = 3
    self.fadetime = 0.5
    self.size = 0.05
    self.color = Color(200, 200, 200)

    self.particles = {}

    -- generate first count of particles into pool
    for i = 1, self.count do
        local particle = Quad()
        particle.lifetime = self.lifetime + (math.random(0, 50)/10)
        particle.life = 0
        particle.Scale = self.size
        particle.Anchor = Number2(0.5, 0.5)
        particle.fadetime = self.fadetime
        particle.Color = self.color
        particle.random_pos = function(p)
            p.Position = Number3(
                math.random(10, 50),
                math.random(5, 40),
                math.random(10, 50)
            )
            p.vel = Number3(
                math.random(-100, 100)/100,
                math.random(-100, 100)/100,
                math.random(-100, 100)/100
            )
        end
        particle:random_pos()
        particle.Tick = function(p, dt)
            if map_manager.isLight then
                particle.Color = Color(255, 255, 255)
            end
            -- rotate particle towards camera
            local dir = (Camera.Position - p.Position):Normalize()
            local yaw = math.atan2(dir.X, dir.Z)
            local pitch = math.asin(dir.Y)

            p.Rotation = Rotation(-pitch, yaw, 0)
            -- move particle
            p.Position = p.Position + p.vel * (dt)

            -- fade particle and teleport it
            p.life = p.life + dt
            if p.life > p.lifetime then
                p.life = 0
                p:random_pos()
            end

            if p.life < p.fadetime then
                -- fade in
                local t = p.life / p.fadetime
                p.Color.A = math.min(math.floor(mathlib.lerp(0, 255, t)), 200)
            elseif p.life > p.lifetime - p.fadetime then
                -- fade out
                local t = (p.life - (p.lifetime - p.fadetime)) / p.fadetime
                p.Color.A = math.min(math.floor(mathlib.lerp(255, 0, t)), 200)
            else
                p.Color.A = 200
            end
        end
        particle:SetParent(World)
    end
end