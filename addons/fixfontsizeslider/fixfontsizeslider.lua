local addonName = "BOSSTRACKER";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};
local g = _G['ADDONS']['MIEI'][addonName];

function g.chatSetFontsize(num)
	local chatFrame = ui.GetFrame("chatframe");
	if chatFrame == nil then
		return;
	end
	local targetSize = GET_CHAT_FONT_SIZE();
	local count = chatFrame:GetChildCount();
	for  i = 0, count-1 do 
		local groupBox  = chatFrame:GetChildByIndex(i);
		local childName = groupBox:GetName();
		if string.sub(childName, 1, 5) == "chatg" then
			if groupBox:GetClassName() == "groupbox" then
				groupBox = tolua.cast(groupBox, "ui::CGroupBox");
				local beforeHeight = 1;
				local lastChild = nil;
				local ctrlSetCount = groupBox:GetChildCount();
				for j = 0 , ctrlSetCount - 1 do
					local chatCtrl = groupBox:GetChildByIndex(j);
					if chatCtrl:GetClassName() == "controlset" then
						local label = chatCtrl:GetChild('bg');
						local txt = GET_CHILD(label, "text");
						txt:SetTextByKey("size", targetSize);
						local timeBox = GET_CHILD(chatCtrl, "timebox");
						RESIZE_CHAT_CTRL(chatCtrl, label, txt, timeBox)
						beforeHeight = chatCtrl:GetY() + chatCtrl:GetHeight();
						lastChild = chatCtrl;
					end
				end

				GBOX_AUTO_ALIGN(groupBox, 0, 0, 0, true, false);
				if lastChild ~= nil then
					local afterHeight = lastChild:GetY() + lastChild:GetHeight();					
					local heightRatio = afterHeight / beforeHeight;
					
					groupBox:UpdateData();
					groupBox:SetScrollPos(groupBox:GetCurLine() * (heightRatio * 1.1));
				end
			end
		end
	end

	chatFrame:Invalidate();
end

-- INIT
_G["CHAT_SET_FONTSIZE"] = g.chatSetFontsize;
-- /INIT
