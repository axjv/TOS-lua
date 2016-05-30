local addonName = "REMOVEFPSCOUNTER";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};

local g = _G['ADDONS']['MIEI'][addonName];
local acutil = require('acutil');
if g.loaded ~= true then
	g.settings = {
		showFPSCounter = false;
	};
end

g.settingsComment = [[%s
Remove FPS Counter by Miei, settings file
http://github.com/Miei/TOS-lua

%s

]];

g.settingsComment = string.format(g.settingsComment, "--[[", "]]");
g.settingsFileLoc = '../addons/removefpscounter/settings.json';

-- INIT
g.addon:RegisterMsg("GAME_START_3SEC", "REMOVEFPSCOUNTER_ON_3SEC")

-- /INIT

function REMOVEFPSCOUNTER_ON_3SEC()
	local g = _G["ADDONS"]["MIEI"]["REMOVEFPSCOUNTER"];
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

function g.processCommand(words)
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
