#if defined _mines_natives_included
    #endinput
#endif
#define _mines_natives_included 
#include <mines_const>

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib mines_natives
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib mines_natives
	#endif
#else
	#pragma library mines_natives
#endif

//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 200
	#assert "AMX Mod X v1.10.0 or greater library required!"
#endif

native register_mines(classname[MAX_CLASS_LENGTH], minesData[COMMON_MINES_DATA], langKey[MAX_NAME_LENGTH]);

native mines_progress_deploy(id, iMinesId);
native mines_progress_pickup(id, iMinesId);
native mines_progress_stop(id);
native mines_buy(id, iMinesId);
native mines_explosion(id, iMinesId, iEnt);
native mines_valid_takedamage(iAttacker, iTarget);
native mines_register_dictionary(path[]);

forward mines_entity_spawn_settings(iEnt, uID, iMinesId);
forward mines_client_putinserver(id);
forward	mines_client_disconnected(id);
forward	mines_plugin_end();
forward mines_remove_entity(iEnt);

forward	CheckForDeploy(id, iMinesId);
forward	CheckForPickup(id, iMinesId);
forward	CheckForBuy(id, iMinesId);
forward	MinesPickup(id, iMinesId, target);
forward	MinesThink(iEnt, iMinesId);
forward MinesBreaked(iMinesId, iEnt, iAttacker);

stock mines_spark_wall(Float:vEndOrigin[3])
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

stock mines_spark(Float:vEndOrigin[3])
{
	get_array_f(1, vEndOrigin, sizeof(vEndOrigin));
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_SPARKS);
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[2]);
	message_end();
}

// r = 0, g = 1, b = 2
stock get_color(src, rgb)
{
    src >>= ((rgb * 0x08));
    return (src & 0xFF);
}

stock set_color(r, g, b)
{
    new color = r;
    color |= (g << 8);
    color |= (b << 16);
    return color;
}

stock CsTeams:get_team_code(arg[4])
{
    new CsTeams:team;
	// Terrorist
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "Z")  || equali(arg, "Zombie"))
#else
	if(equali(arg, "TR") || equali(arg, "T"))
#endif
		team = CS_TEAM_T;
	else
	// Counter-Terrorist
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "H") || equali(arg, "Human"))
#else
	if(equali(arg, "CT"))
#endif
		team = CS_TEAM_CT;
	else
	// All team.
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "ZH") || equali(arg, "HZ") || equali(arg, "ALL"))
#else
	if(equali(arg, "ALL"))
#endif
		team = CS_TEAM_UNASSIGNED;
	else
		team = CS_TEAM_UNASSIGNED;

    return team;
}

stock get_cvar_to_color(args[13])
{
	new i = 0, n = 0, iPos = 0;
	new values[3];
	new sSplit		[20];
	new sSplitLen = charsmax(sSplit);

	formatex(args, charsmax(args), "%s%s", args, ",");
	while((i = split_string(args[iPos += i], ",", sSplit, sSplitLen)) != -1 && n < sizeof(values))
	{
		values[n++] = str_to_num(sSplit);
	}
	return set_color(values[0], values[1], values[2]);
}

stock mines_glow(iEnt, minesData[COMMON_MINES_DATA])
{
	// Glow mode.
	if (minesData[GLOW_ENABLE])
	{
		new Float:tcolor[3];
		// Color setting.
		if (!minesData[GLOW_MODE])
		{
			// Team color.
			switch (CsTeams:pev(iEnt, MINES_TEAM))
			{
				case CS_TEAM_T:
					for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(minesData[GLOW_COLOR_TR], i));
				case CS_TEAM_CT:
					for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(minesData[GLOW_COLOR_CT], i));
				default:
				{
					tcolor[0] = 0.0;
					tcolor[1] = 255.0;
					tcolor[2] = 0.0;
				}
			} 
		}
		else
		{
			tcolor[0] = 0.0;
			tcolor[1] = 255.0;
			tcolor[2] = 0.0;
		}

		set_pev(iEnt, pev_renderfx, 	kRenderFxGlowShell);
		set_pev(iEnt, pev_rendercolor,	tcolor);
		set_pev(iEnt, pev_rendermode, 	kRenderNormal);
		set_pev(iEnt, pev_renderamt, 	float(5));
	}
	return PLUGIN_CONTINUE;
}

