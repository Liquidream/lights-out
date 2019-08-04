require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)
require("common")
require("init")
require("update")
require("draw")



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