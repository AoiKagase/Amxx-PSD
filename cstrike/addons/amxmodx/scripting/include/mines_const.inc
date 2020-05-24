// =====================================
//	Laser/Tripmine Entity Const
//
// 	by Aoi.Kagase
//
// =====================================

#if defined _mines_const_included
	#endinput
#endif
#define _mines_const_included
//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 182
	#assert "AMX Mod X v1.8.2 or greater library required!"
#endif

#if AMXX_VERSION_NUM < 190
#include <mines_182>
#endif

#define CHAT_TAG 					"[M.P]"
#define ENT_CLASS_BREAKABLE			"func_breakable"

#define OFFSET_TEAM 				114
#define OFFSET_MONEY				115
#if cellbits == 32
	#define OFFSET_MAPZONE  		235
#else
	#define OFFSET_MAPZONE  		268
#endif
#define OFFSET_GET_DEATH			444
#define OFFSET_SET_DEATH			711
#define OFFSET_LAST_HIT_GROUP		75
#define EXTRAOFFSET_PL_LINUX		5

#define PLAYER_IN_BUYZONE			(1<<0)
// CS Status Data.
#define mines_get_user_team(%1)			CsTeams:get_offset_value(%1, OFFSET_TEAM)
#define mines_set_user_team(%1,%2)		set_offset_value(%1, OFFSET_TEAM, %2)
#define mines_get_user_deaths(%1)		get_offset_value(%1, OFFSET_GET_DEATH)
#define mines_set_user_deaths(%1,%2)	set_offset_value(%1, OFFSET_SET_DEATH, %2)
#define mines_get_user_money(%1)		get_offset_value(%1, OFFSET_MONEY)
#define mines_set_user_money(%1,%2)		set_offset_value(%1, OFFSET_MONEY, %2)
#define mines_set_user_lasthit(%1,%2)	set_pdata_int(%1, OFFSET_LAST_HIT_GROUP, %2, EXTRAOFFSET_PL_LINUX)
#define mines_get_health(%1,%2)			pev(%1, pev_health, %2)
#define mines_get_user_max_speed(%1,%2)	pev(%1,pev_maxspeed,%2)
#define mines_get_user_frags(%1)		pev(%1,pev_frags)
#define mines_get_user_buyzone(%1)		(get_pdata_int(%1,OFFSET_MAPZONE) & PLAYER_IN_BUYZONE)
#define mines_set_user_frags(%1,%2)		set_pev(%1,pev_frags,%2)
#define mines_set_user_max_speed(%1,%2)	engfunc(EngFunc_SetClientMaxspeed,%1,%2);set_pev(%1, pev_maxspeed,%2)
#define mines_set_user_health(%1,%2)	((health > 0) ? set_pev(id, pev_health, health) : user_kill(id, 1))
#define IsPlayer(%1) ( 1 <= %1 <= 32 ) 

// Lasermine Data Save Area.
#define MINES_TEAM					pev_iuser1
#define MINES_OWNER					pev_iuser2
#define MINES_OWNER_ID				pev_message
#define MINES_STEP					pev_iuser3
#define MAX_CLASS_LENGTH			16
#define MAX_MODEL_LENGTH			32
//====================================================
// ENUM AREA
//====================================================
//
// Tripmine Action Control
//
enum _:TRIPMINE_STATE
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

enum _:TRIPMINE_THINK
{
	POWERUP_THINK			= 0,
	BEAMUP_THINK			,
	BEAMBREAK_THINK			,
	EXPLOSE_THINK			,
};

enum _:TRIPMINE_SOUND
{
	SOUND_POWERUP			= 0,
	SOUND_ACTIVATE			,
	SOUND_STOP				,
	SOUND_PICKUP			,
	SOUND_HIT				,
	SOUND_HIT_SHIELD		,
};

enum _:TRIPMINE_DMGMODE
{
	DMGMODE_ALWAYS			= 0,
	DMGMODE_ONCE			,
	DMGMODE_SECONDS			,
};
//
// CHECK ERROR CODE
//
enum _:ERROR
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

enum _:COMMON_MINES_DATA
{
	AMMO_HAVE_START		,
	AMMO_HAVE_MAX		,
	NO_ROUND			,
	DEPLOY_MAX			,
	DEPLOY_TEAM_MAX		,
	BUY_MODE			,
	BUY_PRICE			,
	BUY_ZONE			,
	CsTeams:BUY_TEAM	,
	FRAG_MONEY			,
	MINES_BROKEN		,
	ALLOW_PICKUP		,
	DEATH_REMOVE		,
	GLOW_ENABLE			,
	GLOW_MODE			,
	GLOW_COLOR_TR		,
	GLOW_COLOR_CT		,
	Float:ACTIVATE_TIME	,
	Float:MINE_HEALTH	,
	Float:EXPLODE_RADIUS,
	Float:EXPLODE_DAMAGE,
	EXPLODE_SPRITE		,
#if defined ZP_SUPPORT
	ZP_WEAPON_ID		,
#endif
}

//
// PLAYER DATA AREA
//
enum _:PLAYER_DATA
{
	int:PL_COUNT_DELAY		= 0,
	int:PL_COUNT_HAVE_MINE	,
	int:PL_COUNT_DEPLOYED	,
}

enum _:COMMON_PLAYER_DATA
{
	int:PL_STATE_DEPLOY		,
	Float:PL_MAX_SPEED		,
	Float:PL_DEPLOY_POS[3]	,
}

enum int:PLAYER_DEPLOY_STATE
{
	STATE_IDLE				= 0,
	STATE_DEPLOYING			,
	STATE_PICKING			,
	STATE_DEPLOYED			,
}

enum _:PICKUP_MODE
{
	DISALLOW_PICKUP			= 0,
	ONLY_ME					,
	ALLOW_FRIENDLY			,
	ALLOW_ENEMY				,
}
