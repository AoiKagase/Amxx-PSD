
    #include <amxmodx>
    #include <fakemeta>
    #include <weaponmod_stocks>
    
    
    #define Plugin  "WPN Shock Rifle"
    #define Version "1.0.0"
    #define Author  "Arkshine"


    /* - - -
     |  Weapon information   |
                       - - - */
        new
            gs_WpnName [] = "Shock Rifle",
            gs_WpnShort[] = "shockrifle";

    /* - - -
     |  Weapon models  |
                 - - - */
        new
            gs_Model_P[] = "models/p_shock.mdl",
            gs_Model_V[] = "models/v_shock.mdl",
            gs_Model_W[] = "models/w_shock.mdl";
    
    /* - - -
     |  Weapon sounds  |
                 - - - */
        new const
            gs_ShockDraw     [] = "weapons/shock_draw.wav",
            gs_ShockFire     [] = "weapons/shock_fire.wav",
            gs_ShockImpact   [] = "weapons/shock_impact.wav",
            gs_ShockRecharge [] = "weapons/shock_recharge.wav",
            gs_ShockDischarge[] = "weapons/shock_discharge.wav";
            
    /* - - -
     |    Sequence   |
               - - - */
        enum
        {
            shock_idle1,
            shock_fire,
            shock_draw,
            shock_holster,
            shock_idle3
        }
        
    /* - - -
     |    Others stuffs   |
                    - - - */
        #define MAX_CLIENTS 32
        #define FCVAR_FLAGS ( FCVAR_SERVER | FCVAR_SPONLY | FCVAR_EXTDLL | FCVAR_UNLOGGED )
        
        #define HEAD_IN_WATER 3
        #define FFADE_IN 0x0000

        // --| Used fo readability.
        enum _:Coord_e { Float:x, Float:y, Float:z };
        enum _:Angle_e { Float:pitch, Float:yaw, Float:roll };
        
        enum ( <<= 1 ) { angles = 1, v_angle, punchangle };
        
        enum
        {
            Red,
            Green, 
            Blue
        };
        
        new Float:gf_TimeWeaponIdle[ MAX_CLIENTS + 1 ];
        new Float:gf_RechargeTime  [ MAX_CLIENTS + 1 ];

        new gi_Weapon         [ MAX_CLIENTS + 1 ];
        
        new gi_Beam;
        new gi_WeaponId;
        new gi_MsgScreenFade;
        new gi_ShockClass;
        
    /* - - -
     |    Macro   |
            - - - */
        #define VectorSubtract(%1,%2,%3) ( %3[ x ] = %1[ x ] - %2[ x ], %3[ y ] = %1[ y ] - %2[ y ], %3[ z ] = %1[ z ] - %2[ z ] )
        #define VectorAdd(%1,%2,%3)      ( %3[ x ] = %1[ x ] + %2[ x ], %3[ y ] = %1[ y ] + %2[ y ], %3[ z ] = %1[ z ] + %2[ z ] )
        #define VectorCopy(%1,%2)        ( %2[ x ] = %1[ x ],  %2[ y ] = %1[ y ], %2[ z ] = %1[ z ] )
        #define VectorScale(%1,%2,%3)    ( %3[ x ] = %2 * %1[ x ], %3[ y ] = %2 * %1[ y ], %3[ z ] = %2 * %1[ z ] )
        #define VectorLength(%1)         ( floatsqroot ( %1[ x ] * %1[ x ] + %1[ y ] * %1[ y ] + %1[ z ] * %1[ z ] ) )
        #define VectorMA(%1,%2,%3,%4)    ( %4[ x ] = %1[ x ] + %2 * %3[ x ], %4[ y ] = %1[ y ] + %2 * %3[ y ], %4[ z ] = %1[ z ] + %2 * %3[ z ] )

        #if !defined charsmax
            #define charsmax(%1)  ( sizeof ( %1 ) - 1 )
        #endif
        
        #define message_begin_f(%1,%2,%3) ( engfunc ( EngFunc_MessageBegin, %1, %2, %3 ) )
        #define write_coord_f(%1)         ( engfunc ( EngFunc_WriteCoord, %1 ) )
    
    
    public plugin_precache ()
    {
        //  -- Weapon models
        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );
        precache_model ( gs_Model_W );
        
        // -- Weapon sounds
        precache_sound ( gs_ShockDraw );
        precache_sound ( gs_ShockFire );
        precache_sound ( gs_ShockImpact );
        precache_sound ( gs_ShockRecharge );
        precache_sound ( gs_ShockDischarge );
        
        precache_model ( "models/shock_effect.mdl" );
        gi_Beam = precache_model ( "sprites/plasma.spr" );
    }
    
    
    public plugin_init ()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_sr_version", Version, FCVAR_FLAGS );

        register_forward ( FM_PlayerPreThink, "Forward_PreThink" );
        register_forward ( FM_Touch, "Forward_Touch" );
    }


    public plugin_cfg ()
    {
        gi_ShockClass    = engfunc ( EngFunc_AllocString, "info_target" );
        gi_MsgScreenFade = get_user_msgid ( "ScreenFade" );
        
        CreateWeapon ();
    }
    
    
    public client_putinserver ( id )
    {
        gf_TimeWeaponIdle[ id ] = 0.0;
        gf_RechargeTime  [ id ] = 0.0;
    }
    
    
    CreateWeapon ()
    {
        new i_Weapon_id = wpn_register_weapon ( gs_WpnName, gs_WpnShort );

        if ( i_Weapon_id == -1 )
        {
            return;
        }

        wpn_set_string ( i_Weapon_id, wpn_viewmodel  , gs_Model_V );
        wpn_set_string ( i_Weapon_id, wpn_weaponmodel, gs_Model_P );
        wpn_set_string ( i_Weapon_id, wpn_worldmodel , gs_Model_W );

        wpn_register_event ( i_Weapon_id, event_attack1, "Shockrifle_PrimaryAttack" );
        wpn_register_event ( i_Weapon_id, event_draw   , "Shockrifle_Deploy"  );
        wpn_register_event ( i_Weapon_id, event_hide   , "Shockrifle_Holster" );

        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, 0.25 );
        wpn_set_float ( i_Weapon_id, wpn_run_speed, 250.0 );

        wpn_set_integer ( i_Weapon_id, wpn_ammo1, 15 );
        wpn_set_integer ( i_Weapon_id, wpn_count_bullets2, 0 ); 
        wpn_set_integer ( i_Weapon_id, wpn_cost, 2500 );

        gi_WeaponId = i_Weapon_id;
    }
    
    
    public Shockrifle_PrimaryAttack ( id )
    {
        if ( IsWeaponEmpty ( id ) )
        {
            return PLUGIN_HANDLED;
        }
        
        if ( pev ( id, pev_flags ) == HEAD_IN_WATER )
        {
            wpn_kill_user ( gi_WeaponId, id, id, 0, DMG_SHOCK );
            FX_Screenfade ( id, { 201, 236, 255 }, 2.0, 0.5, 128, FFADE_IN );
            
            return PLUGIN_HANDLED;
        }

        Shockrifle_Fire ( id );

        return PLUGIN_CONTINUE;
    }

    
    public Shockrifle_Deploy ( id )
    {
        wpn_playanim ( id, shock_draw );
    }
    

    public Shockrifle_Holster ( id )
    {
        wpn_playanim ( id, shock_holster );

        new i_Weapon = wpn_has_weapon ( id, gi_WeaponId );
        new i_Ammo1 = wpn_get_userinfo ( id, usr_wpn_ammo1, i_Weapon );

        if ( !i_Ammo1 )
        {
            wpn_set_userinfo ( id, usr_wpn_ammo1, i_Weapon, i_Ammo1 + 1 );
        }
    }
    
    
    public Forward_Touch ( const i_Ent, const i_Other )
    {
        if ( pev ( i_Ent, pev_iuser1 ) )
        {
            set_pev ( i_Ent, pev_iuser1, 0 );
            
            static Float:f_TakeDamage; pev ( i_Other, pev_takedamage, f_TakeDamage );
            
            if ( f_TakeDamage )
            {
                
            }
            
            // FX_Sparks ( i_Ent );
            // ShockExplode( i_Ent );
        }
    }
    
  
    public Forward_PreThink ( id )
    {
        if ( is_user_alive ( id ) && wpn_uses_weapon ( id, gi_WeaponId ) )
        {
            Shockrifle_Reload ( id );
            Shockrifle_Idle ( id );
        }
    }
    
    
    Shockrifle_Fire ( const id )
    {
        Shockrifle_FireEffect ( id );
        emit_sound ( id, CHAN_ITEM, gs_ShockFire, random_float ( 0.95, VOL_NORM ), ATTN_NORM, 0, 93 + random_num ( 0, 15 ) );
        
        static Float:vf_AngleAim[ Angle_e ], Float:vf_Source[ Coord_e ];
        static Float:vf_Forward [ Coord_e ], Float:f_Time, i_Shock;
        
        UTIL_MakeVector ( id, v_angle + punchangle, vf_AngleAim );
        UTIL_GetStartPosition ( id, 16.0, 16.0, -12.0, vf_Source );
        
        vf_AngleAim[ pitch ] = -vf_AngleAim[ pitch ];
        
        if ( ShockCreate ( id, vf_Source, vf_AngleAim, i_Shock ) )
        {
            ShockSpawn ( id, i_Shock );
        
            global_get ( glb_v_forward, vf_Forward );
            VectorScale ( vf_Forward, 1500.0, vf_Forward );
            
            set_pev ( i_Shock, pev_velocity, vf_Forward );
        }
        
        f_Time = get_gametime ();
        
        gf_RechargeTime[ id ] = f_Time + 0.5;
        wpn_set_userinfo ( id, usr_wpn_ammo1, gi_Weapon[ id ],  GetAmmo ( id, usr_wpn_ammo1 ) - 1 );
        
        if ( gf_RechargeTime[ id ] < f_Time )
        {
            gf_RechargeTime[ id ] = f_Time + 0.25;
        }
        
        gf_TimeWeaponIdle[ id ] = f_Time + 0.5;
    }
    
    
    Shockrifle_Reload ( const id )
    {
        if ( !gf_RechargeTime[ id ] )
        {
            return;
        }
        
        if ( ( gi_Weapon[ id ] = wpn_has_weapon ( id, gi_WeaponId ) ) == -1 )
        {
            return;
        }
        
        static i_Ammo1;
        
        if ( ( i_Ammo1 = GetAmmo ( id, usr_wpn_ammo1 ) ) >= 10 )
        {
            gf_RechargeTime[ id ] = 0.0;
            return;
        }

        while ( i_Ammo1 < 10 && gf_RechargeTime[ id ] < get_gametime () )
        {
            emit_sound ( id, CHAN_WEAPON, gs_ShockRecharge, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
            
            i_Ammo1 = GetAmmo ( id, usr_wpn_ammo1 );
            wpn_set_userinfo ( id, usr_wpn_ammo1, gi_Weapon[ id ], i_Ammo1 + 1 );

            gf_RechargeTime[ id ] += 0.7;
        }
    }

        
    Shockrifle_FireEffect ( const id )
    {
        UTIL_SetAnimation ( id, shock_fire, 2 );

        FX_BeamEnt ( id | 0x2000, id | 0x1000, gi_Beam, 1, 8, 50, 200, 6, 0, 10, { 200, 200, 255 } );
        FX_BeamEnt ( id | 0x3000, id | 0x1000, gi_Beam, 1, 8, 50, 200, 6, 0, 10, { 200, 200, 255 } );
        FX_BeamEnt ( id | 0x4000, id | 0x1000, gi_Beam, 1, 8, 50, 200, 6, 0, 10, { 200, 200, 255 } );
        
        emit_sound ( id, CHAN_WEAPON, gs_ShockFire, VOL_NORM, ATTN_NORM, 0, 93 + random_num ( 0, 15 ) );
        emit_sound ( id, CHAN_ITEM, gs_ShockRecharge, random_float ( 0.95, VOL_NORM ), ATTN_NORM, 0, 93 + random_num ( 0, 15 ) );
        
        UTIL_SetAnimation ( id, shock_fire, 1 );
        UTIL_PunchAngle ( id, -2.0 );
    }
    
    
    ShockExplode ( const i_Ent )
    {
        // BlastOff ();
        
        emit_sound ( i_Ent, CHAN_BODY, gs_ShockImpact, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        FX_DynamicLight ( i_Ent );

        static i_Owner; i_Owner = ( pev ( i_Ent, pev_owner ) ) ? pev ( i_Ent, pev_owner ) : 0;
        set_pev ( i_Ent, pev_owner, 0 );
        
        // wpn_radiusdamage ( pev->origin, pev, pevOwner, pev->dmg, 16, CLASS_ALIEN_BIOWEAPON, DMG_BLAST | DMG_ALWAYSGIB )
        // UTIL_TraceLine( pev->origin, pev->origin + pev->velocity * 10, dont_ignore_monsters, ENT( pev ), &tr );
        // UTIL_DecalTrace(&tr, DECAL_SMALLSCORCH1 + RANDOM_LONG(0,2));
        
        set_pev ( i_Ent, pev_flags, FL_KILLME );
    }

        
    Shockrifle_Idle ( const id )
    {
        static Float:f_Time; f_Time = get_gametime ();
        
        if ( gf_TimeWeaponIdle[ id ] > f_Time )
        {
            return;
        }

        if ( random_float ( 0.0, 1.0 ) <= 0.75 )
        {
            wpn_playanim ( id, shock_idle1 );
            gf_TimeWeaponIdle[ id ] = f_Time + 5.0;
        }
        else
        {   
            wpn_playanim ( id, shock_idle3 );
            gf_TimeWeaponIdle[ id ] = f_Time + 4.0;
        }
    }
    
    
    ShockCreate ( const id, const Float:vf_Origin[], const Float:vf_Angles[], &i_Shock )
    {
        i_Shock = engfunc ( EngFunc_CreateNamedEntity, gi_ShockClass );
        
        if ( i_Shock )
        {
            set_pev ( i_Shock, pev_classname, "wpn_shock_effect" );
            set_pev ( i_Shock, pev_origin, vf_Origin );
            set_pev ( i_Shock, pev_angles, vf_Angles );
            set_pev ( i_Shock, pev_owner , id );
        }
        
        return i_Shock;
    }
    
    
    ShockSpawn ( const id, const i_Shock )
    {
        static Float:vf_Forward[ Coord_e ];
        
        set_pev ( i_Shock, pev_movetype, MOVETYPE_FLY );
        set_pev ( i_Shock, pev_solid, SOLID_BBOX );
        set_pev ( i_Shock, pev_takedamage, DAMAGE_YES );
        set_pev ( i_Shock, pev_flags, pev ( i_Shock, pev_flags ) | FL_MONSTER );
        set_pev ( i_Shock, pev_health, 1.0 );
        set_pev ( i_Shock, pev_dmg, 10.0 );
        
        engfunc ( EngFunc_SetModel, i_Shock, "models/shock_effect.mdl" );
        engfunc ( EngFunc_SetSize , i_Shock, Float:{ 0.0, 0.0, 0.0 }, Float:{ 0.0, 0.0, 0.0 } );
        
        ShockBlastOn ( i_Shock );
        
        UTIL_MakeAimVectors ( id, angles );
        global_get ( glb_v_forward, vf_Forward );

        set_pev ( i_Shock, pev_vuser1, vf_Forward );
        set_pev ( i_Shock, pev_gravity, 0.5 );
        set_pev ( i_Shock, pev_dmg, 10.0 );
        
        set_pev ( i_Shock, pev_iuser1, 1 );
    }
    
    #define BEAM_ENTS 2
    
    ShockBlastOn ( const i_Ent )
    {
        new i_Beam = engfunc ( EngFunc_CreateNamedEntity, engfunc ( EngFunc_AllocString, "beam" ) );

        static Float:vf_PosGun[ Coord_e ], Float:vf_AngleGun[ Angle_e ];
        static Float:vf_Forward[ Coord_e ], Float:vf_End[ Coord_e ];
        
        engfunc ( EngFunc_GetAttachment, i_Ent, 1, vf_PosGun, vf_AngleGun );
        engfunc ( EngFunc_GetAttachment, i_Ent, 2, vf_PosGun, vf_AngleGun );

        global_get ( glb_v_forward, vf_Forward );
        VectorMA ( vf_PosGun, 40.0, vf_Forward, vf_End );
        
        engfunc ( EngFunc_TraceLine, vf_PosGun, vf_End, DONT_IGNORE_MONSTERS, i_Ent, 0 );

        set_pev( i_Beam, pev_flags, pev ( i_Beam, pev_flags ) | FL_CUSTOMENTITY );
        
        set_pev ( i_Beam, pev_body, 65 ); // noise
        set_pev ( i_Beam, pev_scale, 1.0 ); // width
        set_pev ( i_Beam, pev_animtime, 20.0 ); // scroll rate
        set_pev ( i_Beam, pev_renderamt, 255.0 ); // brightness
        set_pev ( i_Beam, pev_rendercolor, Float:{ 255.0, 0.0, 255.0 } );
        set_pev ( i_Beam, pev_rendermode, BEAM_ENTS & 0x0F ); // type
        // set_pev ( i_Beam, pev_rendermode, SF_BEAM_SHADEOUT & 0xF0 ); // flag
        
        set_pev ( i_Beam, pev_sequence,( i_Ent & 0x0FFF ) | ( ( 1 & 0xF ) << 12 ) ); // set end attachment
        set_pev ( i_Beam, pev_owner, i_Ent ); // set start point
        
        set_pev ( i_Beam, pev_skin,( i_Ent & 0x0FFF ) | ( ( 2 & 0xF ) << 12 ) ); // set start attachment
        set_pev ( i_Beam, pev_aiment, i_Ent ); // set end point
        
        // set_pev ( i_Beam, pev_sequence,( pev ( i_Beam, pev_sequence ) & 0x0FFF ) | ( ( 1 & 0xF ) << 12 ) ); // set end attachment
        // set_pev ( i_Beam, pev_skin,( i_Ent & 0x0FFF ) | ( ( 1 & 0xF ) << 12 ) ); // set start attachment

        set_pev ( i_Beam, pev_model, engfunc ( EngFunc_AllocString, "sprites/plasma.spr" ) );
        set_pev ( i_Beam, pev_modelindex, gi_Beam );
        
        new i_Sprite = engfunc ( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "env_sprite" ) );

        engfunc ( EngFunc_SetModel, i_Sprite, "sprites/hotglow.spr");
        engfunc ( EngFunc_SetSize, i_Sprite, Float:{0.0,0.0,0.0}, Float:{0.0,0.0,0.0});
        engfunc ( EngFunc_SetOrigin, i_Sprite, vf_Origin );
        // set_pev ( i_Sprite, pev_model, "sprites/hotglow.spr" );
        set_pev ( i_Sprite, pev_movetype, MOVETYPE_FLY );
        // set_pev ( i_Sprite, pev_solid, SOLID_TRIGGER );
        // set_pev ( i_Sprite, pev_spawnflags, SF_SPRITE_TEMPORARY );
        set_pev ( i_Sprite, pev_scale, i_Scale );
        set_pev ( i_Sprite, pev_rendermode, kRenderGlow );
        set_pev ( i_Sprite, pev_renderfx, kRenderFxNoDissipation );
        // set_pev ( i_Sprite, pev_ltime, i_Life );
        
        /* new i_Noise = engfunc ( EngFunc_CreateNamedEntity, engfunc ( EngFunc_AllocString, "beam" ) );

        engfunc ( EngFunc_GetAttachment, i_Ent, 1, vf_PosGun, vf_AngleGun );
        engfunc ( EngFunc_GetAttachment, i_Ent, 2, vf_PosGun, vf_AngleGun );

        engfunc ( EngFunc_TraceLine, vf_PosGun, vf_End, DONT_IGNORE_MONSTERS, i_Ent, 0 );

        set_pev( i_Noise, pev_flags, pev ( i_Noise, pev_flags ) | FL_CUSTOMENTITY );
        
        set_pev ( i_Noise, pev_body, 65 ); // noise
        set_pev ( i_Noise, pev_scale, 1.0 ); // width
        set_pev ( i_Noise, pev_animtime, 35.0 ); // scroll rate
        set_pev ( i_Noise, pev_renderamt, 190.0 ); // brightness
        set_pev ( i_Noise, pev_rendercolor, Float:{ 255.0, 255.0, 173.0 } );
        set_pev ( i_Noise, pev_rendermode, BEAM_ENTS & 0x0F ); // type
        // set_pev ( i_Noise, pev_rendermode, SF_BEAM_SHADEOUT & 0xF0 ); // flag
        
        set_pev ( i_Noise, pev_sequence,( i_Ent & 0x0FFF ) | ( ( 1 & 0xF ) << 12 ) ); // set end attachment
        set_pev ( i_Noise, pev_owner, i_Ent ); // set start point
        
        set_pev ( i_Noise, pev_skin,( i_Ent & 0x0FFF ) | ( ( 2 & 0xF ) << 12 ) ); // set start attachment
        set_pev ( i_Noise, pev_aiment, i_Ent ); // set end point
        
        // set_pev ( i_Noise, pev_sequence,( pev ( i_Noise, pev_sequence ) & 0x0FFF ) | ( ( 1 & 0xF ) << 12 ) ); // set end attachment
        // set_pev ( i_Noise, pev_skin,( i_Ent & 0x0FFF ) | ( ( 1 & 0xF ) << 12 ) ); // set start attachment

        set_pev ( i_Noise, pev_model, engfunc ( EngFunc_AllocString, "sprites/plasma.spr" ) );
        set_pev ( i_Noise, pev_modelindex, gi_Beam );*/
    }
    
    
    ShockBlastOff ( const i_Ent )
    {
        set_pev ( pev ( i_Ent, pev_iuser2 ), pev_flags, FL_KILLME );
        set_pev ( i_Ent, pev_iuser2, 0 );
        
        set_pev ( pev ( i_Ent, pev_iuser3 ), pev_flags, FL_KILLME );
        set_pev ( i_Ent, pev_iuser3, 0 );
    }

    
    GetAmmo ( const id, const wpn_usr_info:i_AmmoType )
    {
        return wpn_get_userinfo ( id, i_AmmoType, gi_Weapon[ id ] );
    }

    
    bool:IsWeaponEmpty ( const id )
    {
        gi_Weapon[ id ] = wpn_has_weapon ( id, gi_WeaponId );
        return bool:( wpn_get_userinfo ( id, usr_wpn_ammo1, gi_Weapon[ id ] ) <= 0 );
    }

    
    FX_DynamicLight ( const i_Ent )
    {
        static Float:vf_Origin[ Coord_e ]; pev ( i_Ent, pev_origin, vf_Origin );
        
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte ( TE_DLIGHT );
        write_coord_f ( vf_Origin[ x ] ); 
        write_coord_f ( vf_Origin[ y ] )
        write_coord_f ( vf_Origin[ z ] );
        write_byte ( 108 );    // radius * 0.1
        write_byte ( 201 );    // r
        write_byte ( 236 );    // g
        write_byte ( 255 );    // b
        write_byte ( 1 );      // time * 10
        write_byte ( 0 );      // decay * 0.1
        message_end ();
    }
    
    
    FX_Sparks ( const i_Ent )
    {
        static Float:vf_Origin[ Coord_e ]; pev ( i_Ent, pev_origin, vf_Origin );
            
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte ( TE_SPARKS );
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        message_end ();
    }
    

    FX_Screenfade ( const id, const vi_Color[], const Float:f_Duration, const Float:Holdtime, const i_Alpha, const i_Flag )
    {
        message_begin ( MSG_ONE_UNRELIABLE, gi_MsgScreenFade, _, id );
        write_short( floatround ( f_Duration * ( 1 << 12 ) ) );     // fade lasts this long
        write_short( floatround ( Holdtime   * ( 1 << 12 ) ) );     // fade lasts this long
        write_short( i_Flag );               // fade type (in / out)
        write_byte( vi_Color[ Red   ] );     // fade red
        write_byte( vi_Color[ Green ] );     // fade green
        write_byte( vi_Color[ Blue  ] );     // fade blue
        write_byte( i_Alpha );               // fade blue
        message_end();
    }

    
    FX_BeamEnt ( i_StartEnt, i_EndEnt, const i_SpriteIndex, const i_Life, const i_Width, const i_Amplitude, const i_Brightness, const i_Speed, const i_StartFrame, const i_FrameRate, const vi_Color[] )
    {
        message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte(  TE_BEAMENTS );
        write_short ( i_StartEnt );
        write_short ( i_EndEnt );
        write_short ( i_SpriteIndex );
        write_byte ( i_StartFrame );
        write_byte ( i_FrameRate );
        write_byte ( i_Life );
        write_byte ( i_Width ) ;
        write_byte ( i_Amplitude );
        write_byte ( vi_Color[ Red ] );
        write_byte ( vi_Color[ Green ] );
        write_byte ( vi_Color[ Blue ] );
        write_byte ( i_Brightness );
        write_byte ( i_Speed );
        message_end (); 
    }
    
    
    UTIL_GetStartPosition ( const id, const Float:i_Forward = 0.0, const Float:i_Right = 0.0, const Float:i_Up = 0.0, Float:vf_Source[] )
    {
        UTIL_GetGunPosition ( id, vf_Source );

        static FLoat:vf_Forward[ Coord_e ], Float:vf_Right[ Coord_e ], Float:vf_Up[ Coord_e ];

        if ( i_Forward > 0.0 ) global_get ( glb_v_forward, vf_Forward );
        if ( i_Right   > 0.0 ) global_get ( glb_v_right, vf_Right );
        if ( i_Up      > 0.0 ) global_get ( glb_v_up, vf_Up );

        vf_Source[ x ] += vf_Forward[ x ] * i_Forward + vf_Right[ x ] * i_Right + vf_Up[ x ] * i_Up;
        vf_Source[ y ] += vf_Forward[ y ] * i_Forward + vf_Right[ y ] * i_Right + vf_Up[ y ] * i_Up;
        vf_Source[ z ] += vf_Forward[ z ] * i_Forward + vf_Right[ z ] * i_Right + vf_Up[ z ] * i_Up;
    }
    
    
    UTIL_PunchAngle ( const id, const Float:f_Value )
    {
        static Float:vf_Punchangle[ Coord_e ]; vf_Punchangle[ x ] = f_Value;
        set_pev ( id, pev_punchangle, vf_Punchangle );
    }
    
       
    UTIL_SetAnimation ( const id, const i_Anim, const i_Body = -1 )
    {
        if ( i_Body != -1 )
        {
            set_pev ( id, pev_body, i_Body );
        }
        
        wpn_playanim ( id, i_Anim );
    }


    UTIL_MakeVector ( const id, const i_Bits, Float:vf_vAngles[] )
    {
        static Float:vf_PunchAngles[ Coord_e ], Float:vf_vAngles [ Coord_e ];

        if ( i_Bits & v_angle )    pev ( id, pev_v_angle, vf_vAngles );
        if ( i_Bits & punchangle ) pev ( id, pev_punchangle, vf_PunchAngles );

        if ( i_Bits & ( v_angle & punchangle ) ) VectorAdd ( vf_vAngles, vf_PunchAngles, vf_vAngles );
        engfunc ( EngFunc_MakeVectors, vf_vAngles );
    }

     
    UTIL_MakeAimVectors ( const id, const i_Type )
    {
        static Float:vf_Angle[ Angle_e ]; 
        
        if ( i_Type & angles )     pev ( id, pev_angles, vf_Angle );
        if ( i_Type & punchangle ) pev ( id, pev_punchangle, vf_Angle );
        if ( i_Type & v_angle    ) pev ( id, pev_v_angle, vf_Angle );
        
        vf_Angle[ pitch ] = -vf_Angle[ pitch ];
        engfunc ( EngFunc_MakeVectors, vf_Angle );
    }
    

    UTIL_GetGunPosition ( const id, Float:vf_Source[] )
    {
        static Float:vf_Origin[ Coord_e ], Float:vf_ViewOfs[ Coord_e ];

        pev ( id, pev_origin, vf_Origin );
        pev ( id, pev_view_ofs, vf_ViewOfs );

        VectorAdd ( vf_Origin, vf_ViewOfs, vf_Source );
    }
