
function update_game(dt)
  update_player(dt)
  game_time = game_time + 1
end

function update_player(dt)

  -- handle player control/movement
  if game_time > 100
   and not player.moving then
    -- left
    if btnp(0) then
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
    -- reached new pos?
    if player.moveFrameCount <= 0 then
      player.moving = false
      player.x = player.newX
      player.y = player.newY
      player.tx = player.x/8
      player.ty = player.y/8
      init_anim(player, player.idle_anim)
      checkTile()
    end    
  end

  -- keep player within the screen
  -- TODO: update this later, when allow "wrapping"
  player.x = mid(0,player.x,56)
  player.y = mid(0,player.y,56)

  -- update player animation
  update_anim(player)

  -- update detail animations
  for _,m in pairs(monsters) do
    update_anim(m)
  end
end

-- function checkValidDir(dx, dy)

-- end

-- check the tile the player is now on
function checkTile()
  local cx = player.tx>0 and player.tx or 0
  local cy = player.ty>0 and player.ty or 0
  player.tileCol = sget(cx,cy,"levels")
  log("...checkTile ("..cx..","..cy..") = "..player.tileCol)
  log("player pos = "..player.x..","..player.y)

  if player.tileCol==COL_START then
    -- player on start
    -- do nothing
  elseif player.tileCol==COL_PATH then
    -- player found path (valid movement)
    log("valid move")
  elseif player.tileCol==COL_FINISH then
    -- player reached end
    log("- level complete -")
    init_anim(player, player.win_anim)
    log("TODO: load next level...")
  else
    -- player fell
    log("player fell!")
    init_anim(player, player.fall_anim, function(self)
      -- restart level
      init_game()
    end)
  end

  player.tileHistory[cx..","..cy]=true
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
        -- should we run a function?
        if anim_obj.func_on_finish then
          anim_obj.func_on_finish(anim_obj)
        else
          -- loop back to the start
          anim_obj.frame_pos = 1
        end
      end
    end
  end
end