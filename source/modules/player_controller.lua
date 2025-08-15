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

    self.tick = Object()
    self.t = 0

    self.tick.Tick = function(_)
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
    end

    Player.Position = Number3(30, 1, 10)

    Client.AnalogPad = function(dx, dy)
        Player.LocalRotation = Rotation(0, dx * 0.01, 0) * Player.LocalRotation
        Player.Head.LocalRotation = Rotation(-dy * 0.01, 0, 0) * Player.Head.LocalRotation

        local dpad = require("controls").DirectionalPadValues
        Player.Motion = (Player.Forward * dpad.Y + Player.Right * dpad.X) * Player._speed
    end

    Client.DirectionalPad = function(x, y)
        Player.Motion = (Player.Forward * y + Player.Right * x) * Player._speed
    end
end