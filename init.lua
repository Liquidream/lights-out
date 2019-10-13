local Sounds = require 'sounds'

_t=0

function init_sugarcoat()
  init_sugar("Lights-Out", GAME_WIDTH, GAME_HEIGHT, GAME_SCALE)
  
  use_palette(ak54)
  load_font ("assets/Hungry.ttf", 16, "main-font", true)
  --load_font ("assets/Particle.ttf", 16, "main-font", true)
  load_png("title", "assets/title-text-small.png", nil, true)
  screen_render_stretch(false)
  screen_render_integer_scale(false)
  set_frame_waiting(60)
end

function init_data()
  -- Get User info
  network.async(function()
    user = castle.user.getMe()
    my_id = user.userId
    my_name = user.username
  end)
  -- Get saved data...
  -- Last level reached
  storage.getUserValue("currLevel", START_LEVEL, function()
    -- Now init level (either 1 or saved progress)
    init_level()
  end)
  -- Time taken since last reset/win
  storage.getUserValue("currTime", 0)
  -- Total no. of lives lost since last reset/win  
  storage.getUserValue("currDeaths", 0)
  -- Difficulty level (Easy/Hard)
  storage.getUserValue("difficulty", 0)
  -- Get Global saved data
  refreshGlobalHighScores()
end

function resetPlayerProgress()
  -- reset progress
  log("resetting player progress..")
  levelReady = false
  storage.currLevel = START_LEVEL
  storage.currTime = 0
  storage.currDeaths = 0
  storage.difficulty = 0 -- 0=Easy, 1=Hard
  storage.saveUserValues(function()
    if gameState ~= GAME_STATE.COMPLETED then
      init_data()
    end
  end)

  -- ####################################
  -- ...also wipe GLOBAL data!
  -- ####################################
  --storage.setGlobalValue("globalHighScores",{})
  -- ####################################
end

function refreshGlobalHighScores()
  -- Get Global saved data
  storage.getGlobalValue("globalHighScores", {}, function(retValue) 
    globalHighScores = retValue
    -- debug contents
    for key,score in pairs(globalHighScores) do
      log(" > ["..key.."] time="..score.time.." (💀="..score.deaths..")")
    end
  end)
end

function init_input()
  -- keyboard & gamepad input
  register_btn(0, 0, {input_id("keyboard", "left"),
                      input_id("keyboard", "a"),
                      input_id("controller_button", "dpleft")})
  register_btn(1, 0, {input_id("keyboard", "right"),
                      input_id("keyboard", "d"),
                      input_id("controller_button", "dpright")})
  register_btn(2, 0, {input_id("keyboard", "up"),
                      input_id("keyboard", "w"),
                      input_id("controller_button", "dpup")})
  register_btn(3, 0, {input_id("keyboard", "down"),
                      input_id("keyboard", "s"),
                      input_id("controller_button", "dpdown")})


end

function init_level()
  init_player()
  load_level(storage.currLevel)
  init_detail_anims()
  -- reset game time
  game_time = 0
  state_time = 0
  -- set state
  gameState = GAME_STATE.LVL_PLAY   
  light_start = love.timer.getTime()
  levelReady = true
  Sounds.startLevel:play()
  Sounds.music:play()
  log("init done!!")
end

function load_level(lvl_num)
  local lvl_xoffset = ((storage.currLevel-1)%10*8)
  local lvl_yoffset = flr((storage.currLevel-1)/10)*8
  log("lvl_xoffset="..lvl_xoffset)
  log("lvl_yoffset="..lvl_yoffset)
  -- todo: read pixel data for level
  spritesheet("levels")
  for x=0,7 do
    for y=0,7 do
      local col=sget(x+lvl_xoffset, y+lvl_yoffset, "levels")
      -- handle level data
      if col==COL_START then
        -- found start
        log("found player start at: "..x..","..y)
        -- place player at start
        player.x,player.y = x*TILE_SIZE, y*TILE_SIZE
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
    idle_anim = {60},
    walk_anim_1 = {61,62,62,61},
    walk_anim_2 = {63,64,64,63},
    fall_anim = {70,71,72,73,74,75,76,77,77,77,77,77},
    win_anim = {80,81,82,83,84,85,86},
    frame_pos = 1,
    frame_delay = 4,
    frame_count = 0,
    moving = false,
    moveFrameCount = nil,
    tileHistory={},
    tileHistoryKeys={},
    moveCount = 0, -- number of moves player has made
  }
  player.curr_anim = player.idle_anim
end

function init_player_move(angle, dx, dy)  
  Sounds.step:play()
  player.angle = angle 
  
  -- assume normal move (within screen bounds?)
  player.newX = player.x+(TILE_SIZE*dx)
  player.newY = player.y+(TILE_SIZE*dy)

  -- check for "wrap" screen movement
  if player.newX < 0 then player.wrapX=1 player.newX = (GAME_WIDTH-TILE_SIZE) end
  if player.newY < 0 then player.wrapY=1 player.newY = (GAME_HEIGHT-TILE_SIZE) end
  if player.newX > (GAME_WIDTH-TILE_SIZE) then player.wrapX=-1 player.newX = 0 end
  if player.newY > (GAME_HEIGHT-TILE_SIZE) then player.wrapY=-1 player.newY = 0 end

  -- check to see if player on a "wrap" tile
  -- (if not, then undo the move)
  if (player.wrapX or player.wrapY)
   and player.tileCol ~= COL_WRAP then
    player.newX = player.x
    player.newY = player.y
    player.wrapX = nil
    player.wrapY = nil
    -- abort now
    return
  end

   -- calc tween "smoothness"
   local frames = 16 --16
   local pxDist = TILE_SIZE
   player.dx = (pxDist/frames) * dx
   player.dy = (pxDist/frames) * dy
   player.moveFrameCount = frames
   player.lastX = player.x
   player.lastY = player.y
   player.moving = true
  
  -- switch to a "walking" anim
  init_anim(player, 
       player.moveCount%2==0 
        and player.walk_anim_1 or player.walk_anim_2)
  player.moveCount = player.moveCount + 1

  player.moved = true
end

function init_anim(anim_obj, anim, func_on_finish)
  anim_obj.curr_anim = anim
  anim_obj.frame_count = 0
  --if anim_obj.frame_pos > #anim then
    anim_obj.frame_pos = 1
  --end
  -- set the function to run on finish (if applicable)
  anim_obj.func_on_finish = func_on_finish
end

function init_sounds()
  Sounds.music = Sound:new('music.mp3', 1)
  Sounds.music:setVolume(0.7)
  Sounds.music:setLooping(true)

  Sounds.step = Sound:new('step.mp3', 3)
  Sounds.step:setVolume(0.25)

  Sounds.fall = Sound:new('fall.mp3', 3)
  Sounds.fall:setVolume(0.5)

  Sounds.flickerHigh = Sound:new('flicker_high.mp3', 1)
  Sounds.flickerHigh:setVolume(0.7)

  Sounds.flickerLow = Sound:new('flicker_low.mp3', 1)
  Sounds.flickerLow:setVolume(0.7)

  Sounds.splash = Sound:new('splash.mp3', 1)
  Sounds.splash:setVolume(0.7)

  Sounds.win = Sound:new('win.mp3', 1)
  Sounds.win:setVolume(0.3)

  Sounds.startLevel = Sound:new('start_level.mp3', 3)
  Sounds.startLevel:setVolume(0.7)
  
  Sounds.collect = Sound:new('collect.mp3', 3)
  Sounds.collect:setVolume(0.7)
end

function load_assets()
  -- load gfx
  load_png("spritesheet", "assets/spritesheet.png", nil, true)
  spritesheet_grid(14,14)
  load_png("levels", "assets/levels.png", nil, true)
  -- capture pixel info
  scan_surface("levels")
  -- todo: load sfx + music
  init_sounds()
end

function init_detail_anims()
  -- random monsters
  monsters = {}
  for i=1,irnd(2)+2 do
    local val = irnd(GAME_WIDTH)
    local cx,cy = val%TILE_SIZE, flr(val/TILE_SIZE)
    if sget(cx, cy, "levels")==0 
    and sget(cx, cy-1, "levels")==0 
    then
      local frames = create_monster_frames()
      table.insert(monsters, {
        x = cx*TILE_SIZE,
        y = cy*TILE_SIZE,
        curr_anim = frames,
        frame_pos = irnd(#frames),
        frame_delay = 5,
        frame_count = 0,
      })      
    end
  end
end

function create_monster_frames()
  resetRNG()
  local frames = { 91, 92 }
  for i=1,rnd(20)+20 do
    table.insert(frames, 93)
  end
  table.insert(frames, 92)
  table.insert(frames, 91)
  for i=1,rnd(20)+30 do
    table.insert(frames, 94)
  end
  return frames
end
