--GETMYFAMILYNAME();

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI']["REMOVEFPSCOUNTER"] = _G['ADDONS']['MIEI']["REMOVEFPSCOUNTER"] or {};

function REMOVEFPSCOUNTER_ON_INIT(addon, frame)
	local g = _G['ADDONS']['MIEI']["REMOVEFPSCOUNTER"];
	if g.loaded ~= true then
		g.settings = {
			showFPSCounter = false;
		};
	end

	g.settingsFileLoc = path.GetDataPath() .. '../addons/removefpscounter/settings.json';
	g.addon = addon;
	g.frame = frame;
	g.addon:RegisterMsg("GAME_START_3SEC", "REMOVEFPSCOUNTER_3SEC");
end

function REMOVEFPSCOUNTER_3SEC()
	local g = _G['ADDONS']['MIEI']["REMOVEFPSCOUNTER"];
	local acutil = require('acutil');

	if g.loaded ~= true then
		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
		if err then
			acutil.saveJSON(g.settingsFileLoc, g.settings);
		else
			g.settings = t;
		end

		acutil.slashCommand('/fps', g.processCommand);
		CHAT_SYSTEM('[removeFPSCounter:help] /fps');

		g.loaded = true;
	end
	
	if g.settings.showFPSCounter ~= true then
		ui.CloseFrame("fps");
	end
end

function ADDONS.MIEI.REMOVEFPSCOUNTER.processCommand(words)
	local g = _G['ADDONS']['MIEI']["REMOVEFPSCOUNTER"];
	local acutil = require('acutil');

	local cmd = table.remove(words,1);
	if g.settings.showFPSCounter == true then
		ui.CloseFrame("fps");
		g.settings.showFPSCounter = false;
		CHAT_SYSTEM("[removeFPSCounter] Hiding FPS counter.")
	else
		ui.OpenFrame("fps");
		g.settings.showFPSCounter = true;
		CHAT_SYSTEM("[removeFPSCounter] Showing FPS counter.")
	end

	acutil.saveJSON(g.settingsFileLoc, g.settings);
end
