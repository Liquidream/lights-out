

function draw_game()
  cls()

  draw_level()

  
  --circfill(x, y, 4 + 2 * cos(t()), 3)
end

function draw_level()
  -- todo: read pixel data for level
  -- todo: place level tiles, based on pixels
  
  -- draw player (current anim cycle)
  spr(1, player.x, player.y)
  
end