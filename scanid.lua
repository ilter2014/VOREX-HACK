local MarketplaceService = game:GetService("MarketplaceService")

local placeId = game.PlaceId
local success, info = pcall(function()
    return MarketplaceService:GetProductInfo(placeId)
end)

local gameName = success and info.Name or "Bilinmeyen Oyun"

-- F9 Konsoluna Yazdır
print("[DataDev]: Oynanan Oyun -> " .. gameName .. " (Place ID: " .. placeId .. ")")

-- Place ID'yi Panoya Kopyala
if setclipboard then
    setclipboard(tostring(placeId))
    print("[DataDev]: Place ID panoya kopyalandı! (Ctrl + V ile yapıştırabilirsin)")
elseif toclipboard then
    toclipboard(tostring(placeId))
    print("[DataDev]: Place ID panoya kopyalandı!")
else
    warn("[DataDev]: Executor'ın kopyalama fonksiyonunu desteklemiyor.")
end
