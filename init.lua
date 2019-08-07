
function init_sugarcoat()
  init_sugar("Lights-Out", GAME_WIDTH, GAME_HEIGHT, GAME_SCALE)
  
  use_palette(ak54)
  load_font ("assets/Particle.ttf", 16, "main-font", true)
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
  init_detail_anims()
  -- reset game time
  game_time = 0
  state_time = 0
  -- set state
  gameState = GAME_STATE.LVL_PLAY 
  log("init done!!")
end

function load_level(lvl_num)
  local lvl_offset = (curr_level-1)*8
  -- todo: read pixel data for level
  spritesheet("levels")
  for x=0,7 do
    for y=0,7 do
      local col=sget(x+lvl_offset, y, "levels")
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
    angle = 0.25, --0=right, 0.25=down, 0.5=left, 0.75=top
    idle_anim = {18},
    walk_anim_1 = {16,17},
    walk_anim_2 = {18,19},
    fall_anim = {24,25,26,27,28,29},
    win_anim = {32,33,34,35},
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
  player.lastX = player.x
  player.lastY = player.y
  player.moving = true
  
  -- assume normal move (within screen bounds?)
  player.newX = player.x+(8*dx)
  player.newY = player.y+(8*dy)

  -- check for "wrap" screen movement
  if player.newX < 0 then player.newX = 56 end
  if player.newY < 0 then player.newY = 56 end
  if player.newX > 56 then player.newX = 0 end
  if player.newY > 56 then player.newY = 0 end

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

function init_detail_anims()
  -- random monsters
  monsters = {}
  for i=1,irnd(2)+2 do
    local val = irnd(64)
    local cx,cy = val%8, flr(val/8)    
    if sget(cx, cy, "levels")==0 
    and sget(cx, cy-1, "levels")==0 
    then      
      table.insert(monsters, {
        x = cx*8,
        y = cy*8,
        curr_anim = {40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63},
        frame_pos = irnd(24),
        frame_delay = 5,
        frame_count = 0,
      })      
    end
  end
end