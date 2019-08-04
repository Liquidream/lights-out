
function update_game(dt)
  update_player(dt)
end

function update_player(dt)
  if btn(0) then player.x = player.x - 1 end
  if btn(1) then player.x = player.x + 1 end
  if btn(2) then player.y = player.y - 1 end
  if btn(3) then player.y = player.y + 1 end
end