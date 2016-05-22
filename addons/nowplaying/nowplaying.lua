local settings = {
	showFrame = 1; 				-- Default enable or disable onscreen text. This will also disable notifications.
	onlyNotification = 1;		-- Do you want to only show text as a temporary notification after bgm changes?
	notifyDuration = 15;		-- Duration of the notification text
	chatMessage = 0;			-- Chat message for each new bgm?
}

local nowPlaying = _G["ADDONS"]["NOWPLAYING"];
nowPlaying.chatFrame = ui.GetFrame("chatframe");
nowPlaying.frame = ui.GetFrame("nowplaying");
nowPlaying.textBox = GET_CHILD(nowPlaying.frame, "textbox");

function NOWPLAYING_UPDATE_FRAME()
	local nowPlaying = _G["ADDONS"]["NOWPLAYING"];

	if nowPlaying.settings.showFrame ~= 1 then return end
	if imcSound.GetPlayingMusicInst() == nil then return end
	if config.GetMusicVolume() == 0 then return end

	if nowPlaying.musicInst ~= imcSound.GetPlayingMusicInst() then
		nowPlaying.musicInst = imcSound.GetPlayingMusicInst();

		local musicFileName = nowPlaying.musicInst:GetFileName();
		
		for word in string.gmatch(musicFileName, "bgm\(.-)mp3") do
			local musicArtist = string.match(musicFileName, "tos_(.-)_");
			local musicTitle = string.match(musicFileName, "tos_.-_(.-)%.mp3");
			musicTitle = string.gsub(musicTitle, '_', ' ');

			if musicArtist == "Tree" then
				musicTitle = "Tree of Savior";
				musicArtist = "Cinenote; Sevin";
			end
			if musicArtist == "SFA" then
				musicArtist = "S.F.A"
			end

			nowPlaying.currentTrack = string.format('Now playing: %s - %s', musicArtist, musicTitle);
			nowPlaying.frame:ShowWindow(nowPlaying.settings.showFrame);

			nowPlaying.frame:ShowWindow(1);
			if nowPlaying.settings.onlyNotification == 1 then
				nowPlaying.frame:SetDuration(nowPlaying.settings.notifyDuration);
			end

			if nowPlaying.settings.chatMessage == 1 then
				CHAT_SYSTEM(nowPlaying.currentTrack);
			end

			nowPlaying.frame:SetPos(nowPlaying.chatFrame:GetX()+2, nowPlaying.chatFrame:GetY()-nowPlaying.frame:GetHeight());
			nowPlaying.textBox:SetTextByKey("text", nowPlaying.currentTrack);
		end
	end
end

function nowPlaying.processCommand(words)
	local cmd = table.remove(words,1);
	if cmd == 'off' then
		nowPlaying.settings.showFrame = 0;
		nowPlaying.frame:ShowWindow(0);
		return;
	elseif cmd == 'on' then
		nowPlaying.settings.showFrame = 1;
		nowPlaying.frame:ShowWindow(1);
		return;
	elseif cmd == 'chat' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			nowPlaying.settings.chatMessage = 1;
			cwAPI.util.log("[nowPlaying] Chat messages enabled");
			nowPlaying.frame.SetDuration(nowPlaying.settings.notifyDuration);
		elseif cmd == 'off' then
			nowPlaying.settings.chatMessage = 0;
			cwAPI.util.log("[nowPlaying] Chat messages disabled");
		end
		return;
	elseif cmd == 'notify' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			nowPlaying.settings.onlyNotification = 1;
			cwAPI.util.log("[nowPlaying] Notify mode enabled");
		elseif cmd == 'off' then
			nowPlaying.settings.onlyNotification = 0;
			cwAPI.util.log("[nowPlaying] Notify mode disabled");
		end
		return;
	elseif cmd == 'help' then
		local msg = 'nowPlaying{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np{nl}'
		msg = msg .. 'Show the current track name.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np [on/off]{nl}';
		msg = msg .. 'Show/hide the yellow text above chat.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np chat [on/off]{nl}';
		msg = msg .. 'Show/hide chat messages on new track.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np notify [on/off]{nl}';
		msg = msg .. 'Enable/disable notification mode.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np help{nl}';
		msg = msg .. 'Shows this window.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np can also be used as /music or /nowplaying';

		return ui.MsgBox(msg,"","Nope");
	end

	local msg = '';
	msg = nowPlaying.currentTrack;
	if msg == '' then
		msg = 'Now Playing: None';
	end
	cwAPI.util.log(msg);
end

if not nowPlaying.loaded then
	nowPlaying.settings = settings;
	nowPlaying.frame:ShowWindow(settings.showFrame);

	if settings.onlyNotification == 1 then
		nowPlaying.frame:SetDuration(settings.notifyDuration);
	end

	nowPlaying.loaded = true;
end

nowPlaying["addon"]:RegisterMsg('FPS_UPDATE', 'NOWPLAYING_UPDATE_FRAME');

if (not cwAPI) then
	return false;
else
	_G['ADDON_LOADER']['nowplaying'] = function()
		cwAPI.commands.register('/nowplaying',nowPlaying.processCommand);
		cwAPI.commands.register('/np',nowPlaying.processCommand);
		cwAPI.commands.register('/music',nowPlaying.processCommand);
		cwAPI.util.log('[nowPlaying:help] /np [on/off]');
		return true;
	end
end
