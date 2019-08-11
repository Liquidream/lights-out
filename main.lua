--[[
-- Lights Out
-- by Paul Nicholas
-- (for #LOWREZJAM 2019)

## TODO's
- • Instructions
- • Global high-score
- • Credits (Jason, @somepx, Patreon supporters)

## IDEAS
  • Have a global high score table for 
    - Times+deaths to complete of ALL levels
    - Use Castle's UI to show it!

## DONE
  • Have a light switch tile (shows level again for a few secs, once!)
  • Have advanced levels with DOORS (wrap level, like "Pac Man")

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
require("ui_input")



function love.load()
  init_data()
  init_sugarcoat()  
  load_assets()
  init_input()

  --init_level() -- Don't do this until receive data from Castle
end

function love.update(dt)
  update_game(dt)
end

function love.draw()
  draw_game()
end