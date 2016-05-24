function REMOVEMAPBACKGROUND_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START_3SEC', 'ADDON_REMOVE_MAP_BACKGROUND');
end

function ADDON_REMOVE_MAP_BACKGROUND()
	GET_CHILD(ui.GetFrame("map"), "bg"):ShowWindow(0);
end