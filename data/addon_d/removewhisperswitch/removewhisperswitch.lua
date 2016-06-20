_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI']["REMOVEWHISPERSWITCH"] = _G['ADDONS']['MIEI']["REMOVEWHISPERSWITCH"] or {};


function REMOVEWHISPERSWITCH_ON_INIT(addon, frame)
	local g = _G["ADDONS"]["MIEI"]["REMOVEWHISPERSWITCH"];

	g.addon = addon;
	g.frame = frame;
	g.addon:RegisterMsg("GAME_START_3SEC", "REMOVEWHISPERSWITCH_3SEC");
end

function REMOVEWHISPERSWITCH_3SEC()
	local g = _G["ADDONS"]["MIEI"]["REMOVEWHISPERSWITCH"];
	local acutil = require('acutil');

	_G["CHAT_GROUP_CREATE"] = g.chatGroupCreate;
end

function ADDONS.MIEI.REMOVEWHISPERSWITCH.chatGroupCreate(roomID, autoFocusToRoom)
	autoFocusToRoom = 0;	-- GO AWAY NASTY WHISPER SWITCHY >:(
	
	local frame = ui.GetFrame('chatframe');
	if frame == nil then
		return;
	end

	local groupbox = CHAT_CREATE_GROUP_LIST(frame, roomID);

	ui.OnGroupChatCreated(roomID);

	if autoFocusToRoom == 1 then
		ui.SetChatGroupBox(CT_WHISPER,roomID);
	end

	local popupframe = ui.GetFrame("chatpopup_"..roomID);
	if (popupframe ~= nil and popupframe:IsVisible() == 1) or groupbox:IsVisible() == 1 then -- ÀÌ¹Ì ¸Þ½ÃÁö°¡ Ç¥½Ã ÁßÀÌ¸é ¹Ù·Î ¾÷µ¥ÀÌÆ®
		chat.UpdateReadFlag(roomID);
		chat.CheckNewMessage(roomID);
	end
	
end
