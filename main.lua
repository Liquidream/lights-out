require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)
require("common")
require("init")
require("update")
require("draw")

-- local fields
local x = 64
local y = 64

function love.load()
  init_sugarcoat()
  
  init_input()
end

function love.update(dt)
  game_update(dt)
end

function love.draw()
  game_draw()
end