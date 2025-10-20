-- Display available commands when logging in

local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event)
    C_Timer.After(3, function()
        print("Bento Shortcuts commands:")
        print("/wl <message> - whisper raid leader")
    end)
end)
