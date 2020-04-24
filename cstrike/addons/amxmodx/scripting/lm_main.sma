
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

#define PLUGIN 					"Laser/Tripmine Entity"

#define CHAT_TAG 				"[Lasermine]"
#define CVAR_TAG				"amx_ltm"
#define LANG_KEY_NOT_BUY_TEAM 	"NOT_BUY_TEAM"

//=====================================
//  Resource Setting AREA
//=====================================
// #define ENT_MODELS					"models/v_tripmine.mdl"
// #define ENT_SOUND1					"weapons/mine_deploy.wav"
// #define ENT_SOUND2					"weapons/mine_charge.wav"
// #define ENT_SOUND3					"weapons/mine_activate.wav"
#define ENT_SOUND4					"items/gunpickup2.wav"
// #define ENT_SOUND5					"debris/beamstart9.wav"
// #define ENT_SOUND6					"weapons/ric_metal-1.wav"
// #define ENT_SOUND7					"weapons/ric_metal-2.wav"
// #define ENT_SOUND8					"debris/bustglass1.wav"
// #define ENT_SOUND9					"debris/bustglass2.wav"
// #define ENT_SPRITE1 				"sprites/laserbeam.spr"
#define ENT_SPRITE2 				"sprites/eexplo.spr"

//=====================================
//  MACRO AREA
//=====================================
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"4.00"

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
	FWD_PICKUP_MINE,
	FWD_CHECK_DEPLOY,
	FWD_CHECK_PICKUP,
	FWD_CHECK_BUY,
	FWD_DISCONNECTED,
	FWD_MINES_THINK,
	FWD_PLUGINS_END,
};
//====================================================
//  GLOBAL VARIABLES
//====================================================
new gCvar[CVAR_SETTING];
new gBoom;
new gMsgBarTime;
new gEntMine;
new gForwarder			[FORWARDER];

new Array:gMinesClass;
new Array:gMinesParameter;
new Array:gPlayerData	[MAX_PLAYERS];
new gCPlayerData		[MAX_PLAYERS][COMMON_PLAYER_DATA];
//====================================================
//  Player Data functions
//====================================================
stock int:mines_get_user_deploy_state			(id) 						{ return int:gCPlayerData[id][PL_STATE_DEPLOY];}
stock Float:mines_load_user_max_speed			(id)						{ return Float:gCPlayerData[id][PL_MAX_SPEED]; }
stock Float:mines_get_user_max_speed			(id)						{ return Float:pev(id, pev_maxspeed); }
stock Float:mines_get_user_health				(id)
{
	new Float:health;
	pev(id, pev_health, health);
	return health;
}

stock mines_get_user_frags						(id)						{ return pev(id, pev_frags);}
stock bool:mines_get_user_buyzone				(id)						{ return bool:(get_pdata_int(id, OFFSET_MAPZONE) & PLAYER_IN_BUYZONE);}

stock mines_set_user_frags						(id, int:frags)				{ set_pev(id, pev_frags, frags); }
stock mines_set_user_deploy_state				(id, int:value)				{ gCPlayerData[id][PL_STATE_DEPLOY]	= int:value; }
stock mines_set_user_health						(id, Float:health)			{ health > 0 ? set_pev(id, pev_health, health) : user_kill(id, 1); }
stock mines_save_user_max_speed					(id, Float:value)			{ gCPlayerData[id][PL_MAX_SPEED]	= Float:value; }
stock mines_set_user_max_speed					(id, Float:value)			{ engfunc(EngFunc_SetClientMaxspeed, id, value);set_pev(id, pev_maxspeed, value); }



//====================================================
// Function: Count to deployed in team.
//====================================================
stock mines_get_mines_id(targetClass[])
{
	static result;
	result = -1;
	static sClassName[MAX_NAME_LENGTH];
	for(new i = 0; i < ArraySize(gMinesClass); i++)
	{
		ArrayGetString(gMinesClass, i, sClassName, charsmax(sClassName));
		if (equali(sClassName, targetClass))
		{
			result = i;
			break;
		}
	}
	return result;
}
stock mines_get_mines_parameter(minesId, field)
{
	static mData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, minesId, mData, sizeof(mData));
	return mData[field];
}
stock mines_set_mines_parameter(minesId, field, value)
{
	static mData[COMMON_MINES_DATA];
	ArrayGetArray(gMinesParameter, minesId, mData, sizeof(mData));
	mData[field] = value;
	ArraySetArray(gMinesParameter, minesId, mData, sizeof(mData));
}
stock mines_get_player_data(id, minesId, field)
{
	static plData[PLAYER_DATA];
	ArrayGetArray(gPlayerData[id], minesId, plData, sizeof(plData));
	return plData[field];
}
stock mines_set_player_data(id, minesId, field, value)
{
	static plData[PLAYER_DATA];
	ArrayGetArray(gPlayerData[id], minesId, plData, sizeof(plData));
	plData[field] = value;
	ArraySetArray(gPlayerData[id], minesId, plData, sizeof(plData));
}
stock mines_stock_set_user_delay_count			(id, minesId, int:value) 	
{
	mines_set_player_data(id, minesId, PL_COUNT_DELAY, value);
}
stock mines_stock_set_user_have_mine			(id, minesId, int:value)
{
	mines_set_player_data(id, minesId, PL_COUNT_HAVE_MINE, value);
}
stock mines_stock_set_user_mine_deployed		(id, minesId, int:value)
{
	mines_set_player_data(id, minesId, PL_COUNT_DEPLOYED, value);
}
stock int:mines_stock_get_user_delay_count		(id, minesId)
{
	return mines_get_player_data(id, minesId, PL_COUNT_DELAY);
}
stock int:mines_stock_get_user_have_mine		(id, minesId)
{
	return int:mines_get_player_data(id, minesId, PL_COUNT_HAVE_MINE);
}
stock int:mines_stock_get_user_mine_deployed	(id, minesId)
{
	return int:mines_get_player_data(id, minesId, PL_COUNT_DEPLOYED);
}
stock mines_get_mines_classname(minesId)
{
	static className[MAX_NAME_LENGTH];
	ArrayGetString(gMinesClass, minesId, className, charsmax(className));
	return className;
}
stock int:mines_get_team_deployed_count		(id, minesId)
{
	static int:i;
	static int:count;
	static int:num;
	static players[MAX_PLAYERS];
	static team[3] = '^0';

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
		count += mines_stock_get_user_mine_deployed(players[i], minesId);

	return count;
}
stock mines_reset_have_mines(id)
{
	for(new i = 0; i < ArraySize(gMinesClass); i++)
	{
		// reset deploy count.
		mines_stock_set_user_mine_deployed(id, i, int:0);
		// reset hove mine.
		mines_stock_set_user_have_mine(id, i, int:0);
	}
}
stock mines_remove_all_mines(id)
{
	static result;
	result = false;
	for(new i = 0; i < ArraySize(gMinesClass); i++)
	{
		// Dead Player remove lasermine.
		if (mines_get_mines_parameter(i, DEATH_REMOVE))
		{
			result |= mines_remove_all_entity_main(id, i);
		}
	}
	return result;
}

stock mines_remove_all_entity_main(id, minesId)
{
	static result;
	result = false;
	if (mines_stock_get_user_mine_deployed(id, minesId) > int:0)
		result = true;

	mines_remove_all_entity(id, mines_get_mines_classname(minesId));
	// reset deploy count.
	mines_stock_set_user_mine_deployed(id, minesId, int:0);
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
	// RegisterHam(Ham_Think,			ENT_CLASS_BREAKABLE, "MinesThink");
	// RegisterHam(Ham_TakeDamage,		ENT_CLASS_BREAKABLE, "MinesTakeDamage");

	// Register Event
	register_event("DeathMsg", "DeathEvent",	"a");
	register_event("TeamInfo", "CheckSpectator","a");

	// Get Message Id
	gMsgBarTime		= get_user_msgid("BarTime");

	// Register Forward.
	register_forward(FM_PlayerPostThink,"PlayerPostThink");
	register_forward(FM_PlayerPreThink, "PlayerPreThink");
	register_forward(FM_TraceLine,		"MinesShowInfo", 1);

	gForwarder[FWD_SET_ENTITY_SPAWN] = CreateMultiForward("mines_entity_spawn_settings", ET_IGNORE, FP_CELL, FP_CELL);
	gForwarder[FWD_PUTIN_SERVER]	 = CreateMultiForward("mines_client_putinserver"	, ET_IGNORE, FP_CELL);
	gForwarder[FWD_PICKUP_MINE]		 = CreateMultiForward("PickupMines"				, ET_IGNORE, FP_CELL, FP_CELL);
	gForwarder[FWD_CHECK_DEPLOY]	 = CreateMultiForward("CheckForDeploy"			, ET_IGNORE, FP_CELL);
	gForwarder[FWD_CHECK_PICKUP]	 = CreateMultiForward("CheckForPickup"			, ET_IGNORE, FP_CELL);
	gForwarder[FWD_CHECK_BUY]	 	 = CreateMultiForward("CheckForBuy"				, ET_IGNORE, FP_CELL);
	gForwarder[FWD_DISCONNECTED] 	 = CreateMultiForward("mines_client_disconnected"	, ET_IGNORE, FP_CELL);
	gForwarder[FWD_MINES_THINK]		 = CreateMultiForward("MinesThink"				, ET_IGNORE, FP_CELL);
	gForwarder[FWD_PLUGINS_END] 	 = CreateMultiForward("mines_plugin_end"			, ET_IGNORE);
	// Multi Language Dictionary.
	register_dictionary("lasermine.txt");

	register_cvar(PLUGIN, VERSION, FCVAR_SERVER|FCVAR_SPONLY);

	gMinesClass = ArrayCreate(MAX_NAME_LENGTH);
	gMinesParameter = ArrayCreate(COMMON_MINES_DATA);

	return PLUGIN_CONTINUE;
}

public plugin_natives()
{
	register_library("lasermine_natives");
	register_native("register_mines",		"_native_register_mines");
	register_native("mines_progress_deploy",	"_native_deploy_progress");
	register_native("mines_progress_pickup",	"_native_pickup_progress");
	register_native("mines_progress_stop", 	"_native_stop_progress");
	register_native("mines_mines_explosion", 	"_native_mines_explosion");
	
}

//====================================================
//  Native Functions.
//====================================================
//====================================================
//  Native: Register Mines.
//====================================================
public _native_register_mines(iPlugin, iParams)
{
	new className[MAX_NAME_LENGTH];
	new minesParam[COMMON_MINES_DATA];

	get_string(1, className, charsmax(className));
	new minesId = ArrayPushString(gMinesClass, className);
	get_array(2, minesParam, sizeof(minesParam));
	ArraySetArray(gMinesParameter, minesId, minesParam);

	return minesId;
}
// mines_progress_deploy(id, minesId);
public _native_deploy_progress(iPlugin, iParams)
{
	mines_progress_deploy(get_param(1), get_param(2));
}
// mines_progress_pickup(id, minesId);
public _native_pickup_progress(iPlugin, iParams)
{
	mines_progress_pickup(get_param(1), get_param(2));
}
// mines_progress_stop(id);
public _native_stop_progress(iPlugin, iParams)
{
	mines_progress_stop(get_param(1));
}
// mines_mines_explosion(id, minesId, iEnt);
public _native_mines_explosion(iPlugin, iParams)
{
	new id	= get_param(1);
	new mId = get_param(2);
	new iEnt= get_param(3); 

	// Stopping entity to think
	set_pev(iEnt, pev_nextthink, 0.0);

	// Count down. deployed lasermines.
	mines_stock_set_user_mine_deployed(id, mId, mines_stock_get_user_mine_deployed(id, mId) - int:1);

	// effect explosion.
	mines_create_explosion(iEnt, gBoom);
	
	// damage.
	mines_create_explosion_damage(iEnt, id, Float:mines_get_mines_parameter(mId, EXPLODE_DAMAGE), Float:mines_get_mines_parameter(mId, EXPLODE_RADIUS));

	// remove this.
	mines_remove_entity(iEnt);
}

//====================================================
//  PLUGIN END
//====================================================
public plugin_end()
{
	ExecuteForward(gForwarder[FWD_PLUGINS_END]);
}

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	// precache_sound(ENT_SOUND1);
	// precache_sound(ENT_SOUND2);
	// precache_sound(ENT_SOUND3);
	precache_sound(ENT_SOUND4);
	// precache_sound(ENT_SOUND5);
	// precache_sound(ENT_SOUND6);
	// precache_sound(ENT_SOUND7);
	// precache_sound(ENT_SOUND8);
	// precache_sound(ENT_SOUND9);
	// precache_model(ENT_MODELS);
	// gBeam = precache_model(ENT_SPRITE1);
	gBoom = precache_model(ENT_SPRITE2);
	
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
	if (mines_is_user_alive(id) && pev(id, pev_flags) & (FL_CLIENT)) 
	{
		// Task Delete.
		delete_task(id);

		for (new i = 0; i < ArraySize(gMinesClass); i++)
		{
			// Delay time reset
			mines_stock_set_user_delay_count(id, i, int:floatround(get_gametime()));
			// Removing already put lasermine.
			mines_remove_all_entity_main(id, i);
			// Round start set ammo.
			set_start_ammo(id, i);
		}
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Keep Max Speed.
//====================================================
public KeepMaxSpeed(id)
{
	if (mines_is_user_alive(id))
	{
		new Float:now_speed = mines_get_user_max_speed(id);
		if (now_speed > 1.0 && now_speed < 300.0)
			mines_save_user_max_speed(id, mines_get_user_max_speed(id));
	}

	return PLUGIN_CONTINUE;
}

//====================================================
// Round Start Set Ammo.
// Native:_native_set_start_ammo(iPlugin, iParam);
//====================================================
set_start_ammo(id, minesId)
{
	// Get CVAR setting.
	new int:stammo = int:mines_get_mines_parameter(minesId, AMMO_HAVE_START);

	// Zero check.
	if(stammo <= int:0) 
		return;

	// Getting have ammo.
	new int:haveammo = int:mines_stock_get_user_have_mine(id, minesId);

	// Set largest.
	mines_stock_set_user_have_mine(id, minesId, (haveammo <= stammo ? stammo : haveammo));

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
public mines_progress_deploy(id, minesId)
{
	// Deploying Check.
	new iReturn;
	ExecuteForward(gForwarder[FWD_CHECK_DEPLOY], iReturn, id, minesId);

	if (!iReturn)
		return PLUGIN_HANDLED;

	new Float:wait = Float:mines_get_mines_parameter(minesId, ACTIVATE_TIME);
	if (wait > 0)
	{
		mines_show_progress(id, int:floatround(wait), gMsgBarTime);
	}

	// Set Flag. start progress.
	mines_set_user_deploy_state(id, int:STATE_DEPLOYING);

	new sMineId[4];
	num_to_str(minesId, sMineId, charsmax(sMineId));
	// Start Task. Put Lasermine.
	set_task(wait, "SpawnMine", (TASK_PLANT + id), sMineId, charsmax(sMineId));

	return PLUGIN_HANDLED;
}

//====================================================
// Removing target put lasermine.
//====================================================
public mines_progress_pickup(id, minesId)
{
	// Removing Check.
	new iReturn;
	ExecuteForward(gForwarder[FWD_CHECK_PICKUP]);

	if (!iReturn)
		return PLUGIN_HANDLED;

	new Float:wait = Float:mines_get_mines_parameter(minesId, ACTIVATE_TIME);
	if (wait > 0)
		mines_show_progress(id, int:floatround(wait), gMsgBarTime);

	// Set Flag. start progress.
	mines_set_user_deploy_state(id, int:STATE_DEPLOYING);

	new sMineId[4];
	num_to_str(minesId, sMineId, charsmax(sMineId));
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
	// is Valid?
	if(!iEnt)
	{
		cp_debug(uID);
		return PLUGIN_HANDLED_MAIN;
	}

	new iReturn;
	ExecuteForward(gForwarder[FWD_SET_ENTITY_SPAWN], iReturn, iEnt, uID);
	new iMineId = str_to_num(params);

	// Cound up. deployed.
	mines_stock_set_user_mine_deployed(uID, iMineId, mines_stock_get_user_mine_deployed(uID, iMineId) + int:1);
	// Cound down. have ammo.
	mines_stock_set_user_have_mine(uID, iMineId, mines_stock_get_user_have_mine(uID, iMineId) - int:1);

	// Set Flag. end progress.
	mines_set_user_deploy_state(uID, int:STATE_DEPLOYED);

	if (iReturn)
	{
		RegisterHamFromEntity(Ham_Think, 		iEnt, "MinesThink");
		RegisterHamFromEntity(Ham_TakeDamage, 	iEnt, "MinesTakeDamage", 0);
		RegisterHamFromEntity(Ham_TakeDamage, 	iEnt, "MinesBreaked", 	 1);
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
	entityName = mines_get_entity_class_name(target);
	new iClassName[MAX_NAME_LENGTH];
	iClassName = mines_get_mines_classname(str_to_num(params));
	// Check. is Target Entity Lasermine?
	if(!equali(entityName, iClassName))
		return 1;

	new ownerID = pev(target, MINES_OWNER);

	new PICKUP_MODE:pickup 	= PICKUP_MODE:mines_get_mines_parameter(str_to_num(params), PICKUP_MODE);
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
			if(CsTeams:pev(target, MINES_TEAM) != cs_get_user_team(uID))
				return 1;
		}		
	}
	new minesId = str_to_num(params);
	new iReturn;
	ExecuteForward(gForwarder[FWD_PICKUP_MINE], iReturn, uID, target);

	// Remove!
	mines_remove_entity(target);

	// Collect for this removed lasermine.
	mines_stock_set_user_have_mine(uID, minesId, mines_stock_get_user_have_mine(uID, minesId) + int:1);

	if (pev_valid(ownerID))
	{
		// Return to before deploy count.
		mines_stock_set_user_mine_deployed(ownerID, minesId, mines_stock_get_user_mine_deployed(ownerID, minesId) - int:1);
	}

	// Play sound.
	emit_sound(uID, CHAN_ITEM, ENT_SOUND4, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	// Set Flag. end progress.
	mines_set_user_deploy_state(uID, int:STATE_DEPLOYED);

	return 1;
}

//====================================================
// Blocken Mines.
//====================================================
public MinesTakeDamage(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	new entityName[MAX_NAME_LENGTH];
	entityName = mines_get_entity_class_name(victim);
	static b;
	static broken;
	b = false;
	new iClassName[MAX_NAME_LENGTH];
	for (new i = 0; i < ArraySize(gMinesClass); i++)
	{
		iClassName = mines_get_mines_classname(i);
		// is this lasermine? no.
		if (equali(entityName, iClassName))
		{
			broken = mines_get_mines_parameter(i, MINE_BROKEN);
			b = true;
			break;
		}
	}
	if (!b) return HAM_IGNORED;

	// We get the ID of the player who put the mine.
	new iOwner = pev(victim, MINES_OWNER);
	switch(broken)
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
		default:
			return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public MinesThink(iEnt)
{
	// Check plugin enabled.
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return HAM_IGNORED;

	// is valid this entity?
	if (!pev_valid(iEnt))
		return HAM_IGNORED;
	
	static className[MAX_NAME_LENGTH];
	className = mines_get_entity_class_name(iEnt);
	static iReturn;
	ExecuteForward(gForwarder[FWD_MINES_THINK], iReturn, iEnt, mines_get_mines_id(className));
	return HAM_IGNORED;
}

//====================================================
// Player killing (Set Money, Score)
//====================================================
public PlayerKilling(iVictim, iAttacker)
{
	static entityName[MAX_NAME_LENGTH];
	entityName = mines_get_entity_class_name(iAttacker);

	static b;
	b = false;
	new iClassName[MAX_NAME_LENGTH];
	for (new i = 0; i < ArraySize(gMinesClass); i++)
	{
		iClassName = mines_get_mines_classname(i);
		// is this lasermine? no.
		if (equali(entityName, iClassName))
		{
			b = true;
			break;
		}
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
		new aFrag	= mines_get_user_frags(iAttacker) + score;
		new aDeath	= cs_get_user_deaths(iAttacker);

		mines_set_user_deaths(iAttacker, aDeath);
		ExecuteHamB(Ham_AddPoints, iAttacker, aFrag - mines_get_user_frags(iAttacker), true);

		new tDeath = mines_get_user_deaths(iVictim);

		mines_set_user_deaths(iVictim, tDeath);
		ExecuteHamB(Ham_AddPoints, iVictim, 0, true);

		// Get Money attacker.
		cs_set_user_money(iAttacker, cs_get_user_money(iAttacker) + money);
		return HAM_HANDLED;
	}
}

//====================================================
// Buy Lasermine.
//====================================================
stock mines_buy_mine(id, minesId)
{	
	new iReturn;
	ExecuteForward(gForwarder[FWD_CHECK_FOR_BUY], iReturn, id);

	if(!iReturn)
		return PLUGIN_CONTINUE;

	new cost = mines_get_mines_parameter(minesId, BUY_PRICE);
	cs_set_user_money(id, cs_get_user_money(id) - cost);

	mines_stock_set_user_have_mine(id, minesId, mines_stock_get_user_have_mine(id, minesId) + int:1);

	cp_bought(id);

	emit_sound(id, CHAN_ITEM, ENT_SOUND4, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

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
			new bool:now_speed = (mines_get_user_max_speed(id) <= 1.0)
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

	mines_reset_have_mines(id);

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
stock ERROR:check_for_common(id, minesId)
{
	new cvar_enable = get_pcvar_num(gCvar[CVAR_ENABLE]);
	new cvar_access = get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]);
	new user_flags	= get_user_flags(id) & ADMIN_ACCESSLEVEL;
	new is_alive	= mines_is_user_alive(id);
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
	return ERROR:check_for_time(id, minesId);
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
		mines_set_glow_rendering(iEnt, kRenderFxGlowShell, tcolor, kRenderNormal, 5);
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
		if (mines_remove_all_mines(id))
		{
			new namep[MAX_NAME_LENGTH];
			get_user_name(id, namep, charsmax(namep));
			cp_remove_spec(0, namep);
		}
     } 
}