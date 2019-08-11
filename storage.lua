
-- Simple wrapper around Castle's storage API
-- https://castle.games/documentation/storage-api-reference

local storage = {}

-- --------------------------------------------------------
-- USER STORAGE
-- --------------------------------------------------------

-- Get "User" storage value for given key
-- (or use the default value specified)
storage.getUserValue = function(key,default)
  local retValue = nil
  -- set the default while we wait for response
  storage[key] = default

  network.async(function()
    local retValue = castle.storage.get(key)
    log("getUserValue["..key.."]:"..(retValue or "<nil>"))
    -- store the final setting (or default if none found)
    storage[key] = retValue or default
  end)
end

-- Set "User" storage value (if null passed - key will be deleted)
storage.setUserValue = function(key,value)
  log("setUserValue["..key.."]:"..(value or "<nil>"))
    network.async(function()
      castle.storage.set(key, value)
    end)
end

-- Save all "User" values to Castle 
-- (helpful if been using the storage table directly to update values)
storage.saveUserValues = function()
  log("saveUserValues()...")
  for key,value in pairs(storage) do
    -- skip functions
    if type(value) ~= "function" then
      network.async(function()
        castle.storage.set(key, value)
      end)
      --storage.setUserValue(key, setting)
    end
  end
end

-- --------------------------------------------------------
-- GLOBAL STORAGE
-- --------------------------------------------------------

-- Get "Global" storage value for given key
-- (or use the default value specified)
storage.getGlobalValue = function(key,default)
  local retValue = nil
  -- set the default while we wait for response
  storage[key] = default

  network.async(function()
    local retValue = castle.storage.getGlobal(key)
    log("getGlobalValue["..key.."]:"..(retValue or "<nil>"))
    -- store the final setting (or default if none found)
    storage[key] = retValue or default
  end)
end

-- Set "Global" storage value (if null passed - key will be deleted)
storage.setGlobalValue = function(key,value)
  log("setGlobalValue["..key.."]:"..(value or "<nil>"))
  network.async(function()
    castle.storage.setGlobal(key, value)
  end)
end


return storage