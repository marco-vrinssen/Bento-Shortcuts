-- Whisper the raid leader using the slash command /wl followed by a message

local function findRaidLeader()
    local numGroupMembers = GetNumGroupMembers()
    
    if numGroupMembers == 0 then
        return nil
    end
    
    for i = 1, numGroupMembers do
        local unit = "raid" .. i
        
        if UnitExists(unit) and UnitIsGroupLeader(unit) then
            local name, realm = UnitName(unit)
            
            if realm and realm ~= "" then
                return name .. "-" .. realm
            else
                return name
            end
        end
    end
    
    return nil
end

local function whisperRaidLeader(message)
    if not IsInRaid() then
        print("|cffff0000[Whisper Leader]|r You are not in a raid group.")
        return
    end
    
    if not message or message == "" then
        print("|cffff0000[Whisper Leader]|r Please provide a message. Usage: /wl Your message here")
        return
    end
    
    local leaderName = findRaidLeader()
    
    if not leaderName then
        print("|cffff0000[Whisper Leader]|r Could not find the raid leader.")
        return
    end
    
    SendChatMessage(message, "WHISPER", nil, leaderName)
    print("|cff00ff00[Whisper Leader]|r Message sent to " .. leaderName)
end

SLASH_WHISPERLEADER1 = "/wl"
SlashCmdList["WHISPERLEADER"] = function(message)
    whisperRaidLeader(message)
end
