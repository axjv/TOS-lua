--todo:
-- custom chat channels
-- finish integrating lkchat
-- theme settings (color picker etc etc)
--

_G["CLASSICCHAT"] = _G["CLASSICCHAT"] or {};

function CLASSICCHAT_ON_INIT(addon, frame)
	local acutil = require('acutil');
	local g = _G['CLASSICCHAT'];

	g.myFamilyName = GETMYFAMILYNAME();

	g.addon = addon;
	g.frame = frame;

	addon:RegisterMsg("GAME_START_3SEC", "CLASSICCHAT_3SEC");
end

function CLASSICCHAT_3SEC()
	local acutil = require('acutil');
	local g = _G['CLASSICCHAT'];

	if not g.loaded then
		g.messages = {};
		g.messages.ignore = {};
		g.messages.names = {};
		g.sizes = {};

		g.settingsFileLoc = path.GetDataPath() .. "..\\addons\\classicchat\\settings.json";

		g.botSpamTest = "([3vw]-%s*[vw]-%s*[vw]-%s*[vw]-%s*[,%.%-]+%s*.-%s*[,%.%-]+%s*c[_%s]-[o0%(%)]-[_%s]-[nm])(.*)";
		g.botSpamPatterns = {
			-- find
			{ pattern = "sell",				type = "find", weight = 1 },
			{ pattern = "usd",				type = "find", weight = 1 },
			{ pattern = "eur",				type = "find", weight = 1 },
			{ pattern = "daum",				type = "find", weight = 1 },
			{ pattern = "cheap",			type = "find", weight = 1 },
			{ pattern = "fast",				type = "find", weight = 1 },
			{ pattern = "f@st",				type = "find", weight = 1 },
			{ pattern = "offer",			type = "find", weight = 1 },
			{ pattern = "qq",				type = "find", weight = 1 },
			{ pattern = "skype",			type = "find", weight = 1 },
			{ pattern = "delivery",			type = "find", weight = 1 },
			{ pattern = "silver",			type = "find", weight = 1 },
			{ pattern = "s1lver",			type = "find", weight = 1 },
			{ pattern = "gold",				type = "find", weight = 1 },
			{ pattern = "g0ld",				type = "find", weight = 1 },
			{ pattern = "powerleveling",	type = "find", weight = 1 },
			{ pattern = "powerlevling",		type = "find", weight = 1 },
			{ pattern = "p0wer1eve1ing",	type = "find", weight = 1 },
			{ pattern = "mmoceo",			type = "find", weight = 2 },
			{ pattern = "mmocvv",			type = "find", weight = 2 },
			{ pattern = "hoagold",			type = "find", weight = 2 },
			{ pattern = "m%-m%-o%-c%-e%-o",	type = "find", weight = 3 },

			-- match
			{ pattern = "=%d+%$",		type = "match", weight = 3 },	-- =1$
			{ pattern = "=%d[,%.]%d+%$",type = "match", weight = 3 },	-- =0.6$
		};


		g.channelWatch = {
			Normal = true,
			Whisper = true,
			Shout = true,
			Party = false,
			Guild = false,
			System = false,
		};

		g.settings = {
			theme = 'simple';
			boldSender = true;
			channelTag = false;
			closeChatOnSend = true;
			hideSystemName = true;
			urlClickWarning = true;
			timeStamp = true;
			urlMatching = true;	
			spamDetection = true;
			spamNotice = true;
			reportSpamBots = false;
			blockReason = false;
			whisperNotice = true;
			friendNotice = true;
		};

		g.settings.whisperSound = {
			cooldown = 0; 
			sound = 'sys_jam_slot_equip';
			onSendingMessage = false;
			requireNewCluster = true;
		};

		g.settings.formatting = {
			channelTagBrackets = "<>";
			nameTagBrackets = "<>";
			timeStampBrackets = "[]";
			indentation = " ";
		};

		g.settings.chatColors = {	
			Whisper = 'ff40ff';
			Normal = 'f4e65c';
			Shout = 'ff2223';
			Party = '2da6ff';
			Guild = '40fb40';
			System = 'ff9696';
			Link = "2a58ff"; 
		};

		g.settings.tagStringColors = {
			enabled = false;
			Whisper = 'ff40ff';
			Normal = 'f4e65c';
			Shout = 'ff2223';
			Party = '2da6ff';
			Guild = '40fb40';
			System = 'ff9696';
		};

		g.settings.itemColors = {
			"e1e1e1", 	-- white item
			"108CFF", 	-- blue item
			"9F30FF", 	-- purple item
			"FF4F00", 	-- orange item
		};

		g.load();

		if g.settings.urlMatching == true then
			CHAT_SYSTEM("https://classich.at loaded!");
		else
			CHAT_SYSTEM("Classic Chat loaded!");
		end

		g.RefreshFriendList();

		g.loaded = true;
	end

	g.addon:RegisterMsg("MYPC_GUILD_JOIN", "CLASSICCHAT_ON_GUILD_INFO_UPDATE");
	g.addon:RegisterMsg("GUILD_EVENT_UPDATE", "CLASSICCHAT_ON_GUILD_INFO_UPDATE");
	g.addon:RegisterOpenOnlyMsg("GUILD_INFO_UPDATE", "CLASSICCHAT_ON_GUILD_INFO_UPDATE");
	g.addon:RegisterOpenOnlyMsg("ADD_FRIEND", "CLASSICCHAT_ON_GUILD_INFO_UPDATE");
	g.addon:RegisterOpenOnlyMsg("REMOVE_FRIEND", "CLASSICCHAT_ON_GUILD_INFO_UPDATE");
	g.addon:RegisterOpenOnlyMsg("UPDATE_FRIEND_LIST", "CLASSICCHAT_ON_GUILD_INFO_UPDATE");

	_G["DRAW_CHAT_MSG"] = g.drawChatMsg;
	_G["RESIZE_CHAT_CTRL"] = g.resizeChatCtrl;
	_G["CHAT_SET_OPACITY"] = g.chatSetOpacity;
	_G["CHAT_OPEN_OPTION"] = function()
		ui.ToggleFrame('classicchat');
	end;


	acutil.setupEvent(g.addon, "ui.Chat", "CLASSICCHAT_ON_UICHAT");

	local framefn = function() ui.ToggleFrame('classicchat') end
	acutil.slashCommand('/chat', framefn)
	acutil.slashCommand('/classicchat', framefn)
	acutil.slashCommand('/lkc', framefn)
	acutil.slashCommand('/lkchat', framefn)

	g.isWhisperCooldown = false;

	g.chatSetOpacity(-1);
	g.InitializeSettings();
end

function CLASSICCHAT.load()
	local g = _G['CLASSICCHAT']
	local acutil = require('acutil');

	local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
	if err then 
		acutil.saveJSON(g.settingsFileLoc, g.settings);
	else 
		g.settings = t; 
	end

	g.settings.itemColors = setmetatable(g.settings.itemColors, {__index = function() return tostring(g.settings.itemColors[1]) end });
end

function CLASSICCHAT.save()
	local g = _G['CLASSICCHAT']
	local acutil = require('acutil');
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function CLASSICCHAT_ON_UICHAT(addonframe, eventMsg)
	local g = _G['CLASSICCHAT'];
	local acutil = require('acutil')

	if g.settings.closeChatOnSend == true then
		acutil.closeChat();
	end
end

function CLASSICCHAT.redraw()
	DRAW_CHAT_MSG("chatgbox_TOTAL", CLASSICCHAT.sizeParam, 0);
	CLASSICCHAT.realign()
end

function CLASSICCHAT_REALIGN()
	local chatFrame = ui.GetFrame("chatframe");
	if chatFrame == nil then
		return;
	end
	local count = chatFrame:GetChildCount();
	for  i = 0, count-1 do 
		local groupBox  = chatFrame:GetChildByIndex(i);
		local childName = groupBox:GetName();
		if string.sub(childName, 1, 5) == "chatg" then
			if groupBox:GetClassName() == "groupbox" then
				groupBox = tolua.cast(groupBox, "ui::CGroupBox");
				local y = 0;
				local ctrlSetCount = groupBox:GetChildCount();
				for j = 0 , ctrlSetCount - 1 do
					local chatCtrl = groupBox:GetChildByIndex(j);
					if chatCtrl:GetClassName() == "controlset" then
						local label = chatCtrl:GetChild('bg');
						local txt = GET_CHILD(label, "text");
						local timeBox = GET_CHILD(chatCtrl, "timebox");
						RESIZE_CHAT_CTRL(chatCtrl, label, txt, timeBox)
						chatCtrl:SetOffset(ctrl:GetX(), y);
						y = y + chatCtrl:GetHeight();
					end
				end

			end
		end
	end

	chatFrame:Invalidate();
end

function CLASSICCHAT.realign()
	local chatFrame = ui.GetFrame('chatframe');
	chatFrame:CancelReserveScript('CLASSICCHAT_REALIGN')
	chatFrame:ReserveScript("CLASSICCHAT_REALIGN", 0.1, 1);
end


function CLASSICCHAT.drawChatMsg(groupBoxName, size, startIndex, frameName)
	local acutil = require('acutil');
	local g = _G['CLASSICCHAT'];

	if groupBoxName == 'chatgbox_TOTAL' then
		g.sizeParam = size;
	end

	if not g.drawinit then
		g.drawinit = true;
		CLASSICCHAT.redraw();
		return;
	end

	if startIndex < 0 then
		return;
	end

	if frameName == nil then
		frameName = "chatframe";

		local popupFrameName = "chatpopup_" ..groupBoxName:sub(10, groupBoxName:len())
		DRAW_CHAT_MSG(groupBoxName, size, startIndex, popupFrameName);
	end

	local chatFrame = ui.GetFrame(frameName)
	if chatFrame == nil then
		return
	end

	local groupBox = GET_CHILD(chatFrame,groupBoxName);

	if groupBox == nil then
		local groupBoxLeftMargin = chatFrame:GetUserConfig("GBOX_LEFT_MARGIN")
		local groupBoxRightMargin = chatFrame:GetUserConfig("GBOX_RIGHT_MARGIN")
		local groupBoxTopMargin = chatFrame:GetUserConfig("GBOX_TOP_MARGIN")
		local groupBoxBottomMargin = chatFrame:GetUserConfig("GBOX_BOTTOM_MARGIN")

		groupBox = chatFrame:CreateControl("groupbox", groupBoxName, chatFrame:GetWidth() - (groupBoxLeftMargin + groupBoxRightMargin), chatFrame:GetHeight() - (groupBoxTopMargin + groupBoxBottomMargin), ui.RIGHT, ui.BOTTOM, 0, 0, groupBoxRightMargin, groupBoxBottomMargin);

		_ADD_GBOX_OPTION_FOR_CHATFRAME(groupBox)
		groupBox:SetSkinName("bg");
	end

	if startIndex == 0 then
		DESTROY_CHILD_BYNAME(groupBox, "cluster_");
	end

	for i = startIndex, size - 1 do
		local message = session.ui.GetChatMsgClusterInfo(groupBoxName, i);
		if message then
			local msg = g.formatMessage(message, groupBoxName)
			if groupBoxName == 'chatgbox_TOTAL' and not g.messages.ignore[msg.id] then
				g.messages.names = {};
				if g.settings.spamDetection and g.channelWatch[msg.type] and --[[not g.isFriendOrGuildMember(msg.name) and]]  msg.name ~= g.myFamilyName then
					if g.filterMessage(msg.text) then
						g.messages.names[msg.name] = true;
						g.messages.ignore[msg.id] = true;


						friends.RequestBlock(msg.name);		-- Blocked! No more spam for you!
						if g.settings.reportSpamBots then
							packet.ReportAutoBot(msg.name);		-- Bot Report
						end

						if g.settings.spamNotice then
							g.spamRemoval_Notice(msg);
						end
					end
				end
			elseif g.messages.names[msg.name] then
				g.messages.ignore[msg.id] = true;
			end
		end
	end

	local roomID = "Default"

	local marginLeft = 0;
	local marginRight = 25;

	local ypos = 0

	for i = startIndex , size - 1 do
		if i ~= 0 then
			local j = tonumber(i);
			local clusterInfo = nil;
			repeat
				j = j-1;
				local cInfo = session.ui.GetChatMsgClusterInfo(groupBoxName, j)
				if g.messages.ignore[cInfo:GetClusterID()] ~= true then
					clusterInfo = cInfo;
				end
			until (clusterInfo ~= nil or j <= 0);

			--local clusterInfo = session.ui.GetChatMsgClusterInfo(groupBoxName, i-1)
			if clusterInfo ~= nil then
				local beforeChildName = "cluster_"..clusterInfo:GetClusterID()
				local beforeChild = GET_CHILD(groupBox, beforeChildName);

				if beforeChild ~= nil then
					ypos = beforeChild:GetY() + beforeChild:GetHeight();
				end
			end

			if ypos == 0 then
				DRAW_CHAT_MSG(groupBoxName, size, 0, frameName);
				return;
			end
		end

		local clusterInfo = session.ui.GetChatMsgClusterInfo(groupBoxName, i);
		if clusterInfo == nil then
			return;
		end

		if g.messages.ignore[clusterInfo:GetClusterID()] ~= true then
			roomID = clusterInfo:GetRoomID();

			local clusterName = "cluster_"..clusterInfo:GetClusterID()
			local cluster = GET_CHILD(groupBox, clusterName);

			local messageType = clusterInfo:GetMsgType();
			if type(tonumber(messageType)) == "number" then
				messageType = "Whisper";
			end
			local messageSender = clusterInfo:GetCommanderName();
			if messageSender ~= nil then
				for match in messageSender:gmatch(" %[%[.+]") do
					messageSender = g.escape(messageSender);
					messageSender = messageSender:gsub(g.escape(match), "");
					messageSender = g.unescape(messageSender);
				end
			end

			local messageText = clusterInfo:GetMsg();

			
			if g.settings.theme == 'simple' then
				local roomInfo = session.chat.GetByStringID(roomID);
				local memberString = GET_GROUP_TITLE(roomInfo);

				local nameTag = '';
				local channelTag = '';
				local timeStamp = '';

				local chatColor = g.settings.chatColors[messageType];

				local styleString = string.format("{ol}{#%s}", chatColor);

				local tagStyleString = '';

				if g.settings.tagStringColors.enabled == true then
					tagStyleString = string.format("{ol}{#%s}", g.settings.tagStringColors[messageType]);
				else
					tagStyleString = string.format("{ol}{#%s}", chatColor);
				end

				if g.settings.boldSender == true then
					tagStyleString = tagStyleString .. "{ds}";
				end

				-- channel tag
				if g.settings.channelTag == true then
					local channelTagFormat = string.format("%s%%s%s ", g.settings.formatting.channelTagBrackets:sub(1,1),  g.settings.formatting.channelTagBrackets:sub(2,2));
					channelTag = channelTagFormat:format(messageType);
				end

				-- name tag
				local nameTagFormat = string.format("%s%%s%s", g.settings.formatting.nameTagBrackets:sub(1,1),  g.settings.formatting.nameTagBrackets:sub(2,2));
				nameTag = nameTagFormat:format(messageSender);

				-- timestamp
				if g.settings.timeStamp == true then
					local timeStampFormat = string.format("%s%%s%s ", g.settings.formatting.timeStampBrackets:sub(1,1),  g.settings.formatting.timeStampBrackets:sub(2,2));
					timeStamp = timeStampFormat:format(clusterInfo:GetTimeStr());
				end


				-- structuring for different scenarios
				-- [AM 00:00] [System]: msg
				if messageType == 'System' then
					if g.settings.hideSystemName == true then
						messageText =  string.format("%s%s", styleString, messageText);
					else
						messageText =  string.format("%s%s%s%s:{/}%s %s", tagStyleString, g.settings.formatting.indentation, timeStamp, nameTag, styleString, messageText);
					end

				-- [AM 00:00] [Player] whispers: msg
				elseif messageType == 'Whisper' and messageSender ~= g.myFamilyName then
					messageText =  string.format("%s%s%s%s whispers:{/}%s %s", tagStyleString, g.settings.formatting.indentation, timeStamp, nameTag, styleString, messageText);

				-- [AM 00:00] To [Player]: msg
				elseif messageType == 'Whisper' and roomInfo ~= nil then
					messageText =  string.format("%s%s%sTo %s:{/}%s %s", tagStyleString, g.settings.formatting.indentation, timeStamp, memberString, styleString, messageText);

				-- [AM 00:00] [Chat][Player]: msg
				else
					messageText =  string.format("%s%s%s%s%s:{/}%s %s", tagStyleString, g.settings.formatting.indentation, timeStamp, channelTag, nameTag, styleString, messageText);
				end

				messageText = g.escape(messageText);

				-- refresh style after {/} but not {/}{
				messageText = g.insertText(messageText, "{/}[^{]", "{/}", styleString);


				-- refresh style after {/} before {a for consecutive chat links
				messageText = g.insertText(messageText, "{/}[{][a]", "{/}", styleString);

				-- refresh style after {/} before {nl} for newlines directly after chat link
				messageText = g.insertText(messageText, "{/}[{][n][l][}]", "{/}", styleString);

				--never display black text (had some issues with system msgs coming up black)
				messageText = messageText:gsub("{#000000}", string.format("{#%s}", chatColor));


				messageText = g.unescape(messageText);
			end
			

			if g.settings.urlMatching == true then
				messageText = g.processUrls(messageText);
			end

			messageText = g.escape(messageText);
			-- item link colours
			for word in messageText:gmatch("{a SLI.-}{#0000FF}{img.-{/}{/}{/}") do
				local itemID, itemIcon = word:match("{a SLI .- (.-)}{#0000FF}{img (.-) .-{/}{/}{/}");

				local messageTextSubstring = itemID .. "}{#0000FF}";
				local itemObj = CreateIESByID("Item", tonumber(itemID));
				local itemColor = g.settings.itemColors[itemObj.ItemGrade];
				if itemObj.GroupName == "Recipe" then 					--recipes do not hold an itemgrade
					local recipeGrade = itemIcon:match("misc(%d)"); 	-- e.g icon_item_gloves_misc[1-5]
					if recipeGrade ~= nil then
						itemColor = g.settings.itemColors[tonumber(recipeGrade)-1];
					end
				end

				local messageTextReplace = messageTextSubstring:gsub("0000FF", itemColor);
				messageText = messageText:gsub(messageTextSubstring, messageTextReplace);
			end

			if g.settings.theme == 'simple' then
			--change default color for other links (party, map)
				messageText = messageText:gsub("{#0000FF}", string.format("{#%s}", g.settings.chatColors.Link));
			end

			messageText = g.unescape(messageText);

			
			repeat
				if g.settings.whisperNotice and messageType == "Whisper" and startIndex ~= 0 then
					if g.settings.whisperSound.onSendingMessage ~= true and messageSender == g.myFamilyName then break end
					if g.isWhisperCooldown == true then break end
					if g.settings.whisperSound.requireNewCluster == true and cluster ~= nil then break end

					imcSound.PlaySoundEvent(g.settings.whisperSound.sound);
					g.isWhisperCooldown = true;
					ReserveScript("CLASSICCHAT.isWhisperCooldown = false;", g.settings.whisperSound.cooldown);
				end
			until true

			local myColor, targetColor = GET_CHAT_COLOR(clusterInfo:GetMsgType())

			--text always on the left
			local chatCtrlName = 'chatu';
			local horzGravity = ui.LEFT;

			if true == ui.IsMyChatCluster(clusterInfo) and g.settings.theme == 'bubble' then
				chatCtrlName = 'chati';
				horzGravity = ui.RIGHT;
			end

			local fontSize = GET_CHAT_FONT_SIZE();
			if not (chatCtrlName and clusterName and horzGravity and marginLeft and ypos and marginRight) then
				print("classicchat error on creating chatCtrl");
				return
			end
			local err, chatCtrl = pcall(function() return groupBox:CreateOrGetControlSet(chatCtrlName, clusterName, horzGravity, ui.TOP, marginLeft, ypos, marginRight, 0) end);
			if chatCtrl == nil then
				print("classicchat error on creating chatCtrl");
				return
			end
			local label = chatCtrl:GetChild('bg');
			local txt = GET_CHILD(label, "text", "ui::CRichText");
			local notread = GET_CHILD(label, "notread", "ui::CRichText");
			local timeBox = GET_CHILD(chatCtrl, "timebox", "ui::CGroupBox");
			local timeCtrl = GET_CHILD(timeBox, "time", "ui::CRichText");
			local nameText = GET_CHILD(chatCtrl, "name", "ui::CRichText");

			notread:ShowWindow(0);

			if g.settings.theme == 'simple' then
				txt:SetMaxWidth(groupBox:GetWidth()-40);
				txt:Resize(groupBox:GetWidth()-40, txt:GetHeight());
				txt:SetGravity(ui.LEFT, ui.TOP);

				label:SetOffset(25, 0);
				label:SetAlpha(0);

				timeBox:ShowWindow(0);
				nameText:ShowWindow(0);
			elseif g.settings == 'bubble' then
				timeBox:ShowWindow(g.settings.timeStamp and 1 or 0);
				txt:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
			end
			
			txt:SetTextByKey("size", fontSize);
			txt:SetTextByKey("text", messageText);

			timeCtrl:SetTextByKey("time", clusterInfo:GetTimeStr());
			


			if chatCtrlName == 'chati' then
				label:SetSkinName('textballoon_i');
				label:SetColorTone(myColor);
			else			
				local iconPicture = GET_CHILD(chatCtrl, "iconPicture", "ui::CPicture");
				iconPicture:ShowWindow(0);

				nameText:SetText('{@st61}'..messageSender..'{/}');
				label:SetColorTone(targetColor);
			end
			
			
			
			if messageType ~= "System" then
				--txt:SetUserValue("TARGET_NAME", clusterInfo:GetCommanderName()); -- crashy crashy ;_;
				chatCtrl:SetEventScript(ui.RBUTTONUP, 'CHAT_RBTN_POPUP');
				chatCtrl:SetUserValue("TARGET_NAME", clusterInfo:GetCommanderName());
				chatCtrl:EnableHitTest(1);
			end

			chatCtrl:SetEventScript(ui.LBUTTONDOWN, 'CLASSICCHAT_LBUTTONDOWN')

--[[
			local slflag = messageText:find('a SL')
			if slflag == nil then
				label:EnableHitTest(0)
			else
				label:EnableHitTest(1)
			end
]]
			label:EnableHitTest(0)

			RESIZE_CHAT_CTRL(chatCtrl, label, txt, timeBox);
			if g.sizes[groupBoxName] == nil then g.sizes[groupBoxName] = 0; end
			g.sizes[groupBoxName] = g.sizes[groupBoxName] + 1;
		end
	end

	local scrollend = false
	if groupBox:GetLineCount() == groupBox:GetCurLine() + groupBox:GetVisibleLineCount() then
		scrollend = true;
	end

	local beforeLineCount = groupBox:GetLineCount();
	groupBox:UpdateData();

	local afterLineCount = groupBox:GetLineCount();
	local changedLineCount = afterLineCount - beforeLineCount;
	local curLine = groupBox:GetCurLine();
	if scrollend == false then
		groupBox:SetScrollPos(curLine + changedLineCount);
	else
		groupBox:SetScrollPos(99999);
	end

	if groupBox:GetName() == "chatgbox_TOTAL" and groupBox:IsVisible() == 1 then
		chat.UpdateAllReadFlag();
	end

	local parentframe = groupBox:GetParent()

	if parentframe:GetName():find("chatpopup_") == nil then
		if roomID ~= "Default" and groupBox:IsVisible() == 1 then
			chat.UpdateReadFlag(roomID);
		end
	else

		if roomID ~= "Default" and parentframe:IsVisible() == 1 then
			chat.UpdateReadFlag(roomID);
		end
	end

end


CLASSICCHAT.labels = {};
function CLASSICCHAT_LBUTTONDOWN(frame, chatCtrl, argStr, argNum)
	local label = chatCtrl:GetChild('bg');
	local id = math.floor(math.random(999999));

	CLASSICCHAT.labels[id] = label;
	label:EnableHitTest(1)
	ReserveScript('CLASSICCHAT.labels['..id..']:EnableHitTest(0); CLASSICCHAT.labels['..id..'] = nil;', 1);
end

function SLL(text, warned)
	local acutil = require('acutil');
	local g = _G['CLASSICCHAT'];

	if g.settings.urlClickWarning == true and warned ~= true then
		local msgBoxString = "Do you want to open the URL?{nl}"
		local length = 35;
		if #text > length then
			msgBoxString = msgBoxString .. text:sub(1, length) .. "...";
		else
			msgBoxString = msgBoxString .. text;
		end
		local msgBoxScp = string.format("SLL('%s', true)", text);
		ui.MsgBox(msgBoxString, msgBoxScp, "None");
	else
		login.OpenURL(text);
	end
end

local domains = [[.ac.ad.ae.aero.af.ag.ai.al.am.an.ao.aq.ar.arpa.as.asia.at.au
	.aw.ax.az.ba.bb.bd.be.bf.bg.bh.bi.biz.bj.bm.bn.bo.br.bs.bt.bv.bw.by.bz.ca
	.cat.cc.cd.cf.cg.ch.ci.ck.cl.cm.cn.co.com.coop.cr.cs.cu.cv.cx.cy.cz.dd.de
	.dj.dk.dm.do.dz.ec.edu.ee.eg.eh.er.es.et.eu.fi.firm.fj.fk.fm.fo.fr.fx.ga
	.gb.gd.ge.gf.gh.gi.gl.gm.gn.gov.gp.gq.gr.gs.gt.gu.gw.gy.hk.hm.hn.hr.ht.hu
	.id.ie.il.im.in.info.int.io.iq.ir.is.it.je.jm.jo.jobs.jp.ke.kg.kh.ki.km.kn
	.kp.kr.kw.ky.kz.la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly.ma.mc.md.me.mg.mh.mil.mk
	.ml.mm.mn.mo.mobi.mp.mq.mr.ms.mt.mu.museum.mv.mw.mx.my.mz.na.name.nato.nc
	.ne.net.nf.ng.ni.nl.no.nom.np.nr.nt.nu.nz.om.org.pa.pe.pf.pg.ph.pk.pl.pm
	.pn.post.pr.pro.ps.pt.pw.py.qa.re.ro.ru.rw.sa.sb.sc.sd.se.sg.sh.si.sj.sk
	.sl.sm.sn.so.sr.ss.st.store.su.sv.sy.sz.tc.td.tel.tf.tg.th.tj.tk.tl.tm.tn
	.to.tp.tr.travel.tt.tv.tw.tz.ua.ug.uk.um.us.uy.va.vc.ve.vg.vi.vn.vu.web.wf
	.ws.xxx.ye.yt.yu.za.zm.zr.zw]]

function CLASSICCHAT.processUrls(text)
	local acutil = require('acutil');
	local g = _G['CLASSICCHAT'];

	local minLength = 8;
	local tlds = {}
	for tld in domains:gmatch'%w+' do
		tlds[tld] = true
	end
	local function max4(a,b,c,d) return math.max(a+0, b+0, c+0, d+0) end
	local protocols = {[''] = 0, ['http://'] = 0, ['https://'] = 0, ['ftp://'] = 0}
	local finished = {}
	local textNew = text;
	for pos_start, url, prot, subd, tld, colon, port, slash, path in
		text:gmatch'()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
	do
		if protocols[prot:lower()] == (1 - #slash) * #path and not subd:find'%W%W'
			and (colon == '' or port ~= '' and port + 0 < 65536)
			and (tlds[tld:lower()] or tld:find'^%d+$' and subd:find'^%d+%.%d+%.%d+%.$'
			and max4(tld, subd:match'^(%d+)%.(%d+)%.(%d+)%.$') < 256)
		then
			finished[pos_start] = true
			if #url >= minLength then
				textNew = g.insertlink(textNew, url);
			end
		end
	end

	for pos_start, url, prot, dom, colon, port, slash, path in
		text:gmatch'()((%f[%w]%a+://)(%w[-.%w]*)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
	do
		if not finished[pos_start] and not (dom..'.'):find'%W%W'
			and protocols[prot:lower()] == (1 - #slash) * #path
			and (colon == '' or port ~= '' and port + 0 < 65536)
		then
			if #url >= minLength then
				textNew = g.insertlink(textNew, url);
			end
		end
	end
	return textNew;
end

function CLASSICCHAT.insertlink(text, url, urlDisplay)
	local acutil = require('acutil');
	local g = _G['CLASSICCHAT'];

	local maxLength = 28;

	text = g.escape(text);
	url = g.escape(url);
	urlDisplay = urlDisplay or url;
	text = text .. '   ';

	local urlHttp = url;
	if urlHttp:match("https?://") == nil then
		urlHttp = "http://" .. urlHttp;
	end

	if urlDisplay == g.escape("https://classich.at") then
		urlDisplay = "Classic Chat";
		urlHttp = g.escape("https://github.com/Miei/TOS-lua/");
	end

	if urlDisplay ~= url then
		maxLength = 100;
	end

	local linkFormat = "{a SLL %s}{#%s}%s{/}{/}";

	if #g.unescape(urlDisplay) >= maxLength then
		linkFormat = "{a SLL %s}{#%s}%s!@#DOT#@!!@#DOT#@!!@#DOT#@!{/}{/}";
		urlDisplay = g.escape(g.unescape(urlDisplay):sub(1, maxLength-3));
	end

	text = text:gsub(url..'([^{^}])', linkFormat:format(urlHttp, '0000FF', urlDisplay) .. '%1');
	text = text:sub(1,#text-3);
	--text = g.insertText(text, "[^}]", ".", linkFormat:format(urlHttp, '0000FF', urlDisplay));
	return g.unescape(text);
end

function CLASSICCHAT.escape(text)
	text = text:gsub('[%%]','!@#PERCENT#@!');
	text = text:gsub('[%(]','!@#LPAREN#@!');
	text = text:gsub('[%)]','!@#RPAREN#@!');
	text = text:gsub('[%+]','!@#PLUS#@!');
	text = text:gsub('[%-]','!@#MINUS#@!');
	text = text:gsub('[%*]','!@#ASTERISK#@!');
	text = text:gsub('[%?]','!@#QMARK#@!');
	text = text:gsub('[%[]','!@#LBRACKET#@!');
	text = text:gsub('[%]]','!@#RBRACKET#@!');
	text = text:gsub('[%^]','!@#CARET#@!');
	text = text:gsub('[%$]','!@#DOLLAR#@!');
	return text:gsub('[%.]','!@#DOT#@!');
end

function CLASSICCHAT.unescape(text)
	text = text:gsub('!@#RPAREN#@!', '%)')
	text = text:gsub('!@#LPAREN#@!', '%(')
	text = text:gsub('!@#PERCENT#@!', '%%');
	text = text:gsub('!@#PLUS#@!', '%+');
	text = text:gsub('!@#MINUS#@!', '%-');
	text = text:gsub('!@#ASTERISK#@!', '%*');
	text = text:gsub('!@#QMARK#@!', '%?');
	text = text:gsub('!@#LBRACKET#@!', '%[');
	text = text:gsub('!@#RBRACKET#@!', '%]');
	text = text:gsub('!@#CARET#@!', '%^');
	text = text:gsub('!@#DOLLAR#@!', '%$');
	return text:gsub('!@#DOT#@!', '%.');
end


function CLASSICCHAT.insertText(messageText, pattern, insertAfter, insertString)
	for word in messageText:gmatch(pattern) do

		local messageTextSubstring = messageText:match(pattern);
		if messageTextSubstring == nil then
			break;
		end

		local messageTextReplace = messageTextSubstring:gsub(insertAfter, "%1" .. insertString);
		messageText = messageText:gsub(messageTextSubstring, messageTextReplace);
	end
	return messageText;
end

function CLASSICCHAT.resizeChatCtrl(chatCtrl, label, txt, timeBox)
	local g = _G['CLASSICCHAT']
	local groupBox = chatCtrl:GetParent();

	if g.settings.theme == 'simple' then

		local labelWidth = txt:GetWidth();
		local chatWidth = groupBox:GetWidth();

		label:Resize(labelWidth, txt:GetHeight());
		chatCtrl:Resize(chatWidth, label:GetY() + label:GetHeight());
	elseif g.settings.theme == 'bubble' then
		local lablWidth = txt:GetWidth() + 40;
		local chatWidth = chatCtrl:GetWidth();
		label:Resize(lablWidth, txt:GetHeight() + 20);

		chatCtrl:Resize(chatWidth, label:GetY() + label:GetHeight() + 10);

		if chatCtrlName == 'chati' then
			local offsetX = label:GetX() + txt:GetWidth() - 60;
			if 35 > offsetX then
				offsetX = offsetX + 40;
			end
			if label:GetWidth() < timeBox:GetWidth() + 20 then		
				offsetX = math.min(offsetX, label:GetX() - timeBox:GetWidth()/2);
			end
			timeBox:SetOffset(offsetX, label:GetY() + label:GetHeight() - 10);
		else
			
			local offsetX = label:GetX() + txt:GetWidth() - 60;
			if 35 > offsetX then
				offsetX = offsetX + 40;
			end
			timeBox:SetOffset(offsetX, label:GetY() + label:GetHeight() - 10);
		end
	end
end

function CLASSICCHAT.chatSetOpacity(num)
	local acutil = require('acutil');
	local g = _G['CLASSICCHAT'];

	local chatFrame = ui.GetFrame("chatframe");
	if chatFrame == nil then
		return;
	end

	local count = chatFrame:GetChildCount();
	for  i = 0, count-1 do
		local child = chatFrame:GetChildByIndex(i);
		local childName = child:GetName();
		if childName:sub(1, 9) == "chatgbox_" then
			if child:GetClassName() == "groupbox" then

				child = tolua.cast(child, "ui::CGroupBox");

				if child:GetSkinName() ~= 'bg' then
					child:SetSkinName("bg");
				end

				if num == -1 then
					return;
				elseif num == 0 then
					num = 1;
				end

				local colorToneStr = string.format("%02X", num);
				colorToneStr = colorToneStr .. "000000";
				child:SetColorTone(colorToneStr);
			end
		end
	end

end


function CLASSICCHAT_ON_OPEN(frame)
	--PRIVATE.SetVersion(frame);

	CLASSICCHAT.InitializeSettings();
end

function CLASSICCHAT_ON_CLOSE(frame)
	g.save();
end

function CLASSICCHAT_ON_CHANGE_THEME(frame, ctrl, str, num)
	local g = _G['CLASSICCHAT'];

	local dropList = tolua.cast(ctrl, "ui::CDropList");
	
	local themeIndex = dropList:GetSelItemIndex();
	g.settings.theme = themeIndex == 0 and 'simple' or 'bubble';
	g.redraw();
	g.save();
end

function CLASSICCHAT_ON_SLIDE_FONTSIZE(frame, ctrl, str, num)
	local slider = tolua.cast(ctrl, "ui::CSlideBar");
	local size = slider:GetLevel();

	config.SetConfig("CHAT_FONTSIZE", size);
	CHAT_SET_FONTSIZE(size);

	local parent = ctrl:GetParent();
	local label = GET_CHILD(parent, "label_FontSize", "ui::CRichText");
	label:SetTextByKey("size", GET_CHAT_FONT_SIZE());
end

function CLASSICCHAT_ON_SLIDE_OPACITY(frame, ctrl, str, num)
	local slider = tolua.cast(ctrl, "ui::CSlideBar");
	local value = slider:GetLevel();
	
	local parent = ctrl:GetParent();
	local label = GET_CHILD(parent, "label_Transparency", "ui::CRichText");
	label:SetTextByKey("pct", string.format("%0.f%%", (value / 255) * 100));
	
	config.SetConfig("CLCHAT_OPACITY", value or 160);
	CHAT_SET_OPACITY(value or 160);

end

function CLASSICCHAT_ON_CHECKBOX(frame, obj, argStr, argNum)
	local g = _G['CLASSICCHAT'];
	local checkBox = tolua.cast(obj, "ui::CCheckBox");
	
	local isChecked = checkBox:IsChecked();
	local setting = obj:GetName():gsub('check_', '');
	g.settings[setting] = isChecked == 1 or false;
	g.save();
	if setting == 'timeStamp' then
		g.redraw()
	end
end

function CLASSICCHAT.InitializeSettings()
	local g = _G['CLASSICCHAT']
	local frame = ui.GetFrame('classicchat')

	local gBoxSettings = GET_CHILD(frame, "gbox_settings", "ui::CGroupBox");
	local gBoxChatDisplay = GET_CHILD(gBoxSettings, "gbox_ChatDisplay", "ui::CGroupBox");
	local gBoxAntiSpam = GET_CHILD(gBoxSettings, "gbox_AntiSpam", "ui::CGroupBox");
	
	-- Theme Dropdown List
	local dropListTheme = GET_CHILD(gBoxChatDisplay, "droplist_Theme", "ui::CDropList");
	dropListTheme:ClearItems();
	dropListTheme:AddItem(0, "Simple");
	dropListTheme:AddItem(1, "Bubble");

	-- Load stored theme
	dropListTheme:SelectItem(g.settings.theme == 'bubble' and 1 or 0);
	
	-- Font Size
	local sliderFontSize = GET_CHILD(gBoxChatDisplay, "slider_FontSize", "ui::CSlideBar");
	sliderFontSize:SetLevel(config.GetConfigInt("CHAT_FONTSIZE", 100));

	local labelFontSize = GET_CHILD(gBoxChatDisplay, "label_FontSize", "ui::CRichText");
	labelFontSize:SetTextByKey("size", GET_CHAT_FONT_SIZE());

	-- Transparency
	local sliderTransparency = GET_CHILD(gBoxChatDisplay, "slider_Transparency", "ui::CSlideBar");
	sliderTransparency:SetLevel(config.GetConfigInt("CLCHAT_OPACITY", 160));

	local labelTransparency = GET_CHILD(gBoxChatDisplay, "label_Transparency", "ui::CRichText");
	labelTransparency:SetTextByKey("pct", string.format("%0.f%%", (config.GetConfigInt("CLCHAT_OPACITY", 160) / 255) * 100));

	CHAT_SET_OPACITY(config.GetConfigInt("CLCHAT_OPACITY", 160));


	-- Timestamp
	local checkTimeStamp = GET_CHILD(gBoxChatDisplay, "check_timeStamp", "ui::CCheckBox");
	checkTimeStamp:SetCheck(g.settings.timeStamp and 1 or 0);
	
	-- Autohide Input
	local checkCloseOnSend = GET_CHILD(gBoxChatDisplay, "check_closeChatOnSend", "ui::CCheckBox");
	checkCloseOnSend:SetCheck(g.settings.closeChatOnSend and 1 or 0);

	-- Whisper Notice
	local checkWhisperNotice = GET_CHILD(gBoxChatDisplay, "check_whisperNotice", "ui::CCheckBox");
	checkWhisperNotice:SetCheck(g.settings.whisperNotice and 1 or 0);
	
	-- Friend Notice
	local checkFriendNotice = GET_CHILD(gBoxChatDisplay, "check_friendNotice", "ui::CCheckBox");
	checkFriendNotice:SetCheck(g.settings.friendNotice and 1 or 0);
	
	-- AntiSpam

	-- Spam Detection
	local checkSpamDetect = GET_CHILD(gBoxAntiSpam, "check_spamDetection", "ui::CCheckBox");
	checkSpamDetect:SetCheck(g.settings.spamDetection and 1 or 0);

	-- Spam Notice
	local checkSpamNotice = GET_CHILD(gBoxAntiSpam, "check_spamNotice", "ui::CCheckBox");
	checkSpamNotice:SetCheck(g.settings.spamNotice and 1 or 0);
	
	-- Auto Report
	local checkAutoReport = GET_CHILD(gBoxAntiSpam, "check_reportSpamBots", "ui::CCheckBox");
	checkAutoReport:SetCheck(g.settings.reportSpamBots and 1 or 0);

	-- Display Reason
	local checkBlockReason = GET_CHILD(gBoxAntiSpam, "check_blockReason", "ui::CCheckBox");
	checkBlockReason:SetCheck(g.settings.blockReason and 1 or 0);		

end

function CLASSICCHAT.formatMessage(msg, group)
	local name = msg:GetCommanderName();
	local isGM = (string.sub(name, 1, 3) == "GM_");
	local o = {
		id = msg:GetClusterID(),
		group = group,
		name = name,
		time = msg:GetTimeStr(),
		type = CLASSICCHAT.GetMessageType(msg),
		room = msg:GetRoomID(),
		text = msg:GetMsg(),
		unreadCount = msg:GetNotReadCount(),
		isGM = isGM,
	};

	return o;
end

function CLASSICCHAT.GetMessageType(msg)
	local messageType = msg:GetMsgType();
	if type(tonumber(messageType)) == "number" then
		return "Whisper";
	end
	return messageType;
end

function CLASSICCHAT.hasUrl(text)
	local g = _G['CLASSICCHAT'];
	if g.processUrls(text) ~= text or string.match(string.lower(text), g.botSpamTest) then
		return true;
	end
	return false;
end

-- Text is set to lowercase for easier detection
function CLASSICCHAT.filterMessage(text)
	local g = _G['CLASSICCHAT']
	-- TODO: Normalize text
	local weight = 0;
	local threshold = 5

	if g.hasUrl(text) then
		weight = 3;
	end

	for i = 1, #g.botSpamPatterns do
		local bsp = g.botSpamPatterns[i];
		if (string[bsp.type](text, bsp.pattern)) then
			weight = weight + bsp.weight;
			if weight >= threshold then
				return true;
			end
		end
	end

	return false;
end

function CLASSICCHAT.spamRemoval_Notice(msg)
	local g = _G['CLASSICCHAT'];
	local blockMsg = '';

	if g.settings.autoReport then
		blockMsg = blockMsg .. string.format("User %s has been blocked and reported for spam.", msg.name);
	else
		blockMsg = blockMsg .. string.format("User %s has been blocked for spam.", msg.name);
	end
	if g.settings.blockReason then
		blockMsg = blockMsg .. "{nl}Reason:{nl}"..msg.text:sub(1,50)..' ...';
	end

	CHAT_SYSTEM(blockMsg);
end

function CLASSICCHAT.isFriendOrGuildMember(name)
	return CLASSICCHAT.friendWhiteList[name] or CLASSICCHAT.guildWhiteList[name];
end

function CLASSICCHAT_ON_GUILD_INFO_UPDATE()
	CLASSICCHAT.RefreshGuildMembers();
end

function CLASSICCHAT_ON_UPDATE_FRIENDLIST()
	CLASSICCHAT.RefreshFriendList();
end

function CLASSICCHAT.RefreshGuildMembers()
	local list = session.party.GetPartyMemberList(PARTY_GUILD);
	local count = list:Count();
	
	CLASSICCHAT.guildWhiteList = {};
	for i = 0 , count - 1 do
		local partyMemberInfo = list:Element(i);
		local name = partyMemberInfo:GetName();
		
		CLASSICCHAT.guildWhiteList[name] = true;
	end
end

function CLASSICCHAT.RefreshFriendList()
	CLASSICCHAT.friendWhiteList = {};
	local num = session.friends.GetFriendCount(FRIEND_LIST_COMPLETE);
	for i = 0 , num - 1 do
		local f = session.friends.GetFriendByIndex(FRIEND_LIST_COMPLETE, i);
		local fInfo = f:GetInfo();
		local familyName = fInfo:GetFamilyName();
		
		CLASSICCHAT.friendWhiteList[familyName] = true;
		
		--CLASSICCHAT.NotifyFriendState(fInfo, familyName);
	end
end

function CLASSICCHAT.NotifyFriendState(fInfo, familyName)
	local g = _G['CLASSICCHAT'];
	g.friendLoginState = g.friendLoginState or {};

	if not g.friendLoginState[familyName] then
		g.friendLoginState[familyName] = {
			online = false,
		};
	end
	local isOnlinePrev = g.friendLoginState[familyName].online;
	local isOnlineCurr = (fInfo.mapID ~= 0 and fInfo.mapID ~= nil);
	--CHAT_SYSTEM(string.format("%s mapId: %s", familyName, fInfo.mapID));
	
	if isOnlinePrev ~= isOnlineCurr then
		if isOnlineCurr then
			CHAT_SYSTEM(string.format("%s has come online.", familyName));
			imcSound.PlaySoundEvent("travel_diary_1");
		else
			CHAT_SYSTEM(string.format("%s has gone offline.", familyName));
		end
	end
	g.friendLoginState[familyName].online = isOnlineCurr;
end

function CLASSICCHAT.clearBlocked()
	local cnt = session.friends.GetFriendCount(FRIEND_LIST_BLOCKED);
	local msg = '';
	for i = 0 , cnt - 1 do
		local f = session.friends.GetFriendByIndex(FRIEND_LIST_BLOCKED, i);	
		local aid = f:GetInfo():GetACCID();
			friends.RequestDelete(aid);
		msg = msg .. "{nl}Block Removed: "..f:GetInfo():GetFamilyName();
	end
	CHAT_SYSTEM(msg);
end


function CLASSICCHAT.chatlog(text)
	local acutil = require('acutil');
	local g = _G['CLASSICCHAT'];
	
	if g.lastMessage == text then
		return;
	end
	local file, error = io.open(path.GetDataPath() .. '..\\chatlog.txt', "a");
	if (error) then
		return false;
	else
		g.lastMessage = text;
		file:write(text.."\n");
		 io.close(file);
		 return true;
	end
end


function CLASSICCHAT.testfilter(text)
	print(tostring(CLASSICCHAT.filterMessage(text)));
end




--[[
function rel(txt)
	dofile('addon_d/classicchat/classicchat.lua');
	CLASSICCHAT_3SEC();
end


function testscp()
	local selCol = GET_SELECTED_COL();
	print(selCol);
end

function CLASSICCHAT.colorPicker()
	--local str = 'propname' -- child name
	--local strScp = string.format("EXEC_SET_COLOR(\"%s\", \"%s\" )", frame:GetName(), str);
	local strScp = 'testscp()';

	local x, y =  GET_MOUSE_POS();
	OPEN_COLORSELECT_DLG(strScp, '0000FF', x, y);
end
]]
