-- Enables instant auto looting with rapid ticker-based looting

local lootTicker = nil
local isLooting = false
local lastNumLoot = nil

-- Set loot rate to instant

local function setInstantLootRate()
    SetCVar("autoLootRate", 0)
end

-- Enable auto loot by default

local function enableAutoLoot()
    SetCVar("autoLootDefault", 1)
end

-- Cancel active loot ticker

local function cancelLootTicker()
    if lootTicker then
        lootTicker:Cancel()
        lootTicker = nil
    end
end

-- Start rapid looting using ticker

local function startRapidLooting(numItems)
    cancelLootTicker()
    local currentSlot = numItems
    
    lootTicker = C_Timer.NewTicker(0.033, function()
        if currentSlot >= 1 then
            LootSlot(currentSlot)
            currentSlot = currentSlot - 1
        else
            cancelLootTicker()
        end
    end, numItems + 1)
end

-- Handle loot ready event

local function onLootReady(autoLoot)
    isLooting = true
    
    local numItems = GetNumLootItems()
    if numItems == 0 or lastNumLoot == numItems then
        return
    end
    
    local shouldAutoLoot = autoLoot or (GetCVarBool("autoLootDefault") and not IsModifiedClick("AUTOLOOTTOGGLE"))
    
    if shouldAutoLoot then
        startRapidLooting(numItems)
    end
    
    lastNumLoot = numItems
end

-- Handle loot closed event

local function onLootClosed()
    isLooting = false
    lastNumLoot = nil
    cancelLootTicker()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("LOOT_CLOSED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        enableAutoLoot()
        setInstantLootRate()
    elseif event == "LOOT_READY" then
        onLootReady(...)
    elseif event == "LOOT_CLOSED" then
        onLootClosed()
    end
end)