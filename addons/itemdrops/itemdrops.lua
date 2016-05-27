-- todo: 
-- more research into whether filtering by owner is possible.. currently shows drops for any owner

local addonName = "ITEMDROPS";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};
local g = _G['ADDONS']['MIEI'][addonName];

g.settings = {
	showGrade = true;				-- show item grade as text in the drop msg?
	showGroupName = true;			-- show item group name (e.g. "Recipe") in the drop msg?
	msgFilterGrade = "rare";		-- only show messages for items of this grade and above, "common" applies msgs to all objects, "off" means msgs will be off
	effectFilterGrade = "rare"; 	-- only draw effects for items of this grade and above, "common" applies effects to all objects, "off" means effects will be off
	alwaysShowCards = true;			-- always show effects and msgs for exp cards
	alwaysShowGems = true;			-- always show effects and msgs for gems
}

g.itemGrades = {
	"common",	 	-- white item
	"rare", 		-- blue item
	"epic", 		-- purple item
	"legendary", 	-- orange item
};

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
	local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 100000, 'ALL');
	for i = 1, selectedObjectsCount do
	    if GetHandle(selectedObjects[i]) ~= handle then return end;
	    local actor = world.GetActor(handle);
		if actor ~= nil then
			local itemobj = GetClass("Item", selectedObjects[i].ClassName);
			if itemobj ~= nil then
				local itemGrade = itemobj.ItemGrade;
				if tostring(itemGrade) == "None" then
					itemGrade = 1;
				end

				local alwaysShow = false;
				local groupName = itemobj.GroupName;
				if groupName == "Recipe" then
					local recipeGrade = GET_ITEM_ICON_IMAGE(itemobj):match("misc(%d)");
					itemGrade = tonumber(recipeGrade)-1;
				elseif groupName == "Gem" and g.settings.alwaysShowGems == true then
					alwaysShow = true;
				elseif groupName == "Card" and g.settings.alwaysShowCards == true then
					alwaysShow = true;
				end

				local itemGradeMsg = g.itemGrades[itemGrade];
				local filterGradeIndex = g.indexOf(g.itemGrades, g.settings.effectFilterGrade);
				filterGradeIndex = g.indexOf(g.itemGrades, g.settings.effectFilterGrade);
				if filterGradeIndex == nil and alwaysShow ~= true then
					if g.settings.effectFilterGrade ~= "off" then
						CHAT_SYSTEM("[itemDrops] invalid effect filter grade");
					end
				elseif filterGradeIndex <= itemGrade or alwaysShow == true then
					local effect = g.settings.effects[itemGradeMsg];
					-- delay to allow the actor to finish it's falling animation..
					ReserveScript(string.format('pcall(effect.AddActorEffectByOffset(world.GetActor(%d) or 0, "%s", %d, 0))', handle, effect.name, effect.scale), 0.6);
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
