--[[
-- Lights Out
-- by Paul Nicholas
-- (for #LOWREZJAM 2019)

## TODO's
  • 
  •

## IDEAS
  • Have advanced levels with DOORS (wrap level, like "Pac Man")
  • Have a global high score for 
      - Each level, and 
      - Fastest complete of ALL levels
  • 

## ACKNOWLEDGEMENTS
 • @somepx for Particle font
   (https://www.patreon.com/posts/three-tiny-fonts-24214421)

]]

require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)
require("common")
require("init")
require("update")
require("draw")


curr_level = 11

function love.load()
  init_sugarcoat()  
  load_assets()
  init_input()
  init_game()
end

function love.update(dt)
  update_game(dt)
end

function love.draw()
  draw_game()
end