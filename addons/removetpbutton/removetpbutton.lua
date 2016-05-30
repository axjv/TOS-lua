local addonName = "REMOVETPBUTTON";
_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};

local g = _G["ADDONS"]["MIEI"][addonName];

-- INIT
g.addon:RegisterMsg("GAME_START_3SEC", "REMOVETPBUTTON_3SEC");
-- /INIT

function REMOVETPBUTTON_3SEC()
	local g = _G["ADDONS"]["MIEI"]["REMOVETPBUTTON"];
	local acutil = require('acutil');

	if g.loaded ~= true then
		acutil.slashCommand('/tp', g.processCommand);
		CHAT_SYSTEM('[removeTPButton:help] /tp');

		g.loaded = true;
	end

	ui.CloseFrame("openingameshopbtn");
end

function g.processCommand(words)
	--local cmd = table.remove(words,1);

	ui.OpenFrame('simpleingameshop');
end
