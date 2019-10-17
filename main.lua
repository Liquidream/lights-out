--[[
-- Lights Out
-- by Paul Nicholas
-- (originally for #LOWREZJAM 2019)

## TODO's
  • New mechanics
  - On/Off / Moving tile (alternates being there or "thin air") 
  • 
  
## IDEAS
  • New mechanics
  - Visited path crumbles behind you (fast paced!)
  • Splash screen
  • Title screen 
  - Just use Level 1, rolling demo, with Title logo
  
  
## DONE
  • New mechanics
    - Keys to unlock other tile areas
  • New tile cols/shapes (for diff zones)
- • Instructions (not really needed - as sidebar intro covers it)
- • Global high-score
    • Have a global high score table for 
      - Times+deaths to complete of ALL levels
      - Use Castle's UI to show it!
- • Credits (Jason, @somepx, Patreon supporters)
  • Have a light switch tile (shows level again for a few secs, once!)
  • Have advanced levels with DOORS (wrap level, like "Pac Man")

## ACKNOWLEDGEMENTS
 • @somepx for Particle font
   (https://www.patreon.com/posts/three-tiny-fonts-24214421)

 • https://freesound.org/people/Leszek_Szary/sounds/146723/

]]


if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    'common.lua',
    'draw.lua',
    'init.lua',
    'main.lua',
    'storage.lua',
    'ui_input.lua',
    'update.lua',
    'sugarcoat/sugarcoat.lua',
    'sprinklez.lua',
    'assets/levels.png',
    'assets/Hungry.ttf',
    'assets/Particle.ttf',
    'assets/splash.png',
    'assets/spritesheet.png',
    'assets/title-text.png',
    'assets/title-text-small.png',
    'assets/controls.gif',
    'assets/snd/music.mp3',
    'assets/snd/win.mp3',
    'assets/snd/fall.mp3',
    'assets/snd/step.mp3',
    'assets/snd/collect.mp3',
    'assets/snd/flicker_high.mp3',
    'assets/snd/flicker_low.mp3',
    'assets/snd/start_level.mp3',
  })
end

require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)
require("common")
require("init")
require("update")
require("draw")
require("ui_input")
require("sprinklez")


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