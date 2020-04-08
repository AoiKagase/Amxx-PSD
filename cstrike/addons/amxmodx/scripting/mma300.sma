#pragma semicolon 1
#include <amxmodx>
#include <amxmisc>

#define PLUGIN			"Music Menu Advance"
#define VERSION			"3.00"
#define AUTHOR			"Aoi.Kagase"

#define MEDIA_LIST		"bgmlist.ini"	// in configdir.

#define MAX_LIST		16

enum BGM
{
	MENU_TITLE = 0,
	FILE_PATH,
}
new g_bgm_title	[MAX_LIST][MAX_NAME_LENGTH];
new g_bgm_path	[MAX_LIST][MAX_RESOURCE_PATH_LENGTH];
new g_bgm_count;
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

public plugin_cfg()
{
	new configDir	[MAX_RESOURCE_PATH_LENGTH];
	new iniFile		[MAX_RESOURCE_PATH_LENGTH];

	get_localinfo("amxx_configsdir", configDir, charsmax(configDir));
	formatex(iniFile, charsmax(iniFile), "%s/%s", configDir, MEDIA_LIST);

	load_bgm_files(iniFile);
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
	for(new i = 0; i < sizeof(g_bgm_path); i++)
	{
		if (file_exists(g_bgm_path[i]))
		{
			precache_generic(g_bgm_path[i]);
		}
	}
}

load_bgm_files(sFileName[])
{ 
	if (!file_exists(sFileName))
		return;

	new i = 0, n = 0, iPos = 0;

	new sRec	[MAX_NAME_LENGTH + MAX_RESOURCE_PATH_LENGTH];
	new sBlock	[MAX_RESOURCE_PATH_LENGTH];
	new sRecLen 	= charsmax(sRec);
	new	sBlockLen	= charsmax(sBlock);

	new iLine = 0, iCount = 0, iLen;

	while(read_file(sFileName, iLine++, sRec, sRecLen, iLen) && iCount < MAX_LIST)
	{
		replace_all(sRec, sRecLen,  " ", ",");
		replace_all(sRec, sRecLen, "^t", ",");
		formatex(sRec, sRecLen, "%s%s", sRec, ",");
		iPos = 0, n = 0, i = 0;
		while((i = split_string(sRec[n += i], ",", sBlock, sBlockLen)) != -1 && BGM:iPos <= FILE_PATH)
		{

			switch(BGM:iPos++)
			{
				case MENU_TITLE:
					formatex(g_bgm_title[iCount], MAX_NAME_LENGTH - 1, "%s", sBlock);
				case FILE_PATH:
				{
					formatex(sBlock, sBlockLen, "%s", sBlock);
					if (file_exists(sBlock, true))
					{
						formatex(g_bgm_path[iCount++], MAX_RESOURCE_PATH_LENGTH - 1, "%s", sBlock);
					}
					else
					{
						server_print("File not exists: %s", sBlock);
						continue;
					}
				}
			}
		}
	}
	g_bgm_count = iCount;
	server_print("Server BGMs Loaded (%i BGMs)", iCount);
} 

public client_connect(id)
{
	if(get_pcvar_num(g_loadsong))
	{
		if (!is_user_bot(id))
		{
			new j = random_num(0, g_bgm_count - 1);
			client_cmd(id, "mp3 play %s", g_bgm_path[j]);
		}
	}
	return PLUGIN_CONTINUE;
}

public server_bgm()
{
	new arg[3];
	read_argv(1, arg, charsmax(arg));
	new num = str_to_num(arg);
	if (g_bgm_count <= 0)
	{
		server_print("BGM isn't registered.");
		return PLUGIN_HANDLED;
	} 
	else
	{
		if (num > 0 && num - 1 < g_bgm_count)
		{
			// All Player Command.
			client_cmd(0, "mp3 stop");
			client_cmd(0, "mp3 play %s", g_bgm_path[num - 1]);

			client_print_color(0, print_chat, "^4[MMA] ^3ADMIN: BGM START! ^2[%s]", g_bgm_title[num - 1]);
		}
		else
		{
			server_print("BGM isn't registered in this number.");
		}
	}
	return PLUGIN_HANDLED;
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
	new szData[MAX_RESOURCE_PATH_LENGTH], szName[MAX_NAME_LENGTH];
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

//====================================================
// Main menu.
//====================================================
music_showmenu(id)
{
    // Some variables to hold information about the players
	new szPath[MAX_RESOURCE_PATH_LENGTH];

    // Create a variable to hold the menu
	new menu = menu_create("Music Menu: BGM-List", "music_menu_handler");

	menu_additem(menu, "STOP BGM.", "stop", 0);
	for(new i = 0; i < sizeof(g_bgm_title); i++)
	{
		formatex(szPath, MAX_RESOURCE_PATH_LENGTH - 1, "play %s", g_bgm_path[i]);
        // Add the item for this player
		menu_additem(menu, g_bgm_title[i], szPath, 0);
    }
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");

    // We now have all players in the menu, lets display the menu
	menu_display(id, menu, 0);
}
