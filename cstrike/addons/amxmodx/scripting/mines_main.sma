
//=============================================
//	Plugin Writed by Visual Studio Code.
//=============================================
//#pragma semicolon 1

// Supported BIOHAZARD.
// #define BIOHAZARD_SUPPORT

// Supported Zombie Plague.
// #define ZP_SUPPORT

//=====================================
//  INCLUDE AREA
//=====================================
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <mines_util>
#if defined BIOHAZARD_SUPPORT
	#include <biohazard>
#endif

#if defined ZP_SUPPORT
	#include <zp50_items>
	#include <zp50_gamemodes>
	#include <zp50_colorchat>
	#include <zp50_ammopacks>
#endif

//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 200
	#assert "AMX Mod X v1.10.0 or greater library required!"
#endif

#define PLUGIN 					"Mines Entity Platform"

#define CHAT_TAG 				"[M.E.P]"
#define CVAR_TAG				"amx_mines"

//=====================================
//  Resource Setting AREA
//=====================================
#define ENT_SOUND				"items/gunpickup2.wav"
#define ENT_SOUND1				"debris/bustglass1.wav"
#define ENT_SOUND2				"debris/bustglass2.wav"
#define ENT_SPRITE 				"sprites/eexplo.spr"

//=====================================
//  MACRO AREA
//=====================================
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define AUTHOR 					"Aoi.Kagase"
#define VERSION 				"4.00"

//#define STR_MINEDETNATED 			"Your mine has detonated.",
//#define STR_MINEDETNATED2			"detonated your mine.",
//#define STR_CANTDEPLOY			"Your team can't deploying lasermine!"

#define LANG_KEY_REFER			"REFER"
#define LANG_KEY_BOUGHT       	"BOUGHT"
#define LANG_KEY_NO_MONEY     	"NO_MONEY"
#define LANG_KEY_NOT_ACCESS   	"NOT_ACCESS"
#define LANG_KEY_NOT_ACTIVE   	"NOT_ACTIVE"
#define LANG_KEY_NOT_HAVE     	"NOT_HAVE"
#define LANG_KEY_NOT_BUY      	"NOT_BUY"
#define LANG_KEY_NOT_BUYZONE  	"NOT_BUYZONE"
#define LANG_KEY_NOT_PICKUP   	"NOT_PICKUP"
#define LANG_KEY_MAX_DEPLOY   	"MAX_DEPLOY"
#define LANG_KEY_MAX_HAVE     	"MAX_HAVE"
#define LANG_KEY_MAX_PPL      	"MAX_PPL"
#define LANG_KEY_DELAY_SEC    	"DELAY_SEC"
#define LANG_KEY_STATE_AMMO   	"STATE_AMMO"
#define LANG_KEY_STATE_INF    	"STATE_INF"
#define LANG_KEY_PLANT_WALL   	"PLANT_WALL"
#define LANG_KEY_PLANT_GROUND 	"PLANT_GROUND"
#define LANG_KEY_SORRY_IMPL   	"SORRY_IMPL"
#define LANG_KEY_NOROUND		"NO_ROUND"
#define LANG_KEY_ALL_REMOVE		"ALL_REMOVE"
#define LANG_KEY_GIVE_MINE		"GIVE_MINE"
#define LANG_KEY_REMOVE_SPEC	"REMOVE_SPEC"
#define LANG_KEY_MINE_HUD		"MINE_HUD_MSG"
#define LANG_KEY_NOT_BUY_TEAM 	"NOT_BUY_TEAM"

// ADMIN LEVEL
#define ADMIN_ACCESSLEVEL		ADMIN_LEVEL_H

// Put Guage ID
#define TASK_PLANT				15100
#define TASK_RESET				15500
#define TASK_RELEASE			15900

// Client Print Command Macro.
#define cp_debug(%1)				client_print_color(%1, %1, "^4[Laesrmine Debug] ^1Can't Create Entity")
#define cp_not_active(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY_NOT_ACTIVE, CHAT_TAG)
#define cp_not_access(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY_NOT_ACCESS, CHAT_TAG)
#define cp_delay_time(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_DELAY_SEC,	CHAT_TAG, cvar_delay - nowTime)

#define cp_bought(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_BOUGHT,		CHAT_TAG)
#define	cp_no_money(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NO_MONEY,		CHAT_TAG, cost)
#define cp_dont_have(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_HAVE,		CHAT_TAG)
#define cp_cant_buy(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUY,		CHAT_TAG)
#define cp_buyzone(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUYZONE,	CHAT_TAG)
#define cp_cant_buy_team(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUY_TEAM,	CHAT_TAG)
#define cp_cant_pickup(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_PICKUP,	CHAT_TAG)
#define cp_maximum_deployed(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_DEPLOY,	CHAT_TAG)
#define cp_have_max(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_HAVE,		CHAT_TAG)
#define cp_many_ppl(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_PPL,		CHAT_TAG)
#define cp_noround(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOROUND, 		CHAT_TAG)
#define cp_all_remove(%1,%2,%3)		client_print_color(%1, %1, "%L", %1, LANG_KEY_ALL_REMOVE,	CHAT_TAG, %2, %3)
#define cp_gave(%1,%2,%3)			client_print_color(%1, %1, "%L", %1, LANG_KEY_GIVE_MINE,	CHAT_TAG, %2, %3)
#define cp_remove_spec(%1,%2)		client_print_color(%1, %1, "%L", %1, LANG_KEY_REMOVE_SPEC,	CHAT_TAG, %2)

//
// CVAR SETTINGS
//
enum CVAR_SETTING
{
	CVAR_ENABLE				= 0,    // Plugin Enable.
	CVAR_ACCESS_LEVEL		,		// Access level for 0 = ADMIN or 1 = ALL.
	CVAR_NOROUND			,		// Check Started Round.
	CVAR_CMD_MODE			,    	// 0 = +USE key, 1 = bind, 2 = each.
	CVAR_FRIENDLY_FIRE		,		// Friendly Fire.
	CVAR_START_DELAY        ,   	// Round start delay time.
};

enum _:FORWARDER
{
	FWD_SET_ENTITY_SPAWN,
	FWD_PUTIN_SERVER,
	FWD_CHECK_DEPLOY,
	FWD_CHECK_PICKUP,
	FWD_CHECK_BUY,
	FWD_DISCONNECTED,
	FWD_MINES_THINK,
	FWD_MINES_BREAKED,
	FWD_MINES_PICKUP,
	FWD_REMOVE_ENTITY,
	FWD_PLUGINS_END,
};
#if defined ZP_SUPPORT
enum _:GAMEMODE_TAG
{
	GMODE_ARMAGEDDON,
	GMODE_ZTAG,
	GMODE_ASSASIN,
};
new gZpGameMode[GAMEMODE_TAG];
#endif

//====================================================
//  GLOBAL VARIABLES
//====================================================
new gBoom;
new gMsgBarTime;
new gEntMine;
new gCvar				[CVAR_SETTING];
new gForwarder			[FORWARDER];

new Array:gMinesClass;
new Array:gMinesLongName;
new Array:gMinesParameter;
new Array:gPlayerData	[MAX_PLAYERS];
new gCPlayerData		[MAX_PLAYERS][COMMON_PLAYER_DATA];

//====================================================
//  Player Data functions
//====================================================
#define mines_get_user_deploy_state(%1)					gCPlayerData[%1][PL_STATE_DEPLOY]
#define mines_set_user_deploy_state(%1,%2)				gCPlayerData[%1][PL_STATE_DEPLOY] = %2
#define mines_load_user_max_speed(%1)					gCPlayerData[%1][PL_MAX_SPEED]
#define mines_save_user_max_speed(%1,%2)				gCPlayerData[%1][PL_MAX_SPEED] = Float:%2

//====================================================
// Function: Count to deployed in team.
//====================================================
stock int:mines_get_team_deployed_count(id, iMinesId, plData[PLAYER_DATA])
{
	new int:i;
	new int:count;
	new int:num;
	new team[3] = '^0';
	new players[MAX_PLAYERS];

	// Witch your team?
	switch(CsTeams:mines_get_user_team(id))
	{
		case CS_TEAM_CT: team = "CT";
		case CS_TEAM_T : team = "T";
		default:
			return int:0;
	}

	// Get your team member.
	get_players(players, num, "e", team);

	// Count your team deployed lasermine.
	count = int:0;
	for(i = int:0;i < num;i++)
	{
		ArrayGetArray(gPlayerData[players[i]], iMinesId, plData, sizeof(plData));
		count += plData[PL_COUNT_DEPLOYED];
	}

	return count;
}

stock mines_reset_have_mines(id)
{
	new plData[PLAYER_DATA];
	for(new i = 0; i < ArraySize(gMinesClass); i++)
	{
		ArrayGetArray(gPlayerData[id], i, plData, sizeof(plData));
		// reset deploy count.
		plData[PL_COUNT_DEPLOYED]	= int:0;
		// reset hove mine.
		plData[PL_COUNT_HAVE_MINE]	= int:0;

		ArraySetArray(gPlayerData[id], i, plData, sizeof(plData));
	}
}

stock mines_remove_all_mines(id)
{
	static minesData[COMMON_MINES_DATA];
	new result = false;

	for(new i = 0; i < ArraySize(gMinesClass); i++)
	{
		ArrayGetArray(gMinesParameter, i, minesData, sizeof(minesData));
		// Dead Player remove lasermine.
		if (minesData[DEATH_REMOVE])
		{
			result |= mines_remove_all_entity_main(id, i);
		}
	}
	return result;
}

stock mines_remove_all_entity_main(id, iMinesId)
{
	static plData[PLAYER_DATA];
	static sClassName[MAX_CLASS_LENGTH];
	new result = false;
	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));

	if (plData[PL_COUNT_DEPLOYED] > int:0)
		result = true;

	ArrayGetString(gMinesClass, iMinesId, sClassName, charsmax(sClassName));
	mines_remove_all_entity(id, sClassName);

	// reset deploy count.
	plData[PL_COUNT_DEPLOYED] = int:0;
	ArraySetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));
	return result;
}
//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// CVar settings.
	// Common.
	gCvar[CVAR_ENABLE]	        = register_cvar(fmt("%s%s", CVAR_TAG, "_enable"),		"1"	);	// 0 = off, 1 = on.
	gCvar[CVAR_ACCESS_LEVEL]   	= register_cvar(fmt("%s%s", CVAR_TAG, "_access"),		"0"	);	// 0 = all, 1 = admin
	gCvar[CVAR_START_DELAY]    	= register_cvar(fmt("%s%s", CVAR_TAG, "_round_delay"),	"5"	);	// Round start delay time.
	gCvar[CVAR_FRIENDLY_FIRE]  	= get_cvar_pointer("mp_friendlyfire");							// Friendly fire. 0 or 1

	// Get Message Id
	gMsgBarTime		= get_user_msgid("BarTime");

	gForwarder[FWD_SET_ENTITY_SPAWN] = CreateMultiForward("mines_entity_spawn_settings"	, ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	gForwarder[FWD_PUTIN_SERVER]	 = CreateMultiForward("mines_client_putinserver"	, ET_IGNORE, FP_CELL);
	gForwarder[FWD_DISCONNECTED] 	 = CreateMultiForward("mines_client_disconnected"	, ET_IGNORE, FP_CELL);
	gForwarder[FWD_REMOVE_ENTITY]	 = CreateMultiForward("mines_remove_entity"			, ET_IGNORE, FP_CELL);
	gForwarder[FWD_PLUGINS_END] 	 = CreateMultiForward("mines_plugin_end"			, ET_IGNORE);
	gForwarder[FWD_CHECK_PICKUP]	 = CreateMultiForward("CheckForPickup"				, ET_STOP,   FP_CELL, FP_CELL, FP_CELL);
	gForwarder[FWD_CHECK_DEPLOY]	 = CreateMultiForward("CheckForDeploy"				, ET_STOP,   FP_CELL, FP_CELL);
	gForwarder[FWD_CHECK_BUY]	 	 = CreateMultiForward("CheckForBuy"					, ET_STOP,   FP_CELL, FP_CELL);
	gForwarder[FWD_MINES_THINK]		 = CreateMultiForward("MinesThink"					, ET_IGNORE, FP_CELL, FP_CELL);
	gForwarder[FWD_MINES_PICKUP]	 = CreateMultiForward("MinesPickup"					, ET_IGNORE, FP_CELL, FP_CELL);
	gForwarder[FWD_MINES_BREAKED]	 = CreateMultiForward("MinesBreaked"				, ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);

	gMinesClass 					= ArrayCreate(MAX_CLASS_LENGTH);
	gMinesParameter 				= ArrayCreate(COMMON_MINES_DATA);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		gPlayerData[i] = ArrayCreate(PLAYER_DATA);
	}

	// Register Event
	register_event("DeathMsg", "DeathEvent",	"a");
	register_event("TeamInfo", "CheckSpectator","a");

	// Register Forward.
	register_forward(FM_PlayerPostThink,"PlayerPostThink");
	register_forward(FM_PlayerPreThink, "PlayerPreThink");
	register_forward(FM_TraceLine,		"MinesShowInfo", 1);

	// Register Hamsandwich
	RegisterHam(Ham_Spawn, 		"player", 			 "NewRound", 		1);
	RegisterHam(Ham_Killed, 	"player", 			 "PlayerKilling", 	0);
	RegisterHam(Ham_Think, 		ENT_CLASS_BREAKABLE, "MinesThinkMain",	0);
	RegisterHam(Ham_TakeDamage,	ENT_CLASS_BREAKABLE, "MinesTakeDamage", 0);
	RegisterHam(Ham_TakeDamage,	ENT_CLASS_BREAKABLE, "MinesBreakedMain",1);

	// Multi Language Dictionary.
	register_dictionary("mines/mines_main.txt");

	register_cvar(PLUGIN, VERSION, FCVAR_SERVER|FCVAR_SPONLY);


	return PLUGIN_CONTINUE;
}

public plugin_natives()
{
	register_library("mines_natives");

	register_native("register_mines",			"_native_register_mines");
	register_native("mines_progress_deploy",	"_native_deploy_progress");
	register_native("mines_progress_pickup",	"_native_pickup_progress");
	register_native("mines_progress_stop", 		"_native_stop_progress");
	register_native("mines_explosion", 			"_native_mines_explosion");
	register_native("mines_buy",				"_native_buy_mines");
	register_native("mines_valid_takedamage",	"_native_is_valid_takedamage");

#if defined ZP_SUPPORT
	register_native("zp_give_lm", 				"ZpMinesNative");
#endif
}

//====================================================
//  Native: Register Mines.
//====================================================
public _native_is_valid_takedamage(iPlugin, iParams)
	return is_valid_takedamage(get_param(1), get_param(2));

//====================================================
//  Native: Register Mines.
//====================================================
public _native_register_mines(iPlugin, iParams)
{
	new className[MAX_CLASS_LENGTH];
	new sLongName[MAX_NAME_LENGTH];
	new minesData[COMMON_MINES_DATA];
	new iMinesId = -1;
	get_string(1, className, charsmax(className));
	get_string(2, sLongName, charsmax(sLongName));
	get_array(3, minesData, sizeof(minesData));

	#if defined ZP_SUPPORT
		new zpWeaponId					= zp_items_register(className, minesData[BUY_PRICE]);
		gZpGameMode[GMODE_ARMAGEDDON]	= zp_gamemodes_get_id("Armageddon Mode");
		gZpGameMode[GMODE_ZTAG] 		= zp_gamemodes_get_id("Zombie Tag Mode");
		gZpGameMode[GMODE_ASSASIN]		= zp_gamemodes_get_id("Assassin Mode");
		minesData[ZP_WEAPON_ID]			= zpWeaponId;
	#endif
	iMinesId = ArrayPushString(gMinesClass, className);
	ArrayPushString(gMinesLongName, sLongName);
	ArrayPushArray(gMinesParameter, minesData);

	new plData[PLAYER_DATA];
	for(new i = 0; i < MAX_PLAYERS; i++)
		ArrayPushArray(gPlayerData[i], plData, sizeof(plData));

	return iMinesId;
}
// mines_progress_deploy(id, iMinesId);
public _native_deploy_progress(iPlugin, iParams)
{
	mines_progress_deploy(get_param(1), get_param(2));
}
// mines_progress_pickup(id, iMinesId);
public _native_pickup_progress(iPlugin, iParams)
{
	mines_progress_pickup(get_param(1), get_param(2));
}
// mines_progress_stop(id);
public _native_stop_progress(iPlugin, iParams)
{
	mines_progress_stop(get_param(1));
}
// mines_mines_explosion(id, iMinesId, iEnt);
public _native_mines_explosion(iPlugin, iParams)
{
	new id	= get_param(1);
	new mId = get_param(2);
	new iEnt= get_param(3); 
	static plData[PLAYER_DATA];
	static minesData[COMMON_MINES_DATA];

	// Stopping entity to think
	set_pev(iEnt, pev_nextthink, 0.0);

	// reset deploy count.
	// Count down. deployed lasermines.
	ArrayGetArray(gPlayerData[id], mId, plData, sizeof(plData));
	plData[PL_COUNT_DEPLOYED]--;
	ArraySetArray(gPlayerData[id], mId, plData, sizeof(plData));
	ArrayGetArray(gMinesParameter, mId, minesData, sizeof(minesData));

	// effect explosion.
	mines_create_explosion(iEnt, gBoom);
	
	// damage.
	mines_create_explosion_damage(iEnt, id, Float:minesData[EXPLODE_DAMAGE], Float:minesData[EXPLODE_RADIUS]);

	// remove this.
	mines_remove_entity(iEnt);
}

//====================================================
// Buy Lasermine.
//====================================================
public _native_buy_mines(iPlugin, iParams)
{	
#if !defined ZP_SUPPORT
	mines_buy_mine(get_param(1), get_param(2));
#endif
	return PLUGIN_HANDLED;
}

//====================================================
//  PLUGIN END
//====================================================
public plugin_end()
{
	ExecuteForward(gForwarder[FWD_PLUGINS_END]);
	ArrayDestroy(gMinesClass);
	ArrayDestroy(gMinesParameter);

	for (new i = 0; i < FORWARDER; i++)
		DestroyForward(gForwarder[i]);

	for (new i = 0; i < MAX_PLAYERS; i++)
		ArrayDestroy(gPlayerData[i]);
}

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	precache_sound(ENT_SOUND);
	precache_sound(ENT_SOUND1);
	precache_sound(ENT_SOUND2);
	gBoom = precache_model(ENT_SPRITE);
	
	return PLUGIN_CONTINUE;
}
//====================================================
//  PLUGIN CONFIG
//====================================================
public plugin_cfg()
{
	// registered func_breakable
	gEntMine = engfunc(EngFunc_AllocString, ENT_CLASS_BREAKABLE);

	new file[64];
	new len = charsmax(file);
	get_localinfo("amxx_configsdir", file, len);
	format(file, len, "%s/mines_cvars.cfg", file);
	if(file_exists(file)) 
	{
		server_cmd("exec %s", file);
		server_exec();
	}
}

//====================================================
//  Bot Register Ham.
//====================================================
new g_bots_registered = false;
public client_authorized( id )
{
    if( !g_bots_registered && is_user_bot( id ) )
    {
        set_task( 0.1, "register_bots", id );
    }
}

public register_bots( id )
{
    if( !g_bots_registered && is_user_connected( id ) )
    {
        RegisterHamFromEntity( Ham_Killed, id, "PlayerKilling");
        g_bots_registered = true;
    }
}

//====================================================
// Friendly Fire Method.
//====================================================
bool:is_valid_takedamage(iAttacker, iTarget)
{
	if (get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]))
		return true;

	if (cs_get_user_team(iAttacker) != cs_get_user_team(iTarget))
		return true;

	return false;
}

//====================================================
// Round Start Initialize
//====================================================
public NewRound(id)
{
	// Check Plugin Enabled
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	// alive?
	if (is_user_alive(id) && pev(id, pev_flags) & (FL_CLIENT)) 
	{
		// Task Delete.
		delete_task(id);

		new plData[PLAYER_DATA];
		for (new i = 0; i < ArraySize(gMinesClass); i++)
		{
			ArrayGetArray(gPlayerData[id], i, plData, sizeof(plData));
			// Delay time reset
			plData[PL_COUNT_DELAY] = int:floatround(get_gametime());
			ArraySetArray(gPlayerData[id], i, plData, sizeof(plData));
			// Removing already put lasermine.
			mines_remove_all_entity_main(id, i);
			// Round start set ammo.
			set_start_ammo(id, i);
		}
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Round Start Set Ammo.
// Native:_native_set_start_ammo(iPlugin, iParam);
//====================================================
set_start_ammo(id, iMinesId)
{
	static plData[PLAYER_DATA];
	static minesData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));
	// Get CVAR setting.
	new int:stammo = int:minesData[AMMO_HAVE_START];

	// Zero check.
	if(stammo <= int:0) 
		return;

	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));

	// Getting have ammo.
	new int:haveammo = plData[PL_COUNT_HAVE_MINE];

	// Set largest.
	plData[PL_COUNT_HAVE_MINE] = (haveammo <= stammo ? stammo : haveammo);
	ArraySetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));

	return;
}

//====================================================
// Death Event / Delete Task.
//====================================================
public DeathEvent()
{
	// new kID = read_data(1); // killer
	new vID = read_data(2); // victim
	// new isHS = read_data(3); // is headshot
	// new wpnName = read_data(4); // wpnName

	// Check Plugin Enabled
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	// Is Connected?
	if (is_user_connected(vID)) 
		delete_task(vID);

	mines_remove_all_mines(vID);

	return PLUGIN_CONTINUE;
}

//====================================================
// Put LaserMine Start Progress A
//====================================================
public mines_progress_deploy(id, iMinesId)
{
	// Deploying Check.
	if (!CheckDeploy(id, iMinesId))
		return PLUGIN_HANDLED;

	static minesData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));
	new Float:wait = Float:minesData[ACTIVATE_TIME];

	if (wait > 0)
		mines_show_progress(id, int:floatround(wait), gMsgBarTime);

	// Set Flag. start progress.
	mines_set_user_deploy_state(id, int:STATE_DEPLOYING);

	new sMineId[4];
	num_to_str(iMinesId, sMineId, charsmax(sMineId));
	// Start Task. Put Lasermine.
	set_task(wait, "SpawnMine", (TASK_PLANT + id), sMineId, charsmax(sMineId));

	return PLUGIN_HANDLED;
}

//====================================================
// Removing target put lasermine.
//====================================================
public mines_progress_pickup(id, iMinesId)
{
	// Removing Check.
	if (!CheckPickup(id, iMinesId))
		return PLUGIN_HANDLED;

	static minesData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));

	new Float:wait = Float:minesData[ACTIVATE_TIME];
	if (wait > 0)
		mines_show_progress(id, int:floatround(wait), gMsgBarTime);

	// Set Flag. start progress.
	mines_set_user_deploy_state(id, int:STATE_DEPLOYING);

	new sMineId[4];
	num_to_str(iMinesId, sMineId, charsmax(sMineId));
	// Start Task. Remove Lasermine.
	set_task(wait, "RemoveMine", (TASK_RELEASE + id), sMineId, charsmax(sMineId));

	return PLUGIN_HANDLED;
}

//====================================================
// Stopping Progress.
//====================================================
public mines_progress_stop(id)
{
	mines_hide_progress(id, gMsgBarTime);
	delete_task(id);

	return PLUGIN_HANDLED;
}

//====================================================
// Task: Spawn Lasermine.
//====================================================
public SpawnMine(params[], id)
{
	// Task Number to uID.
	new uID = id - TASK_PLANT;
	// Create Entity.
	new iEnt = engfunc(EngFunc_CreateNamedEntity, gEntMine);
	new plData[PLAYER_DATA];

	// is Valid?
	if(!iEnt)
	{
		cp_debug(uID);
		return PLUGIN_HANDLED_MAIN;
	}

	new iReturn;
	new iMinesId = str_to_num(params);
	if (ExecuteForward(gForwarder[FWD_SET_ENTITY_SPAWN], iReturn, iEnt, uID, iMinesId))
	{
		new authid[MAX_AUTHID_LENGTH];
		get_user_authid(uID, authid, charsmax(authid));
		set_pev(iEnt, pev_netname, authid);

		ArrayGetArray(gPlayerData[uID], iMinesId, plData, sizeof(plData));
		// Cound up. deployed.
		plData[PL_COUNT_DEPLOYED]++;
		// Cound down. have ammo.
		plData[PL_COUNT_HAVE_MINE]--;
		ArraySetArray(gPlayerData[uID], iMinesId, plData, sizeof(plData));

		// Set Flag. end progress.
		mines_set_user_deploy_state(uID, int:STATE_DEPLOYED);
	}
	return iReturn;
}

//====================================================
// Task: Remove Lasermine.
//====================================================
public RemoveMine(params[], id)
{
	new target, body;
	new Float:vOrigin[3];
	new Float:tOrigin[3];
	static plData[PLAYER_DATA];

	// Task Number to uID.
	new uID = id - TASK_RELEASE;

	// Get target entity.
	get_user_aiming(uID, target, body);

	// is valid target?
	if(!pev_valid(target))
		return;
	
	// Get Player Vector Origin.
	// Get Mine Vector Origin.
	pev(uID, pev_origin, vOrigin);
	pev(target, pev_origin, tOrigin);

	// Distance Check. far 128.0 (cm?)
	if(get_distance_f(vOrigin, tOrigin) > 128.0)
		return;
	
	static tClassName[MAX_CLASS_LENGTH];
	static iClassName[MAX_CLASS_LENGTH];
	new iMinesId = str_to_num(params);

	pev(target, pev_classname, tClassName, charsmax(tClassName));
	ArrayGetString(gMinesClass, iMinesId, iClassName, charsmax(iClassName));

	// Check. is Target Entity Lasermine?
	if(!equali(tClassName, iClassName))
		return;

	new ownerID = pev(target, MINES_OWNER);
	static minesData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));

	switch(PICKUP_MODE:minesData[PICKUP_MODE])
	{
		case DISALLOW_PICKUP:
			return;
		case ONLY_ME:
		{
			// Check. is Owner you?
			if(ownerID != uID)
				return;
		}
		case ALLOW_FRIENDLY:
		{
			// Check. is friendly team?
			if(CsTeams:pev(target, MINES_TEAM) != cs_get_user_team(uID))
				return;
		}		
	}
	new iReturn;
	ExecuteForward(gForwarder[FWD_MINES_PICKUP], iReturn, uID, target);

	// Remove!
	mines_remove_entity(target);

	ArrayGetArray(gPlayerData[uID], iMinesId, plData, sizeof(plData));
	// Collect for this removed lasermine.
	plData[PL_COUNT_HAVE_MINE]++;
	ArraySetArray(gPlayerData[uID], iMinesId, plData, sizeof(plData));


	if (pev_valid(ownerID))
	{
		ArrayGetArray(gPlayerData[ownerID], iMinesId, plData, sizeof(plData));
		// Return to before deploy count.
		plData[PL_COUNT_DEPLOYED]--;
		ArraySetArray(gPlayerData[ownerID], iMinesId, plData, sizeof(plData));
	}
	// Play sound.
	emit_sound(uID, CHAN_ITEM, ENT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	// Set Flag. end progress.
	mines_set_user_deploy_state(uID, int:STATE_DEPLOYED);

	return;
}

//====================================================
// Blocken Mines.
//====================================================
public MinesTakeDamage(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	static sClassName[MAX_CLASS_LENGTH];
	static minesData[COMMON_MINES_DATA];
	static iMinesId;
	pev(victim, pev_classname, sClassName, charsmax(sClassName));

	iMinesId = ArrayFindString(gMinesClass, sClassName);
	if (iMinesId == -1)
		return HAM_IGNORED;

	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));

	// We get the ID of the player who put the mine.
	new iOwner = pev(victim, MINES_OWNER);
	switch(minesData[MINES_BROKEN])
	{
		// 0 = mines.
		case 0:
		{
			// If the one who set the mine does not coincide with the one who attacked it, then we stop execution.
			if(iOwner != attacker)
				return HAM_SUPERCEDE;
		}
		// 1 = team.
		case 1:
		{
			// If the team of the one who put the mine and the one who attacked match.
			if(CsTeams:pev(victim, MINES_TEAM) != cs_get_user_team(attacker))
				return HAM_SUPERCEDE;
		}
		// 2 = Enemy.
		case 2:
		{
			return HAM_IGNORED;
		}
		// 3 = Enemy Only.
		case 3:
		{
			if(iOwner == attacker || CsTeams:pev(victim, MINES_TEAM) == cs_get_user_team(attacker))
				return HAM_SUPERCEDE;
		}
		default:
			return HAM_IGNORED;
	}	
	return HAM_IGNORED;
}

public MinesThinkMain(iEnt)
{
	// Check plugin enabled.
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return HAM_IGNORED;

	// is valid this entity?
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	static sClassName[MAX_CLASS_LENGTH];
	static iMinesId;
	pev(iEnt, pev_classname, sClassName, charsmax(sClassName));
	iMinesId = ArrayFindString(gMinesClass, sClassName);

	if (iMinesId != -1)
	{
		static iReturn;
		ExecuteForward(gForwarder[FWD_MINES_THINK], iReturn, iEnt, iMinesId );
	}
	return HAM_SUPERCEDE;
}

//====================================================
// Player killing (Set Money, Score)
//====================================================
public PlayerKilling(iVictim, iAttacker)
{
	static iMinesId;
	static minesData[COMMON_MINES_DATA];
	static sClassName[MAX_CLASS_LENGTH];

	pev(iAttacker, pev_classname, sClassName, charsmax(sClassName));
	iMinesId = ArrayFindString(gMinesClass, sClassName);

	if (iMinesId == -1)
		return HAM_IGNORED;

	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));

	//
	// Refresh Score info.
	//
	// Get Target Team.
	new CsTeams:aTeam = cs_get_user_team(iAttacker);
	new CsTeams:vTeam = cs_get_user_team(iVictim);
	new score  = (vTeam != aTeam) ? 1 : -1;

	// Attacker Frag.
	// Add Attacker Frag (Friendly fire is minus).
	new aFrag	= mines_get_user_frags(iAttacker) + score;
	new aDeath	= cs_get_user_deaths(iAttacker);

	mines_set_user_deaths(iAttacker, aDeath);
	ExecuteHamB(Ham_AddPoints, iAttacker, aFrag - mines_get_user_frags(iAttacker), true);

	new tDeath = mines_get_user_deaths(iVictim);

	mines_set_user_deaths(iVictim, tDeath);
	ExecuteHamB(Ham_AddPoints, iVictim, 0, true);

	#if !defined ZP_SUPPORT
		#if !defined BIOHAZARD_SUPPORT
			// Get Money attacker.
			new money  = (vTeam != aTeam) ? minesData[FRAG_MONEY] : (minesData[FRAG_MONEY] * -1);
			cs_set_user_money(iAttacker, cs_get_user_money(iAttacker) + money);
		#endif
	#endif

	return HAM_HANDLED;
}

//====================================================
// Buy Lasermine.
//====================================================
stock mines_buy_mine(id, iMinesId)
{	
	if (!CheckBuyMines(id, iMinesId))
		return PLUGIN_CONTINUE;
	static plData[PLAYER_DATA];
	static minesData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));
	new cost = minesData[BUY_PRICE];
	cs_set_user_money(id, cs_get_user_money(id) - cost);

	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));
	plData[PL_COUNT_HAVE_MINE]++;
	ArraySetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));

	cp_bought(id);

	emit_sound(id, CHAN_ITEM, ENT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

//====================================================
// Player post think event.
// Stop movement for mine deploying.
//====================================================
public PlayerPostThink(id) 
{
	if ((pev(id, pev_weapons) & (1 << CSW_C4)) && (pev(id, pev_oldbuttons) & IN_ATTACK))
		return FMRES_IGNORED;

	switch (mines_get_user_deploy_state(id))
	{
		case STATE_IDLE:
		{
			new Float:speed;
			mines_get_user_max_speed(id, speed);
			new bool:now_speed = (speed <= 1.0)
			if (now_speed)
				ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
		}
		case STATE_DEPLOYING:
		{
			mines_set_user_max_speed(id, 1.0);
		}
		case STATE_DEPLOYED:
		{
			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
			mines_set_user_deploy_state(id, STATE_IDLE);
		}
	}

	return FMRES_IGNORED;
}

//====================================================
// Player connected.
//====================================================
public client_putinserver(id)
{
	// check plugin enabled.
	if(!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	new iReturn;
	ExecuteForward(gForwarder[FWD_PUTIN_SERVER], iReturn, id);

	mines_reset_have_mines(id);

	return PLUGIN_CONTINUE;
}

//====================================================
// Player Disconnect.
//====================================================
/*
	symbol "client_disconnect" is marked as deprecated: Use client_disconnected() instead.
*/
public client_disconnected(id)
{
	// check plugin enabled.
	if(!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;
	
	new iReturn;
	ExecuteForward(gForwarder[FWD_DISCONNECTED], iReturn, id);

	// delete task.
	delete_task(id);
	// remove all lasermine.
	mines_remove_all_mines(id);
	return PLUGIN_CONTINUE;
}

//====================================================
// Delete Task.
//====================================================
delete_task(id)
{
	if (task_exists((TASK_PLANT + id)))
		remove_task((TASK_PLANT + id));

	if (task_exists((TASK_RELEASE + id)))
		remove_task((TASK_RELEASE + id));

	mines_set_user_deploy_state(id, STATE_IDLE);
	return;
}

//====================================================
// Check: common.
//====================================================
stock bool:CheckCommon(id, plData[PLAYER_DATA])
{
	new cvar_enable = get_pcvar_num(gCvar[CVAR_ENABLE]);
	new cvar_access = get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]);
	new cvar_delay	= get_pcvar_num(gCvar[CVAR_START_DELAY]);
	new user_flags	= get_user_flags(id) & ADMIN_ACCESSLEVEL;
	new is_alive	= is_user_alive(id);

	// Plugin Enabled
	if (!cvar_enable)
	{
		cp_not_active(id);
		return false;
	}

	// Can Access.
	if (cvar_access && !user_flags)
	{
		cp_not_access(id);
		return false;
	}

	// Is this player Alive?
	if (!is_alive) 
		return false;

	// Can set Delay time?
	// gametime - playertime = delay count.
	new nowTime = (floatround(get_gametime()) - _:plData[PL_COUNT_DELAY]);
	if(nowTime < cvar_delay)
	{
		cp_delay_time(id);
		return false;
	}
	return true;
}

//====================================================
// Check: Deploy.
//====================================================
stock bool:CheckDeploy(id, iMinesId)
{
	static plData[PLAYER_DATA];
	ArrayGetArray(gPlayerData[id], iMinesId, plData, 	sizeof(plData));

	// Check common.
	if (!CheckCommon(id, plData))
		return false;

	static minesData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));

#if defined BIOHAZARD_SUPPORT
	// Check Started Round.
	if (!CheckRoundStarted(id, iMinesId, minesData))
		return false;
#endif

	// Have mine? (use buy system)
	if (minesData[BUY_MODE])
	{
		if (plData[PL_COUNT_HAVE_MINE] <= int:0) 
		{
			cp_dont_have(id);
			return false;
		}
	}

	if (!CheckMaxDeploy(id, iMinesId, plData, minesData))
	{
		cp_maximum_deployed(id);
		return false;
	}
	
	new iReturn;
	ExecuteForward(gForwarder[FWD_CHECK_DEPLOY], iReturn, id, iMinesId);

	return bool:iReturn;
}

//====================================================
// Check: Round Started
//====================================================
#if defined BIOHAZARD_SUPPORT
stock bool:CheckRoundStarted(id, iMinesId, minesData[COMMON_MINES_DATA])
{
	if (minesData[NO_ROUND])
	{
		if(!game_started())
		{
			cp_noround(id);
			return false;
		}
	}
	return true;
}
#endif

//====================================================
// Check: Remove Lasermine.
//====================================================
public bool:CheckPickup(id, iMinesId)
{
	static plData[PLAYER_DATA];
	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));

	if (!CheckCommon(id, plData))
		return false;

	static minesData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));

	// have max ammo? (use buy system.)
	if (minesData[BUY_MODE])
	{
		if (plData[PL_COUNT_HAVE_MINE] + int:1 > int:minesData[AMMO_HAVE_MAX])
			return false;
	}

	new target, body;
	new Float:vOrigin[3];
	new Float:tOrigin[3];

	get_user_aiming(id, target, body);

	// is valid target entity?
	if(!pev_valid(target))
		return false;

	// get potision. player and target.
	pev(id,		pev_origin, vOrigin);
	pev(target, pev_origin, tOrigin);

	// Distance Check. far 128.0 (cm?)
	if(get_distance_f(vOrigin, tOrigin) > 128.0)
		return false;
	
	static minesClass[MAX_CLASS_LENGTH];
	static sClassName[MAX_CLASS_LENGTH];

	pev(target, pev_classname, sClassName, charsmax(sClassName));
	ArrayGetString(gMinesClass, iMinesId, minesClass, charsmax(minesClass));

	// is target lasermine?
	if(!equali(sClassName, minesClass))
		return false;

	switch(minesData[ALLOW_PICKUP])
	{
		case DISALLOW_PICKUP:
		{
			cp_cant_pickup(id);
			return false;
		}
		case ONLY_ME:
		{
			// is owner you?
			if(pev(target, MINES_OWNER) != id)
			{
				cp_cant_pickup(id);
				return false;
			}
		}
		case ALLOW_FRIENDLY:
		{
			// is team friendly?
			if(CsTeams:pev(target, MINES_TEAM) != cs_get_user_team(id))
			{
				cp_cant_pickup(id);
				return false;
			}
		}
	}

	new iReturn;
	ExecuteForward(gForwarder[FWD_CHECK_PICKUP], iReturn, id, iMinesId, target);

	// Allow Enemy.
	return true;
}

//====================================================
// Check: Buy Mines
//====================================================
stock bool:CheckBuyMines(id, iMinesId)
{
	static minesData[COMMON_MINES_DATA];
	static plData[PLAYER_DATA];
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));
	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));

	// Check common.
	if (!CheckCommon(id, plData))
		return false;

	new buymode	= 	minesData[BUY_MODE];
	new maxhave	=	minesData[AMMO_HAVE_MAX];
	new cost	= 	minesData[BUY_PRICE];
	new buyzone	=	minesData[BUY_ZONE];

	// Buy mode ON?
	if (buymode)
	{
		// Can this team buying?
		if (!CheckTeam(id, minesData))
		{
			cp_cant_buy_team(id);
			return false;
		}

		// Have Max?
		if (plData[PL_COUNT_HAVE_MINE] >= int:maxhave)
		{
			cp_have_max(id);
			return false;
		}

		// buyzone area?
		if (buyzone && !cs_get_user_buyzone(id))
		{
			cp_buyzone(id);
			return false;
		}

		// Have money?
		if (cs_get_user_money(id) < cost)
		{
			cp_no_money(id);
			return false;
		}

	}
	else
	{
		cp_cant_buy(id);
		return false;
	}

	return true;
}

//====================================================
// Check: Can use this Team.
//====================================================
stock bool:CheckTeam(id, minesData[COMMON_MINES_DATA])
{
	new CsTeams:team;

	team = CsTeams:minesData[BUY_TEAM]

	// Cvar setting equal your team? Not.
	if(team != CS_TEAM_UNASSIGNED && team != cs_get_user_team(id))
		return false;

	return true;
}

//====================================================
// Check: Max Deploy.
//====================================================
stock bool:CheckMaxDeploy(id, iMinesId, plData[PLAYER_DATA], minesData[COMMON_MINES_DATA])
{
	new max_have 	= minesData[AMMO_HAVE_MAX];
	new team_max 	= minesData[DEPLOY_TEAM_MAX];
	new team_count 	= mines_get_team_deployed_count(id, iMinesId, plData);

	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));

	// Max deployed per player.
	if (plData[PL_COUNT_HAVE_MINE] >= int:max_have)
	{
		cp_maximum_deployed(id);
		return false;
	}

	// Max deployed per team.
	if (team_count >= team_max)
	{
		cp_many_ppl(id);
		return false;
	}

	return true;
}

public CheckSpectator() 
{
	new id, szTeam[2];
	id = read_data(1);
	read_data(2, szTeam, charsmax(szTeam));

	if (szTeam[0] == 'U' || szTeam[0] == 'S')
	{
		delete_task(id);
		if (mines_remove_all_mines(id))
		{
			new namep[MAX_NAME_LENGTH];
			get_user_name(id, namep, charsmax(namep));
			cp_remove_spec(0, namep);
		}
     } 
}

public MinesBreakedMain(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	static sClassName[MAX_CLASS_LENGTH];
	static iMinesId;

	pev(victim, pev_classname, sClassName, charsmax(sClassName));
	iMinesId = ArrayFindString(gMinesClass, sClassName);

    // is this lasermine? no.
	if (iMinesId == -1)
		return HAM_IGNORED;

	new Float:health;
	mines_get_health(victim, health);
	if (health <= 0.0)
	{
		new iReturn;
		ExecuteForward(gForwarder[FWD_MINES_BREAKED], iReturn, iMinesId, victim, attacker);
	}
	return HAM_IGNORED;
}


//====================================================
// ShowInfo Hud Message
//====================================================
public MinesShowInfo(Float:vStart[3], Float:vEnd[3], Conditions, id, iTrace)
{ 
	static sClassName[MAX_CLASS_LENGTH];
	static sName[MAX_NAME_LENGTH];
	static minesData[COMMON_MINES_DATA];

	new iHit, iOwner, Float:health;
	new hudMsg[64];
	new Float:vHitPoint[3];

	iHit = get_tr2(iTrace, TR_pHit);
	get_tr2(iTrace, TR_vecEndPos, vHitPoint);				

	if (pev_valid(iHit))
	{
		static iMinesId;
		pev(iHit, pev_classname, sClassName, charsmax(sClassName));
		iMinesId = ArrayFindString(gMinesClass, sClassName);

		if (iMinesId != -1)
		{
			if (get_distance_f(vStart, vHitPoint) < 200.0) 
			{
				ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));
				iOwner = pev(iHit, MINES_OWNER);
				mines_get_health(iHit, health)
				get_user_name(iOwner, sName, charsmax(sName));
				formatex(hudMsg, charsmax(hudMsg), "%L", id, LANG_KEY_MINE_HUD, sName, floatround(health), floatround(Float:minesData[MINE_HEALTH]));
				//set_hudmessage(red = 200, green = 100, blue = 0, Float:x = -1.0, Float:y = 0.35, effects = 0, Float:fxtime = 6.0, Float:holdtime = 12.0, Float:fadeintime = 0.1, Float:fadeouttime = 0.2, channel = -1)
				set_hudmessage(50, 100, 150, -1.0, 0.60, 0, 6.0, 0.4, 0.0, 0.0, -1);
				show_hudmessage(id, hudMsg);
			}
		}
    }
} 

//====================================================
// Admin: Remove Player Lasermine
//====================================================
public admin_remove_mines(id, level, cid) 
{ 
	if (!cmd_access(id, level, cid, 2)) 
		return PLUGIN_HANDLED;

	new arga[3];
	read_argv(1, arga, charsmax(arga));

	new player = cmd_target(id, arga, CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;

	delete_task(player);
	mines_remove_all_mines(player);

	new namea[MAX_NAME_LENGTH],namep[MAX_NAME_LENGTH]; 
	get_user_name(id, namea, charsmax(namea));
	get_user_name(player, namep, charsmax(namep));
	cp_all_remove(0, namea, namep);

	return PLUGIN_HANDLED; 
} 

//====================================================
// Admin: Give Player Lasermine
//====================================================
public admin_give_mines(id, level, cid) 
{ 
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED;

	new arga[3];
	new argb[MAX_CLASS_LENGTH];
	read_argv(1, arga, charsmax(arga));
	read_argv(2, argb, charsmax(argb));

	new iMinesId = ArrayFindString(gMinesClass, argb);

	if (iMinesId == -1)
		return PLUGIN_HANDLED;

	new player = cmd_target(id, arga, CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;

	delete_task(player);
	set_start_ammo(player, iMinesId);

	new namea[MAX_NAME_LENGTH];
	new namep[MAX_NAME_LENGTH]; 

	get_user_name(id, namea, charsmax(namea)); 
	get_user_name(player, namep, charsmax(namep)); 
	cp_gave(0, namea, namep);

	return PLUGIN_HANDLED; 
} 

#if defined ZP_SUPPORT
public ZpMinesNative(iPlugin, iParams)
{
	new id 		 = get_param(1);
	new iMinesId = get_param(3);

	if (!is_user_alive(id))
		return;

	mines_stock_set_user_have_mine(id, iMinesId, int:get_param(2));
}

public zp_fw_core_infect_post(id, attacker)
{
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	// Is Connected?
	if (is_user_connected(id)) 
		delete_task(id);

	// Dead Player remove lasermine.
	mines_remove_all_mines(id);

	return PLUGIN_HANDLED;
}

public zp_fw_items_select_pre(id, itemid, ignorecost)
{
	static szMinesName[MAX_CLASS_LENGTH];
	mines_get_mines_classname(itemid, szMinesName, charsmax(szMinesName))

	if (strlen(szMinesName) <= 0)
		return ZP_ITEM_AVAILABLE;

	if (zp_core_is_zombie(id))
		return ZP_ITEM_DONT_SHOW;

	new gamemode = zp_gamemodes_get_current();

	if (gamemode == -2
	||	gamemode == gZpGameMode[GMODE_ARMAGEDDON]
	||	gamemode == gZpGameMode[GMODE_ZTAG]
	||	gamemode == gZpGameMode[GMODE_ASSASIN]
	)
	{
		zp_colored_print(id, "This is not available right now...");
		return ZP_ITEM_NOT_AVAILABLE;
	}

	static minesData[COMMON_MINES_DATA];
	static iMinesId;
	for(new i = 0; i < ArraySize(gMinesClass); i++)
	{
		ArrayGetArray(gMinesParameter, i, minesData, sizeof(minesData));
		if (minesData[ZP_WEAPON_ID] == itemid)
		{
			iMinesId = i;
			break;
		}
	}

	zp_items_menu_text_add(fmt("[%d/%d]", mines_stock_get_user_have_mine(id, iMinesId), minesData[AMMO_HAVE_MAX]));

	if (mines_stock_get_user_have_mine(id, iMinesId) >= int:have_max)
	{
		zp_colored_print(id, "You reached the limit..");
		return ZP_ITEM_NOT_AVAILABLE;
	}

	return ZP_ITEM_AVAILABLE;
}

public zp_fw_items_select_post(id, itemid, ignorecost)
{
	new sMinesName[MAX_CLASS_LENGTH];
	new iMinesId;
	for(new i = 0; i < ArraySize(gMinesClass); i++)
	{
		ArrayGetArray(gMinesParameter, i, minesData, sizeof(minesData));
		if (minesData[ZP_WEAPON_ID] == itemid)
		{
			iMinesId = i;
			break;
		}
	}

	mines_get_mines_classname(iMinesId, sMinesName, charsmax(sMinesName));
	if(strlen(sMinesName) > 0)
	{
		mines_stock_set_user_have_mine(id, iMinesId, mines_stock_get_user_have_mine(id, iMinesId) + int:1);
		cp_bought(id);
		emit_sound(id, CHAN_ITEM, ENT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
}
#endif

//====================================================
// Remove all Entity.
//====================================================
stock mines_remove_all_entity(id, className[])
{
	new iEnt = -1;
	new steamid[MAX_AUTHID_LENGTH];
	new sAuthid[MAX_AUTHID_LENGTH];
	get_user_authid(id, sAuthid, charsmax(sAuthid));

	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", className)))
	{
		if (!pev_valid(iEnt))
			continue;

		if (pev(iEnt, MINES_OWNER) == id)
		{
			pev(iEnt, pev_netname, steamid, charsmax(steamid));
			if (equali(sAuthid, steamid))
			{
				// mines_play_sound(iEnt, SOUND_STOP);
				mines_remove_entity(iEnt);
			}
		}
	}
}

stock mines_remove_entity(iEnt)
{
	new iReturn;
	ExecuteForward(gForwarder[FWD_REMOVE_ENTITY], iReturn, iEnt);
	mines_stop_laserline(iEnt);
	engfunc(EngFunc_RemoveEntity, iEnt);
}

