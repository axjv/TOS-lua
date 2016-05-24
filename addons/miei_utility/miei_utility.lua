_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['EVENTS'] = _G['ADDONS']['EVENTS'] or {};
_G['ADDONS']['EVENTS']['ARGS'] = _G['ADDONS']['EVENTS']['ARGS'] or {};

_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI']['utils'] = _G['ADDONS']['MIEI']['utils'] or {};

local utils = _G['ADDONS']['MIEI']['utils'];
utils.slashcommands = utils.slashcommands or {};

-- INIT
utils.addon:RegisterMsg("GAME_START_3SEC", "MIEI_UTILS_ON_GAME_START_3SEC");
-- /INIT

function MIEI_UTILS_ON_GAME_START_3SEC()
	local utils = _G['ADDONS']['MIEI']['utils'];
	g_uiChatHandler = "MIEI_UTILS_ON_UI_CHAT";
	_G["TOURNAMENT_GAME"] = utils.tournamentGameHooked;
end

function utils.tournamentGameHooked(isPlaying)

	local sysFrame = ui.GetFrame("sysmenu");
	local frame = ui.GetFrame("tournament_view");
	frame:SetUserValue("PLAYING", isPlaying);
	if isPlaying == 1 then
		frame:ShowWindow(0);
		SYSMENU_DELETE_QUEUE_BTN(sysFrame, "TOURNAMENT_VIEW");
		g_uiChatHandlerOn = nil;
	else
		-- frame:ShowWindow(1);

		local btn = SYSMENU_CREATE_QUEUE_BTN(sysFrame, "TOURNAMENT_VIEW", "button_collection", 1);
		local toggleScp = "ui.ToggleFrame('tournament_view')";
		btn:SetEventScript(ui.LBUTTONUP, toggleScp);
		g_uiChatHandlerOn = true;
	end
end

-- alternate chat hooks to avoid conflict with cwapi and lkchat
-- from cwapi
function MIEI_UTILS_ON_UI_CHAT(msg)
	local words = utils.splitString(msg);
	local cmd = table.remove(words,1);

	local fn = utils.slashcommands[cmd];
	if (fn ~= nil) then
		return fn(words);
	elseif g_uiChatHandlerOn == true then
		CHAT_TOURNAMENT(msg)
	end
end

-- from cwapi
function utils.splitString(s,type)
	if (not type) then type = ' '; end
	local words = {};
	local m = type;
	if (type == ' ') then m = "%S+" end;
	if (type == '.') then m = "%." end;
	for word in s:gmatch(m) do table.insert(words, word) end
	return words;
end

-- http://lua-users.org/wiki/SaveTableToFile
function utils.exportstring( s )
	s = string.format( "%q",s )
	-- to replace
	s = string.gsub( s,"\\\n","\\n" )
	s = string.gsub( s,"\r","\\r" )
	s = string.gsub( s,string.char(26),"\"..string.char(26)..\"" )
	return s
end
--// The Save Function
function utils.save(  tbl, filename, settingsComment )
	local charS,charE = "   ","\n"
	local file,err
	-- create a pseudo file that writes to a string and return the string
	if not filename then
		file =  { write = function( self,newstr ) self.str = self.str..newstr end, str = "" }
		charS,charE = "",""
	-- write table to tmpfile
	elseif filename == true or filename == 1 then
		charS,charE,file = "","",io.tmpfile()
	-- write table to file
	-- use io.open here rather than io.output, since in windows when clicking on a file opened with io.output will create an error
	else
		file,err = io.open( filename, "w" )
		if err then return _,err end
	end
	-- initiate variables for save procedure
	local tables,lookup = { tbl },{ [tbl] = 1 }
	file:write( settingsComment .. "return {"..charE )

	local table_names = {};

	for idx,t in ipairs( tables ) do
		local tablename = table_names[t] or '';
		if filename and filename ~= true and filename ~= 1 then
			file:write( "-- Settings: "..tablename..charE )
		end
		file:write( "{"..charE )
		local thandled = {}
		for i,v in ipairs( t ) do
			thandled[i] = true
			-- escape functions and userdata
			if type( v ) ~= "userdata" then
				-- only handle value
				if type( v ) == "table" then
					if not lookup[v] then
						table.insert( tables, v )
						lookup[v] = #tables
					end
					file:write( charS.."{"..lookup[v].."},"..charE )
				elseif type( v ) == "function" then
					file:write( charS.."loadstring("..utils.exportstring(string.dump( v )).."),"..charE )
				else
					local value =  ( type( v ) == "string" and utils.exportstring( v ) ) or tostring( v )
					file:write(  charS..value..","..charE )
				end
			end
		end
		for i,v in pairs( t ) do
			-- escape functions and userdata
			if (not thandled[i]) and type( v ) ~= "userdata" then
				-- handle index
				if type( i ) == "table" then
					if not lookup[i] then
						table.insert( tables,i )
						lookup[i] = #tables
					end
					file:write( charS.."[{"..lookup[i].."}]=" )
				else

					local index = ( type( i ) == "string" and "["..utils.exportstring( i ).."]" ) or string.format( "[%d]",i )
					table_names[v] = i;
					file:write( charS..index.."=" )
				end
				-- handle value
				if type( v ) == "table" then
					if not lookup[v] then
						table.insert( tables,v )
						lookup[v] = #tables
					end
					file:write( "{"..lookup[v].."},"..charE )
				elseif type( v ) == "function" then
					file:write( "loadstring("..utils.exportstring(string.dump( v )).."),"..charE )
				else
					local value =  ( type( v ) == "string" and utils.exportstring( v ) ) or tostring( v )
					file:write( value..","..charE )
				end
			end
		end
		file:write( "},"..charE..charE)
	end
	file:write( "}" )
	-- Return Values
	-- return stringtable from string
	if not filename then
		-- set marker for stringtable
		return file.str.."--|"
	-- return stringttable from file
	elseif filename == true or filename == 1 then
		file:seek ( "set" )
		-- no need to close file, it gets closed and removed automatically
		-- set marker for stringtable
		return file:read( "*a" ).."--|"
	-- close file and return 1
	else
		file:close()
		return 1
	end
end

--// The Load Function
function utils.load( tbl, sfile, settingsComment )
	local settingsFile=io.open(sfile,"r")
	if settingsFile~=nil then
		io.close(settingsFile)
	else 
		utils.save(tbl, sfile, settingsComment)
		CHAT_SYSTEM("Settings file created at " .. sfile);
		return tbl;
	end

	local tables, err, _
	-- catch marker for stringtable
	if string.sub( sfile,-3,-1 ) == "--|" then
		tables,err = loadstring( sfile )
	else
		tables,err = loadfile( sfile )
	end
	if err then 
		CHAT_SYSTEM (err);
		return tbl;
	end
	tables = tables()
	for idx = 1,#tables do
		local tolinkv,tolinki = {},{}
		for i,v in pairs( tables[idx] ) do
			if type( v ) == "table" and tables[v[1]] then
				table.insert( tolinkv,{ i,tables[v[1]] } )
			end
			if type( i ) == "table" and tables[i[1]] then
				table.insert( tolinki,{ i,tables[i[1]] } )
			end
		end
		-- link values, first due to possible changes of indices
		for _,v in ipairs( tolinkv ) do
			tables[idx][v[1]] = v[2]
		end
		-- link indices
		for _,v in ipairs( tolinki ) do
			tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
		end
	end

	local loadedSettings = tables[1];

	if loadedSettings.version < tbl.version then
		local version = tbl.version;
		for k,v in pairs(loadedSettings) do tbl[k] = v end
		tbl.version = version;
		utils.save(tbl, sfile, settingsComment);
		CHAT_SYSTEM("New settings have been added to the config, ver " .. tbl.version);
	else
		tbl = loadedSettings;
	end
	return tbl;
end

function utils.setupEvent(myAddon, functionName, myFunctionName)
	if _G['ADDONS']['EVENTS'][functionName .. "_OLD"] == nil then
		_G['ADDONS']['EVENTS'][functionName .. "_OLD"] =  _G[functionName];
	end

	local hookedFuncString = [[_G[']]..functionName..[['] = function(...)
		local function pack2(...) return {n=select('#', ...), ...} end
		local thisFuncName = "]]..functionName..[[";
		local result = pack2(pcall(_G['ADDONS']['EVENTS'][thisFuncName .. '_OLD'], ...));
		_G['ADDONS']['EVENTS']['ARGS'][thisFuncName] = {...};
		imcAddOn.BroadMsg(thisFuncName);
		return unpack(result, i, result.n);
	end
	]];
	
	pcall(loadstring(hookedFuncString));

	myAddon:RegisterMsg(functionName, myFunctionName);
end

function utils.eventArgs(eventMsg)
	return unpack(_G['ADDONS']['EVENTS']['ARGS'][eventMsg]);
end

