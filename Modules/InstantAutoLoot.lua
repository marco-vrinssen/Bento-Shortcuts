-- Enables instant auto looting with stability delay

local lastLootTime = 0
local lootDelay = 0.05

-- Set loot rate to instant

local function setInstantLootRate()
    SetCVar("autoLootRate", 0)
end

-- Enable auto loot by default

local function enableAutoLoot()
    SetCVar("autoLootDefault", 1)
end

-- Loot all slots with delay to prevent errors

local function lootWithDelay()
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        if (GetTime() - lastLootTime) >= lootDelay then
            for slot = GetNumLootItems(), 1, -1 do
                LootSlot(slot)
            end
            lastLootTime = GetTime()
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("LOOT_READY")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        enableAutoLoot()
        setInstantLootRate()
    elseif event == "LOOT_READY" then
        lootWithDelay()
    end
end)