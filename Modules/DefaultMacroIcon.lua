-- Set default macro icon to WoW icon when creating new macros

local frame = CreateFrame("Frame")

local wowIconIndex = 1

local function setDefaultIcon()
    if MacroFrame and MacroFrame:IsShown() then
        local macroPopup = MacroPopupFrame
        
        if macroPopup and macroPopup:IsShown() then
            C_Timer.After(0.1, function()
                if MacroPopupFrame.selectedIconTexture then
                    MacroPopupFrame.selectedIconTexture = wowIconIndex
                    MacroPopupFrame_Update(MacroPopupFrame)
                    
                    local iconButton = _G["MacroPopupButton" .. wowIconIndex]
                    if iconButton then
                        iconButton:Click()
                    end
                end
            end)
        end
    end
end

frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, addon)
    if addon == "Blizzard_MacroUI" then
        hooksecurefunc("MacroFrame_Show", function()
            if MacroPopupFrame then
                MacroPopupFrame:HookScript("OnShow", setDefaultIcon)
            end
        end)
    end
end)
