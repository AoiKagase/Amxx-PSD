

    #include <amxmodx>
    #include <fakemeta_util>
    #include <weaponmod>
    #include <weaponmod_stocks>
    #include <xs>


    #define Plugin  "WPN Tau Cannon"
    #define Version "1.0.0"
    #define Author  "Arkshine"


    /* - - -
     |  Weapon information   |
                       - - - */
        new
            gs_WpnName [] = "Tau Cannon",
            gs_WpnShort[] = "gauss";

    /* - - -
     |  Weapon model   |
                 - - - */
        new
            gs_Model_P[] = "models/p_gauss.mdl",
            gs_Model_V[] = "models/v_alt_gauss.mdl",
            gs_Model_W[] = "models/w_gauss.mdl";

    /* - - -
     |    Sequence   |
               - - - */
        enum
        {
            gauss_idle,
            gauss_idle2,
            gauss_fidget,
            gauss_spinup,
            gauss_spin,
            gauss_fire,
            gauss_fire2,
            gauss_holster,
            gauss_draw
        };


    #define MAX_CLIENTS   32
    #define HEAD_IN_WATER 3


    #define FFADE_IN         0x0000

    enum e_Color
    {
        red,
        green,
        blue
    }
    
    new const GAUSS_DEFAULT_COLOR_PRI[ e_Color ] = { 100, 255, 100 };
    new const GAUSS_DEFAULT_COLOR_SEC[ e_Color ] = { 255, 255, 255 };

    #define GAUSS_BEAM_WIDTH_PRI    16
    #define GAUSS_BEAM_WIDTH_SEC    24
    #define GAUSS_BEAM_NOISE        0

    #define GAUSS_DAMAGE            20.0 // --| Float
    #define GAUSS_FULL_CHARGE_TIME  4.0  // --| Float

    new gi_InAttack[ MAX_CLIENTS + 1 ];
    new gi_SoundState[ MAX_CLIENTS + 1 ];

    new bool:gb_PrimaryFire[ MAX_CLIENTS + 1 ];
    new bool:gb_HasWeapon  [ MAX_CLIENTS + 1 ];

    new Float:gf_StartCharge    [ MAX_CLIENTS + 1 ];
    new Float:gf_AmmoStartCharge[ MAX_CLIENTS + 1 ];
    new Float:gf_TimeWeaponIdle [ MAX_CLIENTS + 1 ];
    new Float:gf_NextAmmoBurn   [ MAX_CLIENTS + 1 ];
    new Float:gf_PlayAftershock [ MAX_CLIENTS + 1 ];
    new Float:gf_LastAttack2    [ MAX_CLIENTS + 1 ] = { 0.0, ... };

    enum e_Coord
    {
        Float:x,
        Float:y,
        Float:z
    };

    

    new gi_Glow;
    new gi_Beam;

    new gi_Weaponid;
    new gi_MsgScreenFade;
    new gi_MaxClients;


    #define VectorSubtract(%1,%2,%3) ( %3[ x ] = %1[ x ] - %2[ x ], %3[ y ] = %1[ y ] - %2[ y ], %3[ z ] = %1[ z ] - %2[ z ] )
    #define VectorAdd(%1,%2,%3)      ( %3[ x ] = %1[ x ] + %2[ x ], %3[ y ] = %1[ y ] + %2[ y ], %3[ z ] = %1[ z ] + %2[ z ] )
    #define VectorCopy(%1,%2)        ( %2[ x ] = %1[ x ],  %2[ y ] = %1[ y ], %2[ z ] = %1[ z ] )
    #define VectorScale(%1,%2,%3)    ( %3[ x ] = %2 * %1[ x ], %3[ y ] = %2 * %1[ y ], %3[ z ] = %2 * %1[ z ] )
    #define VectorLength(%1)         ( floatsqroot ( %1[ x ] * %1[ x ] + %1[ y ] * %1[ y ] + %1[ z ] * %1[ z ] ) )
    
    #define message_begin_f(%1,%2,%3)  ( engfunc ( EngFunc_MessageBegin, %1, %2, %3 ) )
    #define write_coord_f(%1)          ( engfunc ( EngFunc_WriteCoord, %1 ) )



    public plugin_precache ()
    {
        // --| Weapon models
        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );
        precache_model ( gs_Model_W );

        // --| Weapon sounds
        precache_sound ( "weapons/gauss2.wav" );
        precache_sound ( "weapons/electro4.wav" );
        precache_sound ( "weapons/electro5.wav" );
        precache_sound ( "weapons/electro6.wav" );
        precache_sound ( "weapons/gauss_fire1.wav");
        precache_sound ( "weapons/gauss_fire2.wav");
        precache_sound ( "weapons/gauss_hit.wav");
        precache_sound ( "weapons/gauss_refl1.wav");
        precache_sound ( "weapons/gauss_refl2.wav");
        precache_sound ( "weapons/gauss_spin.wav" );
        precache_sound ( "ambience/pulsemachine.wav" );

        // --| Sprites
        gi_Glow  = precache_model ( "sprites/hotglowwh.spr" );
        gi_Beam  = precache_model ( "sprites/gaussbeam.spr" );
    }


    public plugin_init ()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_hh_version", Version, FCVAR_SERVER | FCVAR_SPONLY );

        register_forward ( FM_PlayerPreThink, "fwd_PlayerPreThink" );

        register_forward ( FM_Think, "fwd_Think" );
        register_forward ( FM_Touch, "fwd_Touch" );
    }


    public plugin_cfg ()
    {
        gi_MsgScreenFade = get_user_msgid ( "ScreenFade" );
        gi_MaxClients = global_get ( glb_maxClients );

        CreateWeapon ();
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

        wpn_register_event ( i_Weapon_id, event_attack1, "Gauss_PrimaryAttack"   );
        // wpn_register_event ( i_Weapon_id, event_attack2, "Gauss_SecondaryAttack" );
        wpn_register_event ( i_Weapon_id, event_draw   , "Gauss_Deploy"  );
        wpn_register_event ( i_Weapon_id, event_hide   , "Gauss_Holster" );

        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, 0.2 );
        wpn_set_float ( i_Weapon_id, wpn_refire_rate2, 0.1 );
        wpn_set_float ( i_Weapon_id, wpn_run_speed, 250.0  );

        wpn_set_integer ( i_Weapon_id, wpn_bullets_per_shot1, 2 );
        wpn_set_integer ( i_Weapon_id, wpn_ammo1, 100 );
        wpn_set_integer ( i_Weapon_id, wpn_cost, 3000 );

        gi_Weaponid = i_Weapon_id;
    }


    public Gauss_PrimaryAttack ( id )
    {
        if ( pev ( id, pev_waterlevel ) == HEAD_IN_WATER )
        {
            PlayEmptySound ( id );
            return PLUGIN_HANDLED;
        }

        /* static i_Weapon; i_Weapon = wpn_has_weapon ( id, gi_Weaponid );
        static i_Ammo1;  i_Ammo1  = wpn_get_userinfo ( id, usr_wpn_ammo1, i_Weapon );

        if ( i_Ammo1 < 2 )
        {
            PlayEmptySound( id );
            return PLUGIN_HANDLED;
        } */

        gb_PrimaryFire[ id ] = true;
        // wpn_set_userinfo ( id, usr_wpn_ammo1, i_Weapon, i_Ammo1 - 2 );

        Gauss_StartFire ( id );

        gf_TimeWeaponIdle[ id ] = get_gametime () + 1.0;

        return PLUGIN_CONTINUE;
    }


    stock Gauss_SecondaryAttack ( id )
    {
        if ( pev ( id, pev_waterlevel ) == HEAD_IN_WATER )
        {
            if ( gi_InAttack[ id ] != 0 )
            {
                emit_sound ( id, CHAN_WEAPON, "weapons/electro4.wav", VOL_NORM, ATTN_NORM, 0, 80 + random_num ( 0, 63 ) );
                wpn_playanim ( id, gauss_idle );
                gi_InAttack[ id ] = 0;
            }
            else
            {
                PlayEmptySound ( id );
            }

            return PLUGIN_HANDLED;
        }

        gf_LastAttack2[ id ] = get_gametime ();

        switch ( gi_InAttack[ id ] )
        {
            case 0 :
            {
                static i_Weapon; i_Weapon = wpn_has_weapon ( id, gi_Weaponid );
                static i_Ammo1;  i_Ammo1  = wpn_get_userinfo ( id, usr_wpn_ammo1, i_Weapon );

                if ( i_Ammo1 <= 0 )
                {
                    PlayEmptySound ( id );
                    return PLUGIN_HANDLED;
                }

                gb_PrimaryFire[ id ] = false;

                wpn_set_userinfo ( id, usr_wpn_ammo1, i_Weapon, i_Ammo1 - 1 );
                gf_NextAmmoBurn[ id ] = get_gametime () + 0.1;

                wpn_playanim( id, gauss_spinup );
                gi_InAttack[ id ] = 1;

                static Float:f_Time; f_Time = get_gametime ();

                gf_TimeWeaponIdle [ id ] = f_Time + 0.5;
                gf_StartCharge    [ id ] = f_Time;
                gf_AmmoStartCharge[ id ] = f_Time + GAUSS_FULL_CHARGE_TIME;

                emit_sound ( id, CHAN_WEAPON, "ambience/pulsemachine.wav", VOL_NORM, ATTN_NORM, 0, 110 );
                gi_SoundState[ id ] = SND_CHANGE_PITCH;
            }
            case 1 :
            {
                if ( gf_TimeWeaponIdle[ id ] < get_gametime () )
                {
                    wpn_playanim( id, gauss_spin );
                    gi_InAttack[ id ] = 2;
                }
            }
            default :
            {
                static i_Weapon; i_Weapon = wpn_has_weapon ( id, gi_Weaponid );
                static i_Ammo1;  i_Ammo1  = wpn_get_userinfo ( id, usr_wpn_ammo1, i_Weapon );

                if ( get_gametime () >= gf_NextAmmoBurn[ id ] && gf_NextAmmoBurn[ id ] != 1000.0 )
                {
                    wpn_set_userinfo ( id, usr_wpn_ammo1, i_Weapon, i_Ammo1 - 1);
                    gf_NextAmmoBurn[ id ] = get_gametime () + 0.1;
                }

                if ( i_Ammo1 <= 0 )
                {
                    Gauss_StartFire ( id );
                    gi_InAttack[ id ] = 0 ;
                    gf_TimeWeaponIdle [ id ] = get_gametime () + 1.0;

                    return PLUGIN_HANDLED;
                }

                if ( get_gametime () >= gf_AmmoStartCharge[ id ] )
                {
                    gf_NextAmmoBurn[ id ] = 1000.0;
                }

                static Float:i_Pitch; i_Pitch = ( get_gametime () - gf_StartCharge[ id ] ) * ( 150.0 / FULL_CHARGE_TIME ) + 100.0;

                if ( i_Pitch > 250.0 )
                {
                    i_Pitch = 250.0;
                }

                emit_sound ( id, CHAN_WEAPON, "ambience/pulsemachine.wav", VOL_NORM, ATTN_NORM, gi_SoundState[ id ] == SND_CHANGE_PITCH ? 1 : 0, floatround ( i_Pitch ) );
                gi_SoundState[ id ] = SND_CHANGE_PITCH;

                if ( gf_StartCharge[ id ] < get_gametime () - 10.0 )
                {
                    emit_sound ( id, CHAN_WEAPON, "weapons/electro4.wav", VOL_NORM, ATTN_NORM, 0, 80 + random_num ( 0, 63 ) );
                    emit_sound ( id, CHAN_ITEM,   "weapons/electro6.wav", VOL_NORM, ATTN_NORM, 0, 75 + random_num ( 0, 63 ) );

                    gi_InAttack[ id ] = 0 ;
                    gf_TimeWeaponIdle[ id ] = get_gametime () + 1.0;

                    FX_Screenfade ( id, 2 << 12, 1 << 11, FFADE_IN, 225, 128, 0, 128 );

                    wpn_damage_user ( gi_Weaponid, id, 0, 0, 50, DMG_SHOCK );
                    wpn_playanim( id, gauss_idle );

                    return PLUGIN_CONTINUE;
                }
            }
        }

        return PLUGIN_CONTINUE;
    }


    public Gauss_Deploy ( id )
    {
        gf_PlayAftershock[ id ] = 0.0;
        wpn_playanim( id, gauss_draw );
    }


    public Gauss_Holster ( id )
    {
        if ( gi_InAttack[ id ] )
        {
            emit_sound ( id, CHAN_WEAPON, "weapons/gauss_spin.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM );
            Gauss_StartFire ( id );
        }

        wpn_playanim( id, gauss_holster );
        gi_InAttack[ id ] = 0;
    }


    public fwd_PlayerPreThink ( id )
    {
        if ( !gb_HasWeapon[ id ] )
        {
            return FMRES_IGNORED;
        }

        if ( gf_PlayAftershock[ id ] > 0.0 && gf_PlayAftershock[ id ] < get_gametime () )
        {
            switch ( random_num ( 0, 3 ) )
            {
                case 0 : emit_sound ( id, CHAN_WEAPON, "weapons/electro4.wav", random_float ( 0.7, 0.8 ), ATTN_NORM, 0, PITCH_NORM );
                case 1 : emit_sound ( id, CHAN_WEAPON, "weapons/electro5.wav", random_float ( 0.7, 0.8 ), ATTN_NORM, 0, PITCH_NORM );
                case 2 : emit_sound ( id, CHAN_WEAPON, "weapons/electro6.wav", random_float ( 0.7, 0.8 ), ATTN_NORM, 0, PITCH_NORM );
            }

            gf_PlayAftershock[ id ] = 0.0;
        }

        if ( gi_InAttack[ id ] != 0 )
        {
            if ( gf_LastAttack2[ id ] != -1.0 && get_gametime () - gf_LastAttack2[ id ] > 0.2 )
            {
                Gauss_StartFire ( id );
                gi_InAttack[ id ] = 0;
                gf_TimeWeaponIdle[ id ] = get_gametime () + 2.0;
            }
        }
        else
        {
            WeaponIdle ( id );
        }

        return FMRES_IGNORED;
    }


    WeaponIdle ( id )
    {
        if ( gf_TimeWeaponIdle[ id ] > get_gametime () )
        {
            return;
        }

        static Float:f_Rand;
        f_Rand = random_float ( 0.0, 1.0 );

        if ( f_Rand <= 0.5 )
        {
            wpn_playanim ( id, gauss_idle );
            gf_TimeWeaponIdle[ id ] = get_gametime () + random_float ( 10.0, 15.0 );
        }
        else if ( f_Rand <= 0.75 )
        {
            wpn_playanim ( id, gauss_idle2 );
            gf_TimeWeaponIdle[ id ] = get_gametime () + random_float ( 10.0, 15.0 );
        }
        else
        {
            wpn_playanim ( id, gauss_fidget );
            gf_TimeWeaponIdle[ id ] = get_gametime () + 3.0;
        }
    }


    UTIL_MakeVectors ( const id )
    {
        static Float:vf_vAngle [ e_Coord ], Float:vf_Punchangle[ e_Coord ];

        pev ( id, pev_v_angle, vf_vAngle );
        pev ( id, pev_punchangle, vf_Punchangle );

        xs_vec_add ( vf_vAngle, vf_Punchangle, vf_vAngle );
        engfunc( EngFunc_MakeVectors, vf_vAngle );
    }


    Gauss_StartFire ( id )
    {
        static Float:vf_Color [ e_Color ];
        static Float:f_Damage; f_Damage = 0.0;

        UTIL_MakeVectors ( id );

        emit_sound ( id, CHAN_WEAPON, "weapons/gauss_spin.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM );
        gi_SoundState[ id ] = 0;

        if ( gb_PrimaryFire[ id ] )
        {
            f_Damage = GAUSS_DAMAGE;
            ColorIntToFloat ( GAUSS_DEFAULT_COLOR_PRI, vf_Color );

            set_pev ( id, pev_renderamt, 255.0 );
            set_pev ( id, pev_rendercolor, vf_Color );
        }
        else
        {
            static Float:k; k = ( get_gametime () - gf_StartCharge[ id ] ) / GAUSS_FULL_CHARGE_TIME;

            if ( k > 1.0 )
            {
                k = 1.0;
            }

            f_Damage = GAUSS_DAMAGE * 10.0 * k;
            set_pev ( id, pev_renderamt, k * 255.0 );

            if ( !gb_PrimaryFire[ id ] )
            {
                ColorIntToFloat ( GAUSS_DEFAULT_COLOR_SEC, vf_Color );
                set_pev ( id, pev_rendercolor, vf_Color );

                static Float:vf_Velocity[ e_Coord ]; pev ( id, pev_velocity, vf_Velocity );
                static Float:vf_Forward[ e_Coord ];  global_get ( glb_v_forward, vf_Forward );

                VectorMS ( vf_Velocity, f_Damage * 5.0, vf_Forward, vf_Velocity );
                set_pev ( id, pev_velocity, vf_Velocity );
            }
        }

        wpn_playanim ( id, gauss_fire2 );

        static Float:vf_Punchangle[ e_Coord ]; vf_Punchangle[ x ] = -2.0;
        set_pev ( id, pev_punchangle, vf_Punchangle );

        gb_PrimaryFire[ id ] ?

            emit_sound ( id, CHAN_WEAPON, "weapons/gauss_fire1.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num ( 0, 8 ) ) :
            emit_sound ( id, CHAN_WEAPON, "weapons/gauss_fire2.wav", ( VOL_NORM / 2 ) + f_Damage * ( 1.0 / 400.0 ), ATTN_NORM, 0, 96 + random_num ( 0, 8 ) );

        static Float:vf_Source[ e_Coord ]; static Float:vf_Forward[ e_Coord ];

        global_get ( glb_v_forward, vf_Forward );
        GetGunPosition ( id, vf_Source );

        Gauss_Fire ( id, vf_Source, vf_Forward, f_Damage );

        gi_InAttack[ id ] = 0;
        gf_PlayAftershock[ id ] = get_gametime () + random_float ( 0.5, 0.8 );
    }


    Gauss_Fire ( id, Float:vf_OrigSrc[], Float:vf_Dir[], Float:f_Damage )
    {
        static Float:vf_Source[ e_Coord ], Float:vf_Dest[ e_Coord ], Float:vf_EndPos[ e_Coord ], Float:vf_RenderColor[ 3 ];
        static Float:f_SaveDamage, Float:f_TakeDamage, Float:f_MaxFrac, Float:f_Brightness;
        static bool:b_FirstBeam, bool:b_HasPunched, bool:b_GoThrough;
        static i_EntIgnore, tr, beam_tr, i_MaxHits, i_Hit;

        xs_vec_copy ( vf_OrigSrc, vf_Source );
        VectorMA ( vf_Source, 8192.0, vf_Dir, vf_Dest );

        f_SaveDamage = f_Damage;
        f_MaxFrac    = 1.0;
        i_MaxHits    = 8;
        b_FirstBeam  = true;
        b_HasPunched = false;
        b_GoThrough  = false;

        client_print ( id, print_chat, "( Gauss_Fire ) damage = %f", f_Damage );

        while ( f_Damage > 10 && i_MaxHits > 0 )
        {
            i_MaxHits--;
            engfunc ( EngFunc_TraceLine, vf_Source, vf_Dest, DONT_IGNORE_MONSTERS, i_EntIgnore, tr );

            if ( get_tr2 ( tr, TR_AllSolid ) )
            {
                break;
            }

            i_Hit = Instance ( get_tr2 ( tr, TR_pHit ) );

            get_tr2 ( tr, TR_vecEndPos, vf_EndPos );

            pev ( id, pev_rendercolor, vf_RenderColor );
            pev ( id, pev_renderamt, f_Brightness );

            new i_Red = floatround ( vf_RenderColor[ 0 ] );
            new i_Green = floatround ( vf_RenderColor[ 1 ] );
            new i_Blue = floatround ( vf_RenderColor[ 2 ] );

            // client_print ( id, print_chat, "%f %f %f", vf_RenderColor[ red ], vf_RenderColor[ green ], vf_RenderColor[ blue ] ):

            message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Source, 0 );

            if ( b_FirstBeam )
            {
                b_FirstBeam = false;
                write_byte ( TE_BEAMENTPOINT );
                write_short ( id | 0x1000 );
            }
            else
            {
                write_byte ( TE_BEAMPOINTS );
                write_coord_f ( vf_Source[ x ] );
                write_coord_f ( vf_Source[ y ] );
                write_coord_f ( vf_Source[ z ] );
            }

            write_coord_f ( vf_EndPos[ x ] );
            write_coord_f ( vf_EndPos[ y ] );
            write_coord_f ( vf_EndPos[ z ] );
            write_short ( gi_Beam );
            write_byte ( 0 );                         // starting frame
            write_byte ( 1 );                         // framerate
            write_byte ( 1 );                         // life
            write_byte ( gb_PrimaryFire[ id ] ? GAUSS_BEAM_WIDTH_PRI : GAUSS_BEAM_WIDTH_SEC );
            write_byte ( GAUSS_BEAM_NOISE );          // noise amplitude
            write_byte ( 255 );   // red
            write_byte ( 255 );   // green
            write_byte ( 255 );   // blue
            write_byte ( floatround ( f_Brightness ) );              // brightness
            write_byte ( 0 );                         // scroll speed
            message_end ();

            pev ( i_Hit, pev_takedamage, f_TakeDamage );

            if ( 1 <= i_Hit <= gi_MaxClients && f_TakeDamage != DAMAGE_NO )
            {
                wpn_damage_user ( gi_Weaponid, i_Hit, id, 0, floatround ( f_Damage ), DMG_BULLET | DMG_ENERGYBEAM );
            }

            if ( ReflectGauss ( i_Hit, f_TakeDamage ) )
            {
                static Float:vf_PlaneNormal[ e_Coord ], Float:n, Float:r[ e_Coord ];
                get_tr2 ( tr, TR_vecPlaneNormal, vf_PlaneNormal );

                n = - xs_vec_dot ( vf_PlaneNormal, vf_Dir );
                client_print ( id, print_chat, "n = %f", n );

                if ( 0 < n < 0.5 )
                {
                    static f_Fraction;
                    VectorMA ( vf_Dir, 2.0 * n, vf_PlaneNormal, r );

                    get_tr2 ( tr, TR_flFraction, f_Fraction );
                    get_tr2 ( tr, TR_vecEndPos, vf_EndPos );

                    f_MaxFrac = f_MaxFrac - f_Fraction;

                    xs_vec_copy ( r, vf_Dir );

                    VectorMA ( vf_EndPos, 8.0, vf_Dir, vf_Source );
                    VectorMA ( vf_Source, 8192.0, vf_Dir, vf_Dest );

                    wpn_radius_damage ( gi_Weaponid, id, 0, f_Damage * n * 2, f_Damage * 2, DMG_BLAST );
                    FX_BeamImpact ( id, vf_EndPos, vf_PlaneNormal, f_Damage * n, true, false );

                    if ( !n )
                    {
                        n = 0.1;
                    }

                    f_Damage = f_Damage * ( 1  - n );
                }
                else
                {
                    if ( b_HasPunched )
                    {
                        FX_BeamImpact ( id, vf_EndPos, vf_Dir, f_Damage, false, true );
                    }

                    b_HasPunched = true;
                    b_GoThrough  = false;
                    f_SaveDamage = f_Damage;

                    if ( gb_PrimaryFire[ id ] )
                    {
                        f_Damage = 0.0;
                    }
                    else
                    {
                        static Float:vf_Start[ e_Coord ];

                        get_tr2 ( tr, TR_vecEndPos, vf_EndPos );
                        VectorMA ( vf_EndPos, 8.0, vf_Dir, vf_Start );

                        engfunc ( EngFunc_TraceLine, vf_Source, vf_Dest, DONT_IGNORE_MONSTERS, IGNORE_GLASS, i_EntIgnore, beam_tr );

                        if ( !get_tr2 ( beam_tr, TR_AllSolid ) )
                        {
                            static Float:vf_BeamEndPos[ e_Coord ], Float:vf_Temp[ e_Coord ];
                            static Float:l;

                            get_tr2 ( beam_tr, TR_vecEndPos, vf_BeamEndPos );
                            engfunc ( EngFunc_TraceLine, vf_BeamEndPos, vf_EndPos, DONT_IGNORE_MONSTERS, i_EntIgnore, beam_tr );

                            get_tr2 ( beam_tr, TR_vecEndPos, vf_BeamEndPos );
                            xs_vec_sub ( vf_BeamEndPos, vf_EndPos, vf_Temp );

                            l = xs_vec_len ( vf_Temp );

                            if ( l < f_Damage )
                            {
                                if ( !l )
                                {
                                    l = 1.0;
                                }

                                f_Damage -= l;

                                VectorMA ( vf_BeamEndPos, 8.0, vf_Dir, vf_Temp );
                                wpn_radius_damage ( gi_Weaponid, id, 0, f_Damage * 2.0, f_Damage, DMG_BLAST );

                                xs_vec_add ( vf_BeamEndPos, vf_Dir, vf_Source );
                            }
                            else
                            {
                                f_Damage = 0.0;
                            }
                        }
                        else
                        {
                            f_Damage = 0.0;
                        }
                    }

                    FX_BeamImpact ( id, vf_EndPos, b_GoThrough ? vf_Source : vf_Dir, f_SaveDamage, false, true );
                }
            }
            else
            {
                xs_vec_add ( vf_EndPos, vf_Dir, vf_Source );
                i_EntIgnore = i_Hit;
            }
        }
    }


    FX_BeamImpact ( id, Float:vf_Origin[], Float:vf_Angles[], Float:f_Damage, bool:b_Reflect, bool:b_GoThrough )
    {
        static Float:vf_Normal[ e_Coord ], Float:vf_Spot[ e_Coord ], Float:vf_End[ e_Coord ];

        VectorScale ( vf_Angles, -1.0, vf_Normal );
        VectorNormalize ( vf_Normal );
        VectorAdd ( vf_Origin, vf_Normal, vf_Spot );    // --| Move back a little bit
        VectorMA ( vf_Origin, 8.0, vf_Angles, vf_End ); // --| Move forward little more

        static i_Scale, i_Count, r, g, b; 
        
        i_Scale = i_Count = 1;
        r = g = b = 255;

        if ( gb_PrimaryFire[ id ] )
        {
            r = GAUSS_DEFAULT_COLOR_PRI[ red ]; 
            g = GAUSS_DEFAULT_COLOR_PRI[ green ]; 
            b = GAUSS_DEFAULT_COLOR_PRI[ blue ];
            
            i_Scale = floatround ( f_Damage * 0.25 );
            i_Count = floatround ( f_Damage * 0.4 );
        }
        else
        {
            r = GAUSS_DEFAULT_COLOR_SEC[ red ]; 
            g = GAUSS_DEFAULT_COLOR_SEC[ green ]; 
            b = GAUSS_DEFAULT_COLOR_SEC[ blue ];
            
            i_Scale = floatround ( 0.1 + f_Damage * 0.08 );
            i_Count = floatround ( 2.0 + f_Damage * 0.2 );
        }

        client_print ( id, print_chat, "( FX_BeamImpact ) damage = %f | f_Scale = %i | i_Count = %i", f_Damage, i_Scale, i_Count );

        if ( b_Reflect )
        {
            // FX_TempSprite  ( vf_Origin, i_Scale, 10 );
            FX_SpriteTrail ( vf_Origin, vf_Spot, 50, 10, 1, 50 /* floatround ( floatmin ( f_Damage * 2.0, 200.0 ) )*/ , 50 );

            engfunc ( EngFunc_EmitAmbientSound, 0, vf_Origin, random_num ( 0, 1 ) ? "weapons/gauss_refl2.wav" : "weapons/gauss_refl1.wav", VOL_NORM, ATTN_IDLE, 0, PITCH_NORM );
        }
        /* else
        {
            static Float:vf_EndPos[ e_Coord ], Float:vf_PlaneNormal[ e_Coord ];
            static Float:vf_Temp  [ e_Coord ], Float:vf_Delta[ e_Coord ];
            
            engfunc ( EngFunc_TraceLine, vf_Origin, vf_End, DONT_IGNORE_MONSTERS, -1, 0 );
        
            get_tr2 ( 0, TR_vecEndPos, vf_EndPos );
        
            FX_DecalGunshot ( id, vf_EndPos, Instance ( get_tr2 ( 0, TR_pHit ) ), engfunc ( EngFunc_DecalIndex, "{gaussshot1" ) );
            FX_DynamicLight ( vf_Spot, i_Scale * 64, r, g, b, 20, 200 );
        
            if ( !get_tr2 ( 0, TR_AllSolid ) && b_GoThrough )
            {
                VectorAdd ( vf_Origin, vf_Normal, vf_Temp );
            
                FX_TempSprite  ( vf_Origin, ( i_Scale / 2 ) + 1, 20 );
                FX_SpriteTrail ( vf_Origin, vf_Temp, i_Count / 2, 30, 1, floatround ( floatmin ( f_Damage * 2.0, 200.0 ) ), 200 );
                
                VectorCopy ( vf_EndPos, vf_End ); // --| Trace back from the other side of the wall
                engfunc ( EngFunc_TraceLine, vf_End, vf_Origin, DONT_IGNORE_MONSTERS, -1, 0 );
                
                get_tr2 ( 0, TR_vecEndPos, vf_EndPos );
                get_tr2 ( 0, TR_vecPlaneNormal, vf_PlaneNormal );
                
                VectorSubtract ( vf_End, vf_EndPos, vf_Delta );
                VectorAdd ( vf_EndPos, vf_PlaneNormal, vf_Temp );

                if ( !get_tr2 ( 0, TR_AllSolid ) && VectorLength ( vf_Delta ) < f_Damage )
                {
                    FX_TempSprite  ( vf_EndPos, ( i_Scale / 2 ) + 1, 20 );
                    FX_SpriteTrail ( vf_EndPos, vf_Temp, floatround ( i_Count * 0.8 ), 30, 1, floatround ( floatmin ( f_Damage * 2.0, 200.0 ) ), 200 );
                    FX_DecalGunshot ( id, vf_EndPos, Instance ( get_tr2 ( 0, TR_pHit ) ), engfunc ( EngFunc_DecalIndex, "{gaussshot1" ) );
                    
                    engfunc ( EngFunc_EmitAmbientSound, 0, vf_EndPos, "weapons/gauss_hit.wav", VOL_NORM, ATTN_STATIC, 0, PITCH_NORM );
                }
            }
            else
            {
                FX_TempSprite  ( vf_Spot, i_Scale, 50 );
                FX_SpriteTrail ( vf_Origin, vf_Spot, i_Count, 30, 1, floatround ( floatmin ( 100 + f_Damage * 0.5, 200.0 ) ), floatround ( 100 + f_Damage ) );
            }
        } */
    }


    FX_TempSprite ( const Float:vf_Origin[], const i_Scale, const i_Life )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte  ( TE_GLOWSPRITE )    // --| Display and glow a sprite with fading out effect.
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        write_short ( gi_Glow );
        write_byte  ( i_Life );    // --| Life in 10s
        write_byte  ( i_Scale );   // --| Size in 10s
        write_byte  ( 255 )        // --| Brigthness
        message_end ();
    }


    FX_SpriteTrail ( const Float:vf_Start[], const Float:vf_End[], i_Count, i_Life, i_Scale, i_Velocity, i_Randomness )
    {
        message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte ( TE_SPRITETRAIL );
        write_coord_f ( vf_Start[ x ] );
        write_coord_f ( vf_Start[ y ] );
        write_coord_f ( vf_Start[ z ] );
        write_coord_f ( vf_End[ x ] );
        write_coord_f ( vf_End[ y ] );
        write_coord_f ( vf_End[ z ] );
        write_short ( gi_Glow );
        write_byte ( i_Count );         // count
        write_byte ( i_Life );          // life in 0.1's
        write_byte ( i_Scale );         // scale in 0.1's
        write_byte ( i_Velocity );      // velocity along vector in 10's
        write_byte ( i_Randomness );    // randomness of velocity in 10's
        message_end ();
    }


    FX_DynamicLight ( const Float:vf_Origin[], i_Radius, r, g, b, i_Life, i_Decay )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte ( TE_DLIGHT )
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        write_byte ( i_Radius );
        write_byte ( r );
        write_byte ( g );
        write_byte ( b );
        write_byte ( 255 );
        write_byte ( i_Life );
        write_coord ( i_Decay );
        message_end ();
    }


    PlayEmptySound ( id )
    {
        emit_sound ( id, CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
    }


    GetGunPosition ( id, Float:vf_Source[] )
    {
        static Float:vf_Origin[ e_Coord ], Float:vf_ViewOfs[ e_Coord ];

        pev ( id, pev_origin, vf_Origin );
        pev ( id, pev_view_ofs, vf_ViewOfs );

        xs_vec_add ( vf_Origin, vf_ViewOfs, vf_Source );
    }


    ReflectGauss ( i_Ent, Float:f_TakeDamage )
    {
        if ( i_Ent == -1 )
        {
            return 0;
        }

        return ( IsBSPModel ( i_Ent ) && f_TakeDamage == DAMAGE_NO );
    }


    IsBSPModel ( i_Ent )
    {
        return pev ( i_Ent, pev_solid ) == SOLID_BSP || pev ( i_Ent, pev_movetype ) == MOVETYPE_PUSHSTEP;
    }


    ColorIntToFloat ( const vi_Color[], Float:vf_Output[] )
    {
        vf_Output[ red   ] = vi_Color[ red   ] * 1.0;
        vf_Output[ green ] = vi_Color[ green ] * 1.0;
        vf_Output[ blue  ] = vi_Color[ blue ] * 1.0;
    }


    FX_DecalGunshot ( id, const Float:vf_EndPos[], i_Hit, i_Decal )
    {
        if ( i_Hit > 0 )
        {
            message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
            write_byte ( TE_DECAL );
            write_coord_f ( vf_EndPos[ x ] );
            write_coord_f ( vf_EndPos[ y ] );
            write_coord_f ( vf_EndPos[ z ] );
            write_byte ( i_Decal );
            write_short ( i_Hit );
            message_end();
        }
        else
        {
            message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
            write_byte ( TE_WORLDDECAL );
            write_coord_f ( vf_EndPos[ x ] );
            write_coord_f ( vf_EndPos[ y ] );
            write_coord_f ( vf_EndPos[ z ] );
            write_byte ( i_Decal );
            message_end();
        }

        message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte ( TE_GUNSHOTDECAL );
        write_coord_f ( vf_EndPos[ x ] );
        write_coord_f ( vf_EndPos[ y ] );
        write_coord_f ( vf_EndPos[ z ] );
        write_short ( id );
        write_byte ( i_Decal );
        message_end();
    }


    FX_Sprite ( const Float:vf_Origin[], i_Scale, Float:i_Life )
    {
    /* Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"));
        set_pev(Ent, pev_movetype, MOVETYPE_FLY);
        set_pev(Ent, pev_solid, SOLID_TRIGGER);
        set_pev(Ent, pev_renderamt, 0.0);
        set_pev(Ent, pev_rendermode, kRenderTransAlpha);
        engfunc(EngFunc_SetModel, Ent, "models/w_usp.mdl");

        set_pev(Ent, pev_mins, Float:{ -1.0, -1.0, -1.0 } );
        set_pev(Ent, pev_maxs, Float:{ 1.0, 1.0, 1.0 } );

        set_pev(Ent, pev_origin, vf_Origin); */

        /* new i_Sprite = engfunc ( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "env_sprite" ) );
        set_pev ( i_Sprite, pev_classname, "wpn_effect" );
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

        // dllfunc ( DLLFunc_Spawn, i_Sprite ); */


        message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte ( TE_SPRITE)
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        write_short ( gi_Glow );
        write_byte ( i_Scale );           // scale in 0.1's
        write_byte ( 200 );      // brigthness
        message_end ();
    }


    FX_Screenfade ( id, i_Duration, i_Holdtime, i_Flags, i_Red, i_Green, i_Blue, i_Alpha )
    {
        message_begin ( MSG_ONE_UNRELIABLE, gi_MsgScreenFade, _, id );
        write_short ( i_Duration ); // Duration
        write_short ( i_Holdtime ); // Holdtime
        write_short ( i_Flags );    // Flags ( fade type )
        write_byte ( i_Red );       // fade red
        write_byte ( i_Green );     // fade green
        write_byte ( i_Blue );      // fade blue
        write_byte ( i_Alpha );     // Alpha
        message_end();
    }


    Instance ( const i_Target )
    {
        return i_Target == -1 ? 0 : i_Target;
    }
    
    
    VectorMA ( const Float:vf_Add[], const Float:f_Scale, const Float:vf_Mult[], Float:vf_Output[] )
    {
        vf_Output[ x ] = vf_Add[ x ] + vf_Mult[ x ] * f_Scale;
        vf_Output[ y ] = vf_Add[ y ] + vf_Mult[ y ] * f_Scale;
        vf_Output[ z ] = vf_Add[ z ] + vf_Mult[ z ] * f_Scale;
    }
    
    #define VectorMA(%1,%2,%3,%4) ( %4[ x ] = %1[ x ] + %2 * %3[ x ], %4[ y ] = %1[ y ] + %2 * %3[ y ], %4[ z ] = %1[ z ] + %2 * %3[ z ] )


    VectorMS ( const Float:vf_Sou[], const Float:f_Scale, const Float:vf_Mult[], Float:vf_Output[] )
    {
        vf_Output[ x ] = vf_Sou[ x ] - vf_Mult[ x ] * f_Scale;
        vf_Output[ y ] = vf_Sou[ y ] - vf_Mult[ y ] * f_Scale;
        vf_Output[ z ] = vf_Sou[ z ] - vf_Mult[ z ] * f_Scale;
    }
    
    
    VectorNormalize ( Float:vf_Source[] )
    {
        static Float:f_Invlen; f_Invlen = VectorLength ( vf_Source );
        
        vf_Source[ x ] *= f_Invlen 
        vf_Source[ y ] *= f_Invlen; 
        vf_Source[ z ] *= f_Invlen;
    } 

