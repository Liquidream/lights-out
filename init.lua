
function init_sugarcoat()
  init_sugar("Lights-Out", GAME_WIDTH, GAME_HEIGHT, GAME_SCALE)
  
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
  load_level(curr_level)

  -- reset game time
  game_time = 0
end

function load_level(lvl_num)
  -- todo: read pixel data for level
  spritesheet("levels")
  for x=0,15 do
    for y=0,15 do
      local col=sget(x, y, "levels")
      -- handle level data
      if col==COL_START then
        -- found start
        log("found player start at: "..x..","..y)
        player.x,player.y = x*8,y*8
      else
      end
    end
  end

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
    angle = 0, --0=right, 0.25=top, 0.5=left, 0.75=down
    --dir = 3, --0=left, 1=right, 2=up, 3=down
    walk_anim = {1,2,3,4}
  }
end

function load_assets()
  -- load gfx
  load_png("spritesheet", "assets/spritesheet.png", nil, true)
  load_png("levels", "assets/levels.png", nil, true)
  -- capture pixel info
  scan_surface("levels")

  -- todo: load sfx + music

end