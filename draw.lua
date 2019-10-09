local Sounds = require 'sounds'

function draw_game()
  cls()
  -- set default pprint style
  printp(
    0x2220, 
    0x2120, 
    0x2220, 
    0x0)
  -- printp(
  --   0x1000, 
  --   0x2000, 
  --   0x0, 
  --   0x0)
  printp_color(47, 0, 0, 0)

  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen

  elseif gameState == GAME_STATE.TITLE then
    -- todo: title screen
    
  elseif gameState == GAME_STATE.COMPLETED then
    -- draw congrats!
    pprintc("CONGRATULATIONS", 8, 9,29)
    pprintc("YOU COMPLETED", 24, 47,29)
    pprintc("THE GAME!", 34, 47,29)    
    local myScore = globalHighScores[my_id]
    if myScore then
      pprint("TIME = "..formatTime(myScore.time), 8,51, 45,29)
      pprint("DEATHS = "..myScore.deaths, 0,61, 38,29)
    end
    pprintc("DON'T FORGET TO", 80, 17,29)
    pprintc("SHARE YOUR SCORE", 90, 17,29)
  else
  --   -- normal play (level intro/outro/game-over)    
    draw_level()
  end

  
  --circfill(x, y, 4 + 2 * cos(t()), 3)
end

function draw_level()
  -- todo: read pixel data for level
  spritesheet("spritesheet")

  -- still loading?
  if not levelReady then
    pprintc("  LOADING... ", 20, 47,29)
    -- abort now!
    return
  end

  -- draw detail animations  
  for _,m in pairs(monsters) do
    spr(m.curr_anim[m.frame_pos], m.x, m.y)
  end
  
  local lightTime = love.timer.getTime()-light_start
  local segment = lightTime%1
  --log(segment)
  local flicker = lightTime < MAX_LIGHT_DURATION
   and (segment>=.8 and segment<=1)  

   
  -- place level tiles, based on pixels  
  palt(0,false)
  local lvl_xoffset = ((storage.currLevel-1)%10*8)
  local lvl_yoffset = flr((storage.currLevel-1)/10)*8
  for x=0,7 do
    for y=0,7 do
      local col=sget(x+lvl_xoffset, y+lvl_yoffset, "levels")
      -- handle level data
      if lightTime < MAX_LIGHT_DURATION
       or player.tileHistory[x..","..y]
       or col==COL_KEY_PINK
       or col==COL_PLAT_UD
       or col==COL_PLAT_LR
       then
        -- is tile still "lighting up"?
        local dim = false
        
        if player.tileHistory[x..","..y]
         and player.tileHistory[x..","..y]<1 
        then
          player.tileHistory[x..","..y] 
            = min(player.tileHistory[x..","..y]+0.1, 1)
            -- only dim if lights aren't "on"
            if lightTime > MAX_LIGHT_DURATION then
            dim = true
          end
        end
        if col==COL_START then
          -- draw start
          spr(0, x*TILE_SIZE, y*TILE_SIZE) 
          -- draw edge?
          spr(10, x*TILE_SIZE, (y+1)*TILE_SIZE)

        elseif col==COL_FINISH then
          -- draw end
          spr((flicker or dim) and 5 or 2, x*TILE_SIZE, y*TILE_SIZE)
          -- draw edge?
          spr((flicker or dim) and 15 or 12, x*TILE_SIZE, (y+1)*TILE_SIZE)
        
        elseif col==COL_PATH or col==COL_WRAP then
          -- draw path?
          spr((flicker or dim) and 4 or 1, x*TILE_SIZE, y*TILE_SIZE)
          -- draw edge?
          spr((flicker or dim) and 14 or 11, x*TILE_SIZE, (y+1)*TILE_SIZE)

        elseif col==COL_LIGHT then
          -- draw end
          spr((flicker or dim) and 23 or 20, x*TILE_SIZE, y*TILE_SIZE)
          -- draw edge?
          spr((flicker or dim) and 33 or 30, x*TILE_SIZE, (y+1)*TILE_SIZE)        

        elseif col==COL_KEY_PINK then
          -- draw path?
          spr(1, x*TILE_SIZE, y*TILE_SIZE)
          -- draw edge?
          spr(11, x*TILE_SIZE, (y+1)*TILE_SIZE)     
          -- draw key?
          if not player.gotKey then
            palt()
            local bounce = sin(t())*1.5
            line(x*TILE_SIZE+4-bounce, y*TILE_SIZE+8, x*TILE_SIZE+TILE_SIZE-3+bounce, y*TILE_SIZE+8, 41)
            spr(42, x*TILE_SIZE, y*TILE_SIZE + bounce)
            palt(0,false)          
          end

        elseif col==COL_PINK then
          if (not player.fell or player.gotKey) then
            -- draw pink path
            spr((flicker or dim) and 25 or 22, x*TILE_SIZE, y*TILE_SIZE)
            -- draw edge?
            spr((flicker or dim) and 35 or 32, x*TILE_SIZE, (y+1)*TILE_SIZE)        
          else
            -- draw pink "hint" outline
            palt()
            spr((flicker or dim) and 55 or 52, x*TILE_SIZE, y*TILE_SIZE)
            palt(0,false)
          end

        elseif col==COL_PLAT_UD 
         or col==COL_PLAT_LR then
          -- draw "phase" platform?
          local phaseDuration = 3
          local fadeDuration = .15
          local pos_offset = flr( t() % (phaseDuration*2) / phaseDuration )
          local ypos_offset = (col==COL_PLAT_UD) and pos_offset or 0
          local xpos_offset = (col==COL_PLAT_LR) and pos_offset or 0
          
          local phaseTime = t()%phaseDuration
          local fadeInStart = 2*fadeDuration
          local fadeInEnd = fadeInStart + fadeDuration
          local fadeOutStart = phaseDuration - (2*fadeDuration)
          local fadeOutEnd = phaseDuration - fadeDuration
          local fading = phaseTime > fadeInStart and phaseTime < fadeInEnd
                       or phaseTime > fadeOutStart and phaseTime < fadeOutEnd
          if phaseTime > fadeInStart
           and phaseTime < fadeOutEnd then
            spr(fading and 27 or 26, (x+xpos_offset)*TILE_SIZE, (y+ypos_offset)*TILE_SIZE)
            -- draw edge?
            spr(fading and 37 or 36, (x+xpos_offset)*TILE_SIZE, (y+1+ypos_offset)*TILE_SIZE)  
          end

        end

      end
    end
  end
  
  palt()

  -- draw player (current anim cycle)
  aspr(player.curr_anim[player.frame_pos], player.x+7, player.y+7, player.angle)

  -- draw "wrap" movement?
  -- (draw a second player sprite so we see the wrap)
  if player.wrapX or player.wrapY then
    local offX = player.wrapX and (player.wrapX>0 and GAME_WIDTH-1 or -7) or player.newX
    local offY = player.wrapY and (player.wrapY>0 and GAME_HEIGHT-1 or -7) or player.newY
    log("draw wrap!! "..offX..","..offY)
    aspr(player.curr_anim[player.frame_pos], 
      offX-(player.lastX-player.x)+4, 
      offY-(player.lastY-player.y)+4, 
      player.angle)
  
  end

  -- Draw UI  
  if game_time < 100 then
    pprintc("LEVEL "..storage.currLevel, 1, 47,29)

  elseif storage.currLevel == 1
   and game_time > 300 
   and not player.moved then
    -- draw "hint"
     if not alternate() then
      spr(90, player.x + 20 + sin(t()*2)*1.1, player.y)
     end
  end


  -- pprintc("TIME "..flr(storage.currTime),40, 47)  
  -- pprintc("DEATHS "..flr(storage.currDeaths),50, 47)  
end

-- pprint, centered
function pprintc(text, y, col1, col2, col3)
    local letterWidth = 6.5
    pprint(text, GAME_WIDTH/2-((#text+1.5)*letterWidth)/2, y, col1,col2,col3)
end

   
function fade(i)
  for c=0,15 do
      if flr(i+1)>=16 or flr(i+1)<=0 then
          pal(c,0)
      else
          pal(c,fadeBlackTable[c+1][flr(i+1)])
      end
  end
end