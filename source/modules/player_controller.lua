local player_controller = {}

player_controller.init = function(self)
    debug.log("Player Controller initialized.")

    Player:SetParent(World)
    Player.Body.IsHidden = true

    Player.camera_rotation_offset = Rotation(0, 0, 0)
    Player._speed = 25

    Camera:SetModeFree()
    Pointer:Hide()

    self.click_listener = LocalEvent:Listen(LocalEvent.Name.Action2, function()
        if self.clicking ~= nil then
            self.clicking:click()
        end
    end)
    self.pointer = _UIKIT:createFrame()
    self.pointer.Color = Color(255, 255, 255, 0)
    self.pointer.Size = Number2(16, 16)
    self.pointer.pos = Number2(Screen.Width/2-4, Screen.Height/2-4)
    self.pointer.background.Image = {data = textures.pointer}
    self.pointer.Size = Number2(8, 8)

    self.hand_icon = _UIKIT:createFrame()
    self.hand_icon.Color = Color(255, 255, 255, 254)
    self.hand_icon.Size = Number2(512, 512)
    self.hand_icon.pos = Number2(Screen.Width/2-20, Screen.Height/2-20)
    self.hand_icon.background.Image = {data = textures.hand_icon}
    self.hand_icon.Size = Number2(40, 40)

    if Client.IsMobile then
        self.hand_icon.onPress = function(_)
            if self.clicking ~= nil then
                self.clicking:click()
            end
            debug.log("Hand icon pressed, probably mobile client.")
        end
    end

    self.step_sound1 = AudioSource()
    self.step_sound1.Sound = sounds.step_sound1
    self.step_sound1.Volume = 0.3
    self.step_sound1:SetParent(Camera)

    self.step_sound2 = AudioSource()
    self.step_sound2.Sound = sounds.step_sound2
    self.step_sound2.Volume = 0.3
    self.step_sound2:SetParent(Camera)

    self.tick = Object()
    self.t = 0
    self.motion_t = 0

    self.tick.Tick = function(_, dt)
        Camera.Position = Number3(
            Player.Position.X,
            Player.Position.Y+10,
            Player.Position.Z)
        Camera.Rotation = Rotation(
            Player.Head.Rotation.X,
            Player.Head.Rotation.Y,
            Player.Head.Rotation.Z
        )
        self.hand_icon.pos = Number2(Screen.Width/2-20, Screen.Height/2-20)
        self.pointer.pos = Number2(Screen.Width/2-4, Screen.Height/2-4)

        Camera.Rotation = Camera.Rotation * Player.camera_rotation_offset
        Player.camera_rotation_offset.X = math.sin(self.t*0.02)*0.005

        -- cast a ray to check if player is looking at a button
        local ray = Ray(Camera.Position, Camera.Forward)
        local impact = ray:Cast({5})
        if impact.Object ~= nil then
            if impact.Object.clickable and impact.Distance < 10 then
                self.hand_icon.Color.A = 254
                self.pointer.Color.A = 0
                self.clicking = impact.Object
            else
                self.hand_icon.Color.A = 0
                self.pointer.Color.A = 254
                self.clicking = nil
            end
        else
            self.hand_icon.Color.A = 0
            self.pointer.Color.A = 254
            self.clicking = nil
        end

        if self.t ~= nil then
            self.t = self.t + 1
        end

        if not (Player.Motion.X < 0.1 and Player.Motion.X > -0.1) or not (Player.Motion.Z < 0.1 and Player.Motion.Z > -0.1) then
            self.motion_t = self.motion_t + dt
        else
            self.motion_t = 0.2
        end

        if self.motion_t > 0.4 then
            if math.random(0, 1) == 0 then
                self.step_sound1:Play()
            else
                self.step_sound2:Play()
            end
            self.motion_t = 0
        end

        if Player.isExiting then
            Player.Motion = Number3(0, 0, 0)
            if Player.white_screen == nil then
                Player.white_screen = _UIKIT:createFrame()
                Player.exit_timer = 0

                local exit_sound = AudioSource()
                exit_sound.Sound = sounds.exit_music
                exit_sound:SetParent(Camera)
                exit_sound:Play()

                Timer(5, false, function()
                    exit_sound:Destroy()
                    ending_manager:give_ending(map_manager.ending)
                end)
            end

            Player.exit_timer = Player.exit_timer + (dt*63)
            Player.white_screen.Width = Screen.Width
            Player.white_screen.Height = Screen.Height
            Player.white_screen.Color = Color(255, 255, 255, math.min(math.floor(Player.exit_timer), 255))
        end
    end

    Player.Position = Number3(30, 1, 10)

    Client.AnalogPad = function(dx, dy)
        Player.LocalRotation = Rotation(0, dx * 0.01, 0) * Player.LocalRotation
        Player.Head.LocalRotation = Rotation(-dy * 0.01, 0, 0) * Player.Head.LocalRotation

        local dpad = require("controls").DirectionalPadValues
        if not Player.isExiting then
            Player.Motion = (Player.Forward * dpad.Y + Player.Right * dpad.X) * Player._speed
        end
    end

    Client.DirectionalPad = function(x, y)
        if not Player.isExiting then
            Player.Motion = (Player.Forward * y + Player.Right * x) * Player._speed
        end
    end
end