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
    draw_level(61)
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

function draw_level(num)
  local levelNum = num or storage.currLevel
  -- todo: read pixel data for level
  spritesheet("spritesheet")

  -- still loading?
  if not levelReady 
   and levelNum <= MAX_LEVELS then
    pprintc("  LOADING... ", 45, 46,5)
    -- abort now!
    return
  end

  -- draw detail animations  
  for _,m in pairs(monsters) do
    spr(m.curr_anim[m.frame_pos], m.x, m.y)
  end
  
  local lightTime = love.timer.getTime()-light_start
  local segment = lightTime%1
  local flicker = lightTime < MAX_LIGHT_DURATION
   and (segment>=.8 and segment<=1)  

   
   
   -- place level tiles, based on pixels  
   palt(0,false)
   local lvl_xoffset = ((levelNum-1)%10*8)
   local lvl_yoffset = flr((levelNum-1)/10)*8
   for x=0,7 do
    for y=0,7 do
      local col=sget(x+lvl_xoffset, y+lvl_yoffset, "levels")
      local key = x..","..y
      local deadTile = player.tileHistory[key] and player.tileHistory[key]==0
      
      if not deadTile then 
        -- handle level data
        if lightTime < MAX_LIGHT_DURATION
        or player.tileHistory[x..","..y]
        or col==COL_KEY_PINK
        or col==COL_PLATFORM1
        or col==COL_PLATFORM2
        or ((col==COL_FINISH or col==COL_FINISH_BONUS) and levelNum==1)
        then
          -- is tile still "lighting up"?
          local dim = false
          local fadingAway = false
          if player.tileHistory[x..","..y] then
            if player.tileHistory[x..","..y] > 0 
             and player.tileHistory[x..","..y] < 1 then
              -- fading up
              player.tileHistory[x..","..y] 
                = min(player.tileHistory[x..","..y]+0.1, 1)
              -- only dim if lights aren't "on"
              if lightTime > MAX_LIGHT_DURATION then
                dim = true
              end
            elseif  player.tileHistory[x..","..y] < 0 then
              -- fading down
              dim = true
              fadingAway = true
              player.tileHistory[x..","..y] 
                = min(player.tileHistory[x..","..y]+0.05, 0)
            end
          end
          if col==COL_START then
            -- draw start
            spr(((flicker or dim) and player.moved) and 3 or 0, x*TILE_SIZE, y*TILE_SIZE) 
            -- draw edge?
            spr(((flicker or dim) and player.moved) and 13 or 10, x*TILE_SIZE, (y+1)*TILE_SIZE)

          elseif col==COL_FINISH 
            or (col==COL_FINISH_BONUS and storage.reverseUnlocked) 
            then
            -- draw end
            spr(((flicker or dim) and levelNum~=1) and 5 or 2, x*TILE_SIZE, y*TILE_SIZE)
            -- draw edge?
            spr(((flicker or dim) and levelNum~=1) and 15 or 12, x*TILE_SIZE, (y+1)*TILE_SIZE)
            
          elseif col==COL_PATH 
           or col==COL_WRAP 
           or (col==COL_PATH_BONUS and storage.reverseUnlocked) 
           then
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

          elseif col==COL_PLATFORM1 
          or col==COL_PLATFORM2 then
            -- draw "phase" platform?
            local phaseDuration = 6
            local fadeDuration = .15
            local phaseoffset = (col==COL_PLATFORM2) and (phaseDuration/2) or 0
            
            local phaseTime = (t()+phaseoffset)%phaseDuration
            local fadeInStart = fadeDuration
            local fadeInEnd = fadeInStart + fadeDuration
            local fadeOutStart = (phaseDuration/2) - (2*fadeDuration)
            local fadeOutEnd = (phaseDuration/2) - fadeDuration
            local fading = phaseTime > fadeInStart and phaseTime < fadeInEnd
                        or phaseTime > fadeOutStart and phaseTime < fadeOutEnd
                        or fadingAway
            if phaseTime > fadeInStart
            and phaseTime < fadeOutEnd then
              spr(fading and 27 or 26, x*TILE_SIZE, y*TILE_SIZE)
              -- draw edge?
              spr(fading and 37 or 36, x*TILE_SIZE, (y+1)*TILE_SIZE)  
            end

          end

        end  -- if dead

      end  -- for
    end  -- for
  end
  
  palt()

  -- draw player (current anim cycle)
  if levelNum <= MAX_LEVELS then
    aspr(player.curr_anim[player.frame_pos], player.x+7, player.y+7, player.angle)
  end
  -- draw "wrap" movement?
  -- (draw a second player sprite so we see the wrap)
  if player.wrapX or player.wrapY then
    local offX = player.wrapX and (player.wrapX>0 and GAME_WIDTH-1 or -7) or player.newX
    local offY = player.wrapY and (player.wrapY>0 and GAME_HEIGHT-1 or -7) or player.newY
    aspr(player.curr_anim[player.frame_pos], 
      offX-(player.lastX-player.x)+4, 
      offY-(player.lastY-player.y)+4, 
      player.angle)
  
  end

  -- Draw UI  
  if levelNum > 1 
  and levelNum <= MAX_LEVELS 
  and game_time < 100 then
    pprintc("LEVEL "..levelNum, 1, 46,5)

  elseif levelNum == 1
   and game_time > 300 
   and not player.moved then
    -- draw "hint"
     if not alternate() then
      spr(90, player.x + 10 + sin(t()*2)*1.1, player.y)
     end
  end

  -- draw difficulty selection
  if levelNum==1 then
    if surface_exists("title") then
      spr_sheet("title", 0,0) 
    end
    
    pprint("EASY", 70,40, 7,5)
    pprint("HARD", 70,68, 39,31)
    if storage.reverseUnlocked then
      pprint("REVERSE", 56,11, 26,30)
    end
    
    -- small font stuff
    use_font("small-font")
    if storage.reverseUnlocked ~= true then
      pprint("CHOOSE YOUR PATH!", 20,20, 46,5)
    end
    --if flr(t())%6 < 3 then
      pprint(" Code + Art   Music + SFX", -2,90, 21,29)
    --else
      pprint("PAUL NICHOLAS  JASON RIGGS", -2,97, 18,29)
    --end
    use_font("main-font")
  end
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