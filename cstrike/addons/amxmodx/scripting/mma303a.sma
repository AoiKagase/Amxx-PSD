//#pragma semicolon 1
#include <amxmodx>
#include <amxmisc>
#include <cromchat>

//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 182
	#assert "AMX Mod X v1.8.2 or greater library required!"
#endif

#define PLUGIN			"Music Menu Advance"
#define VERSION			"3.03a"
#define AUTHOR			"Aoi.Kagase"

#define MEDIA_LIST		"bgmlist.ini"	// in configdir.

new Array:g_menu_title;
new Array:g_file_path;

new g_loadsong;
new gc_loadsong;

stock split_string_amxx(const szSource[], const szDelim[], szParsed[], iMaxChars)
{
    new iPos = strfind(szSource, szDelim);
    return (iPos > -1) ? copy(szParsed, min(iPos, iMaxChars), szSource) + strlen(szDelim) : -1;
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

#if AMXX_VERSION_NUM < 190
	g_loadsong  = register_cvar("amx_mma_loadingsong", "1");
	gc_loadsong = get_pcvar_num(g_loadsong);
#else
	g_loadsong  = create_cvar("amx_mma_loadingsong", "1");
	bind_pcvar_num(g_loadsong, gc_loadsong);
#endif
	// Add your code here...
	register_clcmd("mma", "cmdBgmMenu", -1, " - shows a menu of a Music commands");
	register_clcmd("say", "say_mma");

	register_concmd("amx_mma_play", "server_bgm", ADMIN_ADMIN, "amx_mma_play <BgmNumber> | server bgm starting");

}

//====================================================
// Chat command.
//====================================================
public say_mma(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;

	new said[32];
	read_argv(1, said, charsmax(said));
	
	if (equali(said,"/bgm") 
	||	equali(said,"/mma"))
	{
		music_showmenu(id);
	}  
	return PLUGIN_CONTINUE;
}

public cmdBgmMenu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;

	music_showmenu(id);
	return PLUGIN_HANDLED;
}

public plugin_precache()
{
	new iniFile		[64];
	new sConfigDir	[64];
	new aFilePath	[64];

	get_configsdir(sConfigDir, charsmax(sConfigDir));
	formatex(iniFile, charsmax(iniFile), "%s/%s", sConfigDir, MEDIA_LIST);

	load_bgm_files(iniFile);

	for(new i = 0; i < ArraySize(g_file_path); i++)
	{
		ArrayGetString(g_file_path, i, aFilePath, sizeof(aFilePath));
#if AMXX_VERSION_NUM < 190
		if (file_exists(aFilePath))
#else
		if (file_exists(aFilePath, true))
#endif
		{
			precache_generic(aFilePath);
		}
	}
	server_print("Server BGMs Loaded (%i BGMs)", ArraySize(g_file_path));
}

load_bgm_files(sFileName[])
{ 
	if (!file_exists(sFileName))
		return;

	new sRec		[32 + 64];
	new sBlock		[64];
	new aMenuTitle	[32];
	new aFilePath	[64];

	new sRecLen 	= charsmax(sRec);
	new	sBlockLen	= charsmax(sBlock);

	new fp 			= fopen(sFileName, "r");
	new iCount 		= 0;

	new i = 0, n = 0, iPos = 0;

	g_menu_title 	= ArrayCreate(32);
	g_file_path		= ArrayCreate(64);

	while(!feof(fp))
	{
		if (fgets(fp, sRec, sRecLen) == 0)
			break;

		trim(sRec);
		formatex(sRec, sRecLen, "%s%s", sRec, ";");

		iPos = 0, n = 0, i = 0;

		while((i = split_string_amxx(sRec[n += i], ";", sBlock, sBlockLen)) != -1 && iPos <= 1)
		{
			trim(sBlock);

			if (iPos == 0)
			{
				formatex(aMenuTitle, charsmax(aMenuTitle), "%s", sBlock);
				iPos++;
			} 
			else
			if (iPos == 1)
			{
#if AMXX_VERSION_NUM < 190
				if (file_exists(aFilePath))
#else
				if (file_exists(sBlock, true))
#endif
				{
					formatex(aFilePath, charsmax(aFilePath), "%s", sBlock);
					ArrayPushArray(g_menu_title,aMenuTitle);
					ArrayPushArray(g_file_path,	aFilePath);
					iCount++;
				}
				else
				{
					server_print("File not exists: %s", sBlock);
					continue;
				}
				
			}
		}
	}
	fclose(fp);
} 

public client_connect(id)
{
	if(gc_loadsong)
	{
		if (!is_user_bot(id))
		{
			new sBgm[64];
			new j = random_num(0, ArraySize(g_file_path) - 1);
			ArrayGetString(g_file_path, j, sBgm, charsmax(sBgm));
			client_cmd(id, "mp3 play %s", sBgm);
		}
	}
	return PLUGIN_CONTINUE;
}

public server_bgm()
{
	new aMenuTitle	[32];
	new aFilePath	[64];
	new arg			[3];
	read_argv(1, arg, charsmax(arg));

	new num 	 = str_to_num(arg);
	new bgmCount = ArraySize(g_menu_title);

	if (bgmCount <= 0)
	{
		server_print("BGM isn't registered.");
		return PLUGIN_HANDLED;
	} 
	else
	{
		if (0 < num <= bgmCount)
		{
			ArrayGetString(g_file_path, num - 1, aFilePath, charsmax(aFilePath));
			// All Player Command.
			client_cmd(0, "mp3 stop");
			client_cmd(0, "mp3 play %s", aFilePath);
			client_print_color(0, print_chat, "^4[MMA] ^3ADMIN: BGM START! ^2[%s]", aMenuTitle);
		}
		else
		{
			server_print("BGM isn't registered in this number.");
		}
	}
	return PLUGIN_HANDLED;
}

//====================================================
// Main menu.
//====================================================
music_showmenu(id)
{
    // Some variables to hold information about the players
	new szPath		[64 + 6];
	new aMenuTitle	[32];
	new aFilePath	[64];

    // Create a variable to hold the menu
	new menu = menu_create("Music Menu: BGM-List", "music_menu_handler");
	menu_additem(menu, "STOP BGM.", "stop", 0);
	for(new i = 0; i < ArraySize(g_menu_title); i++)
	{
		ArrayGetString(g_menu_title, i, aMenuTitle, charsmax(aMenuTitle));
		ArrayGetString(g_file_path,  i, aFilePath,	charsmax(aFilePath));
		formatex(szPath, charsmax(szPath), "play %s", aFilePath);
        // Add the item for this player
		menu_additem(menu, aMenuTitle, szPath, 0);
    }
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");

    // We now have all players in the menu, lets display the menu
	menu_display(id, menu, 0);
}

public music_menu_handler(id, menu, item)
{
	// Do a check to see if they exited because menu_item_getinfo ( see below ) will give an error if the item is MENU_EXIT
	if (item == MENU_EXIT)
	{
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }
		
	// now lets create some variables that will give us information about the menu and the item that was pressed/chosen
	new szData[64 + 6], szName[32];
	new _access, item_callback;
	// heres the function that will give us that information ( since it doesnt magicaly appear )
	menu_item_getinfo(menu, item, _access, szData, charsmax(szData), szName, charsmax(szName), item_callback);

	client_cmd(id, "mp3 %s", szData);

	if (equali("stop", szData))
		client_print_color(id, print_chat, "^4[MMA] ^1BGM Stopped.");
	else
		client_print_color(id, print_chat, "^4[MMA] ^1BGM Start!:^3[%s]", szName);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public plugin_end()
{
	ArrayDestroy(g_menu_title);
	ArrayDestroy(g_file_path);
}