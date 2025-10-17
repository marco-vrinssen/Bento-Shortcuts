-- Auto-sell junk and repair gear when merchant window opens

local function merchantShow()
    C_Timer.After(0.1, function()
        if MerchantSellAllJunkButton and MerchantSellAllJunkButton:IsShown() and MerchantSellAllJunkButton:IsEnabled() then
            MerchantSellAllJunkButton:Click()
        end

        if MerchantRepairAllButton and MerchantRepairAllButton:IsShown() and MerchantRepairAllButton:IsEnabled() then
            MerchantRepairAllButton:Click()
        end

        -- Confirm popups
        C_Timer.After(0.1, function()
            local maxPopups = _G.STATICPOPUP_NUMDIALOGS or 4
            for i = 1, maxPopups do
                local popup = _G["StaticPopup" .. i]
                if popup and popup:IsShown() and popup.button1 and popup.button1:IsEnabled() then
                    popup.button1:Click()
                end
            end
        end)
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("MERCHANT_SHOW")
eventFrame:SetScript("OnEvent", merchantShow)
