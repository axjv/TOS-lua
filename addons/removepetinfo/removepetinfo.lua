local addonName = "REMOVEPETINFO";
_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};

local g = _G["ADDONS"]["MIEI"][addonName];
if g.loaded ~= true then
	g.settings = {
		showMyPetName = 1;
		showMyPetHP = 0;
		showOtherPetNames = 0;
		version = 0.1;
	};
end

g.settingsComment = [[%s
Remove Pet Info by Miei, settings file
http://github.com/Miei/TOS-lua

%s

]];

g.settingsComment = string.format(g.settingsComment, "--[[", "]]");
g.settingsFileLoc = '../addons/miei/removepetinfo-settings.lua';


-- INIT
	g.addon:RegisterMsg("GAME_START_3SEC", "REMOVEPETINFO_3SEC");
-- /INIT

function REMOVEPETINFO_3SEC()
	local g = _G["ADDONS"]["MIEI"]["REMOVEPETINFO"];
	local utils = _G['ADDONS']['MIEI']['utils'];

	if g.loaded ~= true then
		g.settings = utils.load(g.settings, g.settingsFileLoc, g.settingsComment);

		utils.setupEvent(g.addon, "UPDATE_COMPANION_TITLE", "REMOVEPETINFO_UPDATE_COMPANION_TITLE")

		utils.slashcommands['/comp'] = g.processCommand;
		utils.slashcommands['/companion'] = g.processCommand;
		CHAT_SYSTEM('[removePetInfo:help] /comp');

		g.loaded = true;
	end
end

function REMOVEPETINFO_UPDATE_COMPANION_TITLE(addonframe, eventMsg)
	local g = _G["ADDONS"]["MIEI"]["REMOVEPETINFO"];
	local utils = _G["ADDONS"]["MIEI"]["utils"];
	local frame, handle = utils.eventArgs(eventMsg);

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
	local utils = _G["ADDONS"]["MIEI"]["utils"];
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
	utils.save(g.settings, g.settingsFileLoc, g.settingsComment);
end
