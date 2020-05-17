// #pragma semicolon 1
//=============================================
//	Plugin Writed by Visual Studio Code.
//=============================================
// Supported BIOHAZARD.
// #define BIOHAZARD_SUPPORT
// #define ZP_SUPPORT

//=====================================
//  INCLUDE AREA
//=====================================
#include <amxmodx>
#include <amxmisc>
#include <amxconst>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <mines_natives>
#if defined ZP_SUPPORT
	#include <zp50_colorchat>
	#include <zp50_ammopacks>
#endif

//=====================================
//  Resource Setting AREA
//=====================================
#define ENT_MODELS					"models/mines/lasermine.mdl"
#define ENT_SOUND1					"mines/laser_deploy.wav"
#define ENT_SOUND2					"mines/laser_charge.wav"
#define ENT_SOUND3					"mines/laser_activate.wav"
#define ENT_SOUND4					"debris/beamstart9.wav"
#define ENT_SOUND5					"weapons/ric_metal-1.wav"
#define ENT_SOUND6					"weapons/ric_metal-2.wav"
#define ENT_SPRITE1 				"sprites/mines/laser.spr"

//=====================================
//  MACRO AREA
//=====================================
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define PLUGIN 						"[M.P] Lasermine"
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"4.01"

#define CVAR_TAG					"mines_lm"

#define LANG_KEY_PLANT_WALL   		"LM_PLANT_WALL"
#define LANG_KEY_LONGNAME			"LM_LONG_NAME"

// ADMIN LEVEL
#define ENT_CLASS_LASER				"lasermine"

#define LASERMINE_HITING			pev_iuser4
#define LASERMINE_COUNT				pev_fuser1
#define LASERMINE_POWERUP			pev_fuser2
#define LASERMINE_BEAMTHINK			pev_fuser3
#define LASERMINE_BEAMENDPOINT1		pev_vuser1
#define LASERMINE_BEAMENDPOINT2		pev_vuser2
#define LASERMINE_BEAMENDPOINT3		pev_vuser3

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
	CVAR_MAX_HAVE			,    	// Max having ammo.
	CVAR_START_HAVE			,    	// Start having ammo.
	CVAR_FRAG_MONEY         ,    	// Get money per kill.
	CVAR_COST               ,    	// Buy cost.
	CVAR_BUY_ZONE           ,    	// Stay in buy zone can buy.
	CVAR_LASER_DMG          ,    	// Laser hit Damage.
	CVAR_MAX_DEPLOY			,		// user max deploy.
	CVAR_TEAM_MAX           ,    	// Max deployed in team.
	CVAR_EXPLODE_RADIUS     ,   	// Explosion Radius.
	CVAR_EXPLODE_DMG        ,   	// Explosion Damage.
	CVAR_FRIENDLY_FIRE      ,   	// Friendly Fire.
	CVAR_CBT                ,   	// Can buy team. TR/CT/ALL
	CVAR_BUY_MODE           ,   	// Buy mode. 0 = off, 1 = on.
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
	CVAR_DIFENCE_SHIELD		,		// Shield hit.
	CVAR_REALISTIC_DETAIL	,		// Spark Effect.
};

enum CVAR_VALUE
{
	VL_MAX_HAVE				,    	// Max having ammo.
	VL_START_HAVE			,    	// Start having ammo.
	VL_FRAG_MONEY       	,    	// Get money per kill.
	VL_COST             	,    	// Buy cost.
	VL_BUY_ZONE         	,    	// Stay in buy zone can buy.
	VL_MAX_DEPLOY			,		// user max deploy.
	VL_TEAM_MAX           	,    	// Max deployed in team.
	VL_FRIENDLY_FIRE      	,   	// Friendly Fire.
	VL_BUY_MODE           	,   	// Buy mode. 0 = off, 1 = on.
	VL_LASER_VISIBLE      	,   	// Laser line Visiblity. 0 = off, 1 = on.
	VL_LASER_BRIGHT       	,   	// Laser line brightness.
	VL_LASER_WIDTH			,		// Laser line width.
	VL_LASER_COLOR       	,   	// Laser line color. 0 = team color, 1 = green
	VL_LASER_DMG_MODE     	,   	// Laser line damage mode. 0 = frame rate dmg, 1 = once dmg, 2 = 1second dmg.
	VL_MINE_GLOW          	,   	// Glowing tripmine.
	VL_MINE_GLOW_MODE     	,   	// Glowing color mode.
	VL_MINE_BROKEN			,		// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
	VL_DEATH_REMOVE			,		// Dead Player Remove Lasermine.
	VL_ALLOW_PICKUP			,		// allow pickup.
	VL_DIFENCE_SHIELD		,		// Shield hit.
	VL_REALISTIC_DETAIL		,		// Spark Effect.
	Float:VL_LASER_DMG     	,    	// Laser hit Damage.
	Float:VL_LASER_DMG_DPS  ,   	// Laser line damage mode 2 only, damage/seconds. default 1 (sec)
	Float:VL_LASER_ACTIVATE	,		// Waiting for put lasermine. (0 = no progress bar.)
	Float:VL_LASER_RANGE	,		// Laserbeam range.
	Float:VL_MINE_HEALTH    ,   	// Lasermine health. (Can break.)
	Float:VL_EXPLODE_RADIUS ,   	// Explosion Radius.
	Float:VL_EXPLODE_DMG    ,   	// Explosion Damage.
	VL_CBT              [4] ,   	// Can buy team. TR/CT/ALL
	VL_LASER_COLOR_TR   [13],   	// Laser line color. 0 = team color, 1 = green
	VL_LASER_COLOR_CT   [13],   	// Laser line color. 0 = team color, 1 = green
	VL_MINE_GLOW_CT     [13],   	// Glowing color for CT.
	VL_MINE_GLOW_TR    	[13],   	// Glowing color for T.
};

enum _:RESEORUCES
{
	MODELS	[32],
	SOUND1	[32],
	SOUND2	[32],
	SOUND3	[32],
	SOUND4	[32],
	SOUND5	[32],
	SOUND6	[32],
	SPRITE1	[32],
}
//====================================================
//  GLOBAL VARIABLES
//====================================================
new gCvar		[CVAR_SETTING];
new gCvarValue	[CVAR_VALUE];

new gBeam;
new gMinesId;

new Stack:gRecycleMine	[MAX_PLAYERS];
new gMinesData[COMMON_MINES_DATA];


new gResources[RESEORUCES];

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	// CVar settings.
	// Ammo.
	gCvar[CVAR_START_HAVE]	    = create_cvar(fmt("%s%s", CVAR_TAG, "_amount"),					"1"			);	// Round start have ammo count.
	gCvar[CVAR_MAX_HAVE]       	= create_cvar(fmt("%s%s", CVAR_TAG, "_max_amount"),   			"2"			);	// Max having ammo.
	gCvar[CVAR_TEAM_MAX]		= create_cvar(fmt("%s%s", CVAR_TAG, "_team_max"),				"10"		);	// Max deployed in team.
	gCvar[CVAR_MAX_DEPLOY]		= create_cvar(fmt("%s%s", CVAR_TAG, "_max_deploy"),				"10"		);	// Max deployed in user.

	// Buy system.
	gCvar[CVAR_BUY_MODE]	    = create_cvar(fmt("%s%s", CVAR_TAG, "_buy_mode"),				"1"			);	// 0 = off, 1 = on.
	gCvar[CVAR_CBT]    			= create_cvar(fmt("%s%s", CVAR_TAG, "_buy_team"),				"ALL"		);	// Can buy team. TR / CT / ALL. (BIOHAZARD: Z = Zombie)
	gCvar[CVAR_COST]           	= create_cvar(fmt("%s%s", CVAR_TAG, "_buy_price"),				"2500"		);	// Buy cost.
	gCvar[CVAR_BUY_ZONE]        = create_cvar(fmt("%s%s", CVAR_TAG, "_buy_zone"),				"1"			);	// Stay in buy zone can buy.
	gCvar[CVAR_FRAG_MONEY]     	= create_cvar(fmt("%s%s", CVAR_TAG, "_frag_money"),   			"300"		);	// Get money.

	// Laser design.
	gCvar[CVAR_LASER_VISIBLE]	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_visible"),			"1"			);	// Laser line visibility.
	gCvar[CVAR_LASER_COLOR]    	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_mode"),		"0"			);	// laser line color 0 = team color, 1 = green.
	// Leser beam color for team color mode.
	gCvar[CVAR_LASER_COLOR_TR] 	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_t"),			"255,0,0"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_LASER_COLOR_CT] 	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_ct"),			"0,0,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)

	gCvar[CVAR_LASER_BRIGHT]   	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_brightness"),		"255"		);	// laser line brightness. 0 to 255
	gCvar[CVAR_LASER_WIDTH]   	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_width"),			"2"			);	// laser line width. 0 to 255
	gCvar[CVAR_LASER_DMG]      	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_damage"),			"60.0"		);	// laser hit dmg. Float Value!
	gCvar[CVAR_LASER_DMG_MODE]	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_damage_mode"),		"0"			);	// Laser line damage mode. 0 = frame dmg, 1 = once dmg, 2 = 1 second dmg.
	gCvar[CVAR_LASER_DMG_DPS]  	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_dps"),				"1"			);	// laser line damage mode 2 only, damage/seconds. default 1 (sec)
	gCvar[CVAR_LASER_RANGE]		= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_range"),			"8192.0"	);	// Laser beam lange (float range.)

	// Mine design.
	gCvar[CVAR_MINE_HEALTH]    	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_health"),			"500"		);	// Tripmine Health. (Can break.)
	gCvar[CVAR_MINE_GLOW]      	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow"),				"0"			);	// Tripmine glowing. 0 = off, 1 = on.
	gCvar[CVAR_MINE_GLOW_MODE]  = create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_mode"),	"0"			);	// Mine glow coloer 0 = team color, 1 = green.
	gCvar[CVAR_MINE_GLOW_TR]  	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_t"),		"255,0,0"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_MINE_GLOW_CT]  	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_ct"),		"0,0,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)
	gCvar[CVAR_MINE_BROKEN]		= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_broken"),			"0"			);	// Can broken Mines.(0 = mines, 1 = Team, 2 = Enemy)
	gCvar[CVAR_EXPLODE_RADIUS] 	= create_cvar(fmt("%s%s", CVAR_TAG, "_explode_radius"),			"320.0"		);	// Explosion radius.
	gCvar[CVAR_EXPLODE_DMG]		= create_cvar(fmt("%s%s", CVAR_TAG, "_explode_damage"),			"100"		);	// Explosion radius damage.

	// Misc Settings.
	gCvar[CVAR_DEATH_REMOVE]	= create_cvar(fmt("%s%s", CVAR_TAG, "_death_remove"),			"0"			);	// Dead Player remove lasermine. 0 = off, 1 = on.
	gCvar[CVAR_LASER_ACTIVATE]	= create_cvar(fmt("%s%s", CVAR_TAG, "_activate_time"),			"1.0"		);	// Waiting for put lasermine. (int:seconds. 0 = no progress bar.)
	gCvar[CVAR_ALLOW_PICKUP]	= create_cvar(fmt("%s%s", CVAR_TAG, "_allow_pickup"),			"1"			);	// allow pickup mine. (0 = disable, 1 = it's mine, 2 = allow friendly mine, 3 = allow enemy mine!)
	gCvar[CVAR_DIFENCE_SHIELD]	= create_cvar(fmt("%s%s", CVAR_TAG, "_shield_difence"),			"1"			);	// allow shiled difence.
	gCvar[CVAR_REALISTIC_DETAIL]= create_cvar(fmt("%s%s", CVAR_TAG, "_realistic_detail"), 		"0"			);	// Spark Effect.

	for(new i = 0; i < MAX_PLAYERS; i++)
		gRecycleMine[i] = CreateStack(1);

	bind_cvars();

	create_cvar("mines_lasermine", VERSION, FCVAR_SERVER|FCVAR_SPONLY);

	// Multi Language Dictionary.
	mines_register_dictionary("mines/mines_lm.txt");
	AutoExecConfig(true, "mines_cvars_lm", "mines");

	return PLUGIN_CONTINUE;
}

bind_cvars()
{
	bind_pcvar_num		(gCvar[CVAR_START_HAVE], 		gCvarValue[VL_START_HAVE]);
	bind_pcvar_num		(gCvar[CVAR_MAX_HAVE], 			gCvarValue[VL_MAX_HAVE]);
#if defined BIOHAZARD_SUPPORT
	bind_pcvar_num		(gCvar[CVAR_NOROUND], 			gCvarValue[VL_NOROUND]);
#endif
	bind_pcvar_num		(gCvar[CVAR_MAX_DEPLOY],		gCvarValue[VL_MAX_DEPLOY]);
	bind_pcvar_num		(gCvar[CVAR_TEAM_MAX],			gCvarValue[VL_TEAM_MAX]);
	bind_pcvar_num		(gCvar[CVAR_BUY_MODE],			gCvarValue[VL_BUY_MODE]);
	bind_pcvar_num		(gCvar[CVAR_BUY_ZONE],			gCvarValue[VL_BUY_ZONE]);
	bind_pcvar_num		(gCvar[CVAR_COST],				gCvarValue[VL_COST]);
	bind_pcvar_num		(gCvar[CVAR_FRAG_MONEY],		gCvarValue[VL_FRAG_MONEY]);
	bind_pcvar_num		(gCvar[CVAR_MINE_BROKEN],		gCvarValue[VL_MINE_BROKEN]);
	bind_pcvar_num		(gCvar[CVAR_ALLOW_PICKUP],		gCvarValue[VL_ALLOW_PICKUP]);
	bind_pcvar_num		(gCvar[CVAR_DEATH_REMOVE],		gCvarValue[VL_DEATH_REMOVE]);
	bind_pcvar_num		(gCvar[CVAR_MINE_GLOW],			gCvarValue[VL_MINE_GLOW]);
	bind_pcvar_num		(gCvar[CVAR_MINE_GLOW_MODE], 	gCvarValue[VL_MINE_GLOW_MODE]);
	bind_pcvar_float	(gCvar[CVAR_MINE_HEALTH], 		gCvarValue[VL_MINE_HEALTH]);
	bind_pcvar_float	(gCvar[CVAR_LASER_ACTIVATE],	gCvarValue[VL_LASER_ACTIVATE]);
	bind_pcvar_float	(gCvar[CVAR_EXPLODE_RADIUS],	gCvarValue[VL_EXPLODE_RADIUS]);
	bind_pcvar_float	(gCvar[CVAR_EXPLODE_DMG],		gCvarValue[VL_EXPLODE_DMG]);
	bind_pcvar_string	(gCvar[CVAR_CBT], 				gCvarValue[VL_CBT], 			charsmax(gCvarValue[VL_CBT]));
	bind_pcvar_string	(gCvar[CVAR_MINE_GLOW_TR],		gCvarValue[VL_MINE_GLOW_TR], 	charsmax(gCvarValue[VL_MINE_GLOW_TR]) - 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_MINE_GLOW_CT],		gCvarValue[VL_MINE_GLOW_CT], 	charsmax(gCvarValue[VL_MINE_GLOW_CT]) - 1);// last comma - 1

	bind_pcvar_num		(gCvar[CVAR_LASER_VISIBLE],	 	gCvarValue[VL_LASER_VISIBLE]);   	// Laser line Visiblity. 0 = off, 1 = on.
	bind_pcvar_num		(gCvar[CVAR_LASER_BRIGHT], 		gCvarValue[VL_LASER_BRIGHT]);   	// Laser line brightness.
	bind_pcvar_num		(gCvar[CVAR_LASER_WIDTH], 		gCvarValue[VL_LASER_WIDTH]);		// Laser line width.
	bind_pcvar_num		(gCvar[CVAR_LASER_COLOR], 		gCvarValue[VL_LASER_COLOR]);   		// Laser line color. 0 = team color, 1 = green
	bind_pcvar_num		(gCvar[CVAR_LASER_DMG_MODE], 	gCvarValue[VL_LASER_DMG_MODE]);   	// Laser line damage mode. 0 = frame rate dmg, 1 = once dmg, 2 = 1second dmg.
	bind_pcvar_num		(gCvar[CVAR_DIFENCE_SHIELD], 	gCvarValue[VL_DIFENCE_SHIELD]);		// Shield hit.
	bind_pcvar_num		(gCvar[CVAR_REALISTIC_DETAIL], 	gCvarValue[VL_REALISTIC_DETAIL]);	// Spark Effect.
	bind_pcvar_float	(gCvar[CVAR_LASER_DMG], 		gCvarValue[VL_LASER_DMG]);    		// Laser hit Damage.
	bind_pcvar_float	(gCvar[CVAR_LASER_DMG_DPS], 	gCvarValue[VL_LASER_DMG_DPS]);   	// Laser line damage mode 2 only, damage/seconds. default 1 (sec)
	bind_pcvar_float	(gCvar[CVAR_LASER_RANGE], 		gCvarValue[VL_LASER_RANGE]);		// Laserbeam range.
	bind_pcvar_string	(gCvar[CVAR_LASER_COLOR_TR], 	gCvarValue[VL_LASER_COLOR_TR],	charsmax(gCvarValue[VL_LASER_COLOR_TR]));  	// Laser line color. 0 = team color, 1 = green
	bind_pcvar_string	(gCvar[CVAR_LASER_COLOR_CT], 	gCvarValue[VL_LASER_COLOR_CT],	charsmax(gCvarValue[VL_LASER_COLOR_CT]));  	// Laser line color. 0 = team color, 1 = green

	gMinesData[BUY_TEAM]			=	get_team_code(gCvarValue[VL_CBT]);
	gMinesData[GLOW_COLOR_TR]		=	get_cvar_to_color(gCvarValue[VL_MINE_GLOW_TR]);
	gMinesData[GLOW_COLOR_CT]		=	get_cvar_to_color(gCvarValue[VL_MINE_GLOW_CT]);

	gMinesData[AMMO_HAVE_START]		=	gCvarValue[VL_START_HAVE];
	gMinesData[AMMO_HAVE_MAX]		=	gCvarValue[VL_MAX_HAVE];
#if defined BIOHAZARD_SUPPORT
	gMinesData[NO_ROUND]			=	gCvarValue[VL_NOROUND];
#endif
	gMinesData[DEPLOY_MAX]			=	gCvarValue[VL_MAX_DEPLOY];
	gMinesData[DEPLOY_TEAM_MAX]		=	gCvarValue[VL_TEAM_MAX];
	gMinesData[BUY_MODE]			=	gCvarValue[VL_BUY_MODE];
	gMinesData[BUY_ZONE]			=	gCvarValue[VL_BUY_ZONE];
	gMinesData[BUY_PRICE]			=	gCvarValue[VL_COST];
	gMinesData[FRAG_MONEY]			=	gCvarValue[VL_FRAG_MONEY];
	gMinesData[MINES_BROKEN]		=	gCvarValue[VL_MINE_BROKEN];
	gMinesData[ALLOW_PICKUP]		=	gCvarValue[VL_ALLOW_PICKUP];
	gMinesData[DEATH_REMOVE]		=	gCvarValue[VL_DEATH_REMOVE];
	gMinesData[GLOW_ENABLE]			=	gCvarValue[VL_MINE_GLOW];
	gMinesData[GLOW_MODE]			=	gCvarValue[VL_MINE_GLOW_MODE];
	gMinesData[MINE_HEALTH]			=	gCvarValue[VL_MINE_HEALTH];
	gMinesData[ACTIVATE_TIME]		=	gCvarValue[VL_LASER_ACTIVATE];
	gMinesData[EXPLODE_RADIUS]		=	gCvarValue[VL_EXPLODE_RADIUS];
	gMinesData[EXPLODE_DAMAGE]		=	gCvarValue[VL_EXPLODE_DMG];

	// commons data update.
	// parameter: this mines id, common mines data, model path.
	register_mines_data(gMinesId, gMinesData, gResources[MODELS]);
}

//====================================================
//  PLUGIN END
//====================================================
public mines_plugin_end()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
		DestroyStack(gRecycleMine[i]);
}

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	gMinesId = 	register_mines(ENT_CLASS_LASER, LANG_KEY_LONGNAME);

	mines_resources(gMinesId, "ENT_SOUND1",  gResources[SOUND1],  charsmax(gResources[SOUND1]),  ENT_SOUND1);
	mines_resources(gMinesId, "ENT_SOUND2",  gResources[SOUND2],  charsmax(gResources[SOUND2]),  ENT_SOUND2);
	mines_resources(gMinesId, "ENT_SOUND3",  gResources[SOUND3],  charsmax(gResources[SOUND3]),  ENT_SOUND3);
	mines_resources(gMinesId, "ENT_SOUND4",  gResources[SOUND4],  charsmax(gResources[SOUND4]),  ENT_SOUND4);
	mines_resources(gMinesId, "ENT_SOUND5",  gResources[SOUND5],  charsmax(gResources[SOUND5]),  ENT_SOUND5);
	mines_resources(gMinesId, "ENT_SOUND6",  gResources[SOUND6],  charsmax(gResources[SOUND6]),  ENT_SOUND6);
	mines_resources(gMinesId, "ENT_MODELS",  gResources[MODELS],  charsmax(gResources[MODELS]),  ENT_MODELS);
	mines_resources(gMinesId, "ENT_SPRITE1", gResources[SPRITE1], charsmax(gResources[SPRITE1]), ENT_SPRITE1);

	precache_sound(gResources[SOUND1]);
	precache_sound(gResources[SOUND2]);
	precache_sound(gResources[SOUND3]);
	precache_sound(gResources[SOUND4]);
	precache_sound(gResources[SOUND5]);
	precache_sound(gResources[SOUND6]);
	precache_model(gResources[MODELS]);
	gBeam = precache_model(gResources[SPRITE1]);

	return PLUGIN_CONTINUE;
}

//====================================================
// Lasermine Settings.
//====================================================
public mines_entity_spawn_settings(iEnt, uID, iMinesId)
{
	if (iMinesId != gMinesId) return;
	// Entity Setting.
	// set class name.
	set_pev(iEnt, pev_classname, ENT_CLASS_LASER);
	// set models.
	engfunc(EngFunc_SetModel, iEnt, gResources[MODELS]);
	// set solid.
	set_pev(iEnt, pev_solid, SOLID_NOT);
	// set movetype.
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY);

	// set model animation.
	set_pev(iEnt, pev_frame,		0);
	set_pev(iEnt, pev_framerate,	0.0);
	set_pev(iEnt, pev_body, 		3);
	set_pev(iEnt, pev_sequence, 	TRIPMINE_WORLD);
	set_pev(iEnt, pev_rendermode,	kRenderNormal);
	set_pev(iEnt, pev_renderfx,	 	kRenderFxNone);

	// set take damage.
	set_pev(iEnt, pev_takedamage, DAMAGE_YES);
	set_pev(iEnt, pev_dmg, 100.0);

	// set entity health.
	// if recycle health.
	new Float:health;
	if (!IsStackEmpty(gRecycleMine[uID]))
		PopStackCell(gRecycleMine[uID], health);
	else
		health = gCvarValue[VL_MINE_HEALTH];

	set_pev(iEnt, pev_health, health);

	// set mine position
	set_mine_position(uID, iEnt);

	// Save results to be used later.
	set_pev(iEnt, MINES_OWNER, uID );
	set_pev(iEnt, MINES_TEAM, int:cs_get_user_team(uID));

	// Reset powoer on delay time.
	new Float:fCurrTime = get_gametime();
	set_pev(iEnt, LASERMINE_POWERUP, 	fCurrTime + 2.5 );   
	set_pev(iEnt, MINES_STEP, 			POWERUP_THINK);
	set_pev(iEnt, LASERMINE_COUNT, 		fCurrTime);
	set_pev(iEnt, LASERMINE_BEAMTHINK, 	fCurrTime);

	// think rate. hmmm....
	set_pev(iEnt, pev_nextthink, 		fCurrTime + 0.2 );

	// Power up sound.
	lm_play_sound(iEnt, SOUND_POWERUP);
}

//====================================================
// Set Lasermine Position.
//====================================================
set_mine_position(uID, iEnt)
{
	// Vector settings.
	new Float:vOrigin	[3],Float:vViewOfs	[3];
	new	Float:vNewOrigin[3],Float:vNormal	[3],
		Float:vTraceEnd	[3],Float:vEntAngles[3];
	// get user position.
	pev(uID, pev_origin, 	vOrigin);
	pev(uID, pev_view_ofs, 	vViewOfs);
	xs_vec_add(vOrigin, vViewOfs, vOrigin);  	
	velocity_by_aim(uID, 128, vTraceEnd);
	xs_vec_add(vTraceEnd, vOrigin, vTraceEnd);

    // create the trace handle.
	new trace = create_tr2();

	// get wall position to vNewOrigin.
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, IGNORE_MONSTERS, uID, trace);
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

		xs_vec_mul_scalar(vNormal, 8.0, vNormal);
		xs_vec_add(vTraceEnd, vNormal, vNewOrigin);
		// // set entity position.
		engfunc(EngFunc_SetOrigin, iEnt, vNewOrigin );
		// set size.
		engfunc(EngFunc_SetSize, iEnt, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );
		// Rotate tripmine.
		vector_to_angle(vNormal, vEntAngles);
		// set angle.
		set_pev(iEnt, pev_angles, vEntAngles);
		// set laserbeam end point position.
		set_laserend_postiion(iEnt, vNormal, vNewOrigin);

	}

    // free the trace handle.
	free_tr2(trace);

}

//====================================================
// Set Laserbeam End Position.
//====================================================
set_laserend_postiion(iEnt, Float:vNormal[3], Float:vNewOrigin[3])
{
	// Calculate laser end origin.
	new Float:vBeamEnd[3];
	new Float:vTracedBeamEnd[3];
	new Float:vTemp[3];
	new Float:fFraction = 0.0;
	new iIgnore;
	new className[MAX_NAME_LENGTH];
	new trace;
	xs_vec_mul_scalar(vNormal, gCvarValue[VL_LASER_RANGE], vNormal);
	xs_vec_add( vNewOrigin, vNormal, vBeamEnd );

    // create the trace handle.
	vTracedBeamEnd	= vBeamEnd;
	vTemp 			= vNewOrigin;
	iIgnore 		= -1;
	// Trace line

	while(fFraction < 1.0)
	{
 		trace = create_tr2();
 		engfunc(EngFunc_TraceLine, vTemp, vBeamEnd, (IGNORE_MONSTERS | IGNORE_GLASS), iIgnore, trace);
		{
			get_tr2(trace, TR_flFraction, fFraction);
			get_tr2(trace, TR_vecEndPos, vTemp);
			iIgnore = get_tr2(trace, TR_pHit);

			// is valid hit entity?
			if (pev_valid(iIgnore))
			{
				pev(iIgnore, pev_classname, className, charsmax(className));
				if (!equali(className, ENT_CLASS_BREAKABLE))
				{
					break;
				}
			} else {
				break;
			}
		}
		free_tr2(trace);
	}
	vTracedBeamEnd = vTemp;

    // free the trace handle.
	free_tr2(trace);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT1, vTracedBeamEnd);
}

//====================================================
// Task: Remove Lasermine.
//====================================================
public MinesPickup(id, target)
{
	// Recycle Health.
	new Float:health;
	pev(target, pev_health, health);
	PushStackCell(gRecycleMine[id], health);
}

//====================================================
// Lasermine Think Event.
//====================================================
public MinesThink(iEnt, iMinesId)
{
	if (!pev_valid(iEnt))
		return;

	// is this lasermine? no.
	if (iMinesId != gMinesId)
		return;

	static Float:fCurrTime;
	static Float:vEnd[3];
	static step;

	fCurrTime = get_gametime();
	step = pev(iEnt, MINES_STEP);
	// Get Laser line end potision.
	pev(iEnt, LASERMINE_BEAMENDPOINT1, vEnd);

	// lasermine state.
	// Power up.
	switch(step)
	{
		case POWERUP_THINK:
		{
			mines_step_powerup(iEnt, fCurrTime);
		}
		case BEAMUP_THINK:
		{
			mines_step_beamup(iEnt, vEnd, fCurrTime);
		}
		// Laser line activated.
		case BEAMBREAK_THINK:
		{
			mines_step_beambreak(iEnt, vEnd, fCurrTime);
		}
		// EXPLODE
		case EXPLOSE_THINK:
		{
			// Stopping sound.
			lm_play_sound(iEnt, SOUND_STOP);

			// effect explosion.
			mines_explosion(pev(iEnt, MINES_OWNER), iMinesId, iEnt);
		}
	}

	return;
}

mines_step_powerup(iEnt, Float:fCurrTime)
{
	static Float:fPowerupTime;
	pev(iEnt, LASERMINE_POWERUP, fPowerupTime);
	// over power up time.
		
	if (fCurrTime > fPowerupTime)
	{
		// next state.
		set_pev(iEnt, MINES_STEP, BEAMUP_THINK);
		// activate sound.
		lm_play_sound(iEnt, SOUND_ACTIVATE);

	}
	mines_glow(iEnt, gMinesData);
	// Think time.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
}

mines_step_beamup(iEnt, Float:vEnd[3], Float:fCurrTime)
{
	// solid complete.
	set_pev(iEnt, pev_solid, SOLID_BBOX);
	// drawing laser line.
	if (gCvarValue[VL_LASER_VISIBLE])
	{
		draw_laserline(iEnt, vEnd);
		if(gCvarValue[VL_REALISTIC_DETAIL])
			mines_spark_wall(vEnd);
	}

	// next state.
	set_pev(iEnt, MINES_STEP, BEAMBREAK_THINK);
	// Think time.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
}

mines_step_beambreak(iEnt, Float:vEnd[3], Float:fCurrTime)
{
	static Array:aTarget;
	static className[32];
	static hPlayer[HIT_PLAYER];
	static iOwner;
	static iTarget;
	static hitGroup;
	static trace;
	static Float:fFraction;
	static Float:vOrigin	[3];
	static Float:vHitPoint	[3];
	static Float:nextTime = 0.0;
	static Float:beamTime = 0.0;

	// Get this mine position.
	pev(iEnt, pev_origin, 			vOrigin);
	pev(iEnt, LASERMINE_COUNT, 		nextTime);
	pev(iEnt, LASERMINE_BEAMTHINK, 	beamTime);
	iOwner = pev(iEnt, MINES_OWNER);

	if (fCurrTime > beamTime)
	{
		if (gCvarValue[VL_LASER_VISIBLE])
			draw_laserline(iEnt, vEnd);

		set_pev(iEnt, LASERMINE_BEAMTHINK, fCurrTime + random_float(0.1, 0.2));
	}

	if (gCvarValue[VL_LASER_DMG_MODE])
	{
		if (fCurrTime < nextTime)
		{
			// Think time.
			set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
			return false;
		}
	}

	aTarget = ArrayCreate(sizeof(hPlayer));

	// create the trace handle.
	trace = create_tr2();

	fFraction	= 0.0;
	iTarget	= iEnt;
	ArrayClear(aTarget);
	vHitPoint = vOrigin;
	set_pev(iEnt, LASERMINE_COUNT, get_gametime());

	// Trace line
	while(fFraction < 1.0)
	{
		// Trace line
		engfunc(EngFunc_TraceLine, vHitPoint, vEnd, DONT_IGNORE_MONSTERS, iTarget, trace);
		{
			get_tr2(trace, TR_flFraction, fFraction);
			iTarget		= get_tr2(trace, TR_pHit);
			hitGroup	= get_tr2(trace, TR_iHitgroup);
			get_tr2(trace, TR_vecEndPos, vHitPoint);				
		}

		// Something has passed the laser.
		if (fFraction < 1.0)
		{
			// is valid hit entity?
			if (pev_valid(iTarget))
			{
				pev(iTarget, pev_classname, className, charsmax(className));
				if (equali(className, ENT_CLASS_BREAKABLE))
				{
					hPlayer[I_TARGET] 	= iTarget;
					hPlayer[V_POSITION]	= vHitPoint;
					hPlayer[I_HIT_GROUP]= hitGroup;
					ArrayPushArray(aTarget, hPlayer);
					continue;
				}

				// is user?
				if (!(pev(iTarget, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
					continue;

				// is dead?
				if (!is_user_alive(iTarget))
					continue;

				// Hit friend and No FF.
				if (!mines_valid_takedamage(iOwner, iTarget))
					continue;
				
				// is godmode?
				if (get_user_godmode(iTarget))
					continue;

				hPlayer[I_TARGET] 	= iTarget;
				hPlayer[V_POSITION]	= vHitPoint;
				hPlayer[I_HIT_GROUP]= hitGroup;
				ArrayPushArray(aTarget, hPlayer);

				if (hitGroup == HIT_SHIELD && gCvarValue[VL_DIFENCE_SHIELD])
					break;

				// keep target id.
				set_pev(iEnt, pev_enemy, iTarget);
			}
			else
			{
				continue;
			}
		}
	}

	for (new n = 0; n < ArraySize(aTarget); n++)
	{
		ArrayGetArray(aTarget, n, hPlayer);

		if(gCvarValue[VL_REALISTIC_DETAIL]) 
			mines_spark_wall(hPlayer[V_POSITION]);

		// Laser line damage mode. Once or Second.
		create_laser_damage(iEnt, hPlayer[I_TARGET], hPlayer[I_HIT_GROUP], hPlayer[V_POSITION]);
	}					

	// Laser line damage mode. Once or Second.
	if (gCvarValue[VL_LASER_DMG_MODE] != 0)
	{
		if (ArraySize(aTarget) > 0)
			set_pev(iEnt, LASERMINE_COUNT, (nextTime + gCvarValue[VL_LASER_DMG_DPS]));

			// if change target. keep target id.
		if (pev(iEnt, LASERMINE_HITING) != iTarget)
			set_pev(iEnt, LASERMINE_HITING, iTarget);
	}

	// free the trace handle.
	free_tr2(trace);
	ArrayDestroy(aTarget);

	// Get mine health.
	static Float:iHealth;
	mines_get_health(iEnt, iHealth);

	// break?
	if (iHealth <= 0 || (pev(iEnt, pev_flags) & FL_KILLME))
	{
		// next step explosion.
		set_pev(iEnt, MINES_STEP, EXPLOSE_THINK);
		set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
	}
				
	// Think time. random_float = laser line blinking.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);

	return true;
}

//====================================================
// Drawing Laser line.
//====================================================
draw_laserline(iEnt, const Float:vEndOrigin[3])
{
	new tcolor	[3];
	new CsTeams:teamid = CsTeams:pev(iEnt, MINES_TEAM);

	// Color mode. 0 = team color.
	if(gCvarValue[VL_LASER_COLOR] == 0)
	{
		switch(teamid)
		{
			case CS_TEAM_T:
				for(new i = 0; i < 3; i++) tcolor[i] = get_color(get_cvar_to_color(gCvarValue[VL_LASER_COLOR_TR]), i);
			case CS_TEAM_CT:
				for(new i = 0; i < 3; i++) tcolor[i] = get_color(get_cvar_to_color(gCvarValue[VL_LASER_COLOR_CT]), i);
			default:
#if !defined BIOHAZARD_SUPPORT
				for(new i = 0; i < 3; i++) tcolor[i] = get_color(get_cvar_to_color("0,255,0"), i);
#else
				for(new i = 0; i < 3; i++) tcolor[i] = get_color(get_cvar_to_color("255,0,0"), i);
#endif
		}

	}else
	{
		// Green.
		for(new i = 0; i < 3; i++) tcolor[i] = get_color(get_cvar_to_color("0,255,0"), i);
	}
	/*
	stock lm_draw_laser(
		const iEnt,
		const Float:vEndOrigin[3], 
		const beam, 
		const framestart	= 0, 
		const framerate		= 0, 
		const life			= 1, 
		const width			= 1, 
		const wave			= 0, 
		const tcolor		[3],
		const bright		= 255,
		const speed			= 255
	)
	*/
	draw_laser(iEnt, vEndOrigin, gBeam, 0, 0, 2, gCvarValue[VL_LASER_WIDTH], 0, tcolor, gCvarValue[VL_LASER_BRIGHT], 255);
}

//====================================================
// Laser damage
//====================================================
create_laser_damage(iEnt, iTarget, hitGroup, Float:hitPoint[3])
{
	new iAttacker = pev(iEnt,MINES_OWNER);

	if (gCvarValue[VL_DIFENCE_SHIELD] && hitGroup == HIT_SHIELD)
	{
		lm_play_sound(iTarget, SOUND_HIT_SHIELD);

		mines_spark(hitPoint);
		lm_hit_shield(iTarget, gCvarValue[VL_LASER_DMG]);
	}
	else
	{
		if (IsPlayer(iTarget))
		{
			lm_play_sound(iTarget, SOUND_HIT);
			mines_set_user_lasthit(iTarget, hitGroup);
		}

		// Damage Effect, Damage, Killing Logic.
		ExecuteHamB(Ham_TakeDamage, iTarget, iEnt, iAttacker, gCvarValue[VL_LASER_DMG], DMG_ENERGYBEAM);
	}
	set_pev(iEnt, LASERMINE_HITING, iTarget);		

	return;
}

//====================================================
// Hit Shield Effect 
//====================================================
lm_hit_shield(id, Float:dmg)
{
	static Float:punchangle[3];
	punchangle[0] = (dmg * random_float(-0.15, 0.15));
	punchangle[2] = (dmg * random_float(-0.15, 0.15));
	if (punchangle[0] < 4.0)
		punchangle[0] = -4.0;
	if (punchangle[2] < -5.0)
		punchangle[2] = -5.0;
	else
		if (punchangle[2] > 5.0)
			punchangle[2] = 5.0;

	set_pev(id, pev_punchangle, punchangle);	
}

//====================================================
// Player connected.
//====================================================
public mines_client_putinserver(id)
{
	// Init Recycle Health.
	ClearStack(gRecycleMine[id]);
}

//====================================================
// Player Disconnect.
//====================================================
public mines_client_disconnected(id)
{
	// Init Recycle Health.
	ClearStack(gRecycleMine[id]);
}

//====================================================
// Check: On the wall.
//====================================================
public CheckForDeploy(id, iMinesId)
{
	if(iMinesId != gMinesId) return false;

	new Float:vTraceEnd	[3];
	new Float:vOrigin	[3],Float:vViewOfs[3];

	// Get potision.
	pev(id, pev_origin, 	vOrigin);
	pev(id, pev_view_ofs, 	vViewOfs);
	xs_vec_add(vOrigin, vViewOfs, vOrigin);  	

	// Get wall position.
	velocity_by_aim(id, 128, vTraceEnd);
	xs_vec_add(vTraceEnd, vOrigin, vTraceEnd);

    // create the trace handle.
	new trace = create_tr2();
	new Float:fFraction = 0.0;
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, IGNORE_MONSTERS, id, trace);
	{
    	get_tr2( trace, TR_flFraction, fFraction );
    }
    // free the trace handle.
	free_tr2(trace);

	// We hit something!
	if ( fFraction < 1.0 )
		return true;

	new sLongName[MAX_NAME_LENGTH];
	formatex(sLongName, charsmax(sLongName), "%L", id, LANG_KEY_LONGNAME);
	client_print_color(id, id, "%L", id, LANG_KEY_PLANT_WALL, CHAT_TAG, sLongName);

	return false;
}

public MinesBreaked(iMinesId, iEnt, iAttacker)
{
	if (iMinesId != gMinesId) 
		return HAM_IGNORED;
#if defined ZP_SUPPORT
	zp_ammopacks_set(iAttacker, zp_ammopacks_get(iAttacker) + gCvarValue[VL_FRAG_MONEY]);
	zp_colored_print(0, "^4%n ^1earned^4 %i points ^1for destorying a lasermine !", iAttacker, gCvarValue[VL_FRAG_MONEY]);
#endif
    return HAM_IGNORED;
}

//====================================================
// Play sound.
//====================================================
lm_play_sound(iEnt, iSoundType)
{
	switch (iSoundType)
	{
		case SOUND_POWERUP:
		{
			emit_sound(iEnt, CHAN_VOICE, gResources[SOUND1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			emit_sound(iEnt, CHAN_BODY , gResources[SOUND2], 0.2, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_ACTIVATE:
		{
			emit_sound(iEnt, CHAN_VOICE, gResources[SOUND3], 0.5, ATTN_NORM, 1, 75);
		}
		case SOUND_STOP:
		{
			emit_sound(iEnt, CHAN_BODY , gResources[SOUND2], 0.2, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(iEnt, CHAN_VOICE, gResources[SOUND3], 0.5, ATTN_NORM, SND_STOP, 75);
		}
		case SOUND_HIT:
		{
			emit_sound(iEnt, CHAN_WEAPON, gResources[SOUND4], 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_HIT_SHIELD:
		{
			if (random_num(0, 1))
				emit_sound(iEnt, CHAN_VOICE, gResources[SOUND5], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			else
				emit_sound(iEnt, CHAN_VOICE, gResources[SOUND6], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
	}
}

ClearStack(Stack:handle)
{
	new Float:health;
	while (!IsStackEmpty(handle))
	{
		PopStackCell(handle, health);
	}
}

//====================================================
// Draw Laserline
//====================================================
stock draw_laser(
	const iEnt,
	/* const Float:vOrigin[3],*/ 
	const Float:vEndOrigin[3], 
	const beam, 
	const framestart	= 0, 
	const framerate		= 0, 
	const life			= 1, 
	const width			= 1, 
	const wave			= 0, 
	const tcolor		[3],
	const bright		= 255,
	const speed			= 255
)
{
	// Draw Laser line message.
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(TE_BEAMENTPOINT);
	write_short(iEnt | 0x1000);
	// engfunc(EngFunc_WriteCoord, vOrigin[0]);
	// engfunc(EngFunc_WriteCoord, vOrigin[1]);
	// engfunc(EngFunc_WriteCoord, vOrigin[2]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]); //Random
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]); //Random
	engfunc(EngFunc_WriteCoord, vEndOrigin[2]); //Random
	write_short(beam);
	write_byte(framestart);						// framestart
	write_byte(framerate);						// framerate
	write_byte(life);							// Life
	write_byte(width);							// Width
	write_byte(wave);							// wave/noise
	write_byte(tcolor[0]);						// r
	write_byte(tcolor[1]);						// g
	write_byte(tcolor[2]);						// b
	write_byte(bright);							// Brightness.
	write_byte(speed);							// speed
	message_end();
}

public mines_deploy_hologram(id, iEnt, iMinesId)
{
	if (iMinesId != gMinesId)
		return 0;

	// Vector settings.
	static	Float:vOrigin	[3],Float:vViewOfs	[3];
	static	Float:vNewOrigin[3],Float:vNormal	[3];
	static	Float:vTraceEnd	[3],Float:vEntAngles[3];

	// Get wall position.
	velocity_by_aim(id, 128, vTraceEnd);
	// get user position.
	pev(id, pev_origin, vOrigin);
	pev(id, pev_view_ofs, vViewOfs);
	xs_vec_add(vOrigin, vViewOfs, vOrigin);  	
	xs_vec_add(vTraceEnd, vOrigin, vTraceEnd);

	// create the trace handle.
	static trace;
	static result;
	result = 0;
	trace = create_tr2();
	// get wall position to vNewOrigin.
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, IGNORE_MONSTERS, id, trace);
	{
		// -- We hit something!
		// -- Save results to be used later.
		get_tr2(trace, TR_vecEndPos, vTraceEnd);
		get_tr2(trace, TR_vecPlaneNormal, vNormal);

		if (xs_vec_distance(vOrigin, vTraceEnd) < 128.0)
		{
			xs_vec_mul_scalar(vNormal, 8.0, vNormal);
			xs_vec_add(vTraceEnd, vNormal, vNewOrigin);
			// set entity position.
			engfunc(EngFunc_SetOrigin, iEnt, vNewOrigin);
			// Rotate tripmine.
			vector_to_angle(vNormal, vEntAngles);
			// set angle.
			set_pev(iEnt, pev_angles, vEntAngles);
			result = 1;
		}
		else
		{
			result = 0;
		}
	}
	// free the trace handle.
	free_tr2(trace);

	return result;
}