-- todo: 
-- more research into whether filtering by owner is possible.. currently shows drops for any owner
	-- timer until someone else' (grayed out) item becomes available to everyone
-- find out why drops are sometimes not detected
-- custom sounds by rarity upon drop

-- use with https://github.com/TehSeph/tos-addons "Colored Item Names" for colored drop nametags

local addonName = "ITEMDROPS";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};
local g = _G['ADDONS']['MIEI'][addonName];

if not g.loaded then
	g.settings = {
		showGrade = true;				-- show item grade as text in the drop msg?
		showGroupName = true;			-- show item group name (e.g. "Recipe") in the drop msg?
		msgFilterGrade = "common";		-- only show messages for items of this grade and above, "common" applies msgs to all objects, "off" means msgs will be off
		effectFilterGrade = "common";	-- only draw effects for items of this grade and above, , "common" applies effects to all objects, "off" means effects will be off
		nameTagFilterGrade = "common";	-- only display name tag (as if you were pressing alt) for items of this grade and above, "common" applies to all objects, "off" means name tags will be off
		alwaysShowCards = true;			-- always show effects and msgs for exp cards
		alwaysShowGems = true;			-- always show effects and msgs for gems
		showSilverNameTag = false;		-- item name tags for silver drops
	}

	g.itemGrades = {
		"common",	 	-- white item
		"rare", 		-- blue item
		"epic", 		-- purple item
		"legendary", 	-- orange item
		"set",			-- set piece
	};

	--F_light080_blue_loop
	--F_cleric_MagnusExorcismus_shot_burstup
	--F_magic_prison_line

	g.settings.effects ={
		["common"] = {
			name = "F_magic_prison_line_white";
			scale = 6;
		};

		["rare"] = {
			name = "F_magic_prison_line_blue";
			scale = 6;
		};

		["epic"] = {
			name = "F_magic_prison_line_dark";
			scale = 6;
		};

		["legendary"] = {
			name = "F_magic_prison_line_red";
			scale = 6;
		};
		["set"] = {
			name = "F_magic_prison_line_green";
			scale = 6;
		};
	}
end

g.settingsComment = [[%s
 Item Drops by Miei, settings file
 http://github.com/Miei/TOS-lua

showGrade			- show item grade as text in the drop msg?
showGroupName		- show item group name (e.g. "Recipe") in the drop msg?

msgFilterGrade		- only show messages for items of this grade and above, "common" applies msgs to all objects, "off" means msgs will be off
effectFilterGrade	- accepts "common", "rare", "epic", "legendary", "set", "off"
nameTagFilterGrade	- same as above two options but for name tags under items

alwaysShowCards		- always show effects and msgs for exp cards
alwaysShowGems		- always show effects and msgs for gems

showSilverNameTag	- item name tags for silver drops

%s

]];

g.settingsComment = string.format(g.settingsComment, "--[[", "]]");
g.settingsFileLoc = "../addons/miei/itemdrops-settings.lua";

--on init


--/init

-- INIT
	g.addon:RegisterMsg("GAME_START_3SEC", "ITEMDROPS_3SEC");
-- /INIT

function ITEMDROPS_3SEC()
	local g = _G["ADDONS"]["MIEI"]["ITEMDROPS"];
	local utils = _G["ADDONS"]["MIEI"]["utils"];

	if g.loaded ~= true then
		g.settings = utils.load(g.settings, g.settingsFileLoc, g.settingsComment);
		CHAT_SYSTEM('[itemDrops:help] /drops');
		g.loaded = true;
	end
	utils.slashcommands['/drops'] = g.processCommand;
	g.addon:RegisterMsg("MON_ENTER_SCENE", "ITEMDROPS_ON_MON_ENTER_SCENE")
end

function ITEMDROPS_ON_MON_ENTER_SCENE(frame, msg, str, handle)
	local g = _G['ADDONS']['MIEI']['ITEMDROPS'];

	local actor = world.GetActor(handle);
	if actor:GetObjType() == GT_ITEM then

		local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 100000, 'ALL');
		for i = 1, selectedObjectsCount do
			if GetHandle(selectedObjects[i]) == handle then

				local itemObj = GetClass("Item", selectedObjects[i].ClassName);
				local itemName = actor:GetName();
				local itemGrade = nil;
				local groupName = nil;
				local alwaysShow = false;

				if itemObj ~= nil then
					groupName = itemObj.GroupName;
					itemGrade = itemObj.ItemGrade;
					itemName = GET_FULL_NAME(itemObj);
					local itemProp = geItemTable.GetProp(itemObj.ClassID);

					if groupName == "Recipe" then
						itemGrade = itemObj.Icon:match("misc(%d)")-1;
					elseif groupName == "Gem" and g.settings.alwaysShowGems == true then
						alwaysShow = true;
					elseif groupName == "Card" and g.settings.alwaysShowCards == true then
						alwaysShow = true;
					elseif (itemProp.setInfo ~= nil) then 
						itemGrade = 5; -- set piece, credits TehSeph
					elseif tostring(itemGrade) == "None" then
						itemGrade = 1;
					end
				end

				local filterGradeIndex = g.indexOf(g.itemGrades, g.settings.nameTagFilterGrade);
				if filterGradeIndex == nil and alwaysShow ~= true then
					if g.settings.nameTagFilterGrade ~= "off" then
						CHAT_SYSTEM("[itemDrops] invalid name tag filter grade");
					end
				elseif itemObj == nil or filterGradeIndex <= itemGrade or alwaysShow == true then
					if itemObj == nil and g.settings.showSilverNameTag ~= true then return end
					g.drawItemFrame(handle, itemName);
				end

				if itemObj ~= nil then
					local itemGradeMsg = g.itemGrades[itemGrade];
					filterGradeIndex = g.indexOf(g.itemGrades, g.settings.effectFilterGrade);
					if filterGradeIndex == nil and alwaysShow ~= true then
						if g.settings.effectFilterGrade ~= "off" then
							CHAT_SYSTEM("[itemDrops] invalid effect filter grade");
						end
					elseif filterGradeIndex <= itemGrade or alwaysShow == true then
						local effect = g.settings.effects[itemGradeMsg];
						-- delay to allow the actor to finish it's falling animation..
						ReserveScript(string.format('pcall(effect.AddActorEffectByOffset(world.GetActor(%d) or 0, "%s", %d, 0))', handle, effect.name, effect.scale), 0.7);
					end

					filterGradeIndex = g.indexOf(g.itemGrades, g.settings.msgFilterGrade);

					if filterGradeIndex == nil and alwaysShow ~= true then
						if g.settings.msgFilterGrade ~= "off" then
							CHAT_SYSTEM("[itemDrops] invalid message filter grade");
						end
					elseif filterGradeIndex <= itemGrade or alwaysShow == true then
						groupNameMsg = " " .. groupName:lower();
						if g.settings.showGroupName ~= true then
							groupNameMsg = '';
						end
						
						local itemGradeMsg = " " .. itemGradeMsg;
						if g.settings.showGrade ~= true then
							itemGradeMsg = '';
						end
						CHAT_SYSTEM(string.format("Dropped%s%s %s", itemGradeMsg, groupNameMsg, g.linkitem(itemObj)));
					end
				end 
			end
		end	
	end
end

function g.drawItemFrame(handle, itemName)
	local itemFrame = ui.CreateNewFrame("itembaseinfo", "itembaseinfo_" .. handle);
	--
	local nameRichText = GET_CHILD(itemFrame, "name", "ui::CRichText");
	nameRichText:SetText(itemName);

	itemFrame:SetUserValue("_AT_OFFSET_HANDLE", handle);
	itemFrame:SetUserValue("_AT_OFFSET_X", -itemFrame:GetWidth() / 2);
	itemFrame:SetUserValue("_AT_OFFSET_Y", 3);
	itemFrame:SetUserValue("_AT_OFFSET_TYPE", 1);
	itemFrame:SetUserValue("_AT_AUTODESTROY", 1);

	-- makes frame blurry, see FRAME_AUTO_POS_TO_OBJ function
	--AUTO_CAST(itemFrame);
	--itemFrame:SetFloatPosFrame(true);

	_FRAME_AUTOPOS(itemFrame);
	itemFrame:RunUpdateScript("_FRAME_AUTOPOS");

	itemFrame:ShowWindow(1);
end

function g.linkitem(itemObj)
	local imgheight = 30;
	local imgtag =  "";
	local imageName = GET_ITEM_ICON_IMAGE(itemObj);
	local imgtag = string.format("{img %s %d %d}", imageName, imgheight, imgheight);
	local properties = "";
	local itemName = GET_FULL_NAME(itemObj);

	if tostring(itemObj.RefreshScp) ~= "None" then
		_G[itemObj.RefreshScp](itemObj);
	end

	if itemObj.ClassName == 'Scroll_SkillItem' then		
		local sklCls = GetClassByType("Skill", itemObj.SkillType)
		itemName = itemName .. "(" .. sklCls.Name ..")";
		properties = GetSkillItemProperiesString(itemObj);
	else
		properties = GetModifiedProperiesString(itemObj);
	end

	if properties == "" then
		properties = 'nullval'
	end

	local itemrank_num = itemObj.ItemStar

	return string.format("{a SLI %s %d}{#0000FF}%s%s{/}{/}{/}", properties, itemObj.ClassID, imgtag, itemName);
end


function g.processCommand(words)
	local g = _G["ADDONS"]["MIEI"]["ITEMDROPS"];
	local utils = _G["ADDONS"]["MIEI"]["utils"];
	local cmd = table.remove(words,1);
	local validFilterGrades = 'common, rare, epic, legendary, set, off';

	if not cmd then
		local msg = 'Item Drops{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/drops cards on/off{nl}';
		msg = msg .. 'Enable/disable always showing xp card drops.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/drops gems on/off{nl}';
		msg = msg .. 'Enable/disable always showing gem drops.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/drops silver on/off{nl}';
		msg = msg .. 'Enable/disable showing name tag for silver.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/drops msg [grade]{nl}';
		msg = msg .. 'Set the filter grade for chat messages{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/drops fx [grade]{nl}';
		msg = msg .. 'Set the filter grade for effects on dropped items{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/drops name [grade]{nl}';
		msg = msg .. 'Set the filter grade for item name tags{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/drops filter [grade]{nl}'
		msg = msg .. 'Set ALL filters to the specified item grade.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. 'Filter [grade] can be any of the following:{nl}';
		msg = msg .. validFilterGrades .. '{nl}';
		msg = msg .. 'With off meaning that the feature will be disabled.'

		return ui.MsgBox(msg,"","Nope");

	elseif cmd == 'cards' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			g.settings.alwaysShowCards = true;
			CHAT_SYSTEM("[itemDrops] Always show card drops enabled.")
		elseif cmd == 'off' then
			g.settings.alwaysShowCards = false;
			CHAT_SYSTEM("[itemDrops] Always show card drops disabled.")
		end

	elseif cmd == 'gems' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			g.settings.alwaysShowGems = true;
			CHAT_SYSTEM("[itemDrops] Always show gem drops enabled.")
		elseif cmd == 'off' then
			g.settings.alwaysShowGems = false;
			CHAT_SYSTEM("[itemDrops] Always show gem drops disabled.")
		end

	elseif cmd == 'silver' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			g.settings.showSilverNameTag = true;
			CHAT_SYSTEM("[itemDrops] Showing silver name tags.")
		elseif cmd == 'off' then
			g.settings.showSilverNameTag = false;
			CHAT_SYSTEM("[itemDrops] Hiding silver name tags.")
		end

	elseif cmd == 'filter' then
		cmd = table.remove(words,1);
		if g.checkFilterGrade(cmd) == true then -- check if valid filter grade
			g.settings.msgFilterGrade = cmd;
			g.settings.effectFilterGrade = cmd;
			g.settings.nameTagFilterGradee = cmd;
			CHAT_SYSTEM("[itemDrops] Setting all filters to: " .. cmd)
		else
			CHAT_SYSTEM("[itemDrops] Invalid filter grade. Valid filter grades are:");
			CHAT_SYSTEM(validFilterGrades);
		end

	elseif cmd == 'msg' then
		cmd = table.remove(words,1);
		if g.checkFilterGrade(cmd) == true then -- check if valid filter grade
			g.settings.msgFilterGrade = cmd;
			CHAT_SYSTEM("[itemDrops] Message filter set to: " .. cmd)
		else
			CHAT_SYSTEM("[itemDrops] Invalid filter grade. Valid filter grades are:");
			CHAT_SYSTEM(validFilterGrades);
		end

	elseif cmd == 'fx' then
		cmd = table.remove(words,1);
		if g.checkFilterGrade(cmd) == true then -- check if valid filter grade
			g.settings.effectFilterGrade = cmd;
			CHAT_SYSTEM("[itemDrops] Effect filter set to: " .. cmd)
		else
			CHAT_SYSTEM("[itemDrops] Invalid filter grade. Valid filter grades are:");
			CHAT_SYSTEM(validFilterGrades);
		end

	elseif cmd == 'name' then
		cmd = table.remove(words,1);
		if g.checkFilterGrade(cmd) == true then -- check if valid filter grade
			g.settings.nameTagFilterGrade = cmd;
			CHAT_SYSTEM("[itemDrops] Name tag filter set to: " .. cmd)
		else
			CHAT_SYSTEM("[itemDrops] Invalid filter grade. Valid filter grades are:");
			CHAT_SYSTEM(validFilterGrades);
		end


	else
		CHAT_SYSTEM('[itemDrops] Invalid input. Type "/drops" for help.');
	end
	utils.save(g.settings, g.settingsFileLoc, g.settingsComment);
end


function g.checkFilterGrade(text)
	if g.indexOf(g.itemGrades, text) ~= nil then
		return true;
	elseif text == "off" then
		return true;
	else 
		return false;
	end
end

function g.indexOf( t, object )
	local result = nil;

	if "table" == type( t ) then
		for i=1,#t do
			if object == t[i] then
				result = i;
				break;
			end
		end
	end

	return result;
end
