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
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <mines_natives>
#include <beams>
#if defined ZP_SUPPORT
	#include <zp50_colorchat>
	#include <zp50_ammopacks>
#endif
//=====================================
//  Resource Setting AREA
//=====================================
#define ENT_MODELS					"models/mines/claymore.mdl"
#define ENT_SOUND1					"mines/claymore_deploy.wav"
#define ENT_SOUND2					"mines/claymore_wallhit.wav"
#define ENT_SPRITE1 				"sprites/mines/claymore_wire.spr"

//=====================================
//  MACRO AREA
//=====================================
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define PLUGIN 						"[M.P] Claymore"
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"0.02"

#define CVAR_TAG					"mines_cm"

#define LANG_KEY_PLANT_GROUND 		"CM_PLANT_GROUND"
#define LANG_KEY_LONGNAME			"CM_LONG_NAME"
// ADMIN LEVEL
#define ADMIN_ACCESSLEVEL			ADMIN_LEVEL_H

#define MAX_CLAYMORE				40
#define ENT_CLASS_CLAYMORE			"claymore"
#define CLAYMORE_WIRE_STARTPOINT	pev_vuser4

#define CLAYMORE_POWERUP			pev_fuser2
#define CLAYMORE_WIREENDPOINT1		pev_vuser1
#define CLAYMORE_WIREENDPOINT2		pev_vuser2
#define CLAYMORE_WIREENDPOINT3		pev_vuser3
//
// CVAR SETTINGS
//
enum _:CVAR_SETTING
{
	CVAR_MAX_HAVE			,    	// Max having ammo.
	CVAR_START_HAVE			,    	// Start having ammo.
	CVAR_FRAG_MONEY         ,    	// Get money per kill.
	CVAR_COST               ,    	// Buy cost.
	CVAR_BUY_ZONE           ,    	// Stay in buy zone can buy.
	CVAR_MAX_DEPLOY			,		// user max deploy.
	CVAR_TEAM_MAX           ,    	// Max deployed in team.
	CVAR_EXPLODE_RADIUS     ,   	// Explosion Radius.
	CVAR_EXPLODE_DMG        ,   	// Explosion Damage.
	CVAR_FRIENDLY_FIRE      ,   	// Friendly Fire.
	CVAR_CBT                ,   	// Can buy team. TR/CT/ALL
	CVAR_BUY_MODE           ,   	// Buy mode. 0 = off, 1 = on.
	// Laser design.
	CVAR_MINE_HEALTH        ,   	// Claymore health. (Can break.)
	CVAR_MINE_GLOW          ,   	// Glowing tripmine.
	CVAR_MINE_GLOW_MODE     ,   	// Glowing color mode.
	CVAR_MINE_GLOW_CT     	,   	// Glowing color for CT.
	CVAR_MINE_GLOW_TR    	,   	// Glowing color for T.
	CVAR_MINE_BROKEN		,		// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
	CVAR_DEATH_REMOVE		,		// Dead Player Remove Claymore.
	CVAR_CM_ACTIVATE		,		// Waiting for put claymore. (0 = no progress bar.)
	CVAR_ALLOW_PICKUP		,		// allow pickup.
	CVAR_CM_WIRE_RANGE		,		// Claymore Wire Range.
	CVAR_CM_WIRE_WIDTH		,		// Claymore Wire Width.
	CVAR_CM_CENTER_PITCH	,		// Claymore Wire Area Center Pitch.
	CVAR_CM_CENTER_YAW		,		// Claymore Wire Area Center Yaw.
	CVAR_CM_LEFT_PITCH		,		// Claymore Wire Area Left Pitch.
	CVAR_CM_LEFT_YAW		,		// Claymore Wire Area Left Yaw.
	CVAR_CM_RIGHT_PITCH		,		// Claymore Wire Area Right Pitch.
	CVAR_CM_RIGHT_YAW		,		// Claymore Wire Area Right Yaw.
	CVAR_CM_TRIAL_FREQ		,		// Claymore Wire trial frequency.
	CVAR_CM_WIRE_VISIBLE    ,   	// Wire Visiblity. 0 = off, 1 = on.
	CVAR_CM_WIRE_BRIGHT     ,   	// Wire brightness.
	CVAR_CM_WIRE_COLOR		,
	CVAR_CM_WIRE_COLOR_T	,
	CVAR_CM_WIRE_COLOR_CT	,
};

enum _:CVAR_VALUE
{
	VALUE_MAX_HAVE				,    	// Max having ammo.
	VALUE_START_HAVE			,    	// Start having ammo.
	VALUE_FRAG_MONEY         	,    	// Get money per kill.
	VALUE_COST               	,    	// Buy cost.
	VALUE_BUY_ZONE           	,    	// Stay in buy zone can buy.
	VALUE_MAX_DEPLOY			,		// user max deploy.
	VALUE_TEAM_MAX           	,    	// Max deployed in team.
	VALUE_BUY_MODE           	,   	// Buy mode. 0 = off, 1 = on.
	// Laser design.
	VALUE_MINE_GLOW         	,   	// Glowing tripmine.
	VALUE_MINE_GLOW_MODE    	,   	// Glowing color mode.
	VALUE_MINE_BROKEN			,		// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
	VALUE_DEATH_REMOVE			,		// Dead Player Remove Claymore.
	VALUE_ALLOW_PICKUP			,		// allow pickup.
	VALUE_CM_TRIAL_FREQ			,		// Claymore Wire trial frequency.
	VALUE_CM_WIRE_VISIBLE	    ,   	// Wire Visiblity. 0 = off, 1 = on.
	VALUE_CM_WIRE_COLOR			,
	Float:VALUE_EXPLODE_RADIUS  ,   	// Explosion Radius.
	Float:VALUE_EXPLODE_DMG     ,   	// Explosion Damage.
	Float:VALUE_MINE_HEALTH    	,   	// Claymore health. (Can break.)
	Float:VALUE_CM_ACTIVATE		,		// Waiting for put claymore. (0 = no progress bar.)
	Float:VALUE_CM_WIRE_RANGE	,		// Claymore Wire Range.
	Float:VALUE_CM_WIRE_BRIGHT	,   	// Wire brightness.
	Float:VALUE_CM_WIRE_WIDTH	,		// Claymore Wire Width.
	VALUE_CBT               [4]	,   	// Can buy team. TR/CT/ALL
	VALUE_MINE_GLOW_CT     	[13],   	// Glowing color for CT.
	VALUE_MINE_GLOW_TR    	[13],   	// Glowing color for T.
	VALUE_CM_CENTER_PITCH	[20],		// Claymore Wire Area Center Pitch.
	VALUE_CM_CENTER_YAW		[20],		// Claymore Wire Area Center Yaw.
	VALUE_CM_LEFT_PITCH		[20],		// Claymore Wire Area Left Pitch.
	VALUE_CM_LEFT_YAW		[20],		// Claymore Wire Area Left Yaw.
	VALUE_CM_RIGHT_PITCH	[20],		// Claymore Wire Area Right Pitch.
	VALUE_CM_RIGHT_YAW		[20],		// Claymore Wire Area Right Yaw.
	VALUE_CM_WIRE_COLOR_T	[13],
	VALUE_CM_WIRE_COLOR_CT	[13],
};

//====================================================
//  GLOBAL VARIABLES
//====================================================
new gCvar		[CVAR_SETTING];
new gCvarValue	[CVAR_VALUE];

new gMinesId;

new gMinesData[COMMON_MINES_DATA];
new CLAYMORE_WIRE[]	= {
	pev_euser1,
	pev_euser2,
	pev_euser3,
};

new Float:gModelMargin[] = {0.0, -0.0, 4.0};
new const gWireLoop = 3;

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// CVar settings.
	// Ammo.
	gCvar[CVAR_START_HAVE]	    = create_cvar(fmt("%s%s", CVAR_TAG, "_amount"),					"1"				);	// Round start have ammo count.
	gCvar[CVAR_MAX_HAVE]       	= create_cvar(fmt("%s%s", CVAR_TAG, "_max_amount"),   			"2"				);	// Max having ammo.
	gCvar[CVAR_TEAM_MAX]		= create_cvar(fmt("%s%s", CVAR_TAG, "_team_max"),				"10"			);	// Max deployed in team.
	gCvar[CVAR_MAX_DEPLOY]		= create_cvar(fmt("%s%s", CVAR_TAG, "_max_deploy"),				"10"			);	// Max deployed in user.

	// Buy system.
	gCvar[CVAR_BUY_MODE]	    = create_cvar(fmt("%s%s", CVAR_TAG, "_buy_mode"),				"1"				);	// 0 = off, 1 = on.
	gCvar[CVAR_CBT]    			= create_cvar(fmt("%s%s", CVAR_TAG, "_buy_team"),				"ALL"			);	// Can buy team. TR / CT / ALL. (BIOHAZARD: Z = Zombie)
	gCvar[CVAR_COST]           	= create_cvar(fmt("%s%s", CVAR_TAG, "_buy_price"),				"2500"			);	// Buy cost.
	gCvar[CVAR_BUY_ZONE]        = create_cvar(fmt("%s%s", CVAR_TAG, "_buy_zone"),				"1"				);	// Stay in buy zone can buy.
	gCvar[CVAR_FRAG_MONEY]     	= create_cvar(fmt("%s%s", CVAR_TAG, "_frag_money"),   			"300"			);	// Get money.

	// Mine design.
	gCvar[CVAR_MINE_HEALTH]    	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_health"),			"50"			);	// Tripmine Health. (Can break.)
	gCvar[CVAR_MINE_GLOW]      	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow"),				"0"				);	// Tripmine glowing. 0 = off, 1 = on.
	gCvar[CVAR_MINE_GLOW_MODE]  = create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_mode"),	"0"				);	// Mine glow coloer 0 = team color, 1 = green.
	gCvar[CVAR_MINE_GLOW_TR]  	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_t"),		"255,0,0"		);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_MINE_GLOW_CT]  	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_ct"),		"0,0,255"		);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)
	gCvar[CVAR_MINE_BROKEN]		= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_broken"),			"2"				);	// Can broken Mines.(0 = mines, 1 = Team, 2 = Enemy)
	gCvar[CVAR_EXPLODE_RADIUS] 	= create_cvar(fmt("%s%s", CVAR_TAG, "_explode_radius"),			"320.0"			);	// Explosion radius.
	gCvar[CVAR_EXPLODE_DMG]		= create_cvar(fmt("%s%s", CVAR_TAG, "_explode_damage"),			"100"			);	// Explosion radius damage.

	// Misc Settings.
	gCvar[CVAR_DEATH_REMOVE]	= create_cvar(fmt("%s%s", CVAR_TAG, "_death_remove"),			"0"				);	// Dead Player remove claymore. 0 = off, 1 = on.
	gCvar[CVAR_CM_ACTIVATE]		= create_cvar(fmt("%s%s", CVAR_TAG, "_activate_time"),			"1.0"			);	// Waiting for put claymore. (int:seconds. 0 = no progress bar.)
	gCvar[CVAR_ALLOW_PICKUP]	= create_cvar(fmt("%s%s", CVAR_TAG, "_allow_pickup"),			"1"				);	// allow pickup mine. (0 = disable, 1 = it's mine, 2 = allow friendly mine, 3 = allow enemy mine!)

	// Claymore Settings. (Color is Laser color)
	gCvar[CVAR_CM_WIRE_VISIBLE]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_visible"),			"1"				);	// wire visibility.
	gCvar[CVAR_CM_WIRE_RANGE]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_range"),				"300"			);	// wire range.
	gCvar[CVAR_CM_WIRE_BRIGHT]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_brightness"),		"255"			);	// wire brightness.
	gCvar[CVAR_CM_WIRE_WIDTH]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_width"),				"2"				);	// wire width.
	gCvar[CVAR_CM_CENTER_PITCH]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_center_pitch"),		"10,-65"		);	// wire area center pitch.
	gCvar[CVAR_CM_CENTER_YAW]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_center_yaw"),		"45,135"		);	// wire area center yaw.
	gCvar[CVAR_CM_LEFT_PITCH]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_left_pitch"),		"10,-45"		);	// wire area left pitch.
	gCvar[CVAR_CM_LEFT_YAW]		= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_left_yaw"),			"100,165"		);	// wire area left yaw.
	gCvar[CVAR_CM_RIGHT_PITCH]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_right_pitch"),		"10,-45"		);	// wire area right pitch.
	gCvar[CVAR_CM_RIGHT_YAW]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_right_yaw"),			"15,80"			);	// wire area right yaw.
	gCvar[CVAR_CM_TRIAL_FREQ]	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_trial_freq"),		"3"				);	// wire trial frequency.
	gCvar[CVAR_CM_WIRE_COLOR]  	= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_color_mode"),		"0"				);	// Mine glow coloer 0 = team color, 1 = green.
	gCvar[CVAR_CM_WIRE_COLOR_T] = create_cvar(fmt("%s%s", CVAR_TAG, "_wire_color_t"),			"255,255,255"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_CM_WIRE_COLOR_CT]= create_cvar(fmt("%s%s", CVAR_TAG, "_wire_color_ct"),			"255,255,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)

	bind_cvars();

	create_cvar("mines_claymore", VERSION, FCVAR_SERVER|FCVAR_SPONLY);

	// Multi Language Dictionary.
	mines_register_dictionary("mines/mines_cm.txt");
	AutoExecConfig(true, "mines_cvars_cm", "mines");

	return PLUGIN_CONTINUE;
}

bind_cvars()
{
	bind_pcvar_num		(gCvar[CVAR_START_HAVE],		gCvarValue[VALUE_START_HAVE]);
	bind_pcvar_num		(gCvar[CVAR_MAX_HAVE],			gCvarValue[VALUE_MAX_HAVE]);
#if defined BIOHAZARD_SUPPORT
	bind_pcvar_num		(gCvar[CVAR_NOROUND],			gCvarValue[VALUE_NOROUND]);
#endif
	bind_pcvar_num		(gCvar[CVAR_MAX_DEPLOY],		gCvarValue[VALUE_MAX_DEPLOY]);
	bind_pcvar_num		(gCvar[CVAR_TEAM_MAX],			gCvarValue[VALUE_TEAM_MAX]);
	bind_pcvar_num		(gCvar[CVAR_BUY_MODE],			gCvarValue[VALUE_BUY_MODE]);
	bind_pcvar_num		(gCvar[CVAR_BUY_ZONE],			gCvarValue[VALUE_BUY_ZONE]);
	bind_pcvar_num		(gCvar[CVAR_COST],				gCvarValue[VALUE_COST]);
	bind_pcvar_num		(gCvar[CVAR_FRAG_MONEY],		gCvarValue[VALUE_FRAG_MONEY]);
	bind_pcvar_num		(gCvar[CVAR_MINE_BROKEN],		gCvarValue[VALUE_MINE_BROKEN]);
	bind_pcvar_num		(gCvar[CVAR_ALLOW_PICKUP],		gCvarValue[VALUE_ALLOW_PICKUP]);
	bind_pcvar_num		(gCvar[CVAR_DEATH_REMOVE],		gCvarValue[VALUE_DEATH_REMOVE]);
	bind_pcvar_num		(gCvar[CVAR_MINE_GLOW],			gCvarValue[VALUE_MINE_GLOW]);
	bind_pcvar_num		(gCvar[CVAR_MINE_GLOW_MODE],	gCvarValue[VALUE_MINE_GLOW_MODE]);
	bind_pcvar_num		(gCvar[CVAR_CM_WIRE_VISIBLE],	gCvarValue[VALUE_CM_WIRE_VISIBLE]);
	bind_pcvar_num		(gCvar[CVAR_CM_WIRE_COLOR],		gCvarValue[VALUE_CM_WIRE_COLOR]);
	bind_pcvar_num		(gCvar[CVAR_CM_TRIAL_FREQ], 	gCvarValue[VALUE_CM_TRIAL_FREQ]);
	bind_pcvar_float	(gCvar[CVAR_CM_WIRE_WIDTH],		gCvarValue[VALUE_CM_WIRE_WIDTH]);
	bind_pcvar_float	(gCvar[CVAR_CM_WIRE_BRIGHT],	gCvarValue[VALUE_CM_WIRE_BRIGHT]);
	bind_pcvar_float	(gCvar[CVAR_MINE_HEALTH],		gCvarValue[VALUE_MINE_HEALTH]);
	bind_pcvar_float	(gCvar[CVAR_CM_ACTIVATE],		gCvarValue[VALUE_CM_ACTIVATE]);
	bind_pcvar_float	(gCvar[CVAR_EXPLODE_RADIUS],	gCvarValue[VALUE_EXPLODE_RADIUS]);
	bind_pcvar_float	(gCvar[CVAR_EXPLODE_DMG],		gCvarValue[VALUE_EXPLODE_DMG]);
	bind_pcvar_float	(gCvar[CVAR_CM_WIRE_RANGE],		gCvarValue[VALUE_CM_WIRE_RANGE]);

	bind_pcvar_string	(gCvar[CVAR_CBT], 				gCvarValue[VALUE_CBT], 				charsmax(gCvarValue[VALUE_CBT]));
	bind_pcvar_string	(gCvar[CVAR_MINE_GLOW_TR],		gCvarValue[VALUE_MINE_GLOW_TR],		charsmax(gCvarValue[VALUE_MINE_GLOW_TR]) 	- 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_MINE_GLOW_CT],		gCvarValue[VALUE_MINE_GLOW_CT],		charsmax(gCvarValue[VALUE_MINE_GLOW_CT]) 	- 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_CM_CENTER_PITCH],	gCvarValue[VALUE_CM_CENTER_PITCH],	charsmax(gCvarValue[VALUE_CM_CENTER_PITCH]) - 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_CM_CENTER_YAW],		gCvarValue[VALUE_CM_CENTER_YAW],	charsmax(gCvarValue[VALUE_MINE_GLOW_CT]) 	- 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_CM_LEFT_PITCH],		gCvarValue[VALUE_CM_LEFT_PITCH],	charsmax(gCvarValue[VALUE_MINE_GLOW_CT]) 	- 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_CM_LEFT_YAW],		gCvarValue[VALUE_CM_LEFT_YAW],		charsmax(gCvarValue[VALUE_MINE_GLOW_CT]) 	- 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_CM_RIGHT_PITCH],	gCvarValue[VALUE_CM_RIGHT_PITCH],	charsmax(gCvarValue[VALUE_MINE_GLOW_CT]) 	- 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_CM_RIGHT_YAW],		gCvarValue[VALUE_CM_RIGHT_YAW],		charsmax(gCvarValue[VALUE_MINE_GLOW_CT]) 	- 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_CM_WIRE_COLOR_T],	gCvarValue[VALUE_CM_WIRE_COLOR_T],	charsmax(gCvarValue[VALUE_MINE_GLOW_CT]) 	- 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_CM_WIRE_COLOR_CT],	gCvarValue[VALUE_CM_WIRE_COLOR_CT],	charsmax(gCvarValue[VALUE_MINE_GLOW_CT]) 	- 1);// last comma - 1


	gMinesData[AMMO_HAVE_START] =	gCvarValue[VALUE_START_HAVE];
	gMinesData[AMMO_HAVE_MAX]	=	gCvarValue[VALUE_MAX_HAVE];
#if defined BIOHAZARD_SUPPORT
	gMinesData[NO_ROUND]		=	gCvarValue[VALUE_NOROUND];
#endif
	gMinesData[DEPLOY_MAX]		=	gCvarValue[VALUE_MAX_DEPLOY];
	gMinesData[DEPLOY_TEAM_MAX]	=	gCvarValue[VALUE_TEAM_MAX];
	gMinesData[BUY_MODE]		=	gCvarValue[VALUE_BUY_MODE];
	gMinesData[BUY_ZONE]		=	gCvarValue[VALUE_BUY_ZONE];
	gMinesData[BUY_PRICE]		=	gCvarValue[VALUE_COST];
	gMinesData[FRAG_MONEY]		=	gCvarValue[VALUE_FRAG_MONEY];
	gMinesData[MINES_BROKEN]	=	gCvarValue[VALUE_MINE_BROKEN];
	gMinesData[ALLOW_PICKUP]	=	gCvarValue[VALUE_ALLOW_PICKUP];
	gMinesData[DEATH_REMOVE]	=	gCvarValue[VALUE_DEATH_REMOVE];
	gMinesData[GLOW_ENABLE]		=	gCvarValue[VALUE_MINE_GLOW];
	gMinesData[GLOW_MODE]		=	gCvarValue[VALUE_MINE_GLOW_MODE];
	gMinesData[MINE_HEALTH]		=	gCvarValue[VALUE_MINE_HEALTH];
	gMinesData[ACTIVATE_TIME]	=	gCvarValue[VALUE_CM_ACTIVATE];
	gMinesData[EXPLODE_RADIUS]	=	gCvarValue[VALUE_EXPLODE_RADIUS];
	gMinesData[EXPLODE_DAMAGE]	=	gCvarValue[VALUE_EXPLODE_DMG];
	gMinesData[BUY_TEAM] 		=	get_team_code(gCvarValue[VALUE_CBT]);
	gMinesData[GLOW_COLOR_TR]	=	get_cvar_to_color(gCvarValue[VALUE_MINE_GLOW_TR]);
	gMinesData[GLOW_COLOR_CT]	=	get_cvar_to_color(gCvarValue[VALUE_MINE_GLOW_CT]);

	gMinesId 					=	register_mines(ENT_CLASS_CLAYMORE, LANG_KEY_LONGNAME);

	register_mines_data(gMinesId, gMinesData, ENT_MODELS);
}

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	precache_sound(ENT_SOUND1);
	precache_sound(ENT_SOUND2);
	precache_model(ENT_MODELS);
	precache_model(ENT_SPRITE1);
	
	return PLUGIN_CONTINUE;
}

//====================================================
// claymore Settings.
//====================================================
public mines_entity_spawn_settings(iEnt, uID, iMinesId)
{
	if (iMinesId != gMinesId) return;
	// Entity Setting.
	// set class name.
	set_pev(iEnt, pev_classname, ENT_CLASS_CLAYMORE);

	// set models.
	engfunc(EngFunc_SetModel, iEnt, ENT_MODELS);

	// set solid.
	set_pev(iEnt, pev_solid, SOLID_NOT);

	// set movetype.
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY);

	// set model animation.
	set_pev(iEnt, pev_frame,		0);
	set_pev(iEnt, pev_body, 		3);
	set_pev(iEnt, pev_sequence, 	TRIPMINE_WORLD);
	set_pev(iEnt, pev_framerate,	0);
	set_pev(iEnt, pev_rendermode,	kRenderNormal);
	set_pev(iEnt, pev_renderfx,	 	kRenderFxNone);

	// set take damage.
	set_pev(iEnt, pev_takedamage, DAMAGE_YES);
	set_pev(iEnt, pev_dmg, 100.0);

	// set entity health.
	set_pev(iEnt, pev_health, gMinesData[MINE_HEALTH]);

	// set mine position
	set_mine_position(uID, iEnt);

	// Save results to be used later.
	set_pev(iEnt, MINES_OWNER, uID );
	set_pev(iEnt, MINES_TEAM, int:cs_get_user_team(uID));

	// Reset powoer on delay time.
	new Float:fCurrTime = get_gametime();
	set_pev(iEnt, CLAYMORE_POWERUP, fCurrTime + 2.5 );
	set_pev(iEnt, MINES_STEP, POWERUP_THINK);

	// think rate. hmmm....
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.2 );

	// Power up sound.
	cm_play_sound(iEnt, SOUND_POWERUP);
}

//====================================================
// Set claymore Position.
//====================================================
set_mine_position(uID, iEnt)
{
	// Vector settings.
	new Float:vOrigin[3];
	new	Float:vNewOrigin[3],Float:vNormal[3],
		Float:vTraceEnd[3],Float:vEntAngles[3];

	// get user position.
	pev(uID, pev_origin, vOrigin);
	velocity_by_aim(uID, 128, vTraceEnd);
	vTraceEnd[2] = -128.0;
	xs_vec_add(vTraceEnd, vOrigin, vTraceEnd );

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
	}
    // free the trace handle.
	free_tr2(trace);

	xs_vec_mul_scalar( vNormal, 8.0, vNormal );
	xs_vec_add( vTraceEnd, vNormal, vNewOrigin );

	// set size.
	engfunc(EngFunc_SetSize, iEnt, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );
	// set entity position.
	engfunc(EngFunc_SetOrigin, iEnt, vNewOrigin );
	// Claymore user Angles.
	new Float:pAngles[3];
	pev(uID, pev_angles, pAngles);
	pAngles[0]   = -90.0;
	//pAngles[1]  += -90.0;

	// Rotate tripmine.
	vector_to_angle(vNormal, vEntAngles);
	xs_vec_add(vEntAngles, pAngles, vEntAngles); 

	// set angle.
	set_pev(iEnt, pev_angles, vEntAngles);
	xs_vec_add(vNewOrigin, gModelMargin, vNewOrigin);

	set_pev(iEnt, CLAYMORE_WIRE_STARTPOINT, vNewOrigin);

	// set laserbeam end point position.
	set_claymore_endpoint(iEnt, vNewOrigin);
}

Float:get_claymore_wire_endpoint(cvar)
{
	new i = 0, n = 0, iPos = 0;
	new Float:values[2];
	new sCvarValue	[20];
	new sSplit		[20];
	new sSplitLen		= charsmax(sSplit);


	formatex(sCvarValue, charsmax(sCvarValue), "%s%s", gCvarValue[cvar], ",");
	while((i = split_string(sCvarValue[iPos += i], ",", sSplit, sSplitLen)) != -1 && n < sizeof(values))
	{
		values[n++] = str_to_float(sSplit);
	}
	return random_float(values[0], values[1]);
}

//====================================================
// Claymore Wire Endpoint
//====================================================
stock set_claymore_endpoint(iEnt, Float:vOrigin[3])
{
	new Float:vAngles		[3];
	new Float:vForward		[3];
	new Float:vResult		[3][3];
	new Float:pAngles		[3];
	new Float:vFwd			[3];
	new Float:vRight		[3];
	new Float:vUp			[3];
	new trace = create_tr2();
	static Float:hitPoint	[3];
	static Float:vTmp		[3];
	static Float:pitch;
	static Float:yaw;
	static Float:fFraction;
	new Float:range;
	new n = 0;
	new freq;
	pev(iEnt, pev_angles, vAngles);

	// roll zero
	pAngles[2] = 0.0;

	for (new i = 0; i < 3; i++)
	{
		hitPoint	= vOrigin;
		vTmp		= vOrigin;
		n = 0;
		while(n < freq)
		{
			while(xs_vec_distance(vOrigin, vTmp) > range || xs_vec_equal(vOrigin, vTmp))
			{
				switch(i)
				{
					// pitch:down 0, back 90, up 180, forward 270(-90)
					// yaw  :left 90, right -90 
					case 0: // center
					{
						pitch 	= get_claymore_wire_endpoint(CVAR_CM_CENTER_PITCH);
						yaw		= get_claymore_wire_endpoint(CVAR_CM_CENTER_YAW);
					}
					case 1: // right
					{
						pitch 	= get_claymore_wire_endpoint(CVAR_CM_RIGHT_PITCH);
						yaw		= get_claymore_wire_endpoint(CVAR_CM_RIGHT_YAW);
					}
					case 2: // left
					{
						pitch 	= get_claymore_wire_endpoint(CVAR_CM_LEFT_PITCH);
						yaw		= get_claymore_wire_endpoint(CVAR_CM_LEFT_YAW);
					}
				}

				pAngles[0] = pitch;
				pAngles[1] = -90 + yaw;

				xs_vec_add(pAngles, vAngles, pAngles);
				xs_anglevectors(pAngles, vFwd, vRight, vUp);
			
				xs_vec_mul_scalar(vFwd, range, vFwd);
				xs_vec_add(vOrigin, vFwd, vForward);
				// xs_vec_add(vFwd, vNormal, vForward);
				// xs_vec_add(vOrigin, vForward, vForward);

				// Trace line
				engfunc(EngFunc_TraceLine, vOrigin, vForward, IGNORE_MONSTERS, iEnt, trace)
				{
					get_tr2(trace, TR_vecEndPos, vTmp);
					get_tr2(trace, TR_flFraction, fFraction);
				}
			}
			new block = engfunc(EngFunc_PointContents, vTmp);
			if (block != CONTENTS_SKY || block == CONTENTS_SOLID) 
			{
				if (xs_vec_distance(vOrigin, vTmp) > xs_vec_distance(vOrigin, hitPoint))
				{
					hitPoint = vTmp;
				}
				n++;
			}
		}
		vResult[i] = hitPoint;
	}

	// free the trace handle.
	free_tr2(trace);

	set_pev(iEnt, CLAYMORE_WIREENDPOINT1, vResult[0]);
	set_pev(iEnt, CLAYMORE_WIREENDPOINT2, vResult[1]);
	set_pev(iEnt, CLAYMORE_WIREENDPOINT3, vResult[2]);
}

//====================================================
// claymore Think Event.
//====================================================
public MinesThink(iEnt, iMinesId)
{
	if (!pev_valid(iEnt))
		return;

	// is this claymore? no.
	if (iMinesId != gMinesId)
		return;

	static Float:fCurrTime;
	static Float:vEnd[3][3];
	static step;

	fCurrTime = get_gametime();
	step = pev(iEnt, MINES_STEP);
	// Get Laser line end potision.
	pev(iEnt, CLAYMORE_WIREENDPOINT1, vEnd[0]);
	pev(iEnt, CLAYMORE_WIREENDPOINT2, vEnd[1]);
	pev(iEnt, CLAYMORE_WIREENDPOINT3, vEnd[2]);

	// claymore state.
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
			cm_play_sound(iEnt, SOUND_STOP);

			// effect explosion.
			mines_explosion(pev(iEnt, MINES_OWNER), iMinesId, iEnt);
		}
	}

	return;
}

mines_step_powerup(iEnt, Float:fCurrTime)
{
	static Float:fPowerupTime;
	pev(iEnt, CLAYMORE_POWERUP, fPowerupTime);
	// over power up time.
		
	if (fCurrTime > fPowerupTime)
	{
		// next state.
		set_pev(iEnt, MINES_STEP, BEAMUP_THINK);
		// activate sound.
		cm_play_sound(iEnt, SOUND_ACTIVATE);

	}
	mines_glow(iEnt, gMinesData);
	// Think time.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
}

mines_step_beamup(iEnt, Float:vEnd[3][3], Float:fCurrTime)
{
	static wire;
	// solid complete.
	set_pev(iEnt, pev_solid, SOLID_BBOX);

	for (new i = 0; i < gWireLoop; i++)
	{
		wire = draw_laserline(iEnt, vEnd[i]);
		set_pev(iEnt, CLAYMORE_WIRE[i], wire);
		mines_spark_wall(vEnd[i]);
	}

	// next state.
	set_pev(iEnt, MINES_STEP, BEAMBREAK_THINK);
	// Think time.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
}

mines_step_beambreak(iEnt, Float:vEnd[3][3], Float:fCurrTime)
{
	static iTarget;
	static trace;
	static Float:fFraction;
	static Float:vOrigin[3];
	static Float:hitPoint[3];

	// Get owner id.
	new iOwner = pev(iEnt, MINES_OWNER);
	// Get this mine position.
	pev(iEnt, CLAYMORE_WIRE_STARTPOINT, vOrigin);

	for(new i = 0; i < gWireLoop; i++)
	{
		// create the trace handle.
		trace = create_tr2();
		// Trace line
		engfunc(EngFunc_TraceLine, vOrigin, vEnd[i], DONT_IGNORE_MONSTERS, iEnt, trace);
		{
			get_tr2(trace, TR_flFraction, fFraction);
			iTarget		= get_tr2(trace, TR_pHit);
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
		if (!is_user_alive(iTarget))
			continue;

		// Hit friend and No FF.
		if (!mines_valid_takedamage(iOwner, iTarget))
			continue;

		// is godmode?
		if (get_user_godmode(iTarget))
			continue;

		// keep target id.
		set_pev(iEnt, pev_enemy, iTarget);

		// State change. to Explosing step.
		set_pev(iEnt, MINES_STEP, EXPLOSE_THINK);
	}

	// Get mine health.
	static Float:iHealth;
	pev(iEnt, pev_health, iHealth);

	// break?
	if (iHealth <= 0 || (pev(iEnt, pev_flags) & FL_KILLME))
	{
		// next step explosion.
		set_pev(iEnt, MINES_STEP, EXPLOSE_THINK);
		set_pev(iEnt, pev_nextthink, fCurrTime + random_float( 0.1, 0.3 ));
	}
				
	// Think time. random_float = laser line blinking.
	set_pev(iEnt, pev_nextthink, fCurrTime + random_float(0.01, 0.02));

	return true;
}

//====================================================
// Drawing Laser line.
//====================================================
draw_laserline(iEnt, const Float:vEndOrigin[3])
{
	new Float:tcolor[3];
	new CsTeams:teamid = CsTeams:pev(iEnt, MINES_TEAM);

	// Color mode. 0 = team color.
	if(gCvarValue[VALUE_CM_WIRE_COLOR] == 0)
	{
		switch(teamid)
		{
			case CS_TEAM_T:
				for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(get_cvar_to_color(gCvarValue[VALUE_CM_WIRE_COLOR_T]), i));
			case CS_TEAM_CT:
				for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(get_cvar_to_color(gCvarValue[VALUE_CM_WIRE_COLOR_CT]), i));
			default:
				for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(get_cvar_to_color("20,20,20"), i));
		}

	}

	static Float:vStartOrigin[3];
	pev(iEnt, CLAYMORE_WIRE_STARTPOINT, vStartOrigin);
	// lm_draw_laser(iEnt, vEndOrigin, gBeam, 0, 0, 0, width, 0, tcolor, bind_pcvar_num(gCvar[CVAR_CM_WIRE_BRIGHT]), 0);
	return cm_draw_wire(vStartOrigin, vEndOrigin, 0.0, gCvarValue[VALUE_CM_WIRE_WIDTH], 0, tcolor, gCvarValue[VALUE_CM_WIRE_BRIGHT], 0.0);
}

stock cm_draw_wire(
		const Float:vStartOrigin[3],
		const Float:vEndOrigin[3], 
		const Float:framestart	= 0.0, 
		const Float:width		= 1.0, 
		const wave				= 0, 
		const Float:tcolor[3],
		const Float:bright		= 255.0,
		const Float:speed		= 255.0
	)
{
	new beams = Beam_Create(ENT_SPRITE1, width);
	Beam_PointsInit(beams, vStartOrigin, vEndOrigin);
	Beam_SetFlags(beams, BEAM_FSOLID);
	Beam_SetFrame(beams, framestart);
	Beam_SetNoise(beams, wave);
	Beam_SetColor(beams, tcolor);
	Beam_SetBrightness(beams, bright);
	Beam_SetScrollRate(beams, speed);
	set_pev(beams, pev_renderamt, 255.0);
	return beams;
}

//====================================================
// Check: On the wall.
//====================================================
public CheckForDeploy(id, iMinesId)
{
	if(iMinesId != gMinesId) return false;

	new Float:vTraceEnd[3];
	new Float:vOrigin[3];

	// Get potision.
	pev(id, pev_origin, vOrigin);
	
	// Get wall position.
	velocity_by_aim(id, 128, vTraceEnd);
	vTraceEnd[2] = -128.0;

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
	client_print_color(id, id, "%L", id, LANG_KEY_PLANT_GROUND, CHAT_TAG, sLongName);

	return false;
}

public MinesBreaked(iMinesId, iEnt, iAttacker)
{
	if (iMinesId != gMinesId) return HAM_IGNORED;
#if defined ZP_SUPPORT
	zp_ammopacks_set(iAttacker, zp_ammopacks_get(iAttacker) + gCvarValue[VALUE_FRAG_MONEY]);
	zp_colored_print(0, "^4%n ^1earned^4 %i points ^1for destorying a claymore !", iAttacker, addpoint);
#endif
    return HAM_IGNORED;
}

//====================================================
// Play sound.
//====================================================
cm_play_sound(iEnt, iSoundType)
{
	switch (iSoundType)
	{
		case SOUND_POWERUP:
		{
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_ACTIVATE:
		{
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND2, 0.5, ATTN_NORM, 1, 75);
		}
	}
}

public mines_remove_entity(iEnt)
{
	new wire;
	for (new i = 0; i < 3; i++)
	{
		wire = pev(iEnt, CLAYMORE_WIRE[i]);
		engfunc(EngFunc_RemoveEntity, wire);
	}
}

public mines_deploy_hologram(id, iEnt, iMinesId)
{
	if (iMinesId != gMinesId)
		return 0;

	// Vector settings.
	static	Float:vOrigin[3];
	static	Float:vNewOrigin[3],Float:vNormal[3],
			Float:vTraceEnd[3],Float:vEntAngles[3];

	// Get wall position.
	velocity_by_aim(id, 128, vTraceEnd);
	vTraceEnd[2] = -128.0;

	// get user position.
	pev(id, pev_origin, vOrigin);
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
			// Claymore user Angles.
			new Float:pAngles[3];
			pev(id, pev_angles, pAngles);
			pAngles[0]   = -90.0;
			// Rotate tripmine.
			vector_to_angle(vNormal, vEntAngles);
			xs_vec_add(vEntAngles, pAngles, vEntAngles); 
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