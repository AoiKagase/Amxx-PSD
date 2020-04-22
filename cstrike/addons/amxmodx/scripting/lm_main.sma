
//=============================================
//	Plugin Writed by Visual Studio Code.
//=============================================
// Supported BIOHAZARD.
// #define BIOHAZARD_SUPPORT

//=====================================
//  INCLUDE AREA
//=====================================
#include <amxmodx>
#include <amxmisc>
#include <amxconst>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <mines_util>

//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 200
	#assert "AMX Mod X v1.10.0 or greater library required!"
	#define MAX_PLAYERS				32
#endif

#if defined BIOHAZARD_SUPPORT
	#define PLUGIN 					"Lasermine for BIOHAZARD"

	#define CHAT_TAG 				"[Biohazard]"
	#define CVAR_TAG				"bh_ltm"
	#define LANG_KEY_NOT_BUY_TEAM	"NOT_BUY_TEAM"
#else
	#define PLUGIN 					"Laser/Tripmine Entity"

	#define CHAT_TAG 				"[Lasermine]"
	#define CVAR_TAG				"amx_ltm"
	#define LANG_KEY_NOT_BUY_TEAM 	"NOT_BUY_TEAM"
#endif

//=====================================
//  Resource Setting AREA
//=====================================
#define ENT_MODELS					"models/v_tripmine.mdl"
#define ENT_SOUND1					"weapons/mine_deploy.wav"
#define ENT_SOUND2					"weapons/mine_charge.wav"
#define ENT_SOUND3					"weapons/mine_activate.wav"
#define ENT_SOUND4					"items/gunpickup2.wav"
#define ENT_SOUND5					"debris/beamstart9.wav"
#define ENT_SOUND6					"weapons/ric_metal-1.wav"
#define ENT_SOUND7					"weapons/ric_metal-2.wav"
#define ENT_SOUND8					"debris/bustglass1.wav"
#define ENT_SOUND9					"debris/bustglass2.wav"
#define ENT_SPRITE1 				"sprites/laserbeam.spr"
#define ENT_SPRITE2 				"sprites/eexplo.spr"

//=====================================
//  MACRO AREA
//=====================================
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"3.08"

//#define STR_MINEDETNATED 			"Your mine has detonated.",
//#define STR_MINEDETNATED2			"detonated your mine.",
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
#define LANG_KEY_ALL_REMOVE			"ALL_REMOVE"
#define LANG_KEY_GIVE_MINE			"GIVE_MINE"
#define LANG_KEY_REMOVE_SPEC		"REMOVE_SPEC"
#define LANG_KEY_MINE_HUD			"MINE_HUD_MSG"

// ADMIN LEVEL
#define ADMIN_ACCESSLEVEL			ADMIN_LEVEL_H

#if defined BIOHAZARD_SUPPORT
	#define CS_TEAM_ZOMBIE			4
#endif

// Put Guage ID
#define TASK_PLANT					15100
#define TASK_RESET					15500
#define TASK_RELEASE				15900

#define MAX_CLAYMORE				40

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
#define cp_must_wall(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_PLANT_WALL,	CHAT_TAG)
#define cp_must_ground(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_PLANT_GROUND,	CHAT_TAG)
#define cp_sorry(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_SORRY_IMPL,	CHAT_TAG)
#define cp_noround(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOROUND, 		CHAT_TAG)
#define cp_all_remove(%1,%2,%3)		client_print_color(%1, %1, "%L", %1, LANG_KEY_ALL_REMOVE,	CHAT_TAG, %2, %3)
#define cp_gave(%1,%2,%3)			client_print_color(%1, %1, "%L", %1, LANG_KEY_GIVE_MINE,	CHAT_TAG, %2, %3)
#define cp_remove_spec(%1,%2)		client_print_color(%1, %1, "%L", %1, LANG_KEY_REMOVE_SPEC,	CHAT_TAG, %2)

enum _:HIT_PLAYER
{
	I_TARGET				= 0,
	I_HIT_GROUP				= 1,
	Float:V_POSITION[3]		= 2,
};

//
// CVAR SETTINGS
//
enum CVAR_SETTING
{
	CVAR_ENABLE				= 0,    // Plugin Enable.
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
	CVAR_LASER_WIDTH		,		// Laser line width.
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
	CVAR_CM_WIRE_RANGE		,		// Claymore Wire Range.
	CVAR_CM_WIRE_WIDTH		,		// Claymore Wire Width.
	CVAR_CM_CENTER_PITCH	,		// Claymore Wire Area Center Pitch.
	CVAR_CM_CENTER_YAW		,		// Claymore Wire Area Center Yaw.
	CVAR_CM_LEFT_PITCH		,		// Claymore Wire Area Left Pitch.
	CVAR_CM_LEFT_YAW		,		// Claymore Wire Area Left Yaw.
	CVAR_CM_RIGHT_PITCH		,		// Claymore Wire Area Right Pitch.
	CVAR_CM_RIGHT_YAW		,		// Claymore Wire Area Right Yaw.
	CVAR_CM_TRIAL_FREQ		,		// Claymore Wire trial frequency.
	CVAR_CM_WIRE_COLOR		,
	CVAR_CM_WIRE_COLOR_T	,
	CVAR_CM_WIRE_COLOR_CT	,
};

enum _:FORWARDER
{
	FWD_SET_ENTITY_SPAWN,
	FWD_PUTIN_SERVER,
	FWD_REMOVE_MINE,
	FWD_CHECK_DEPLOY,
	FWD_CHECK_REMOVE,
	FWD_CHECK_FOR_BUY,
	FWD_DISCONNECTED,
};
//====================================================
//  GLOBAL VARIABLES
//====================================================
new gCvar[CVAR_SETTING];

new gMsgBarTime;

new gEntMine;
new gForwarder			[FORWARDER];
new Array:gCMinesData;
new Array:gPlayerData	[MAX_PLAYERS];
new gCPlayerData		[MAX_PLAYERS][COMMON_PLAYER_DATA];
//====================================================
//  Player Data functions
//====================================================
stock lm_get_mines_data(minesid, field)
{
	static mData[COMMON_MINES_DATA];
	ArrayGetArray(gCMinesData, minesid, mData, sizeof(mData));
	return mData[field];
}
stock lm_set_mines_data(minesid, field, value)
{
	static mData[COMMON_MINES_DATA];
	ArrayGetArray(gCMinesData, minesid, mData, sizeof(mData));
	mData[field] = value;
	ArraySetArray(gCMinesData, minesid, mData, sizeof(mData));
}
stock lm_get_player_data(id, minesid, field)
{
	static plData[PLAYER_DATA];
	ArrayGetArray(gPlayerData[id], minesid, plData, sizeof(plData));
	return plData[field];
}
stock lm_set_player_data(id, minesid, field, value)
{
	static plData[PLAYER_DATA];
	ArrayGetArray(gPlayerData[id], minesid, plData, sizeof(plData));
	plData[field] = value;
	ArraySetArray(gPlayerData[id], minesid, plData, sizeof(plData));
}
stock lm_stock_set_user_delay_count			(id, minesid, int:value) 	
{
	lm_set_player_data(id, minesid, PL_COUNT_DELAY, value);
}
stock lm_stock_set_user_have_mine			(id, minesid, int:value)
{
	lm_set_player_data(id, minesid, PL_COUNT_HAVE_MINE, value);
}
stock lm_stock_set_user_mine_deployed		(id, minesid, int:value)
{
	lm_set_player_data(id, minesid, PL_COUNT_DEPLOYED, value);
}
stock int:lm_stock_get_user_delay_count		(id, minesid)
{
	return lm_get_player_data(id, minesid, PL_COUNT_DELAY);
}
stock int:lm_stock_get_user_have_mine		(id, minesid)
{
	return int:lm_get_player_data(id, minesid, PL_COUNT_HAVE_MINE);
}
stock int:lm_stock_get_user_mine_deployed	(id, minesid)
{
	return int:lm_get_player_data(id, minesid, PL_COUNT_DEPLOYED);
}

stock int:lm_get_user_deploy_state			(id) 						{ return int:gCPlayerData[id][PL_STATE_DEPLOY];}
stock Float:lm_load_user_max_speed			(id)						{ return Float:gCPlayerData[id][PL_MAX_SPEED]; }
stock Float:lm_get_user_max_speed			(id)						{ return Float:pev(id, pev_maxspeed); }
stock Float:lm_get_user_health				(id)
{
	new Float:health;
	pev(id, pev_health, health);
	return health;
}

stock lm_get_user_frags						(id)						{ return pev(id, pev_frags);}
stock bool:lm_get_user_buyzone				(id)						{ return bool:(get_pdata_int(id, OFFSET_MAPZONE) & PLAYER_IN_BUYZONE);}

stock lm_set_user_frags						(id, int:frags)				{ set_pev(id, pev_frags, frags); }
stock lm_set_user_deploy_state				(id, int:value)				{ gCPlayerData[id][PL_STATE_DEPLOY]	= int:value; }
stock lm_set_user_health					(id, Float:health)			{ health > 0 ? set_pev(id, pev_health, health) : user_kill(id, 1); }
stock lm_save_user_max_speed				(id, Float:value)			{ gCPlayerData[id][PL_MAX_SPEED]	= Float:value; }
stock lm_set_user_max_speed					(id, Float:value)			{ engfunc(EngFunc_SetClientMaxspeed, id, value);set_pev(id, pev_maxspeed, value); }



//====================================================
// Function: Count to deployed in team.
//====================================================
stock int:lm_get_team_deployed_count		(id, minesid)
{
	static int:i;
	static int:count;
	static int:num;
	static players[MAX_PLAYERS];
	static team[3] = '^0';

	// Witch your team?
	switch(CsTeams:lm_get_user_team(id))
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
		count += lm_stock_get_user_mine_deployed(players[i], minesid);

	return count;
}
stock lm_reset_have_mines(id)
{
	for(new i = 0; i < ArraySize(gCMinesData); i++)
	{
		// reset deploy count.
		lm_stock_set_user_mine_deployed(id, i, int:0);
		// reset hove mine.
		lm_stock_set_user_have_mine(id, i, int:0);
	}
}
stock lm_remove_all_mines(id)
{
	static result;
	result = false;
	for(new i = 0; i < ArraySize(gCMinesData); i++)
	{
		// Dead Player remove lasermine.
		if (lm_get_mines_data(i, DEATH_REMOVE))
		{
			result |= lm_remove_all_entity_main(id, i);
		}
	}
	return result;
}

stock lm_remove_all_entity_main(id, minesid)
{
	static mines[COMMON_MINES_DATA];
	ArrayGetArray(gCMinesData, minesid, mines, sizeof(mines));
	static result;
	result = false;
	if (lm_stock_get_user_mine_deployed(id, minesid) > int:0)
		result = true;

	lm_remove_all_entity(id, mines[CLASS_NAME]);
	// reset deploy count.
	lm_stock_set_user_mine_deployed(id, minesid, int:0);
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
	gCvar[CVAR_ENABLE]	        = register_cvar(fmt("%s%s", CVAR_TAG, "_enable"),				"1"			);	// 0 = off, 1 = on.
	gCvar[CVAR_ACCESS_LEVEL]   	= register_cvar(fmt("%s%s", CVAR_TAG, "_access"),				"0"			);	// 0 = all, 1 = admin
	gCvar[CVAR_MODE]           	= register_cvar(fmt("%s%s", CVAR_TAG, "_mode"),   				"0"			);	// 0 = lasermine, 1 = tripmine, 2 = claymore wire trap
	gCvar[CVAR_START_DELAY]    	= register_cvar(fmt("%s%s", CVAR_TAG, "_round_delay"),			"5"			);	// Round start delay time.

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

	gCvar[CVAR_LASER_BRIGHT]   	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_brightness"),		"255"		);	// laser line brightness. 0 to 255
	gCvar[CVAR_LASER_WIDTH]   	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_width"),			"2"			);	// laser line width. 0 to 255
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
	gCvar[CVAR_REALISTIC_DETAIL]= register_cvar(fmt("%s%s", CVAR_TAG, "_realistic_detail"), 	"0"			);	// Spark Effect.
	gCvar[CVAR_FRIENDLY_FIRE]  	= get_cvar_pointer("mp_friendlyfire");											// Friendly fire. 0 or 1

	// Register Hamsandwich
	RegisterHam(Ham_Spawn, 			"player", "NewRound", 		1);
	RegisterHam(Ham_Item_PreFrame,	"player", "KeepMaxSpeed", 	1);
	RegisterHam(Ham_Killed, 		"player", "PlayerKilling", 	0);
	RegisterHam(Ham_Think,			ENT_CLASS_BREAKABLE, "LaserThink");
	RegisterHam(Ham_TakeDamage,		ENT_CLASS_BREAKABLE, "MinesTakeDamage");

	// Register Event
	register_event("DeathMsg", "DeathEvent",	"a");
	register_event("TeamInfo", "CheckSpectator","a");

	// Get Message Id
	gMsgBarTime		= get_user_msgid("BarTime");

	// Register Forward.
	register_forward(FM_PlayerPostThink,"PlayerPostThink");
	register_forward(FM_PlayerPreThink, "PlayerPreThink");
	register_forward(FM_TraceLine,		"MinesShowInfo", 1);

	// Multi Language Dictionary.
	register_dictionary("lasermine.txt");

	register_cvar(PLUGIN, VERSION, FCVAR_SERVER|FCVAR_SPONLY);

	gCMinesData = ArrayCreate(COMMON_MINES_DATA);

	return PLUGIN_CONTINUE;
}

public plugin_natives()
{
	register_library("lasermine_natives");


}

//====================================================
//  PLUGIN END
//====================================================
public plugin_end()
{

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
public NewRound(id, minesid)
{
	// Check Plugin Enabled
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	// alive?
	if (lm_is_user_alive(id) && pev(id, pev_flags) & (FL_CLIENT)) 
	{
		// Delay time reset
		lm_stock_set_user_delay_count(id, minesid, int:floatround(get_gametime()));

		// Task Delete.
		delete_task(id);

		// Removing already put lasermine.
		lm_remove_all_entity_main(id, minesid);

		// Round start set ammo.
		set_start_ammo(id, minesid);
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Keep Max Speed.
//====================================================
public KeepMaxSpeed(id)
{
	if (lm_is_user_alive(id))
	{
		new Float:now_speed = lm_get_user_max_speed(id);
		if (now_speed > 1.0 && now_speed < 300.0)
			lm_save_user_max_speed(id, lm_get_user_max_speed(id));
	}

	return PLUGIN_CONTINUE;
}

//====================================================
// Round Start Set Ammo.
// Native:_native_set_start_ammo(iPlugin, iParam);
//====================================================
set_start_ammo(id, minesid)
{
	// Get CVAR setting.
	new int:stammo = int:lm_get_mines_data(minesid, AMMO_HAVE_START);

	// Zero check.
	if(stammo <= int:0) 
		return;

	// Getting have ammo.
	new int:haveammo = int:lm_stock_get_user_have_mine(id, minesid);

	// Set largest.
	lm_stock_set_user_have_mine(id, minesid, (haveammo <= stammo ? stammo : haveammo));

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

	lm_remove_all_mines(vID);

	return PLUGIN_CONTINUE;
}

//====================================================
// Put LaserMine Start Progress A
//====================================================
public lm_progress_deploy_main(id, minesid)
{
	// Deploying Check.
	new iReturn;
	ExecuteForward(gForwarder[FWD_CHECK_DEPLOY]);

	if (!iReturn)
		return PLUGIN_HANDLED;

	new Float:wait = Float:lm_get_mines_data(minesid, ACTIVATE_TIME);
	if (wait > 0)
	{
		lm_show_progress(id, int:floatround(wait), gMsgBarTime);
	}

	// Set Flag. start progress.
	lm_set_user_deploy_state(id, int:STATE_DEPLOYING);

	new sMineId[4];
	num_to_str(minesid, sMineId, charsmax(sMineId));
	// Start Task. Put Lasermine.
	set_task(wait, "SpawnMine", (TASK_PLANT + id), sMineId, charsmax(sMineId));

	return PLUGIN_HANDLED;
}

//====================================================
// Put LaserMine Start Progress B
//====================================================
public lm_progress_deploy(id, minesid)
{
	// Mode check. Bind Key Command.
	if(lm_get_mines_data(minesid, BIND_MODE) != 0)
		lm_progress_deploy_main(id, minesid);

	return PLUGIN_HANDLED;
}

//====================================================
// Removing target put lasermine.
//====================================================
public lm_progress_remove(id, minesid)
{
	// Removing Check.
	new iReturn;
	ExecuteForward(gForwarder[FWD_CHECK_REMOVE]);

	if (!iReturn)
		return PLUGIN_HANDLED;

	new Float:wait = Float:lm_get_mines_data(minesid, ACTIVATE_TIME);
	if (wait > 0)
		lm_show_progress(id, int:floatround(wait), gMsgBarTime);

	// Set Flag. start progress.
	lm_set_user_deploy_state(id, int:STATE_DEPLOYING);

	new sMineId[4];
	num_to_str(minesid, sMineId, charsmax(sMineId));
	// Start Task. Remove Lasermine.
	set_task(wait, "RemoveMine", (TASK_RELEASE + id), sMineId, charsmax(sMineId));

	return PLUGIN_HANDLED;
}

//====================================================
// Stopping Progress.
//====================================================
public lm_progress_stop(id)
{
	lm_hide_progress(id, gMsgBarTime);
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
	// is Valid?
	if(!iEnt)
	{
		cp_debug(uID);
		return PLUGIN_HANDLED_MAIN;
	}

	new iReturn;
	ExecuteForward(gForwarder[FWD_SET_ENTITY_SPAWN], iReturn, iEnt, uID);

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
	entityName = lm_get_entity_class_name(target);
	new iClassName[MAX_NAME_LENGTH];
	iClassName[0] = lm_get_mines_data(str_to_num(params), CLASS_NAME);
	// Check. is Target Entity Lasermine?
	if(!equali(entityName, iClassName))
		return 1;

	new ownerID = pev(target, LASERMINE_OWNER);

	new PICKUP_MODE:pickup 	= PICKUP_MODE:lm_get_mines_data(str_to_num(params), PICKUP_MODE);
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
			if(CsTeams:pev(target, LASERMINE_TEAM) != cs_get_user_team(uID))
				return 1;
		}		
	}
	new minesid = str_to_num(params);
	ExecuteForward(gForwarder[FWD_REMOVE_MINE], uID, target);

	// Remove!
	lm_remove_entity(target);

	// Collect for this removed lasermine.
	lm_stock_set_user_have_mine(uID, minesid, lm_stock_get_user_have_mine(uID, minesid) + int:1);

	if (pev_valid(ownerID))
	{
		// Return to before deploy count.
		lm_stock_set_user_mine_deployed(ownerID, minesid, lm_stock_get_user_mine_deployed(ownerID, minesid) - int:1);
	}

	// Play sound.
	emit_sound(uID, CHAN_ITEM, ENT_SOUND4, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	// Set Flag. end progress.
	lm_set_user_deploy_state(uID, int:STATE_DEPLOYED);

	return 1;
}

//====================================================
// Blocken Mines.
//====================================================
public MinesTakeDamage(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	new entityName[MAX_NAME_LENGTH];
	entityName = lm_get_entity_class_name(victim);
	static b;
	b = false;
	new iClassName[MAX_NAME_LENGTH];
	for (new i = 0; i < ArraySize(gCMinesData); i++)
	{
		iClassName[0] = lm_get_mines_data(i, CLASS_NAME);
		// is this lasermine? no.
		if (equali(entityName, iClassName))
			b = true;
	}
	if (!b) return HAM_IGNORED;

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
			if(CsTeams:pev(victim, LASERMINE_TEAM) != cs_get_user_team(attacker))
				return HAM_SUPERCEDE;
		}
		default:
			return HAM_IGNORED;
	}
	return HAM_IGNORED;
}


//====================================================
// Player killing (Set Money, Score)
//====================================================
public PlayerKilling(iVictim, iAttacker)
{
	static entityName[MAX_NAME_LENGTH];
	entityName = lm_get_entity_class_name(iAttacker);

	static b;
	b = false;
	new iClassName[MAX_NAME_LENGTH];
	for (new i = 0; i < ArraySize(gCMinesData); i++)
	{
		iClassName[0] = lm_get_mines_data(i, CLASS_NAME);
		// is this lasermine? no.
		if (equali(entityName, iClassName))
			b = true;
	}
	if (!b) return HAM_IGNORED;


	//
	// Refresh Score info.
	//
	{
		// Get Target Team.
		new CsTeams:aTeam = cs_get_user_team(iAttacker);
		new CsTeams:vTeam = cs_get_user_team(iVictim);

		new score  = (vTeam != aTeam) ? 1 : -1;
		new money  = (vTeam != aTeam) ? get_pcvar_num(gCvar[CVAR_FRAG_MONEY]) : (get_pcvar_num(gCvar[CVAR_FRAG_MONEY]) * -1);

		// Attacker Frag.
		// Add Attacker Frag (Friendly fire is minus).
		new aFrag	= lm_get_user_frags(iAttacker) + score;
		new aDeath	= cs_get_user_deaths(iAttacker);

		lm_set_user_deaths(iAttacker, aDeath);
		ExecuteHamB(Ham_AddPoints, iAttacker, aFrag - lm_get_user_frags(iAttacker), true);

		new tDeath = lm_get_user_deaths(iVictim);

		lm_set_user_deaths(iVictim, tDeath);
		ExecuteHamB(Ham_AddPoints, iVictim, 0, true);

		// Get Money attacker.
		cs_set_user_money(iAttacker, cs_get_user_money(iAttacker) + money);
		return HAM_HANDLED;
	}
}

//====================================================
// Buy Lasermine.
//====================================================
public lm_buy_mine(id, minesid)
{	
	new iReturn;
	ExecuteForward(gForwarder[FWD_CHECK_FOR_BUY], iReturn, id);

	if(!iReturn)
		return PLUGIN_CONTINUE;

	new cost = lm_get_mines_data(minesid, BUY_PRICE);
	cs_set_user_money(id, cs_get_user_money(id) - cost);

	lm_stock_set_user_have_mine(id, minesid, lm_stock_get_user_have_mine(id, minesid) + int:1);

	cp_bought(id);

	emit_sound(id, CHAN_ITEM, ENT_SOUND4, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

//====================================================
// Chat command.
//====================================================
public lm_say_lasermine(id)
{
	if(!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	new said[32];
	read_argv(1, said, charsmax(said));
	
	if (equali(said, "mines") || equali(said, "/mines"))
	{
		const SIZE = 1024;
		new msg[SIZE + 1], len = 0;
		len += formatex(msg[len], SIZE - len, "<html><head><style>body{background-color:gray;color:white;} table{border-color:black;}</style></head><body>");
		len += formatex(msg[len], SIZE - len, "<p><b>Laser/TripMine Entity v%s</b></p>", VERSION);
		len += formatex(msg[len], SIZE - len, "<p>You can be setting the mine on the wall.</p>");
		len += formatex(msg[len], SIZE - len, "<p>That laser will give what touched it damage.</p>");
		len += formatex(msg[len], SIZE - len, "<p><b>Commands</b></p>");
		len += formatex(msg[len], SIZE - len, "<table border='1' cellspacing='0' cellpadding='10'>");
		len += formatex(msg[len], SIZE - len, "<tr><td>say</td><td><b>/buy lasermine</b> or <b>/lm</td><td rowspan='2'>buying lasermine</td></tr>");
		len += formatex(msg[len], SIZE - len, "<tr><td>console</td><td><b>buy_lasermine</b></td></tr>");
		len += formatex(msg[len], SIZE - len, "<tr><tr><td rowspan='2'>bind</td><td><b>+setlaser</b></td><td>bind j +setlaser :using j set lasermine on wall.</td></tr>");
		len += formatex(msg[len], SIZE - len, "<tr><td><b>+dellaser</b></td><td>bind k +dellaser :using k remove lasermine.</td></tr>");
		len += formatex(msg[len], SIZE - len, "</table>");
		len += formatex(msg[len], SIZE - len, "</body></html>");
		show_motd(id, msg, "Lasermine Entity help");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Player post think event.
// Stop movement for mine deploying.
//====================================================
public PlayerPostThink(id) 
{
	if ((pev(id, pev_weapons) & (1 << CSW_C4)) && (pev(id, pev_oldbuttons) & IN_ATTACK))
		return FMRES_IGNORED;

	switch (lm_get_user_deploy_state(id))
	{
		case STATE_IDLE:
		{
			new bool:now_speed = (lm_get_user_max_speed(id) <= 1.0)
			if (now_speed)
				ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
		}
		case STATE_DEPLOYING:
		{
			lm_set_user_max_speed(id, 1.0);
		}
		case STATE_DEPLOYED:
		{
			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
			lm_set_user_deploy_state(id, STATE_IDLE);
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

	lm_reset_have_mines(id);

	new iReturn;
	ExecuteForward(gForwarder[FWD_PUTIN_SERVER], iReturn, id);
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
	lm_remove_all_mines(id);
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

	lm_set_user_deploy_state(id, STATE_IDLE);
	return;
}

//====================================================
// Check: common.
//====================================================
stock ERROR:check_for_common(id, minesid)
{
	new cvar_enable = get_pcvar_num(gCvar[CVAR_ENABLE]);
	new cvar_access = get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]);
	new user_flags	= get_user_flags(id) & ADMIN_ACCESSLEVEL;
	new is_alive	= lm_is_user_alive(id);
	//new cvar_mode	= get_pcvar_num(gCvar[CVAR_MODE]);

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
	//if (cvar_mode == MODE_BF4_CLAYMORE)
	// 	return ERROR:NOT_IMPLEMENT;

	// Can set Delay time?
	return ERROR:check_for_time(id, minesid);
}

//====================================================
// Mine Glowing
//====================================================
stock mine_glowing(iEnt)
{
	new Float:tcolor[3];
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
			tcolor[n++] = float(str_to_num(sColor));
		}
		lm_set_glow_rendering(iEnt, kRenderFxGlowShell, tcolor, kRenderNormal, 5);
	}
}

public CheckSpectator() 
{
	new id, szTeam[2];
	id = read_data(1);
	read_data(2, szTeam, charsmax(szTeam));

	if (szTeam[0] == 'U' || szTeam[0] == 'S')
	{
		delete_task(id);
		if (lm_remove_all_mines(id))
		{
			new namep[MAX_NAME_LENGTH];
			get_user_name(id, namep, charsmax(namep));
			cp_remove_spec(0, namep);
		}
     } 
}