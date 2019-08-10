
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

  ui.section("Credits", function()

    ui.markdown([[
**Code & Art**:  
**[Paul Nicholas](https://twitter.com/Liquidream)**

**Music & SFX**:  
**[Jason Riggs](https://twitter.com/_castlegames)**

**Font**:  
**[Eeve Somepx](https://twitter.com/somepx)**
]])

  end)

  -- ui.section("Patreon Thanks", function()

  --   ui.markdown([[
  --     - 
  --     - 
  --     - 
  --   ]])

  -- end)

end
