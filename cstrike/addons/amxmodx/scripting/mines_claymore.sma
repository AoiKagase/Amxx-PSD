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
#include <beams>

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
#define PLUGIN 						"[M.E.P] Claymore"
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"3.08"

#define CHAT_TAG 					"[M.E.P CM]"
#define CVAR_TAG					"mines_cm"

#if defined BIOHAZARD_SUPPORT
	#define LANG_KEY_NOT_BUY_TEAM	"NOT_BUY_TEAMB"
#else
	#define LANG_KEY_NOT_BUY_TEAM 	"NOT_BUY_TEAM"
#endif

//#define STR_MINEDETNATED 			"Your mine has detonated.",
//#define STR_MINEDETNATED2			"detonated your mine.",
//#define STR_CANTDEPLOY			"Your team can't deploying claymore!"

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

#define MAX_CLAYMORE				40
#define ENT_CLASS_CLAYMORE			"claymore"
#define CLAYMORE_WIRE_STARTPOINT	pev_vuser4
// Client Print Command Macro.
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
#define cp_all_remove(%1,%2,%3)		client_print_color(%1, %1, "%L", %1, LANG_KEY_ALL_REMOVE,	CHAT_TAG, %2, %3)
#define cp_gave(%1,%2,%3)			client_print_color(%1, %1, "%L", %1, LANG_KEY_GIVE_MINE,	CHAT_TAG, %2, %3)
#define cp_remove_spec(%1,%2)		client_print_color(%1, %1, "%L", %1, LANG_KEY_REMOVE_SPEC,	CHAT_TAG, %2)

#define CLAYMORE_POWERUP			pev_fuser2
#define CLAYMORE_WIREENDPOINT1		pev_vuser1
#define CLAYMORE_WIREENDPOINT2		pev_vuser2
#define CLAYMORE_WIREENDPOINT3		pev_vuser3
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

//====================================================
//  GLOBAL VARIABLES
//====================================================
new gCvar[CVAR_SETTING];
new gMinesId;

new Float:gDeployPos	[MAX_PLAYERS][3];

#if defined ZP_SUPPORT
	new ITEM_NAME[] = "Claymore";
	new gZpGameMode[GAMEMODE_TAG];
	new gZpWeaponId;
#endif

new gMinesData[COMMON_MINES_DATA];
new CLAYMORE_WIRE[]	= {
	pev_euser1,
	pev_euser2,
	pev_euser3,
};

new Float:gModelMargin[] = {0.0, -0.0, 4.0};
const gWireLoop = 3;
//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Add your code here...
	register_clcmd("+setcm", 	"cm_progress_deploy");
	register_clcmd("+remcm", 	"cm_progress_remove");
   	register_clcmd("-setcm", 	"cm_progress_stop");
   	register_clcmd("-remcm", 	"cm_progress_stop");
	register_clcmd("say", 		"cm_say_claymore");
#if !defined ZP_SUPPORT	
	register_clcmd("buy_cm",	"cm_buy_claymore");
#endif

	// CVar settings.
	// Ammo.
	gCvar[CVAR_START_HAVE]	    = register_cvar(fmt("%s%s", CVAR_TAG, "_amount"),				"1"			);	// Round start have ammo count.
	gCvar[CVAR_MAX_HAVE]       	= register_cvar(fmt("%s%s", CVAR_TAG, "_max_amount"),   		"2"			);	// Max having ammo.
	gCvar[CVAR_TEAM_MAX]		= register_cvar(fmt("%s%s", CVAR_TAG, "_team_max"),				"10"		);	// Max deployed in team.
	gCvar[CVAR_MAX_DEPLOY]		= register_cvar(fmt("%s%s", CVAR_TAG, "_max_deploy"),			"10"		);	// Max deployed in user.

	// Buy system.
	gCvar[CVAR_BUY_MODE]	    = register_cvar(fmt("%s%s", CVAR_TAG, "_buy_mode"),				"1"			);	// 0 = off, 1 = on.
	gCvar[CVAR_CBT]    			= register_cvar(fmt("%s%s", CVAR_TAG, "_buy_team"),				"ALL"		);	// Can buy team. TR / CT / ALL. (BIOHAZARD: Z = Zombie)
	gCvar[CVAR_COST]           	= register_cvar(fmt("%s%s", CVAR_TAG, "_buy_price"),			"2500"		);	// Buy cost.
	gCvar[CVAR_BUY_ZONE]        = register_cvar(fmt("%s%s", CVAR_TAG, "_buy_zone"),				"1"			);	// Stay in buy zone can buy.
	gCvar[CVAR_FRAG_MONEY]     	= register_cvar(fmt("%s%s", CVAR_TAG, "_frag_money"),   		"300"		);	// Get money.

	// Mine design.
	gCvar[CVAR_MINE_HEALTH]    	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_health"),			"50"		);	// Tripmine Health. (Can break.)
	gCvar[CVAR_MINE_GLOW]      	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow"),			"1"			);	// Tripmine glowing. 0 = off, 1 = on.
	gCvar[CVAR_MINE_GLOW_MODE]  = register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_mode"),	"0"			);	// Mine glow coloer 0 = team color, 1 = green.
	gCvar[CVAR_MINE_GLOW_TR]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_t"),	"255,0,0"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_MINE_GLOW_CT]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_ct"),	"0,0,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)
	gCvar[CVAR_MINE_BROKEN]		= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_broken"),			"2"			);	// Can broken Mines.(0 = mines, 1 = Team, 2 = Enemy)
	gCvar[CVAR_EXPLODE_RADIUS] 	= register_cvar(fmt("%s%s", CVAR_TAG, "_explode_radius"),		"320.0"		);	// Explosion radius.
	gCvar[CVAR_EXPLODE_DMG]		= register_cvar(fmt("%s%s", CVAR_TAG, "_explode_damage"),		"100"		);	// Explosion radius damage.

	// Misc Settings.
	gCvar[CVAR_DEATH_REMOVE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_death_remove"),			"0"			);	// Dead Player remove claymore. 0 = off, 1 = on.
	gCvar[CVAR_CM_ACTIVATE]		= register_cvar(fmt("%s%s", CVAR_TAG, "_activate_time"),		"1"			);	// Waiting for put claymore. (int:seconds. 0 = no progress bar.)
	gCvar[CVAR_ALLOW_PICKUP]	= register_cvar(fmt("%s%s", CVAR_TAG, "_allow_pickup"),			"1"			);	// allow pickup mine. (0 = disable, 1 = it's mine, 2 = allow friendly mine, 3 = allow enemy mine!)

	// Claymore Settings. (Color is Laser color)
	gCvar[CVAR_CM_WIRE_VISIBLE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_visible"),			"1"			);	// wire visibility.
	gCvar[CVAR_CM_WIRE_RANGE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_range"),		"300"		);	// wire range.
	gCvar[CVAR_CM_WIRE_BRIGHT]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_brightness"),	"255"		);	// wire brightness.
	gCvar[CVAR_CM_WIRE_WIDTH]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_width"),		"2"			);	// wire width.
	gCvar[CVAR_CM_CENTER_PITCH]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_center_pitch"),"10,-65"		);	// wire area center pitch.
	gCvar[CVAR_CM_CENTER_YAW]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_center_yaw"),	"45,135"	);	// wire area center yaw.
	gCvar[CVAR_CM_LEFT_PITCH]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_left_pitch"),	"10,-45"	);	// wire area left pitch.
	gCvar[CVAR_CM_LEFT_YAW]		= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_left_yaw"),	"100,165"	);	// wire area left yaw.
	gCvar[CVAR_CM_RIGHT_PITCH]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_right_pitch"),	"10,-45"	);	// wire area right pitch.
	gCvar[CVAR_CM_RIGHT_YAW]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_right_yaw"),	"15,80"		);	// wire area right yaw.
	gCvar[CVAR_CM_TRIAL_FREQ]	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_trial_freq"),	"3"			);	// wire trial frequency.
	gCvar[CVAR_CM_WIRE_COLOR]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_color_mode"),	"0"			);	// Mine glow coloer 0 = team color, 1 = green.
	gCvar[CVAR_CM_WIRE_COLOR_T] = register_cvar(fmt("%s%s", CVAR_TAG, "_wire_color_t"),		"255,255,255"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_CM_WIRE_COLOR_CT]= register_cvar(fmt("%s%s", CVAR_TAG, "_wire_color_ct"),	"255,255,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)

	gMinesData[AMMO_HAVE_START]		=	get_pcvar_num(gCvar[CVAR_START_HAVE]);
	gMinesData[AMMO_HAVE_MAX]		=	get_pcvar_num(gCvar[CVAR_MAX_HAVE]);
#if defined BIOHAZARD_SUPPORT
	gMinesData[NO_ROUND]			=	get_pcvar_num(gCvar[CVAR_NOROUND]);
#endif
	gMinesData[DEPLOY_MAX]			= 	get_pcvar_num(gCvar[CVAR_MAX_DEPLOY]);
	gMinesData[DEPLOY_TEAM_MAX]		= 	get_pcvar_num(gCvar[CVAR_TEAM_MAX]);
	gMinesData[BUY_MODE]			=	get_pcvar_num(gCvar[CVAR_BUY_MODE]);
	gMinesData[BUY_ZONE]			=	get_pcvar_num(gCvar[CVAR_BUY_ZONE]);
	gMinesData[BUY_PRICE]			= 	get_pcvar_num(gCvar[CVAR_COST]);
	gMinesData[FRAG_MONEY]			= 	get_pcvar_num(gCvar[CVAR_FRAG_MONEY]);
	gMinesData[MINES_BROKEN]		= 	get_pcvar_num(gCvar[CVAR_MINE_BROKEN]);
	gMinesData[ALLOW_PICKUP]		=	get_pcvar_num(gCvar[CVAR_ALLOW_PICKUP]);
	gMinesData[DEATH_REMOVE]		=	get_pcvar_num(gCvar[CVAR_DEATH_REMOVE]);
	gMinesData[GLOW_ENABLE]			=	get_pcvar_num(gCvar[CVAR_MINE_GLOW]);
	gMinesData[GLOW_MODE]			=	get_pcvar_num(gCvar[CVAR_MINE_GLOW_MODE]);
	gMinesData[MINE_HEALTH]			= 	get_pcvar_float(gCvar[CVAR_MINE_HEALTH]);
	gMinesData[ACTIVATE_TIME]		= 	get_pcvar_float(gCvar[CVAR_CM_ACTIVATE]);
	gMinesData[EXPLODE_RADIUS]		=	get_pcvar_float(gCvar[CVAR_EXPLODE_RADIUS]);
	gMinesData[EXPLODE_DAMAGE]		=	get_pcvar_float(gCvar[CVAR_EXPLODE_DMG]);
	new arg[4], argColor[13];
	get_pcvar_string(gCvar[CVAR_CBT], arg, charsmax(arg));
	gMinesData[BUY_TEAM]			=	get_team_code(arg);
	get_pcvar_string(gCvar[CVAR_MINE_GLOW_TR],	argColor,	charsmax(argColor) - 1);// last comma - 1
	gMinesData[GLOW_COLOR_TR]		=	get_cvar_to_color(argColor);
	get_pcvar_string(gCvar[CVAR_MINE_GLOW_CT],	argColor,	charsmax(argColor) - 1);// last comma - 1
	gMinesData[GLOW_COLOR_CT]		=	get_cvar_to_color(argColor);

	gMinesId = register_mines(ENT_CLASS_CLAYMORE, gMinesData);

	// Multi Language Dictionary.
	register_dictionary("claymore.txt");

	register_cvar(PLUGIN, VERSION, FCVAR_SERVER|FCVAR_SPONLY);

	return PLUGIN_CONTINUE;
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
//  PLUGIN CONFIG
//====================================================
public plugin_cfg()
{
}

//====================================================
// Put claymore Start Progress A
//====================================================
public cm_progress_deploy(id)
{
	mines_progress_deploy(id, gMinesId);
	return PLUGIN_HANDLED;
}

//====================================================
// Removing target put claymore.
//====================================================
public cm_progress_remove(id)
{
	mines_progress_pickup(id, gMinesId);
	return PLUGIN_HANDLED;
}

//====================================================
// Stopping Progress.
//====================================================
public cm_progress_stop(id)
{
	mines_progress_stop(id);
	return PLUGIN_HANDLED;
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
	set_pev(iEnt, pev_health, get_pcvar_float(gCvar[CVAR_MINE_HEALTH]));

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
	xs_vec_add( gDeployPos[uID], vOrigin, vTraceEnd );

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

Float:get_claymore_wire_endpoint(CVAR_SETTING:cvar)
{
	new i = 0, n = 0, iPos = 0;
	new Float:values[2];
	new sCvarValue	[20];
	new sSplit		[20];

	new sSplitLen		= charsmax(sSplit);

	get_pcvar_string(gCvar[cvar], sCvarValue, charsmax(sCvarValue));

	formatex(sCvarValue, charsmax(sCvarValue), "%s%s", sCvarValue, ",");
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
	new Float:vAngles	[3];
	new Float:vForward	[3];
	new Float:vResult	[3][3];
	static Float:hitPoint	[3];
	static Float:vTmp		[3];
	new Float:pAngles	[3];
	new Float:vFwd		[3];
	new Float:vRight	[3];
	new Float:vUp		[3];
	new trace = create_tr2();
	static Float:pitch;
	static Float:yaw;
	new Float:range;
	new n = 0;
	new freq = get_pcvar_num(gCvar[CVAR_CM_TRIAL_FREQ]);
	range = get_pcvar_float(gCvar[CVAR_CM_WIRE_RANGE]);
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
				}
			}
			if (xs_vec_distance(vOrigin, vTmp) > xs_vec_distance(vOrigin, hitPoint))
				hitPoint = vTmp;

			n++;
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
	new sRGB		[13];
	new sColor		[4];
	new sRGBLen 	= charsmax(sRGB);
	new sColorLen	= charsmax(sColor);
	new CsTeams:teamid = CsTeams:pev(iEnt, MINES_TEAM);
	new Float:width = get_pcvar_float(gCvar[CVAR_CM_WIRE_WIDTH]);
	new i = 0, n = 0, iPos = 0;
	// Color mode. 0 = team color.
	if(get_pcvar_num(gCvar[CVAR_CM_WIRE_COLOR]) == 0)
	{
		switch(teamid)
		{
			case CS_TEAM_T:
				get_pcvar_string(gCvar[CVAR_CM_WIRE_COLOR_T], sRGB, sRGBLen);
			case CS_TEAM_CT:
				get_pcvar_string(gCvar[CVAR_CM_WIRE_COLOR_CT], sRGB, sRGBLen);
			default:
				formatex(sRGB, sRGBLen, "20,20,20");
		}

	}

	formatex(sRGB, sRGBLen, "%s%s", sRGB, ",");
	while(n < sizeof(tcolor))
	{
		i = split_string(sRGB[iPos += i], ",", sColor, sColorLen);
		tcolor[n++] = str_to_float(sColor);
	}
	/*
	stock cm_draw_laser(
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
	static Float:vStartOrigin[3];
	pev(iEnt, CLAYMORE_WIRE_STARTPOINT, vStartOrigin);
	// lm_draw_laser(iEnt, vEndOrigin, gBeam, 0, 0, 0, width, 0, tcolor, get_pcvar_num(gCvar[CVAR_CM_WIRE_BRIGHT]), 0);
	return cm_draw_wire(vStartOrigin, vEndOrigin, 0.0, width, 0, tcolor, get_pcvar_float(gCvar[CVAR_CM_WIRE_BRIGHT]), 0.0);
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

// //====================================================
// // Show ammo.
// //====================================================
// show_ammo(id)
// { 

// #if defined ZP_SUPPORT
// 	client_print(id, print_center, "[%i/%i]", cm_get_user_have_mine(id), get_pcvar_num(gCvar[CVAR_MAX_HAVE]));
// #else
// #if defined BIOHAZARD_SUPPORT
// 	client_print(id, print_center, "[%i/%i]", cm_get_user_have_mine(id), get_pcvar_num(gCvar[CVAR_MAX_HAVE]));
// #else
// 	new ammo[51];
// 	if (get_pcvar_num(gCvar[CVAR_BUY_MODE]) != 0)
// 		formatex(ammo, charsmax(ammo), "%L", id, LANG_KEY_STATE_AMMO, cm_get_user_have_mine(id), get_pcvar_num(gCvar[CVAR_MAX_HAVE]));
// 	else
// 		formatex(ammo, charsmax(ammo), "%L", id, LANG_KEY_STATE_INF);

// 	if (pev_valid(id))
// 		client_print(id, print_center, ammo);
// #endif
// #endif
// } 

public cm_buy_claymore(id)
{
	mines_buy(id, gMinesId);
}
//====================================================
// Chat command.
//====================================================
public cm_say_claymore(id)
{
	new said[32];
	read_argv(1, said, charsmax(said));
	
	if (equali(said,"/buy claymore") || equali(said,"/lm"))
	{
#if defined ZP_SUPPORT
		zp_items_force_buy(id, gZpWeaponId);
#else
		mines_buy(id, gMinesId);
#endif
	} else 
	if (equali(said, "claymore") || equali(said, "/claymore"))
	{
		const SIZE = 1024;
		new msg[SIZE + 1], len = 0;
		len += formatex(msg[len], SIZE - len, "<html><head><style>body{background-color:gray;color:white;} table{border-color:black;}</style></head><body>");
		len += formatex(msg[len], SIZE - len, "<p><b>Laser/TripMine Entity v%s</b></p>", VERSION);
		len += formatex(msg[len], SIZE - len, "<p>You can be setting the mine on the wall.</p>");
		len += formatex(msg[len], SIZE - len, "<p>That laser will give what touched it damage.</p>");
		len += formatex(msg[len], SIZE - len, "<p><b>Commands</b></p>");
		len += formatex(msg[len], SIZE - len, "<table border='1' cellspacing='0' cellpadding='10'>");
		len += formatex(msg[len], SIZE - len, "<tr><td>say</td><td><b>/buy claymore</b> or <b>/lm</td><td rowspan='2'>buying claymore</td></tr>");
		len += formatex(msg[len], SIZE - len, "<tr><td>console</td><td><b>buy_claymore</b></td></tr>");
		len += formatex(msg[len], SIZE - len, "<tr><tr><td rowspan='2'>bind</td><td><b>+setlaser</b></td><td>bind j +setlaser :using j set claymore on wall.</td></tr>");
		len += formatex(msg[len], SIZE - len, "<tr><td><b>+dellaser</b></td><td>bind k +dellaser :using k remove claymore.</td></tr>");
		len += formatex(msg[len], SIZE - len, "</table>");
		len += formatex(msg[len], SIZE - len, "</body></html>");
		show_motd(id, msg, "claymore Entity help");
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
	velocity_by_aim(id, 128, gDeployPos[id]);
	gDeployPos[id][2] = -128.0;

	xs_vec_add(gDeployPos[id], vOrigin, vTraceEnd);

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

	cp_must_ground(id);
	return false;
}

public MinesBreaked(iMinesId, iEnt, iAttacker)
{
	if (iMinesId != gMinesId) return HAM_IGNORED;
#if defined ZP_SUPPORT
	new szName[MAX_NAME_LENGTH];
	new addpoint = get_pcvar_num(gCvar[CVAR_FRAG_MONEY]);
	get_user_name(iAttacker, szName, charsmax(szName));
	zp_ammopacks_set(iAttacker, zp_ammopacks_get(iAttacker) + addpoint);
	zp_colored_print(0, "^4%s ^1earned^4 %i points ^1for destorying a claymore !", szName, addpoint);
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