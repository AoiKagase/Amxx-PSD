
    #include <amxmodx>
    #include <fakemeta>
    #include <weaponmod_stocks>
    
    
    #define Plugin  "WPN Flame Thrower"
    #define Version "1.0.0"
    #define Author  "Arkshine"
    
    
    /* - - -
     |  Weapon information   |
                       - - - */
        new
            gs_WpnName [] = "Flame Thrower",
            gs_WpnShort[] = "flamethrower";

    /* - - -
     |  Weapon model   |
                 - - - */
        new
            gs_Model_P[] = "models/p_flame.mdl",
            gs_Model_V[] = "models/v_flame.mdl";
            
    /* - - -
     |  Flame sounds   |
                 - - - */
        new const 
            gs_FlameSelect[] = "weapons/flame_select.wav",
            gs_FlameRun1  [] = "weapons/flame_run1.wav",
            gs_FlameRun2  [] = "weapons/flame_run2.wav",
            gs_FlameBurn  [] = "weapons/flame_burn.wav";
        
    /* - - -
     |    Sequence   |
               - - - */
        enum
        {
            flame_draw,
            flame_idle,
            flame_fidget,
            flame_fire,
            flame_shoot,
            flame_holster
        };
        
    /* - - -
     |   Others stuffs   |
                   - - - */
        #define MAX_CLIENTS   32
        #define FLAME_STAYPUT 1
        
        new Float:gf_TimeWeaponIdle[ MAX_CLIENTS + 1 ];
        new Float:gf_NextAmmoBurn  [ MAX_CLIENTS + 1 ];
        
        new gi_FireMode [ MAX_CLIENTS + 1 ];
        new gi_FireState[ MAX_CLIENTS + 1 ];
        
        // --| Used fo readability.
        enum _:Coord_e { Float:x, Float:y, Float:z };
        enum _:Angle_e { Float:pitch, Float:yaw, Float:roll };
        
        enum ( <<= 1 ) { v_angle = 1, punchangle };
        enum { FIRE_OFF, FIRE_CHARGE, FIRE_PRI, FIRE_SEC  };
                   
        new gi_Flame, gi_Flame2;                    // --| Index flame sprite.
        new gi_FlameFrameCnt, gi_Flame2FrameCnt;    // --| Sprite max frame count.
        new gi_MaxClients;                          // --| Max slots of server.
        new gi_WeaponId;                            // --| Real weapon id.
        new gi_CloudClass;
        
    /* - - -
     |   Macros   |
            - - - */
        #define VectorSubtract(%1,%2,%3) ( %3[ x ] = %1[ x ] - %2[ x ], %3[ y ] = %1[ y ] - %2[ y ], %3[ z ] = %1[ z ] - %2[ z ] )
        #define VectorAdd(%1,%2,%3)      ( %3[ x ] = %1[ x ] + %2[ x ], %3[ y ] = %1[ y ] + %2[ y ], %3[ z ] = %1[ z ] + %2[ z ] )
        #define VectorCopy(%1,%2)        ( %2[ x ] = %1[ x ],  %2[ y ] = %1[ y ], %2[ z ] = %1[ z ] )
        #define VectorScale(%1,%2,%3)    ( %3[ x ] = %2 * %1[ x ], %3[ y ] = %2 * %1[ y ], %3[ z ] = %2 * %1[ z ] )
        #define VectorLength(%1)         ( floatsqroot ( %1[ x ] * %1[ x ] + %1[ y ] * %1[ y ] + %1[ z ] * %1[ z ] ) )
        #define VectorMA(%1,%2,%3,%4)    ( %4[ x ] = %1[ x ] + %2 * %3[ x ], %4[ y ] = %1[ y ] + %2 * %3[ y ], %4[ z ] = %1[ z ] + %2 * %3[ z ] )
        
        #define IsBSPModel(%1)           ( pev ( %1, pev_solid )== SOLID_BSP || pev ( %1, pev_movetype )== MOVETYPE_PUSHSTEP )
        
        #define message_begin_f(%1,%2,%3)  ( engfunc ( EngFunc_MessageBegin, %1, %2, %3 ) )
        #define write_coord_f(%1)          ( engfunc ( EngFunc_WriteCoord, %1 ) )
    
    
    public plugin_precache ()
    {
        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );
        
        precache_sound ( gs_FlameSelect );
        precache_sound ( gs_FlameRun1 );
        precache_sound ( gs_FlameRun2 );
        precache_sound ( gs_FlameBurn );
    
        gi_Flame  = precache_model ( "sprites/flamefire.spr" );
        gi_Flame2 = precache_model ( "sprites/flamefire2.spr" );
    }
    
    
    public plugin_init ()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_ft_version", Version, FCVAR_SERVER | FCVAR_SPONLY );

        register_forward ( FM_PlayerPreThink, "Forward_PlayerPreThink" );

        register_forward ( FM_Think, "Forward_Think" );
        register_forward ( FM_Touch, "Forward_Touch" );
    }
    
    
    public plugin_cfg ()
    {
        gi_MaxClients = global_get ( glb_maxClients );
        gi_CloudClass = engfunc ( EngFunc_AllocString, "env_sprite" );
        
        gi_FlameFrameCnt  = engfunc ( EngFunc_ModelFrames, gi_Flame );
        gi_Flame2FrameCnt = engfunc ( EngFunc_ModelFrames, gi_Flame2 );

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

        wpn_register_event ( i_Weapon_id, event_attack1, "Flame_PrimaryAttack"   );
        wpn_register_event ( i_Weapon_id, event_attack2, "Flame_SecondaryAttack" );
        wpn_register_event ( i_Weapon_id, event_attack1_released, "Flame_PrimaryReleaseAttack" );
        wpn_register_event ( i_Weapon_id, event_attack2_released, "Flame_SecondaryReleaseAttack" );
        wpn_register_event ( i_Weapon_id, event_draw   , "Flame_Deploy"  );
        wpn_register_event ( i_Weapon_id, event_hide   , "Flame_Holster" );
        wpn_register_event ( i_Weapon_id, event_weapondrop_post, "Flame_Drop" );

        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, 0.0 );
        wpn_set_float ( i_Weapon_id, wpn_refire_rate2, 0.0 );
        wpn_set_float ( i_Weapon_id, wpn_run_speed, 250.0  );

        // wpn_set_integer ( i_Weapon_id, wpn_bullets_per_shot1, 1 );
        wpn_set_integer ( i_Weapon_id, wpn_ammo1, 100 );
        wpn_set_integer ( i_Weapon_id, wpn_cost, 3000 );

        gi_WeaponId = i_Weapon_id;
    }
    
    
    public Flame_PrimaryAttack ( const id )
    {
        Attack ( id, FIRE_PRI );
    }
    
    
    public Flame_SecondaryAttack ( const id )
    {
        Attack ( id, FIRE_SEC );
    }
    
    
    public Flame_PrimaryReleaseAttack ( const id )
    {
        EndAttack ( id );
    }
    
    
    public Flame_SecondaryReleaseAttack ( const id )
    {
        EndAttack ( id );
    }
    
    
    public Flame_Deploy ( const id )
    {
        if ( HasAmmo ( id ) )
        {
            emit_sound ( id, CHAN_WEAPON, gs_FlameSelect, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        }
        
        gi_FireState[ id ] = FIRE_OFF;
        wpn_playanim ( id, flame_draw );
    }
    
    
    public Flame_Holster ( const id )
    {
        EndAttack ( id );
        wpn_playanim ( id, flame_holster );
    }
    
    
    /*
        + - - - - - - - - -
        |  Called when flamethrower is dropped by player.
        |
        |  World model is implemented into player model.
           So, we have to set the model manually.
                                                          |
           @param           Player's id                   |
           @param           Entity index                  |
                                        - - - - - - - - - +
    */
    public Flame_Drop( const id, const i_Ent )
    {
        engfunc ( EngFunc_SetModel, i_Ent, gs_Model_P );
        set_pev ( i_Ent, pev_sequence, FLAME_STAYPUT );
    }
    
        
    public Forward_PlayerPreThink ( const id )
    {
        if ( is_user_alive ( id ) && wpn_uses_weapon( id, gi_WeaponId ) )
        {
            WeaponIdle ( id );
        }
    }

    #define IsFlame(%1) ( pev ( i_Ent, pev_iuser1 ) == FLAME_THINK
    public Forward_Think ( const i_Ent )
    {
        if ( IsFlame ( i_Ent ) )
        {
            
        }
        
        if ( pev ( i_Ent, pev_iuser1 ) )
        {
            if ( pev ( i_Ent, pev_waterlevel ) > 1 )
            {
                set_pev ( i_Ent, pev_flags, FL_KILLME );
            }
            
            static Float:f_Frame; pev ( i_Ent, pev_frame, f_Frame );
        
            if ( pev ( i_Ent, pev_impulse ) > 1 )
            {
                if ( f_Frame < pev ( i_Ent, pev_impulse ) - 1 )
                {
                    set_pev ( i_Ent, pev_frame, f_Frame + 1.0 );
                }
                else
                {
                    set_pev ( i_Ent, pev_frame, 0.0 );
                }
            }
            
            static Float:vf_Velocity[ Coord_e ]; pev ( i_Ent, pev_velocity, vf_Velocity );
            VectorScale ( vf_Velocity, 0.84, vf_Velocity );
            set_pev ( i_Ent, pev_velocity, vf_Velocity );
            
            static Float:vf_Color[ Coord_e ]; pev ( i_Ent, pev_rendercolor, vf_Color );
            vf_Color[ x ] = floatclamp ( vf_Color[ x ] + 50.0, 0.0, 255.0 );
            vf_Color[ y ] = floatclamp ( vf_Color[ y ] + 50.0, 0.0, 255.0 );
            set_pev ( i_Ent, pev_rendercolor, vf_Color );
            
            static Float:f_Brightness; pev ( i_Ent, pev_renderamt, f_Brightness );

            if ( f_Brightness > pev ( i_Ent, pev_iuser2 ) - 1 )
            {
                set_pev ( i_Ent, pev_renderamt, f_Brightness - pev ( i_Ent, pev_iuser2 ) );
            }
            else
            {
                set_pev ( i_Ent, pev_flags, FL_KILLME );
            }
            
            static Float:f_Scale, Float:f_ScaleAdd;
            
            pev ( i_Ent, pev_scale, f_Scale );
            pev ( i_Ent, pev_frags, f_ScaleAdd );
            
            if ( f_Scale >= 1.0 )
            {
                set_pev ( i_Ent, pev_rendermode, kRenderTransAdd );
            }
            
            set_pev ( i_Ent, pev_scale, f_Scale + f_ScaleAdd );
            set_pev ( i_Ent, pev_nextthink, get_gametime () + 0.05 );
        }
    }
    
    
    public Forward_Touch ( const i_Ent, const i_Other )
    {
        if ( pev ( i_Ent, pev_iuser1 ) )
        {
            if ( pev ( i_Ent, pev_modelindex ) == pev ( i_Other, pev_modelindex ) )
            {
                return FMRES_IGNORED;
            } 
            
            if ( IsBSPModel ( i_Other ) )
            {
                set_pev ( i_Ent, pev_velocity, Float:{ 0.0, 0.0, 0.0 } );
            }
            else if ( pev ( i_Other, pev_solid ) > SOLID_TRIGGER )
            {
                static Float:vf_Velocity[ Coord_e ], Float:vf_OVelocity[ Coord_e ];
            
                pev ( i_Ent, pev_velocity, vf_Velocity );
                pev ( i_Other, pev_velocity, vf_OVelocity );
                
                VectorMA ( vf_OVelocity, 0.5, vf_Velocity, vf_Velocity );
                set_pev ( i_Ent, pev_velocity, vf_Velocity );
                
                static Float:f_DmgTime; pev ( i_Ent, pev_dmgtime, f_DmgTime );
                
                if ( f_DmgTime <= get_gametime () )
                {
                    static Float:f_Scale, Float:f_ScaleAdd;
                    
                    pev ( i_Ent, pev_scale, f_Scale );
                    pev ( i_Ent, pev_frags, f_ScaleAdd );
                    
                    set_pev ( i_Ent, pev_scale, f_Scale + f_ScaleAdd );
                }
                
                static Float:f_TakeDamage; pev ( i_Other, pev_takedamage, f_TakeDamage );
                
                if ( f_TakeDamage && pev ( i_Ent, pev_dmg ) > 0 )
                {
                    set_pev ( i_Ent, pev_movetype, MOVETYPE_NONE );
                    set_pev ( i_Ent, pev_solid, SOLID_NOT );
                    set_pev ( i_Ent, pev_modelindex, gi_Flame2 );
                    
                }
            }
            
            set_pev ( i_Ent, pev_dmgtime, get_gametime () + 0.2 );
        }
        
        return FMRES_IGNORED;
    }
    
    
    Attack ( const id, const i_FireMode )
    {
        if ( gi_FireMode[ id ] != i_FireMode )
        {
            if ( gi_FireState[ id ] != FIRE_OFF )
            {
                EndAttack ( id );
                return;
            }
            else
            {
                gi_FireMode[ id ] = i_FireMode;
            }
        }
        
        if ( pev ( id, pev_waterlevel ) == 3 )
        {
            gi_FireState[ id ] != FIRE_OFF ? EndAttack ( id ) : UTIL_PlayEmptySound( id );
            
            wpn_set_float ( gi_WeaponId, wpn_refire_rate1, 1.0 );
            wpn_set_float ( gi_WeaponId, wpn_refire_rate2, 1.0 );
                    
            return;
        }
        
        static Float:vf_Aiming[ Coord_e ], Float:vf_Source[ Coord_e ];
        UTIL_MakeVector ( id, v_angle );
        
        global_get ( glb_v_forward, vf_Aiming );
        UTIL_GetStartPosition ( id, 8.0, 2.0, -4.0, vf_Source );
        
        switch ( gi_FireState[ id ] )
        {
            case FIRE_OFF :
            {
                if ( !HasAmmo ( id ) )
                {
                    UTIL_PlayEmptySound ( id );
                    UpdateRefireRate ( 0.25, 0.25 );
                    return;
                }
                
                static Float:f_CurrTime; f_CurrTime = get_gametime ();
                
                gf_NextAmmoBurn[ id ] = f_CurrTime;
                wpn_playanim ( id, flame_fire );
                
                emit_sound ( id, CHAN_WEAPON, gi_FireMode[ id ] == FIRE_PRI ? gs_FlameRun1 : gs_FlameRun2, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                
                gi_FireState[ id ] = FIRE_CHARGE;
                gf_TimeWeaponIdle[ id ] = f_CurrTime + 0.1;
                
                UpdateRefireRate ();
            }
            case FIRE_CHARGE :
            {
                Fire ( id, vf_Source, vf_Aiming );
                
                if ( !HasAmmo ( id ) )
                {
                    EndAttack ( id );
                    gi_FireState[ id ] = FIRE_OFF;
                    
                    UpdateRefireRate ( 1.0, 1.0 );
                }
            }
        }
    }
    
    
    Fire ( const id, const Float:vf_Source[], const Float:vf_Dir[] )
    {
        static Float:f_CurrTime; f_CurrTime = get_gametime ();
        
        if ( gf_NextAmmoBurn[ id ] <= f_CurrTime )
        {
            // UseAmmo ( 1 );
            gf_NextAmmoBurn[ id ] = f_CurrTime + ( gi_FireMode[ id ] == FIRE_PRI ? 0.25 : 0.2 );
        }
        
        static Float:vf_Temp[ Coord_e ], Float:vf_Forward[ Coord_e ];
        
        VectorCopy ( vf_Dir, vf_Temp );
        
        vf_Temp[ x ] = vf_Temp[ x ] * ( gi_FireMode[ id ] == FIRE_PRI ? 60 : 120 ) + random_float ( -1.0, 1.0 );
        vf_Temp[ y ] = vf_Temp[ y ] * ( gi_FireMode[ id ] == FIRE_PRI ? 60 : 120 ) + random_float ( -1.0, 1.0 );
        vf_Temp[ z ] = vf_Temp[ z ] * ( gi_FireMode[ id ] == FIRE_PRI ? 60 : 120 );
        
        global_get ( glb_v_forward, vf_Forward );
        
        VectorScale ( vf_Temp, 8.0, vf_Temp );
        VectorMA ( vf_Source, 2.0, vf_Forward, vf_Forward );
        
        CreateFlame ( id, vf_Forward, vf_Temp, 0.1, 0.05, 10.0, 255, 20, random_num ( 0, 1 ) ? true : false );
    }
    
    
    CreateFlame ( const i_Owner, const Float:vf_Origin[], const Float:vf_Velocity[], Float:f_Scale, Float:f_ScaleAdd, Float:f_Damage, i_Brightness, i_BrDelta, bool:b_DynLight )
    {
        static i_Cloud; i_Cloud = engfunc ( EngFunc_CreateNamedEntity, gi_CloudClass );
        client_print ( 0, print_chat, "cloud = %d", i_Cloud );
        
        set_pev ( i_Cloud, pev_classname, "wpn_cloud_effect" );
        set_pev ( i_Cloud, pev_solid, SOLID_NOT );
        set_pev ( i_Cloud, pev_origin, vf_Origin );
        set_pev ( i_Cloud, pev_velocity, vf_Velocity );
        set_pev ( i_Cloud, pev_modelindex, gi_Flame );
        set_pev ( i_Cloud, pev_owner, i_Owner );
        set_pev ( i_Cloud, pev_dmg, f_Damage );
        set_pev ( i_Cloud, pev_renderamt, i_Brightness * 1.0 );
        set_pev ( i_Cloud, pev_iuser2, i_BrDelta );
        set_pev ( i_Cloud, pev_scale, f_Scale );
        set_pev ( i_Cloud, pev_frags, f_ScaleAdd );
        
        FlameSpawn ( i_Cloud );
        
        if ( b_DynLight ) 
        {
            set_pev ( i_Cloud, pev_effects, pev ( i_Cloud, pev_effects ) | EF_DIMLIGHT );
        }
    }
    
    
    FlameSpawn ( const i_Cloud )
    {
        set_pev ( i_Cloud, pev_movetype, MOVETYPE_FLY );
        set_pev ( i_Cloud, pev_solid, SOLID_SLIDEBOX );
        set_pev ( i_Cloud, pev_takedamage, DAMAGE_NO );
        set_pev ( i_Cloud, pev_flags, FL_FLY );
        
        static Float:vf_Origin[ Coord_e ]; pev ( i_Cloud, pev_origin, vf_Origin );
        
        engfunc ( EngFunc_SetOrigin, i_Cloud, vf_Origin );
        engfunc ( EngFunc_SetSize, i_Cloud, Float:{ 0.0, 0.0, 0.0 }, Float:{ 0.0, 0.0, 0.0 } );
    
        set_pev ( i_Cloud, pev_impulse, gi_FlameFrameCnt );
        set_pev ( i_Cloud, pev_frame, random_num ( 0, pev ( i_Cloud, pev_impulse ) - 1 ) * 1.0 );
        set_pev ( i_Cloud, pev_framerate, 1.0 );

        set_pev ( i_Cloud, pev_rendercolor, Float:{ 100.0, 80.0, 255.0 } );
        set_pev ( i_Cloud, pev_rendermode, kRenderTransAdd );
        set_pev ( i_Cloud, pev_gravity, -1.0 );
        set_pev ( i_Cloud, pev_renderfx, kRenderFxPulseFast );
        
        static Float:f_Time; f_Time = get_gametime ();
        
        set_pev ( i_Cloud, pev_dmgtime, f_Time );
        set_pev ( i_Cloud, pev_iuser1, 1 );
        set_pev ( i_Cloud, pev_nextthink, f_Time + 0.02 );
    }
    
    
    EndAttack ( const id )
    {
        if ( gi_FireState[ id ] != FIRE_OFF )
        {
            emit_sound ( id, CHAN_WEAPON, gi_FireMode[ id ] == FIRE_PRI ? gs_FlameRun1 : gs_FlameRun2, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM );
        }
        
        gi_FireState[ id ] = FIRE_OFF;
        gf_TimeWeaponIdle[ id ] = get_gametime () + 0.1;
        
        UpdateRefireRate ( 0.5, 0.5 );
    }
    
    
    WeaponIdle ( const id )
    {
        if ( gi_FireState[ id ] != FIRE_OFF )
        {
            return;
        }
        
        static Float:f_CurrTime; f_CurrTime = get_gametime ();
        
        if ( gf_TimeWeaponIdle[ id ] > f_CurrTime )
        {
            return;
        }

        wpn_playanim ( id, random_num ( flame_idle, flame_fidget ) );
        gf_TimeWeaponIdle[ id ] = f_CurrTime + random_float ( 10.0, 15.0 );
        
        UpdateRefireRate ( 0.8, 0.2 );
    }
    
    
    bool:HasAmmo ( const id )
    {
    
        return true;
    }
    
    
    UpdateRefireRate ( const Float:f_Refire1 = 0.0, const Float:f_Refire2 = 0.0 )
    {
        wpn_set_float ( gi_WeaponId, wpn_refire_rate1, f_Refire1 );
        wpn_set_float ( gi_WeaponId, wpn_refire_rate2, f_Refire2 );
    }
    
    
    UTIL_GetStartPosition ( const id, const Float:i_Forward = 0.0, const Float:i_Right = 0.0, const Float:i_Up = 0.0, Float:vf_Source[] )
    {
        UTIL_MakeVector ( id, v_angle + punchangle );
        UTIL_GetGunPosition ( id, vf_Source );

        static FLoat:vf_Forward[ Coord_e ], Float:vf_Right[ Coord_e ], Float:vf_Up[ Coord_e ];

        if ( i_Forward > 0.0 ) global_get ( glb_v_forward, vf_Forward );
        if ( i_Right   > 0.0 ) global_get ( glb_v_right, vf_Right );
        if ( i_Up      > 0.0 ) global_get ( glb_v_up, vf_Up );

        vf_Source[ x ] += vf_Forward[ x ] * i_Forward + vf_Right[ x ] * i_Right + vf_Up[ x ] * i_Up;
        vf_Source[ y ] += vf_Forward[ y ] * i_Forward + vf_Right[ y ] * i_Right + vf_Up[ y ] * i_Up;
        vf_Source[ z ] += vf_Forward[ z ] * i_Forward + vf_Right[ z ] * i_Right + vf_Up[ z ] * i_Up;
    }
    
    
    UTIL_GetGunPosition ( const id, Float:vf_Source[] )
    {
        static Float:vf_Origin[ Coord_e ], Float:vf_ViewOfs[ Coord_e ];

        pev ( id, pev_origin, vf_Origin );
        pev ( id, pev_view_ofs, vf_ViewOfs );

        VectorAdd ( vf_Origin, vf_ViewOfs, vf_Source );
    }
    
    
    UTIL_MakeVector ( const id, const i_Bits )
    {
        static Float:vf_PunchAngles[ Coord_e ], Float:vf_vAngles [ Coord_e ];

        if ( i_Bits & v_angle )    pev ( id, pev_v_angle, vf_vAngles );
        if ( i_Bits & punchangle ) pev ( id, pev_punchangle, vf_PunchAngles );

        if ( i_Bits & ( v_angle & punchangle ) ) VectorAdd ( vf_vAngles, vf_PunchAngles, vf_vAngles );
        engfunc ( EngFunc_MakeVectors, vf_vAngles );
    }
    
    
    UTIL_PlayEmptySound ( const id )
    {
        emit_sound ( id, CHAN_WEAPON, "weapons/dryfire1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
    }