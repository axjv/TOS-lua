local addonName = "REMOVEMAPBACKGROUND";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};
local g = _G['ADDONS']['MIEI'][addonName];

-- INIT
	g.addon:RegisterMsg('GAME_START_3SEC', 'REMOVEMAPBACKGROUND');
-- /INIT

function REMOVEMAPBACKGROUND()
	GET_CHILD(ui.GetFrame("map"), "bg"):ShowWindow(0);
end
