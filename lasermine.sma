//=============================================
//	Plugin Writed by Visual Studio Code.
//=============================================

// Supported BIOHAZARD.
// #define BIOHAZARD_SUPPORT

// Supported More money than 16000.
// #define UL_MONEY_SUPPORT

/*=====================================*/
/*  INCLUDE AREA				       */
/*=====================================*/
#include <amxmodx>
#include <amxconst>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#if defined BIOHAZARD_SUPPORT
	#include <biohazard>
#endif

#if defined UL_MONEY_SUPPORT
	#include <money_ul>
#endif


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

#if defined BIOHAZARD_SUPPORT
	#define PLUGIN 					"Lasermine for BIOHAZARD"
	#define VERSION 				"3.0"

	#define CHAT_TAG 				"[BioLaser]"
	#define CVAR_TAG				"bio_ltm_"

	#define STR_CBT					"Your Zombie! Can't buy and deploying lasermine!"
#else
	#define PLUGIN 					"Laser/Tripmine Entity"
	#define VERSION 				"3.0"

	#define CHAT_TAG 				"[Lasermine]"
	#define CVAR_TAG				"amx_ltm_"

	#define STR_CBT					"Your Team Can't buy and deploying lasermine!"
#endif

#define ENT_MODELS					"models/v_tripmine.mdl"
#define ENT_SOUND1					"weapons/mine_deploy.wav"
#define ENT_SOUND2					"weapons/mine_charge.wav"
#define ENT_SOUND3					"weapons/mine_activate.wav"
#define ENT_SOUND4					"debris/beamstart9.wav"
#define ENT_SOUND5					"items/gunpickup2.wav"
#define ENT_SOUND6					"debris/bustglass1.wav"
#define ENT_SOUND7					"debris/bustglass2.wav"
#define ENT_SPRITE1 				"sprites/laserbeam.spr"
#define ENT_SPRITE2 				"sprites/zerogxplode.spr"

#define ENT_CLASS_NAME1				"lasermine"
#define ENT_CLASS_NAME2				"info_target"
#define ENT_CLASS_NAME3				"func_breakable"
#define ENT_CLASS_NAME4				"tripmine"

//#define STR_MINEDETNATED 		"Your mine has detonated.",
//#define STR_MINEDETNATED2		"detonated your mine.",
#define STR_NOTACTIVE 				"Lasermines are not currently active."
#define STR_DONTHAVEMINE			"You don't have lasermine."
//#define STR_CANTDEPLOY			"Your team can't deploying lasermine!"
#define STR_MAXDEPLOY				"Maximum mines have been deployed."
#define STR_MANYPPL					"Too many ppl on your team..."
#define STR_PLANTWALL				"You must plant the lasermine on a wall!"
#define STR_PLANTGROUND				"You must plant the Claymore on a ground!"
#define STR_REF						"Refer to a lasermine rule with this server. say 'lasermine'"
#define STR_CANTBUY					"Can't buying this server."
#define STR_HAVEMAX					"You have a maximum lasermine."
#define STR_NOMONEY					"You don't have enough money to buy a lasermine! ($"
#define STR_DELAY					"You can buying and deploying lasermine in after "
#define STR_BOUGHT					"You have successfully bought a lasermine."
#define STR_STATE					"LaserMines Ammo:"
#define STR_NOACCESS				"You can't access, this command."

// Remove Lasermine Entity Macro
#define remove_entity(%1)			engfunc(EngFunc_RemoveEntity, %1)

// ADMIN LEVEL
#define ADMIN_ACCESSLEVEL			ADMIN_LEVEL_H

// Put Guage ID
#define TASK_PLANT					15100
#define TASK_RESET					15500
#define TASK_RELEASE				15900

// Lasermine Data Save Area.
#define LASERMINE_TEAM				pev_iuser1
#define LASERMINE_OWNER				pev_iuser2
#define LASERMINE_STEP				pev_iuser3
#define LASERMINE_HITING			pev_iuser4
#define LASERMINE_COUNT				pev_fuser1
#define LASERMINE_POWERUP			pev_fuser2
#define LASERMINE_BEAMTHINK			pev_fuser3
#define LASERMINE_BEAMENDPOINT1		pev_vuser1
#define LASERMINE_BEAMENDPOINT2		pev_vuser2
#define LASERMINE_BEAMENDPOINT3		pev_vuser3

#define MAX_PLAYERS					32
#define MAX_MINES					10
#define OFFSET_TEAM 				114
#define OFFSET_MONEY				115
#define OFFSET_DEATH	 			444

// CS Status Data.
#define cs_get_user_team(%1)		CsTeams:get_offset_value(%1,OFFSET_TEAM)
#define cs_get_user_deaths(%1)		get_offset_value(%1,OFFSET_DEATH)
#define cs_get_user_money(%1)		get_offset_value(%1,OFFSET_MONEY)
#define cs_set_user_money(%1,%2)	set_offset_value(%1,OFFSET_MONEY,%2)

// Client Print Command Macro.
#define cp_debug(%1)				client_print(%1, print_chat, "[Laesrmine Debug] Can't Create Entity")
#define cp_not_active(%1)			client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_NOTACTIVE)
#define cp_not_access(%1)			client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_NOACCESS)
#define cp_cant_buy_team(%1)		client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_CBT)
#define cp_dont_have(%1)			client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_DONTHAVEMINE)
#define cp_cant_buy(%1)				client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_CANTBUY)
#define cp_have_max(%1)				client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_HAVEMAX)
#define	cp_no_money(%1)				client_print(%1, print_chat, "%s %s%d%s", CHAT_TAG, STR_NOMONEY, get_pcvar_num(gCvar[CVAR_COST]), " needed)")
#define cp_delay_time(%1)			client_print(%1, print_chat, "%s %s%d%s", CHAT_TAG, STR_DELAY, int:get_pcvar_num(gCvar[CVAR_START_DELAY]) - gNowTime, " seconds.")
#define cp_maximum_deployed(%1)		client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_MAXDEPLOY)
#define cp_many_ppl(%1)				client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_MANYPPL)
#define cp_must_wall(%1)			client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_PLANTWALL)
#define cp_must_ground(%1)			client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_PLANTGROUND)
#define cp_bought(%1)				client_print(%1, print_chat, "%s %s", CHAT_TAG, STR_BOUGHT)
#define cp_refer(%1)				client_print(%1, print_chat, STR_REF)

//====================================================
// ENUM AREA
//====================================================
//
// Tripmine Action Control
//
enum TRIPMINE_MODE
{
	MODE_LASERMINE			= 0,
	MODE_TRIPMINE			= 1,
	MODE_BF4_CLAYMORE		= 2,
}
enum TRIPMINE_STATE
{
	TRIPMINE_IDLE1			= 0,
	TRIPMINE_IDLE2			= 1,
	TRIPMINE_ARM1			= 2,
	TRIPMINE_ARM2			= 3,
	TRIPMINE_FIDGET			= 4,
	TRIPMINE_HOLSTER		= 5,
	TRIPMINE_DRAW			= 6,
	TRIPMINE_WORLD			= 7,		// Put.
	TRIPMINE_GROUND			= 8,
};

enum TRIPMINE_THINK
{
	POWERUP_THINK			= 0,
	BEAMBREAK_THINK			= 1,
	EXPLOSE_THINK			= 2,
};

enum TRIPMINE_SOUND
{
	POWERUP_SOUND			= 0,
	ACTIVATE_SOUND			= 1,
	STOP_SOUND				= 2,
};

//
// CHECK ERROR CODE
//
enum ERROR
{
	NONE					= 0,
	NOT_ACTIVE				= 1,
	NOT_ACCESS				= 2,
	DONT_HAVE				= 3,
	CANT_BUY_TEAM			= 4,
	CANT_BUY				= 5,
	HAVE_MAX				= 6,
	NO_MONEY				= 7,
	MAXIMUM_DEPLOYED		= 8,
	MANY_PPL				= 9,
	DELAY_TIME				= 10,
	NOT_ALIVE				= 11,
	MUST_WALL				= 12,
	MUST_GROUND				= 13,
};

//
// CVAR SETTINGS
//
enum CVAR_SETTING
{
	CVAR_ENABLE             = 0,    // Plugin Enable.
	CVAR_ACCESS_LEVEL       = 1,    // Access level for 0 = ADMIN or 1 = ALL.
	CVAR_CMD_MODE           = 2,    // 0 = +USE key, 1 = bind, 2 = each.
	CVAR_MODE               = 3,    // 0 = Lasermine, 1 = Tripmine.
	CVAR_MAX_HAVE           = 4,    // Max having ammo.
	CVAR_START_HAVE         = 5,    // Start having ammo.
	CVAR_FRAG_MONEY         = 6,    // Get money per kill.
	CVAR_COST               = 7,    // Buy cost.
	CVAR_LASER_DMG          = 8,    // Laser hit Damage.
	CVAR_TEAM_MAX           = 9,    // Max deployed in team.
	CVAR_EXPLOSE_RADIUS     = 10,   // Explosion Radius.
	CVAR_EXPLOSE_DMG        = 11,   // Explosion Damage.
	CVAR_FRIENDLY_FIRE      = 12,   // Friendly Fire.
	CVAR_CBT                = 13,   // Can buy team. TR/CT/ALL
	CVAR_BUY_MODE           = 14,   // Buy mode. 0 = off, 1 = on.
	CVAR_START_DELAY        = 15,   // Round start delay time.
	// Laser design.
	CVAR_LASER_VISIBLE      = 16,   // Laser line Visiblity. 0 = off, 1 = on.
	CVAR_LASER_BRIGHT       = 17,   // Laser line brightness.
	CVAR_LASER_COLOR        = 18,   // Laser line color. 0 = team color, 1 = green
	CVAR_LASER_DMG_MODE     = 19,   // Laser line damage mode. 0 = frame rate dmg, 1 = once dmg, 2 = 1second dmg.
	CVAR_LASER_DMG_DPS      = 20,   // Laser line damage mode 2 only, damage/seconds. default 1 (sec)
	CVAR_MINE_HEALTH        = 21,   // Lasermine health. (Can break.)
	CVAR_MINE_GLOW          = 22,   // Glowing tripmine.
	CVAR_DEATH_REMOVE		= 23,	// Dead Player Remove Lasermine.
	CVAR_LASER_PUT_WAIT		= 24,	// Waiting for put lasermine. (0 = no progress bar.)
	CVAR_LASER_RANGE		= 25,	// Laserbeam range.
//  CVAR_LASER_THINK        = 21,   // Laser line think.
};

//
// PLAYER DATA AREA
//
enum PLAYER_DATA_INT
{
	PLAYER_DELAY_COUNT		= 0,
	PLAYER_HAVE_MINE		= 1,
	PLAYER_MINE_SETTING		= 2,
	PLAYER_DEPLOYED			= 3,
}
enum PLAYER_DATA_FLOAT
{
	PLAYER_MAX_SPEED		= 0,
}
enum int:PLAYER_DEPLOY_STATE
{
	STATE_IDLE				= 0,
	STATE_DEPLOYING			= 1,
	STATE_DEPLOYED			= 2,
}

//====================================================
//  GLOBAL VARIABLES
//====================================================
new gEntMine;
new gCvar[CVAR_SETTING];
new int:gPlayerInt[MAX_PLAYERS][PLAYER_DATA_INT];
new Float:gPlayerFloat[MAX_PLAYERS][PLAYER_DATA_FLOAT];
new gBeam, gBoom
new int:gNowTime
new gMsgDeathMsg, gMsgDamage, gMsgStatusText, gMsgBarTime;
#if !defined UL_MONEY_SUPPORT
	new gMsgMoney;
#endif

const m_iDeaths = 711;

//====================================================
//  Player Data functions
//====================================================
stock set_user_delay_count		(id, int:value) 	{ gPlayerInt[id][PLAYER_DELAY_COUNT] = int:value; }
stock set_user_have_mine		(id, int:value) 	{ gPlayerInt[id][PLAYER_HAVE_MINE] = int:value; }
stock set_user_mine_deployed	(id, int:value)		{ gPlayerInt[id][PLAYER_DEPLOYED] = int:value; }
stock set_user_deploy_state		(id, int:value)		{ gPlayerInt[id][PLAYER_MINE_SETTING] = int:value; }
stock set_user_health			(id, Float:health)	{ health > 0 ? set_pev(id, pev_health, health) : user_kill(id, 1); }
stock set_user_frags			(id, int:frags)		{ set_pev(id, pev_frags, frags); }
stock save_user_max_speed		(id, Float:value)	{ gPlayerFloat[id][PLAYER_MAX_SPEED] = Float:value; }
stock set_user_max_speed		(id, Float:value)	{ engfunc(EngFunc_SetClientMaxspeed, id, value);set_pev(id, pev_maxspeed, value); }

stock int:get_user_delay_count	(id) 				{ return int:gPlayerInt[id][PLAYER_DELAY_COUNT]; }
stock int:get_user_have_mine	(id) 				{ return int:gPlayerInt[id][PLAYER_HAVE_MINE]; }
stock int:get_user_mine_deployed(id) 				{ return int:gPlayerInt[id][PLAYER_DEPLOYED]; }
stock int:get_user_deploy_state	(id)				{ return int:gPlayerInt[id][PLAYER_MINE_SETTING]; }
stock Float:load_user_max_speed	(id)				{ return Float:gPlayerFloat[id][PLAYER_MAX_SPEED]; }
stock Float:get_user_max_speed	(id)				{ return Float:pev(id, pev_maxspeed); }
stock Float:fm_get_user_health	(id)
{
	new Float:health;
	pev(id, pev_health, health);
	return health;
}
stock fm_get_user_frags			(id)				{ return pev(id, pev_frags); }
stock bool:fm_is_user_godmode	(id) 				{ return (pev(id, pev_takedamage) == DAMAGE_NO); }
stock bool:fm_is_user_alive		(id)				{ return (pev(id,pev_deadflag) == DEAD_NO); }

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Add your code here...
	register_clcmd("+setlaser", "LaserMineProgressB");
	register_clcmd("+dellaser", "RemoveProgress");
   	register_clcmd("-setlaser", "StopProgress");
   	register_clcmd("-dellaser", "StopProgress");
	register_clcmd("say", "SayLasermine");
	register_clcmd("buy_lasermine", "BuyLasermine");

	new cvar_command[32] = "^0";
	// CVar settings.
	// Common.
	format(cvar_command, 31, "%s", CVAR_TAG);
	gCvar[CVAR_ENABLE]	        = register_cvar(cvar_command,   "1");   	// 0 = off, 1 = on.

	format(cvar_command, 31, "%s%s", CVAR_TAG, "acs");
	gCvar[CVAR_ACCESS_LEVEL]   	= register_cvar(cvar_command,   "0");   	// 0 = all, 1 = admin
	format(cvar_command, 31, "%s%s", CVAR_TAG, "mode");
	gCvar[CVAR_MODE]           	= register_cvar(cvar_command,   "0");   	// 0 = lasermine, 1 = tripmine, 2 = claymore wire trap
	format(cvar_command, 31, "%s%s", CVAR_TAG, "ff");
	gCvar[CVAR_FRIENDLY_FIRE]  	= register_cvar(cvar_command,   "0");   	// Friendly fire. 0 or 1
	format(cvar_command, 31,"%s%s", CVAR_TAG, "delay");
	gCvar[CVAR_START_DELAY]    	= register_cvar(cvar_command,   "5");  		// Round start delay time.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "cmdmode");
	gCvar[CVAR_CMD_MODE]	    = register_cvar(cvar_command,   "1");  		// 0 is +USE key, 1 is bind, 2 is each.

	// Ammo.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "ammo");
	gCvar[CVAR_MAX_HAVE]       	= register_cvar(cvar_command,   "2");   	// Max having ammo.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "teammax");
	gCvar[CVAR_TEAM_MAX]		= register_cvar(cvar_command,   "10"); 		// Max deployed in team.

	// Buy system.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "buymode");
	gCvar[CVAR_BUY_MODE]	    = register_cvar(cvar_command,   "1");   	// 0 = off, 1 = on.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "cbt");
	gCvar[CVAR_CBT]    			= register_cvar(cvar_command,   "ALL");	 	// Can buy team. TR / CT / ALL.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "cost");
	gCvar[CVAR_COST]           	= register_cvar(cvar_command,   "2500");	// Buy cost.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "fragmoney");
	gCvar[CVAR_FRAG_MONEY]     	= register_cvar(cvar_command,   "300"); 	// Get money.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "startammo");
	gCvar[CVAR_START_HAVE]	    = register_cvar(cvar_command,   "1");   	// Round start have ammo count.

	// Laser design.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "line");
	gCvar[CVAR_LASER_VISIBLE]	= register_cvar(cvar_command,   "1");   	// Laser line visibility.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "color");
	gCvar[CVAR_LASER_COLOR]    	= register_cvar(cvar_command,   "0");   	// laser line color 0 = team color, 1 = green.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "bright");
	gCvar[CVAR_LASER_BRIGHT]   	= register_cvar(cvar_command,   "255"); 	// laser line brightness.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "dmg");
	gCvar[CVAR_LASER_DMG]      	= register_cvar(cvar_command,   "60.0"); 	// laser hit dmg. Float Value!
	format(cvar_command, 31, "%s%s", CVAR_TAG, "ldmgmode");
	gCvar[CVAR_LASER_DMG_MODE]	= register_cvar(cvar_command,   "0");   	// Laser line damage mode. 0 = frame dmg, 1 = once dmg, 2 = 1 second dmg.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "ldmgseconds");
	gCvar[CVAR_LASER_DMG_DPS]  	= register_cvar(cvar_command,   "1");   	// laser line damage mode 2 only, damage/seconds. default 1 (sec)

	format(cvar_command, 31, "%s%s", CVAR_TAG, "health");
	gCvar[CVAR_MINE_HEALTH]    	= register_cvar(cvar_command,   "500"); 	// Tripmine Health. (Can break.)
	format(cvar_command, 31, "%s%s", CVAR_TAG, "glow");
	gCvar[CVAR_MINE_GLOW]      	= register_cvar(cvar_command,   "1");   	// Tripmine glowing. 0 = off, 1 = on.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "radius");
	gCvar[CVAR_EXPLOSE_RADIUS] 	= register_cvar(cvar_command,   "320.0");	// Explosion radius.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "rdmg");
	gCvar[CVAR_EXPLOSE_DMG]		= register_cvar(cvar_command,   "100"); 	// Explosion radius damage.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "death_remove");
	gCvar[CVAR_DEATH_REMOVE]	= register_cvar(cvar_command,   "0"); 		// Dead Player remove lasermine. 0 = off, 1 = on.
	format(cvar_command, 31, "%s%s", CVAR_TAG, "put_wait");
	gCvar[CVAR_LASER_PUT_WAIT]	= register_cvar(cvar_command,   "1"); 		// Waiting for put lasermine. (int:seconds. 0 = no progress bar.)
	format(cvar_command, 31, "%s%s", CVAR_TAG, "lrange");
	gCvar[CVAR_LASER_RANGE]		= register_cvar(cvar_command,   "8192.0"); 	// Laser beam lange (float range.)

	RegisterHam(Ham_Spawn, "player", "NewRound", 1);
	RegisterHam(Ham_Item_PreFrame,"player","KeepMaxSpeed", 1);

	// register_event("HLTV", 		"NewRound", 	"a", "1=0", "2=0") 
	register_event("DeathMsg",  "DeathEvent",   "a");

	gMsgDeathMsg 	= get_user_msgid("DeathMsg");
	gMsgDamage 		= get_user_msgid("Damage");
	gMsgStatusText 	= get_user_msgid("StatusText");
	gMsgBarTime		= get_user_msgid("BarTime");
#if !defined UL_MONEY_SUPPORT
	gMsgMoney	    = get_user_msgid("Money");
#endif

	// -- Forward.
	register_forward(FM_Think, 			"LaserThink");
	register_forward(FM_PlayerPostThink,"PlayerPostThink");
	register_forward(FM_PlayerPreThink, "PlayerPreThink");

	return PLUGIN_CONTINUE;
}

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	precache_sound(ENT_SOUND1);
	precache_sound(ENT_SOUND2);
	precache_sound(ENT_SOUND3);
	precache_sound(ENT_SOUND4);
	precache_sound(ENT_SOUND5);
	precache_sound(ENT_SOUND6);
	precache_sound(ENT_SOUND7);
	precache_model(ENT_MODELS);
	gBeam = precache_model(ENT_SPRITE1);
	gBoom = precache_model(ENT_SPRITE2);
	
	return PLUGIN_CONTINUE;
}

//====================================================
//  PLUGIN REQUIRE MODULE
//====================================================
/* 
	1.8.3
	symbol "plugin_modules" is marked as deprecated: 
	Module dependency is now automatically handled by the compiler. 
	This forward is no longer called.
*/
/*
public plugin_modules() 
{
	require_module("fakemeta");
	require_module("hamsandwich");
}
*/

//====================================================
//  PLUGIN CONFIG
//====================================================
public plugin_cfg()
{
	// registered func_breakable
	gEntMine = engfunc(EngFunc_AllocString, ENT_CLASS_NAME3);

	new file[64];
	get_localinfo("amxx_configsdir", file, 63);

#if defined BIOHAZARD_SUPPORT
	format(file, 63, "%s/bhltm_cvars.cfg", file);
#else
	format(file, 63, "%s/ltm_cvars.cfg", file);
#endif
	if(file_exists(file)) 
	{
		server_cmd("exec %s", file);
		server_exec();
	}
}

//====================================================
// Round Start Initialize
//====================================================
public NewRound(id)
{
	// Check Plugin Enabled
	if (!get_pcvar_num( gCvar[CVAR_ENABLE] ))
		return PLUGIN_CONTINUE;

	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	// alive?
	if (fm_is_user_alive(id) && pev(id, pev_flags) & (FL_CLIENT)) 
	{
		// Delay time reset
		set_user_delay_count(id, int:floatround(get_gametime()));

		// Task Delete.
		delete_task(id);

		// Removing already put lasermine.
		remove_all_lasermines(id);

		// Round start set ammo.
		set_start_ammo(id);

		// Refresh show ammo.
		show_ammo(id);
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Keep Max Speed.
//====================================================
public KeepMaxSpeed(id)
{
	if (fm_is_user_alive(id))
	{
		new Float:now_speed = get_user_max_speed(id);
		if (now_speed > 1.0 && now_speed < 300.0)
			save_user_max_speed(id, get_user_max_speed(id));
	}

	return PLUGIN_CONTINUE;
}

//====================================================
// Round Start Set Ammo.
//====================================================
set_start_ammo(id)
{
	// Get CVAR setting.
	new int:stammo = int:get_pcvar_num(gCvar[CVAR_START_HAVE]);

	// Zero check.
	if(stammo <= int:0) 
		return;

	// Getting have ammo.
	new int:haveammo = get_user_have_mine(id);

	// Set largest.
	set_user_have_mine(id, (haveammo <= stammo ? stammo : haveammo));

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

	// Dead Player remove lasermine.
	if (get_pcvar_num(gCvar[CVAR_DEATH_REMOVE]))
		remove_all_lasermines(vID);

	return PLUGIN_CONTINUE;
}


//====================================================
// Show Progress Bar.
//====================================================
show_progress(id, int:time)
{
	if (pev_valid(id))
	{
		engfunc(EngFunc_MessageBegin, MSG_ONE, gMsgBarTime, {0,0,0}, id);
		write_short(time);
		message_end();
	}
}

//====================================================
// Hide Progress Bar.
//====================================================
hide_progress(id)
{
	if (pev_valid(id))
	{
		engfunc(EngFunc_MessageBegin, MSG_ONE, gMsgBarTime, {0,0,0}, id);
		write_short(0);
		message_end();
	}
}

//====================================================
// Put LaserMine Start Progress A
//====================================================
public LaserMineProgressA(id)
{
	// Deploying Check.
	if (!check_for_deploy(id))
		return PLUGIN_HANDLED;

	new Float:wait = get_pcvar_float(gCvar[CVAR_LASER_PUT_WAIT]);
	if (wait > 0)
	{
		show_progress(id, int:floatround(wait));
	}

	// Set Flag. start progress.
	set_user_deploy_state(id, int:STATE_DEPLOYING);

	// Start Task. Put Lasermine.
	set_task(wait, "SpawnMine", (TASK_PLANT + id));

	return PLUGIN_HANDLED;
}

//====================================================
// Put LaserMine Start Progress B
//====================================================
public LaserMineProgressB(id)
{
	// Mode check. Bind Key Command.
	if(get_pcvar_num(gCvar[CVAR_CMD_MODE]) != 0)
		LaserMineProgressA(id);

	return PLUGIN_HANDLED;
}

//====================================================
// Removing target put lasermine.
//====================================================
public RemoveProgress(id)
{
	// Removing Check.
	if (!check_for_remove(id))
		return PLUGIN_HANDLED;

	new Float:wait = get_pcvar_float(gCvar[CVAR_LASER_PUT_WAIT]);
	if (wait > 0)
	{
		show_progress(id, int:floatround(wait));
	}

	// Set Flag. start progress.
	set_user_deploy_state(id, int:STATE_DEPLOYING);

	// Start Task. Remove Lasermine.
	set_task(wait, "RemoveMine", (TASK_RELEASE + id));

	return PLUGIN_HANDLED;
}

//====================================================
// Stopping Progress.
//====================================================
public StopProgress(id)
{
	hide_progress(id);
	delete_task(id);

	return PLUGIN_HANDLED;
}

//====================================================
// Task: Spawn Lasermine.
//====================================================
public SpawnMine(id)
{
	// Task Number to uID.
	new uID = id - TASK_PLANT
	// Create Entity.
	new iEnt = engfunc(EngFunc_CreateNamedEntity, gEntMine);
	// is Valid?
	if(!iEnt)
	{
		cp_debug(uID);
		return PLUGIN_HANDLED_MAIN;
	}

	// Entity Setting.
	// set class name.
	set_pev(iEnt, pev_classname, ENT_CLASS_NAME1);
	// set models.
	engfunc(EngFunc_SetModel, iEnt, ENT_MODELS);
	// set solid.
	set_pev(iEnt, pev_solid, SOLID_NOT);
	// set movetype.
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY);
	// set model animation.
	set_pev(iEnt, pev_frame, 0);
	set_pev(iEnt, pev_body, 3);
	set_pev(iEnt, pev_sequence, TRIPMINE_WORLD);
	set_pev(iEnt, pev_framerate, 0);
	// set take damage.
	set_pev(iEnt, pev_takedamage, DAMAGE_YES);
	set_pev(iEnt, pev_dmg, 100.0);
	// set entity health.
	set_user_health(iEnt, get_pcvar_float(gCvar[CVAR_MINE_HEALTH]));

	// solid complete.
	set_pev(iEnt, pev_solid, SOLID_BBOX);

	// set mine position
	set_mine_position(uID, iEnt);

	// Save results to be used later.
	set_pev(iEnt, LASERMINE_OWNER, uID );
	set_pev(iEnt, LASERMINE_TEAM, int:cs_get_user_team(uID));

	// Reset powoer on delay time.
	new Float:fCurrTime = get_gametime();
	set_pev(iEnt, LASERMINE_POWERUP, fCurrTime + 2.5 );   
	set_pev(iEnt, LASERMINE_STEP, POWERUP_THINK);

	// think rate. hmmm....
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.2 );

	// Power up sound.
	play_sound(iEnt, TRIPMINE_SOUND:POWERUP_SOUND);

	// Cound up. deployed.
	set_user_mine_deployed(uID, get_user_mine_deployed(uID) + int:1);
	// Cound down. have ammo.
	set_user_have_mine(uID, get_user_have_mine(uID) - int:1);

	// Refresh show ammo.
	show_ammo(uID);

	// Set Flag. end progress.
	set_user_deploy_state(uID, int:STATE_DEPLOYED);

	return 1;
}

//====================================================
// Set Lasermine Position.
//====================================================
set_mine_position(uID, iEnt)
{
	// Vector settings.
	new Float:vOrigin[3];
	new	Float:vNewOrigin[3],Float:vNormal[3],Float:vTraceDirection[3],
		Float:vTraceEnd[3],Float:vEntAngles[3];
	new bool:mode_claymore = (TRIPMINE_MODE:get_pcvar_num(gCvar[CVAR_MODE]) == MODE_BF4_CLAYMORE);

	// get user position.
	pev(uID, pev_origin, vOrigin);

	// get user aiming direction.
	velocity_by_aim( uID, 128, vTraceDirection );

	if (mode_claymore)
	{
		// Claymore is ground position.
		vTraceDirection[2] = -128.0;
	}

	xs_vec_add( vTraceDirection, vOrigin, vTraceEnd );

    // create the trace handle.
	new trace = create_tr2();
	// get wall position to vNewOrigin.
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, uID, trace);
	{
		new Float:fFraction;
		get_tr2( trace, TR_flFraction, fFraction );
			
		// -- We hit something!
		if ( fFraction < 1.0 )
		{
			// -- Save results to be used later.
			get_tr2( trace, TR_vecEndPos, vTraceEnd );
			get_tr2( trace, TR_vecPlaneNormal, vNormal );
		}
	}
    // free the trace handle.
	free_tr2(trace);

	xs_vec_mul_scalar( vNormal, 8.0, vNormal );
	xs_vec_add( vTraceEnd, vNormal, vNewOrigin );

	// set size.
	engfunc(EngFunc_SetSize, iEnt, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );
	// set entity position.
	engfunc(EngFunc_SetOrigin, iEnt, vNewOrigin );

	// Rotate tripmine.
	vector_to_angle(vNormal, vEntAngles);

	// claymore add vector aim angle.
	if (mode_claymore)
	{
		new Float:aimAngles[3];
		vector_to_angle(vTraceDirection, aimAngles);
		aimAngles[0] = 0.0;
		aimAngles[2] = 0.0;
		xs_vec_add(vEntAngles, aimAngles, vEntAngles);
	}
	// set angle.
	set_pev(iEnt, pev_angles, vEntAngles);

	// set laserbeam end point position.
	set_laserend_postiion(iEnt, vNormal, vNewOrigin, mode_claymore);
}

//====================================================
// Set Laserbeam End Position.
//====================================================
set_laserend_postiion(iEnt, Float:vNormal[3], Float:vNewOrigin[3], bool:claymore)
{
	// Calculate laser end origin.
	new Float:vBeamEnd[3];
	new Float:vTracedBeamEnd[3];
	new Float:range = get_pcvar_float(gCvar[CVAR_LASER_RANGE]);

	xs_vec_mul_scalar(vNormal, range, vNormal );
	xs_vec_add( vNewOrigin, vNormal, vBeamEnd );

    // create the trace handle.
	new trace = create_tr2();
	// (const float *v1, const float *v2, int fNoMonsters, edict_t *pentToSkip, TraceResult *ptr);
	engfunc(EngFunc_TraceLine, vNewOrigin, vBeamEnd, IGNORE_MONSTERS, -1, trace);
	{
		get_tr2(trace, TR_vecPlaneNormal, vNormal);
		get_tr2(trace, TR_vecEndPos, vTracedBeamEnd);
	}
    // free the trace handle.
	free_tr2(trace);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT1, vTracedBeamEnd);

	// claymore
	// vNormal -> aimAngle 90
	// left 45 to 90
	// center 45 to 135
	// right 90 to 135
	// down -45 to up 65
	// hit point far 128 near.
	if (claymore)
	{
		new Float:clradius = 300.0;
		trace = create_tr2();
		new Float:aimAngles[3];
		
		vector_to_angle(vBeamEnd, aimAngles);
		aimAngles[0] = 0.0;
		aimAngles[2] = 0.0;
		xs_vec_add(vNormal, aimAngles, vNormal);
		new rEnt = -1;
		// (const float *v1, const float *v2, int fNoMonsters, float radius, edict_t *pentToSkip, TraceResult *ptr);
//		while((rEnt = engfunc(EngFunc_FindEntityInSphere, rEnt, vOrigin, radius)) != 0)
		while((rEnt = engfunc(EngFunc_TraceSphere, vNewOrigin, vBeamEnd, IGNORE_MONSTERS, clradius, rEnt, trace)) != 0)
		{
			// get_tr2(trace, TR_vecPlaneNormal, vNormal);
			// get_tr2(trace, TR_vecEndPos, vTracedBeamEnd);
		}
		free_tr2(trace);
		set_pev(iEnt, LASERMINE_BEAMENDPOINT1, vTracedBeamEnd);
	}
	set_pev(iEnt, LASERMINE_BEAMENDPOINT2, vTracedBeamEnd);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT3, vTracedBeamEnd);
}

//====================================================
// Task: Remove Lasermine.
//====================================================
public RemoveMine(id)
{
	new target, body;
	new Float:vOrigin[3];
	new Float:tOrigin[3];

	// Task Number to uID.
	new uID = id - TASK_RELEASE;

	// Get target entity.
	get_user_aiming(uID, target, body);

	// is valid target?
	if(!pev_valid(target))
		return 1;
	
	// Get Player Vector Origin.
	pev(uID, pev_origin, vOrigin);
	// Get Mine Vector Origin.
	pev(target, pev_origin, tOrigin);

	// Distance Check. far 70.0 (cm?)
	if(get_distance_f(vOrigin, tOrigin) > 70.0)
		return 1;
	
	new entityName[32];
	entityName[0] = '^0';
	pev(target, pev_classname, entityName, 31);

	// Check. is Target Entity Lasermine?
	if(!equal(entityName, ENT_CLASS_NAME1))
		return 1;

	// Check. is Owner you?
	if(pev(target, LASERMINE_OWNER) != uID)
		return 1;

	// Remove!
	remove_entity(target);

	// Collect for this removed lasermine.
	set_user_have_mine(uID, get_user_have_mine(uID) + int:1);
	// Return to before deploy count.
	set_user_mine_deployed(uID, get_user_mine_deployed(uID) - int:1);

	// Play sound.
	emit_sound(uID, CHAN_ITEM, ENT_SOUND5, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	// Set Flag. end progress.
	set_user_deploy_state(uID, int:STATE_DEPLOYED);

	// Refresh show ammo.
	show_ammo(uID)

	return 1;
}

//====================================================
// Function: Count to deployed in team.
//====================================================
stock int:TeamDeployedCount(id)
{
	static int:i;
	static int:count;
	static int:num;
	static players[MAX_PLAYERS];
	static team[3] = '^0';

	// Witch your team?
	switch(CsTeams:cs_get_user_team(id))
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
		count += get_user_mine_deployed(players[i]);

	return count;
}

#if !defined BIOHAZARD_SUPPORT
//====================================================
// Check: Can use this Team.
//====================================================
bool:check_for_team(id)
{
	new arg[5];
	new CsTeam:team;

	// Get Cvar
	get_pcvar_string(gCvar[CVAR_CBT], arg, 3);

	// Terrorist
	if(equali(arg, "TR") || equali(arg, "T"))
		team = CsTeam:CS_TEAM_T;
	else
	// Counter-Terrorist
	if(equali(arg, "CT"))
		team = CsTeam:CS_TEAM_CT;
	else
	// All team.
	if(equali(arg, "ALL"))
		team = CsTeam:CS_TEAM_UNASSIGNED;
	else
		team = CsTeam:CS_TEAM_UNASSIGNED;

	// Cvar setting equal your team? Not.
	if(team != CsTeam:CS_TEAM_UNASSIGNED && team != CsTeam:cs_get_user_team(id))
		return false;

	return true;
}
#endif
//====================================================
// Check: common.
//====================================================
ERROR:check_for_common(id)
{
	new cvar_enable = get_pcvar_num(gCvar[CVAR_ENABLE]);
	new cvar_access = get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]);
	new user_flags	= get_user_flags(id) & ADMIN_IMMUNITY;
	new is_alive	= fm_is_user_alive(id);

	// Plugin Enabled
	if (!cvar_enable)
		return ERROR:NOT_ACTIVE;

	// Can Access.
	if (cvar_access != 0 && !user_flags) 
		return ERROR:NOT_ACCESS;

	// Is this player Alive?
	if (!is_alive) 
		return ERROR:NOT_ALIVE;

	// Can set Delay time?
	return ERROR:check_for_time(id);
}

//====================================================
// Check: Can use this time.
//====================================================
ERROR:check_for_time(id)
{
	new int:cvar_delay = int:get_pcvar_num(gCvar[CVAR_START_DELAY]);

	// gametime - playertime = delay count.
	gNowTime = int:floatround(get_gametime()) - get_user_delay_count(id);

	// check.
	if(gNowTime >= cvar_delay)
		return ERROR:NONE;

	return ERROR:DELAY_TIME;
}

//====================================================
// Check: Can buy.
//====================================================
ERROR:check_for_buy(id)
{
	new int:cvar_buymode= int:get_pcvar_num(gCvar[CVAR_BUY_MODE]);
	new int:cvar_maxhave= int:get_pcvar_num(gCvar[CVAR_MAX_HAVE]);
	new cvar_cost		= 	  get_pcvar_num(gCvar[CVAR_COST]);

	// Buy mode ON?
	if (cvar_buymode)
	{
		// Can this team buying?
#if defined BIOHAZARD_SUPPORT
		if (is_user_zombie(id))
#else
		if (!check_for_team(id))
#endif
			return ERROR:CANT_BUY_TEAM;
	} else {
		return ERROR:CANT_BUY;
	}

	// Have Max?
	if (get_user_have_mine(id) >= cvar_maxhave)
		return ERROR:HAVE_MAX;

	// Have money?
	if (cs_get_user_money(id) < cvar_cost)
		return ERROR:NO_MONEY;

	return ERROR:NONE;
}

//====================================================
// Check: Max Deploy.
//====================================================
ERROR:check_for_max_deploy(id)
{
	new int:cvar_maxhave = int:get_pcvar_num(gCvar[CVAR_MAX_HAVE]);
	new int:cvar_teammax = int:get_pcvar_num(gCvar[CVAR_TEAM_MAX]);
	// Max deployed per player.
	if (get_user_mine_deployed(id) >= cvar_maxhave)
		return ERROR:MAXIMUM_DEPLOYED;

	//// client_print(id,print_chat,"[Lasermine] your team deployed %d",TeamDeployedCount(id))
	// Max deployed per team.
	if(TeamDeployedCount(id) >= cvar_teammax)
		return ERROR:MANY_PPL;

	return ERROR:NONE;
}

//====================================================
// Show Chat area Messages
//====================================================
show_error_message(id, ERROR:err_num)
{
	switch(ERROR:err_num)
	{
		case NOT_ACTIVE:		cp_not_active(id);
		case NOT_ACCESS:		cp_not_access(id);
		case DONT_HAVE:			cp_dont_have(id);
		case CANT_BUY_TEAM:		cp_cant_buy_team(id);
		case CANT_BUY:			cp_cant_buy(id);
		case HAVE_MAX:			cp_have_max(id);
		case NO_MONEY:			cp_no_money(id);
		case MAXIMUM_DEPLOYED:	cp_maximum_deployed(id);
		case MANY_PPL:			cp_many_ppl(id);
		case DELAY_TIME:		cp_delay_time(id);
		case MUST_WALL:			cp_must_wall(id);
		case MUST_GROUND:		cp_must_ground(id);
	}
}

//====================================================
// Check: Remove Lasermine.
//====================================================
bool:check_for_remove(id)
{
	new int:cvar_ammo	= int:get_pcvar_num(gCvar[CVAR_MAX_HAVE]);
	new ERROR:error 	= check_for_common(id);

	// common check.
	if (error)
		return false;

	// have max ammo? (use buy system.)
	if (get_pcvar_num(gCvar[CVAR_BUY_MODE]) != 0)
	if (get_user_have_mine(id) + int:1 > cvar_ammo) 
		return false;

	new target;
	new body;
	new Float:vOrigin[3];
	new Float:tOrigin[3];

	get_user_aiming(id, target, body);

	// is valid target entity?
	if(!pev_valid(target))
		return false;

	// get potision. player and target.
	pev(id, pev_origin, vOrigin);
	pev(target, pev_origin, tOrigin);

	// Distance Check. far 70.0 (cm?)
	if(get_distance_f(vOrigin, tOrigin) > 70.0)
		return false;
	
	new entityName[32];
	entityName[0] = '^0';
	pev(target, pev_classname, entityName, 31);

	// is target lasermine?
	if(!equal(entityName, ENT_CLASS_NAME1))
		return false;

	// is owner you?
	if(pev(target, LASERMINE_OWNER) != id)
		return false;
	
	return true;
}

//====================================================
// Check: On the wall.
//====================================================
ERROR:check_for_onwall(id)
{
	new Float:vTraceDirection[3];
	new Float:vTraceEnd[3];
	new Float:vOrigin[3];
	new bool:mode_claymore = (TRIPMINE_MODE:get_pcvar_num(gCvar[CVAR_MODE]) == MODE_BF4_CLAYMORE);

	// Get potision.
	pev(id, pev_origin, vOrigin);
	
	// Get wall position.
	velocity_by_aim(id, 128, vTraceDirection);
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd);

	if (mode_claymore)
	{
		// Claymore is ground position.
		vTraceDirection[2] = -128.0;
	}

    // create the trace handle.
	new trace = create_tr2();
	new Float:fFraction = 0.0;
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, trace);
	{
    	get_tr2( trace, TR_flFraction, fFraction );
    }
    // free the trace handle.
	free_tr2(trace);

	// We hit something!
	if ( fFraction < 1.0 )
		return ERROR:NONE;

	if (mode_claymore)
		return ERROR:MUST_GROUND;
	else
		return ERROR:MUST_WALL;
}

//====================================================
// Check: Lasermine Deploy.
//====================================================
bool:check_for_deploy(id)
{
	// Check common.
	new ERROR:error = check_for_common(id);
	if (error)
	{
		show_error_message(id, error);
		return false;
	}

	// Have mine? (use buy system)
	if (get_pcvar_num(gCvar[CVAR_BUY_MODE]) != 0)
	if (get_user_have_mine(id) <= int:0) 
	{
		show_error_message(id, ERROR:DONT_HAVE);
		return false;
	}

	// Max deployed?
	error = check_for_max_deploy(id);
	if (error) 
	{
		show_error_message(id, error);
		return false;
	}
	
	// On the wall?
	error = check_for_onwall(id);
	if (error) 
	{
		show_error_message(id, error);
		return false;
	}

	return true;
}

//====================================================
// Lasermine Think Event.
//====================================================
public LaserThink(iEnt)
{
	// Check plugin enabled.
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return FMRES_IGNORED;

	// is valid this entity?
	if (!pev_valid( iEnt ))
		return FMRES_IGNORED;

	new entityName[32];
	entityName[0] = '^0';
	pev(iEnt, pev_classname, entityName, 31);

	// is this lasermine? no.
	if (!equal(entityName, ENT_CLASS_NAME1))
		return FMRES_IGNORED;

	static Float:fCurrTime;
	fCurrTime = get_gametime();

	// lasermine state.
	switch (pev(iEnt, LASERMINE_STEP))
	{
		// Power up.
		case POWERUP_THINK:
		{
			new Float:fPowerupTime;
			pev(iEnt, LASERMINE_POWERUP, fPowerupTime);

			// over power up time.
			if (fCurrTime > fPowerupTime)
			{
				// next state.
				set_pev(iEnt, LASERMINE_STEP, BEAMBREAK_THINK);
				// activate sound.
				play_sound(iEnt, ACTIVATE_SOUND);
			}

			// Glow mode.
			if (get_pcvar_num(gCvar[CVAR_MINE_GLOW]) != 0)
			{
				// Color setting.
				if (get_pcvar_num(gCvar[CVAR_LASER_COLOR]) == 0)
				{
					// Team color.
					switch (pev(iEnt,LASERMINE_TEAM))
					{
						case CS_TEAM_T :set_glow_rendering(iEnt, kRenderFxGlowShell, 255,0,0, kRenderNormal, 5); // Red
						case CS_TEAM_CT:set_glow_rendering(iEnt, kRenderFxGlowShell, 0,0,255, kRenderNormal, 5); // Blue
					}
				} else
				{
					// Optional Color (Green).
					set_glow_rendering(iEnt, kRenderFxGlowShell, 0,255,0, kRenderNormal, 5);
				}
			}
			// Think time.
			set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
		}

		// Laser line activated.
		case BEAMBREAK_THINK:
		{
			static Float:vEnd[3][3]; // Claymore 3 point
			static Float:vOrigin[3];

			// Get this mine position.
			pev(iEnt, pev_origin, vOrigin);
			// Get Laser line end potision.
			pev(iEnt, LASERMINE_BEAMENDPOINT1, vEnd[0]);
			pev(iEnt, LASERMINE_BEAMENDPOINT2, vEnd[1]);
			pev(iEnt, LASERMINE_BEAMENDPOINT3, vEnd[2]);

			static iTarget;
			static Float:fFraction;
			new loop = 1;
			loop = TRIPMINE_MODE:get_pcvar_num(gCvar[CVAR_MODE]) == MODE_BF4_CLAYMORE ? 3 : 1;

			new trace;
			for(new i = 0; i < loop; i++)
			{
                // create the trace handle.
				trace = create_tr2();
				// Trace line
				engfunc(EngFunc_TraceLine, vOrigin, vEnd[i], DONT_IGNORE_MONSTERS, iEnt, trace);
				{
					get_tr2(trace, TR_flFraction, fFraction);
					iTarget = get_tr2(trace, TR_pHit);
                }
				// free the trace handle.
				free_tr2(trace);

				// Something has passed the laser.
				if (fFraction >= 1.0)
					continue;

				// is valid hit entity?
				if (!pev_valid(iTarget))
					continue;

				entityName[0] = '^0';
				pev(iTarget, pev_classname, entityName, 31);

				// Ignoring others tripmines entity.
				if (equal(entityName, ENT_CLASS_NAME1))
					continue;

				// keep target id.
				set_pev(iEnt, pev_enemy, iTarget);

				// Mode. Lasermine / Tripmine / Claymore wire trap.
				switch(get_pcvar_num(gCvar[CVAR_MODE]))
				{
					case MODE_LASERMINE:
					{
						// Lasermine mode.
						// Laser damage.
						create_laser_damage(iEnt, iTarget);
					}
					case MODE_TRIPMINE:
					{
						// Tripmine mode.
						// Friendly Fire ON or Target is Enemy Team.
						if (get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]) 
						|| CsTeams:pev(iEnt, LASERMINE_TEAM) != cs_get_user_team(iTarget))
							// State change. to Explosing step.
							set_pev(iEnt, LASERMINE_STEP, EXPLOSE_THINK);
					}
					case MODE_BF4_CLAYMORE:
					{
						// Claymore mode.
						// Friendly Fire ON or Target is Enemy Team.
						if (get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]) 
						|| CsTeams:pev(iEnt, LASERMINE_TEAM) != cs_get_user_team(iTarget))
							// State change. to Explosing step.
							set_pev(iEnt, LASERMINE_STEP, EXPLOSE_THINK);
					}
				}
				// Think time. random_float = laser line blinking.
				set_pev(iEnt, pev_nextthink, fCurrTime + random_float(0.1, 0.3));
			}

			// Laser line damage mode. Once or Second.
			if (get_pcvar_num(gCvar[CVAR_LASER_DMG_MODE]) != 0)
				// if change target. keep target id.
				if (pev(iEnt, LASERMINE_HITING) != iTarget)
					set_pev(iEnt, LASERMINE_HITING, iTarget);
 
			// Tripmine is still there.
			if (pev_valid(iEnt))
			{
				// Get mine health.
				static Float:iHealth;
				iHealth = fm_get_user_health(iEnt);

				// break?
				if (iHealth < 0 || (pev(iEnt, pev_flags) & FL_KILLME))
				{
					// next step explosion.
					set_pev(iEnt, LASERMINE_STEP, EXPLOSE_THINK);
					set_pev(iEnt, pev_nextthink, fCurrTime + random_float( 0.1, 0.3 ));
				}
					
				static Float:fBeamthink;
				pev(iEnt, LASERMINE_BEAMTHINK, fBeamthink);
				
				// drawing laser line.
				if (fBeamthink < fCurrTime && get_pcvar_num(gCvar[CVAR_LASER_VISIBLE]))
				{
					for (new i = 0; i < loop; i++)
					{
						draw_laserline(iEnt, vOrigin, vEnd[i]);
					}
					set_pev(iEnt, LASERMINE_BEAMTHINK, fCurrTime + 0.1);
				}
				set_pev(iEnt, pev_nextthink, fCurrTime + 0.01);
			}
		}
		// Explosion.
		case EXPLOSE_THINK:
		{
			// Stopping entity to think
			set_pev(iEnt, pev_nextthink, 0.0);
			// 
			play_sound(iEnt, STOP_SOUND);

			// Get owner id.
			new owner = pev(iEnt, LASERMINE_OWNER);
			// Count down. deployed lasermines.
			set_user_mine_deployed(owner, get_user_mine_deployed(owner) - int:1);

			// effect explosion.
			create_explosion(iEnt);
			// damage.
			create_explosion_damage(iEnt, get_pcvar_float(gCvar[CVAR_EXPLOSE_DMG]), get_pcvar_float(gCvar[CVAR_EXPLOSE_RADIUS]));

			// remove this.
			remove_entity(iEnt);
		}
	}

	return FMRES_IGNORED;
}

//====================================================
// Play sound.
//====================================================
play_sound(iEnt, TRIPMINE_SOUND:i_SoundType)
{
	switch (i_SoundType)
	{
		case POWERUP_SOUND:
		{
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			emit_sound(iEnt, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, 0, PITCH_NORM);
		}
		case ACTIVATE_SOUND:
		{
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, 1, 75);
		}
		case STOP_SOUND:
		{
			emit_sound(iEnt, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, SND_STOP, 75);
		}
	}
}

//====================================================
// Drawing Laser line.
//====================================================
draw_laserline(iEnt, const Float:vOrigin[3], const Float:vEndOrigin[3])
{
	new tcolor[3];
	new CsTeams:teamid = CsTeams:pev(iEnt, LASERMINE_TEAM);
	new width = 5;
	// Color mode. 0 = team color.
	if(get_pcvar_num(gCvar[CVAR_LASER_COLOR]) == 0)
	{
		switch(teamid)
		{
			case CS_TEAM_T:
			{
				tcolor[0] = 255; // Red.
				tcolor[1] = 0;
				tcolor[2] = 0;
			}
			case CS_TEAM_CT:
			{
				tcolor[0] = 0;
				tcolor[1] = 0;
				tcolor[2] = 255; // Blue.
			}
			default:
			{
				tcolor[0] = 0;
				tcolor[1] = 255; // Green.
				tcolor[2] = 0;
			}
		}
	}else
	{
		tcolor[0] = 0;
		tcolor[1] = 255; // Green.
		tcolor[2] = 0;
	}

	// Test. Claymore color is black wire.
	if (TRIPMINE_MODE:get_pcvar_num(gCvar[CVAR_MODE]) == MODE_BF4_CLAYMORE)
	{
		tcolor[0] = 255;
		tcolor[1] = 255;
		tcolor[2] = 255;
		width = 1;
	}

	// Draw Laser line message.
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord, vOrigin[0]);
	engfunc(EngFunc_WriteCoord, vOrigin[1]);
	engfunc(EngFunc_WriteCoord, vOrigin[2]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]); //Random
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]); //Random
	engfunc(EngFunc_WriteCoord, vEndOrigin[2]); //Random
	write_short(gBeam);
	write_byte(0);	// framestart
	write_byte(0);	// framerate
	write_byte(1);	// Life
	write_byte(width);	// Width
	write_byte(0);	// wave/noise
	write_byte(tcolor[0]); // r
	write_byte(tcolor[1]); // g
	write_byte(tcolor[2]); // b
	write_byte(get_pcvar_num(gCvar[CVAR_LASER_BRIGHT])); // Brightness.
	write_byte(255);	// speed
	message_end();
}

//====================================================
// Stop Laser line.
//====================================================
stop_laserline(iEnt)
{
	// Laser line stop.
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(99); //99 = KillBeam
	write_short(iEnt);
	message_end();
}

//====================================================
// Effect Explosion.
//====================================================
create_explosion(iEnt)
{
	// Stop laser line.
	stop_laserline(iEnt);

	// Get position.
	new Float:vOrigin[3];
	pev(iEnt, pev_origin, vOrigin);

	// Boooom.
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vOrigin[0]);
	engfunc(EngFunc_WriteCoord, vOrigin[1]);
	engfunc(EngFunc_WriteCoord, vOrigin[2]);
	write_short(gBoom);
	write_byte(30);
	write_byte(15);
	write_byte(0);
	message_end();
}

//====================================================
// Explosion Damage.
//====================================================
create_explosion_damage(iEnt, Float:dmgMax, Float:radius)
{
	// Get given parameters
	
	new Float:vOrigin[3];
	pev(iEnt, pev_origin, vOrigin);

	new iAttacker  		  = pev(iEnt, LASERMINE_OWNER);
	new CsTeams:tAttacker = CsTeams:pev(iEnt, LASERMINE_TEAM);

	// radius entities.
	new rEnt  = -1;
	new Float:tmpDmg = dmgMax;

	new Float:kickBack = 0.0;
	
	// Needed for doing some nice calculations :P
	new Float:Tabsmin[3], Float:Tabsmax[3];
	new Float:vecSpot[3];
	new Float:Aabsmin[3], Float:Aabsmax[3];
	new Float:vecSee[3];
	new Float:flFraction;
	new Float:vecEndPos[3];
	new Float:distance;
	new Float:origin[3], Float:vecPush[3];
	new Float:invlen;
	new Float:velocity[3];
	new trace;
	new iHit;

	// Calculate falloff
	new Float:falloff;
	if (radius > 0.0)
		falloff = dmgMax / radius;
	else
		falloff = 1.0;
	
	// Find monsters and players inside a specifiec radius
	while((rEnt = engfunc(EngFunc_FindEntityInSphere, rEnt, vOrigin, radius)) != 0)
	{
		// is valid entity? no to continue.
		if(!pev_valid(rEnt)) 
			continue;

		// Entity is not a player or monster, ignore it
		if(!(pev(rEnt, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
			continue;

		// is alive?
		if(!fm_is_user_alive(rEnt))
			continue;

		// Reset data
		kickBack = 1.0;
		tmpDmg = dmgMax;
		
		// The following calculations are provided by Orangutanz, THANKS!
		// We use absmin and absmax for the most accurate information
		pev(rEnt, pev_absmin, Tabsmin);
		pev(rEnt, pev_absmax, Tabsmax);

		xs_vec_add(Tabsmin, Tabsmax, Tabsmin);
		xs_vec_mul_scalar(Tabsmin, 0.5, vecSpot);
		
		pev(iEnt, pev_absmin, Aabsmin);
		pev(iEnt, pev_absmax, Aabsmax);

		xs_vec_add(Aabsmin, Aabsmax, Aabsmin);
		xs_vec_mul_scalar(Aabsmin, 0.5, vecSee);
		
        // create the trace handle.
		trace = create_tr2();
		engfunc(EngFunc_TraceLine, vecSee, vecSpot, 0, iEnt, trace);
		{
			get_tr2(trace, TR_flFraction, flFraction);
			iHit = get_tr2(trace, TR_pHit);

			// Work out the distance between impact and entity
			get_tr2(trace, TR_vecEndPos, vecEndPos);
		}
        // free the trace handle.
		free_tr2(trace);

		// Explosion can 'see' this entity, so hurt them! (or impact through objects has been enabled xD)
		if (flFraction >= 0.9 || iHit == rEnt)
		{
			distance = get_distance_f(vOrigin, vecEndPos) * falloff;
			tmpDmg -= distance;
			if(tmpDmg < 0.0)
				tmpDmg = 0.0;
			
			// Kickback Effect
			if(kickBack != 0.0)
			{
				xs_vec_sub(vecSpot, vecSee, origin);
				
				invlen = 1.0 / get_distance_f(vecSpot, vecSee);

				xs_vec_mul_scalar(origin, invlen, vecPush);
				pev(rEnt, pev_velocity, velocity);
				xs_vec_mul_scalar(vecPush, tmpDmg, vecPush);
				xs_vec_mul_scalar(vecPush, kickBack, vecPush);
				xs_vec_add(velocity, vecPush, velocity);
				
				if(tmpDmg < 60.0)
					xs_vec_mul_scalar(velocity, 12.0, velocity);
				else
					xs_vec_mul_scalar(velocity, 4.0, velocity);
				
				if(velocity[0] != 0.0 || velocity[1] != 0.0 || velocity[2] != 0.0)
				{
					// There's some movement todo :)
					set_pev(rEnt, pev_velocity, velocity);
				}
			}
			// Get Target Team.
			new CsTeams:tTarget = cs_get_user_team(rEnt);
			// Score and damage.
			calculate_score(iEnt, iAttacker, tAttacker, rEnt, tTarget, tmpDmg);
		}
	}
	return;
}

//====================================================
// Create bullet hit Effect.
//====================================================
create_damage_effect(id, iEnt, Float:dmg)
{
	if (!pev_valid(id) || !pev_valid(iEnt))
	{
		return;
	}
	new Float:vOrigin[3];
	pev(iEnt, pev_origin, vOrigin);

	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, gMsgDamage, {0, 0, 0}, id);
	write_byte(floatround(dmg));
	write_byte(floatround(dmg));
	write_long(DMG_BULLET);
	engfunc(EngFunc_WriteCoord,vOrigin[0]);
	engfunc(EngFunc_WriteCoord,vOrigin[1]);
	engfunc(EngFunc_WriteCoord,vOrigin[2]);
	message_end();

	return;
}

//====================================================
// Calculate Score.
//====================================================
bool:calculate_score(iEnt, iAttacker, CsTeams:tAttacker, iTarget, CsTeams:tTarget, Float:dmg)
{
	// Hit friend and No FF.
	if (tTarget == tAttacker)
		if(!get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]))
			return false;

	new score  = (tTarget != tAttacker) ? 1 : -1;
	new money  = (tTarget != tAttacker) ? get_pcvar_num(gCvar[CVAR_FRAG_MONEY]) : (get_pcvar_num(gCvar[CVAR_FRAG_MONEY]) * -1);

	// Hit point.
	new Float:iHitHP = fm_get_user_health(iTarget) - dmg;

	// Dead?
	if (iHitHP <= 0.0)
	{
		// Get Money attacker.
		cs_set_user_money(iAttacker, cs_get_user_money(iAttacker) + money);
		// Score up attacker.
		set_score(iAttacker, iTarget, score, iHitHP);
	} else
	{
		// damage effect to target.
		create_damage_effect(iTarget, iEnt, dmg);
		// alive. HP set target.
		set_user_health(iTarget, Float:iHitHP);
	}

	return true;
}

//====================================================
// Laser damage
//====================================================
create_laser_damage(iEnt, iTarget)
{
	// is valid target?
	if (!pev_valid(iTarget) || !pev_valid(iEnt))
		return;

	// Damage mode.	
	switch (get_pcvar_num(gCvar[CVAR_LASER_DMG_MODE]))
	{
		// Once hit.
		case 1:
		{
			// Already Hit target.
			if (pev(iEnt, LASERMINE_HITING) == iTarget)
				return;
		}
		// Seconds hit.
		case 2:
		{
			static Float:laserdps = 0.0;
			laserdps = get_pcvar_float(gCvar[CVAR_LASER_DMG_DPS]);
			// Alread hit target.
			if (pev(iEnt, LASERMINE_HITING) == iTarget)
			{
				static Float:ntime = 0.0; ntime = get_gametime();
				static Float:htime = 0.0; pev(iEnt, LASERMINE_COUNT, htime);

				if (ntime < htime)
				{
					// Through Next time.
					return;
				}
				// Keep now time.
				set_pev(iEnt, LASERMINE_COUNT, (get_gametime() + laserdps))

			}else
			{
				// Other hit, keep now time.
				set_pev(iEnt, LASERMINE_COUNT, (get_gametime() + laserdps))
			}
		}
	}

	new isDead, isGod;
	new entityName[32];
	
	entityName[0] = '^0';
	pev(iTarget, pev_classname, entityName, 32);
	
	// is target player or monster?
	if((pev(iTarget, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
	{
		// is dead or god?
		isDead  = !fm_is_user_alive(iTarget);
		isGod   = fm_is_user_godmode(iTarget);

		if(isDead || isGod)
			return;

		new iAttacker   		= pev(iEnt,LASERMINE_OWNER);
		new CsTeams:tAttacker 	= CsTeams:pev(iEnt, LASERMINE_TEAM);
		new CsTeams:tTarget 	= CsTeams:cs_get_user_team(iTarget);

		if (calculate_score(iEnt, iAttacker, tAttacker, iTarget, tTarget, get_pcvar_float(gCvar[CVAR_LASER_DMG])))
		{
			// Hit
			emit_sound(iTarget, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM);
			set_pev(iEnt, LASERMINE_HITING, iTarget);
		}
	}else
	// is target func_breakable?
	if(equal(entityName, ENT_CLASS_NAME3))
	{
		// damage it.
		set_user_health(iTarget, Float:(fm_get_user_health(iTarget) - get_pcvar_float(gCvar[CVAR_LASER_DMG])));
	}
	return;
}

//====================================================
// Set Score
//====================================================
set_score(iAttacker, iTarget, score, Float:HP)
{
	new int:aFrag;	// Attacker Frag.

	// Dead target.
	if (HP <= 0)
	{
		// Death Message.
		engfunc(EngFunc_MessageBegin, MSG_ALL, gMsgDeathMsg, {0, 0, 0}, 0);
		write_byte(iAttacker);	// killer
		write_byte(iTarget);	// victim
		write_byte(0);			// headshot
		write_string(ENT_CLASS_NAME4);	// weapon
		message_end();

		set_msg_block(gMsgDeathMsg, BLOCK_ONCE);

		// Target kill.
		set_user_health(iTarget, HP);

		// Add Attacker Frag (Friendly fire is minus).
		aFrag = int:fm_get_user_frags(iAttacker) + int:score;
	}

	//
	// Refresh Score info.
	//
	new aDeath = cs_get_user_deaths(iAttacker);

	set_pdata_int(iAttacker, m_iDeaths, aDeath);
	ExecuteHamB(Ham_AddPoints, iAttacker, aFrag - int:fm_get_user_frags(iAttacker), true);

	new tDeath = cs_get_user_deaths(iTarget);

	set_pdata_int(iTarget, m_iDeaths, tDeath);
	ExecuteHamB(Ham_AddPoints, iTarget, 0, true);
}

//====================================================
// Buy Lasermine.
//====================================================
public BuyLasermine(id)
{	
	new ERROR:error = check_for_buy(id);
	if( error )
	{
		show_error_message(id, error);
		return PLUGIN_CONTINUE;
	}

	cs_set_user_money(id,cs_get_user_money(id) - get_pcvar_num(gCvar[CVAR_COST]));
	set_user_have_mine(id, get_user_have_mine(id) + int:1);

	cp_bought(id);

	emit_sound(id, CHAN_ITEM, ENT_SOUND5, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	show_ammo(id);

	return PLUGIN_HANDLED;
}

//====================================================
// Show ammo.
//====================================================
show_ammo(id)
{ 
	new ammo[51];
	if (get_pcvar_num(gCvar[CVAR_BUY_MODE]) != 0)
		formatex(ammo, 50, "%s %i/%i",STR_STATE, get_user_have_mine(id), get_pcvar_num(gCvar[CVAR_MAX_HAVE]));
	else
		formatex(ammo, 50, "%s Infinite.",STR_STATE);

	if (pev_valid(id))
	{
		engfunc(EngFunc_MessageBegin, MSG_ONE, gMsgStatusText, {0, 0, 0}, id);
		write_byte(0);
		write_string(ammo);
		message_end();
	}
} 

//====================================================
// Chat command.
//====================================================
public SayLasermine(id)
{
	if(!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	new said[32];
	read_argv(1, said, 31);
	
	if (equali(said,"/buy lasermine") || equali(said,"/lm"))
	{
		BuyLasermine(id);
	} else 
	if (equali(said, "lasermine") || equali(said, "/lasermine"))
	{
		const SIZE = 1024;
		new msg[SIZE+1],len = 0;
		len += formatex(msg[len], SIZE - len, "<html><body>");
		len += formatex(msg[len], SIZE - len, "<p><b>LaserMine</b></p><br/><br/>");
		len += formatex(msg[len], SIZE - len, "<p>You can be setting the mine on the wall.</p><br/>");
		len += formatex(msg[len], SIZE - len, "<p>That laser will give what touched it damage.</p><br/><br/>");
		len += formatex(msg[len], SIZE - len, "<p><b>LaserMine Commands</b></p><br/><br/>");
		len += formatex(msg[len], SIZE - len, "<p><b>Say /buy lasermine</b> or <b>Say /lm</b> //buying lasermine<br/>");
		len += formatex(msg[len], SIZE - len, "<b>buy_lasermine</b> //bind ^"F2^" buy_lasermine : using F2 buying lasermine<br/>");
		len += formatex(msg[len], SIZE - len, "<b>+setlaser</b> //bind mouse3 +setlaser : using mouse3 set lasermine on wall<br/>");
		len += formatex(msg[len], SIZE - len, "</body></html>");
		show_motd(id, msg, "Lasermine Entity help");
		return PLUGIN_CONTINUE;
	} else 
	if (containi(said, "laser") != -1) 
	{
		cp_refer(id);
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Player post think event.
// Stop movement for mine deploying.
//====================================================
public PlayerPostThink(id) 
{
	switch (get_user_deploy_state(id))
	{
		case STATE_IDLE:
		{
			new bool:now_speed = (get_user_max_speed(id) <= 1.0)
			if (now_speed)
				ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
		}
		case STATE_DEPLOYING:
		{
			set_user_max_speed(id, 1.0);
		}
		case STATE_DEPLOYED:
		{
			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
			set_user_deploy_state(id, STATE_IDLE);
		}
	}

	return FMRES_IGNORED;
}

//====================================================
// Player pre think event.
//====================================================
public PlayerPreThink(id)
{
	if (!fm_is_user_alive(id)			// isDead?
		|| is_user_bot(id) 				// is bot?
		|| get_user_deploy_state(id) != int:STATE_IDLE	 // deploying?
		|| get_pcvar_num(gCvar[CVAR_CMD_MODE]) == 1) // +setlaser use?
		return FMRES_IGNORED;

	// [USE] Key.
	if(pev(id, pev_button ) & IN_USE && !(pev(id, pev_oldbuttons ) & IN_USE ))
		LaserMineProgressA(id);			// deploying.

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

	// reset deploy count.
	set_user_mine_deployed(id, int:0);
	// reset hove mine.
	set_user_have_mine(id, int:0);

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

	// delete task.
	delete_task(id);
	// remove all lasermine.
	remove_all_lasermines(id);

	return PLUGIN_CONTINUE;
}

//====================================================
// Remove all lasermine.
//====================================================
remove_all_lasermines(id)
{
	new iEnt = -1;
	new entityName[32];
	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", ENT_CLASS_NAME1)))
	{
		if (!pev_valid(iEnt))
			continue;

		if (is_user_connected(id))
		{
			if (pev(iEnt, LASERMINE_OWNER) != id)
				continue;
			entityName[0] = '^0';
			pev(iEnt, pev_classname, entityName, 31);
				
			if (equali(entityName, ENT_CLASS_NAME1))
			{
				play_sound(iEnt, STOP_SOUND);
				remove_entity(iEnt);
			}
		}
		else
			set_pev(iEnt, pev_flags, FL_KILLME);
	}
	// reset deploy count.
	set_user_mine_deployed(id, int:0);
}

//====================================================
// Infected player Deploy stop. (BIOHAZARD)
//====================================================
#if defined BIOHAZARD_SUPPORT
public event_infect2(id)
{
	delete_task(id);
	return PLUGIN_CONTINUE;
}
#endif

//====================================================
// Delete Task.
//====================================================
delete_task(id)
{
	if (task_exists((TASK_PLANT + id)))
		remove_task((TASK_PLANT + id));

	if (task_exists((TASK_RELEASE + id)))
		remove_task((TASK_RELEASE + id));

	set_user_deploy_state(id, STATE_IDLE);
	return;
}

//====================================================
// Glow Rendering
//====================================================
stock set_glow_rendering(iEnt, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:renderColor[3];
	renderColor[0] = float(r);
	renderColor[1] = float(g);
	renderColor[2] = float(b);

	set_pev(iEnt, pev_renderfx, fx);
	set_pev(iEnt, pev_rendercolor, renderColor);
	set_pev(iEnt, pev_rendermode, render);
	set_pev(iEnt, pev_renderamt, float(amount));

	return 1;
}

//====================================================
// Gets offset data
//====================================================
get_offset_value(id, type)
{
#if defined UL_MONEY_SUPPORT
	if (type == OFFSET_MONEY)
	{
			return cs_get_user_money_ul(id);
	}
#endif

	new key = type;
/*
	symbol "is_amd64_server" is marked as deprecated: AMXX is not shipping 64bits builds anymore.
	This native is basically guaranteed to return 0.

	if (is_amd64_server())
		key += 25;
*/
	return get_pdata_int(id, key);	
}

//====================================================
// Sets offset data
//====================================================
set_offset_value(id, type, value)
{
	if (type == OFFSET_MONEY)
	{
#if defined UL_MONEY_SUPPORT
		return cs_set_user_money_ul(id, value);
#else
		if (pev_valid(id))
		{
			// Send Money message to update player's HUD
			engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, gMsgMoney, {0, 0, 0}, id);
			write_long(value);
			write_byte(1);	// Flash (difference between new and old money)
			message_end();
		}
#endif
	}

	new key = type;
/*
	symbol "is_amd64_server" is marked as deprecated: AMXX is not shipping 64bits builds anymore.
	This native is basically guaranteed to return 0.

	if(is_amd64_server()) 
		key += 25;
*/
	set_pdata_int(id, key, value);	
	return;
}
