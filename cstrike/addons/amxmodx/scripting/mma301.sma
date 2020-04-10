#pragma semicolon 1
#include <amxmodx>
#include <amxmisc>

#define PLUGIN			"Music Menu Advance"
#define VERSION			"3.01"
#define AUTHOR			"Aoi.Kagase"

#define MEDIA_LIST		"bgmlist.ini"	// in configdir.

enum _:BGM
{
	MENU_TITLE	[MAX_NAME_LENGTH],
	FILE_PATH	[MAX_RESOURCE_PATH_LENGTH],
}
new Array:g_bgm;

new g_loadsong;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_loadsong = register_cvar("amx_mma_loadingsong", "1");

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
	new iniFile		[MAX_RESOURCE_PATH_LENGTH];
	new sConfigDir	[MAX_RESOURCE_PATH_LENGTH];
	new aBgm		[BGM];

	get_configsdir(sConfigDir, charsmax(sConfigDir));
	formatex(iniFile, charsmax(iniFile), "%s/%s", sConfigDir, MEDIA_LIST);

	load_bgm_files(iniFile);

	for(new i = 0; i < ArraySize(g_bgm); i++)
	{
		ArrayGetArray(g_bgm, i, aBgm, sizeof(aBgm));
		if (file_exists(aBgm[FILE_PATH], true))
		{
			precache_generic(aBgm[FILE_PATH]);
		}
	}
	server_print("Server BGMs Loaded (%i BGMs)", ArraySize(g_bgm));
}

load_bgm_files(sFileName[])
{ 
	if (!file_exists(sFileName))
		return;

	new sRec		[MAX_NAME_LENGTH + MAX_RESOURCE_PATH_LENGTH];
	new sBlock		[MAX_RESOURCE_PATH_LENGTH];
	new aBgm		[BGM];

	new sRecLen 	= charsmax(sRec);
	new	sBlockLen	= charsmax(sBlock);

	new fp 			= fopen(sFileName, "r");
	new iCount 		= 0;

	new i = 0, n = 0, iPos = 0;

	g_bgm = ArrayCreate(MAX_NAME_LENGTH + MAX_RESOURCE_PATH_LENGTH);

	while(!feof(fp))
	{
		if (fgets(fp, sRec, sRecLen) == 0)
			break;

		trim(sRec);
		formatex(sRec, sRecLen, "%s%s", sRec, ";");

		iPos = 0, n = 0, i = 0;
		while((i = split_string(sRec[n += i], ";", sBlock, sBlockLen)) != -1 && iPos <= 1)
		{
			trim(sBlock);

			if (iPos == 0)
			{
				formatex(aBgm[MENU_TITLE], charsmax(aBgm[MENU_TITLE]), "%s", sBlock);
				iPos++;
			} 
			else
			if (iPos == 1)
			{
				if (file_exists(sBlock, true))
				{
					formatex(aBgm[FILE_PATH], charsmax(aBgm[FILE_PATH]), "%s", sBlock);
					ArrayPushArray(g_bgm, aBgm);
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
	if(get_pcvar_num(g_loadsong))
	{
		if (!is_user_bot(id))
		{
			new sBgm[BGM];
			new j = random_num(0, ArraySize(g_bgm) - 1);
			ArrayGetArray(g_bgm, j, sBgm);
			client_cmd(id, "mp3 play %s", sBgm[FILE_PATH]);
		}
	}
	return PLUGIN_CONTINUE;
}

public server_bgm()
{
	new aBgm[BGM];
	new arg	[3];
	read_argv(1, arg, charsmax(arg));

	new num 	 = str_to_num(arg);
	new bgmCount = ArraySize(g_bgm);

	if (bgmCount <= 0)
	{
		server_print("BGM isn't registered.");
		return PLUGIN_HANDLED;
	} 
	else
	{
		if (num > 0 && num - 1 < bgmCount)
		{
			ArrayGetArray(g_bgm, num - 1, aBgm);
			// All Player Command.
			client_cmd(0, "mp3 stop");
			client_cmd(0, "mp3 play %s", aBgm[FILE_PATH]);
			client_print_color(0, print_chat, "^4[MMA] ^3ADMIN: BGM START! ^2[%s]", aBgm[MENU_TITLE]);
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
	new szPath	[MAX_RESOURCE_PATH_LENGTH + 6];
	new aBgm	[BGM];

    // Create a variable to hold the menu
	new menu = menu_create("Music Menu: BGM-List", "music_menu_handler");
	menu_additem(menu, "STOP BGM.", "stop", 0);
	for(new i = 0; i < ArraySize(g_bgm); i++)
	{
		ArrayGetArray(g_bgm, i, aBgm);
		formatex(szPath, charsmax(szPath), "play %s", aBgm[FILE_PATH]);
        // Add the item for this player
		menu_additem(menu, aBgm[MENU_TITLE], szPath, 0);
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
	new szData[MAX_RESOURCE_PATH_LENGTH + 6], szName[MAX_NAME_LENGTH];
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
	ArrayDestroy(g_bgm);
}