
local ui = castle.ui


-- All the UI-related code is just in this function. Everything below it is normal game code!

function castle.uiupdate()

  ui.markdown('![](assets/title-text.png)')   

  ui.markdown([[
Navigate the path to safety, with the...  
💡 **LIGHTS OUT**!
]])

  ui.section("Controls", function()

    ui.markdown([[
**⬆⬇⬅➡** = *Move Player*
]])

  end)

  ui.section("Global High Score", function()
    local scoreTable = [[
| Name          | Time(#💀) |
| ------------- |:------------:|]]

    if globalHighScores then
      for key,score in pairs(globalHighScores) do
        scoreTable = scoreTable.."\n"
         ..score.name.." | "..formatTime(score.time).." ("..score.deaths..") |"
      end
    end
    -- write final table    
    ui.markdown(scoreTable)
--     ui.markdown([[
-- | Name          | Time (💀's) |
-- | ------------- |:------------:|
-- | Liquidream     | 10m 30s (12💀) |
-- | Another    | 10m 30s (32💀)      |
-- | N.E.One    | 30m 1s (92💀)      |
-- ]])
  end)

  ui.section("Credits", function()

    ui.markdown([[
**Code & Art**:  
**[Paul Nicholas](https://twitter.com/Liquidream)**

**Music & SFX**:  
**[Jason Riggs](https://twitter.com/_castlegames)**

**Creative Director**:  
**[Hilda Nicholas](https://twitter.com/shade_green)**

**"Particle" Font**:  
**[Eeve Somepx](https://twitter.com/somepx)**

#### Special Thanks to the following supporters on [Patreon](https://www.patreon.com/liquidream):
**•ThatTomHall•**  
**•Roy Fielding•**  
**•bbsamurai•**  
**•Christopher Castillo•**  
**•Not Invader Zim•**  
**•Andy•**  
Qristy Overton  
Tobias V. Langhoff  
Damien Cirade  
Antonio Bianchetti  
Joseph White  
**•Graham Wenz•**  
**•Daljit Chandi•**  
**•Scramp Shortfriend•**  
**•Vitorio Miliano•**  
**•Andy Kaye (Anakey)•**  
Gruber  
Michael Leonardi  
Paul Zimmermann  
Hyperlink Your Heart  
Llewelyn Griffiths  
**•Andrew Dicker•**  
**•Wilman•**  
Joe  
Johnathan Roatch  
Morten Schouenborg  
matteusbeus  
Mike Poole  
]])

  end)

  ui.section("Settings", function()
    ui.markdown([[
#### Reset Player Progress
_**WARNING**: Clicking this will lose your saved progress!_
]])
    if ui.button("Reset", { kind='danger'}) then
      resetPlayerProgress()
    end

  end)
    

  -- ui.section("Patreon Thanks", function()

  --   ui.markdown([[
  --     - 
  --     - 
  --     - 
  --   ]])

  -- end)

end
