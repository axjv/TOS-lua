_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI']["CABINETCOMMAS"] = _G['ADDONS']['MIEI']["CABINETCOMMAS"] or {};

function CABINETCOMMAS_ON_INIT(addon, frame)
	local g = _G['ADDONS']['MIEI']["CABINETCOMMAS"];
	g.addon = addon;
	g.addon:RegisterMsg("CABINET_ITEM_LIST", "CABINETCOMMAS_ON_CABINET_ITEM_LIST");
	g.addon:RegisterMsg("MARKET_ITEM_LIST","CABINETCOMMAS_ON_SELL_LIST");
end

function CABINETCOMMAS_ON_CABINET_ITEM_LIST()
	local frame = ui.GetFrame("market_cabinet");
	local itemGbox = GET_CHILD(frame, "itemGbox");
	local itemlist = GET_CHILD(itemGbox, "itemlist", "ui::CDetailListBox");
	local cnt = itemlist:GetChildCount();

	for i = 0 , cnt - 1 do
		local cabinetItem = session.market.GetCabinetItemByIndex(i);
		local ctrlSet = itemlist:GetChild("DETAIL_ITEM_" .. i .. "_0");
		local totalPrice = ctrlSet:GetChild("totalPrice");
		totalPrice:SetTextByKey("value", GetCommaedText(cabinetItem.count));
	end

end


function CABINETCOMMAS_ON_SELL_LIST()
	local frame = ui.GetFrame("market_sell");
	local itemlist = GET_CHILD(frame, "itemlist", "ui::CDetailListBox");
	local cnt = itemlist:GetChildCount();

	for i = 0 , cnt - 1 do
		local marketItem = session.market.GetItemByIndex(i);
		local ctrlSet = itemlist:GetChild("DETAIL_ITEM_" .. i .. "_0");
		local priceStr = string.format("{img icon_item_silver %d %d}%s", 20, 20, GetCommaedText(marketItem.sellPrice * marketItem.count))
		local totalPrice = ctrlSet:GetChild("totalPrice");
		totalPrice:SetTextByKey("value", priceStr);

		local cashValue = GetCashValue(marketItem.premuimState, "marketSellCom") * 0.01;
		local stralue = GetCashValue(marketItem.premuimState, "marketSellCom");
		priceStr = string.format("{img icon_item_silver %d %d}%s [%d%%]", 20, 20, GetCommaedText(marketItem.sellPrice * marketItem.count * cashValue), stralue)
		local silverFee = ctrlSet:GetChild("silverFee");
		silverFee:SetTextByKey("value", priceStr);
	end
end
