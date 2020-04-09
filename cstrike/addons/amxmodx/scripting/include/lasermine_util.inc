// =====================================
//	Laser/Tripmine Entity functions
//
// 	by Aoi.Kagase
//
// =====================================

#if defined _lasermine_util_included
	#endinput
#endif
#define _lasermine_util_included
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
// CS Status Data.
#define cs_get_user_team(%1)		CsTeams:get_offset_value(%1, OFFSET_TEAM)
#define cs_set_user_team(%1,%2)		set_offset_value(%1, OFFSET_TEAM, %2)
#define cs_get_user_deaths(%1)		get_offset_value(%1, OFFSET_GET_DEATH)
#define cs_set_user_deaths(%1,%2)	set_offset_value(%1, OFFSET_SET_DEATH, %2)
#define cs_get_user_money(%1)		get_offset_value(%1, OFFSET_MONEY)
#define cs_set_user_money(%1,%2)	set_offset_value(%1, OFFSET_MONEY, %2)

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

// Remove Lasermine Entity Macro
#define remove_entity(%1)			engfunc(EngFunc_RemoveEntity, %1)

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
	POWERUP_SOUND			= 0,
	ACTIVATE_SOUND			,
	STOP_SOUND				,
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
// CVAR SETTINGS
//
enum _:CVAR_SETTING
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
enum int:PLAYER_DATA_INT
{
	PLAYER_DELAY_COUNT		= 0,
	PLAYER_HAVE_MINE		,
	PLAYER_MINE_SETTING		,
	PLAYER_DEPLOYED			,
}

enum Float:PLAYER_DATA_FLOAT
{
	PLAYER_MAX_SPEED		= 0,
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
new int:gPlayerInt[MAX_PLAYERS][PLAYER_DATA_INT];
new Float:gPlayerFloat[MAX_PLAYERS][PLAYER_DATA_FLOAT];

//====================================================
//  Player Data functions
//====================================================
stock set_user_delay_count		(id, int:value) 	{ gPlayerInt[id][PLAYER_DELAY_COUNT]	= int:value; }
stock set_user_have_mine		(id, int:value) 	{ gPlayerInt[id][PLAYER_HAVE_MINE]		= int:value; }
stock set_user_mine_deployed	(id, int:value)		{ gPlayerInt[id][PLAYER_DEPLOYED]		= int:value; }
stock set_user_deploy_state		(id, int:value)		{ gPlayerInt[id][PLAYER_MINE_SETTING]	= int:value; }
stock set_user_health			(id, Float:health)	{ health > 0 ? set_pev(id, pev_health, health) : user_kill(id, 1); }
stock set_user_frags			(id, int:frags)		{ set_pev(id, pev_frags, frags); }
stock save_user_max_speed		(id, Float:value)	{ gPlayerFloat[id][PLAYER_MAX_SPEED]	= Float:value; }
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
stock fm_get_user_frags			(id)				{ return pev(id, pev_frags);}
stock bool:fm_is_user_godmode	(id) 				{ return (pev(id, pev_takedamage) == DAMAGE_NO); }
stock bool:fm_is_user_alive		(id)				{ return (pev(id,pev_deadflag) == DEAD_NO);}
stock bool:fm_get_user_buyzone	(id)				{ return bool:(get_pdata_int(id, OFFSET_MAPZONE) & PLAYER_IN_BUYZONE);}
stock fm_get_entity_class_name	(id)
{
	new entityName[MAX_NAME_LENGTH];
	pev(id, pev_classname, entityName, charsmax(entityName));
	return entityName;
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

//====================================================
// Show Progress Bar.
//====================================================
stock show_progress(id, int:time, msg)
{
	if (pev_valid(id))
	{
		engfunc(EngFunc_MessageBegin, MSG_ONE, msg, {0,0,0}, id);
		write_short(time);
		message_end();
	}
}

//====================================================
// Hide Progress Bar.
//====================================================
stock hide_progress(id, msg)
{
	if (pev_valid(id))
	{
		engfunc(EngFunc_MessageBegin, MSG_ONE, msg, {0,0,0}, id);
		write_short(0);
		message_end();
	}
}

//====================================================
// Draw Spark
//====================================================
stock draw_spark(Float:origin[3])
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_SPARKS);
	engfunc(EngFunc_WriteCoord, origin[0]);
	engfunc(EngFunc_WriteCoord, origin[1]);
	engfunc(EngFunc_WriteCoord, origin[2]);
	message_end();
}

stock draw_spark_for_wall(const Float:vEndOrigin[3])
{
   	// Sparks
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
	return get_pdata_int(id, type);	
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
#endif
	}
	set_pdata_int(id, type, value);	
	return;
}

//====================================================
// Flashing Money Hud
//====================================================
stock flash_money_hud(id, value, msg)
{
	if (pev_valid(id))
	{
		// Send Money message to update player's HUD
		engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, msg, {0, 0, 0}, id);
		write_long(value);
		write_byte(1);	// Flash (difference between new and old money)
		message_end();
	}	
}


//====================================================
// Draw Laserline
//====================================================
stock draw_laser(const iEnt, /* const Float:vOrigin[3],*/ const Float:vEndOrigin[3], const tcolor[3], const width, const bright, const beam)
{
	// Draw Laser line message.
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(TE_BEAMENTPOINT);
	write_short(iEnt);
	// engfunc(EngFunc_WriteCoord, vOrigin[0]);
	// engfunc(EngFunc_WriteCoord, vOrigin[1]);
	// engfunc(EngFunc_WriteCoord, vOrigin[2]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]); //Random
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]); //Random
	engfunc(EngFunc_WriteCoord, vEndOrigin[2]); //Random
	write_short(beam);
	write_byte(0);	// framestart
	write_byte(0);	// framerate
	write_byte(0);	// Life
	write_byte(width);	// Width
	write_byte(0);	// wave/noise
	write_byte(tcolor[0]); // r
	write_byte(tcolor[1]); // g
	write_byte(tcolor[2]); // b
	write_byte(bright); // Brightness.
	write_byte(255);	// speed
	message_end();	
}

//====================================================
// Effect Explosion.
//====================================================
stock create_explosion(iEnt, boom)
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
	write_short(boom);
	write_byte(30);
	write_byte(15);
	write_byte(0);
	message_end();
}

//====================================================
// Stop Laser line.
//====================================================
stock stop_laserline(iEnt)
{
	// Laser line stop.
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(99); //99 = KillBeam
	write_short(iEnt);
	message_end();
}

//====================================================
// Explosion Damage.
//====================================================
stock create_explosion_damage(iEnt, iAttacker, Float:dmgMax, Float:radius)
{
	// Get given parameters
	
	new Float:vOrigin[3];
	pev(iEnt, pev_origin, vOrigin);

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
// show status text 
//====================================================
stock status_text(id, szText[], msg)
{
	engfunc(EngFunc_MessageBegin, MSG_ONE, msg, {0, 0, 0}, id);
	write_byte(0);
	write_string(szText);
	message_end();	
}

//====================================================
// Hit Shield Effect 
//====================================================
stock hit_shield(id, Float:dmg)
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
// Remove all Entity.
//====================================================
remove_all_entity(id, className[])
{
	new iEnt = -1;
	new entityName[MAX_NAME_LENGTH];
	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", className)))
	{
		if (!pev_valid(iEnt))
			continue;

		if (is_user_connected(id))
		{
			if (pev(iEnt, LASERMINE_OWNER) != id)
				continue;
			entityName = fm_get_entity_class_name(iEnt);
				
			if (equali(entityName, className))
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
