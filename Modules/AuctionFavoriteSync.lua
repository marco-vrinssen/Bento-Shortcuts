-- Syncs auction house favorites across all characters on the account

local favoritesDB
local characterFavorites = {}
local isSyncing = false

local function createItemKeyHash(itemKey)
	local keys, values = {}, {}
	for k in pairs(itemKey) do table.insert(keys, k) end
	table.sort(keys)
	for _, k in ipairs(keys) do table.insert(values, itemKey[k]) end
	return table.concat(values, "-")
end

local function getItemNameFromKey(itemKey)
	local itemName = C_Item.GetItemNameByID(itemKey.itemID)
	return itemName or ("Item " .. itemKey.itemID)
end

local function saveFavoriteChange(itemKey, isFavorited)
	if isSyncing then return end
	
	local itemHash = createItemKeyHash(itemKey)
	favoritesDB.favorites[itemHash] = isFavorited and itemKey or nil
	characterFavorites[itemHash] = isFavorited
end

hooksecurefunc(C_AuctionHouse, "SetFavoriteItem", saveFavoriteChange)

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")

eventFrame:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" and ... == "Bento-Shortcuts" then
		eventFrame:UnregisterEvent("ADDON_LOADED")

		BentoAuctionFavoritesDB = BentoAuctionFavoritesDB or {}
		favoritesDB = BentoAuctionFavoritesDB
		favoritesDB.favorites = favoritesDB.favorites or {}
	end

	if event == "AUCTION_HOUSE_SHOW" then
		isSyncing = true

		local addedItemNames = {}
		local removedItemNames = {}

		for itemHash, itemKey in pairs(favoritesDB.favorites) do
			if not characterFavorites[itemHash] then
				C_AuctionHouse.SetFavoriteItem(itemKey, true)
				table.insert(addedItemNames, getItemNameFromKey(itemKey))
			end
			characterFavorites[itemHash] = true
		end

		for itemHash in pairs(characterFavorites) do
			if not favoritesDB.favorites[itemHash] then
				local itemKey = favoritesDB.favorites[itemHash]
				if itemKey then
					table.insert(removedItemNames, getItemNameFromKey(itemKey))
				end
				characterFavorites[itemHash] = nil
			end
		end

		isSyncing = false

		if #addedItemNames > 0 then
			for _, itemName in ipairs(addedItemNames) do
				print(itemName .. " added to favorites")
			end
		end

		if #removedItemNames > 0 then
			for _, itemName in ipairs(removedItemNames) do
				print(itemName .. " removed from favorites")
			end
		end

		C_AuctionHouse.SearchForFavorites({})
	end

end)
