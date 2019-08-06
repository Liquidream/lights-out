

function draw_game()
  cls()

  draw_level()

  
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
  --spr(19, player.x, player.y)
  
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