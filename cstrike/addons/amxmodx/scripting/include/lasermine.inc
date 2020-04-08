/* Laser/Tripmine Entity functions
*
*  by Aoi.Kagase
*/

#if defined _lasermine_included
	#endinput
#endif
#define _lasermine_included

// Supported BIOHAZARD.
// #define BIOHAZARD_SUPPORT

// Supported More money than 16000.
// #define UL_MONEY_SUPPORT

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
#define OFFSET_GET_DEATH			444
#define OFFSET_SET_DEATH			711
#define PLAYER_IN_BUYZONE			(1<<0)
#if defined BIOHAZARD_SUPPORT
	#define CS_TEAM_ZOMBIE			4
#endif

// CS Status Data.
#define cs_get_user_team(%1)		get_offset_value(%1, OFFSET_TEAM)
#define cs_set_user_team(%1,%2)		set_offset_value(%1, OFFSET_TEAM, %2)
#define cs_get_user_deaths(%1)		get_offset_value(%1, OFFSET_GET_DEATH)
#define cs_set_user_deaths(%1,%2)	set_offset_value(%1, OFFSET_SET_DEATH, %2)
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
// Gets offset data
//====================================================
stock get_offset_value(id, type)
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
stock set_offset_value(id, type, value)
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