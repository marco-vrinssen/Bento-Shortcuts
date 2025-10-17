-- Syncs auction house favorites across all characters on the account

local accountDB
local characterDB

local function createItemKeyHash(itemKey)
	local keys, values = {}, {}
	for k in pairs(itemKey) do table.insert(keys, k) end
	table.sort(keys)
	for _, k in ipairs(keys) do table.insert(values, itemKey[k]) end
	return table.concat(values, "-")
end

local function syncFavorite(itemKey)
	local itemHash = createItemKeyHash(itemKey)

	if not accountDB.favorites[itemHash] == not characterDB.favorites[itemHash] then
		return false
	end

	C_AuctionHouse.SetFavoriteItem(itemKey, accountDB.favorites[itemHash] ~= nil)
	return true
end

local function saveFavorite(itemKey, isFavorited)
	local itemHash = createItemKeyHash(itemKey)

	accountDB.favorites[itemHash] = isFavorited and itemKey or nil
	characterDB.favorites[itemHash] = isFavorited and itemKey or nil
end

hooksecurefunc(C_AuctionHouse, "SetFavoriteItem", saveFavorite)

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

eventFrame:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" and ... == "Bento-Shortcuts" then
		eventFrame:UnregisterEvent("ADDON_LOADED")

		BentoAuctionFavoritesDB = BentoAuctionFavoritesDB or {}
		accountDB = BentoAuctionFavoritesDB
		accountDB.favorites = accountDB.favorites or {}

		BentoAuctionFavoritesCharDB = BentoAuctionFavoritesCharDB or {}
		characterDB = BentoAuctionFavoritesCharDB
		characterDB.favorites = characterDB.favorites or {}

		if not characterDB.synced then
			eventFrame:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
			eventFrame:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_ADDED")
			eventFrame:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
			eventFrame:RegisterEvent("COMMODITY_SEARCH_RESULTS_ADDED")
			eventFrame:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
			eventFrame:RegisterEvent("ITEM_SEARCH_RESULTS_ADDED")
		end
	end

	if event == "AUCTION_HOUSE_SHOW" then
		local needRefresh = false

		if characterDB.synced then
			for _, favorites in ipairs { accountDB.favorites, characterDB.favorites } do
				for _, itemKey in pairs(favorites) do
					needRefresh = syncFavorite(itemKey) or needRefresh
				end
			end
		else
			for _, itemKey in pairs(accountDB.favorites) do
				C_AuctionHouse.SetFavoriteItem(itemKey, true)
				needRefresh = true
			end
		end

		if needRefresh then
			C_AuctionHouse.SearchForFavorites({})
		end
	end

	if event == "AUCTION_HOUSE_CLOSED" then
		characterDB.synced = true
		eventFrame:UnregisterAllEvents()
	end

	local function processItemKey(itemKey)
		saveFavorite(itemKey, C_AuctionHouse.IsFavoriteItem(itemKey))
	end

	if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
		for _, result in ipairs(C_AuctionHouse.GetBrowseResults()) do
			processItemKey(result.itemKey)
		end
	end

	if event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
		for _, result in ipairs(...) do
			processItemKey(result.itemKey)
		end
	end

	if event == "COMMODITY_SEARCH_RESULTS_UPDATED" or event == "COMMODITY_SEARCH_RESULTS_ADDED" then
		processItemKey(C_AuctionHouse.MakeItemKey(...))
	end

	if event == "ITEM_SEARCH_RESULTS_UPDATED" or event == "ITEM_SEARCH_RESULTS_ADDED" then
		processItemKey(...)
	end
end)
