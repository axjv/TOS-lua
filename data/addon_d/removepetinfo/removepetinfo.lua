GETMYFAMILYNAME();
_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI']["REMOVEPETINFO"] = _G['ADDONS']['MIEI']["REMOVEPETINFO"] or {};

local g = _G["ADDONS"]["MIEI"]["REMOVEPETINFO"];
local acutil = require('acutil');

if g.loaded ~= true then
	g.settings = {
		showMyPetName = 1;
		showMyPetHP = 0;
		showOtherPetNames = 0;
	};
end

g.settingsFileLoc = path.GetDataPath() .. '../addons/removepetinfo/settings.json';


function REMOVEPETINFO_ON_INIT(addon, frame)
	local g = _G["ADDONS"]["MIEI"]["REMOVEPETINFO"];

	g.addon = addon;
	g.frame = frame;
	g.addon:RegisterMsg("GAME_START_3SEC", "REMOVEPETINFO_3SEC");
end

function REMOVEPETINFO_3SEC()
	local g = _G["ADDONS"]["MIEI"]["REMOVEPETINFO"];
	local acutil =  require('acutil');

	if g.loaded ~= true then
		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
		if err then
			acutil.saveJSON(g.settingsFileLoc, g.settings);
		else
			g.settings = t;
		end

		acutil.slashCommand('/comp', g.processCommand)
		acutil.slashCommand('/companion', g.processCommand);
		CHAT_SYSTEM('[removePetInfo:help] /comp');

		g.loaded = true;
	end

	acutil.setupEvent(g.addon, "UPDATE_COMPANION_TITLE", "REMOVEPETINFO_UPDATE_COMPANION_TITLE")
end

function REMOVEPETINFO_UPDATE_COMPANION_TITLE(addonframe, eventMsg)
	local g = _G["ADDONS"]["MIEI"]["REMOVEPETINFO"];

	local frame, handle = acutil.getEventArgs(eventMsg);

	frame = tolua.cast(frame, "ui::CObject");

	local mycompinfoBox = GET_CHILD_RECURSIVELY(frame, "mycompinfo");
	if mycompinfoBox == nil then
		return;
	end
	local otherscompinfo = GET_CHILD_RECURSIVELY(frame, "otherscompinfo");

	local mynameRtext = GET_CHILD_RECURSIVELY(frame, "myname");
	local gauge_stamina = GET_CHILD_RECURSIVELY(frame, "StGauge");
	local hp_stamina = GET_CHILD_RECURSIVELY(frame, "HpGauge");
	local pcinfo_bg_L = GET_CHILD_RECURSIVELY(frame, "pcinfo_bg_L");
	local pcinfo_bg_R = GET_CHILD_RECURSIVELY(frame, "pcinfo_bg_R");

	local othernameTxt = GET_CHILD_RECURSIVELY(frame, "othername");

	gauge_stamina:ShowWindow(tonumber(g.settings.showMyPetHP))
	hp_stamina:ShowWindow(tonumber(g.settings.showMyPetHP))
	pcinfo_bg_L:ShowWindow(tonumber(g.settings.showMyPetHP))
	pcinfo_bg_R:ShowWindow(tonumber(g.settings.showMyPetHP))
	mynameRtext:ShowWindow(tonumber(g.settings.showMyPetName))

	othernameTxt:ShowWindow(tonumber(g.settings.showOtherPetNames))

	frame:Invalidate()
end


function g.processCommand(words)
	local g = _G["ADDONS"]["MIEI"]["REMOVEPETINFO"];
	local acutil =  require('acutil');
	
	local cmd = table.remove(words,1);

	if not cmd then
		local msg = 'removePetInfo{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/comp name [on/off]{nl}'
		msg = msg .. 'Show/hide your pet name.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/comp hp [on/off]{nl}';
		msg = msg .. 'Show/hide your pet HP.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/comp other [on/off]{nl}';
		msg = msg .. 'Show/hide other pet names.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. 'These commands can also be accessed with /companion';

		return ui.MsgBox(msg,"","Nope");

	elseif cmd == 'name' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			g.settings.showMyPetName = 1;
			CHAT_SYSTEM("[removePetInfo] Showing your pet's name.")
		elseif cmd == 'off' then
			g.settings.showMyPetName = 0;
			CHAT_SYSTEM("[removePetInfo] Hiding your pet's name.")
		end

	elseif cmd == 'hp' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			g.settings.showMyPetHP = 1;
			CHAT_SYSTEM("[removePetInfo] Showing your pet's stats.")
		elseif cmd == 'off' then
			g.settings.showMyPetHP = 0;
			CHAT_SYSTEM("[removePetInfo] Hiding your pet's stats.")
		end

	elseif cmd == 'other' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			g.settings.showOtherPetNames =  1;
			CHAT_SYSTEM("[removePetInfo] Showing other pet's names.")
		elseif cmd == 'off' then
			g.settings.showOtherPetNames = 0;
			CHAT_SYSTEM("[removePetInfo] Hiding other pet's names.")
		end

	else
		CHAT_SYSTEM('[removePetInfo] Invalid input. Type "/companion" for help.');
	end
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end
