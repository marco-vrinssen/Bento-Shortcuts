-- Display available commands when logging in

local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event)
    C_Timer.After(3, function()
        print("Bento Shortcuts:")
        print("/wl <message> - whisper raid leader")
        print("spacebar - post auction (auction house)")
        print("right-click main menu - reload ui")
    end)
end)
