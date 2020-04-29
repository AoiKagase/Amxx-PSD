// =====================================
//	Laser/Tripmine Entity functions
//
// 	by Aoi.Kagase
//
// =====================================

#if defined _mines_util_included
	#endinput
#endif
#define _mines_util_included

#include <mines_const>

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
