
function init_sugarcoat()
  init_sugar("Hello world!", GAME_WIDTH, GAME_HEIGHT, GAME_SCALE)
  
  use_palette(ak54)
  screen_render_stretch(false)
  screen_render_integer_scale(false)
  set_frame_waiting(60)
end

function init_input()
  register_btn(0, 0, input_id("keyboard", "left"))
  register_btn(1, 0, input_id("keyboard", "right"))
  register_btn(2, 0, input_id("keyboard", "up"))
  register_btn(3, 0, input_id("keyboard", "down"))
end

function init_game()
  init_player()
end

function load_level(lvl_num)
  -- todo: read pixel data for level
  -- todo: place player at start
  -- todo: 
  -- todo: 
  -- todo: 
  -- todo: 
end

function init_player()
  player = {
    x = 30,
    y = 30,
    walk_anim = {1,2,3,4}
  }
end

function load_assets()
  load_png("spritesheet", "assets/spritesheet.png", nil, true)

  -- todo: load sfx + music

end