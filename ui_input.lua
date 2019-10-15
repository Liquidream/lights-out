
local ui = castle.ui


-- All the UI-related code is just in this function. Everything below it is normal game code!

function castle.uiupdate()

  ui.markdown('![](assets/title-text.png)')   

  ui.markdown([[
Navigate the path to safety,   
with the... **LIGHTS OUT**!💡
]])

  ui.section("Controls", { defaultOpen = true }, function()

    ui.markdown('![](assets/controls.gif)') 

  end)

  -- DEBUG: Allow level selection in debug
  if DEBUG_MODE then
    ui.section("🐞 === DEBUG MENU === 🤫",  { defaultOpen = true }, function()
    
      ui.numberInput("Warp to Level", storage.currLevel, { min=1, max=MAX_LEVELS, onChange=function(value)
        -- Level jump
        storage.currLevel = value
        init_level()
      end })

      if ui.button("Unlock 'Reverse' Mode", { kind='danger'}) then
        resetPlayerProgress()
        -- unlock reverse mode
        storage.reverseUnlocked = true
        storage.saveUserValues()
      end
    end)
  end

  ui.section("Global High Score", function()
    local scoreTable = [[
| Name          | Time(#💀) |
| ------------- |:------------:|]]

    if globalHighScores then
      -- this uses an custom sorting function ordering by score descending
      for key,score in spairs(globalHighScores, function(t,a,b) 
        return (t[a].time+(t[a].deaths*10)) < (t[b].time+(t[b].deaths*10))         
       end) 
      do
        scoreTable = scoreTable.."\n"
         ..score.name.." | "..formatTime(score.time).." ("..score.deaths..") |"
      end
    end
    -- write final table    
    ui.markdown(scoreTable)
  end)

  ui.section("Credits", function()

    ui.markdown([[
**Code & Art**:  
**[Paul Nicholas](https://twitter.com/Liquidream)**

**Music & SFX**:  
**[Jason Riggs](https://twitter.com/_castlegames)**

**Creative Director**:  
**[Hilda Nicholas](https://www.instagram.com/hildanicholas)**

**'Hungry' + 'Particle' Fonts**:  
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
    

end
