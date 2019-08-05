
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
        -- place player at start
        player.x,player.y = x*8,y*8
        player.tx,player.ty = x,y
      else
      end
    end
  end

  -- check the first tile (player start)
  checkTile()
end

function init_player()
  player = {
    x = 30,
    y = 30,
    angle = 0, --0=right, 0.25=top, 0.5=left, 0.75=down
    --dir = 3, --0=left, 1=right, 2=up, 3=down
    idle_anim = {18},
    walk_anim_1 = {16,17},
    walk_anim_2 = {18,19},
    fall_anim = {24,25,26,27,28,29},
    frame_pos = 1,
    frame_delay = 5,
    frame_count = 0,
    moving = false,
    moveFrameCount = 0,
    tileHistory={},
    moveCount = 0, -- number of moves player has made
  }
  player.curr_anim = player.idle_anim
end

function init_player_move(angle, dx, dy)
  player.angle = angle
  -- calc tween "smoothness"
  local frames = 12
  local pxDist = 8
  player.dx = (pxDist/frames) * dx
  player.dy = (pxDist/frames) * dy
  player.moveFrameCount = frames
  player.moving = true
  player.newX = player.x+(8*dx)
  player.newY = player.y+(8*dy)
  -- switch to a "walking" anim
  init_anim(player, 
       player.moveCount%2==0 
        and player.walk_anim_1 or player.walk_anim_2)
  player.moveCount = player.moveCount + 1
end

function init_anim(anim_obj, anim, func_on_finish)
  anim_obj.curr_anim = anim
  anim_obj.frame_count = 0
  if anim_obj.frame_pos > #anim then
    anim_obj.frame_pos = 1
  end
  -- set the function to run on finish (if applicable)
  anim_obj.func_on_finish = func_on_finish
end

function load_assets()
  -- load gfx
  load_png("spritesheet", "assets/spritesheet.png", nil, true)
  load_png("levels", "assets/levels.png", nil, true)
  -- capture pixel info
  scan_surface("levels")

  -- todo: load sfx + music

end