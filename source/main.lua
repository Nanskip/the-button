Modules = {
    worldgen = "modules/worldgen.lua",
    loading_screen = "modules/loading_screen.lua",
    debug = "modules/debug.lua",
    mathlib = "modules/mathlib.lua",
    advanced_ui = "modules/advanced_ui.lua",
    map_manager = "modules/map_manager.lua",
    player_controller = "modules/player_controller.lua",
}

Models = {
    lamp = "models/lamp.glb",
    mechanical_hand = "models/mechanical_hand.glb",
    button = "models/button.glb",
    lever = "models/lever.glb",
    rusty_tube = "models/rusty_tube.glb",
}

Textures = {
    intro_logo = "textures/intro_logo.png",
    floor_concrete = "textures/floor_concrete.png",
    wall_concrete = "textures/wall_concrete.png",
    hand_icon = "textures/hand_icon.png",
    mud_texture = "textures/mud_texture.png",
    skip_tag = "textures/skip_tag.png",
    pointer = "textures/pointer.png",
    white_gradient = "textures/white_gradient.png",

    --debug
    lightbulb = "textures/lightbulb.png",
}

Sounds = {
    loading_completed = "sounds/loading_completed.mp3",
    lamp_buzz = "sounds/lamp_buzz.mp3",
    narrator_game_start = "sounds/game_start.mp3",
    light_switch = "sounds/light_switch.mp3",
    dark_ambient = "sounds/dark_ambient.mp3",
    arm_move_in = "sounds/arm_move_in.mp3",
    arm_move_out = "sounds/arm_move_out.mp3",
    button_click = "sounds/button_click.mp3",
    impact_hit = "sounds/impact_hit.mp3",
    exit_door_open1 = "sounds/exit_door_open1.mp3",
    exit_door_open2 = "sounds/exit_door_open2.mp3",

    pt1_var1 = "sounds/pt1_var1.mp3",
    voice_glitch = "sounds/voice_glitch.mp3",
    voice_offline = "sounds/voice_offline.mp3",
    new_voice_assistant = "sounds/new_voice_assistant.mp3",
    new_assistant = "sounds/new_assistant.mp3",

    step_sound1 = "sounds/step_sound1.mp3",
    step_sound2 = "sounds/step_sound2.mp3",
}

Data = {

}

Other = {
    vcr_font = "other/vcr_font.ttf",
}

_ON_START = function()
    loading_screen:intro()
    _UI:init()
end

_ON_START_CLIENT = function()
    _UIKIT = require("uikit")
    _UI = advanced_ui
    _BADGES = require("badge")

    loading_screen:start()
end