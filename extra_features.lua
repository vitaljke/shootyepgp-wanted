-- PARSE ID
SLASH_PARSEID1 = "/parseid"

SlashCmdList["PARSEID"] = function(msg)

  local _, _, itemID = string.find(msg, "Hitem:(%d+)")
  
  if itemID then
    DEFAULT_CHAT_FRAME:AddMessage("Item ID is: " .. itemID)
  else
    DEFAULT_CHAT_FRAME:AddMessage(
      "No item ID found. Make sure to shift-click an actual item link.\nReceived: " .. (msg or "nil")
    )
  end
end


-- SHOW RANK IN ROLL
-- Hook the chat event for roll results
local origSystemMessage = ChatFrame_MessageEventHandler
function ChatFrame_MessageEventHandler(self, event, message, ...)
    -- Check if it's a roll message
    if event == "CHAT_MSG_SYSTEM" then
        -- Pattern to match roll messages: "PlayerName rolls X (1-Y)"
        local playerName, roll, range = string.match(message, "^([^%s]+) rolls (%d+) %(1%-(%d+)%)$")
        
        if playerName and roll then
            -- Get player's guild information
            local guildRank = GetGuildRankForPlayer(playerName)
            
            if guildRank then
                -- Modify message to include guild rank
                local newMessage = playerName .. " <" .. guildRank .. "> rolls " .. roll .. " (1-" .. range .. ")"
                -- Call original handler with modified message
                return origSystemMessage(self, event, newMessage, ...)
            end
        end
    end
    
    -- Call original handler for all other messages
    return origSystemMessage(self, event, message, ...)
end

-- Helper function to get guild rank for a player
function GetGuildRankForPlayer(playerName)
    -- Make sure we're in a guild
    if not IsInGuild() then
        return nil
    end
    
    -- Check if player is in our guild
    local numGuildMembers = GetNumGuildMembers()
    for i = 1, numGuildMembers do
        local name, rank = GetGuildRosterInfo(i)
        -- Strip realm name if present
        name = string.match(name, "([^-]+)") or name
        
        if name == playerName then
            return rank
        end
    end
    
    return nil
end