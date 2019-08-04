
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

  -- update player animation
  update_anim(player)
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
        -- loop back to the start
        anim_obj.frame_pos = 1
      end
    end
  end
end