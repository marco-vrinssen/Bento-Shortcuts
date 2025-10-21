-- Makes looting instant with no delay when auto loot is enabled

local lastLootTime = 0
local timeBetweenLoots = 0.025

local bagsFull = false
local currentlyLooting = false

local function makeAutoLootInstant()
    SetCVar("autoLootRate", 0)
end

local function enableAutoLoot()
    SetCVar("autoLootDefault", 1)
end

local function tryLootingSlot(slotNumber)
    local slotType = GetLootSlotType(slotNumber)
    
    if slotType == Enum.LootSlotType.None then
        return true
    end
    
    local itemLink = GetLootSlotLink(slotNumber)
    local itemQuantity, _, itemQuality, itemLocked = select(3, GetLootSlotInfo(slotNumber))
    
    if itemLocked then
        bagsFull = true
        return false
    end
    
    LootSlot(slotNumber)
    return true
end

local function lootAllSlots()
    local autoLootEnabled = GetCVarBool("autoLootDefault")
    local shiftKeyPressed = IsModifiedClick("AUTOLOOTTOGGLE")
    
    if autoLootEnabled ~= shiftKeyPressed then
        local currentTime = GetTime()
        local enoughTimePassed = (currentTime - lastLootTime) >= timeBetweenLoots
        
        if enoughTimePassed then
            bagsFull = false
            
            for slotNumber = GetNumLootItems(), 1, -1 do
                tryLootingSlot(slotNumber)
            end
            
            lastLootTime = currentTime
        end
    end
end

local function closeLootWindowIfEmpty()
    local noItemsLeft = GetNumLootItems() == 0
    local notLooting = not currentlyLooting
    
    if noItemsLeft and notLooting then
        CloseLoot()
    end
end

local function handleLootReady()
    local itemCount = GetNumLootItems()
    
    if itemCount == 0 then
        CloseLoot()
        return
    end
    
    currentlyLooting = true
    lootAllSlots()
    currentlyLooting = false
end

local function handleLootClosed()
    currentlyLooting = false
    bagsFull = false
    
    C_Timer.After(1, closeLootWindowIfEmpty)
end

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("LOOT_READY")
eventFrame:RegisterEvent("LOOT_CLOSED")
eventFrame:RegisterEvent("UI_ERROR_MESSAGE")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        enableAutoLoot()
        makeAutoLootInstant()
        
    elseif event == "LOOT_READY" then
        handleLootReady()
        
    elseif event == "LOOT_CLOSED" then
        handleLootClosed()
        
    elseif event == "UI_ERROR_MESSAGE" then
        local messageType, errorMessage = ...
        
        local inventoryFull = errorMessage == ERR_INV_FULL
        local tooManyItems = errorMessage == ERR_ITEM_MAX_COUNT
        
        if inventoryFull or tooManyItems then
            bagsFull = true
        end
    end
end)