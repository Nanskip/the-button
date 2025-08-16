local map_manager = {}

map_manager.init = function(self)
    debug.log("Map Manager initialized.")

    map_manager.narrator_glitch = AudioSource()
    map_manager.narrator_glitch.Sound = sounds.voice_glitch
    map_manager.narrator_glitch:SetParent(Camera)
    self:createMap()
end

map_manager.createMap = function(self)
    debug.log("Map Manager: creating map.")

    self.map = Object()
    local scale_multiplier = 20

    local floor_table = self:getFloors()
    map_manager.floors = {}

    for key, value in ipairs(floor_table) do
        local floor = Quad()
        floor.Size = Number2(128, 128)
        floor.Image = {data = textures.floor_concrete, filtering = false}
        floor.Position = value.pos * 20
        floor.Rotation = value.rot
        floor.Scale = scale_multiplier/128
        floor.Shadow = true
        floor.Physics = PhysicsMode.Static
        floor:SetParent(self.map)

        if value.isWhite then
            floor.Image = false
            floor.Color = Color(255, 255, 255)
            floor.IsUnlit = true
        end

        map_manager.floors[#map_manager.floors+1] = floor
    end

    local wall_table = self:getWalls()

    map_manager.walls = {}

    for key, value in ipairs(wall_table) do
        local wall = Quad()
        wall.Size = Number2(128, 128)
        wall.Image = {data = textures.wall_concrete, filtering = false}
        wall.Position = value.pos * 20
        wall.Rotation = value.rot
        wall.Scale = scale_multiplier/128
        wall.Shadow = true
        wall.Physics = PhysicsMode.Static
        if value.make_darker then
            --wall.Color = Color(220, 220, 220)
        end
        wall:SetParent(self.map)

        if value.isDoor then
            map_manager.exit = wall

            map_manager.exit.side1 = Quad()
            map_manager.exit.side1.Color = Color(150, 150, 150)
            map_manager.exit.side1:SetParent(map_manager.exit)
            map_manager.exit.side1.Rotation = Rotation(0, -math.pi, 0)
            map_manager.exit.side1.Size = Number2(128, 128)
            map_manager.exit.side1.Scale = Number3(0.1, 1, 1)

            map_manager.exit.side2 = Quad()
            map_manager.exit.side2.Color = Color(150, 150, 150)
            map_manager.exit.side2:SetParent(map_manager.exit)
            map_manager.exit.side2.Rotation = Rotation(0, -math.pi, 0)
            map_manager.exit.side2.Position.Z = map_manager.exit.Position.Z + 20
            map_manager.exit.side2.Size = Number2(128, 128)
            map_manager.exit.side2.Scale = Number3(0.1, 1, 1)

            map_manager.exit.backside = Quad()
            map_manager.exit.backside.Color = Color(150, 150, 150)
            map_manager.exit.backside:SetParent(map_manager.exit)
            map_manager.exit.backside.Position = map_manager.exit.Position - Number3(2, 0, 0)
            map_manager.exit.backside.Size = Number2(128, 128)
            map_manager.exit.backside.Scale = Number3(1, 1, 1)

            map_manager.exit_trigger = Quad()
            map_manager.exit_trigger.Color = Color(255, 255, 255, 0)
            map_manager.exit_trigger:SetParent(World)
            map_manager.exit_trigger.Position = map_manager.exit.Position - Number3(5, 0, 0)
            map_manager.exit_trigger.Rotation.Y = -math.pi/2
            map_manager.exit_trigger.Scale = 20
            map_manager.exit_trigger.Physics = PhysicsMode.Trigger
            map_manager.exit_trigger.OnCollisionBegin = function(self, other)
                if other == Player then
                    Player.isExiting = true
                end
            end
        end

        if value.isWhite then
            wall.Image = false
            wall.Color = Color(255, 255, 255)
            wall.IsUnlit = true
        end

        map_manager.walls[#map_manager.walls+1] = wall
    end

    self.map:SetParent(World)

    -- add skip tag on wall
    local tag = Quad()
    tag.Color = Color(255, 255, 255, 100)
    tag.Size = Number2(128, 128)
    tag.Image = {data = textures.skip_tag, filtering = false}
    tag.Position = Number3(60-0.01, 5, 40)
    tag.Rotation = Rotation(0, math.pi/2, 0)
    tag.Scale = 10/128
    tag:SetParent(self.map)

    -- add mud on floor
    local mud = Quad()
    mud.Color = Color(255, 255, 255, 200)
    mud.Size = Number2(64, 64)
    mud.Image = {data = textures.mud_texture, filtering = false}
    mud.Position = Number3(5, 0.01, 7)
    mud.Rotation = Rotation(math.pi/2, 0, 0)
    mud.Scale = 10/64
    mud:SetParent(World)

    map_manager.mud = mud

    -- add rusty tube
    local tube = models.rusty_tube[1]:Copy()
    tube.Position = Number3(57.25, 18, 4.25)
    tube.Rotation = Rotation(math.pi, -math.pi/2, math.pi/2)
    tube:SetParent(World)
    self.tube = tube

    -- create the lamp
    self.lamp_flicker1 = AudioSource()
    self.lamp_flicker1.Sound = sounds.lamp_flicker1
    self.lamp_flicker1:SetParent(self.lamp_light1)

    self.lamp_flicker2 = AudioSource()
    self.lamp_flicker2.Sound = sounds.lamp_flicker2
    self.lamp_flicker2:SetParent(self.lamp_light2)

    self.lamp = models.lamp[1]:Copy()
    self.lamp.light_part = models.lamp[2]:Copy()
    self.lamp.light_part:SetParent(self.lamp)
    self.lamp.light_part.IsUnlit = true
    self.lamp.Position = Number3(30, 35, 30)
    self.lamp.Pivot = Number3(0, 30, 0)
    self.lamp:SetParent(self.map)
    self.lamp.Scale = 0.5
    self.lamp.t = 0
    self.lamp.Tick = function(s)
        s.Rotation.Y = math.sin(s.t*0.01)*0.1 + math.pi/2
        s.Rotation.X = math.cos(s.t*0.015)*0.15
        self.lamp_light1.Position = s.Position + s.Down*16 + s.Forward*3
        self.lamp_light2.Position = s.Position + s.Down*16 + s.Backward*3
        s.t = s.t + 1

        if not s.turned_off then
            if math.random(0, 100) == 0 then
                local rand_color = 150 + math.random(0, 50)
                if math.random(0, 1) == 0 then
                    self.lamp_flicker1:Play()
                    self.lamp_light1.Color = Color(rand_color, rand_color, rand_color)
                    
                    Timer(0.05, false, function()
                        if not s.turned_off then
                            self.lamp_light1.Color = Color(255, 255, 255)
                        end
                    end)
                else
                    self.lamp_flicker2:Play()
                    self.lamp_light2.Color = Color(rand_color, rand_color, rand_color)
                    
                    Timer(0.05, false, function()
                        if not s.turned_off then
                            self.lamp_light2.Color = Color(255, 255, 255)
                        end
                    end)
                end
            end
        end
    end

    self.lamp_light1 = Light()
    self.lamp_light1.Color = Color(255, 255, 255)
    self.lamp_light1.Radius = 50
    self.lamp_light1.Hardness = 0
    self.lamp_light1:SetParent(self.map)
    self.lamp_light1.CastsShadows = true
    debug.light_icon1 = debug:createIcon(self.lamp_light1, "lightbulb")

    self.lamp_light2 = Light()
    self.lamp_light2.Color = Color(255, 255, 255)
    self.lamp_light2.Radius = 50
    self.lamp_light2.Hardness = 0
    self.lamp_light2:SetParent(self.map)
    self.lamp_light2.CastsShadows = true
    debug.light_icon2 = debug:createIcon(self.lamp_light2, "lightbulb")

    self.lamp.turn_off = function(l)
        l.turned_off = true
        map_manager.lamp_light1.Color = Color(0, 0, 0)
        map_manager.lamp_light2.Color = Color(0, 0, 0)
        map_manager.lamp_flicker1:Stop()
        map_manager.lamp_flicker2:Stop()
        map_manager.lamp_sound1:Stop()
        map_manager.lamp_sound2:Stop()
        l.light_part.IsUnlit = false
    end

    self.lamp.turn_on = function(l)
        l.turned_off = false
        map_manager.lamp_light1.Color = Color(255, 255, 255)
        map_manager.lamp_light2.Color = Color(255, 255, 255)
        l.light_part.IsUnlit = true
    end

    self.lamp_sound1 = AudioSource()
    self.lamp_sound1.Sound = sounds.lamp_buzz
    self.lamp_sound1:SetParent(self.map)
    self.lamp_sound1.Position = Number3(30, 20, 30)
    self.lamp_sound1.Spatialized = true
    self.lamp_sound1:Play()

    self.lamp_sound2 = AudioSource()
    self.lamp_sound2.Sound = sounds.lamp_buzz
    self.lamp_sound2:SetParent(self.map)
    self.lamp_sound2.Position = Number3(30, 20, 30)
    self.lamp_sound2.Spatialized = true

    Timer(1, true, function()
        if not self.lamp.turned_off then
            self.lamp_sound1:Play()
            Timer(0.5, false, function()
                if not self.lamp.turned_off then
                    self.lamp_sound2:Play()
                end
            end)
        end
    end)

    -- create black ceiling gradient
    for i = 1, 20 do
        local quad = Quad()
        quad.Scale = 20*3
        quad.Rotation = Rotation(math.pi/2, 0, 0)
        quad.Color = Color(255, 255, 255, math.floor(i*255/20))
        quad.Position.Y = 30 + (i*0.5)
        quad:SetParent(self.map)
    end

    -- create dark ambient sound
    local ambient_sound = AudioSource()
    ambient_sound.Sound = sounds.dark_ambient
    ambient_sound.Loop = true
    ambient_sound.Volume = 0.5
    ambient_sound:Play()
    ambient_sound:SetParent(Camera)

    Timer(3, false, function()
        self:start_game()
    end)

    debug.log("Map Manager: map created.")

    ambient_particles:init()
end

map_manager.open_exit = function(self)
    debug.log("Map Manager: Opening exit door.")
    local sound = AudioSource()
    sound.Sound = sounds.exit_door_open1
    sound:SetParent(map_manager.exit)
    sound.Spatialized = true

    local left_light_beam = Quad()
    left_light_beam.Color = Color(255, 255, 255, 0)
    left_light_beam.Size = Number2(16, 16)
    left_light_beam.Image = {data = textures.white_gradient, filtering = false}
    left_light_beam.Scale = Number3(1/16, 20/16, 1/16)
    left_light_beam.Position = Number3(0, 0, 20)
    left_light_beam.Rotation = Rotation(0, math.pi/2-0.1, 0)
    left_light_beam.IsUnlit = true
    left_light_beam:SetParent(World)

    local right_light_beam = Quad()
    right_light_beam.Color = Color(255, 255, 255, 0)
    right_light_beam.Size = Number2(16, 16)
    right_light_beam.Image = {data = textures.white_gradient, filtering = false}
    right_light_beam.Scale = Number3(1/16, 20/16, 1/16)
    right_light_beam.Position = Number3(0, 0, 40)
    right_light_beam.Rotation = Rotation(0, -math.pi/2+0.1, 0)
    right_light_beam.IsUnlit = true
    right_light_beam:SetParent(World)

    local top_light_beam = Quad()
    top_light_beam.Color = Color(255, 255, 255, 0)
    top_light_beam.Size = Number2(16, 16)
    top_light_beam.Image = {data = textures.white_gradient, filtering = false}
    top_light_beam.Scale = Number3(1/16, 20/16, 1/16)
    top_light_beam.Position = Number3(0, 20, 20)
    top_light_beam.Rotation = Rotation(math.pi/2, 0, 0)
    top_light_beam.Rotation = top_light_beam.Rotation * Rotation(0, math.pi/2-0.1, 0)
    top_light_beam.IsUnlit = true
    top_light_beam:SetParent(World)

    local beams = {
        left_light_beam,
        right_light_beam,
        top_light_beam,
    }

    map_manager.exit.t = 0
    map_manager.exit.Tick = function(self, dt)
        self.t = self.t + dt
        if sound ~= nil and not sound.IsPlaying then
            sound:Play()
            Timer(4.5, false, function()
                sound:Stop()
                sound = nil

                local sound2 = AudioSource()
                sound2.Sound = sounds.exit_door_open2
                sound2:SetParent(map_manager.exit)
                sound2.Spatialized = true
                sound2:Play()
            end)
        end

        if self.t > 1 and self.t < 3 then
            map_manager.exit.Position.X = mathlib.lerp(map_manager.exit.Position.X, 1, 0.05)
        elseif self.t > 3 and self.t < 5 then
            map_manager.exit.Position.X = mathlib.lerp(map_manager.exit.Position.X, -1, 0.1)
            for key, value in beams do
                value.Color.A = math.floor(mathlib.lerp(0, 255, 0.5))
            end
        elseif self.t > 5 then
            map_manager.exit.Position.X = -1
            map_manager.exit.Position.Z = mathlib.lerp(map_manager.exit.Position.Z, 40, 0.03)
        end
    end
end

map_manager.start_game = function(self)
    debug.log("Map Manager: starting game.")
    local narrator_game_start1 = AudioSource()
    narrator_game_start1.Sound = sounds.game_start
    narrator_game_start1:SetParent(Camera)
    narrator_game_start1:Play()

    Timer(26, false, function()
        narrator_game_start1:Destroy()
    end)

    local button = Object()
    button.base = models.button[1]:Copy()
    button.base:SetParent(button)
    button.base.Physics = PhysicsMode.Static
    button.button = models.button[2]:Copy()
    button.button.clickable = true
    button.button:SetParent(button)
    button.button.sound = AudioSource()
    button.button.sound.Sound = sounds.button_click
    button.button.sound:SetParent(button)
    button.button.sound.Spatialized = true

    button.button.Physics = PhysicsMode.Static
    button.button.CollisionGroups = {5}
    button.Rotation.Y = math.pi
    button.Scale = 2
    button.button.clickedpos = Number3(0, -0.2, 0.1)

    button.button.click = function(self)
        if self.clickable then
            self.Position = self.Position + self.clickedpos
            self.sound:Play()
            self.clickable = false

            if narrator_game_start1.IsPlaying then
                narrator_game_start1:Stop()
                map_manager.narrator_glitch:Play()
                Timer(2, false, function()
                    map_manager:start_pt1_var1()
                    map_manager:use_mechanical_hand(
                        {
                            position = Number3(30, 10, 50),
                            object = self:GetParent(),
                            offset = Number3(0, 10, 0),
                            handle_rotations = 0.15,
                            take_out = true
                        }
                    )
                end)
            else
                map_manager:start_pt1_var1()
                map_manager:use_mechanical_hand(
                    {
                        position = Number3(30, 10, 50),
                        object = self:GetParent(),
                        offset = Number3(0, 10, 0),
                        handle_rotations = 0.15,
                        take_out = true
                    }
                )
            end

            Timer(1, false, function()
                self.sound:Destroy()
            end)
        end
    end

    Timer(3, false, function()
        self:use_mechanical_hand(
            {
                position = Number3(30, 10, 50),
                object = button,
                offset = Number3(0, 10, 0),
                handle_rotations = -0.05,
                handle_rotations_off = -0.3
            }
        )
    end)
end

map_manager.use_mechanical_hand = function(self, config)
    local defaultConfig = {
        position = Number3(30, 10, 30),
        handle_rotations = -0.3,
        handle_rotations_off = -0.5,
        time_multiplier = 1,
        reset_rotations = true, -- resets rotations after putting object in scene at out_time/2
        object = "none",
        offset = "none",
        take_out = false -- to remove object from scene
    }
    local cfg = {0}
    for k, v in pairs(defaultConfig) do
        if config[k] ~= nil then
            cfg[k] = config[k]
        else
            cfg[k] = v
        end
    end

    local hand = models.mechanical_hand[1]:Copy()
    hand.Rotation.Y = math.pi/2
    hand.right_handle = models.mechanical_hand[2]:Copy()
    hand.left_handle = models.mechanical_hand[3]:Copy()
    hand.t = 0

    hand.start_pos = cfg.position + Number3(0, 40, 0)
    hand.Position = Number3(hand.start_pos.X, hand.start_pos.Y, hand.start_pos.Z)

    hand.right_handle:SetParent(hand)
    hand.left_handle:SetParent(hand)

    if cfg.object ~= nil and cfg.object ~= "none" then
        if not cfg.take_out then
            hand.object = cfg.object
            hand.object.save_rotation = Rotation(
                hand.object.Rotation.X,
                hand.object.Rotation.Y,
                hand.object.Rotation.Z
            )
            hand.object:SetParent(hand)
            hand.object.Position = hand.Position - (cfg.offset or 0)
            hand.object.Rotation.Y = hand.object.Rotation.Y - math.pi/2
            debug.log("Hand object: " .. tostring(hand.object))
        end
    else
        debug.log("Hand object: none")
    end

    if cfg.take_out then
        hand.right_handle.Rotation.X = cfg.handle_rotations_off
        hand.left_handle.Rotation.X  = -cfg.handle_rotations_off
    else
        hand.right_handle.Rotation.X = cfg.handle_rotations
        hand.left_handle.Rotation.X  = -cfg.handle_rotations
    end

    hand.move_in_sound = AudioSource()
    hand.move_in_sound.Sound = sounds.arm_move_in
    hand.move_in_sound:SetParent(hand)
    hand.move_in_sound.Volume = 0.75
    hand.move_in_sound.Pitch = (1 + (1 / cfg.time_multiplier)) / 2
    hand.move_in_sound.Spatialized = true
    hand.move_in_sound:Play()

    hand.move_out_sound = AudioSource()
    hand.move_out_sound.Sound = sounds.arm_move_out
    hand.move_out_sound:SetParent(hand)
    hand.move_out_sound.Volume = 0.75
    hand.move_out_sound.Pitch = (1 + (1 / cfg.time_multiplier)) / 2
    hand.move_out_sound.StartAt = 0.2
    hand.move_out_sound.Spatialized = true

    hand.Tick = function(s, dt)
        local duration_in       = 1 * cfg.time_multiplier
        local hold_before_open  = 1 * cfg.time_multiplier  -- пауза перед открытием лап
        local open_time         = 0.5 * cfg.time_multiplier
        local duration_out      = 1 * cfg.time_multiplier
        local total_time

        if cfg.take_out then
            total_time = duration_in + duration_out + 0.1
        else
            total_time = duration_in + hold_before_open + open_time + duration_out
        end

        local t_sec = s.t / 63
        local phase = t_sec

        if phase < duration_in then
            local alpha = phase / duration_in
            s.Position = Number3(
                mathlib.easeOutBack(s.start_pos.X, cfg.position.X, alpha),
                mathlib.easeOutBack(s.start_pos.Y, cfg.position.Y, alpha),
                mathlib.easeOutBack(s.start_pos.Z, cfg.position.Z, alpha)
            )

            if cfg.take_out and alpha > 0.8 then
                if s.object == nil then
                    local obj = cfg.object
                    if obj ~= nil and obj.Parent == World then
                        s.object = obj
                        s.object.save_rotation = Rotation(obj.Rotation.X, obj.Rotation.Y, obj.Rotation.Z)
                        s.object:SetParent(s)
                        s.object.Position = s.Position - (cfg.offset or 0)
                        s.object.Rotation.Y = s.object.Rotation.Y - math.pi/2
                    end
                end
                s.right_handle.LocalRotation:Slerp(s.right_handle.LocalRotation, Rotation(cfg.handle_rotations, 0, 0), 0.1)
                s.left_handle.LocalRotation:Slerp(s.left_handle.LocalRotation, Rotation(-cfg.handle_rotations, 0, 0), 0.1)
            end

        elseif not cfg.take_out and phase < duration_in + hold_before_open then
            s.Position = cfg.position
            if s.object ~= nil then
                s.object:SetParent(World)
                s.object.Position = s.Position - (cfg.offset or 0)
                s.object.Rotation = s.object.save_rotation
                s.object = nil
            end

        elseif not cfg.take_out and phase < duration_in + hold_before_open + open_time then
            s.Position = cfg.position
            local alpha = (phase - duration_in - hold_before_open) / open_time
            s.right_handle.LocalRotation:Slerp(s.right_handle.LocalRotation, Rotation(cfg.handle_rotations_off, 0, 0), alpha)
            s.left_handle.LocalRotation:Slerp(s.left_handle.LocalRotation, Rotation(-cfg.handle_rotations_off, 0, 0), alpha)

        elseif phase < total_time then
            local alpha
            if cfg.take_out then
                alpha = (phase - duration_in) / duration_out
            else
                alpha = (phase - duration_in - hold_before_open - open_time) / duration_out
            end
            s.Position = Number3(
                (1 - alpha) * cfg.position.X + alpha * s.start_pos.X,
                (1 - alpha) * cfg.position.Y + alpha * s.start_pos.Y,
                (1 - alpha) * cfg.position.Z + alpha * s.start_pos.Z
            )

            if not s.move_out_sound.IsPlaying then
                s.move_out_sound:Play()
            end
        else
            s:Destroy()
        end

        if s.t ~= nil then
            s.t = s.t + 1
        end
    end


    hand:SetParent(World)

    return hand
end


function map_manager.start_pt1_var1()
    local narrator_pt1_var1_1 = AudioSource()
    narrator_pt1_var1_1.Sound = sounds.pt1_var1
    narrator_pt1_var1_1:SetParent(Camera)
    narrator_pt1_var1_1:Play()

    Timer(20, false, function()
        narrator_pt1_var1_1:Destroy()
    end)

    local button = Object()
    button.base = models.button[1]:Copy()
    button.base:SetParent(button)
    button.base.Physics = PhysicsMode.Static
    button.button = models.button[2]:Copy()
    button.button.clickable = true
    button.button:SetParent(button)
    button.button.sound = AudioSource()
    button.button.sound.Sound = sounds.button_click
    button.button.sound:SetParent(button)
    button.button.sound.Spatialized = true

    local text_overlay = Text()
    text_overlay.Text = "DO\nNOT\nPRESS"
    text_overlay.Color = Color(255, 255, 255)
    text_overlay.Format = { alignment="center" }
    text_overlay.Scale = 0.1
    text_overlay:SetParent(button)
    text_overlay.Tick = function(self)
        self.Position = button.button.Position + Number3(0, 0.4, 0)
        self.Rotation.Y = 0
        self.Rotation.X = math.pi/2-0.35
    end

    button.button.Physics = PhysicsMode.Static
    button.button.CollisionGroups = {5}
    button.Rotation.Y = math.pi
    button.Scale = 2
    button.button.clickedpos = Number3(0, -0.2, 0.1)

    button.button.click = function(self)
        if self.clickable then
            self.Position = self.Position + self.clickedpos
            self.sound:Play()
            self.clickable = false
            Timer(1, false, function()
                self.sound:Destroy()
            end)

            if narrator_pt1_var1_1.IsPlaying then
                narrator_pt1_var1_1:Stop()
                map_manager.narrator_glitch:Play()
                Timer(2, false, function()
                    map_manager:start_pt2_var1()
                    map_manager:use_mechanical_hand(
                        {
                            position = Number3(30, 10, 50),
                            object = self:GetParent(),
                            offset = Number3(0, 10, 0),
                            handle_rotations = 0.15,
                            take_out = true
                        }
                    )
                end)
            else
                map_manager:start_pt2_var1()
                map_manager:use_mechanical_hand(
                    {
                        position = Number3(30, 10, 50),
                        object = self:GetParent(),
                        offset = Number3(0, 10, 0),
                        handle_rotations = 0.15,
                        take_out = true
                    }
                )
            end
        end
    end

    Timer(15, false, function()
        map_manager:use_mechanical_hand(
            {
                position = Number3(30, 10, 50),
                object = button,
                offset = Number3(0, 10, 0),
                handle_rotations = -0.05
            }
        )
    end)
end

function map_manager.start_pt2_var1()
    local narrator_pt2_var1= AudioSource()
    narrator_pt2_var1.Sound = sounds.voice_offline
    narrator_pt2_var1:SetParent(Camera)
    narrator_pt2_var1:Play()

    Timer(8, false, function()
        narrator_pt2_var1:Destroy()
        map_manager.lamp:turn_off()

        local impact_sound = AudioSource()
        impact_sound.Sound = sounds.impact_hit
        impact_sound:SetParent(Camera)
        impact_sound.Volume = 0.5
        impact_sound.Pitch = 0.5
        impact_sound:Play()

        -- paint the walls and floors at white
        local black_screen = _UIKIT:frame()
        black_screen.Color = Color(0, 0, 0)
        black_screen.Size = {Screen.Width, Screen.Height}

        Timer(1, false, function()
            for key, value in ipairs(map_manager.floors) do
                if not value.IsUnlit then
                    value.Image = {data = textures.floor_concrete_clear, filtering = false}
                end
            end

            for key, value in ipairs(map_manager.walls) do
                if not value.IsUnlit then
                    value.Image = {data = textures.wall_concrete_clear, filtering = false}
                end
            end

            map_manager.lamp_light1.Radius = 65
            map_manager.lamp_light2.Radius = 65

            map_manager.isLight = true

            for i=1, 10 do
                Timer(0.1 * i, false, function()
                    black_screen.Color.A = 1.0 - (i * 0.1)
                end)
            end
            Timer(1, false, function()
                black_screen:remove()
                black_screen = nil
            end)
        end)

        Timer(5, false, function()
            impact_sound:Destroy()
            local new_voice_assistant = AudioSource()
            new_voice_assistant.Sound = sounds.new_voice_assistant
            new_voice_assistant:SetParent(Camera)
            new_voice_assistant:Play()

            Timer(26, false, function()
                new_voice_assistant:Destroy()
                map_manager.lamp:turn_on()
                local sound = AudioSource()
                sound.Sound = sounds.light_switch
                sound:SetParent(Camera)
                sound:Play()
                Timer(3, false, function()
                    sound:Destroy()

                    local new_assistant = AudioSource()
                    new_assistant.Sound = sounds.new_assistant
                    new_assistant:SetParent(Camera)
                    new_assistant:Play()

                    Timer(31, false, function()
                        -- spawn the lever
                        map_manager.lever = Object()
                        map_manager.lever.base = models.lever[1]:Copy()
                        map_manager.lever.base:SetParent(map_manager.lever)
                        map_manager.lever.base.Physics = PhysicsMode.Static
                        map_manager.lever.lever = models.lever[2]:Copy()
                        map_manager.lever.lever.clickable = true
                        map_manager.lever.lever:SetParent(map_manager.lever)

                        map_manager.lever.lever.sound = AudioSource()
                        map_manager.lever.lever.sound.Sound = sounds.button_click
                        map_manager.lever.lever.sound:SetParent(button)
                        map_manager.lever.lever.sound.Spatialized = true

                        map_manager.lever.lever.Physics = PhysicsMode.Static
                        map_manager.lever.lever.CollisionGroups = {5}

                        map_manager.lever.Scale = 2
                        map_manager.lever.Rotation.Y = math.pi

                        map_manager.lever.lever.click = function(self)
                            if self.clickable then
                                self.Rotation.X = self.Rotation.X + math.pi/3
                                self.clickable = false
                                map_manager.lever.lever.sound:Play()

                                if new_assistant.IsPlaying then
                                    new_assistant:Stop()
                                    new_assistant:Destroy()
                                end

                                Timer(1, false, function()
                                    map_manager:use_mechanical_hand(
                                        {
                                            position = Number3(30, 10, 50),
                                            object = map_manager.lever,
                                            offset = Number3(0, 10, 0),
                                            handle_rotations = -0.05,
                                            handle_rotations_off = -0.3,
                                            take_out = true,
                                        }
                                    )

                                    local you_pressed_the_lever = AudioSource()
                                    you_pressed_the_lever.Sound = sounds.you_pressed_the_lever
                                    you_pressed_the_lever:SetParent(Camera)
                                    you_pressed_the_lever:Play()

                                    map_manager:start_leave_lever()
                                end)
                            end
                        end

                        map_manager:use_mechanical_hand(
                            {
                                position = Number3(30, 10, 50),
                                object = map_manager.lever,
                                offset = Number3(0, 10, 0),
                                handle_rotations = -0.05,
                                handle_rotations_off = -0.3
                            }
                        )
                    end)
                end)
            end)
        end)
    end)
end

function map_manager.start_leave_lever(self)
    debug.log("Ending can be made by pressing exit button.")

    local button = Object()
    button.base = models.button[1]:Copy()
    button.base:SetParent(button)
    button.base.Physics = PhysicsMode.Static
    button.button = models.button[2]:Copy()
    button.button.clickable = true
    button.button:SetParent(button)
    button.button.sound = AudioSource()
    button.button.sound.Sound = sounds.button_click
    button.button.sound:SetParent(button)
    button.button.sound.Spatialized = true

    local text_overlay = Text()
    text_overlay.Text = "EXIT"
    text_overlay.Color = Color(255, 255, 255)
    text_overlay.Format = { alignment="center" }
    text_overlay.Scale = 0.15
    text_overlay:SetParent(button)
    text_overlay.Tick = function(self)
        self.Position = button.button.Position + Number3(0, 0.4, 0)
        self.Rotation.Y = math.pi
        self.Rotation.X = math.pi/2-0.35
    end

    button.button.Physics = PhysicsMode.Static
    button.button.CollisionGroups = {5}
    button.Scale = 2
    button.button.clickedpos = Number3(0, -0.2, -0.1)

    button.button.click = function(self)
        if self.clickable then
            self.Position = self.Position + self.clickedpos
            self.sound:Play()
            self.clickable = false

            map_manager:open_exit()
            map_manager.ending = "protocolviolation"
            map_manager:use_mechanical_hand(
                {
                    position = Number3(30, 10, 10),
                    object = button,
                    offset = Number3(0, 10, 0),
                    handle_rotations = -0.05,
                    handle_rotations_off = -0.3,
                    take_out = true,
                }
            )
        end
    end

    Timer(18, false, function()
        map_manager:use_mechanical_hand(
            {
                position = Number3(30, 10, 10),
                object = button,
                offset = Number3(0, 10, 0),
                handle_rotations = -0.05,
                handle_rotations_off = -0.3,
                time_multiplier = 1.5,
            }
        )
    end)
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

        {
            pos = Number3(-1, 0, 0),
            rot = Rotation(math.pi/2, 0, 0),
            isWhite = true,
        },
        {
            pos = Number3(-1, 0, 1),
            rot = Rotation(math.pi/2, 0, 0),
            isWhite = true,
        },
        {
            pos = Number3(-1, 0, 2),
            rot = Rotation(math.pi/2, 0, 0),
            isWhite = true,
        },
        {
            pos = Number3(-1, 1, 0),
            rot = Rotation(math.pi/2, 0, 0),
            isWhite = true,
        },
        {
            pos = Number3(-1, 1, 1),
            rot = Rotation(math.pi/2, 0, 0),
            isWhite = true,
        },
        {
            pos = Number3(-1, 1, 2),
            rot = Rotation(math.pi/2, 0, 0),
            isWhite = true,
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
            isDoor = true
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

        {
            pos = Number3(0, 1, 0),
            rot = Rotation(0, 0, 0),
            make_darker = true
        },
        {
            pos = Number3(1, 1, 0),
            rot = Rotation(0, 0, 0),
            make_darker = true
        },
        {
            pos = Number3(2, 1, 0),
            rot = Rotation(0, 0, 0),
            make_darker = true
        },
        {
            pos = Number3(0, 1, 3),
            rot = Rotation(0, 0, 0),
            make_darker = true
        },
        {
            pos = Number3(1, 1, 3),
            rot = Rotation(0, 0, 0),
            make_darker = true
        },
        {
            pos = Number3(2, 1, 3),
            rot = Rotation(0, 0, 0),
            make_darker = true
        },
        {
            pos = Number3(0, 1, 0),
            rot = Rotation(0, -math.pi/2, 0),
            make_darker = true
        },
        {
            pos = Number3(0, 1, 1),
            rot = Rotation(0, -math.pi/2, 0),
            make_darker = true
        },
        {
            pos = Number3(0, 1, 2),
            rot = Rotation(0, -math.pi/2, 0),
            make_darker = true
        },
        {
            pos = Number3(3, 1, 0),
            rot = Rotation(0, -math.pi/2, 0),
            make_darker = true
        },
        {
            pos = Number3(3, 1, 1),
            rot = Rotation(0, -math.pi/2, 0),
            make_darker = true
        },
        {
            pos = Number3(3, 1, 2),
            rot = Rotation(0, -math.pi/2, 0),
            make_darker = true
        },



        {
            pos = Number3(-1, 0, 0),
            rot = Rotation(0, 0, 0),
            isWhite = true
        },
        {
            pos = Number3(-1, 0, 3),
            rot = Rotation(0, 0, 0),
            isWhite = true
        },
        {
            pos = Number3(-1, 0, 0),
            rot = Rotation(0, -math.pi/2, 0),
            isWhite = true
        },
        {
            pos = Number3(-1, 0, 2),
            rot = Rotation(0, -math.pi/2, 0),
            isWhite = true
        },
        {
            pos = Number3(-1, 0, 1),
            rot = Rotation(0, -math.pi/2, 0),
            isWhite = true
        },
    }

    return wall_table
end