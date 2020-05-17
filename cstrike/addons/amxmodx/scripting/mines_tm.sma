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
#define ENT_MODELS					"models/v_tripmine.mdl"
#define ENT_SOUND1					"weapons/mine_deploy.wav"
#define ENT_SOUND2					"weapons/mine_charge.wav"
#define ENT_SOUND3					"weapons/mine_activate.wav"
#define ENT_SPRITE1 				"sprites/laserbeam.spr"

//=====================================
//  MACRO AREA
//=====================================
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define PLUGIN 						"[M.P] Tripmine"
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"0.02"
#define CVAR_TAG					"mines_tm"

#define LANG_KEY_PLANT_WALL   		"TM_PLANT_WALL"
#define LANG_KEY_LONGNAME			"TM_LONG_NAME"

// ADMIN LEVEL
#define ADMIN_ACCESSLEVEL			ADMIN_LEVEL_H

#define ENT_CLASS_TRIP				"tripmine"

#define TRIPMINE_COUNT				pev_fuser1
#define TRIPMINE_POWERUP			pev_fuser2
#define TRIPMINE_BEAMTHINK			pev_fuser3
#define TRIPMINE_BEAMENDPOINT		pev_vuser1

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
	CVAR_LASER_VISIBLE      ,   	// Laser line Visiblity. 0 = off, 1 = on.
	CVAR_LASER_BRIGHT       ,   	// Laser line brightness.
	CVAR_LASER_WIDTH		,		// Laser line width.
	CVAR_LASER_COLOR        ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_TR     ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_CT     ,   	// Laser line color. 0 = team color, 1 = green
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
};

enum CVAR_VALUE
{
	VL_MAX_HAVE				,    	// Max having ammo.
	VL_START_HAVE			,    	// Start having ammo.
	VL_FRAG_MONEY   	    ,    	// Get money per kill.
	VL_COST         	    ,    	// Buy cost.
	VL_BUY_ZONE     	    ,    	// Stay in buy zone can buy.
	VL_LASER_DMG    	    ,    	// Laser hit Damage.
	VL_MAX_DEPLOY			,		// user max deploy.
	VL_TEAM_MAX     	    ,    	// Max deployed in team.
	VL_BUY_MODE     	    ,   	// Buy mode. 0 = off, 1 = on.
	VL_LASER_VISIBLE    	,   	// Laser line Visiblity. 0 = off, 1 = on.
	VL_LASER_BRIGHT     	,   	// Laser line brightness.
	VL_LASER_WIDTH			,		// Laser line width.
	VL_LASER_COLOR      	,   	// Laser line color. 0 = team color, 1 = green
	VL_MINE_GLOW        	,   	// Glowing tripmine.
	VL_MINE_GLOW_MODE   	,   	// Glowing color mode.
	VL_MINE_BROKEN			,		// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
	VL_DEATH_REMOVE			,		// Dead Player Remove Lasermine.
	VL_ALLOW_PICKUP			,		// allow pickup.

	Float:VL_LASER_ACTIVATE	,		// Waiting for put lasermine. (0 = no progress bar.)
	Float:VL_LASER_RANGE	,		// Laserbeam range.
	Float:VL_MINE_HEALTH    ,   	// Lasermine health. (Can break.)
	Float:VL_EXPLODE_RADIUS ,   	// Explosion Radius.
	Float:VL_EXPLODE_DMG    ,   	// Explosion Damage.

	VL_CBT              [4] ,  		// Can buy team. TR/CT/ALL
	VL_MINE_GLOW_CT     [13],  		// Glowing color for CT.
	VL_MINE_GLOW_TR    	[13],  		// Glowing color for T.
	VL_LASER_COLOR_TR   [13],  		// Laser line color. 0 = team color, 1 = green
	VL_LASER_COLOR_CT   [13],  		// Laser line color. 0 = team color, 1 = green
};


//====================================================
//  GLOBAL VARIABLES
//====================================================
new gCvar[CVAR_SETTING];
new gCvarValue[CVAR_VALUE];
new gBeam;
new gMinesId;

new gMinesData[COMMON_MINES_DATA];

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
	gCvar[CVAR_LASER_COLOR_TR] 	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_t"),			"0,255,255"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_LASER_COLOR_CT] 	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_ct"),			"0,255,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)

	gCvar[CVAR_LASER_BRIGHT]   	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_brightness"),		"255"		);	// laser line brightness. 0 to 255
	gCvar[CVAR_LASER_WIDTH]   	= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_width"),			"2"			);	// laser line width. 0 to 255
	gCvar[CVAR_LASER_RANGE]		= create_cvar(fmt("%s%s", CVAR_TAG, "_laser_range"),			"8192.0"	);	// Laser beam lange (float range.)

	// Mine design.
	gCvar[CVAR_MINE_HEALTH]    	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_health"),			"1"			);	// Tripmine Health. (Can break.)
	gCvar[CVAR_MINE_GLOW]      	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow"),				"1"			);	// Tripmine glowing. 0 = off, 1 = on.
	gCvar[CVAR_MINE_GLOW_MODE]  = create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_mode"),	"1"			);	// Mine glow coloer 0 = team color, 1 = green.
	gCvar[CVAR_MINE_GLOW_TR]  	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_t"),		"255,0,0"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_MINE_GLOW_CT]  	= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_ct"),		"0,0,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)
	gCvar[CVAR_MINE_BROKEN]		= create_cvar(fmt("%s%s", CVAR_TAG, "_mine_broken"),			"2"			);	// Can broken Mines.(0 = mines, 1 = Team, 2 = Enemy)
	gCvar[CVAR_EXPLODE_RADIUS] 	= create_cvar(fmt("%s%s", CVAR_TAG, "_explode_radius"),			"320.0"		);	// Explosion radius.
	gCvar[CVAR_EXPLODE_DMG]		= create_cvar(fmt("%s%s", CVAR_TAG, "_explode_damage"),			"100"		);	// Explosion radius damage.

	// Misc Settings.
	gCvar[CVAR_DEATH_REMOVE]	= create_cvar(fmt("%s%s", CVAR_TAG, "_death_remove"),			"0"			);	// Dead Player remove lasermine. 0 = off, 1 = on.
	gCvar[CVAR_LASER_ACTIVATE]	= create_cvar(fmt("%s%s", CVAR_TAG, "_activate_time"),			"1.0"		);	// Waiting for put lasermine. (int:seconds. 0 = no progress bar.)
	gCvar[CVAR_ALLOW_PICKUP]	= create_cvar(fmt("%s%s", CVAR_TAG, "_allow_pickup"),			"1"			);	// allow pickup mine. (0 = disable, 1 = it's mine, 2 = allow friendly mine, 3 = allow enemy mine!)

	create_cvar("mines_tripmine", VERSION, FCVAR_SERVER|FCVAR_SPONLY);

	bind_cvars();

	// Multi Language Dictionary.
	mines_register_dictionary("mines/mines_tm.txt");
	AutoExecConfig(true, "mines_cvars_tm", "mines");

	return PLUGIN_CONTINUE;
}

bind_cvars()
{

	bind_pcvar_num		(gCvar[CVAR_START_HAVE],	gCvarValue[VL_START_HAVE]);
	bind_pcvar_num		(gCvar[CVAR_MAX_HAVE],		gCvarValue[VL_MAX_HAVE]);
#if defined BIOHAZARD_SUPPORT
	bind_pcvar_num		(gCvar[CVAR_NOROUND],		gCvarValue[VL_NOROUND]);
#endif
	bind_pcvar_num		(gCvar[CVAR_MAX_DEPLOY],	gCvarValue[VL_MAX_DEPLOY]);
	bind_pcvar_num		(gCvar[CVAR_TEAM_MAX],		gCvarValue[VL_TEAM_MAX]);
	bind_pcvar_num		(gCvar[CVAR_BUY_MODE],		gCvarValue[VL_BUY_MODE]);
	bind_pcvar_num		(gCvar[CVAR_BUY_ZONE],		gCvarValue[VL_BUY_ZONE]);
	bind_pcvar_num		(gCvar[CVAR_COST],			gCvarValue[VL_COST]);
	bind_pcvar_num		(gCvar[CVAR_FRAG_MONEY],	gCvarValue[VL_FRAG_MONEY]);
 	bind_pcvar_num		(gCvar[CVAR_MINE_BROKEN],	gCvarValue[VL_MINE_BROKEN]);
	bind_pcvar_num		(gCvar[CVAR_ALLOW_PICKUP],	gCvarValue[VL_ALLOW_PICKUP]);
	bind_pcvar_num		(gCvar[CVAR_DEATH_REMOVE],	gCvarValue[VL_DEATH_REMOVE]);
	bind_pcvar_num		(gCvar[CVAR_MINE_GLOW],		gCvarValue[VL_MINE_GLOW]);
	bind_pcvar_num		(gCvar[CVAR_MINE_GLOW_MODE],gCvarValue[VL_MINE_GLOW_MODE]);

	bind_pcvar_num		(gCvar[CVAR_LASER_VISIBLE],	gCvarValue[VL_LASER_VISIBLE]); 	// Laser line Visiblity. 0 = off, 1 = on.
	bind_pcvar_num		(gCvar[CVAR_LASER_BRIGHT],	gCvarValue[VL_LASER_BRIGHT]);  	// Laser line brightness.
	bind_pcvar_num		(gCvar[CVAR_LASER_WIDTH],	gCvarValue[VL_LASER_WIDTH]);	// Laser line width.
	bind_pcvar_num		(gCvar[CVAR_LASER_COLOR],	gCvarValue[VL_LASER_COLOR]);  	// Laser line color. 0 = team color, 1 = green

	bind_pcvar_float	(gCvar[CVAR_LASER_RANGE],	gCvarValue[VL_LASER_RANGE]);	// Laserbeam range.
	bind_pcvar_float	(gCvar[CVAR_MINE_HEALTH],	gCvarValue[VL_MINE_HEALTH]);
	bind_pcvar_float	(gCvar[CVAR_LASER_ACTIVATE],gCvarValue[VL_LASER_ACTIVATE]);
	bind_pcvar_float	(gCvar[CVAR_EXPLODE_RADIUS],gCvarValue[VL_EXPLODE_RADIUS]);
	bind_pcvar_float	(gCvar[CVAR_EXPLODE_DMG],	gCvarValue[VL_EXPLODE_DMG]);

	bind_pcvar_string	(gCvar[CVAR_CBT], 			gCvarValue[VL_CBT], 			charsmax(gCvarValue[VL_CBT]));
	bind_pcvar_string	(gCvar[CVAR_MINE_GLOW_TR],	gCvarValue[VL_MINE_GLOW_TR],	charsmax(gCvarValue[VL_MINE_GLOW_TR]) - 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_MINE_GLOW_CT],	gCvarValue[VL_MINE_GLOW_CT],	charsmax(gCvarValue[VL_MINE_GLOW_CT]) - 1);// last comma - 1
	bind_pcvar_string	(gCvar[CVAR_LASER_COLOR_TR],gCvarValue[VL_LASER_COLOR_TR],  charsmax(gCvarValue[VL_LASER_COLOR_TR]) - 1);
	bind_pcvar_string	(gCvar[CVAR_LASER_COLOR_CT],gCvarValue[VL_LASER_COLOR_CT],  charsmax(gCvarValue[VL_LASER_COLOR_CT]) - 1);

	gMinesId 						= 	register_mines		(ENT_CLASS_TRIP, LANG_KEY_LONGNAME);

	gMinesData[BUY_TEAM]			=	get_team_code		(gCvarValue[VL_CBT]);
	gMinesData[GLOW_COLOR_TR]		=	get_cvar_to_color	(gCvarValue[VL_MINE_GLOW_TR]);
	gMinesData[GLOW_COLOR_CT]		=	get_cvar_to_color	(gCvarValue[VL_MINE_GLOW_CT]);

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

	register_mines_data(gMinesId, gMinesData, ENT_MODELS);



}

//====================================================
//  PLUGIN END
//====================================================
public mines_plugin_end()
{
}

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	precache_sound(ENT_SOUND1);
	precache_sound(ENT_SOUND2);
	precache_sound(ENT_SOUND3);
	precache_model(ENT_MODELS);
	gBeam = precache_model(ENT_SPRITE1);
	
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
	set_pev(iEnt, pev_classname, ENT_CLASS_TRIP);

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
	set_pev(iEnt, pev_health, gCvarValue[VL_MINE_HEALTH]);

	// set mine position
	set_mine_position(uID, iEnt);

	// Save results to be used later.
	set_pev(iEnt, MINES_OWNER, uID );
	set_pev(iEnt, MINES_TEAM, int:cs_get_user_team(uID));

	// Reset powoer on delay time.
	new Float:fCurrTime = get_gametime();
	set_pev(iEnt, TRIPMINE_POWERUP, fCurrTime + 2.5 );   
	set_pev(iEnt, MINES_STEP, POWERUP_THINK);
	set_pev(iEnt, TRIPMINE_COUNT, fCurrTime);
	set_pev(iEnt, TRIPMINE_BEAMTHINK, fCurrTime);

	// think rate. hmmm....
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.2 );

	// Power up sound.
	tm_play_sound(iEnt, SOUND_POWERUP);
}

//====================================================
// Set Lasermine Position.
//====================================================
set_mine_position(uID, iEnt)
{
	// Vector settings.
	new Float:vOrigin	[3],Float:vViewOfs	[3];
	new	Float:vNewOrigin[3],Float:vNormal	[3];
	new	Float:vTraceEnd	[3],Float:vEntAngles[3];

	// get user position.
	pev(uID, pev_origin, vOrigin);
	pev(uID, pev_view_ofs, vViewOfs);
	xs_vec_add(vOrigin, vViewOfs, vOrigin);  	

	velocity_by_aim(uID, 128, vTraceEnd);
	xs_vec_add( vTraceEnd, vOrigin, vTraceEnd );

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

	// Rotate tripmine.
	vector_to_angle(vNormal, vEntAngles);

	// set angle.
	set_pev(iEnt, pev_angles, vEntAngles);

	// set laserbeam end point position.
	set_laserend_postiion(iEnt, vNormal, vNewOrigin);
}

//====================================================
// Set Laserbeam End Position.
//====================================================
set_laserend_postiion(iEnt, Float:vNormal[3], Float:vNewOrigin[3])
{
	// Calculate laser end origin.
	new Float:vBeamEnd[3];
	new Float:vTracedBeamEnd[3];

	xs_vec_mul_scalar(vNormal, gCvarValue[VL_LASER_RANGE], vNormal );
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
	set_pev(iEnt, TRIPMINE_BEAMENDPOINT, vTracedBeamEnd);
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
	pev(iEnt, TRIPMINE_BEAMENDPOINT, vEnd);

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
			tm_play_sound(iEnt, SOUND_STOP);

			// effect explosion.
			mines_explosion(pev(iEnt, MINES_OWNER), iMinesId, iEnt);
		}
	}

	return;
}

mines_step_powerup(iEnt, Float:fCurrTime)
{
	static Float:fPowerupTime;
	pev(iEnt, TRIPMINE_POWERUP, fPowerupTime);
	// over power up time.
		
	if (fCurrTime > fPowerupTime)
	{
		// next state.
		set_pev(iEnt, MINES_STEP, BEAMUP_THINK);
		// activate sound.
		tm_play_sound(iEnt, SOUND_ACTIVATE);

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
	}

	// next state.
	set_pev(iEnt, MINES_STEP, BEAMBREAK_THINK);
	// Think time.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
}

mines_step_beambreak(iEnt, Float:vEnd[3], Float:fCurrTime)
{
	static iOwner;
	static iTarget;
	static trace;
	static Float:fFraction;
	static Float:vOrigin	[3];
	static Float:vHitPoint	[3];
	static Float:nextTime = 0.0;
	static Float:beamTime = 0.0;

	// Get this mine position.
	pev(iEnt, pev_origin, 			vOrigin);
	pev(iEnt, TRIPMINE_COUNT, 		nextTime);
	pev(iEnt, TRIPMINE_BEAMTHINK, 	beamTime);
	iOwner = pev(iEnt, MINES_OWNER);

	if (fCurrTime > beamTime)
	{
		// drawing spark.
		if (gCvarValue[VL_LASER_VISIBLE])
			draw_laserline(iEnt, vEnd);

		set_pev(iEnt, TRIPMINE_BEAMTHINK, fCurrTime + random_float(0.1, 0.2));
	}

	// create the trace handle.
	trace = create_tr2();

	fFraction	= 0.0;
	set_pev(iEnt, TRIPMINE_COUNT, get_gametime());

	// Trace line
	engfunc(EngFunc_TraceLine, vOrigin, vEnd, DONT_IGNORE_MONSTERS, iEnt, trace);
	{
		get_tr2(trace, TR_flFraction, fFraction);
		iTarget		= get_tr2(trace, TR_pHit);
		get_tr2(trace, TR_vecEndPos, vHitPoint);				
	}

	// Something has passed the laser.
	if (fFraction < 1.0)
	{
		// is valid hit entity?
		if (pev_valid(iTarget))
		{
			// is user?
			if (pev(iTarget, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER))
			{
				// is dead?
				if(is_user_alive(iTarget))
				{
					// Hit friend and No FF.
					if(mines_valid_takedamage(iOwner, iTarget))
					{
						// is godmode?
						if (get_user_godmode(iTarget))
						{
							// keep target id.
							set_pev(iEnt, pev_enemy, iTarget);
							// State change. to Explosing step.
							set_pev(iEnt, MINES_STEP, EXPLOSE_THINK);
						}
					}
				}
			}
		}
	}

	// free the trace handle.
	free_tr2(trace);

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
	new CsTeams:teamid  = CsTeams:pev(iEnt, MINES_TEAM);

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
	*/
	draw_laser(iEnt, vEndOrigin, gBeam, 0, 0, 2, gCvarValue[VL_LASER_WIDTH], 0, tcolor, gCvarValue[VL_LASER_BRIGHT], 255);
}

//====================================================
// Check: On the wall.
//====================================================
public CheckForDeploy(id, iMinesId)
{
	if (iMinesId != gMinesId) return false; 

	new Float:vTraceEnd	[3];
	new Float:vOrigin	[3],Float:vViewOfs[3];

	// Get potision.
	pev(id, pev_origin, vOrigin);
	pev(id, pev_view_ofs, vViewOfs);
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
	if (iMinesId != gMinesId) return HAM_IGNORED; 
#if defined ZP_SUPPORT
	zp_ammopacks_set(iAttacker, zp_ammopacks_get(iAttacker) +  gCvarValue[VL_FRAG_MONEY]);
	zp_colored_print(0, "^4%n ^1earned^4 %i points ^1for destorying a tripmine !", iAttacker, gCvarValue[VL_FRAG_MONEY]);
#endif
    return HAM_IGNORED;
}

//====================================================
// Play sound.
//====================================================
tm_play_sound(iEnt, iSoundType)
{
	switch (iSoundType)
	{
		case SOUND_POWERUP:
		{
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			emit_sound(iEnt, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_ACTIVATE:
		{
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, 1, 75);
		}
		case SOUND_STOP:
		{
			emit_sound(iEnt, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, SND_STOP, 75);
		}
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