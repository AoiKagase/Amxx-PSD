
//=============================================
//	Plugin Writed by Visual Studio Code.
//=============================================
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
#include <ini_file>
#if defined BIOHAZARD_SUPPORT
	#include <biohazard>
#endif

#if defined ZP_SUPPORT
	#include <zombieplague>
	#include <zp50_items>
	#include <zp50_gamemodes>
	#include <zp50_colorchat>
	#include <zp50_ammopacks>
#endif

#pragma semicolon 1

//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 200
	#assert "AMX Mod X v1.10.0 or greater library required!"
#endif

#define PLUGIN 					"Mines Platform"
#define CVAR_TAG				"amx_mines"

//=====================================
//  MACRO AREA
//=====================================
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define AUTHOR 					"Aoi.Kagase"
#define VERSION 				"4.00"

// ADMIN LEVEL
#define ADMIN_ACCESSLEVEL		ADMIN_LEVEL_H

// Put Guage ID
#define TASK_PLANT				315100
#define TASK_RESET				315500
#define TASK_RELEASE			315900

#define INI_FILE				"mines/mines_resources.ini"
#define CVAR_FILE				"mines/mines_cvars.cfg"
//====================================================
//  Enum Area.
//====================================================
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
//  GLOBAL VARIABLES.
//====================================================
new gBoom;
new gMsgBarTime;
new gEntMine;
new gSubMenuCallback;
new gCvar				[CVAR_SETTING];
new gSelectedMines		[MAX_PLAYERS];

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	precache_sound(ENT_SOUND);
	precache_sound(ENT_SOUND1);
	precache_sound(ENT_SOUND2);
	precache_sound(ENT_SOUND3);
	gBoom = precache_model(ENT_SPRITE);
	
	return PLUGIN_CONTINUE;
}

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Add your code here...
	register_concmd("mines_remove", "admin_remove_mines",ADMIN_ACCESSLEVEL, " - <userid>"); 
	register_concmd("mines_give", 	"admin_give_mines",  ADMIN_ACCESSLEVEL, " - <userid> <minesId>"); 

	// Add your code here...
	register_clcmd("+mdeploy", "mines_cmd_progress_deploy");
	register_clcmd("+mpickup", "mines_cmd_progress_pickup");
   	register_clcmd("-mdeploy", "mines_cmd_progress_stop");
   	register_clcmd("-mpickup", "mines_cmd_progress_stop");
	register_clcmd("say", 		"say_mines");

	// CVar settings.
	// Common.
	gCvar[CVAR_ENABLE]				= register_cvar(fmt("%s%s", CVAR_TAG, "_enable"),		"1"	);	// 0 = off, 1 = on.
	gCvar[CVAR_ACCESS_LEVEL]		= register_cvar(fmt("%s%s", CVAR_TAG, "_access"),		"0"	);	// 0 = all, 1 = admin
	gCvar[CVAR_START_DELAY]			= register_cvar(fmt("%s%s", CVAR_TAG, "_round_delay"),	"5"	);	// Round start delay time.
	gCvar[CVAR_FRIENDLY_FIRE]		= get_cvar_pointer("mp_friendlyfire");							// Friendly fire. 0 or 1

	gForwarder[FWD_SET_ENTITY_SPAWN]= CreateMultiForward("mines_entity_spawn_settings"	, ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	gForwarder[FWD_PUTIN_SERVER]	= CreateMultiForward("mines_client_putinserver"		, ET_IGNORE, FP_CELL);
	gForwarder[FWD_DISCONNECTED] 	= CreateMultiForward("mines_client_disconnected"	, ET_IGNORE, FP_CELL);
	gForwarder[FWD_REMOVE_ENTITY]	= CreateMultiForward("mines_remove_entity"			, ET_IGNORE, FP_CELL);
	gForwarder[FWD_PLUGINS_END] 	= CreateMultiForward("mines_plugin_end"				, ET_IGNORE);
	gForwarder[FWD_CHECK_PICKUP]	= CreateMultiForward("CheckForPickup"				, ET_STOP,   FP_CELL, FP_CELL, FP_CELL);
	gForwarder[FWD_CHECK_DEPLOY]	= CreateMultiForward("CheckForDeploy"				, ET_STOP,   FP_CELL, FP_CELL);
	gForwarder[FWD_CHECK_BUY]	 	= CreateMultiForward("CheckForBuy"					, ET_STOP,   FP_CELL, FP_CELL);
	gForwarder[FWD_MINES_THINK]		= CreateMultiForward("MinesThink"					, ET_IGNORE, FP_CELL, FP_CELL);
	gForwarder[FWD_MINES_PICKUP]	= CreateMultiForward("MinesPickup"					, ET_IGNORE, FP_CELL, FP_CELL);
	gForwarder[FWD_MINES_BREAKED]	= CreateMultiForward("MinesBreaked"					, ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);

	gMinesClass 					= ArrayCreate(MAX_CLASS_LENGTH);
	gMinesParameter 				= ArrayCreate(COMMON_MINES_DATA);
	gMinesLongName					= ArrayCreate(MAX_NAME_LENGTH);

	// Get Message Id
	gMsgBarTime						= get_user_msgid("BarTime");
	gSubMenuCallback				= menu_makecallback("mines_submenu_callback");

	for(new i = 0; i < MAX_PLAYERS; i++)
		gPlayerData[i] = ArrayCreate(PLAYER_DATA);

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

//====================================================
//  PLUGIN END
//====================================================
public plugin_end()
{
	// Forward Plugin End Function.
	ExecuteForward(gForwarder[FWD_PLUGINS_END]);

	// Destroy Fowards
	for (new i = 0; i < FORWARDER; i++)
		DestroyForward(gForwarder[i]);

	// Destroy Arrays
	ArrayDestroy(gMinesClass);
	ArrayDestroy(gMinesParameter);
	ArrayDestroy(gMinesLongName);

	for (new i = 0; i < MAX_PLAYERS; i++)
		ArrayDestroy(gPlayerData[i]);
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
	get_configsdir(file, len);
	format(file, len, "%s/%s", file, CVAR_FILE);
	if(file_exists(file)) 
	{
		server_cmd("exec %s", file);
		server_exec();
	}
}

//====================================================
//  PLUGIN NATIVES
//====================================================
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
	register_native("mines_register_dictionary","_native_register_dictionary");

#if defined ZP_SUPPORT
	register_native("zp_give_lm", 				"ZpMinesNative");
#endif
}

//====================================================
//  Native Functions
//====================================================
// Register Mines.
public _native_register_mines(iPlugin, iParams)
{
	new className	[MAX_CLASS_LENGTH];
	new sLongName	[MAX_NAME_LENGTH];
	new minesData	[COMMON_MINES_DATA];
	new plData		[PLAYER_DATA];
	new iMinesId = -1;

	get_string	(1, className, charsmax(className));
	get_array	(2, minesData, sizeof(minesData));
	get_string	(3, sLongName, charsmax(sLongName));

	#if defined ZP_SUPPORT
		new zpWeaponId					= zp_items_register(className, minesData[BUY_PRICE]);
		gZpGameMode[GMODE_ARMAGEDDON]	= zp_gamemodes_get_id("Armageddon Mode");
		gZpGameMode[GMODE_ZTAG] 		= zp_gamemodes_get_id("Zombie Tag Mode");
		gZpGameMode[GMODE_ASSASIN]		= zp_gamemodes_get_id("Assassin Mode");
		minesData[ZP_WEAPON_ID]			= zpWeaponId;
	#endif

	// register mines classname/parameter/longname key
	iMinesId = ArrayPushString(gMinesClass, className);
	ArrayPushArray	(gMinesParameter, 	minesData);
	ArrayPushString	(gMinesLongName, 	sLongName);

	// initialize player data.
	for(new i = 0; i < MAX_PLAYERS; i++)
		ArrayPushArray(gPlayerData[i], plData, sizeof(plData));

	return iMinesId;
}

// Register Dictionary
public _native_register_dictionary(iPlugin, iParams)
{
	new sDictionary[64];
	get_string(1, sDictionary, charsmax(sDictionary));
	register_dictionary(sDictionary);
}

// is valid Take Damage.
public _native_is_valid_takedamage(iPlugin, iParams) 
{
	return is_valid_takedamage(get_param(1), get_param(2));
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

// Buy mines.
public _native_buy_mines(iPlugin, iParams)
{	
#if !defined ZP_SUPPORT
	mines_buy_mine(get_param(1), get_param(2));
#endif
	return PLUGIN_HANDLED;
}

// mines_mines_explosion(id, iMinesId, iEnt);
public _native_mines_explosion(iPlugin, iParams)
{
	new id		 = get_param(1);
	new iMinesId = get_param(2);
	new iEnt	 = get_param(3); 

	static plData[PLAYER_DATA];
	static minesData[COMMON_MINES_DATA];

	// Stopping entity to think
	set_pev(iEnt, pev_nextthink, 0.0);

	// reset deploy count.
	// Count down. deployed lasermines.
	ArrayGetArray(gPlayerData[id], iMinesId, plData, 	sizeof(plData));
	plData[PL_COUNT_DEPLOYED]--;
	ArraySetArray(gPlayerData[id], iMinesId, plData, 	sizeof(plData));
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));

	if (minesData[EXPLODE_SPRITE])
		mines_create_explosion(iEnt, minesData[EXPLODE_SPRITE]);
	else
		// effect explosion. (default sprite)
		mines_create_explosion(iEnt, gBoom);
	
	// damage.
	mines_create_explosion_damage(iEnt, id, Float:minesData[EXPLODE_DAMAGE], Float:minesData[EXPLODE_RADIUS]);

	// remove this.
	mines_remove_entity(iEnt);
}

// mines_read_resources(section, key, value, size);
public _native_read_ini_resources(iMinesId, key[], value[], size, def[])
{
	new inifile[64];
	new sClassName[MAX_CLASS_LENGTH];
	ArrayGetArray(gMinesClass, iMinesId, sClassName, charsmax(sClassName));

	get_configsdir(inifile, charsmax(inifile));
	formatex(inifile, charsmax(inifile), "%s/%s", inifile, INI_FILE);

	new result = ini_read_string(inifile, sClassName, key, value, size);

	if (result <= 0)
		formatex(value, size, "%s", def);
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
			// Removing already put mines.
			mines_remove_all_entity_main(id, i);
			// Round start set ammo.
			set_start_ammo(id, i);
		}
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Client Commands
//====================================================
public mines_cmd_progress_deploy(id)
{
	mines_progress_deploy(id, gSelectedMines[id]);
}
public mines_cmd_progress_pickup(id)
{
	mines_progress_pickup(id, gSelectedMines[id]);
}
public mines_cmd_progress_stop(id)
{
	mines_progress_stop(id);
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
	new vID = read_data(2); // victim

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
// Put mines Start Progress A
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
	// Start Task. Put mines.
	set_task(wait, "SpawnMine", (TASK_PLANT + id), sMineId, charsmax(sMineId));

	return PLUGIN_HANDLED;
}

//====================================================
// Removing target put mines.
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
	// Start Task. Remove mines.
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
// Task: Spawn mines.
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

		show_ammo(id, iMinesId);
	}
	return iReturn;
}

//====================================================
// Task: Remove mines.
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

	// Check. is Target Entity mines?
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
	// Collect for this removed mines.
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

	show_ammo(id, iMinesId);

	return;
}

//====================================================
// Brocken Mines.
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

//====================================================
// Mines Think.
//====================================================
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
// Check Spectartor
//====================================================
public MinesBreakedMain(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	static sClassName[MAX_CLASS_LENGTH];
	static iMinesId;

	pev(victim, pev_classname, sClassName, charsmax(sClassName));
	iMinesId = ArrayFindString(gMinesClass, sClassName);

    // is this mines? no.
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
				mines_get_health(iHit, health);
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

			new bool:now_speed = (speed <= 1.0);
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
public client_disconnected(id)
{
	// check plugin enabled.
	if(!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;
	
	new iReturn;
	ExecuteForward(gForwarder[FWD_DISCONNECTED], iReturn, id);

	// delete task.
	delete_task(id);
	// remove all mines.
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
// Check: Remove mines.
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

	// is target mines?
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
// Check Spectartor
//====================================================
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

//====================================================
// Admin: Remove Player mines
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

	cp_all_remove(0, id, player);

	return PLUGIN_HANDLED; 
} 

//====================================================
// Admin: Give Player mines
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

	cp_gave(0, player);

	return PLUGIN_HANDLED; 
} 

//====================================================
// Show ammo.
//====================================================
show_ammo(id, iMinesId)
{ 
	new ammo[64];
	new minesData[COMMON_MINES_DATA];
	new plData[PLAYER_DATA];

	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));
	if (is_user_connected(id))
	{
		if (minesData[BUY_MODE] != 0)
		{
			ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));
			formatex(ammo, charsmax(ammo), "%L", id, LANG_KEY_STATE_AMMO, plData[PL_COUNT_HAVE_MINE], minesData[AMMO_HAVE_MAX]);
			client_print(id, print_center, ammo);
		}
	}
} 

//====================================================
// Say Command (Menu Open).
//====================================================
public say_mines(id)
{
	new said[32];
	read_argv(1, said, 31);

	if (equali(said, "mines") || equali(said, "/mines"))
	{
		mines_show_menu(id, 0);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Mines Menu.
//====================================================
public mines_show_menu(id, iPage)
{
	new count = ArraySize(gMinesClass);
	if (count <= 0)
		return;
	
	new sMenuTitle[32];
	formatex(sMenuTitle, charsmax(sMenuTitle), "%L", id, LANG_KEY_MENU_TITLE);
	new menu = menu_create(sMenuTitle, "mines_menu_handler");
	new sItemName[MAX_NAME_LENGTH];
	for(new i = 0; i < count; i++)
	{
		ArrayGetString(gMinesLongName, i, sItemName, charsmax(sItemName));
		formatex(sItemName, charsmax(sItemName), "%L", id, sItemName);
		menu_additem(menu, sItemName);
	}

	menu_display(id, menu, iPage);
}

//====================================================
// Mines Menu Handler.
//====================================================
public mines_menu_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	mines_show_menu_sub(id, item);
}

//====================================================
// Mines Sub Menu.
//====================================================
public mines_show_menu_sub(id, iMinesId)
{
	new sMenuTitle[32];
	new sMinesId[3];
	new sItemName[MAX_NAME_LENGTH];

	num_to_str(iMinesId, sMinesId, charsmax(sMinesId));
	ArrayGetString(gMinesLongName, iMinesId, sItemName, charsmax(sItemName));
	formatex(sItemName, charsmax(sItemName), "%L", id, sItemName);
	formatex(sMenuTitle, charsmax(sMenuTitle), "%L", id, LANG_KEY_SUB_MENU_TITLE, sItemName);

	new menu = menu_create(sMenuTitle, "mines_menu_sub_handler");
	new minesData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));

	menu_additem(menu, fmt("%L", id, LANG_KEY_MENU_SELECT,		sItemName), 						sMinesId, 0, gSubMenuCallback);
	#if defined ZP_SUPPORT
		menu_addblank2(menu);
	#else
		menu_additem(menu, fmt("%L", id, LANG_KEY_MENU_BUY, 		sItemName, minesData[BUY_PRICE]), 	sMinesId, 0, gSubMenuCallback);
	#endif
	menu_addblank2(menu);
	menu_additem(menu, fmt("%L", id, LANG_KEY_MENU_DEPLOY, 		sItemName), 						sMinesId);
	menu_additem(menu, fmt("%L", id, LANG_KEY_MENU_PICKUP, 		sItemName), 						sMinesId);
	menu_addblank2(menu);
	menu_additem(menu, fmt("%L", id, LANG_KEY_MENU_EXPLOSION, 	sItemName), 						sMinesId);

	menu_setprop(menu, MPROP_EXIT, MEXIT_FORCE);

	menu_display(id, menu, 0);
}

//====================================================
// Mines Sub Menu Callback.
//====================================================
public mines_submenu_callback(id, menu, item)
{
	new szData[6], szName[64];
	new item_access, item_callback;
	//Get information about the menu item
	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
	new iMinesId = str_to_num(szData);
	new minesData[COMMON_MINES_DATA];

	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));

	switch(item)
	{
		case 0:
		{
			if (gSelectedMines[id] == iMinesId)
			{
				formatex(szName, charsmax(szName), "%s\R\y[SELECTED]", szName);
				menu_item_setname(menu, item, szName);
				return ITEM_DISABLED;
			}
		}
		case 1:
		{
			if (!minesData[BUY_MODE])
			{
				return ITEM_DISABLED;
			}
		}
	}
	return ITEM_IGNORE;
}

//====================================================
// Mines Sub Menu Handler.
//====================================================
public mines_menu_sub_handler(id, menu, item)
{
	new szData[6], szName[64];
	new item_access, item_callback;
    //Get information about the menu item
	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);

	new iMinesId = str_to_num(szData);
	switch(item)
	{
		// Select current Mines.
		case 0:
		{
			gSelectedMines[id] = iMinesId;
			// Play sound.
			emit_sound(id, CHAN_ITEM, ENT_SOUND3, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		// Buy Mines.
		case 1:
			mines_buy_mine			(id, iMinesId);
		// Deploy Mines.
		case 3:
			mines_progress_deploy	(id, iMinesId);
		// Pickup Mines.
		case 4:
			mines_progress_pickup	(id, iMinesId);
		// All Mines Explosion.(current selected mines.)
		case 6:
			mines_all_explosion		(id, iMinesId);
		// 
		case MENU_EXIT:
		{
			if (is_user_connected(id))
			{
				mines_show_menu(id, .iPage = (item / 7));
			}
			return PLUGIN_HANDLED;
		}
	}
	mines_show_menu_sub(id, iMinesId);
	return PLUGIN_HANDLED;
}

//====================================================
// Zombie Plague Support Logic.
//====================================================
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

	// Dead Player remove mines.
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
