#pragma semicolon 1
/*
-=MONEY-GIVE=- 

Each player can be Money Give to other players.

================================================ 

-=VERSIONS=- 

Releaseed(Time in JP)	Version 	comment 
------------------------------------------------ 
2005.01.29		1.02		main release 
2005.01.29		1.03		Rename
2005.03.11		1.04		Can donate to the immunity.
							Bot was stopped in the reverse.
2006.03.15		1.05		Any bugfix
2020.03.20		2.00		Rewriten New menu system.
							change cvars and cmds.
================================================ 

-=INSTALLATION=- 

Compile and install plugin. (configs/plugins.ini) 
================================================ 

-=USAGE=- 

Client command: say /mg or /mgive
	- show money give menu.
	  select player => select money value. give to other player.

Server Cvars: 
	- amx_mgive		 			// enable this plugin. 0 = off, 1 = on.
	- amx_mgive_acs 			// Menu access level. 0 = all, 1 = admin only.
	- amx_mgive_max 			// A limit of amount of money to have. default $16000
	- amx_mgive_menu_enemies	// menu display in enemies. 0 = off, 1 = on.
	- amx_mgive_menu_bots		// menu display in bots. 0 = off, 1 = on.
	- amx_mgive_bots_action		// The bot gives money to those who have the least money. 0 = off, 1 = on.
								// (Happens when bot kill someone and exceed your maximum money.)
================================================ 

-=SpecialThanks=-
Idea	Mr.Kaseijin
Tester	Mr.Kaseijin
		orutiga
		justice

================================================
*/
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

/*=====================================*/
/*  VERSION CHECK				       */
/*=====================================*/
#if AMXX_VERSION_NUM < 183
	#assert "AMX Mod X v1.8.3 or greater library required!"
#endif

/*=====================================*/
/*  MACRO AREA					       */
/*=====================================*/
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define AUTHOR 						"Aoi.Kagase"
#define PLUGIN 						"MONEY-GIVE"
#define VERSION 					"2.00"

#define CHAT_TAG 					"[MONEY-GIVE]"
#define CVAR_TAG					"amx_mgive"

// ADMIN LEVEL
#define ADMIN_ACCESSLEVEL			ADMIN_LEVEL_H

#define OFFSET_TEAM 				114
#define OFFSET_MONEY				115

#define cs_get_user_team(%1)		CsTeams:get_pdata_int(%1,OFFSET_TEAM)
#define cs_get_user_money(%1)		get_pdata_int(%1,OFFSET_MONEY)

//====================================================
// ENUM AREA
//====================================================
//
// CVAR SETTINGS
//
enum CVAR_SETTING
{
	CVAR_ENABLE             = 0,    // Plugin Enable.
	CVAR_ACCESS_LEVEL       = 1,    // Access level for 0 = ADMIN or 1 = ALL.
	CVAR_MAX_MONEY			= 2,	// Max have money. default:$16000
	CVAR_ENEMIES			= 3,	// Menu display in Enemiy team.
	CVAR_BOTS_MENU			= 4,	// Bots in menu. 0 = none, 1 = admin, 2 = all.
	CVAR_BOTS_ACTION		= 5,	// Bots give money action.
}

new gCvar[CVAR_SETTING];
new int:gMoneyValues[]		= {
							int:100,
							int:500,
							int:1000,
							int:5000,
							int:10000,
							int:15000,
};
new gMsgMoney;

/*=====================================*/
/*  STOCK FUNCTIONS				       */
/*=====================================*/
//
// Get User Team Name
//
stock cs_get_user_team_name(id)
{
	new team[3];
	// Witch your team?
	switch(CsTeams:cs_get_user_team(id))
	{
		case CS_TEAM_CT: team = "CT";
		case CS_TEAM_T : team = "T";
		default:
			team = "";
	}
	return team;
}

//
// IS User in Team ?
//
stock bool:is_user_in_team(id)
{
	return strlen(cs_get_user_team_name(id)) > 0;
}

// CS_SET_USER_MONEY
stock cs_set_user_money(id, iMoney, iFlash = 1)
{
	set_pdata_int(id, OFFSET_MONEY, iMoney);

	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, gMsgMoney, {0, 0, 0}, id);
	write_long(iMoney);
	write_byte(iFlash ? 1 : 0);	// Flash (difference between new and old money)
	message_end();
}

public plugin_init() 
{ 
	register_plugin(PLUGIN, VERSION, AUTHOR); 

	register_clcmd("say", "say_mg");
	register_clcmd("say_team", "say_mg");

	// CVar settings.
	new cvar_command[32] = "^0";
	format(cvar_command, 31, "%s", CVAR_TAG);
	gCvar[CVAR_ENABLE]	        = register_cvar(cvar_command,   "1");   	// 0 = off, 1 = on.

	format(cvar_command, 31, "%s%s", CVAR_TAG, "_acs");
	gCvar[CVAR_ACCESS_LEVEL]   	= register_cvar(cvar_command,   "0");   	// 0 = all, 1 = admin

	format(cvar_command, 31, "%s%s", CVAR_TAG, "_max");
	gCvar[CVAR_MAX_MONEY]		= register_cvar(cvar_command, 	"16000");	// Max have money. 

	format(cvar_command, 31, "%s%s", CVAR_TAG, "_menu_enemies");
	gCvar[CVAR_ENEMIES]			= register_cvar(cvar_command, 	"0");		// enemies in menu. 

	format(cvar_command, 31, "%s%s", CVAR_TAG, "_menu_bots");
	gCvar[CVAR_BOTS_MENU]		= register_cvar(cvar_command, 	"0");		// Bots in menu. 

	format(cvar_command, 31, "%s%s", CVAR_TAG, "_bots_action");
	gCvar[CVAR_BOTS_ACTION]		= register_cvar(cvar_command, 	"0");		// Bots action. 

	// Bots Action
	register_event("DeathMsg", "bots_action", "a");

	// Money Message.
	gMsgMoney 					= get_user_msgid("Money");

	return PLUGIN_CONTINUE;
} 

//====================================================
// Main menu.
//====================================================
public mg_player_menu(id) 
{
	if (!check_admin(id))
		return PLUGIN_HANDLED;

	if (!check_in_team(id))
		return PLUGIN_HANDLED;

    // Create a variable to hold the menu
	new menu = menu_create("Money-Give Menu:", "mg_player_menu_handler");

    // We will need to create some variables so we can loop through all the players
	new players[MAX_PLAYERS], pnum, tempid;

    // Some variables to hold information about the players
	new szName[32], szUserId[32], szMenu[32], szListFlags[3];
	//new int:money;

    // Fill players with available players
	// Optional list of filtering flags:
	// "a" - do not include dead clients		x
	// "b" - do not include alive clients		x
	// "c" - do not include bots				O
	// "d" - do not include human clients		x
	// "e" - match with team					O
	// "f" - match with part of name			x
	// "g" - match case insensitive				x
	// "h" - do not include HLTV proxies		O
	// "i" - include connecting clients			x
	const SIZE = 3;
	new len = 0;
	// display in bots
	if (get_pcvar_num(gCvar[CVAR_BOTS_MENU]) == 0)
	{
		len += formatex(szListFlags[len], SIZE - len, "c");
	}
	// display in enemies.
	if (get_pcvar_num(gCvar[CVAR_ENEMIES]) == 0) 
	{
		len += formatex(szListFlags[len], SIZE - len, "e");
	}
	// don't include HLTV proxies
	len += formatex(szListFlags[len], SIZE - len, "h");

	// Get Players
	get_players( players, pnum, szListFlags, cs_get_user_team_name(id));

    //Start looping through all players
	for ( new i; i<pnum; i++ )
	{
		//Save a tempid so we do not re-index
		tempid = players[i];

        //Get the players name and userid as strings
		get_user_name(tempid, szName, charsmax(szName));
        //We will use the data parameter to send the userid, so we can identify which player was selected in the handler
		formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
		formatex(szMenu, charsmax(szMenu), "%12s^t\y[$%6d]", szName, cs_get_user_money(tempid));

        //Add the item for this player
		menu_additem(menu, szMenu, szUserId, 0);
    }

    //We now have all players in the menu, lets display the menu
	menu_display( id, menu, 0 );
	return PLUGIN_HANDLED;
}

//====================================================
// Main menu handler.
//====================================================
public mg_player_menu_handler(id, menu, item)
{
	//Do a check to see if they exited because menu_item_getinfo ( see below ) will give an error if the item is MENU_EXIT
	if (item == MENU_EXIT)
	{
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }

	//now lets create some variables that will give us information about the menu and the item that was pressed/chosen
	new szData[6], szName[64];
	new _access, item_callback;
	//heres the function that will give us that information ( since it doesnt magicaly appear )
	menu_item_getinfo( menu, item, _access, szData, charsmax(szData), szName, charsmax(szName), item_callback);

    //Get the userid of the player that was selected
	new userid = str_to_num(szData);

    //Try to retrieve player index from its userid
	new player = find_player("k", userid); // flag "k" : find player from userid

    //If player == 0, this means that the player's userid cannot be found
    //If the player is still alive ( we had retrieved alive players when formating the menu but some players may have died before id could select an item from the menu )
	if (player && is_user_connected(player))
		mg_money_menu(id, player);

	menu_destroy(menu);
	return PLUGIN_HANDLED;	
}

//====================================================
// Sub menu.
//====================================================
public mg_money_menu(id, player)
{
	new menu = menu_create("Choose Money Value.:", "mg_money_menu_handler");
	new szValue[16];
	new i;
	new szPlayer[3];
	num_to_str(player, szPlayer, charsmax(szPlayer));

	for(i = 0;i < sizeof(gMoneyValues); i++)
	{
		formatex(szValue, charsmax(szValue), "^t$%6d", gMoneyValues[i]);
		menu_additem(menu, szValue,	szPlayer, 0);
	}
	menu_display(id, menu, 0);
}

//====================================================
// Sub menu handler.
//====================================================
public mg_money_menu_handler(id, menu, item)
{
	new acces, player, callback, s_tempid[2], s_itemname[64];
	menu_item_getinfo(menu, item, acces, s_tempid, 2, s_itemname, 63, callback);

	player = str_to_num(s_tempid);

	switch(item)
	{
		case MENU_EXIT:
			if (is_user_connected(id))
				mg_player_menu(id);
		default:
		{
			new int:maxMoney = int:get_pcvar_num(gCvar[CVAR_MAX_MONEY]);// MAX
			new int:youMoney = int:cs_get_user_money(id);				// You
			new int:hisMoney = int:cs_get_user_money(player);			// He

			new int:givMoney = int:gMoneyValues[item];
			new oppName[32];
			new youName[32];

			get_user_name(player, oppName, charsmax(oppName));
			get_user_name(id, youName, charsmax(youName));

			// don't enough!
			if (youMoney < givMoney) 
			{
				client_print_color(id, print_chat, "^3%s You don't have enough money to gaving!", CHAT_TAG);
				return PLUGIN_HANDLED;
			}
			// his max have money.
			if (maxMoney < hisMoney + givMoney)
			{
				youMoney -= (maxMoney - hisMoney);
				hisMoney  = maxMoney;
			}
			// give.
			else
			{
				youMoney -= givMoney;
				hisMoney += givMoney;
			}

			cs_set_user_money(id, youMoney);
			cs_set_user_money(player, hisMoney);
			client_print_color(id, print_chat, "^4%s ^1$%d was give to ^3^"%s^".", CHAT_TAG, givMoney, oppName);
			client_print_color(player, print_chat, "^4%s ^1$%d was give from ^3^"%s^".", CHAT_TAG, givMoney, youName);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

//====================================================
// Chat command.
//====================================================
public say_mg(id)
{
	if(!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	if (!check_admin(id))
		return PLUGIN_HANDLED;

	new said[32];
	read_argv(1, said, 31);
	
	if (equali(said,"/mg") 
	||	equali(said,"/mgive"))
	{
		mg_player_menu(id);
	}  

	if (containi(said, "give")	!= -1 
	||	containi(said, "money")	!= -1)
	{
		client_print_color(id, print_chat, "^4%s ^1/mg or /mgive is show money give menu", CHAT_TAG);
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Check Logic.
//====================================================
bool:check_admin(id)
{
	if (get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]) != 0)
		return (get_user_flags(id) | ADMIN_ACCESSLEVEL) != 0;

	return true;
}

bool:check_in_team(id)
{
	if (get_pcvar_num(gCvar[CVAR_ENEMIES]) != 0)
		return is_user_in_team(id);

	return true;
}

//====================================================
// Bots Action.
//====================================================
public bots_action(id)
{
	new killer = read_data(1); // The killer data
	// new victim = read_data(2); // The victim data
	
	if (is_user_connected(killer) && is_user_bot(killer))
	{	new int:maxMoney = int:get_pcvar_num(gCvar[CVAR_MAX_MONEY]);
		new int:tgtMoney = maxMoney;
		new int:botMoney = int:cs_get_user_money(killer);

		new players[MAX_PLAYERS], pnum, target;
		new int:temp;
		const int:botGive = int:500;
		if (botMoney >= maxMoney)
		{
			get_players(players, pnum, "ceh", cs_get_user_team_name(killer));
			
			// get minimun money have player.
			for(new i = 0; i < pnum; i++)
			{
				temp = int:cs_get_user_money(players[i]);
				if (tgtMoney > temp)
				{
					tgtMoney = temp;
					target	 = players[i];
				}
			}

			// his max have money.
			if (maxMoney < tgtMoney + botGive)
			{
				botMoney = (maxMoney - tgtMoney);
				tgtMoney = maxMoney;
			}
			// give.
			else
			{
				botMoney -= botGive;
				tgtMoney += botGive;
			}

			new botName[32];
			get_user_name(killer, botName, charsmax(botName));			

			cs_set_user_money(killer, botMoney);
			cs_set_user_money(target, tgtMoney);
			client_print_color(target, print_chat, "^4%s ^1$%d was give from ^3^"%s^".", CHAT_TAG, botGive, botName);
		}
	}
}