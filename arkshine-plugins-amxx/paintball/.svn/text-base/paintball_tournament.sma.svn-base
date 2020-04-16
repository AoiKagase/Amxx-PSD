
    #include <amxmodx>
    #include <fakemeta>
    #include <hamsandwich>

    #define MAX_CLIENTS  32

    #define PBG_SPEED       280.0
    #define PBG_REFIRE_RATE 0.08
    #define PBG_RECOIL      1.0
    #define PBG_RELOAD_TIME 4.0

    #define PBG_AMMO1 20
    #define PBG_AMMO2 40

    /* - - -
     |  Weapon model   |
                 - - - */
        new const
            gs_Model_P[] = "models/p_dm4.mdl",
            gs_Model_V[] = "models/v_dm4.mdl";

    /* - - -
     |    Sequence    |
                - - - */
        enum
        {
            pb_draw,
            pb_shoot,
            pb_idle,
            pb_ball_rel1,
            pb_ball_rel2,
            pb_ball_rel3,
            pb_holster
        };

    new const gs_SoundWeaponPickup[] = "items/gunpickup2.wav";
    new const gs_SoundWeaponReload[] = "weapons/pbg_reload.wav";
    new const gs_SoundWeaponFire  [] = "weapons/pbg_dm4.wav";

    new const gs_BallSprite[] = "sprites/pb.spr";

    new bool:gb_HasStuff [ MAX_CLIENTS + 1 ];
    new bool:gb_IsAlive  [ MAX_CLIENTS + 1 ];

    new Float:gf_NextShot[ MAX_CLIENTS + 1 ];


    #define PGB_STEP_TOUCH pev_iuser1
    enum { SplashTouch = 1 }

    enum _:Coord_e
    {
        Float:x,
        Float:y,
        Float:z
    };

    enum _:EmitSound_t
    {
        chan,
        sound[ 128 ],
        Float:vol,
        Float:attn,
        flag,
        _pitch
    };

    enum _:Angle_e
    {
        Float:pitch,
        Float:yaw,
        Float:roll
    }

    enum ( += 100 )
    {
        TASK_UPDATE_SPEED = 2000,
        TASK_ENABLE_FREEZE,
        TASK_RELOAD_START,
        TASK_DELAY_ANIM,
        TASK_DELAY_EMIT
    }

    enum ( <<= 1 )
    {
        v_angle = 1,
        punchangle
    }

    enum Ammo_e
    {
        wpn_ammo1,
        wpn_ammo2
    }
    
    enum
    {
        ByEntity,
        ByWeaponId
    };
    

    new gi_AmmoState[ MAX_CLIENTS + 1 ][ Ammo_e ];

    new Float:gvf_Forward[ MAX_CLIENTS + 1 ][ Coord_e ];
    new Float:gvf_vAngles[ MAX_CLIENTS + 1 ][ Angle_e ];

    new gi_MaxClients;
    new gi_WeaponStripEnt;

    new gi_AllocKnife;
    new gi_AllocHe;
    new gi_AllocSmoke;
    new gi_Model_P_Alloc;
    new gi_Model_V_Alloc;
    new gi_PaintballAlloc;

    new gi_MsgCurWeapon;
    new gi_MsgAmmoX;

    new bool:gb_FreezeTime;

    #define OFFSET_NEXT_ATTACK_DELAY 83
    #define SetNextAttackDelay(%1,%2)  ( set_pdata_float( %1, OFFSET_NEXT_ATTACK_DELAY, %2 ) )

    #define VectorAdd(%1,%2,%3)   ( %3[ x ] = %1[ x ] + %2[ x ], %3[ y ] = %1[ y ] + %2[ y ], %3[ z ] = %1[ z ] + %2[ z ] )
    #define VectorScale(%1,%2,%3) ( %3[ x ] = %2 * %1[ x ], %3[ y ] = %2 * %1[ y ], %3[ z ] = %2 * %1[ z ] )
    #define VectorLength(%1)      ( floatsqroot ( %1[ x ] * %1[ x ] + %1[ y ] * %1[ y ] + %1[ z ] * %1[ z ] ) )

    #define write_coord_f(%1)     ( engfunc ( EngFunc_WriteCoord, %1 ) )

    new gi_Beam;
    
    public plugin_precache()
    {
        // --| info_playerstart_red / info_playerstart_blue
    
        precache_model ( "sprites/bhit.spr" );
        precache_model ( "sprites/test40.spr" );

        gi_Beam = precache_model ( "sprites/laserbeam.spr" );
        precache_model ( gs_BallSprite );

        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );

        precache_sound ( gs_SoundWeaponReload );
        precache_sound ( gs_SoundWeaponFire );
    }


    public plugin_init ()
    {
        register_plugin ( "Paintball Tournament", "1.0.0", "Arkshine" );

        register_event ( "ResetHUD" , "Event_ResetHUD" , "b" );
        register_event ( "DeathMsg" , "Event_DeathMsg" , "a" );
        register_event ( "CurWeapon", "Event_CurWeapon", "be", "1=1", "2=19", "2=25", "2=9" );

        register_event ( "TextMsg"  , "Event_RoundRestart"  , "a", "2=#Game_will_restart_in" );
        // register_event ( "TextMsg"  , "Event_GameCommencing", "a", "2=#Game_Commencing" );

        register_logevent ( "LogEvent_RoundStart", 2, "1=Round_Start" );
        register_logevent ( "LogEvent_RoundEnd"  , 2, "0=World triggered", "1=Round_End" );

        register_forward ( FM_ClientDisconnect , "Forward_ClientDisconnect" );
        register_forward ( FM_ClientPutInServer, "Forward_ClientPutInServer" );
        register_forward ( FM_CmdStart         , "Foward_CmdStart" );
        register_forward ( FM_Touch            , "Forward_Touch" );
    }


    public plugin_cfg ()
    {
        gi_MaxClients = global_get ( glb_maxClients );
        server_cmd ( "sv_maxvelocity 5000" );

        gi_MsgCurWeapon = get_user_msgid ( "CurWeapon" );
        gi_MsgAmmoX     = get_user_msgid ( "AmmoX" );

        gi_WeaponStripEnt = engfunc ( EngFunc_CreateNamedEntity, engfunc ( EngFunc_AllocString, "player_weaponstrip" ) );

        gi_PaintballAlloc = engfunc ( EngFunc_AllocString, "info_target" );

        gi_AllocKnife = engfunc ( EngFunc_AllocString, "weapon_mp5navy" );
        gi_AllocHe    = engfunc ( EngFunc_AllocString, "weapon_flashbang" );
        gi_AllocSmoke = engfunc ( EngFunc_AllocString, "weapon_smokegrenade" );

        gi_Model_P_Alloc  = engfunc ( EngFunc_AllocString, gs_Model_P );
        gi_Model_V_Alloc  = engfunc ( EngFunc_AllocString, gs_Model_V );

    }


    public Forward_ClientPutInServer ( const id )
    {
        // --| Refill ammos for new player.
        gi_AmmoState[ id ][ wpn_ammo1 ] = PBG_AMMO1;
        gi_AmmoState[ id ][ wpn_ammo2 ] = PBG_AMMO2;
    }


    public Forward_ClientDisconnect ( const id )
    {
        gb_IsAlive[ id ] = false;
    }


    public Foward_CmdStart ( const id, const uc_handle, const seed )
    {
        // --| Not alive or no paintball gun holding. No need to go further.
        if ( !( gb_IsAlive[ id ] || gb_HasStuff[ id ] ) )
        {
            return FMRES_IGNORED;
        }

        // client_print ( id, print_chat, "old_button = %d", pev ( id, pev_oldbuttons ) );
        
        // --| This forward is called very often. 
        // --| The usage of `static` is recommended.
        
        // --| Retrieve the current game time to check the delay.
        static Float:f_CurrentTime; f_CurrentTime = get_gametime ();

        // --| Retrieve the buttons used.
        static i_Buttons; i_Buttons = get_uc ( uc_handle, UC_Buttons );

        // --| Make sure that the player is not reloading.
        if ( task_exists ( TASK_RELOAD_START + id ) )
        {
            return FMRES_HANDLED;
        }

        // --| Player is firing !
        if ( i_Buttons & IN_ATTACK && !( pev ( id, pev_oldbuttons ) & IN_ATTACK ) )
        {
            // --| We remove the button used. We want to fire considering a custom ROF.
            i_Buttons &= ~IN_ATTACK; set_uc ( uc_handle, UC_Buttons, i_Buttons );

            if ( gb_FreezeTime )
            {
                // --| Disallow fire while the freezetime.
                return FMRES_HANDLED;
            }

            if ( gf_NextShot[ id ] > f_CurrentTime )
            {
                // --| We are not allowed to fire yet.
                return FMRES_HANDLED;
            }

            // --| Enough Ammo1 to fire !
            if ( gi_AmmoState[ id ][ wpn_ammo1 ] >= 1 )
            {
                static i_AttackResult;
                i_AttackResult = PaintballGun_Fire ( id );

                if ( i_AttackResult != PLUGIN_HANDLED )
                {
                    static Float:vf_Recoil[ Angle_e ];

                    // --| Decrease Ammo1.
                    gi_AmmoState[ id ][ wpn_ammo1 ] -= 1;

                    // --| Apply recoil force if need.
                    if ( PBG_RECOIL > 0.0 )
                    {
                        vf_Recoil[ pitch ] = random_float ( PBG_RECOIL * -1, 0.0 );   // --| up - down
                        vf_Recoil[ yaw   ] = random_float ( PBG_RECOIL * -1, 0.0 );   // --| right - left
                        vf_Recoil[ roll  ] = 0.0                                      // --| Screen rotation

                        set_pev ( id, pev_punchangle, vf_Recoil );
                    }

                    // --| Update ammo informations at the hud.
                    UpdateHud ( id );

                    // --| Update next shot time.
                    gf_NextShot[ id ] = f_CurrentTime + PBG_REFIRE_RATE;

                    if ( gi_AmmoState[ id ][ wpn_ammo2 ] > 0 && gi_AmmoState[ id ][ wpn_ammo1 ] <= 0 )
                    {
                        PaintballGun_Reload ( id );
                    }
                }
            }
            // --| No more ammo1. If ammo2 is available yet, we can reload.
            else if ( gi_AmmoState[ id ][ wpn_ammo2 ] > 0 )
            {
                PaintballGun_Reload ( id );
            }
            // --| No ammo1/2 at all.
            else
            {
                emit_sound ( id, CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
                gf_NextShot[ id ] = f_CurrentTime + 1.0;
            }
                 
            return FMRES_HANDLED;
        }
        else if ( i_Buttons & IN_RELOAD )
        {
            PaintballGun_Reload ( id );
            return FMRES_HANDLED;
        }

        return FMRES_IGNORED;
    }
    
    
    PaintballGun_Fire ( const id )
    {
        // --| Play shoot animation.
        UTIL_PlayAnimation ( id, pb_shoot );

        // --| Play the fire sound.
        emit_sound ( id, CHAN_AUTO, gs_SoundWeaponFire, VOL_NORM, ATTN_NORM, 0, 93 + random_num ( 0, 15 ) );

        // --| Calculate start position where the ball should pass.
        static Float:vf_Source [ Coord_e ];
        UTIL_GetStartPosition ( id, 10.0, _, _, vf_Source ); // --| forward, right, up

        // --| Calculate the ball speed.
        VectorScale ( gvf_Forward[ id ], 4000.0, gvf_Forward[ id ] );

        // --| Time to create our ball.
        ShootBall ( id, vf_Source );

        return PLUGIN_CONTINUE;
    }


    PaintballGun_Reload ( const id )
    {
        // --| Be sure that we can reload.
        if ( gi_AmmoState[ id ][ wpn_ammo2 ] < 1 )
        {
            // --| Otherwise, don't go further.
            return;
        }

        // --| Play the reload animation.
        UTIL_PlayAnimation ( id, pb_ball_rel1 );
        UTIL_PlayAnimation ( id, pb_ball_rel2, 1.25 );
        UTIL_PlayAnimation ( id, pb_ball_rel3, 3.80 );

        // --| Play the reload sound.
        UTIL_EmitSound ( id, CHAN_AUTO, gs_SoundWeaponReload, random_float ( 0.95, VOL_NORM ), ATTN_NORM, 0, 93 + random_num ( 0, 15 ), 1.25 );

        // --| Prepare to stop the right moment.
        set_task ( PBG_RELOAD_TIME, "EndReload", TASK_RELOAD_START + id );
        
        // --| Allow fire at the end of reload.
        gf_NextShot[ id ] = PBG_RELOAD_TIME + get_gametime();
    }


    public Forward_Touch ( const i_Ent, const i_Other )
    {
        if ( IsPaintball ( i_Ent, ByEntity ) )
        {
            if ( IsPlayer ( i_Other )  )
            {
                client_print ( i_Other, print_chat, "PAF, je suis touché !" );
            }
            else
            {
                client_print ( 0, print_chat, "Pouet !" );

                static Float:vf_Origin[ Coord_e ], Float:vf_Velocity[ Coord_e ], Float:vf_PlaneNormal[ Coord_e ];
                static Float:vf_Spot[ Coord_e ], Float:vf_Angles[ Angle_e ];

                pev ( i_Ent, pev_origin, vf_Origin );
                pev ( i_Ent, pev_velocity, vf_Velocity );

                VectorNormalize ( vf_Velocity );
                engfunc ( EngFunc_TraceLine, vf_Origin, vf_Velocity, IGNORE_MONSTERS, i_Ent, 0 );

                get_tr2 ( 0, TR_vecPlaneNormal, vf_PlaneNormal );
                engfunc ( EngFunc_VecToAngles, vf_PlaneNormal, vf_Angles );

                vf_Angles[ yaw ] += 180.0;
                vf_Angles[ roll ] = random_float ( 0.0, 380.0 );
                set_pev ( i_Ent, pev_angles, vf_Angles );

                // --| Pull out a bit ( 1 unit ) because of entity / light.
                // --|
                VectorAdd ( vf_Origin, vf_PlaneNormal, vf_Origin );
                set_pev ( i_Ent, pev_origin, vf_Origin );


                set_pev ( i_Ent, pev_velocity, Float:{ 0.0, 0.0, 0.0 } ); // --| Stop moving.
                set_pev ( i_Ent, pev_solid, SOLID_NOT );                  // --| No collision anymore.
                set_pev ( i_Ent, pev_movetype, MOVETYPE_NONE );

                engfunc ( EngFunc_SetModel, i_Ent,  "sprites/test40.spr" );

                new Float:r = random_num ( 1, 255 ) * 1.0, Float:g = random_num ( 1, 255 ) * 1.0, Float:b = random_num ( 1, 255 ) * 1.0;
                SetRendering ( i_Ent, kRenderFxNone, r, g, b, kRenderTransAdd, 255.0 );

                // client_print ( 0, print_chat, "r = %.0f ; g = %.0f ; b = %.0f", r, g, b );

                set_pev ( i_Ent, pev_scale, 0.1 );
                set_pev ( i_Ent, pev_frame, random_num ( 0, 9 ) * 1.0 );

                set_pev ( i_Ent, pev_flags, FL_ALWAYSTHINK );
            }
        }
    }


    public Event_DeathMsg ()
    {
        gb_IsAlive [ read_data ( 2 ) ] = false; // --| Optimization against is_user_alive ().
    }
    
    
    public Event_CurWeapon ( const id )
    {
        gb_HasStuff[ id ] = false;
        
        if ( IsPaintball ( read_data ( 2 ), ByWeaponId ) )
        {
            client_print ( id, print_chat, "Je change d'arme" );
            gb_HasStuff[ id ] = true;
            
            // --| Apply paintball gun model. 
            set_pev ( id, pev_viewmodel  , gi_Model_V_Alloc ); // --| v_ model.
            set_pev ( id, pev_weaponmodel, gi_Model_P_Alloc ); // --| p_ model.
                
            // --| ROF is manually managed. Be sure that to block for a long time the next attack time.
            SetNextAttackDelay ( id, 9999.0 );
                
            // --| Player draws the paintball gun.
            UTIL_PlayAnimation ( id, pb_draw );

            // --| Be sure to reset ammos.
            gi_AmmoState[ id ][ wpn_ammo1 ] = PBG_AMMO1;
            gi_AmmoState[ id ][ wpn_ammo2 ] = PBG_AMMO2;

            // --| Then we update the Hud.
            UpdateHud ( id );
        }
    }


    public Event_ResetHUD ( const id )
    {
        log_amx ( "Event_ResetHUD" );

        // --| Not alive, we ignore.
        if ( !is_user_alive ( id ) )
        {
            return;
        }

        /* // --| Avoid to call 2 times at restart.
        if ( gb_OnRestart[ id ] )
        {
            gb_OnRestart[ id ] = false;
            return;
        } */

        gb_IsAlive [ id ] = true;  // --| Optimization against is_user_alive ().
        gf_NextShot[ id ] = 0.0;

        // --| If task is not set yet, we create it.
        if ( !task_exists ( id ) )
        {
            client_print ( id, print_center, "GET READY !" );
            set_task ( 0.5, "EquipPlayer", id );
        }
    }


    /* public Event_GameCommencing ()
    {
        log_amx ( "Event_GameCommencing" );

        ResetVariables ();
    }*/


    public Event_RoundRestart ()
    {
        log_amx ( "Event_RoundRestart" );

        /* for ( new id = 1; id <= gi_MaxClients; id++ )  if ( gb_IsAlive[ id ] )
        {
            gb_OnRestart[ id ] = true;
        } */

        if ( !task_exists ( TASK_ENABLE_FREEZE ) )
        {
            // --| No task has been created by now, create one.
            set_task ( float ( read_data ( 3 ) ) - 0.1, "EnableFreeze", TASK_ENABLE_FREEZE );
        }
    }


    public LogEvent_RoundStart ()
    {
        log_amx ( "LogEvent_RoundStart" );

        gb_FreezeTime = false;

        // --| Create update speed task (delayed because of possibility to be overwritten by CS)
        set_task ( 0.1, "UpdateSpeed", TASK_UPDATE_SPEED );
    }


    public LogEvent_RoundEnd()
    {
        log_amx ( "LogEvent_RoundEnd" );
        // gb_RoundStart = false;

        set_task ( 4.0, "EnableFreeze", TASK_ENABLE_FREEZE );
    }


    public UpdateSpeed()
    {
        for ( new id = 1; id <= gi_MaxClients; id++ )
        {
            set_pev ( id, pev_maxspeed, PBG_SPEED );

            if ( is_user_alive ( id ) )
            {
                UpdateHud ( id );
            }
        }
    }


    public EnableFreeze ()
    {
        gb_FreezeTime = true
    }


    public EquipPlayer ( const id )
    {
        if ( gb_IsAlive [ id ] )
        {
            UTIL_StripAllWeapons ( id );
            GiveWeaponsSet ( id );
        }
    }


    // --| Just for readability. 
    #define PaintballGun      gi_AllocKnife
    #define GrenadeFlashbang  gi_AllocHe
    #define GrenadeSmoke      gi_AllocSmoke

    GiveWeaponsSet ( const id )
    {
        // --| Give 1 paintball gun, 2 flashbang and 1 smoke.
        UTIL_GiveWeapon ( id, PaintballGun );
        UTIL_GiveWeapon ( id, GrenadeFlashbang );
        UTIL_GiveWeapon ( id, GrenadeFlashbang );
        UTIL_GiveWeapon ( id, GrenadeSmoke );
        
        // --| We should have our weapons set.
        gb_HasStuff[ id ]  = true;
    }

    
    ShootBall ( const id, const Float:vf_Source[] )
    {
        static i_Ball; i_Ball = engfunc ( EngFunc_CreateNamedEntity, gi_PaintballAlloc );

        if ( i_Ball )
        {
            set_pev ( i_Ball, pev_classname, "pbg_splash" );

            set_pev ( i_Ball, pev_owner, id );
            set_pev ( i_Ball, pev_origin, vf_Source );
            set_pev ( i_Ball, pev_angles, gvf_vAngles[ id ] );

            SpawnBall ( i_Ball, vf_Source );

            set_pev ( i_Ball, pev_velocity, gvf_Forward[ id ] );
            set_pev ( i_Ball, PGB_STEP_TOUCH, SplashTouch );
        }
    }


    SpawnBall ( const i_Ball, const Float:vf_Origin[] )
    {
        set_pev ( i_Ball, pev_movetype, MOVETYPE_BOUNCE );
        set_pev ( i_Ball, pev_solid, SOLID_SLIDEBOX );
        set_pev ( i_Ball, pev_gravity, 0.6 );
        set_pev ( i_Ball, pev_friction, 0.8 );

        engfunc ( EngFunc_SetModel , i_Ball, "sprites/pb.spr" );
        engfunc ( EngFunc_SetSize  , i_Ball, Float:{ -1.0, -1.0, -1.0 }, Float:{ 1.0, 1.0, 1.0 } );
        engfunc ( EngFunc_SetOrigin, i_Ball, vf_Origin );

        set_pev ( i_Ball, pev_scale, 0.02 );
    }


    public EndReload ( const i_TaskId )
    {
        new id = i_TaskId - TASK_RELOAD_START;

        // --| Calculate amount of bullets that should be reloaded.
        new i_Reload, i_TotalReload = PBG_AMMO1 - gi_AmmoState[ id ][ wpn_ammo1 ];

        // --| Make sure player really has this amount of bullets, otherwise reload with the remaining bullets.
        i_Reload = ( i_TotalReload <= gi_AmmoState[ id ][ wpn_ammo2 ] ) ? i_TotalReload : gi_AmmoState[ id ][ wpn_ammo2 ];

        gi_AmmoState[ id ][ wpn_ammo1 ] += i_Reload;
        gi_AmmoState[ id ][ wpn_ammo2 ] -= i_Reload;

        UpdateHud ( id );
    }


    StopReload ( const id )
    {
        if ( task_exists ( TASK_RELOAD_START + id ) )
        {
            remove_task ( TASK_RELOAD_START + id );
        }
    }


    UpdateHud ( const id )
    {
        message_begin ( MSG_ONE, gi_MsgCurWeapon, _, id );
        write_byte ( 1 );
        write_byte ( 20 );
        write_byte ( gi_AmmoState[ id ][ wpn_ammo1 ] )
        message_end ();

        message_begin ( MSG_ONE, gi_MsgAmmoX, _, id );
        write_byte ( 3 );
        write_byte ( gi_AmmoState[ id ][ wpn_ammo2 ] );
        message_end ()
    }


    UTIL_GetStartPosition ( const id, const Float:i_Forward = 0.0, const Float:i_Right = 0.0, const Float:i_Up = 0.0, Float:vf_Source[] )
    {
        UTIL_MakeVector ( id, v_angle + punchangle );
        UTIL_GetGunPosition ( id, vf_Source );

        static Float:vf_Right[ Coord_e ], Float:vf_Up[ Coord_e ];

        if ( i_Forward > 0.0 ) global_get ( glb_v_forward, gvf_Forward[ id ] );
        if ( i_Right   > 0.0 ) global_get ( glb_v_right, vf_Right );
        if ( i_Up      > 0.0 ) global_get ( glb_v_up, vf_Up );

        vf_Source[ x ] += gvf_Forward[ id ][ x ] * i_Forward + vf_Right[ x ] * i_Right + vf_Up[ x ] * i_Up;
        vf_Source[ y ] += gvf_Forward[ id ][ y ] * i_Forward + vf_Right[ y ] * i_Right + vf_Up[ y ] * i_Up;
        vf_Source[ z ] += gvf_Forward[ id ][ z ] * i_Forward + vf_Right[ z ] * i_Right + vf_Up[ z ] * i_Up;
    }


    UTIL_MakeVector ( const id, const i_Bits )
    {
        static Float:vf_Punchangles[ Coord_e ], Float:vf_Angles [ Coord_e ];

        if ( i_Bits & v_angle )    pev ( id, pev_v_angle, gvf_vAngles[ id ] );
        if ( i_Bits & punchangle ) pev ( id, pev_punchangle, vf_Punchangles );

        VectorAdd ( gvf_vAngles[ id ], vf_Punchangles, vf_Angles );
        engfunc ( EngFunc_MakeVectors, vf_Angles );
    }


    UTIL_GetGunPosition ( const id, Float:vf_Source[] )
    {
        static Float:vf_Origin[ Coord_e ], Float:vf_ViewOfs[ Coord_e ];

        pev ( id, pev_origin, vf_Origin );
        pev ( id, pev_view_ofs, vf_ViewOfs );

        VectorAdd ( vf_Origin, vf_ViewOfs, vf_Source );
    }


    UTIL_StripAllWeapons ( const id )
    {
        dllfunc( DLLFunc_Spawn, gi_WeaponStripEnt );
        dllfunc( DLLFunc_Use, gi_WeaponStripEnt, id );
    }


    UTIL_GiveWeapon ( const id, const i_Weapon )
    {
        new i_Ent = engfunc( EngFunc_CreateNamedEntity, i_Weapon );

        if ( !pev_valid( i_Ent ) )
        {
            return;
        }

        set_pev ( i_Ent, pev_spawnflags, SF_NORESPAWN );
        dllfunc ( DLLFunc_Spawn, i_Ent );

        if ( !ExecuteHamB ( Ham_AddPlayerItem, id, i_Ent ) && pev_valid ( i_Ent ) )
        {
            set_pev ( i_Ent, pev_flags, pev ( i_Ent, pev_flags ) | FL_KILLME );
            return;
        }

        ExecuteHamB ( Ham_Item_AttachToPlayer, i_Ent, id );
        emit_sound ( id, CHAN_AUTO, gs_SoundWeaponPickup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
    }


    UTIL_PlayAnimation ( const id, const i_Animation, const Float:f_Delay = 0.0 )
    {
        if ( f_Delay > 0.0 )
        {
            new a_Param[ 1 ];
            a_Param[ 0 ] = i_Animation;

            remove_task ( id + TASK_DELAY_ANIM );
            set_task ( f_Delay, "UTIL_DelayedPlayAnimation", id + TASK_DELAY_ANIM, a_Param, 1 );

            return;
        }

        set_pev ( id, pev_weaponanim, i_Animation );

        message_begin ( MSG_ONE, SVC_WEAPONANIM, _, id );
        write_byte ( i_Animation );
        write_byte ( pev ( id, pev_body ) );
        message_end ();
    }


    UTIL_EmitSound ( const id, const i_Channel, const s_Sound[], const Float:f_Volume, const Float:f_Attn, const i_Flags, const i_Pitch, const Float:f_Delay = 0.0 )
    {
        if ( f_Delay > 0.0 )
        {
            new a_Params[ EmitSound_t ];

            a_Params[ chan   ] = i_Channel;
            a_Params[ vol    ] = _:f_Volume;
            a_Params[ attn   ] = _:f_Attn;
            a_Params[ flag   ] = i_Flags;
            a_Params[ _pitch ] = i_Pitch;

            copy ( a_Params[ sound ], charsmax ( a_Params ), s_Sound );

            set_task ( f_Delay, "UTIL_DelayEmitSound", id + TASK_DELAY_EMIT, a_Params, EmitSound_t );
            return;
        }

        emit_sound ( id, i_Channel, s_Sound, f_Volume, f_Attn, i_Flags, i_Pitch );
    }


    public UTIL_DelayedPlayAnimation ( const a_Param[], const i_TaskId )
    {
        UTIL_PlayAnimation ( i_TaskId - TASK_DELAY_ANIM, a_Param[ 0 ] );
    }


    public UTIL_DelayEmitSound ( const a_Params[], const i_TaskId )
    {
        UTIL_EmitSound ( i_TaskId - TASK_DELAY_EMIT, a_Params[ chan ], a_Params[ sound ], a_Params[ vol ], a_Params[ attn ], a_Params[ flag ], a_Params[ _pitch ] );
    }


    VectorMA ( const Float:vf_Add[], const Float:f_Scale, const Float:vf_Mult[], Float:vf_Output[] )
    {
        vf_Output[ x ] = vf_Add[ x ] + vf_Mult[ x ] * f_Scale;
        vf_Output[ y ] = vf_Add[ y ] + vf_Mult[ y ] * f_Scale;
        vf_Output[ z ] = vf_Add[ z ] + vf_Mult[ z ] * f_Scale;
    }


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

    
    SetRendering( const i_Ent, const fx = kRenderFxNone, const Float:r = 0.0, const Float:g = 0.0, const Float:b = 0.0, const render = kRenderNormal, const Float:amount = 16.0 )
    {
        static Float:rendercolor[3];

        rendercolor[ 0 ] = r;
        rendercolor[ 1 ] = g;
        rendercolor[ 2 ] = b;

        set_pev ( i_Ent, pev_renderfx, fx )
        set_pev ( i_Ent, pev_rendercolor, rendercolor );
        set_pev ( i_Ent, pev_rendermode, render );
        set_pev ( i_Ent, pev_renderamt, amount );
    }
    
    
    bool:IsPlayer ( const id )
    {
        return bool:( 1 <= id <= gi_MaxClients &&  gb_IsAlive[ id ] );
    }
    
    
    #define WPN_PAINTBALL_GUN  CSW_MP5NAVY
    
    bool:IsPaintball ( const index, const i_Flag )
    {
        switch ( i_Flag )
        {
            case ByEntity   : return bool:( pev_valid ( index ) && pev ( index, PGB_STEP_TOUCH ) );
            case ByWeaponId : return bool:( index == WPN_PAINTBALL_GUN );
        }
    
        return false;
    }






