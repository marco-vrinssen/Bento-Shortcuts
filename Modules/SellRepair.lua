-- Auto sell junk and repair gear when merchant window opens

local function processMerchantWindow()
    C_Timer.After(0, function()
        if MerchantSellAllJunkButton and MerchantSellAllJunkButton:IsShown() then
            MerchantSellAllJunkButton:Click()
        end
        
        if MerchantRepairAllButton and MerchantRepairAllButton:IsShown() then
            MerchantRepairAllButton:Click()
        end
    end)
    
    C_Timer.After(0.1, function()
        if StaticPopup1Button1 and StaticPopup1Button1:IsShown() then
            StaticPopup1Button1:Click()
        end
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("MERCHANT_SHOW")
eventFrame:SetScript("OnEvent", processMerchantWindow)
