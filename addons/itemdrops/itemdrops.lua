-- todo: 
-- more research into whether filtering by owner is possible.. currently shows drops for any owner
-- find out why drops are sometimes not detected
-- better effects

-- use with https://github.com/TehSeph/tos-addons "Colored Item Names" for colored drop nametags

local addonName = "ITEMDROPS";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};
local g = _G['ADDONS']['MIEI'][addonName];

g.settings = {
	showGrade = true;				-- show item grade as text in the drop msg?
	showGroupName = true;			-- show item group name (e.g. "Recipe") in the drop msg?
	msgFilterGrade = "common";		-- only show messages for items of this grade and above, "common" applies msgs to all objects, "off" means msgs will be off
	effectFilterGrade = "common";	-- only draw effects for items of this grade and above, , "common" applies effects to all objects, "off" means effects will be off
	nameTagFilterGrade = "common";	-- only display name tag (as if you were pressing alt) for items of this grade and above, "common" applies to all objects, "off" means name tags will be off
	alwaysShowCards = true;			-- always show effects and msgs for exp cards
	alwaysShowGems = true;			-- always show effects and msgs for gems
	showSilverNameTag = true;		-- item name tags for silver drops
}

g.itemGrades = {
	"common",	 	-- white item
	"rare", 		-- blue item
	"epic", 		-- purple item
	"legendary", 	-- orange item
};

--F_light080_blue_loop
--

g.settings.effects ={
	["common"] = {
		name = "F_cleric_MagnusExorcismus_shot_burstup";
		scale = 2.5;
	};

	["rare"] = {
		name = "F_cleric_MagnusExorcismus_shot_burstup";
		scale = 2.5;
	};

	["epic"] = {
		name = "F_cleric_MagnusExorcismus_shot_burstup";
		scale = 2.5;
	};

	["legendary"] = {
		name = "F_cleric_MagnusExorcismus_shot_burstup";
		scale = 2.5;
	};
}

g.addon:RegisterMsg("MON_ENTER_SCENE", "ITEMDROPS_ON_MON_ENTER_SCENE")

function ITEMDROPS_ON_MON_ENTER_SCENE(frame, msg, str, handle)
	local g = _G['ADDONS']['MIEI']['ITEMDROPS'];

	local actor = world.GetActor(handle);
	if actor:GetObjType() == GT_ITEM then

		local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 100000, 'ALL');
		for i = 1, selectedObjectsCount do
			if GetHandle(selectedObjects[i]) == handle then

				local itemobj = GetClass("Item", selectedObjects[i].ClassName);
				local itemName = actor:GetName();
				local itemGrade = nil;
				local groupName = nil;
				local alwaysShow = false;

				if itemobj ~= nil then
					groupName = itemobj.GroupName;
					itemGrade = itemobj.ItemGrade;
					itemName = GET_FULL_NAME(itemobj);

					if groupName == "Recipe" then
						itemGrade = tonumber(GET_ITEM_ICON_IMAGE(itemobj):match("misc(%d)"))-1;
					elseif groupName == "Gem" and g.settings.alwaysShowGems == true then
						alwaysShow = true;
					elseif groupName == "Card" and g.settings.alwaysShowCards == true then
						alwaysShow = true;
					end
					if tostring(itemGrade) == "None" then
						itemGrade = 1;
					end
				end

				local filterGradeIndex = g.indexOf(g.itemGrades, g.settings.nameTagFilterGrade);
				if filterGradeIndex == nil and alwaysShow ~= true then
					if g.settings.nameTagFilterGrade ~= "off" then
						CHAT_SYSTEM("[itemDrops] invalid name tag filter grade");
					end
				elseif itemobj == nil or filterGradeIndex <= itemGrade or alwaysShow == true then
					if itemobj == nil and g.settings.showSilverNameTag ~= true then return end
					g.drawItemFrame(handle, itemName);
				end

				if itemobj ~= nil then
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
						CHAT_SYSTEM(string.format("Dropped%s%s %s", itemGradeMsg, groupNameMsg, g.linkitem(itemobj)));
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

function g.linkitem(itemobj)
	local imgheight = 30;
	local imgtag =  "";
	local imageName = GET_ITEM_ICON_IMAGE(itemobj);
	local imgtag = string.format("{img %s %d %d}", imageName, imgheight, imgheight);
	local properties = "";
	local itemName = GET_FULL_NAME(itemobj);

	if tostring(itemobj.RefreshScp) ~= "None" then
		_G[itemobj.RefreshScp](itemobj);
	end

	if itemobj.ClassName == 'Scroll_SkillItem' then		
		local sklCls = GetClassByType("Skill", itemobj.SkillType)
		itemName = itemName .. "(" .. sklCls.Name ..")";
		properties = GetSkillItemProperiesString(itemobj);
	else
		properties = GetModifiedProperiesString(itemobj);
	end

	if properties == "" then
		properties = 'nullval'
	end

	local itemrank_num = itemobj.ItemStar

	return string.format("{a SLI %s %d}{#0000FF}%s%s{/}{/}{/}", properties, itemobj.ClassID, imgtag, itemName);
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
