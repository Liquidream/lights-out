

function draw_game()
  cls()
  -- set default pprint style
  printp( 0x3330,
          0x3130,
          0x3230,
          0x0 )
  printp_color(0, 0, 0)

  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen

  elseif gameState == GAME_STATE.TITLE then
    -- todo: title screen
    
  elseif gameState == GAME_STATE.COMPLETED then
    -- draw congrats!
    pprintc("TODO:", 10, 47)    
    pprintc("ADD MORE LVLS", 20, 47)    
    pprintc("PLS COME BACK!", 40, 47)
    -- pprintc("CONGRATULATIONS", 10, 47)
    -- pprintc("YOU COMPLETED", 30, 47)
    -- pprintc("THE GAME!", 40, 47)
  else
    -- normal play (level intro/outro/game-over)
    draw_level()
  end

  
  --circfill(x, y, 4 + 2 * cos(t()), 3)
end

function draw_level()
  -- todo: read pixel data for level
  spritesheet("spritesheet")

  -- draw detail animations
  for _,m in pairs(monsters) do
    spr(m.curr_anim[m.frame_pos], m.x, m.y)
  end

  local segment = game_time%25
  local flicker = game_time < 100 
   and (segment>=18 and segment<=25)
  -- place level tiles, based on pixels  
  local lvl_offset = (curr_level-1)*8
  for x=0,7 do
    for y=0,7 do
      local col=sget(x+lvl_offset, y, "levels")
      -- handle level data
      if game_time < 100 
       or player.tileHistory[x..","..y]        
       then
        if col==COL_START then
          -- draw start
          spr(0, x*8, y*8)
          -- draw edge?
          --if sget(x, y+1, "levels")==0 then
            spr(8, x*8, (y+1)*8)
          --end
        elseif col==COL_PATH then
          -- draw path?
          spr(flicker and 4 or 1, x*8, y*8)
          -- draw edge?
          --if sget(x, y+1, "levels")==0 then
            spr(flicker and 11 or 8, x*8, (y+1)*8)
          --end
        elseif col==COL_FINISH then
          -- draw end
          spr(flicker and 5 or 2, x*8, y*8)
          -- draw edge?
          --if sget(x, y+1, "levels")==0 then
            spr(flicker and 11 or 8, x*8, (y+1)*8)
          --end
        end
      end
    end
  end

  
  -- draw player (current anim cycle)
  aspr(player.curr_anim[player.frame_pos], player.x+4, player.y+4, player.angle)
  
  -- Draw UI
  if game_time < 100 then
    pprintc("LEVEL "..curr_level, 1, 47)
  end
end

-- pprint, centered
function pprintc(text, y, col)
    local letterWidth = 4
    pprint(text, GAME_WIDTH/2-(#text*letterWidth)/2, y, col)
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