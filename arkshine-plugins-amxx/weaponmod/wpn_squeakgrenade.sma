
   /* - - - - - - - - - - -

        AMX Mod X script.

          | Author  : Arkshine
          | Plugin  : WPN Squeak Grenade ( HL1 )
          | Version : v1.0.2

        (!) Support : http://forums.space-headed.net/viewtopic.php?t=425
        
        This program is free software; you can redistribute it and/or modify it
        under the terms of the GNU General Public License as published by the
        Free Software Foundation; either version 2 of the License, or (at
        your option) any later version.

        This program is distributed in the hope that it will be useful, but
        WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
        General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this program; if not, write to the Free Software Foundation,
        Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

        ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~


        Description :
        - - - - - - -
            Basically, it's almost the same weapon that you can see in Half-life 1.

            Snarks are small, red, and bulbous, with a large (in relation to body porportion) 
            single green eye and a large pincer-like mandible. Snarks are normally calm creatures 
            that show little signs of intelligence, but if they see any living creature other
            than another Snark, they immediately begin to attack it. They attack aggressively, 
            persistently, and erratically, leaping and biting at their target.

            A full description can be found here : http://half-life.wikia.com/wiki/Snark .


        Requirement :
        - - - - - - -
            * CS 1.6 / CZ / DoD / TFC / TS
            * AMX Mod X 1.7x or higher.
            * WeaponMod / GameInfo ( the latest version )

            
        Modules :
        - - - - -
            * Fakemeta
            
            
        Changelog :
        - - - - - -
            v1.0.2 : [ 6 jul 2008 ]
            
                (!) Fixed 'invalid entity' error. It was happening while checking the enemy's health and if enemy was a spawned monster.
                (!) Fixed typo. You was getting a crash by lauching snark and if a spawned monster was around.
                
            v1.0.1 : [ 6 jul 2008 ]
            
                (!) Fixed. Monsters was not tracked by snarks.
        
            v1.0.0 : [ 5 jul 2008 ]

                (+) Initial release.

                
        Credits :
        - - - - -
            * HLSDK
            * DevconeS
            * VEN
            * Sproily ( Alternative models )

    - - - - - - - - - - - */
    
    #include <amxmodx>
    #include <fakemeta>
    #include <weaponmod_stocks>
    #include <xs>


    #define Plugin  "WPN Squeak Grenade"
    #define Version "1.0.2"
    #define Author  "Arkshine"

    
    /* - - - - - - -
     |   Uncomment if you want to use the alternative model. |
                                               - - - - - - - */
        // #define ALTERNATIVE_MODEL
        
    /* - - -
     |  Customization  |
                 - - - */
        #define SNARK_REFIRE_RATE    0.3   // Refire rate for primary attack
        #define SNARK_RUN_SPEED      250.0 // Player's speed when holding the weapon.
        #define SNARK_MAX_AMMOS      5     // Max snarks
        #define SNARK_COST           4352  // Cost of the weapon.
        
        #define SNARK_BLOOD_COLOR    195   // Yellow by default.
        #define SNARK_FOV            0     // Snark's field of view. ( 0 = 180° )
        #define SNARK_HEALTH         2.0   // Max snark's health ( float ).
        #define SNARK_GRAVITY        0.5   // Snark's gravity ( float ).
        #define SNARK_FRICTION       0.5   // Snark's friction ( float ).
        #define SNARK_DAMAGE         5.0   // Snark's damage ( float ).
        #define SNARK_BLOOD_AMOUNT   80    // Amout of blood when snark explodes.
        #define SNARK_DETONATE_DELAY 15.0  // Time before exploding. ( float )
        #define SNARK_SEARCH_RADIUS  512.0 // How far should the snarks searh enemy? ( float ).
        #define SNARK_THROW_VELOCITY 200.0 // Snark's velocity when player throws a snark ( float ).
        
        #define WORLD_MODEL_POSITION 1     // 0 = WM behaviour ; 1 = Lieing on the ground
        #define SNARK_SHOW_TRAIL     1     // 0 = Don't show tracer ; 1 = Show tracers
        
        #define TRAIL_LIFE           40    // Life
        #define TRAIL_WIDTH          5     // Width
        #define TRAIL_RED            10    // Red
        #define TRAIL_GREEN          224   // Red
        #define TRAIL_BLUE           10    // Green
        #define TRAIL_BRIGTHNESS     200   // Blue

    /* - - -
     |  Weapon information   |
                       - - - */
        new
            gs_WpnName [] = "Squeak Grenade",
            gs_WpnShort[] = "snark";

    /* - - -
     |  Weapon models  |
                 - - - */
        new
        #if !defined ALTERNATIVE_MODEL
            gs_Model_P[] = "models/p_squeak.mdl",
            gs_Model_V[] = "models/v_squeak.mdl",
        #else
            gs_Model_P[] = "models/p_alt_squeak.mdl",
            gs_Model_V[] = "models/v_alt_squeak.mdl",
        #endif
            gs_Model_W[] = "models/w_sqknest.mdl";

    /* - - -
     |  Snark sounds  |
                 - - - */
            new const
                gs_SqueakHunt1[] = "squeek/sqk_hunt1.wav",
                gs_SqueakHunt2[] = "squeek/sqk_hunt2.wav",
                gs_SqueakHunt3[] = "squeek/sqk_hunt3.wav";

            new const
                gs_SnarkBlast    [] = "squeek/sqk_blast1.wav",
                gs_SnarkBodySplat[] = "common/bodysplat.wav",
                gs_SnarkDie      [] = "squeek/sqk_die1.wav",
                gs_SnarkAttack   [] = "squeek/sqk_deploy1.wav";

    /* - - -
     |  Snark model   |
                 - - - */
        new
        #if !defined ALTERNATIVE_MODEL
            gs_SnarkModel[] = "models/w_squeak.mdl";
        #else
            gs_SnarkModel[] = "models/w_alt_squeak.mdl";
        #endif

    /* - - -
     |    Sequence   |
               - - - */
        enum
        {
            wsqueak_idle1,
            wsqueak_fidget,
            wsqueak_jump,
            wsqueak_run
        };

        enum
        {
            squeak_idle1,
            squeak_fidgetfit,
            squeak_fidgetnip,
            squeak_down,
            squeak_up,
            squeak_throw
        };

    /* - - -
     |    Custom fields   |
                    - - - */
        #define SG_SNARK_ENEMY   pev_enemy
        #define SG_SNARK_OWNER   pev_iuser2
        #define SG_TOUCH_STEP    pev_iuser3
        #define SG_THINK_STEP    pev_iuser4

        #define SG_NEXT_BS_TIME  pev_fuser1
        #define SG_NEXT_HIT      pev_fuser3
        #define SG_NEXT_HUNT     pev_fuser4
        #define SG_NEXT_ATTACK   pev_fuser2
        #define SG_SNARK_DIE     pev_ltime

        #define SG_SNARK_POSPREV pev_vuser2
        #define SG_SNARK_TARGET  pev_vuser3

    /* - - -
     |    Others stuffs   |
                    - - - */
        #define MAX_CLIENTS   32
        #define NOT_IN_WATER  0
        #define HEAD_IN_WATER 3
        #define NULL          0
        
        #define FCVAR_FLAGS ( FCVAR_SERVER | FCVAR_SPONLY | FCVAR_EXTDLL | FCVAR_UNLOGGED )
        #define SNARK_HEALTH_REF 10000.0

        enum e_Coord
        {
            Float:x,
            Float:y,
            Float:z
        };

        enum
        {
            HuntThink,
            SuperBounceTouch,
            RemoveSnark
        };

        enum
        {
            SnarkHunt,
            SnarkDeploy,
            SnarkHolster,
            SnarkAttack,
            SnarkDie,
            SnarkKilled,
            SnarkRandomHunt
        }

        new bool:gb_JustThrown[ MAX_CLIENTS + 1 ];
        new Float:gf_TimeWeaponIdle[ MAX_CLIENTS + 1 ];

        new gi_Snark [ MAX_CLIENTS + 1 ];
        new gi_Weapon[ MAX_CLIENTS + 1 ];

        new Float:gvf_PlayerOrigin  [ MAX_CLIENTS + 1 ][ e_Coord ];
        new Float:gvf_PlayerVelocity[ MAX_CLIENTS + 1 ][ e_Coord ];
        new Float:gvf_SnarkOrigin   [ MAX_CLIENTS + 1 ][ e_Coord ];
        new Float:gvf_SnarkVelocity [ MAX_CLIENTS + 1 ][ e_Coord ];
        new Float:gvf_Angles        [ MAX_CLIENTS + 1 ][ e_Coord ];
        new Float:gvf_Forward       [ MAX_CLIENTS + 1 ][ e_Coord ];

        new const Float:gvf_HullMin    [ e_Coord ] = { -16.0, -16.0, -36.0 };
        new const Float:gvf_DuckHullMin[ e_Coord ] = { -16.0, -16.0, -18.0 };

        new const gs_SnarkClassname[] = "wpn_snark";
        new const gs_NullSound[] = "common/null.wav";

        new gi_Weaponid;
        new gi_SnarkClass;
        new gi_MaxEntities;
        new gi_BloodSpray;
        new gi_BloodDrop;
        new gi_FriendlyFire;
        new gi_SmokeTrail;
        
        new const gi_ShowTrail     = SNARK_SHOW_TRAIL;
        new const gi_WorldModelPos = WORLD_MODEL_POSITION;


    /* - - -
     |    Macro   |
            - - - */
        #if !defined charsmax
            #define charsmax(%1)  ( sizeof ( %1 ) - 1 )
        #endif

        #define IsDucking(%1)             ( pev ( %1, pev_flags ) & FL_DUCKING )

        #define message_begin_f(%1,%2,%3) ( engfunc ( EngFunc_MessageBegin, %1, %2, %3 ) )
        #define write_coord_f(%1)         ( engfunc ( EngFunc_WriteCoord, %1 ) )


    public plugin_precache ()
    {
        // -- Weapon models
        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );
        precache_model ( gs_Model_W );

        // -- Weapon sounds
        precache_sound ( gs_SqueakHunt2 );
        precache_sound ( gs_SqueakHunt3 );

        // -- Snark model
        precache_model ( gs_SnarkModel );

        // -- Snark sounds
        precache_sound ( gs_SnarkBlast );
        precache_sound ( gs_SnarkBodySplat );
        precache_sound ( gs_SnarkDie );
        precache_sound ( gs_SqueakHunt1 );
        precache_sound ( gs_SqueakHunt2 );
        precache_sound ( gs_SqueakHunt3 );
        precache_sound ( gs_SnarkAttack );

        // -- Sprites
        gi_BloodSpray = precache_model ( "sprites/bloodspray.spr" );
        gi_BloodDrop  = precache_model ( "sprites/blood.spr" );
        
        if ( gi_ShowTrail )
        {
            gi_SmokeTrail = precache_model ( "sprites/smoke.spr" );
        }
    }


    public plugin_init ()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_sg_version", Version, FCVAR_FLAGS );

        register_forward ( FM_Think, "fwd_Think" );
        register_forward ( FM_Touch, "fwd_Touch" );
        register_forward ( FM_PlayerPreThink, "fwd_PlayerPreThink" );
    }


    public plugin_cfg ()
    {
        gi_SnarkClass   = engfunc ( EngFunc_AllocString, "info_target" );
        gi_MaxEntities  = global_get ( glb_maxEntities );
        gi_FriendlyFire = get_pcvar_num ( get_cvar_pointer ( "wpn_friendlyfire" ) );

        CreateWeapon ();
    }


    public client_disconnect ( id )
    {
        gb_JustThrown[ id ] = false;
        gf_TimeWeaponIdle[ id ] = 0.0;
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

        wpn_register_event ( i_Weapon_id, event_attack1, "Squeak_PrimaryAttack" );
        wpn_register_event ( i_Weapon_id, event_draw   , "Squeak_Deploy"  );
        wpn_register_event ( i_Weapon_id, event_hide   , "Squeak_Holster" );
        wpn_register_event ( i_Weapon_id, event_weapondrop_post , "Squeak_Drop" );

        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, SNARK_REFIRE_RATE );
        wpn_set_float ( i_Weapon_id, wpn_run_speed, SNARK_RUN_SPEED );

        wpn_set_integer ( i_Weapon_id, wpn_ammo1, SNARK_MAX_AMMOS );
        wpn_set_integer ( i_Weapon_id, wpn_cost, SNARK_COST );

        gi_Weaponid = i_Weapon_id;
    }


    public Squeak_PrimaryAttack ( id )
    {
        if ( !IsAmmoEmpty ( id, usr_wpn_ammo1 ) && CanThrowSnark ( id ) && Snark_Create ( id ) )
        {
            wpn_playanim ( id, squeak_throw );
            PlaySound ( id, SnarkHunt );

            Snark_Spawn ( id );
            Snark_Throw ( id );

            UpdateAmmo ( id );

            gb_JustThrown[ id ] = true;
            gf_TimeWeaponIdle[ id ] = get_gametime () + 1.0;

            return PLUGIN_CONTINUE;
        }

        return PLUGIN_HANDLED;

    }


    public Squeak_Deploy ( id )
    {
        PlaySound ( id, SnarkDeploy );
        wpn_playanim ( id, squeak_up );
    }


    public Squeak_Drop ( id, i_Ent )
    {
        if ( gi_WorldModelPos )
        {
            engfunc( EngFunc_SetSize, i_Ent, Float:{ -16.0, -16.0, 0.0 }, Float:{ 16.0, 16.0, 16.0 } );
        }
    
        set_pev ( i_Ent, pev_sequence, 1 );
        set_pev ( i_Ent, pev_animtime, get_gametime () );
        set_pev ( i_Ent, pev_framerate, 1.0 );
    }


    public Squeak_Holster ( id )
    {
        PlaySound ( id, SnarkHolster );
        wpn_playanim ( id, squeak_down );
    }


    public fwd_PlayerPreThink ( id )
    {
        if ( is_user_alive ( id ) && wpn_uses_weapon( id, gi_Weaponid ) )
        {
            WeaponIdle ( id );
        }
    }


    public fwd_Think ( i_Ent )
    {
        if ( IsSnark ( i_Ent ) )
        {
            switch ( pev ( i_Ent, SG_THINK_STEP ) )
            {
                case HuntThink   : Snark_TrackTarget ( i_Ent );
                case RemoveSnark : Snark_Removing ( i_Ent );
            }
        }
    }


    public fwd_Touch ( i_Ent, i_Other )
    {
        if ( pev ( i_Ent, SG_TOUCH_STEP ) && IsSnark ( i_Ent ) && !IsSnark ( i_Other ) )
        {
            Snark_SuperBounceTouch ( i_Ent, i_Other );
        }
    }


    Snark_SuperBounceTouch ( const i_Ent, const i_Other )
    {
        static Float:vf_Angles[ e_Coord ];
        static Float:f_Time; static Float:f_NextHit, Float:f_Pitch;
        static Float:f_Die, Float:f_NextBounceSoundTime, Float:f_NextAttack;

        if ( i_Other && i_Other == pev ( i_Ent, pev_owner ) )
        {
            return;
        }

        f_Time = get_gametime ();

        pev ( i_Ent, pev_angles, vf_Angles );
        pev ( i_Ent, SG_NEXT_HIT, f_NextHit );

        vf_Angles[ x ] = 0.0;
        vf_Angles[ z ] = 0.0;

        set_pev ( i_Ent, pev_angles, vf_Angles );
        set_pev ( i_Ent, pev_owner, NULL );

        if ( f_NextHit > f_Time )
        {
            return;
        }

        pev ( i_Ent, SG_SNARK_DIE, f_Die );
        pev ( i_Ent, SG_NEXT_ATTACK, f_NextAttack );

        f_Pitch = 155.0 - 60.0 * ( ( f_Die - f_Time ) / SNARK_DETONATE_DELAY );

        if ( CanTakeDamage ( i_Other ) && f_NextAttack < f_Time )
        {
            wpn_damage_user ( gi_Weaponid, i_Other, pev ( i_Ent, SG_SNARK_OWNER ), 0, floatround ( SNARK_DAMAGE ), DMG_SLASH );
            PlaySound ( i_Ent, SnarkAttack, floatround ( f_Pitch ) );
            set_pev ( i_Ent, SG_NEXT_ATTACK, f_Time + 0.5 );
        }

        set_pev ( i_Ent, SG_NEXT_HIT , f_Time + 0.1 );
        set_pev ( i_Ent, SG_NEXT_HUNT, f_Time );

        pev ( i_Ent, SG_NEXT_BS_TIME, f_NextBounceSoundTime );

        if ( f_Time < f_NextBounceSoundTime )
        {
            return;
        }

        if ( !( pev ( i_Ent, pev_flags ) & FL_ONGROUND ) )
        {
            PlaySound ( i_Ent, SnarkRandomHunt, floatround ( f_Pitch ) );
        }

        set_pev ( i_Ent, SG_NEXT_BS_TIME, f_Time + 0.5 );
    }


    Snark_TrackTarget ( const i_Ent )
    {
        static Float:vf_SnarkOrigin[ e_Coord ], Float:vf_SnarkVelocity[ e_Coord ];

        pev ( i_Ent, pev_origin, vf_SnarkOrigin );
        pev ( i_Ent, pev_velocity, vf_SnarkVelocity );

        if ( !IsInWorld ( vf_SnarkOrigin, vf_SnarkVelocity ) )
        {
            set_pev ( i_Ent, SG_THINK_STEP, NULL );
            Snark_Removing ( i_Ent );
            return;
        }

        static Float:f_Time, Float:f_Die, Float:f_NextHunt, Float:f_SnarkHealth;
        f_Time = get_gametime ();

        set_pev ( i_Ent, pev_nextthink, f_Time + 0.1 );

        pev ( i_Ent, pev_health, f_SnarkHealth );
        pev ( i_Ent, SG_SNARK_DIE, f_Die );

        if ( f_Time >= f_Die || f_SnarkHealth < SNARK_HEALTH_REF + SNARK_HEALTH )
        {
            set_pev ( i_Ent, pev_health, -1.0 );
            Snark_Killed ( i_Ent );
            return;
        }

        if ( pev ( i_Ent, pev_waterlevel ) != NOT_IN_WATER )
        {
            if ( pev ( i_Ent, pev_movetype ) == MOVETYPE_BOUNCE )
            {
                set_pev ( i_Ent, pev_movetype, MOVETYPE_FLY );
            }

            xs_vec_mul_scalar ( vf_SnarkVelocity, 0.9, vf_SnarkVelocity ); vf_SnarkVelocity[ z ] += 8.0;
            set_pev ( i_Ent, pev_velocity, vf_SnarkVelocity );
        }
        else if ( pev ( i_Ent, pev_movetype ) == MOVETYPE_FLY )
        {
            set_pev ( i_Ent, pev_movetype, MOVETYPE_BOUNCE );
        }

        pev ( i_Ent, SG_NEXT_HUNT, f_NextHunt );

        if ( f_NextHunt > f_Time )
        {
            return;
        }

        set_pev ( i_Ent, SG_NEXT_HUNT, f_Time + 2.0 );

        static Float:vf_Dir[ e_Coord ], Float:vf_Angles[ e_Coord ];
        static Float:f_Pitch, i_Enemy;

        pev ( i_Ent, pev_angles, vf_Angles );
        engfunc ( EngFunc_MakeVectors, vf_Angles );

        i_Enemy = pev ( i_Ent, SG_SNARK_ENEMY );

        if ( i_Enemy == NULL || !IsAlive ( i_Enemy ) )
        {
            i_Enemy = BestVisibleEnemy ( i_Ent, vf_SnarkOrigin );
        }

        pev ( i_Ent, SG_SNARK_DIE, f_Die );

        if ( 0.3 <= f_Die - f_Time <= 0.5 )
        {
            PlaySound ( i_Ent, SnarkDie );

        }

        f_Pitch = 155.0 - 60.0 * ( ( f_Die - f_Time ) / SNARK_DETONATE_DELAY );

        if ( f_Pitch < 80.0 )
        {
            f_Pitch = 80.0;
        }

        if ( i_Enemy != NULL )
        {
            static Float:vf_Target[ e_Coord ];

            if ( FVisible( i_Ent, i_Enemy ) )
            {
                static Float:vf_EyePosition[ e_Coord ];
                EyePosition ( i_Enemy, vf_EyePosition );

                xs_vec_sub ( vf_EyePosition, vf_SnarkOrigin, vf_Dir );
                xs_vec_normalize ( vf_Dir, vf_Target );

                set_pev ( i_Ent, SG_SNARK_TARGET, vf_Target );
            }

            static Float:f_Vel, Float:f_Adj;
            pev ( i_Ent, pev_velocity, vf_SnarkVelocity );

            f_Vel = xs_vec_len ( vf_SnarkVelocity );
            f_Adj = 50.0 / ( f_Vel + 10.0 );

            if ( f_Adj > 1.2 )
            {
                f_Adj = 1.2;
            }

            pev ( i_Ent, SG_SNARK_TARGET, vf_Target );

            vf_SnarkVelocity[ x ] = vf_SnarkVelocity[ x ] * f_Adj + vf_Target[ x ] * 300.0;
            vf_SnarkVelocity[ y ] = vf_SnarkVelocity[ y ] * f_Adj + vf_Target[ y ] * 300.0;
            vf_SnarkVelocity[ z ] = vf_SnarkVelocity[ z ] * f_Adj + vf_Target[ z ] * 300.0;

            set_pev ( i_Ent, pev_velocity, vf_SnarkVelocity );
        }

        if ( pev ( i_Ent, pev_flags ) & FL_ONGROUND )
        {
            set_pev ( i_Ent, pev_avelocity, Float:{ 0.0, 0.0, 0.0 } );
        }
        else
        {
            static Float:vf_Avelocity[ e_Coord ];
            pev ( i_Ent, pev_avelocity, vf_Avelocity );

            if ( vf_Avelocity[ x ] == 0.0 && vf_Avelocity[ y ] == 0.0 && vf_Avelocity[ z ] == 0.0 )
            {
                vf_Avelocity[ x ] = random_float ( -100.0, 100.0 );
                vf_Avelocity[ y ] = random_float ( -100.0, 100.0 );

                set_pev ( i_Ent, pev_avelocity, vf_Avelocity );
            }
        }

        static Float:vf_PosPrev[ e_Coord ];

        pev ( i_Ent, SG_SNARK_POSPREV, vf_PosPrev );
        pev ( i_Ent, pev_velocity, vf_SnarkVelocity );

        xs_vec_sub ( vf_SnarkOrigin, vf_PosPrev, vf_PosPrev );

        if ( xs_vec_len ( vf_PosPrev ) < 1.0 )
        {
            vf_SnarkVelocity[ x ] = random_float ( -100.0, 100.0 );
            vf_SnarkVelocity[ y ] = random_float ( -100.0, 100.0 );

            set_pev ( i_Ent, pev_velocity, vf_SnarkVelocity );
        }

        xs_vec_copy ( vf_SnarkOrigin, vf_PosPrev );
        set_pev ( i_Ent, SG_SNARK_POSPREV, vf_PosPrev );

        engfunc ( EngFunc_VecToAngles, vf_SnarkVelocity, vf_Angles );

        vf_Angles[ z ] = 0.0;
        vf_Angles[ x ] = 0.0;

        set_pev ( i_Ent, pev_angles, vf_Angles );
    }


    Snark_Create ( const id  )
    {
        gi_Snark[ id ] = engfunc ( EngFunc_CreateNamedEntity, gi_SnarkClass );

        if ( !gi_Snark[ id ] )
        {
            return NULL;
        }

        set_pev ( gi_Snark[ id ], pev_classname, gs_SnarkClassname );
        static Float:vf_EndPos[ e_Coord ]; get_tr2 ( 0, TR_vecEndPos, vf_EndPos );

        set_pev ( gi_Snark[ id ], pev_owner, id );
        set_pev ( gi_Snark[ id ], pev_origin, vf_EndPos );
        set_pev ( gi_Snark[ id ], pev_angles, gvf_Angles[ id ] );

        return gi_Snark[ id ];
    }


    Snark_Spawn ( const id )
    {
        static Float:f_Time; f_Time = get_gametime ();

        set_pev ( gi_Snark[ id ], pev_movetype, MOVETYPE_BOUNCE );
        set_pev ( gi_Snark[ id ], pev_solid, SOLID_BBOX );

        engfunc ( EngFunc_SetModel, gi_Snark[ id ], gs_SnarkModel );
        engfunc ( EngFunc_SetSize , gi_Snark[ id ], Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 8.0 } );

        pev ( gi_Snark[ id ], pev_origin, gvf_SnarkOrigin[ id ] );
        engfunc ( EngFunc_SetOrigin, gi_Snark[ id ], gvf_SnarkOrigin[ id ] );

        set_pev ( gi_Snark[ id ], SG_THINK_STEP, HuntThink );
        set_pev ( gi_Snark[ id ], SG_TOUCH_STEP, SuperBounceTouch );

        set_pev ( gi_Snark[ id ], pev_nextthink, f_Time + 0.1 );
        set_pev ( gi_Snark[ id ], SG_NEXT_HUNT , f_Time + 1000000.0 );

        set_pev ( gi_Snark[ id ], pev_flags, pev ( gi_Snark[ id ], pev_flags ) | FL_MONSTER );
        set_pev ( gi_Snark[ id ], pev_takedamage, DAMAGE_AIM );
        set_pev ( gi_Snark[ id ], pev_health, SNARK_HEALTH_REF + SNARK_HEALTH );
        set_pev ( gi_Snark[ id ], pev_gravity, SNARK_GRAVITY );
        set_pev ( gi_Snark[ id ], pev_friction, SNARK_FRICTION );
        set_pev ( gi_Snark[ id ], pev_dmg, SNARK_DAMAGE );

        set_pev ( gi_Snark[ id ], SG_SNARK_OWNER, pev ( gi_Snark[ id ], pev_owner ) );

        set_pev ( gi_Snark[ id ], SG_SNARK_DIE, f_Time + SNARK_DETONATE_DELAY );
        set_pev ( gi_Snark[ id ], SG_NEXT_BS_TIME, f_Time );

        set_pev ( gi_Snark[ id ], pev_sequence, wsqueak_run );
        set_pev ( gi_Snark[ id ], pev_framerate, 1.0 );
        set_pev ( gi_Snark[ id ], pev_animtime, f_Time );
        
        if ( gi_ShowTrail )
        {
            message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
            write_byte ( TE_BEAMFOLLOW );
            write_short ( gi_Snark[ id ] );
            write_short ( gi_SmokeTrail );
            write_byte ( TRAIL_LIFE );   // life
            write_byte ( TRAIL_WIDTH );  // width
            write_byte ( TRAIL_RED );
            write_byte ( TRAIL_GREEN ); 
            write_byte ( TRAIL_BLUE ); 
            write_byte ( TRAIL_BRIGTHNESS );
            message_end();
        }
    }


    Snark_Killed ( i_Ent )
    {
        static Float:vf_Origin[ e_Coord ];

        set_pev ( i_Ent, pev_model, NULL );

        set_pev ( i_Ent, SG_THINK_STEP, RemoveSnark );
        set_pev ( i_Ent, SG_TOUCH_STEP, NULL );

        set_pev ( i_Ent, pev_nextthink, get_gametime () + 0.1 );
        set_pev ( i_Ent, pev_takedamage, DAMAGE_NO );
        set_pev ( i_Ent, pev_flags, pev ( i_Ent, pev_flags ) &~ FL_MONSTER );

        PlaySound ( i_Ent, SnarkKilled );
        
        pev ( i_Ent, pev_origin, vf_Origin );
        BloodDrips ( vf_Origin, SNARK_BLOOD_COLOR, SNARK_BLOOD_AMOUNT );

        wpn_kill_user ( gi_Weaponid, i_Ent, 0, 0, DMG_ALWAYSGIB );
        wpn_radius_damage ( gi_Weaponid, pev ( i_Ent, SG_SNARK_OWNER ), i_Ent, 0.0, 5.0, DMG_BLAST );
    }


    WeaponIdle ( id )
    {
        static Float:f_Time, Float:f_Rand;

        f_Time = get_gametime ();

        if ( gf_TimeWeaponIdle[ id ] > f_Time )
        {
            return;
        }

        if ( gb_JustThrown[ id ] )
        {
            gb_JustThrown[ id ] = false;

            if ( IsAmmoEmpty ( id, usr_wpn_ammo1 ) )
            {
                wpn_remove_weapon ( id, gi_Weapon[ id ] );
                return;
            }

            wpn_playanim ( id, squeak_up );
            gf_TimeWeaponIdle[ id ] = f_Time + random_float ( 10.0, 15.0 );

            return;
        }

        f_Rand = random_float ( 0.0, 1.0 );

        if ( f_Rand <= 0.75 )
        {
            wpn_playanim ( id, squeak_idle1 );
            gf_TimeWeaponIdle[ id ] = f_Time + 30.0 / 16.0 * ( 2.0 );
        }
        else if ( f_Rand <= 0.875 )
        {
            wpn_playanim ( id, squeak_fidgetfit );
            gf_TimeWeaponIdle[ id ] = f_Time + 70.0 / 16.0;
        }
        else
        {
            wpn_playanim ( id, squeak_fidgetnip );
            gf_TimeWeaponIdle[ id ] = f_Time + 80.0 / 16.0;
        }
    }



    BestVisibleEnemy ( i_Ent, const Float:vf_Origin[] )
    {
        static i_Target, i_Flags;

        static Float:vf_Mins   [ e_Coord ], Float:vf_Maxs   [ e_Coord ];
        static Float:vf_Absmins[ e_Coord ], Float:vf_Absmaxs[ e_Coord ];
        
        xs_vec_sub ( vf_Origin, Float:{ SNARK_SEARCH_RADIUS, SNARK_SEARCH_RADIUS, SNARK_SEARCH_RADIUS }, vf_Mins );
        xs_vec_add ( vf_Origin, Float:{ SNARK_SEARCH_RADIUS, SNARK_SEARCH_RADIUS, SNARK_SEARCH_RADIUS }, vf_Maxs );

        for ( i_Target = 1; i_Target < gi_MaxEntities; ++i_Target )
        {
            if ( !pev_valid ( i_Target ) )
            {
                continue;
            }

            i_Flags = pev ( i_Target, pev_flags );

            if ( !( i_Flags & ( FL_CLIENT | FL_FAKECLIENT | FL_MONSTER ) ) )
            {
                continue;
            }

            if ( i_Flags & FL_MONSTER )
            {
                if ( IsSnark ( i_Target ) )
                {
                    continue;
                }
            }

            if ( i_Target == i_Ent )
            {
                continue;
            }

            pev ( i_Target, pev_absmin, vf_Absmins );
            pev ( i_Target, pev_absmax, vf_Absmaxs );

            if ( vf_Mins[ x ] > vf_Absmaxs[ x ] || vf_Mins[ y ] > vf_Absmaxs[ y ] || vf_Mins[ z ] > vf_Absmaxs[ z ] ||
                 vf_Maxs[ x ] < vf_Absmins[ x ] || vf_Maxs[ y ] < vf_Absmins[ y ] || vf_Maxs[ z ] < vf_Absmins[ z ] )
            {
                continue;
            }

            if ( IsEnemyValid ( i_Ent, i_Target ) )
            {
                if ( FInViewCone ( i_Ent, i_Target ) && !( i_Flags & FL_NOTARGET ) && FVisible ( i_Ent, i_Target ) )
                {
                    set_pev ( i_Ent, pev_enemy, i_Target );
                    return i_Target;
                }
            }
        }

        return 0;
    }


    Snark_Removing ( const i_Ent )
    {
        set_pev ( i_Ent, pev_flags, FL_KILLME );
    }


    bool:CanThrowSnark ( const id )
    {
        static Float:vf_Start [ e_Coord ], Float:vf_End[ e_Coord ], Float:f_Fraction;

        pev ( id, pev_v_angle, gvf_Angles[ id ] ); engfunc ( EngFunc_MakeVectors, gvf_Angles[ id ] );
        pev ( id, pev_origin, gvf_PlayerOrigin[ id ] );

        if ( IsDucking ( id ) )
        {
            gvf_PlayerOrigin[ id ][ x ] = gvf_PlayerOrigin[ id ][ x ] - ( gvf_HullMin[ x ] - gvf_DuckHullMin[ x ] );
            gvf_PlayerOrigin[ id ][ y ] = gvf_PlayerOrigin[ id ][ y ] - ( gvf_HullMin[ y ] - gvf_DuckHullMin[ y ] );
            gvf_PlayerOrigin[ id ][ z ] = gvf_PlayerOrigin[ id ][ z ] - ( gvf_HullMin[ z ] - gvf_DuckHullMin[ z ] );
        }

        global_get ( glb_v_forward, gvf_Forward[ id ] );

        VectorMA ( gvf_PlayerOrigin[ id ], 20.0, gvf_Forward[ id ], vf_Start );
        VectorMA ( gvf_PlayerOrigin[ id ], 64.0, gvf_Forward[ id ], vf_End );

        engfunc( EngFunc_TraceLine, vf_Start, vf_End, DONT_IGNORE_MONSTERS, NULL, 0 );
        get_tr2 ( 0, TR_flFraction, f_Fraction );

        if ( get_tr2 ( 0, TR_AllSolid ) == 0 && get_tr2 ( 0, TR_StartSolid ) == 0 && f_Fraction > 0.25 )
        {
            return true;
        }

        return false;
    }


    bool:FVisible ( i_Snark, i_Other )
    {
        if ( !pev_valid ( i_Snark ) || pev ( i_Other, pev_flags ) & FL_NOTARGET )
        {
            return false;
        }

        static i_LookerWLevel, i_TargetWLevel;

        i_LookerWLevel = pev ( i_Snark, pev_waterlevel );
        i_TargetWLevel = pev ( i_Other, pev_waterlevel );

        if ( ( i_LookerWLevel != HEAD_IN_WATER && i_TargetWLevel == HEAD_IN_WATER ) ||
             ( i_LookerWLevel == HEAD_IN_WATER && i_TargetWLevel == NOT_IN_WATER  ) )
        {
            return false;
        }

        static Float:vf_LookerOrigin[ e_Coord ], Float:vf_TargetOrigin[ e_Coord ];

        EyePosition ( i_Snark, vf_LookerOrigin );
        EyePosition ( i_Other, vf_TargetOrigin );

        engfunc ( EngFunc_TraceLine, vf_LookerOrigin, vf_TargetOrigin, IGNORE_MONSTERS, i_Snark, 0 );

        static Float:f_Fraction;
        get_tr2 ( 0, TR_flFraction, f_Fraction );

        if ( f_Fraction == 1.0 )
        {
            return true;
        }

        return false;
    }


    bool:FInViewCone ( i_Snark, i_Other )
    {
        static Float:vf_Angles [ e_Coord ];
        static Float:vf_HOrigin[ e_Coord ];
        static Float:vf_Origin [ e_Coord ];

        static Float:f_Dot;

        pev ( i_Snark, pev_angles, vf_Angles );

        engfunc ( EngFunc_MakeVectors, vf_Angles );
        global_get ( glb_v_forward, vf_Angles ); vf_Angles[ z ] = 0.0;

        pev ( i_Snark, pev_origin, vf_HOrigin );
        pev ( i_Other, pev_origin, vf_Origin );

        xs_vec_sub ( vf_Origin, vf_HOrigin, vf_Origin ); vf_Origin[ z ] = 0.0;
        xs_vec_normalize ( vf_Origin, vf_Origin );

        f_Dot = xs_vec_dot ( vf_Origin, vf_Angles );

        if ( f_Dot > SNARK_FOV )
        {
            return true;
        }

        return false;
    }


    bool:IsInWorld ( const Float:vf_SnarkOrigin[], const Float:vf_SnarkVelocity[] )
    {
        if ( vf_SnarkOrigin[ x ] >=  4096.0 ) return false;
        if ( vf_SnarkOrigin[ y ] >=  4096.0 ) return false;
        if ( vf_SnarkOrigin[ z ] >=  4096.0 ) return false;
        if ( vf_SnarkOrigin[ x ] <= -4096.0 ) return false;
        if ( vf_SnarkOrigin[ y ] <= -4096.0 ) return false;
        if ( vf_SnarkOrigin[ z ] <= -4096.0 ) return false;

        if ( vf_SnarkVelocity[ x ] >=  2000.0 ) return false;
        if ( vf_SnarkVelocity[ y ] >=  2000.0 ) return false;
        if ( vf_SnarkVelocity[ z ] >=  2000.0 ) return false;
        if ( vf_SnarkVelocity[ x ] <= -2000.0 ) return false;
        if ( vf_SnarkVelocity[ y ] <= -2000.0 ) return false;
        if ( vf_SnarkVelocity[ z ] <= -2000.0 ) return false;

        return true;
    }



    bool:IsSnark ( const i_Ent )
    {
        if ( !pev_valid ( i_Ent ) )
        {
            return false;
        }

        static s_Classname[ sizeof gs_SnarkClassname + 1 ];
        pev ( i_Ent, pev_classname, s_Classname, charsmax ( s_Classname ) );

        if ( !FastCompare ( s_Classname, gs_SnarkClassname, sizeof gs_SnarkClassname ) )
        {
            return false;
        }

        return true;
    }


    bool:IsEnemyValid ( const i_Ent, const i_Enemy )
    {
        if ( !pev_valid ( i_Enemy ) )
        {
            return false;
        }

        static i_Flags; i_Flags = pev ( i_Enemy, pev_flags );

        if ( i_Flags & ( FL_CLIENT | FL_FAKECLIENT ) )
        {
            if ( !is_user_alive ( i_Enemy ) || pev ( i_Enemy, pev_deadflag ) > DEAD_NO )
            {
                return false;
            }
            else if ( !gi_FriendlyFire && IsSameTeam ( i_Enemy, pev ( i_Ent, pev_owner ) ) )
            {
                return false;
            }
        }
        else if ( i_Flags & FL_MONSTER )
        {
            static Float:f_Health; pev ( i_Enemy, pev_health, f_Health );

            if ( f_Health <= 0 )
            {
                return false;
            }
        }

        return true;
    }


    bool:IsSameTeam ( const FirstId, const SecondId )
    {
        return bool:( get_user_team ( FirstId ) == get_user_team ( SecondId ) );
    }


    bool:FastCompare (  const s_Source[], const s_What[], i_Wlen )
    {
        static i; i = 0;

        while ( i_Wlen-- )
        {
            if ( s_Source[i] != s_What[i] )
            {
                return false;
            }

            ++i;
        }

        return true;
    }


    bool:IsAmmoEmpty ( const id, const wpn_usr_info:i_AmmoType )
    {
        gi_Weapon[ id ] = wpn_has_weapon ( id, gi_Weaponid );
        return wpn_get_userinfo ( id, i_AmmoType, gi_Weapon[ id ] ) <= 0 ? true : false;
    }


    bool:CanTakeDamage ( const i_Other )
    {
        static Float:f_TakeDamage;
        pev ( i_Other, pev_takedamage, f_TakeDamage );

        if ( pev ( i_Other, pev_flags ) & ( FL_CLIENT | FL_FAKECLIENT | FL_MONSTER ) && f_TakeDamage != DAMAGE_NO )
        {
            return true;
        }

        return false;
    }


    bool:IsAlive ( const i_Ent )
    {
        if ( !pev_valid ( i_Ent ) )
        {
            return false;
        }
    
        static Float:f_Health; pev ( i_Ent, pev_health, f_Health );
        return bool:( pev ( i_Ent, pev_deadflag ) == DEAD_NO && f_Health > 0 );
    }


    PlaySound ( const index, const i_Sound, const i_Other = NULL )
    {
        switch ( i_Sound )
        {
            case SnarkHunt    : emit_sound ( index, CHAN_VOICE , random_float ( 0.0, 1.0 ) <= 0.5 ? gs_SqueakHunt2 : gs_SqueakHunt3, VOL_NORM, ATTN_NORM, 0, PITCH_NORM + 5 );
            case SnarkDeploy  : emit_sound ( index, CHAN_VOICE , random_float ( 0.0, 1.0 ) <= 0.5 ? gs_SqueakHunt2 : gs_SqueakHunt3, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
            case SnarkHolster : emit_sound ( index, CHAN_WEAPON, gs_NullSound  , VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
            case SnarkAttack  : emit_sound ( index, CHAN_WEAPON, gs_SnarkAttack, VOL_NORM, ATTN_NORM, 0, i_Other );
            case SnarkDie     : emit_sound ( index, CHAN_VOICE , gs_SnarkDie   , VOL_NORM, ATTN_NORM, 0, PITCH_NORM + random_num ( 0, 63 ) );
            case SnarkKilled  :
            {
                emit_sound ( index, CHAN_ITEM, gs_SnarkBlast, VOL_NORM, 0.5, 0, PITCH_NORM );
                emit_sound ( index, CHAN_VOICE, gs_SnarkBodySplat, 0.75, ATTN_NORM, 0, PITCH_NORM * 2 );
            }   
            case SnarkRandomHunt :
            {   
                static Float:i_Rand; i_Rand = random_float ( 0.0, 1.0 );

                if ( i_Rand <= 0.33 )
                {
                    emit_sound ( index, CHAN_VOICE, gs_SqueakHunt1, VOL_NORM, ATTN_NORM, 0, i_Other );
                }
                else if ( i_Rand <= 0.66 )
                {
                    emit_sound ( index, CHAN_VOICE, gs_SqueakHunt2, VOL_NORM, ATTN_NORM, 0, i_Other );
                }
                else
                {
                    emit_sound ( index, CHAN_VOICE, gs_SqueakHunt3, VOL_NORM, ATTN_NORM, 0, i_Other );
                }
            }   
        }
    }


    Snark_Throw ( const id )
    {
        pev ( id, pev_velocity, gvf_SnarkVelocity[ id ] );
        VectorMA ( gvf_PlayerVelocity[ id ], SNARK_THROW_VELOCITY, gvf_Forward[ id ], gvf_SnarkVelocity[ id ] );

        set_pev ( gi_Snark[ id ], pev_velocity, gvf_SnarkVelocity[ id ] );
    }


    UpdateAmmo ( const id )
    {
        wpn_set_userinfo ( id, usr_wpn_ammo1, gi_Weapon[ id ], wpn_get_userinfo ( id, usr_wpn_ammo1, gi_Weapon[ id ] ) - 1 );
    }


    EyePosition ( const index, Float:vf_Origin[] )
    {
        static Float:vf_ViewOfs[3];

        pev ( index, pev_origin, vf_Origin );
        pev ( index, pev_view_ofs, vf_ViewOfs );

        xs_vec_add ( vf_Origin, vf_ViewOfs, vf_Origin );
    }


    BloodDrips ( const Float:vf_Origin[], const i_Color, i_Amount )
    {
        i_Amount *= 2;

        if ( i_Amount > 255 )
        {
            i_Amount = 255;
        }

        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte ( TE_BLOODSPRITE );
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z] );
        write_short ( gi_BloodSpray );                         // initial sprite model
        write_short ( gi_BloodDrop );                          // droplet sprite models
        write_byte ( i_Color );                                // color index into host_basepal
        write_byte ( min ( max ( 3, i_Amount / 10 ), 16 ) );   // size
        message_end ();
    }


    VectorMA ( const Float:vf_Add[], const Float:f_Scale, const Float:vf_Mult[], Float:vf_Output[] )
    {
        vf_Output[ x ] = vf_Add[ x ] + vf_Mult[ x ] * f_Scale;
        vf_Output[ y ] = vf_Add[ y ] + vf_Mult[ y ] * f_Scale;
        vf_Output[ z ] = vf_Add[ z ] + vf_Mult[ z ] * f_Scale;
    }