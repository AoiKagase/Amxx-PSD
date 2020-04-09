#pragma semicolon 1
#include <amxmodx> 
#include <amxconst>
#include <cstrike>
#include <hamsandwich>

#define PLUGIN 						"Bot vs Player"
#define VERSION						"0.1"
#define AUTHOR		                "Aoi.Kagase"	// +ARUKARI- => Aoi.Kagase

#define CVAR_TAG	                "amx_pvb"
#define CHAT_TAG	                "PvB"
#define TEAM_SELECT_VGUI_MENU_ID    2
#define AUTO_TEAM_JOIN_DELAY        0.1

// CS Status Data.

new g_msg_vgui;
new g_msg_smenu;

enum _:CVARS
{
	CVARS_ENABLE,
}

new g_cvars[CVARS];
new CsTeams:g_player_round;

public plugin_init() 
{ 
	register_plugin(PLUGIN,VERSION,AUTHOR); 

	g_cvars[CVARS_ENABLE] 	= register_cvar(fmt("%s%s", CVAR_TAG, "_enable"), "1");

	g_msg_vgui  = get_user_msgid("VGUIMenu");
	g_msg_smenu = get_user_msgid("ShowMenu");

	register_message(g_msg_smenu, "message_show_menu");
	register_message(g_msg_vgui,  "message_vgui_menu");

	register_logevent("round_end",   2, "0=World triggered", "1=Round_End");
	register_logevent("Event_CTWin", 6, "3=CTs_Win", 		"3=VIP_Escaped", 		"3=Bomb_Defused",  "3=All_Hostages_Rescued", "3=CTs_PreventEscape", "3=Escaping_Terrorists_Neutralized");
	register_logevent("Event_TRWin", 6, "3=Terrorists_Win", "3=VIP_Assassinated",	"3=Target_Bombed", "3=Hostages_Not_Rescued", "3=Terrorists_Escaped");

	g_player_round = CS_TEAM_CT;
	RegisterHam(Ham_Spawn, "player", "round_start_pre", 0);
}

public client_connect(id)
{
	if (is_user_connected(id))
	{
		if (is_user_bot(id) && !is_user_alive(id))
		{
			new CsTeams:num = ((g_player_round != CS_TEAM_CT) ? CS_TEAM_T : CS_TEAM_CT);
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
	new CsTeams:num = (g_player_round == CS_TEAM_CT) ? CS_TEAM_CT : CS_TEAM_T;
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
	if (g_player_round != CS_TEAM_T)
	{
		g_player_round 	= CS_TEAM_T;
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
	if (g_player_round != CS_TEAM_CT)
	{
		g_player_round 	= CS_TEAM_CT;
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
	new CsTeams:team =  (g_player_round == CS_TEAM_CT) ? CS_TEAM_T : CS_TEAM_CT;

	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;

	if (!is_user_bot(id))
		cs_set_user_team(id, g_player_round);
	else
		cs_set_user_team(id, team);

	if (cs_get_user_team(id) == CS_TEAM_T)
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
