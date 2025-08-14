local ui_manager = {}

ui_manager.init = function(self)
    debug.log("UI Manager initialized.")
    self.config = {
        game = {
            name = "Pocket Lands",
            version = "0.1",
            author = "Nanskip",
            gdk = "NaN-GDK",
        },
        themes = {
            default = {
                blank_color = Color(255, 255, 255, 254),
                button_texture = textures.button_template,
                button_texture_pressed = textures.button_template_pressed,
                frame_texture = textures.frame_template,
            }
        }
    }

    self.theme = self.config.themes.default
    self.buttons = {}
    debug.log("UI Manager: set default theme.")

    self:test()
end

ui_manager.test = function(self)
    debug.log("UI Manager: testing features.")

    test_button = self:createButton({
        text = "Test Button",
        size = Number2(200, 100),
        pos = Number2(Screen.Width/2-100, 100),
        color = Color(255, 255, 255),
        onRelease = function(self)
            debug.log("Test button released.")
            self:resetTexture()
        end,
    })
end

ui_manager.createButton = function(self, config)
    local defaultConfig = {
        text = "Button",
        textsize = 14,
        textcolor = Color(0, 0, 0),
        size = Number2(100, 100),
        pos = Number2(0, 0),
        color = self.theme.blank_color,
        texture = self.theme.button_texture,
        texture_pressed = self.theme.button_texture_pressed,
        onPress = function(self)
            debug.log("Button pressed: " .. self.text)
            self.background.Image = {
                data = self.pressed_texture,
                slice9 = true,
                slice9Width = 20,
                slice9Scale = 1.5,
                alpha = true
            }

            self.text_overlay.pos.Y = self.pos.Y + (self.Height - self.text_overlay.Height)/2 + 6 - 12
        end,
        onRelease = function(self)
            debug.log("Button released: " .. self.text)
            self:resetTexture()
        end,
    }

    local cfg = {}
    for k, v in pairs(defaultConfig) do
        if config[k] ~= nil then
            cfg[k] = config[k]
        else
            cfg[k] = v
        end
    end

    -- creating button
    local button = _UIKIT:createFrame()
    -- button.background is a quad, let's texture it with 9-slice
    button.main_texture = cfg.texture
    button.pressed_texture = cfg.texture_pressed
    button.Width = cfg.size.X
    button.Height = cfg.size.Y
    button.pos = cfg.pos
    button.background.Color = cfg.color
    button.text = cfg.text

    button.onPress = cfg.onPress
    button.onRelease = cfg.onRelease

    -- creating text over button
    button.text_overlay = _UIKIT:createText(cfg.text)
    button.text_overlay.Color = cfg.textcolor
    button.text_overlay.object.FontSize = cfg.textsize
    button.text_overlay.pos = {
        button.pos.X + (button.Width - button.text_overlay.Width)/2,
        button.pos.Y + (button.Height - button.text_overlay.Height)/2
    }

    button.resetTexture = function(self)
        self.background.Image = {
            data = self.main_texture,
            slice9 = true,
            slice9Width = 20,
            slice9Scale = 1.5,
            alpha = true
        }
        self.text_overlay.pos.Y = self.pos.Y + (self.Height - self.text_overlay.Height)/2 + 6
    end
    button:resetTexture()

    button.id = #self.buttons+1
    self.buttons[#self.buttons+1] = button

    return button
end

ui_manager.releaseListener = LocalEvent:Listen(LocalEvent.Name.PointerUp, function(pe)
    for _, button in ipairs(ui_manager.buttons) do
        -- check if pointer is over button
        local x = pe.X * Screen.Width
        local y = pe.Y * Screen.Height
        if button.pos.X <= x and button.pos.X + button.Width >= x and button.pos.Y <= y and button.pos.Y + button.Height >= y then
            -- released over button!
            if button.isPressed then
                button:onRelease()
                button.isPressed = false
            end
        end
        button:resetTexture()
    end
end)