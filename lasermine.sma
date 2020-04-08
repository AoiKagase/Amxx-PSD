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
#include <amxmisc>
#include <amxconst>
#include <fakemeta>
#include <hamsandwich>
#include <vector>
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
#if AMXX_VERSION_NUM < 190
	#assert "AMX Mod X v1.9.0 or greater library required!"
	#define MAX_PLAYERS				32
#endif

/*=====================================*/
/*  MACRO AREA					       */
/*=====================================*/
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"3.4b"

#if defined BIOHAZARD_SUPPORT
	#define PLUGIN 					"Lasermine for BIOHAZARD"

	#define CHAT_TAG 				"[Biohazard]"
	#define CVAR_TAG				"bio_ltm"
	#define LANG_KEY_NOT_BUY_TEAM	"NOT_BUY_TEAM"
#else
	#define PLUGIN 					"Laser/Tripmine Entity"

	#define CHAT_TAG 				"[Lasermine]"
	#define CVAR_TAG				"amx_ltm"
	#define LANG_KEY_NOT_BUY_TEAM 	"NOT_BUY_TEAM"
#endif

#define ENT_MODELS					"models/v_tripmine.mdl"
#define ENT_SOUND1					"weapons/mine_deploy.wav"
#define ENT_SOUND2					"weapons/mine_charge.wav"
#define ENT_SOUND3					"weapons/mine_activate.wav"
#define ENT_SOUND4					"debris/beamstart9.wav"
#define ENT_SOUND5					"items/gunpickup2.wav"
#define ENT_SOUND6					"debris/bustglass1.wav"
#define ENT_SOUND7					"debris/bustglass2.wav"
#define ENT_SOUND8					"weapons/ric_metal-1.wav"
#define ENT_SOUND9					"weapons/ric_metal-2.wav"
#define ENT_SPRITE1 				"sprites/laserbeam.spr"
#define ENT_SPRITE2 				"sprites/zerogxplode.spr"

#define ENT_CLASS_NAME1				"lasermine"
#define ENT_CLASS_NAME2				"info_target"
#define ENT_CLASS_NAME3				"func_breakable"

//#define STR_MINEDETNATED 		"Your mine has detonated.",
//#define STR_MINEDETNATED2		"detonated your mine.",
//#define STR_CANTDEPLOY			"Your team can't deploying lasermine!"

#define LANG_KEY_REFER				"REFER"
#define LANG_KEY_BOUGHT       		"BOUGHT"
#define LANG_KEY_NO_MONEY     		"NO_MONEY"
#define LANG_KEY_NOT_ACCESS   		"NOT_ACCESS"
#define LANG_KEY_NOT_ACTIVE   		"NOT_ACTIVE"
#define LANG_KEY_NOT_HAVE     		"NOT_HAVE"
#define LANG_KEY_NOT_BUY      		"NOT_BUY"
#define LANG_KEY_NOT_BUYZONE  		"NOT_BUYZONE"
#define LANG_KEY_NOT_PICKUP   		"NOT_PICKUP"
#define LANG_KEY_MAX_DEPLOY   		"MAX_DEPLOY"
#define LANG_KEY_MAX_HAVE     		"MAX_HAVE"
#define LANG_KEY_MAX_PPL      		"MAX_PPL"
#define LANG_KEY_DELAY_SEC    		"DELAY_SEC"
#define LANG_KEY_STATE_AMMO   		"STATE_AMMO"
#define LANG_KEY_STATE_INF    		"STATE_INF"
#define LANG_KEY_PLANT_WALL   		"PLANT_WALL"
#define LANG_KEY_PLANT_GROUND 		"PLANT_GROUND"
#define LANG_KEY_SORRY_IMPL   		"SORRY_IMPL"
#define LANG_KEY_NOROUND			"NO_ROUND"

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

#define MAX_MINES					10
#define OFFSET_TEAM 				114
#define OFFSET_MONEY				115
#if cellbits == 32
	#define OFFSET_MAPZONE  		235
#else
	#define OFFSET_MAPZONE  		268
#endif
#define OFFSET_DEATH	 			444
#define PLAYER_IN_BUYZONE			(1<<0)
#if defined BIOHAZARD_SUPPORT
	#define CS_TEAM_ZOMBIE			4
#endif
// CS Status Data.
#define cs_get_user_team(%1)		get_offset_value(%1, OFFSET_TEAM)
#define cs_set_user_team(%1,%2)		set_offset_value(%1, OFFSET_TEAM, %2)
#define cs_get_user_deaths(%1)		get_offset_value(%1, OFFSET_DEATH)
#define cs_get_user_money(%1)		get_offset_value(%1, OFFSET_MONEY)
#define cs_set_user_money(%1,%2)	set_offset_value(%1, OFFSET_MONEY, %2)

// Client Print Command Macro.
#define cp_debug(%1)				client_print_color(%1, %1, "^4[Laesrmine Debug] ^1Can't Create Entity")
#define cp_refer(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_REFER,		CHAT_TAG)
#define cp_bought(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_BOUGHT,		CHAT_TAG)
#define	cp_no_money(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NO_MONEY,		CHAT_TAG, get_pcvar_num(gCvar[CVAR_COST]))
#define cp_not_access(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY_NOT_ACCESS, CHAT_TAG)
#define cp_not_active(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY_NOT_ACTIVE, CHAT_TAG)
#define cp_dont_have(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_HAVE,		CHAT_TAG)
#define cp_cant_buy(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUY,		CHAT_TAG)
#define cp_buyzone(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUYZONE,	CHAT_TAG)
#define cp_cant_buy_team(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUY_TEAM,	CHAT_TAG)
#define cp_cant_pickup(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_PICKUP,	CHAT_TAG)
#define cp_maximum_deployed(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_DEPLOY,	CHAT_TAG)
#define cp_have_max(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_HAVE,		CHAT_TAG)
#define cp_many_ppl(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_PPL,		CHAT_TAG)
#define cp_delay_time(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_DELAY_SEC,	CHAT_TAG, int:get_pcvar_num(gCvar[CVAR_START_DELAY]) - gNowTime)
#define cp_must_wall(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_PLANT_WALL,	CHAT_TAG)
#define cp_must_ground(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_PLANT_GROUND,	CHAT_TAG)
#define cp_sorry(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_SORRY_IMPL,	CHAT_TAG)
#define cp_noround(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOROUND, 		CHAT_TAG)


//====================================================
// ENUM AREA
//====================================================
//
// Tripmine Action Control
//
enum TRIPMINE_MODE
{
	MODE_LASERMINE			= 0,
	MODE_TRIPMINE			,
	MODE_BF4_CLAYMORE		,
}
enum TRIPMINE_STATE
{
	TRIPMINE_IDLE1			= 0,
	TRIPMINE_IDLE2			,
	TRIPMINE_ARM1			,
	TRIPMINE_ARM2			,
	TRIPMINE_FIDGET			,
	TRIPMINE_HOLSTER		,
	TRIPMINE_DRAW			,
	TRIPMINE_WORLD			,		// Put.
	TRIPMINE_GROUND			,
};

enum TRIPMINE_THINK
{
	POWERUP_THINK			= 0,
	BEAMBREAK_THINK			,
	EXPLOSE_THINK			,
};

enum TRIPMINE_SOUND
{
	POWERUP_SOUND			= 0,
	ACTIVATE_SOUND			,
	STOP_SOUND				,
};

enum TRIPMINE_DMGMODE
{
	DMGMODE_ALWAYS			= 0,
	DMGMODE_ONCE			,
	DMGMODE_SECONDS			,
};
//
// CHECK ERROR CODE
//
enum ERROR
{
	NONE				= 0,
	NOT_ACTIVE			,
	NOT_ACCESS			,
	DONT_HAVE			,
	CANT_BUY_TEAM		,
	CANT_BUY			,
	HAVE_MAX			,
	NO_MONEY			,
	MAXIMUM_DEPLOYED	,
	MANY_PPL			,
	DELAY_TIME			,
	NOT_ALIVE			,
	MUST_WALL			,
	MUST_GROUND			,
	NOT_IMPLEMENT		,
	NOT_BUYZONE			,
	NO_ROUND			,
};

//
// CVAR SETTINGS
//
enum CVAR_SETTING
{
	CVAR_ENABLE				= 0,    	// Plugin Enable.
	CVAR_ACCESS_LEVEL		,		// Access level for 0 = ADMIN or 1 = ALL.
	CVAR_NOROUND			,		// Check Started Round.
	CVAR_CMD_MODE			,    	// 0 = +USE key, 1 = bind, 2 = each.
	CVAR_MODE				,    	// 0 = Lasermine, 1 = Tripmine.
	CVAR_MAX_HAVE			,    	// Max having ammo.
	CVAR_START_HAVE			,    	// Start having ammo.
	CVAR_FRAG_MONEY         ,    	// Get money per kill.
	CVAR_COST               ,    	// Buy cost.
	CVAR_BUY_ZONE           ,    	// Stay in buy zone can buy.
	CVAR_LASER_DMG          ,    	// Laser hit Damage.
	CVAR_TEAM_MAX           ,    	// Max deployed in team.
	CVAR_EXPLODE_RADIUS     ,   	// Explosion Radius.
	CVAR_EXPLODE_DMG        ,   	// Explosion Damage.
	CVAR_FRIENDLY_FIRE      ,   	// Friendly Fire.
	CVAR_CBT                ,   	// Can buy team. TR/CT/ALL
	CVAR_BUY_MODE           ,   	// Buy mode. 0 = off, 1 = on.
	CVAR_START_DELAY        ,   	// Round start delay time.
	// Laser design.
	CVAR_LASER_VISIBLE      ,   	// Laser line Visiblity. 0 = off, 1 = on.
	CVAR_LASER_BRIGHT       ,   	// Laser line brightness.
	CVAR_LASER_COLOR        ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_TR     ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_CT     ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_DMG_MODE     ,   	// Laser line damage mode. 0 = frame rate dmg, 1 = once dmg, 2 = 1second dmg.
	CVAR_LASER_DMG_DPS      ,   	// Laser line damage mode 2 only, damage/seconds. default 1 (sec)
	CVAR_MINE_HEALTH        ,   	// Lasermine health. (Can break.)
	CVAR_MINE_GLOW          ,   	// Glowing tripmine.
	CVAR_MINE_GLOW_MODE     ,   	// Glowing color mode.
	CVAR_MINE_GLOW_CT     	,   	// Glowing color for CT.
	CVAR_MINE_GLOW_TR    	,   	// Glowing color for T.
	CVAR_MINE_BROKEN		,		// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
	CVAR_DEATH_REMOVE		,		// Dead Player Remove Lasermine.
	CVAR_LASER_ACTIVATE		,		// Waiting for put lasermine. (0 = no progress bar.)
	CVAR_LASER_RANGE		,		// Laserbeam range.
	CVAR_ALLOW_PICKUP		,		// allow pickup.
//  CVAR_LASER_THINK        ,   	// Laser line think.
	CVAR_DIFENCE_SHIELD		,		// Shield hit.
	CVAR_REALISTIC_DETAIL	,		// Spark Effect.
};

//
// PLAYER DATA AREA
//
enum PLAYER_DATA_INT
{
	PLAYER_DELAY_COUNT		= 0,
	PLAYER_HAVE_MINE		,
	PLAYER_MINE_SETTING		,
	PLAYER_DEPLOYED			,
}

enum PLAYER_DATA_FLOAT
{
	PLAYER_MAX_SPEED		= 0,
}

enum int:PLAYER_DEPLOY_STATE
{
	STATE_IDLE				= 0,
	STATE_DEPLOYING			,
	STATE_DEPLOYED			,
}

enum PICKUP_MODE
{
	DISALLOW_PICKUP			= 0,
	ONLY_ME					,
	ALLOW_FRIENDLY			,
	ALLOW_ENEMY				,
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
new gMsgStatusText, gMsgBarTime;
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
stock bool:fm_get_user_buyzone	(id)				{ return bool:(get_pdata_int(id, OFFSET_MAPZONE) & PLAYER_IN_BUYZONE); }
stock fm_get_entity_class_name	(id)
{
	new entityName[MAX_NAME_LENGTH];
	pev(id, pev_classname, entityName, charsmax(entityName));
	return entityName;
}
stock bool:is_valid_takedamage(iAttacker, iTarget)
{
	if (get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]))
		return true;

	if (cs_get_user_team(iAttacker) != cs_get_user_team(iTarget))
		return true;

	return false;
}
stock bool:is_user_friend(iAttacker, iTarget)
{
	if (get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]))
	if (cs_get_user_team(iAttacker) == cs_get_user_team(iTarget))
		return true;
	return false;
}

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Add your code here...
	register_concmd("bh_untakelm",	"luatlaser",	ADMIN_LEVEL_B, " - <num>"); 
	register_concmd("bh_takelm", 	"puslaser",		ADMIN_LEVEL_B, " - <num>"); 

	register_clcmd("+setlaser", "LaserMineProgressB");
	register_clcmd("+dellaser", "RemoveProgress");
   	register_clcmd("-setlaser", "StopProgress");
   	register_clcmd("-dellaser", "StopProgress");
	register_clcmd("say", "SayLasermine");
	register_clcmd("buy_lasermine", "BuyLasermine");

	// CVar settings.
	// Common.
	gCvar[CVAR_ENABLE]	        = register_cvar(fmt("%s%s", CVAR_TAG, "_enable"),				"1"			);	// 0 = off, 1 = on.
	gCvar[CVAR_ACCESS_LEVEL]   	= register_cvar(fmt("%s%s", CVAR_TAG, "_access"),				"0"			);	// 0 = all, 1 = admin
	gCvar[CVAR_MODE]           	= register_cvar(fmt("%s%s", CVAR_TAG, "_mode"),   				"0"			);	// 0 = lasermine, 1 = tripmine, 2 = claymore wire trap
	gCvar[CVAR_FRIENDLY_FIRE]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_friendly_fire"),		"0"			);	// Friendly fire. 0 or 1
	gCvar[CVAR_START_DELAY]    	= register_cvar(fmt("%s%s", CVAR_TAG, "_round_delay"),			"5"			);	// Round start delay time.
	gCvar[CVAR_CMD_MODE]	    = register_cvar(fmt("%s%s", CVAR_TAG, "_cmd_mode"),				"1"			);	// 0 is +USE key, 1 is bind, 2 is each.
#if defined BIOHAZARD_SUPPORT
	gCvar[CVAR_NOROUND]			= register_cvar(fmt("%s%s", CVAR_TAG, "_check_started_round"),	"1"			);	// Check Started Round.
#endif
	// Ammo.
	gCvar[CVAR_START_HAVE]	    = register_cvar(fmt("%s%s", CVAR_TAG, "_amount"),				"1"			);	// Round start have ammo count.
	gCvar[CVAR_MAX_HAVE]       	= register_cvar(fmt("%s%s", CVAR_TAG, "_max_amount"),   		"2"			);	// Max having ammo.
	gCvar[CVAR_TEAM_MAX]		= register_cvar(fmt("%s%s", CVAR_TAG, "_team_max"),				"10"		);	// Max deployed in team.

	// Buy system.
	gCvar[CVAR_BUY_MODE]	    = register_cvar(fmt("%s%s", CVAR_TAG, "_buy_mode"),				"1"			);	// 0 = off, 1 = on.
	gCvar[CVAR_CBT]    			= register_cvar(fmt("%s%s", CVAR_TAG, "_buy_team"),				"ALL"		);	// Can buy team. TR / CT / ALL. (BIOHAZARD: Z = Zombie)
	gCvar[CVAR_COST]           	= register_cvar(fmt("%s%s", CVAR_TAG, "_buy_price"),			"2500"		);	// Buy cost.
	gCvar[CVAR_BUY_ZONE]        = register_cvar(fmt("%s%s", CVAR_TAG, "_buy_zone"),				"1"			);	// Stay in buy zone can buy.
	gCvar[CVAR_FRAG_MONEY]     	= register_cvar(fmt("%s%s", CVAR_TAG, "_frag_money"),   		"300"		);	// Get money.

	// Laser design.
	gCvar[CVAR_LASER_VISIBLE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_visible"),		"1"			);	// Laser line visibility.
	gCvar[CVAR_LASER_COLOR]    	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_mode"),		"0"			);	// laser line color 0 = team color, 1 = green.
	// Leser beam color for team color mode.
	gCvar[CVAR_LASER_COLOR_TR] 	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_t"),		"255,0,0"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_LASER_COLOR_CT] 	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_ct"),		"0,0,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)

	gCvar[CVAR_LASER_BRIGHT]   	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_brightness"),		"255"		);	// laser line brightness.
	gCvar[CVAR_LASER_DMG]      	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_damage"),			"60.0"		);	// laser hit dmg. Float Value!
	gCvar[CVAR_LASER_DMG_MODE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_damage_mode"),	"0"			);	// Laser line damage mode. 0 = frame dmg, 1 = once dmg, 2 = 1 second dmg.
	gCvar[CVAR_LASER_DMG_DPS]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_dps"),			"1"			);	// laser line damage mode 2 only, damage/seconds. default 1 (sec)
	gCvar[CVAR_LASER_RANGE]		= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_range"),			"8192.0"	);	// Laser beam lange (float range.)

	// Mine design.
	gCvar[CVAR_MINE_HEALTH]    	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_health"),			"500"		);	// Tripmine Health. (Can break.)
	gCvar[CVAR_MINE_GLOW]      	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow"),			"1"			);	// Tripmine glowing. 0 = off, 1 = on.
	gCvar[CVAR_MINE_GLOW_MODE]  = register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_mode"),	"0"			);	// Mine glow coloer 0 = team color, 1 = green.
	gCvar[CVAR_MINE_GLOW_TR]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_t"),	"255,0,0"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_MINE_GLOW_CT]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_ct"),	"0,0,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)
	gCvar[CVAR_MINE_BROKEN]		= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_broken"),			"0"			);	// Can broken Mines.(0 = mines, 1 = Team, 2 = Enemy)
	gCvar[CVAR_EXPLODE_RADIUS] 	= register_cvar(fmt("%s%s", CVAR_TAG, "_explode_radius"),		"320.0"		);	// Explosion radius.
	gCvar[CVAR_EXPLODE_DMG]		= register_cvar(fmt("%s%s", CVAR_TAG, "_explode_damage"),		"100"		);	// Explosion radius damage.

	// Misc Settings.
	gCvar[CVAR_DEATH_REMOVE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_death_remove"),			"0"			);	// Dead Player remove lasermine. 0 = off, 1 = on.
	gCvar[CVAR_LASER_ACTIVATE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_activate_time"),		"1"			);	// Waiting for put lasermine. (int:seconds. 0 = no progress bar.)
	gCvar[CVAR_ALLOW_PICKUP]	= register_cvar(fmt("%s%s", CVAR_TAG, "_allow_pickup"),			"1"			);	// allow pickup mine. (0 = disable, 1 = it's mine, 2 = allow friendly mine, 3 = allow enemy mine!)
	gCvar[CVAR_DIFENCE_SHIELD]	= register_cvar(fmt("%s%s", CVAR_TAG, "_shield_difence"),		"1"			);	// allow shiled difence.
	gCvar[CVAR_REALISTIC_DETAIL]= register_cvar(fmt("%s%s", CVAR_TAG, "_realistic_detail"), 	"1"			);	// Spark Effect.
	RegisterHam(Ham_Spawn, 			"player", "NewRound", 		1);
	RegisterHam(Ham_Item_PreFrame,	"player", "KeepMaxSpeed", 	1);
	RegisterHam(Ham_Killed, 		"player", "PlayerKilling", 	0);
	RegisterHam(Ham_Think,			ENT_CLASS_NAME3, "LaserThink");
	RegisterHam(Ham_TakeDamage,		ENT_CLASS_NAME3, "MinesTakeDamage");
	RegisterHam(Ham_TraceAttack,	ENT_CLASS_NAME3, "MinesShowInfo");

	// register_event("HLTV", 		"NewRound", 	"a", "1=0", "2=0") 
	register_event("DeathMsg",  "DeathEvent",   "a");

	gMsgStatusText 	= get_user_msgid("StatusText");
	gMsgBarTime		= get_user_msgid("BarTime");
#if !defined UL_MONEY_SUPPORT
	gMsgMoney	    = get_user_msgid("Money");
#endif

	// -- Forward.
//	register_forward(FM_Think, 			"LaserThink");
	register_forward(FM_PlayerPostThink,"PlayerPostThink");
	register_forward(FM_PlayerPreThink, "PlayerPreThink");

	register_dictionary("lasermine.txt");
	register_cvar(AUTHOR, fmt("%s %s %s", CHAT_TAG, PLUGIN, VERSION), FCVAR_SERVER|FCVAR_SPONLY);

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
	precache_sound(ENT_SOUND8);
	precache_sound(ENT_SOUND9);
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
	new len = charsmax(file);
	get_localinfo("amxx_configsdir", file, len);

#if defined BIOHAZARD_SUPPORT
	format(file, len, "%s/bhltm_cvars.cfg", file);
#else
	format(file, len, "%s/ltm_cvars.cfg", file);
#endif
	if(file_exists(file)) 
	{
		server_cmd("exec %s", file);
		server_exec();
	}
}

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

	new Float:wait = get_pcvar_float(gCvar[CVAR_LASER_ACTIVATE]);
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

	new Float:wait = get_pcvar_float(gCvar[CVAR_LASER_ACTIVATE]);
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
	new Float:claymoreNormal[3];
	claymoreNormal = vNormal;
	xs_vec_mul_scalar(vNormal, range, vNormal );
	xs_vec_add( vNewOrigin, vNormal, vBeamEnd );

    // create the trace handle.
	new trace = create_tr2();
	// (const float *v1, const float *v2, int fNoMonsters, edict_t *pentToSkip, TraceResult *ptr);
	engfunc(EngFunc_TraceLine, vNewOrigin, vBeamEnd, IGNORE_MONSTERS, -1, trace);
	{
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
		set_claymore_endpoint(iEnt, vNewOrigin, claymoreNormal);
		return;
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
	
	new entityName[MAX_NAME_LENGTH];
	entityName = fm_get_entity_class_name(target);

	// Check. is Target Entity Lasermine?
	if(!equal(entityName, ENT_CLASS_NAME1))
		return 1;

	new ownerID = pev(target, LASERMINE_OWNER);

	new PICKUP_MODE:pickup 	= PICKUP_MODE:get_pcvar_num(gCvar[CVAR_ALLOW_PICKUP]);
	switch(pickup)
	{
		case DISALLOW_PICKUP:
			return 1;
		case ONLY_ME:
		{
			// Check. is Owner you?
			if(ownerID != uID)
				return 1;
		}
		case ALLOW_FRIENDLY:
		{
			// Check. is friendly team?
			if(CsTeam:pev(target, LASERMINE_TEAM) != CsTeam:cs_get_user_team(uID))
				return 1;
		}		
	}

	// Remove!
	remove_entity(target);

	// Collect for this removed lasermine.
	set_user_have_mine(uID, get_user_have_mine(uID) + int:1);

	if (pev_valid(ownerID))
	{
		// Return to before deploy count.
		set_user_mine_deployed(ownerID, get_user_mine_deployed(ownerID) - int:1);
	}

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

//====================================================
// Check: Can use this Team.
//====================================================
bool:check_for_team(id)
{
	new arg[4];
	new int:team;

	// Get Cvar
	get_pcvar_string(gCvar[CVAR_CBT], arg, charsmax(arg));

	// Terrorist
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "Z") || equali(arg, "Zombie"))
#else
	if(equali(arg, "TR") || equali(arg, "T"))
#endif
		team = int:CS_TEAM_T;
	else
	// Counter-Terrorist
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "H") || equali(arg, "Human"))
#else
	if(equali(arg, "CT"))
#endif
		team = int:CS_TEAM_CT;
	else
	// All team.
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "ZH") || equali(arg, "HZ") || equali(arg, "ALL"))
#else
	if(equali(arg, "ALL"))
#endif
		team = int:CS_TEAM_UNASSIGNED;
	else
		team = int:CS_TEAM_UNASSIGNED;

	// Cvar setting equal your team? Not.
	if(team != int:CS_TEAM_UNASSIGNED && team != int:cs_get_user_team(id))
		return false;

	return true;
}
//====================================================
// Check: common.
//====================================================
ERROR:check_for_common(id)
{
	new cvar_enable = get_pcvar_num(gCvar[CVAR_ENABLE]);
	new cvar_access = get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]);
	new user_flags	= get_user_flags(id) & ADMIN_ACCESSLEVEL;
	new is_alive	= fm_is_user_alive(id);
	new TRIPMINE_MODE:cvar_mode	= TRIPMINE_MODE:get_pcvar_num(gCvar[CVAR_MODE]);

	// Plugin Enabled
	if (!cvar_enable)
		return ERROR:NOT_ACTIVE;

	// Can Access.
	if (cvar_access != 0 && !user_flags) 
		return ERROR:NOT_ACCESS;

	// Is this player Alive?
	if (!is_alive) 
		return ERROR:NOT_ALIVE;

	// claymore.
	if (cvar_mode == MODE_BF4_CLAYMORE)
	 	return ERROR:NOT_IMPLEMENT;

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
	new cvar_buyzone	=	  get_pcvar_num(gCvar[CVAR_BUY_ZONE]);

	// Buy mode ON?
	if (cvar_buymode)
	{
		// Can this team buying?
		if (!check_for_team(id))
			return ERROR:CANT_BUY_TEAM;

		// Have Max?
		if (get_user_have_mine(id) >= cvar_maxhave)
			return ERROR:HAVE_MAX;

		// buyzone area?
		if (cvar_buyzone && !fm_get_user_buyzone(id))
			return ERROR:NOT_BUYZONE;

		// Have money?
		if (cs_get_user_money(id) < cvar_cost)
			return ERROR:NO_MONEY;


	} else {
		return ERROR:CANT_BUY;
	}

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
		case NOT_IMPLEMENT:		cp_sorry(id);
		case NOT_BUYZONE:		cp_buyzone(id);
		case NO_ROUND:			cp_noround(id);
	}
}

//====================================================
// Check: Remove Lasermine.
//====================================================
bool:check_for_remove(id)
{
	new int:cvar_ammo		= int:get_pcvar_num(gCvar[CVAR_MAX_HAVE]);
	new ERROR:error 		= check_for_common(id);
	new PICKUP_MODE:pickup 	= PICKUP_MODE:get_pcvar_num(gCvar[CVAR_ALLOW_PICKUP]);
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
	
	new entityName[MAX_NAME_LENGTH];
	entityName = fm_get_entity_class_name(target);

	// is target lasermine?
	if(!equal(entityName, ENT_CLASS_NAME1))
		return false;


	switch(pickup)
	{
		case DISALLOW_PICKUP:
		{
			cp_cant_pickup(id);
			return false;
		}
		case ONLY_ME:
		{
			// is owner you?
			if(pev(target, LASERMINE_OWNER) != id)
				return false;
		}
		case ALLOW_FRIENDLY:
		{
			// is team friendly?
			if(CsTeam:pev(target, LASERMINE_TEAM) != CsTeam:cs_get_user_team(id))
				return false;
		}
	}

	// Allow Enemy.
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
// Check: Round Started
//====================================================
#if defined BIOHAZARD_SUPPORT
ERROR:check_round_started()
{
	if (get_pcvar_num(gCvar[CVAR_NOROUND]))
	{
		if(!game_started())
			return ERROR:NO_ROUND;
	}
	return ERROR:NONE;
}
#endif
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

#if defined BIOHAZARD_SUPPORT
	// Check Started Round.
	error = check_round_started();
	if(error)
	{
		show_error_message(id, error);
		return false;
	}	
#endif
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
		return HAM_IGNORED;

	// is valid this entity?
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	new entityName[MAX_NAME_LENGTH];
	entityName = fm_get_entity_class_name(iEnt);

	// is this lasermine? no.
	if (!equal(entityName, ENT_CLASS_NAME1))
		return HAM_IGNORED;

	static Float:fCurrTime
	static TRIPMINE_THINK:step;

	fCurrTime = get_gametime();
	step = TRIPMINE_THINK:pev(iEnt, LASERMINE_STEP);
	
	// lasermine state.
	// Power up.
	if (step == TRIPMINE_THINK:POWERUP_THINK)
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

		mine_glowing(iEnt);

		// Think time.
		set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);

		return HAM_HANDLED;
	}

	// Get owner id.
	new iOwner = pev(iEnt, LASERMINE_OWNER);

	// Laser line activated.
	if (step == TRIPMINE_THINK:BEAMBREAK_THINK)
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
		static hitGroup;
		static loop;
		static Float:fFraction;
		loop = TRIPMINE_MODE:get_pcvar_num(gCvar[CVAR_MODE]) == MODE_BF4_CLAYMORE ? 3 : 1;

		static trace;
		static Float:hitPoint[3];
		for(new i = 0; i < loop; i++)
		{
			// create the trace handle.
			trace = create_tr2();
			// Trace line
			engfunc(EngFunc_TraceLine, vOrigin, vEnd[i], DONT_IGNORE_MONSTERS, iEnt, trace)
			{
				get_tr2(trace, TR_flFraction, fFraction);
				iTarget		= get_tr2(trace, TR_pHit);
				hitGroup	= get_tr2(trace, TR_iHitgroup)
				get_tr2(trace, TR_vecEndPos, hitPoint);				
			}
			// free the trace handle.
			free_tr2(trace);

			// Something has passed the laser.
			if (fFraction >= 1.0)
				continue;

			// is valid hit entity?
			if (!pev_valid(iTarget))
				continue;

			// is user?
			if (!(pev(iTarget, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
				continue;

			// is dead?
			if (!fm_is_user_alive(iTarget))
				continue;

			// Hit friend and No FF.
			if (!is_valid_takedamage(iOwner, iTarget))
				continue;

			// is godmode?
			if (fm_is_user_godmode(iTarget))
				continue;


			// keep target id.
			set_pev(iEnt, pev_enemy, iTarget);

			// Mode. Lasermine / Tripmine / Claymore wire trap.
			switch(get_pcvar_num(gCvar[CVAR_MODE]))
			{
				// Lasermine mode.
				// Laser damage.
				case MODE_LASERMINE:
				{
					create_laser_damage(iEnt, iTarget, hitGroup, hitPoint);

					// Laser line damage mode. Once or Second.
					if (get_pcvar_num(gCvar[CVAR_LASER_DMG_MODE]) != 0)
						// if change target. keep target id.
						if (pev(iEnt, LASERMINE_HITING) != iTarget)
							set_pev(iEnt, LASERMINE_HITING, iTarget);

				}
				// Tripmine mode.
				// Friendly Fire ON or Target is Enemy Team.
				case MODE_TRIPMINE, MODE_BF4_CLAYMORE:
				{
					// State change. to Explosing step.
					set_pev(iEnt, LASERMINE_STEP, EXPLOSE_THINK);
				}
			}
		}
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
				
		// drawing laser line.
		if (get_pcvar_num(gCvar[CVAR_LASER_VISIBLE]))
		{
			for (new i = 0; i < loop; i++)
			{
				draw_laserline(iEnt, vOrigin, vEnd[i]);
				draw_spark_for_wall(vEnd[i]);				
			}
		}

		// Think time. random_float = laser line blinking.
		set_pev(iEnt, pev_nextthink, fCurrTime + random_float(0.01, 0.02));

		return HAM_HANDLED;
	}

	// EXPLODE
	if (TRIPMINE_THINK:step == TRIPMINE_THINK:EXPLOSE_THINK)
	{
		// Stopping entity to think
		set_pev(iEnt, pev_nextthink, 0.0);
		// 
		play_sound(iEnt, STOP_SOUND);

		// Count down. deployed lasermines.
		set_user_mine_deployed(iOwner, get_user_mine_deployed(iOwner) - int:1);

		// effect explosion.
		create_explosion(iEnt);
		// damage.
		create_explosion_damage(iEnt, get_pcvar_float(gCvar[CVAR_EXPLODE_DMG]), get_pcvar_float(gCvar[CVAR_EXPLODE_RADIUS]));

		// remove this.
		remove_entity(iEnt);
		return HAM_HANDLED;
	}

	return HAM_SUPERCEDE;
}

//====================================================
// Blocken Mines.
//====================================================
public MinesTakeDamage(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	// We get the ID of the player who put the mine.
	new iOwner = pev(victim, LASERMINE_OWNER);
	switch(get_pcvar_num(gCvar[CVAR_MINE_BROKEN]))
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
			if(CsTeams:pev(victim, LASERMINE_TEAM) != CsTeams:cs_get_user_team(attacker))
				return HAM_SUPERCEDE;
		}
		default:
			return HAM_IGNORED;
	}
	return HAM_IGNORED;
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

mine_glowing(iEnt)
{
	new tcolor	[3];
	new sRGB	[13];
	new sColor	[4];
	new sRGBLen 	= charsmax(sRGB);
	new sColorLen	= charsmax(sColor);
	new CsTeams:teamid = CsTeams:pev(iEnt, LASERMINE_TEAM);

	new i = 0, n = 0, iPos = 0;

	// Glow mode.
	if (get_pcvar_num(gCvar[CVAR_MINE_GLOW]) != 0)
	{
		// Color setting.
		if (get_pcvar_num(gCvar[CVAR_MINE_GLOW_MODE]) == 0)
		{
			// Team color.
			switch (teamid)
			{
				case CS_TEAM_T:
					get_pcvar_string(gCvar[CVAR_MINE_GLOW_TR], sRGB, sRGBLen);
				case CS_TEAM_CT:
					get_pcvar_string(gCvar[CVAR_MINE_GLOW_CT], sRGB, sRGBLen);
				default:
					formatex(sRGB, sRGBLen, "0,255,0");
			} 
		}
		else
		{
			formatex(sRGB, sRGBLen, "0,255,0");
		}

		formatex(sRGB, sRGBLen, "%s%s", sRGB, ",");
		while(n < sizeof(tcolor))
		{
			i = split_string(sRGB[iPos += i], ",", sColor, sColorLen);
			tcolor[n++] = str_to_num(sColor);
		}
		set_glow_rendering(iEnt, kRenderFxGlowShell, tcolor[0], tcolor[1], tcolor[2], kRenderNormal, 5);
	}
}
//====================================================
// Drawing Laser line.
//====================================================
draw_laserline(iEnt, const Float:vOrigin[3], const Float:vEndOrigin[3])
{
	new tcolor	[3];
	new sRGB	[13];
	new sColor	[4];
	new sRGBLen 	= charsmax(sRGB);
	new sColorLen	= charsmax(sColor);
	new CsTeams:teamid = CsTeams:pev(iEnt, LASERMINE_TEAM);
	new width = 5;
	new i = 0, n = 0, iPos = 0;
	// Color mode. 0 = team color.
	if(get_pcvar_num(gCvar[CVAR_LASER_COLOR]) == 0)
	{
		switch(teamid)
		{
			case CS_TEAM_T:
				get_pcvar_string(gCvar[CVAR_LASER_COLOR_TR], sRGB, sRGBLen);
			case CS_TEAM_CT:
				get_pcvar_string(gCvar[CVAR_LASER_COLOR_CT], sRGB, sRGBLen);
			default:
#if !defined BIOHAZARD_SUPPORT
				formatex(sRGB, sRGBLen, "0,255,0");
#else
				formatex(sRGB, sRGBLen, "255,0,0");
#endif
		}

	}else
	{
		// Green.
		formatex(sRGB, sRGBLen, "0,255,0");
	}

	formatex(sRGB, sRGBLen, "%s%s", sRGB, ",");
	while(n < sizeof(tcolor))
	{
		i = split_string(sRGB[iPos += i], ",", sColor, sColorLen);
		tcolor[n++] = str_to_num(sColor);
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

draw_spark_for_wall(const Float:vEndOrigin[3])
{
   	// Sparks
	if(get_pcvar_num(gCvar[CVAR_REALISTIC_DETAIL])) 
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vEndOrigin, 0);
		write_byte(TE_SPARKS); // TE id
		engfunc(EngFunc_WriteCoord, vEndOrigin[0]); // x
		engfunc(EngFunc_WriteCoord, vEndOrigin[1]); // y
		engfunc(EngFunc_WriteCoord, vEndOrigin[2]); // z
		message_end();
      
		// Effects when cut
		engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, vEndOrigin[0]);
		engfunc(EngFunc_WriteCoord, vEndOrigin[1]);
		engfunc(EngFunc_WriteCoord, vEndOrigin[2] - 10.0);
		write_short(TE_SPARKS);	// sprite index
		write_byte(1);	// scale in 0.1's
		write_byte(30);	// framerate
		write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND);	// flags
		message_end();
	}	
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
		if (!pev_valid(rEnt)) 
			continue;

		// Entity is not a player or monster, ignore it
		if (!(pev(rEnt, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
			continue;

		// is alive?
		if (!fm_is_user_alive(rEnt))
			continue;
		
		// friendly fire
		if (!is_valid_takedamage(iAttacker, rEnt))
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
			// Damage Effect, Damage, Killing Logic.
			ExecuteHamB(Ham_TakeDamage, rEnt, iEnt, iAttacker, tmpDmg, DMG_MORTAR);
		}
	}
	return;
}

//====================================================
// Laser damage
//====================================================
create_laser_damage(iEnt, iTarget, hitGroup, Float:hitPoint[3])
{
	// Damage mode.	
	new dmgmode 	= get_pcvar_num(gCvar[CVAR_LASER_DMG_MODE]);
	new Float:dmg 	= get_pcvar_float(gCvar[CVAR_LASER_DMG]);

	switch (dmgmode)
	{
		// Once hit.
		case DMGMODE_ONCE:
		{
			// Already Hit target.
			if (pev(iEnt, LASERMINE_HITING) == iTarget)
				return;
		}
		// Seconds hit.
		case DMGMODE_SECONDS:
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

			}
			// Keep now time.
			set_pev(iEnt, LASERMINE_COUNT, (get_gametime() + laserdps))
		}
	}

	new iAttacker = pev(iEnt,LASERMINE_OWNER);
	if (get_pcvar_num(gCvar[CVAR_DIFENCE_SHIELD]) && hitGroup == HIT_SHIELD)
	{
		emit_sound(iTarget, CHAN_VOICE, random_num(0, 1) == 1 ? ENT_SOUND8 : ENT_SOUND9, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		draw_spark(hitPoint);

        // EMIT_SOUND(pEntity->edict(), CHAN_VOICE, (RANDOM_LONG(0, 1) == 1) ? "weapons/ric_metal-1.wav" : "weapons/ric_metal-2.wav", VOL_NORM, ATTN_NORM);
        // UTIL_Sparks(tr.vecEndPos);
		static Float:punchangle[3];
		punchangle[0] = dmg * random_float(-0.15, 0.15);
		punchangle[2] = dmg * random_float(-0.15, 0.15);
		if (punchangle[0] < 4.0)
			punchangle[0] = -4.0;
		if (punchangle[2] < -5.0)
			punchangle[2] = -5.0;
		else
			if (punchangle[2] > 5.0)
				punchangle[2] = 5.0;

		set_pev(iTarget, pev_punchangle, punchangle);
	}
	else
	{
		if (is_user_friend(iAttacker, iTarget))
		{
			// Hit
			emit_sound(iTarget, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM);
			new CsTeam:aTeam = CsTeam:cs_get_user_team(iAttacker);
			cs_set_user_team(iAttacker, int:((aTeam == CsTeam:CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T));
			// Damage Effect, Damage, Killing Logic.
			ExecuteHamB(Ham_TakeDamage, iTarget, iEnt, iAttacker, get_pcvar_float(gCvar[CVAR_LASER_DMG]), DMG_ENERGYBEAM);
			cs_set_user_team(iAttacker, int:aTeam);
		}
		else
		{
			// Hit
			emit_sound(iTarget, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM);
			// Damage Effect, Damage, Killing Logic.
			ExecuteHamB(Ham_TakeDamage, iTarget, iEnt, iAttacker, get_pcvar_float(gCvar[CVAR_LASER_DMG]), DMG_ENERGYBEAM);
		}
	}
	set_pev(iEnt, LASERMINE_HITING, iTarget);		
	
	// // is target func_breakable?
	// if (equal(entityName, ENT_CLASS_NAME3))
	// {
	// 	ExecuteHamB(Ham_TakeDamage, iTarget, iEnt, iAttacker, get_pcvar_float(gCvar[CVAR_LASER_DMG]));
	// 	// damage it.
	// 	//set_user_health(iTarget, Float:(fm_get_user_health(iTarget) - get_pcvar_float(gCvar[CVAR_LASER_DMG])));
	// }
	return;
}

stock draw_spark(Float:origin[3])
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_SPARKS);
	engfunc(EngFunc_WriteCoord, origin[0]);
	engfunc(EngFunc_WriteCoord, origin[1]);
	engfunc(EngFunc_WriteCoord, origin[2]);
	message_end();
}
//====================================================
// Player killing (Set Money, Score)
//====================================================
public PlayerKilling(iVictim, iAttacker)
{
	static entityName[MAX_NAME_LENGTH];
	entityName = fm_get_entity_class_name(iAttacker);
	//
	// Refresh Score info.
	//
	if (equali(entityName, ENT_CLASS_NAME1))
	{
		// Get Target Team.
		new aTeam = int:cs_get_user_team(iAttacker);
		new vTeam = int:cs_get_user_team(iVictim);

		new score  = (vTeam != aTeam) ? 1 : -1;
		new money  = (vTeam != aTeam) ? get_pcvar_num(gCvar[CVAR_FRAG_MONEY]) : (get_pcvar_num(gCvar[CVAR_FRAG_MONEY]) * -1);

		// Attacker Frag.
		// Add Attacker Frag (Friendly fire is minus).
		new int:aFrag = int:fm_get_user_frags(iAttacker) + int:score;
		new aDeath = cs_get_user_deaths(iAttacker);

		set_pdata_int(iAttacker, m_iDeaths, aDeath);
		ExecuteHamB(Ham_AddPoints, iAttacker, aFrag - int:fm_get_user_frags(iAttacker), true);

		new tDeath = cs_get_user_deaths(iVictim);

		set_pdata_int(iVictim, m_iDeaths, tDeath);
		ExecuteHamB(Ham_AddPoints, iVictim, 0, true);

		// Get Money attacker.
		cs_set_user_money(iAttacker, cs_get_user_money(iAttacker) + money);

		return HAM_HANDLED;
	}
	return HAM_IGNORED;
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
		formatex(ammo, charsmax(ammo), "%L", id, LANG_KEY_STATE_AMMO, get_user_have_mine(id), get_pcvar_num(gCvar[CVAR_MAX_HAVE]));
	else
		formatex(ammo, charsmax(ammo), "%L", id, LANG_KEY_STATE_INF);

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
	read_argv(1, said, charsmax(said));
	
	if (equali(said,"/buy lasermine") || equali(said,"/lm"))
	{
		BuyLasermine(id);
//		return PLUGIN_HANDLED;
	} else 
	if (equali(said, "lasermine") || equali(said, "/lasermine"))
	{
		const SIZE = 1024;
		new msg[SIZE + 1], len = 0;
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
		return PLUGIN_HANDLED;
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
	new entityName[MAX_NAME_LENGTH];
	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", ENT_CLASS_NAME1)))
	{
		if (!pev_valid(iEnt))
			continue;

		if (is_user_connected(id))
		{
			if (pev(iEnt, LASERMINE_OWNER) != id)
				continue;
			entityName = fm_get_entity_class_name(iEnt);
				
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

stock set_claymore_endpoint(iEnt, Float:vOrigin[3], Float:vNormal[3])
{
	new Float:vForward[3];
	new Float:vResultA[3];
	new Float:vResultB[3];
	new Float:vResultC[3];
	new Float:hitPoint[3];
	new Float:pAngles[3];
	new Float:vFwd[3];
	new Float:vRight[3];
	new Float:vUp[3];
	vResultA = vOrigin;
	vResultB = vOrigin;
	vResultC = vOrigin;

	// pev(iEnt, pev_angles, vAngles);
	// angle_vector(vAngles, ANGLEVECTOR_FORWARD, vAngles);

	// xs_vec_mul_scalar(vAngles, 60.0, vAngles);
	// xs_vec_add(vAngles, vOrigin, vAngles);

	for (new i = 0; i < 3; i++)
	{
		pAngles[0] = random_float(-45.0, 45.0);
		pAngles[1] = random_float(-180.0, 180.0);
		pAngles[2] = random_float(-90.0, 90.0);
		xs_anglevectors(pAngles, vFwd, vRight, vUp);
		xs_vec_mul_scalar(vFwd, 300.0, vFwd);
		xs_vec_add(vFwd, vNormal, vForward);
		xs_vec_add(vOrigin, vForward, vForward);

		new trace = create_tr2();
		// Trace line
		engfunc(EngFunc_TraceLine, vOrigin, vForward, IGNORE_MONSTERS, iEnt, trace)
		{
			get_tr2(trace, TR_vecEndPos, hitPoint);
		}
		if (xs_vec_distance(vOrigin, vResultA) < xs_vec_distance(vOrigin, hitPoint) && !xs_vec_equal(vResultA, hitPoint))
		{
			vResultC = vResultB;
			vResultB = vResultA;
			vResultA = hitPoint;
		}
		else
		if (xs_vec_distance(vOrigin, vResultB) < xs_vec_distance(vOrigin, hitPoint) && !xs_vec_equal(vResultB, hitPoint))
		{
			vResultC = vResultB;
			vResultB = hitPoint;
		}
		else
		if (xs_vec_distance(vOrigin, vResultC) < xs_vec_distance(vOrigin, hitPoint) && !xs_vec_equal(vResultC, hitPoint))
		{
			vResultC = hitPoint;
		}
		// free the trace handle.
		free_tr2(trace);
	}
	set_pev(iEnt, LASERMINE_BEAMENDPOINT1, vResultA);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT2, vResultB);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT3, vResultC);
}

public MinesShowInfo(iVictim, iAttacker, Float:flDamage, Float:flDirection[3], iTr, iDamageBits)
{ 
	new entityName[MAX_NAME_LENGTH];
	entityName = fm_get_entity_class_name(iVictim);

	if (equali(entityName, ENT_CLASS_NAME1))
	{
		new name[MAX_NAME_LENGTH];
		new id = pev(iVictim, LASERMINE_OWNER);
		new Float:health = fm_get_user_health(iVictim);
		get_user_name(id, name, charsmax(name));
		set_hudmessage( 50, 100, 150, -1.0, 0.60, 0, 6.0, 1.1, 0.0, 0.0, -1);
		show_hudmessage(iAttacker, "Owner: %s^nHealth: %d/%d", name, health, get_pcvar_num(gCvar[CVAR_MINE_HEALTH]));
	}
} 

public luatlaser(id, level, cid) 
{ 
   if (!cmd_access(id, level, cid, 2)) 
   { 
      return PLUGIN_HANDLED 
   } 

   new arg[32] 
    
   read_argv(1, arg, 31) 
   new player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF) 
    
   if (!player) 
      return PLUGIN_HANDLED 

   delete_task(player); 
   remove_all_lasermines(player); 

   new namea[32],namep[32]; 
   get_user_name(id,namea,charsmax(namea)); 
   get_user_name(player,namep,charsmax(namep)); 
   client_print_color(0, print_chat, "!g[Biohazard] !yAdminul !g%s !yi-a dezactivat laserele lui !g%s!y.", namea, namep);

   return PLUGIN_HANDLED; 
} 

public puslaser(id, level, cid) 
{ 
   if (!cmd_access(id, level, cid, 2)) 
   { 
      return PLUGIN_HANDLED 
   } 

   new arg[32] 
    
   read_argv(1, arg, 31) 
   new player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF) 
    
   if (!player) 
      return PLUGIN_HANDLED 

   delete_task(player); 
   set_start_ammo(player); 

   new namea[MAX_NAME_LENGTH],namep[MAX_NAME_LENGTH]; 
   get_user_name(id,namea,charsmax(namea)); 
   get_user_name(player,namep,charsmax(namep)); 
   client_print_color(0, print_chat, "!g[Biohazard] !yAdminul !g%s !yi-a reactivat laserele lui !g%s!y.", namea, namep);

   return PLUGIN_HANDLED; 
} 

public checkIfspec(id) 
{
	if(get_user_mine_deployed(id) > int:0) 
	{
		if(CsTeams:cs_get_user_team(id) == CsTeams:CS_TEAM_SPECTATOR)
		{
			delete_task(id);
			remove_all_lasermines(id);
			new namep[MAX_NAME_LENGTH];
			get_user_name(id,namep,charsmax(namep));
			client_print_color(0, print_chat, "!g[Biohazard] !yLaserele lui !g%s !gau fost dezactivate deoarece s-a mutat la !gspectatori!y!",namep); 
          } 
     } 
} 