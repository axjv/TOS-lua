REMOVETPBUTTON = _G["REMOVETPBUTTON"] or {};

function REMOVETPBUTTON_ON_INIT(addon, frame)
	local g = _G["REMOVETPBUTTON"];
	
	g.addon = addon;
	g.frame = frame;
	g.addon:RegisterMsg("GAME_START_3SEC", "REMOVETPBUTTON_3SEC");
end

function REMOVETPBUTTON_3SEC()
	local g = _G["REMOVETPBUTTON"];
	local acutil = require('acutil');

	if not g.loaded then
		acutil.slashCommand('/tp', function() ui.OpenFrame('simpleingameshop') end);
		CHAT_SYSTEM('[removeTPButton:help] /tp');

		g.loaded = true;
	end

	ReserveScript('ui.CloseFrame("openingameshopbtn");', 1);
end

