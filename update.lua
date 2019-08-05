
function update_game(dt)
  update_player(dt)
  game_time = game_time + 1
end

function update_player(dt)

  -- handle player control/movement
  if not player.moving then
    if btnp(0) then         -- left
      init_player_move(0.5, -1, 0)      
    end
    if btnp(1) then         -- right
      init_player_move(0, 1, 0)
    end
    if btnp(2) then         -- up
      init_player_move(0.75, 0, -1)
    end
    if btnp(3) then         -- down
      init_player_move(0.25, 0, 1)
    end
  end

  -- update player move "tweening" frames
  if player.moveFrameCount > 0 then
    player.x = player.x + player.dx
    player.y = player.y + player.dy
    player.moveFrameCount = player.moveFrameCount - 1
  else
    player.moving = false
    init_anim(player, player.idle_anim)
  end

  -- keep player within the screen
  -- TODO: update this later, when allow "wrapping"
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