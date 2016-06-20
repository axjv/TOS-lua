_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI']["REMOVEMAPBACKGROUND"] = _G['ADDONS']['MIEI']["REMOVEMAPBACKGROUND"] or {};

function REMOVEMAPBACKGROUND_ON_INIT(addon, frame)
	local g = _G['ADDONS']['MIEI']["REMOVEMAPBACKGROUND"];

	g.addon = addon;
	g.frame = frame;
	g.addon:RegisterMsg('GAME_START_3SEC', 'REMOVEMAPBACKGROUND');
end

function REMOVEMAPBACKGROUND()
	GET_CHILD(ui.GetFrame("map"), "bg"):ShowWindow(0);
end
