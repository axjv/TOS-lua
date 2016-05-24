local addonName = "REMOVEFPSCOUNTER";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};

local g = _G['ADDONS']['MIEI'][addonName];

if g.loaded ~= true then
	g.settings = {
		showFPSCounter = 0;
		version = 0.1;
	};
end

g.settingsComment = [[%s
Remove FPS Counter by Miei, settings file
http://github.com/Miei/TOS-lua

%s

]];

g.settingsComment = string.format(g.settingsComment, "--[[", "]]");
g.settingsFileLoc = '../addons/miei/removefpscounter-settings.lua';

-- INIT
g.addon:RegisterMsg("GAME_START_3SEC", "REMOVEFPSCOUNTER_ON_3SEC")

-- /INIT

function REMOVEFPSCOUNTER_ON_3SEC()
	local g = _G["ADDONS"]["MIEI"]["REMOVEFPSCOUNTER"];
	local utils = _G['ADDONS']['MIEI']['utils'];


	-- on 3sec
	if g.loaded ~= true then
		g.settings = utils.load(g.settings, g.settingsFileLoc, g.settingsComment);

		utils.slashcommands['/fps'] = g.processCommand;
		CHAT_SYSTEM('[removeFPSCounter:help] /fps');

		g.loaded = true;
	end
	if g.settings.showFPSCounter ~= true then
		ui.CloseFrame("fps");
	end
end

function g.processCommand(words)
	local g = _G["ADDONS"]["MIEI"]["REMOVEFPSCOUNTER"];
	local utils = _G["ADDONS"]["MIEI"]["utils"];
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

	utils.save(g.settings, g.settingsFileLoc, g.settingsComment);
end
