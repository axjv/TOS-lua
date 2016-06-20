--GETMYFAMILYNAME();

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI']["TOGGLEDUELS"] = _G['ADDONS']['MIEI']["TOGGLEDUELS"] or {};


function TOGGLEDUELS_ON_INIT(addon, frame)
	local g = _G["ADDONS"]["MIEI"]["TOGGLEDUELS"];
	local acutil = require('acutil');

	if not g.loaded then
		g.settings = {
			duels = true;
			notify = true; 
		};
	end

	g.settingsFileLoc = path.GetDataPath() .. '../addons/toggleduels/settings.json';

	g.addon = addon;
	g.frame = frame;
	g.addon:RegisterMsg("GAME_START_3SEC", "TOGGLEDUELS_3SEC");
end

function TOGGLEDUELS_3SEC()
	local g = _G["ADDONS"]["MIEI"]["TOGGLEDUELS"];
	local acutil = require('acutil');

	if g.loaded ~= true then
		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
		if err then 
			acutil.saveJSON(g.settingsFileLoc, g.settings);
		else 
			g.settings = t; 
		end
		
		_G["ASKED_FRIENDLY_FIGHT"] = g.AskedFriendlyFight;

		acutil.slashCommand('/duels', g.processCommand);
		CHAT_SYSTEM('[toggleDuels:help] /duels help{nl}' .. g.duelStatusString());

		g.loaded = true;
	end
end

function ADDONS.MIEI.TOGGLEDUELS.AskedFriendlyFight(handle, familyName)
	local g = _G["ADDONS"]["MIEI"]["TOGGLEDUELS"];
	local acutil = require('acutil');

	if g.settings.duels == true then
		local msgBoxString = ScpArgMsg("DoYouAcceptFriendlyFightingWith{Name}?", "Name", familyName);
		ui.MsgBox(msgBoxString, string.format("ACK_FRIENDLY_FIGHT(%d)", handle) ,"None");
	elseif g.settings.notify == true then
		CHAT_SYSTEM('[toggleDuels] Declined duel from ' .. familyName);
	end
end

function ADDONS.MIEI.TOGGLEDUELS.processCommand(words)
	local g = _G["ADDONS"]["MIEI"]["TOGGLEDUELS"];
	local acutil = require('acutil');

	local cmd = table.remove(words,1);
	local msg = '';
	
	if not cmd then
		if g.settings.duels == true then
			g.settings.duels = false;
			msg = '[toggleDuels] Duels toggled off.{nl}'
			
		else
			g.settings.duels = true;
			msg = '[toggleDuels] Duels toggled on.{nl}'
		end
	
	elseif cmd == 'off' then
		g.settings.duels = false;
		msg = g.duelStatusString();
	
	elseif cmd == 'on' then
		g.settings.duels = true;
		msg = g.duelStatusString();
	
	elseif cmd == 'help' then
		msg = 'toggleDuels{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. 'Usage: /duels [on/off/notify/help]{nl}'
		msg = msg .. 'Typing "/duels" without an argument will toggle duels on/off quickly.{nl}';
		msg = msg .. 'e.g. On means that duels are "on" and you will recieve duel requests.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/duels notify{nl}';
		msg = msg .. 'Toggles the chat message that is sent when a duel request is automatically declined.';

		return ui.MsgBox(msg,"","Nope");
		
	elseif cmd == 'notify' then
		if g.settings.notify == true then
			g.settings.notify = false;
			msg = '[toggleDuels] Notify setting toggled off.'
		else
			g.settings.notify = true;
			msg = '[toggleDuels] Notify setting toggled on.'
		end
		
	else 
		msg = '[toggleDuels] Invalid input. Valid inputs are: on, off, notify, help.';
	end
	CHAT_SYSTEM(msg);
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function ADDONS.MIEI.TOGGLEDUELS.duelStatusString()
	local g = _G["ADDONS"]["MIEI"]["TOGGLEDUELS"];
	local acutil = require('acutil');
	
	local statusString = '';
	if g.settings.duels == false then
		statusString = '[toggleDuels] Declining duels.';
	else
		statusString = '[toggleDuels] Allowing duel requests.';
	end
	return statusString;
end
