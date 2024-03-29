local Sounds = require 'sounds'

function updateSplash(dt)
  if splashStartTime then
      duration = t()-splashStartTime 
      if duration > 3.53 then
        -- Now show "Title" level
         init_level()
      end
  end
end

function update_game(dt)
  _t=_t+1
  -- temp tweet code
  -- tweetCounter = tweetCounter + 1
  -- if tweetCounter>25 then
  --   tweetCounter=0
  --   curr_level = curr_level + 1
  --   if curr_level <= MAX_LEVELS then
  --     init_level()
  --   else
  --     -- completed!
  --     gameState = GAME_STATE.COMPLETED
  --   end
  -- end

  -- Update all particle systems
  for key, psys in pairs(pSystems) do
    psys:update(dt)

    -- purge old emitters
    if psys._lifecount > 100 then
      --log("purging old pSystem...")
      table.remove(pSystems, key)
    end
  end

  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen
    updateSplash(dt)

  -- play
  elseif gameState == GAME_STATE.LVL_PLAY then
    update_player(dt)
    game_time = game_time + 1
  
  elseif gameState == GAME_STATE.LVL_END then
    -- update player animation
    update_anim(player)
    state_time = state_time + 1
    if state_time > 100 then
      -- is this the title screen?
      if storage.currLevel == 1 then
        storage.difficulty = player.y<60 and 0 or 1
        log("storage.difficulty = "..tostring(storage.difficulty))        
        -- set game mode (normal/reverse)      
        storage.gameMode = player.y<30 and 1 or 0
        log("storage.gameMode = "..storage.gameMode)
      end
      saveProgress()
      levelUp()      
    end

  elseif gameState == GAME_STATE.COMPLETED then
    if _t%5==0 then
      makeParticles(rnd(GAME_WIDTH), rnd(GAME_HEIGHT), rnd(2)<1 and COL_FINISH or COL_PINK)
    end
  end
end

function levelUp()  
  -- init next level
  storage.currLevel = storage.currLevel + 1  
  if storage.currLevel <= MAX_LEVELS then        
    -- start next level
    init_level()
  else
    -- completed!
    gameState = GAME_STATE.COMPLETED
    -- Submit player's score (if better than prev)
    submitHighScore()
    -- unlock extra game mode
    storage.reverseUnlocked = true
    -- reset back to level 1 again (for next play)
    resetPlayerProgress()    
  end
  -- Refresh Global saved data
  -- (do it periodically, so scores up-to-date)
  refreshGlobalHighScores()
end


-- save player's progress
-- (time taken, lives lost)
function saveProgress()
  -- Update total player time
  storage.currTime = storage.currTime + 
   love.timer.getTime() - (lastSaveTime or sessionStartTime)   
  -- save progress
  storage.saveUserValues()
  lastSaveTime = love.timer.getTime()  
end

-- submit player's time/deaths
function submitHighScore()
  -- look for previous time
  local prevScore = globalHighScores[my_id]
  log("prevScore = "..tostring(prevScore))
  if not prevScore 
   or storage.currTime+storage.currDeaths < 
    (prevScore.time+(prevScore.deaths*10)) 
  then
    log("currScore.time+deaths = "..storage.currTime+storage.currDeaths)
    if prevScore then
      log("prevScore.time+deaths = "..(prevScore.time+(prevScore.deaths*10)))
    end
    -- Submit THIS score
    local newScore = {
      time = storage.currTime,
      deaths = storage.currDeaths,
      name = my_name,
      difficulty = storage.difficulty,
      mode = storage.gameMode,
    }
    -- add/replace player's score
    globalHighScores[my_id] = newScore

    -- save global changes
    storage.setGlobalValue("globalHighScores-v2",globalHighScores)
  end
end


function update_player(dt)

  -- handle player control/movement
  if (love.timer.getTime()-light_start) > MAX_LIGHT_DURATION
   and not player.moving
   and not player.fell then
    -- left
    if btn(0) then
      init_player_move(0.5, -1, 0)      
    end
    if btn(1) then         -- right
      init_player_move(0, 1, 0)
    end
    if btn(2) then         -- up
      init_player_move(0.75, 0, -1)
    end
    if btn(3) then         -- down
      init_player_move(0.25, 0, 1)
    end
  end

  -- update player move "tweening" frames
  if player.moveFrameCount then
    player.x = player.x + player.dx
    player.y = player.y + player.dy
    player.moveFrameCount = player.moveFrameCount - 1
    -- reached new pos?
    if player.moveFrameCount <= 0 then
      player.moveFrameCount = nil
      player.moving = false
      player.x = player.newX
      player.y = player.newY
      player.tx = player.x/TILE_SIZE
      player.ty = player.y/TILE_SIZE
      init_anim(player, player.idle_anim)
      checkTile()

      player.newX = nil
      player.newY = nil
      player.wrapX = nil
      player.wrapY = nil
    end    
  end

  -- also check player's tile status regularly
  -- (as now possible for tile to change!)
  if _t%5==0 
   and not player.moveFrameCount
   and not player.fell then 
      checkTile() 
  end

  -- Crumbling trail (HARD mode only)
  if storage.difficulty>0 and
   _t>5*60 and _t%120==0 and (#player.tileHistoryKeys>0 and player.moved) then
    -- remove trail one-by-one
    local key = player.tileHistoryKeys[1]
    player.tileHistory[key] = -0.5
    table.remove( player.tileHistoryKeys, 1)
  end

  -- update player animation
  update_anim(player)

  -- update detail animations
  for _,m in pairs(monsters) do
    update_anim(m)
  end
end

-- function checkValidDir(dx, dy)

-- end

-- check the tile the player is now on
function checkTile()
  local lvl_xoffset = ((storage.currLevel-1)%10*8)
  local lvl_yoffset = flr((storage.currLevel-1)/10)*8
  local cx = player.tx>0 and player.tx or 0
  local cy = player.ty>0 and player.ty or 0
  player.tileCol = sget(cx+lvl_xoffset,cy+lvl_yoffset,"levels")
  local key = cx..","..cy
  local deadTile = player.tileHistory[key] and player.tileHistory[key]==0

  -- "phase" platform?
  local phaseDuration = 6
  local fadeDuration = .15
  local phaseoffset = (player.tileCol==COL_PLATFORM2) and (phaseDuration/2) or 0
  
  local phaseTime = (t()+phaseoffset)%phaseDuration
  local fadeInStart = fadeDuration
  local fadeInEnd = fadeInStart + fadeDuration
  local fadeOutStart = (phaseDuration/2) - (2*fadeDuration)
  local fadeOutEnd = (phaseDuration/2) - fadeDuration
  local fading = phaseTime > fadeInStart and phaseTime < fadeInEnd
               or phaseTime > fadeOutStart and phaseTime < fadeOutEnd  


  if player.tileCol == COL_START
    and not deadTile then
    -- player on start
    -- do nothing
  elseif player.tileCol == COL_FINISH
    or player.tileCol==COL_FINISH_BONUS then
    -- player reached end
   -- log("- level complete -")
    Sounds.win:play()
    Sounds.music:stop()
    player.win_time = game_time
    gameState = GAME_STATE.LVL_END
    state_time = 0
    player.angle = 0.25
    init_anim(player, player.win_anim)
    makeParticles(player.x, player.y-4, COL_FINISH)

  elseif (player.tileCol == COL_PATH 
   or player.tileCol==COL_WRAP
   or player.tileCol==COL_PATH_BONUS)
   and not deadTile then
    -- player found path (valid movement)
    --log("valid move")

  elseif player.tileCol == COL_LIGHT
   and not deadTile then
    -- light up (if not already used)
    if not player.tileHistory[key] then
     -- log("temp light on")
      light_start = love.timer.getTime()
      -- Added sound to make it significant
      Sounds.startLevel:play()
    else
     -- log("temp light already used!")      
    end
  
  elseif player.tileCol == COL_KEY_PINK
   and not deadTile then
    -- collect blue key (if not already)
    if not player.gotKey then
      player.gotKey = true
      -- play collect sfx & do particles, etc.      
      Sounds.collect:play()
      -- do particles, etc.
      makeParticles(player.x, player.y-4, COL_PINK)
    end

  elseif player.tileCol == COL_PINK
   and player.gotKey
   and not deadTile then
    -- player found key path AND has key
    -- first time?
    if not player.usedKey then
    --if not player.tileHistory[key] then
      makeParticles(player.x, player.y-4, COL_PINK)
      player.usedKey = true
    end

  elseif (player.tileCol == COL_PLATFORM1 
   or player.tileCol == COL_PLATFORM2)
  and (phaseTime > fadeInStart
    and phaseTime < fadeOutEnd)
  and not deadTile
  then
      -- "phase" platform?
      --log("valid move")
      -- log("pos_offset: "..phaseoffset)
      -- log("phaseTime > fadeInStart: "..tostring(phaseTime > fadeInStart))
      -- log("phaseTime < fadeOutEnd: "..tostring(phaseTime < fadeOutEnd))

  else
    -- player fell
    log("player fell!")
    player.fell = true
    player.moveFrameCount = null
    Sounds.fall:play()
    storage.currDeaths = storage.currDeaths + 1
    saveProgress()
    init_anim(player, player.fall_anim, function(self)
      -- restart level
      init_level()
    end)
  end

  -- -------------------------------
  -- tile history states
  -- -------------------------------
  -- nil  = never visited
  -- 0.5  = fading up
  -- 1    = lit
  -- -0.5 = fading down (crumbling path)
  --  0   = gone (player will fall)

  -- only fade tile if first visit  
  if not player.tileHistory[key] 
  -- and not player.fell 
  then
    player.tileHistory[key] = 0.5
    table.insert( player.tileHistoryKeys, key )
  end
end

function makeParticles(x, y, col)
  -- create a new particle system
  local pEmitter = Sprinklez:createSystem(x, y)
  -- set clip bounds
  pEmitter.game_width = GAME_WIDTH
  pEmitter.game_height = GAME_HEIGHT
  -- tweak effect for pickup "poof" 
  pEmitter.angle = 23
  pEmitter.spread = 16 --math.pi --180
  pEmitter.lifetime = 1 -- Only want 1 burst
  pEmitter.rate = 15
  pEmitter.acc_min = 3
  pEmitter.acc_max = 7
  pEmitter.size_min = 0
  pEmitter.size_max = 1
  pEmitter.max_rnd_start = 15
  pEmitter.gravity = 0.15
  pEmitter.cols = particle_cols[col] --{47,35,26,30} 

  table.insert( pSystems, pEmitter )
end


-- step through (and loop) animations
function update_anim(anim_obj)
  -- check for anim
  if anim_obj.curr_anim then
    -- update anim delay
    anim_obj.frame_count = anim_obj.frame_count + 1
    -- time for next frame yet?
    if anim_obj.frame_count > anim_obj.frame_delay then
      -- move to next frame
      anim_obj.frame_pos = anim_obj.frame_pos + 1
      anim_obj.frame_count = 0
      -- have we reached the end of anim?
      if anim_obj.frame_pos > #anim_obj.curr_anim then
        -- should we run a function?
        if anim_obj.func_on_finish then
          anim_obj.func_on_finish(anim_obj)
        else
          -- loop back to the start
          anim_obj.frame_pos = 1
        end
      end
    end
  end
end
