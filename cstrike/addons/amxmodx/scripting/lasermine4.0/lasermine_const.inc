// =====================================
//	Laser/Tripmine Entity Const
//
// 	by Aoi.Kagase
//
// =====================================

#if defined _lasermine_const_included
	#endinput
#endif
#define _lasermine_const_included

#define ENT_CLASS_LASER				"lasermine"
#define ENT_CLASS_BREAKABLE			"func_breakable"
#define MAX_LASER_ENTITY			128

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
#define lm_get_user_team(%1)		CsTeams:get_offset_value(%1, OFFSET_TEAM)
#define lm_set_user_team(%1,%2)		set_offset_value(%1, OFFSET_TEAM, %2)
#define lm_get_user_deaths(%1)		get_offset_value(%1, OFFSET_GET_DEATH)
#define lm_set_user_deaths(%1,%2)	set_offset_value(%1, OFFSET_SET_DEATH, %2)
#define lm_get_user_money(%1)		get_offset_value(%1, OFFSET_MONEY)
#define lm_set_user_money(%1,%2)	set_offset_value(%1, OFFSET_MONEY, %2)
#define lm_set_user_lasthit(%1,%2)	set_pdata_int(%1, OFFSET_LAST_HIT_GROUP, %2, EXTRAOFFSET_PL_LINUX)

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

//====================================================
// ENUM AREA
//====================================================
//
// Tripmine Action Control
//
enum _:TRIPMINE_MODE
{
	MODE_LASERMINE			= 0,
	MODE_TRIPMINE			,
	MODE_BF4_CLAYMORE		,
}
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

//
// PLAYER DATA AREA
//
enum PLAYER_DATA
{
	PL_COUNT_DELAY			= 0,
	PL_COUNT_HAVE_MINE		,
	PL_COUNT_DEPLOYED		,
	PL_STATE_DEPLOY			,
}

enum int:PLAYER_DEPLOY_STATE
{
	STATE_IDLE				= 0,
	STATE_DEPLOYING			,
	STATE_DEPLOYED			,
}

enum _:PICKUP_MODE
{
	DISALLOW_PICKUP			= 0,
	ONLY_ME					,
	ALLOW_FRIENDLY			,
	ALLOW_ENEMY				,
}

enum _:MINES_DATA
{
	MAX_HAVE_AMMO					,	// Max having ammo.
	START_HAVE_AMMO					,	// Start having ammo.
	FRAG_MONEY						,	// Get money per kill.
	BUY_MODE						,	// Buy mode. 0 = off, 1 = on.
	BUY_PRICE						,	// Buy cost.
	BUY_ZONE						,	// Stay in buy zone can buy.
	MAX_TEAM_DEPLOY					,	// Max deployed in team.
	CAN_BUY_TEAM					,	// Can buy team. TR/CT/ALL
	ROUND_START_DELAY				,   // Round start delay time.
	MINE_HEALTH						,	// Mine health. (Can break.)
	MINE_BROKEN						,	// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
	DEATH_REMOVE					,	// Dead Player Remove Mine.
	ACTIVATE_TIME					,	// Waiting for put Mine. (0 = no progress bar.)
	CLASS_NAME	[MAX_NAME_LENGTH]	,
	LONG_NAME	[MAX_NAME_LENGTH]	,
}
