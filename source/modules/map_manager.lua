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
        wall.Physics = PhysicsMode.Static
        if value.make_darker then
            wall.Color = Color(220, 220, 220)
        end
        wall:SetParent(self.map)
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

    -- create the lamp
    self.lamp_light1 = Light()
    self.lamp_light1.Color = Color(255, 255, 255)
    self.lamp_light1.Radius = 50
    self.lamp_light1.Hardness = 0
    self.lamp_light1:SetParent(self.map)

    self.lamp_light2 = Light()
    self.lamp_light2.Color = Color(255, 255, 255)
    self.lamp_light2.Radius = 50
    self.lamp_light2.Hardness = 0
    self.lamp_light2:SetParent(self.map)

    self.lamp = models.lamp[1]:Copy()
    self.lamp.Position = Number3(30, 20, 30)
    self.lamp:SetParent(self.map)
    self.lamp.Scale = 0.5
    self.lamp.IsUnlit = true
    self.lamp.t = 0
    self.lamp.Tick = function(s)
        s.Rotation.Y = math.sin(s.t*0.01)*0.1 + math.pi/2
        self.lamp_light1.Position = Number3(30, 20, 30) + s.Forward*2
        self.lamp_light2.Position = Number3(30, 20, 30) + s.Backward*2
        s.t = s.t + 1
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
        self.lamp_sound1:Play()
        Timer(0.5, false, function()
            self.lamp_sound2:Play()
        end)
    end)

    -- create black ceiling gradient
    for i = 1, 20 do
        local quad = Quad()
        quad.Scale = 20*3
        quad.Rotation = Rotation(math.pi/2, 0, 0)
        quad.Color = Color(255, 255, 255, math.floor(i*255/20))
        quad.Position.Y = 20 + (i*0.5)
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
                            handle_rotations = -0.05,
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
                        handle_rotations = -0.05,
                        take_out = true
                    }
                )
            end

            Timer(1, false, function()
                self.sound:Destroy()
            end)
        end
    end

    Timer(20, false, function()
        self:use_mechanical_hand(
            {
                position = Number3(30, 10, 50),
                object = button,
                offset = Number3(0, 10, 0),
                handle_rotations = -0.05
            }
        )
    end)
end

map_manager.use_mechanical_hand = function(self, config)
    local defaultConfig = {
        position = Number3(30, 10, 30),
        handle_rotations = -0.3,
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

    if cfg.object ~= nil or cfg.object ~= "none" then
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

    hand.right_handle.Rotation.X = cfg.handle_rotations
    hand.left_handle.Rotation.X = -cfg.handle_rotations

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
    hand.move_out_sound.Spatialized = true

    hand.Tick = function(s, dt)
        local duration_in = 1 * cfg.time_multiplier
        local hold_time   = 1 * cfg.time_multiplier
        local duration_out= 1 * cfg.time_multiplier
        local total_time  = duration_in + hold_time + duration_out

        local t_sec = s.t / 63
        local phase = t_sec

        if phase < duration_in then
            local alpha = phase / duration_in
            s.Position = Number3(
                mathlib.lerp(s.start_pos.X, cfg.position.X, alpha),
                mathlib.lerp(s.start_pos.Y, cfg.position.Y, alpha),
                mathlib.lerp(s.start_pos.Z, cfg.position.Z, alpha)
            )

        elseif phase < duration_in + hold_time then
            s.Position = cfg.position
            if s.object ~= nil then
                s.object:SetParent(World)
                s.object.Position = s.Position - (cfg.offset or 0)
                s.object.Rotation = s.object.save_rotation
                s.object = nil
            end

        elseif phase < total_time then
            local alpha = (phase - duration_in - hold_time) / duration_out
            s.Position = Number3(
                mathlib.lerp(cfg.position.X, s.start_pos.X, alpha),
                mathlib.lerp(cfg.position.Y, s.start_pos.Y, alpha),
                mathlib.lerp(cfg.position.Z, s.start_pos.Z, alpha)
            )

            if cfg.reset_rotations and alpha > 0.1 then
                s.right_handle.LocalRotation:Slerp(s.right_handle.LocalRotation, Rotation(0, 0, 0), 0.1)
                s.left_handle.LocalRotation:Slerp(s.left_handle.LocalRotation, Rotation(0, 0, 0), 0.1)
            end

            if not s.move_out_sound.IsPlaying then
                s.move_out_sound:Play()
            end

            if cfg.take_out and s.object == nil then
                local obj = cfg.object
                if obj ~= nil and obj.Parent == World then
                    s.object = obj
                    s.object.save_rotation = Rotation(
                        s.object.Rotation.X,
                        s.object.Rotation.Y,
                        s.object.Rotation.Z
                    )
                    s.object:SetParent(s)
                    s.object.Position = s.Position - (cfg.offset or 0)
                    s.object.Rotation.Y = s.object.Rotation.Y - math.pi/2
                end
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
                    map_manager:start_pt1_var1()
                    map_manager:use_mechanical_hand(
                        {
                            position = Number3(30, 10, 50),
                            object = self:GetParent(),
                            offset = Number3(0, 10, 0),
                            handle_rotations = -0.05,
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
                        handle_rotations = -0.05,
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
    }

    return wall_table
end