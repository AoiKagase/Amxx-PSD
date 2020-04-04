#pragma semicolon 1
#include <amxmodx> 
#include <amxconst>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN 						"Bot vs Player"
#define VERSION						"0.1"
#define AUTHOR		                "Aoi.Kagase"	// +ARUKARI- => Aoi.Kagase

#define CVAR_TAG	                "amx_pvb"
#define CHAT_TAG	                "PVB"
#define TEAM_SELECT_VGUI_MENU_ID    2
#define AUTO_TEAM_JOIN_DELAY        0.1
#define OFFSET_TEAM 				114
#define OFFSET_DEFUSE_PLANT			193 
#define HAS_DEFUSE_KIT				(1<<16) // 65536

// CS Status Data.
#define cs_get_user_team(%1)		get_offset_value(%1,OFFSET_TEAM)
#define cs_set_user_team(%1,%2)		set_offset_value(%1,OFFSET_TEAM,%2)
#define cs_get_user_defuse(%1)		(get_pdata_int(%1,OFFSET_DEFUSE_PLANT) & HAS_DEFUSE_KIT)

new g_msg_vgui;
new g_msg_smenu;
stock	cs_set_user_defuse(id, iDefusekit = 1, iRed = 0, iGreen = 160, iBlue = 0, icon[] = "defuser", iFlash = 0)
{
    static iMsgStatusIcon;
    if( iMsgStatusIcon || (iMsgStatusIcon = get_user_msgid("StatusIcon")) )
    {
        if( iDefusekit )
        {
            set_pev(id, pev_body, 1);

            set_pdata_int(id, OFFSET_DEFUSE_PLANT, get_pdata_int(id, OFFSET_DEFUSE_PLANT) | HAS_DEFUSE_KIT);

            message_begin(MSG_ONE_UNRELIABLE, iMsgStatusIcon, _, id);
            write_byte(iFlash ? 2 : 1);
            write_string(icon);
            write_byte(iRed);
            write_byte(iGreen);
            write_byte(iBlue);
            message_end();
        }
        else
        {
            set_pdata_int(id, OFFSET_DEFUSE_PLANT, get_pdata_int(id, OFFSET_DEFUSE_PLANT) & ~HAS_DEFUSE_KIT);

            message_begin(MSG_ONE_UNRELIABLE, iMsgStatusIcon, _, id);
            write_byte(0);
            write_string(icon);
            message_end();

            set_pev(id, pev_body, 0);
        }
    }
}

enum CVARS
{
	CVARS_ENABLE,
}

new g_cvars[CVARS];
new CsTeam:g_player_round;

public plugin_init() 
{ 
	new cvar_command[32];
	new cvar_length = charsmax(cvar_command);

	register_plugin(PLUGIN,VERSION,AUTHOR); 

	formatex(cvar_command, cvar_length, "%s%s", CVAR_TAG, "enable");

	g_cvars[CVARS_ENABLE] 	= register_cvar(cvar_command, "1");

	g_msg_vgui  = get_user_msgid("VGUIMenu");
	g_msg_smenu = get_user_msgid("ShowMenu");

	register_message(g_msg_smenu, "message_show_menu");
	register_message(g_msg_vgui,  "message_vgui_menu");

	register_logevent("round_end",   2, "0=World triggered", "1=Round_End");
	register_logevent("Event_CTWin", 6, "3=CTs_Win", 		"3=VIP_Escaped", 		"3=Bomb_Defused",  "3=All_Hostages_Rescued", "3=CTs_PreventEscape", "3=Escaping_Terrorists_Neutralized");
	register_logevent("Event_TRWin", 6, "3=Terrorists_Win", "3=VIP_Assassinated",	"3=Target_Bombed", "3=Hostages_Not_Rescued", "3=Terrorists_Escaped");

	g_player_round = CsTeam:CS_TEAM_CT;
	RegisterHam(Ham_Spawn, "player", "round_start_pre", 0);
}

public client_connect(id)
{
	if (is_user_connected(id))
	{
		if (is_user_bot(id) && !is_user_alive(id))
		{
			new num = int:((g_player_round != CsTeam:CS_TEAM_CT) ? CS_TEAM_T : CS_TEAM_CT);
			cs_set_user_team(id, num);
		}
	}
}

public client_disconnected(id)
{
	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	bot_player_balance();

	return PLUGIN_CONTINUE;
}

set_force_team_join_task(id, menu_msgid) 
{
	static param_menu_msgid[2];
	param_menu_msgid[0] = menu_msgid;
	set_task(0.1, "auto_join", id, param_menu_msgid, sizeof param_menu_msgid);
}

public auto_join(menu_msgid[], id)
{
	new msg_block = get_msg_block(menu_msgid[0]);

	set_msg_block(menu_msgid[0], BLOCK_SET);
	new team[2];
	new CsTeam:num = (g_player_round == CsTeam:CS_TEAM_CT) ? (CsTeam:CS_TEAM_CT) : (CsTeam:CS_TEAM_T);
	num_to_str(int:num, team, charsmax(team));

	engclient_cmd(id, "jointeam",  team);
	engclient_cmd(id, "joinclass", "5");

	set_msg_block(menu_msgid[0], msg_block);
}
public round_end()
{
//	g_player_round 	= CsTeam:((g_player_round == CsTeam:CS_TEAM_CT) ? CS_TEAM_T : CS_TEAM_CT);
	bot_player_balance();
}

public Event_TRWin()
{
	if (g_player_round != CsTeam:CS_TEAM_T)
	{
		g_player_round 	= CsTeam:CS_TEAM_T;
		client_print_color(0, print_chat, "^4[%s]^2%s", CHAT_TAG, "Boooo, Your team lost to BOT.");
		client_print_color(0, print_chat, "^4[%s]^2%s", CHAT_TAG, "Swap teams for Terrorist.");
	}
	else
	{
		client_print_color(0, print_chat, "^4[%s]^2%s", CHAT_TAG, "Your team has WON!");
		client_print_color(0, print_chat, "^4[%s]^2%s", CHAT_TAG, "Continue round in Terrorist team.");
	}
	return PLUGIN_CONTINUE;
}

public Event_CTWin()
{
	if (g_player_round != CsTeam:CS_TEAM_CT)
	{
		g_player_round 	= CsTeam:CS_TEAM_CT;
		client_print_color(0, print_chat, "^4[%s]^2%s", CHAT_TAG, "Boooo, Your team lost to BOT.");
		client_print_color(0, print_chat, "^4[%s]^2%s", CHAT_TAG, "Swap teams for Counter-Terrorist.");
	}
	else
	{
		client_print_color(0, print_chat, "^4[%s]^2%s", CHAT_TAG, "Your team has WON!");
		client_print_color(0, print_chat, "^4[%s]^2%s", CHAT_TAG, "Continue round in Counter-Terrorist team.");
	}
	return PLUGIN_CONTINUE;
}

bot_player_balance()
{
	new bots	[MAX_PLAYERS];
	new players	[MAX_PLAYERS];
	new pnum, bnum;
	get_players(bots, 	 bnum, "dh");
	get_players(players, pnum, "ch");
	new add = (pnum + 1) - bnum;

	for(new i = 0; i < abs(add); i++)
	{
		if (add > 0)
			server_cmd("yb add");
		else
			server_cmd("yb kick");
	}
}

public round_start_pre(id)
{
	bot_player_balance();
	new num =  int:((g_player_round == CsTeam:CS_TEAM_CT) ? CS_TEAM_T : CS_TEAM_CT);

	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;

	if (!is_user_bot(id))
		cs_set_user_team(id, int:g_player_round);
	else
		cs_set_user_team(id, num);

	if (CsTeam:cs_get_user_team(id) == CsTeam:CS_TEAM_T)
	{
		if(cs_get_user_defuse(id))
   			cs_set_user_defuse(id, 0);
	}
	return PLUGIN_CONTINUE;
}

public message_show_menu(msgid, dest, id) 
{
	static team_select[] = "#Team_Select";
	static menu_text_code[sizeof team_select];
	get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1);
	if (!equal(menu_text_code, team_select))
		return PLUGIN_CONTINUE;

	set_force_team_join_task(id, msgid);
	return PLUGIN_HANDLED;
}

public message_vgui_menu(msgid, dest, id) 
{
	if (get_msg_arg_int(1) != TEAM_SELECT_VGUI_MENU_ID)
		return PLUGIN_CONTINUE;

	set_force_team_join_task(id, msgid);

	return PLUGIN_HANDLED;
}

//====================================================
// Gets offset data
//====================================================
get_offset_value(id, type)
{
	new key = type;
	return get_pdata_int(id, key);	
}

//====================================================
// Sets offset data
//====================================================
set_offset_value(id, type, value)
{
	new key = type;
	set_pdata_int(id, key, value);	
}