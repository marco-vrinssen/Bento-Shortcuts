-- Instant auto loot with stability delay and empty window close

local lastLootTimestamp = 0
local lootStabilityDelay = 0.025

local function setInstantLootRate()
    SetCVar("autoLootRate", 0)
end

local function enableAutoLootDefault()
    SetCVar("autoLootDefault", 1)
end

local function lootAllItemSlots()
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        if (GetTime() - lastLootTimestamp) >= lootStabilityDelay then
            for slot = GetNumLootItems(), 1, -1 do
                LootSlot(slot)
            end
            lastLootTimestamp = GetTime()
        end
    end
end

local function processLootWindow()
    local lootItemCount = GetNumLootItems()
    
    if lootItemCount == 0 then
        CloseLoot()
        return
    end
    
    lootAllItemSlots()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("LOOT_READY")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        enableAutoLootDefault()
        setInstantLootRate()
    elseif event == "LOOT_READY" then
        processLootWindow()
    end
end)