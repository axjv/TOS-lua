function MIEI_UTILITY_ON_INIT(addon, frame)
	local addonName = "MIEI_UTILITY";

	_G['ADDONS'] = _G['ADDONS'] or {};
	_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
	_G['ADDONS']['MIEI']['utils'] = _G['ADDONS']['MIEI']['utils'] or {};

	local utils = _G['ADDONS']['MIEI']['utils'];
	utils.slashcommands = utils.slashcommands or {};

	utils.addon = addon;
	utils.frame = frame;

	addonName = addonName:lower();
	dofile("../addons/" .. addonName .. "/" .. addonName .. ".lua");
end
