function REMOVETPBUTTON_ON_INIT(addon, frame)
	local addonName = "REMOVETPBUTTON";

	_G['ADDONS'] = _G['ADDONS'] or {};
	_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
	_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};
	local g = _G['ADDONS']['MIEI'][addonName];

	g.addon = addon;
	g.frame = frame;

	addonName = addonName:lower();
	dofile("../addons/" .. addonName .. "/" .. addonName .. ".lua");
end
