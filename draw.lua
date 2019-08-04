

function draw_game()
  cls()

  draw_level()

  
  --circfill(x, y, 4 + 2 * cos(t()), 3)
end

function draw_level()
  -- todo: read pixel data for level
  spritesheet("spritesheet")
  -- todo: place level tiles, based on pixels
  for x=0,15 do
    for y=0,15 do
      local col=sget(x, y, "levels")
      -- handle level data
      if col==COL_START then
        -- found start
        spr(0, x*8, y*8)
      elseif col==COL_PATH then
        -- found path
        spr(1, x*8, y*8)
      elseif col==COL_FINISH then
        -- found end
        spr(2, x*8, y*8)
      end
    end
  end
  
  -- draw player (current anim cycle)
  aspr(player.curr_anim[player.frame_pos], player.x+4, player.y+4, player.angle)
  --spr(19, player.x, player.y)
  
end