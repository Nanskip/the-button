local player_controller = {}

player_controller.init = function(self)
    debug.log("Player Controller initialized.")

    Player:SetParent(World)
    Player.Body.IsHidden = true

    Camera:SetModeFree()
    Pointer:Hide()

    self.click_listener = LocalEvent:Listen(LocalEvent.Name.Action2, function()
        if self.clicking ~= nil then
            self.clicking:click()
        end
    end)

    self.hand_icon = _UIKIT:createFrame()
    self.hand_icon.Color = Color(255, 255, 255, 0)
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

    self.tick.Tick = function(_)
        Camera.Position = Number3(
            Player.Position.X,
            Player.Position.Y+10,
            Player.Position.Z)
        Camera.Rotation = Number3(
            Player.Head.Rotation.X,
            Player.Head.Rotation.Y,
            Player.Head.Rotation.Z
        )
        self.hand_icon.pos = Number2(Screen.Width/2-20, Screen.Height/2-20)

        -- cast a ray to check if player is looking at a button
        local ray = Ray(Camera.Position, Camera.Forward)
        local impact = ray:Cast({5})
        if impact.Object ~= nil then
            if impact.Object.clickable and impact.Distance < 10 then
                self.hand_icon.Color.A = 254
                self.clicking = impact.Object
            else
                self.hand_icon.Color.A = 0
                self.clicking = nil
            end
        else
            self.hand_icon.Color.A = 0
            self.clicking = nil
        end
    end

    Player.Position = Number3(30, 1, 10)
end