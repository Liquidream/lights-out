
function update_game(dt)
  update_player(dt)
  game_time = game_time + 1
end

function update_player(dt)

  -- handle player control/movement
  if btnp(0) then player.x = player.x-8 player.angle=0.5 end
  if btnp(1) then player.x = player.x+8 player.angle=0 end
  if btnp(2) then player.y = player.y-8 player.angle=0.75 end
  if btnp(3) then player.y = player.y+8 player.angle=0.25 end

  -- keep player within the screen
  player.x = mid(0,player.x,56)
  player.y = mid(0,player.y,56)
end