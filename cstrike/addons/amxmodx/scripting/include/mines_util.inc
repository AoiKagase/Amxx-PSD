// =====================================
//	Mines Platform Functions
//
// 	by Aoi.Kagase
//
// =====================================

#if defined _mines_util_included
	#endinput
#endif
#define _mines_util_included

#include <mines_const>

//=====================================
//  Resource Setting AREA
//=====================================
#define ENT_SOUND				"items/gunpickup2.wav"
#define ENT_SOUND1				"debris/bustglass1.wav"
#define ENT_SOUND2				"debris/bustglass2.wav"
#define ENT_SOUND3				"items/gunpickup4.wav"
#define ENT_SPRITE 				"sprites/eexplo.spr"

#define LANG_KEY_REFER			"REFER"
#define LANG_KEY_BOUGHT       	"BOUGHT"
#define LANG_KEY_NO_MONEY     	"NO_MONEY"
#define LANG_KEY_NOT_ACCESS   	"NOT_ACCESS"
#define LANG_KEY_NOT_ACTIVE   	"NOT_ACTIVE"
#define LANG_KEY_NOT_HAVE     	"NOT_HAVE"
#define LANG_KEY_NOT_BUY      	"NOT_BUY"
#define LANG_KEY_NOT_BUYZONE  	"NOT_BUYZONE"
#define LANG_KEY_NOT_PICKUP   	"NOT_PICKUP"
#define LANG_KEY_MAX_DEPLOY   	"MAX_DEPLOY"
#define LANG_KEY_MAX_HAVE     	"MAX_HAVE"
#define LANG_KEY_MAX_PPL      	"MAX_PPL"
#define LANG_KEY_DELAY_SEC    	"DELAY_SEC"
#define LANG_KEY_STATE_AMMO   	"STATE_AMMO"
#define LANG_KEY_STATE_INF    	"STATE_INF"
#define LANG_KEY_NOROUND		"NO_ROUND"
#define LANG_KEY_ALL_REMOVE		"ALL_REMOVE"
#define LANG_KEY_GIVE_MINE		"TAKE_MINE"
#define LANG_KEY_REMOVE_SPEC	"REMOVE_SPEC"
#define LANG_KEY_MINE_HUD		"MINE_HUD_MSG"
#define LANG_KEY_NOT_BUY_TEAM 	"NOT_BUY_TEAM"
#define LANG_KEY_MENU_TITLE		"MENU_TITLE"
#define LANG_KEY_SUB_MENU_TITLE	"SUBM_TITLE"
#define LANG_KEY_MENU_BUY		"MENU_BUY"
#define LANG_KEY_MENU_DEPLOY	"MENU_DEPLOY"
#define LANG_KEY_MENU_PICKUP	"MENU_PICKUP"
#define LANG_KEY_MENU_EXPLOSION	"MENU_EXPLOSION"
#define LANG_KEY_MENU_SELECT	"MENU_SELECTED"

// Client Print Command Macro.
#define cp_debug(%1)				client_print_color(%1, %1, "^4[Mines Debug] ^1Can't Create Entity")
#define cp_not_active(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY_NOT_ACTIVE, CHAT_TAG)
#define cp_not_access(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY_NOT_ACCESS, CHAT_TAG)
#define cp_delay_time(%1,%2)		client_print_color(%1, %1, "%L", %1, LANG_KEY_DELAY_SEC,	CHAT_TAG, %2)
#define cp_bought(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_BOUGHT,		CHAT_TAG)
#define	cp_no_money(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NO_MONEY,		CHAT_TAG, get_long_name(%1, iMinesId), cost)
#define cp_dont_have(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_HAVE,		CHAT_TAG, get_long_name(%1, iMinesId))
#define cp_cant_buy(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUY,		CHAT_TAG)
#define cp_buyzone(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUYZONE,	CHAT_TAG)
#define cp_cant_buy_team(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUY_TEAM,	CHAT_TAG, get_long_name(%1, iMinesId))
#define cp_cant_pickup(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_PICKUP,	CHAT_TAG)
#define cp_maximum_deployed(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_DEPLOY,	CHAT_TAG)
#define cp_have_max(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_HAVE,		CHAT_TAG, get_long_name(%1, iMinesId))
#define cp_many_ppl(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_PPL,		CHAT_TAG)
#define cp_noround(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOROUND, 		CHAT_TAG)
#define cp_all_remove(%1,%2,%3)		client_print_color(%1, %1, "%L", %1, LANG_KEY_ALL_REMOVE,	CHAT_TAG, %2, %3)
#define cp_gave(%1,%2)				client_print_color(0, 0, "%L", 0, LANG_KEY_GIVE_MINE,	CHAT_TAG, 0, get_long_name(%2, iMinesId))
#define cp_remove_spec(%1,%2)		client_print_color(%1, %1, "%L", %1, LANG_KEY_REMOVE_SPEC,	CHAT_TAG, %2)

//====================================================
//  Player Data functions.
//====================================================
#define mines_get_user_deploy_state(%1)		gCPlayerData[%1][PL_STATE_DEPLOY]
#define mines_set_user_deploy_state(%1,%2)	gCPlayerData[%1][PL_STATE_DEPLOY] = %2
#define mines_load_user_max_speed(%1)		gCPlayerData[%1][PL_MAX_SPEED]
#define mines_save_user_max_speed(%1,%2)	gCPlayerData[%1][PL_MAX_SPEED] = Float:%2

enum _:FORWARDER
{
	FWD_SET_ENTITY_SPAWN,
	FWD_PUTIN_SERVER,
	FWD_CHECK_DEPLOY,
	FWD_CHECK_PICKUP,
	FWD_CHECK_BUY,
	FWD_DISCONNECTED,
	FWD_MINES_THINK,
	FWD_MINES_BREAKED,
	FWD_MINES_PICKUP,
	FWD_REMOVE_ENTITY,
	FWD_PLUGINS_END,
	FWD_HOLOGRAM,
};

new Array:gMinesClass;
new Array:gPlayerData	[MAX_PLAYERS];
new Array:gMinesLongName;
new Array:gMinesParameter;
new Array:gMinesModels;
new gForwarder			[FORWARDER];
new gCPlayerData		[MAX_PLAYERS][COMMON_PLAYER_DATA];
//====================================================
// Function: Count to deployed in team.
//====================================================
stock int:mines_get_team_deployed_count(id, iMinesId, plData[PLAYER_DATA])
{
	new int:i;
	new int:count;
	new int:num;
	new team[3] = '^0';
	new players[MAX_PLAYERS];

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

	// Count your team deployed mines.
	count = int:0;
	for(i = int:0;i < num;i++)
	{
#if AMXX_VERSION_NUM > 182
		ArrayGetArray(gPlayerData[players[i]], iMinesId, plData, sizeof(plData));
#else
		ArrayGetArray(gPlayerData[players[i]], iMinesId, plData);
#endif
		count += plData[PL_COUNT_DEPLOYED];
	}

	return count;
}

//====================================================
// Function: Reset Have mines.
//====================================================
stock mines_reset_have_mines(id)
{
	new plData[PLAYER_DATA];
	for(new i = 0; i < ArraySize(gMinesClass); i++)
	{
#if AMXX_VERSION_NUM > 182
		ArrayGetArray(gPlayerData[id], i, plData, sizeof(plData));
#else
		ArrayGetArray(gPlayerData[id], i, plData);
#endif
		// reset deploy count.
		plData[PL_COUNT_DEPLOYED]	= int:0;
		// reset hove mines.
		plData[PL_COUNT_HAVE_MINE]	= int:0;

#if AMXX_VERSION_NUM > 182
		ArraySetArray(gPlayerData[id], i, plData, sizeof(plData));
#else
		ArraySetArray(gPlayerData[id], i, plData);
#endif
	}
}

//====================================================
// Function: Remove All Mines (for id).
//====================================================
stock mines_remove_all_mines(id)
{
	static minesData[COMMON_MINES_DATA];
	new result = false;

	for(new i = 0; i < ArraySize(gMinesClass); i++)
	{
#if AMXX_VERSION_NUM > 182
		ArrayGetArray(gMinesParameter, i, minesData, sizeof(minesData));
#else
		ArrayGetArray(gMinesParameter, i, minesData);
#endif
		// Dead Player remove mines.
		if (minesData[DEATH_REMOVE])
		{
			result |= mines_remove_all_entity_main(id, i);
		}
	}
	return result;
}

//====================================================
// Buy mines.
//====================================================
stock mines_buy_mine(id, iMinesId)
{	
	if (!CheckBuyMines(id, iMinesId))
		return PLUGIN_CONTINUE;
	static plData[PLAYER_DATA];
	static minesData[COMMON_MINES_DATA];
#if AMXX_VERSION_NUM > 182
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));
#else
	ArrayGetArray(gMinesParameter, iMinesId, minesData);
#endif
	new cost = minesData[BUY_PRICE];
	cs_set_user_money(id, cs_get_user_money(id) - cost);

#if AMXX_VERSION_NUM > 182
	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));
#else
	ArrayGetArray(gPlayerData[id], iMinesId, plData);
#endif
	plData[PL_COUNT_HAVE_MINE]++;
#if AMXX_VERSION_NUM > 182
	ArraySetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));
#else
	ArraySetArray(gPlayerData[id], iMinesId, plData);
#endif

	cp_bought(id);

	emit_sound(id, CHAN_ITEM, ENT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	show_ammo(id, iMinesId);

	return PLUGIN_HANDLED;
}

//====================================================
// Function: Remove All Mines (for id+iMinesId).
//====================================================
stock mines_remove_all_entity_main(id, iMinesId)
{
	static plData[PLAYER_DATA];
	static sClassName[MAX_CLASS_LENGTH];
	new result = false;
#if AMXX_VERSION_NUM > 182
	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));
#else
	ArrayGetArray(gPlayerData[id], iMinesId, plData);
#endif

	if (plData[PL_COUNT_DEPLOYED] > int:0)
		result = true;

	ArrayGetString(gMinesClass, iMinesId, sClassName, charsmax(sClassName));
	mines_remove_all_entity(id, sClassName);

	// reset deploy count.
	plData[PL_COUNT_DEPLOYED] = int:0;
#if AMXX_VERSION_NUM > 182
	ArraySetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));
#else
	ArraySetArray(gPlayerData[id], iMinesId, plData);
#endif
	return result;
}

//====================================================
// Check: Buy Mines
//====================================================
stock bool:CheckBuyMines(id, iMinesId)
{
	static minesData[COMMON_MINES_DATA];
	static plData[PLAYER_DATA];
#if AMXX_VERSION_NUM > 182
	ArrayGetArray(gMinesParameter, iMinesId, minesData, sizeof(minesData));
	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));
#else
	ArrayGetArray(gMinesParameter, iMinesId, minesData);
	ArrayGetArray(gPlayerData[id], iMinesId, plData);
#endif

	// Check common.
	if (!CheckCommon(id, plData))
		return false;

	new buymode	= 	minesData[BUY_MODE];
	new maxhave	=	minesData[AMMO_HAVE_MAX];
	new cost	= 	minesData[BUY_PRICE];
	new buyzone	=	minesData[BUY_ZONE];

	// Buy mode ON?
	if (buymode)
	{
		// Can this team buying?
		if (!CheckTeam(id, minesData))
		{
			cp_cant_buy_team(id);
			return false;
		}

		// Have Max?
		if (plData[PL_COUNT_HAVE_MINE] >= int:maxhave)
		{
			cp_have_max(id);
			return false;
		}

		// buyzone area?
		if (buyzone && !cs_get_user_buyzone(id))
		{
			cp_buyzone(id);
			return false;
		}

		// Have money?
		if (cs_get_user_money(id) < cost)
		{
			cp_no_money(id);
			return false;
		}

	}
	else
	{
		cp_cant_buy(id);
		return false;
	}

	return true;
}

stock get_long_name(id, iMinesId)
{
	new sLongName[MAX_NAME_LENGTH];
	ArrayGetString(gMinesLongName, iMinesId, sLongName, charsmax(sLongName));
	formatex(sLongName, charsmax(sLongName), "%L", id, sLongName);
	return sLongName;
}
//====================================================
// Check: Can use this Team.
//====================================================
stock bool:CheckTeam(id, minesData[COMMON_MINES_DATA])
{
	new CsTeams:team;

	team = CsTeams:minesData[BUY_TEAM];

	// Cvar setting equal your team? Not.
	if(team != CS_TEAM_UNASSIGNED && team != cs_get_user_team(id))
		return false;

	return true;
}

//====================================================
// Check: Max Deploy.
//====================================================
stock bool:CheckMaxDeploy(id, iMinesId, plData[PLAYER_DATA], minesData[COMMON_MINES_DATA])
{
	new max_have 	= minesData[AMMO_HAVE_MAX];
	new team_max 	= minesData[DEPLOY_TEAM_MAX];
	new team_count 	= mines_get_team_deployed_count(id, iMinesId, plData);

#if AMXX_VERSION_NUM > 182
	ArrayGetArray(gPlayerData[id], iMinesId, plData, sizeof(plData));
#else
	ArrayGetArray(gPlayerData[id], iMinesId, plData);
#endif
	// Max deployed per player.
	if (plData[PL_COUNT_DEPLOYED] >= int:max_have)
	{
		cp_maximum_deployed(id);
		return false;
	}

	// Max deployed per team.
	if (team_count >= team_max)
	{
		cp_many_ppl(id);
		return false;
	}

	return true;
}

//====================================================
// Remove all Entity.
//====================================================
stock mines_remove_all_entity(id, className[])
{
	new iEnt = -1;
	new steamid[MAX_AUTHID_LENGTH];
	new sAuthid[MAX_AUTHID_LENGTH];
	get_user_authid(id, sAuthid, charsmax(sAuthid));

	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", className)))
	{
		if (!pev_valid(iEnt))
			continue;

		if (pev(iEnt, MINES_OWNER) == id)
		{
			pev(iEnt, pev_netname, steamid, charsmax(steamid));
			if (equali(sAuthid, steamid))
			{
				// mines_play_sound(iEnt, SOUND_STOP);
				mines_remove_entity(iEnt);
			}
		}
	}
}

stock mines_remove_entity(iEnt)
{
	new iReturn;
	ExecuteForward(gForwarder[FWD_REMOVE_ENTITY], iReturn, iEnt);
	mines_stop_laserline(iEnt);
	engfunc(EngFunc_RemoveEntity, iEnt);
}

stock mines_all_explosion(id, iMinesId)
{
	new iEnt = -1;
	new steamid[MAX_AUTHID_LENGTH];
	new sAuthid[MAX_AUTHID_LENGTH];
	new className[MAX_CLASS_LENGTH];
	get_user_authid(id, sAuthid, charsmax(sAuthid));
	ArrayGetString(gMinesClass, iMinesId, className, charsmax(className));

	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", className)))
	{
		if (!pev_valid(iEnt))
			continue;

		if (pev(iEnt, MINES_OWNER) == id)
		{
			pev(iEnt, pev_netname, steamid, charsmax(steamid));
			if (equali(sAuthid, steamid))
			{
				set_pev(iEnt, MINES_STEP, EXPLOSE_THINK);
			}
		}
	}	
}

//====================================================
// Show Progress Bar.
//====================================================
stock mines_show_progress(id, int:time, msg)
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
stock mines_hide_progress(id, msg)
{
	if (pev_valid(id))
	{
		engfunc(EngFunc_MessageBegin, MSG_ONE, msg, {0,0,0}, id);
		write_short(0);
		message_end();
	}
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
#if defined UL_MONEY_SUPPORT
	if (type == OFFSET_MONEY)
	{
		return cs_set_user_money_ul(id, value);
	}
#endif
	set_pdata_int(id, type, value);	
	return;
}

//====================================================
// Flashing Money Hud
//====================================================
stock mines_flash_money_hud(id, value, msg)
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
// Effect Explosion.
//====================================================
stock mines_create_explosion(iEnt, boom)
{
	// Stop laser line.
	mines_stop_laserline(iEnt);

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
stock mines_stop_laserline(iEnt)
{
	// Laser line stop.
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(TE_KILLBEAM); //99 = KillBeam
	write_short(iEnt | 0x1000);
	message_end();
}

//====================================================
// Explosion Damage.
//====================================================
stock mines_create_explosion_damage(iEnt, iAttacker, Float:dmgMax, Float:radius)
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
	new tClassName[MAX_NAME_LENGTH];
	new iClassName[MAX_NAME_LENGTH];
	// Calculate falloff
	new Float:falloff;
	if (radius > 0.0)
		falloff = dmgMax / radius;
	else
		falloff = 1.0;
	
	pev(iEnt, pev_classname, iClassName, charsmax(iClassName));

	// Find monsters and players inside a specifiec radius
	while((rEnt = engfunc(EngFunc_FindEntityInSphere, rEnt, vOrigin, radius)) != 0)
	{
		// is valid entity? no to continue.
		if (!pev_valid(rEnt)) 
			continue;

		pev(rEnt, pev_classname, tClassName, charsmax(tClassName));
		if (!equali(tClassName, iClassName))
		{
			// Entity is not a player or monster, ignore it
			if (!(pev(rEnt, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
				continue;
		}

		// is alive?
		if (!is_user_alive(rEnt))
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
			if (!equali(iClassName, tClassName))
			{
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
stock mines_show_status_text(id, szText[], msg)
{
	engfunc(EngFunc_MessageBegin, MSG_ONE, msg, {0, 0, 0}, id);
	write_byte(0);
	write_string(szText);
	message_end();	
}
