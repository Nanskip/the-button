local player_controller = {}

player_controller.init = function(self)
    debug.log("Player Controller initialized.")

    Player:SetParent(World)
    Player.Body.IsHidden = true

    Camera:SetModeFree()
    Pointer:Hide()

    self.hand_icon = _UIKIT:createFrame()
    self.hand_icon.Color = Color(255, 255, 255, 0)
    self.hand_icon.Size = Number2(512, 512)
    self.hand_icon.pos = Number2(Screen.Width/2-20, Screen.Height/2-20)
    self.hand_icon.background.Image = {data = textures.hand_icon}
    self.hand_icon.Size = Number2(40, 40)

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

        -- cast a ray to check if player is looking at a button
        local ray = Ray(Camera.Position, Camera.Forward)
        local impact = ray:Cast({5})
        if impact.Object ~= nil then
            if impact.Object.clickable then
                self.hand_icon.Color.A = 254
            else
                self.hand_icon.Color.A = 0
            end
        else
            self.hand_icon.Color.A = 0
        end
    end

    Player.Position = Number3(30, 1, 10)
end