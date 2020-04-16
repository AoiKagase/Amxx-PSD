
   /* - - - - - - - - - - -

        AMX Mod X script.

          | Author  : Arkshine
          | Plugin  : WPN Crossbow ( HL1 )
          | Version : v1.0.2

        (!) Support : http://forums.space-headed.net/viewtopic.php?t=354

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
            Basically, it's almost the same weapon that you can see in Half-life.
            
            The Crossbow is a long range sniper weapon featured in Half-Life. It is extremely effective against distant targets, 
            but is difficult to utilize in melees or against fast moving opponents due to its very slow reload and the low velocity of the shot. 
            The primary trigger fires a bolt; the secondary trigger zooms in on targets.
            
            A full description can be found here : http://half-life.wikia.com/wiki/Crossbow_(HL1) .

            
        Requirement :
        - - - - - - -
            * CS 1.6 / CZ / DoD / TFC / TS
            * AMX Mod X 1.7x or higher.
            * WeaponMod / GameInfo

            
        Modules :
        - - - - -
            * Fakemeta


        Changelog :
        - - - - - -
            v1.0.2 : [ 6 jul 2008 ]
            
                (+) Added tracers for bolt. ( disabled by default ).
                (-) Removed the temporary fix about the double reloading. It's now fixed in WM.
                
            v1.0.1 : [ 19 may 2008 ]

                (+) Added weapon idle system.
                (+) The explosion from primary attack is now pulled out a bit from wall.
                (+) Breakable entities are now broken from primary attack.
                (!) Fixed. Zoom was not reset after a weapon change.
                (!) Temporary fixed. If you was keeping at the fire while the auto-reloading processus, you was getting another reloading at the end.
                (*) Minor optimizations / changes.
                
                An alternative and great model is now provided.
                
            v1.0.0 : [ 19 may 2008 ]

                (+) Initial release.


        Credits :
        - - - - -
            * HLSDK
            * DevconeS

    - - - - - - - - - - - */
    
    #include <amxmodx>
    #include <fakemeta>
    #include <weaponmod>
    #include <weaponmod_stocks>


    #define Plugin  "WPN Crossbow ( HL1 )"
    #define Version "1.0.2"
    #define Author  "Arkshine"

    
    /* - - - - - - -
     |   Uncomment if you want to use the alternative model. |
                                               - - - - - - - */
        // #define ALTERNATIVE_MODEL
    
    /* - - -
     |  Customization  |
                 - - - */
        #define CROSSBOW_RECOIL            2.0    // Recoil ( float )
        #define CROSSBOW_RUN_SPEED         250.0  // Max speed ( float )
        #define CROSSBOW_AMMO1             5      // Clip size
        #define CROSSBOW_AMMO2             15     // Ammo size
        #define CROSSBOW_COST              4750   // Cost
        
        #define ZOOM1_WANTED               45     // Primary zoom.
        #define ZOOM2_WANTED               20     // Secondaty zoom.
        
        #define BOLT_AIR_VELOCITY          2000   // Speed in air.
        #define BOLT_WATER_VELOCITY        1000   // Speed in water.
        
        #define BOLT_DAMAGE_MIN            10     // Bolt touches you. Min damage.
        #define BOLT_DAMAGE_MAX            20     // Bolt touches you. Max damage.
        #define BOLT_DAMAGE_MONSTER        40     // Bolt damage on monster.
            
        #define BOLT_EXPLOSION_DAMAGE_MAX  40.0   // Bolt explodes. Max damage. ( float )
        #define BOLT_EXPLOSION_RANGE       128.0  // Bolt explodes. Max range.  ( float )
        
        #define BOLT_SNIPER_DAMAGE_MIN     100    // Bolt sniped. Min damage.
        #define BOLT_SNIPER_DAMAGE_MAX     120    // Bolt sniped. Max damage
        #define BOLT_SNIPER_LIFE           20.0   // Delay before removing. ( float )
        
        #define BOLT_SHOW_TRACERS          0      // 0 = Don't show tracers ;  1 = Show tracers.
        
        #define BOLT_TRACER_RED           100     // Red
        #define BOLT_TRACER_GREEN         100     // Green
        #define BOLT_TRACER_BLUE          200     // Blue
        #define BOLT8TRACER_BBRIGHTNESS   200     // Brightness
    
    /* - - -
     |  Weapon information   |
                       - - - */
        new
            gs_WpnName [] = "Crossbow",
            gs_WpnShort[] = "crossbow";

    /* - - -
     |  Weapon model   |
                 - - - */
        new
        #if !defined ALTERNATIVE_MODEL
            gs_Model_P[] = "models/p_crossbow.mdl",
            gs_Model_V[] = "models/v_crossbow.mdl",
            gs_Model_W[] = "models/w_crossbow.mdl";
        #else
            gs_Model_P[] = "models/p_alt_crossbow.mdl",
            gs_Model_V[] = "models/v_alt_crossbow.mdl",
            gs_Model_W[] = "models/w_alt_crossbow.mdl";
        #endif
       

    /* - - -
     |  Bolt model   |
               - - - */
        new const
        #if !defined ALTERNATIVE_MODEL
            gs_BoltModel[] = "models/crossbow_bolt.mdl";
        #else
            gs_BoltModel[] = "models/crossbow_alt_bolt.mdl";
        #endif
            
    /* - - -
     |  Weapon sound   |
                 - - - */
        new const
            gs_FireSound  [] = "weapons/xbow_fire1.wav",
            gs_ReloadSound[] = "weapons/xbow_reload1.wav";

    /* - - -
     |  Bolt sound   |
               - - - */
        new const
            gs_Hitbody1Sound[] = "weapons/xbow_hitbod1.wav",
            gs_Hitbody2Sound[] = "weapons/xbow_hitbod2.wav",
            gs_HitSound     [] = "weapons/xbow_hit1.wav";

    /* - - -
     |    Sequence   |
               - - - */
        enum
        {
            crossbow_idle1,     // full
            crossbow_idle2,     // empty
            crossbow_fidget1,   // full
            crossbow_fidget2,   // empty
            crossbow_fire1,     // full
            crossbow_fire2,     // reload
            crossbow_fire3,     // empty
            crossbow_reload,    // from empty
            crossbow_draw1,     // full
            crossbow_draw2,     // empty
            crossbow_holster1,  // full
            crossbow_holster2   // empty
        };

    /* - - -
     |  Custom fields  |
                 - - - */
        #define CB_THINK_STEP pev_iuser4
        #define CB_DIRECTION  pev_vuser4

    /* - - -
     |    Others stuff   |
                   - - - */
        #define FCVAR_FLAGS ( FCVAR_SERVER | FCVAR_SPONLY | FCVAR_EXTDLL | FCVAR_UNLOGGED )
        
        #define MAX_CLIENTS   32
        #define DEFAULT_ZOOM  90
        #define HEAD_IN_WATER 3

        new const gs_BoltExplodeClassname[] = "wpn_bolt_explode";
        new const gs_BoltClassname       [] = "wpn_bolt";
        
        new gi_InZoom[ MAX_CLIENTS + 1 ] = { DEFAULT_ZOOM, ... };
        new Float:gf_TimeWeaponIdle[ MAX_CLIENTS + 1 ];

        enum 
        { 
            BubbleThink, 
            ExplosionThink 
        };
    
        enum e_Coord 
        { 
            Float:x, 
            Float:y, 
            Float:z 
        };

        new gi_Weaponid;
        new gi_BoltClass;
        
        new gi_WExplosion;
        new gi_Fireball;
        new gi_Bubbles;

        new gi_MaxClients;
        
        #if BOLT_SHOW_TRACERS == 1
            new gi_Laser;
            new gi_SmokeTrail;
        #endif
        
        new gi_LastBoltIndex     [ MAX_CLIENTS + 1 ];
        new gvf_LastBoltOrigin   [ MAX_CLIENTS + 1 ][ e_Coord ];
        new gvf_LastBoltVelocity [ MAX_CLIENTS + 1 ][ e_Coord ];
        new gvf_LastBoltAvelocity[ MAX_CLIENTS + 1 ][ e_Coord ];
        new gvf_LastBoltAngles   [ MAX_CLIENTS + 1 ][ e_Coord ];

        
    /* - - -
     |    Macro   |
            - - - */
        #define IsPlayer(%1)               ( 1 <= %1 <= gi_MaxClients )
        #define IsMonster(%1)              ( pev ( %1, pev_flags ) & FL_MONSTER )
        
        #define IsInWater_Flag(%1)         ( pev ( %1, pev_waterlevel ) == HEAD_IN_WATER )
        #define IsInWater_Origin(%1)       ( engfunc ( EngFunc_PointContents, %1 ) == CONTENTS_WATER )
        
        #define InZoom(%1)                 ( gi_InZoom[ %1 ] != DEFAULT_ZOOM )
        #define StopThinking(%1)           ( set_pev ( %1, pev_velocity, Float:{ 0.0, 0.0, 0.0 } ) )
        
        #define message_begin_f(%1,%2,%3)  ( engfunc ( EngFunc_MessageBegin, %1, %2, %3 ) )
        #define write_coord_f(%1)          ( engfunc ( EngFunc_WriteCoord, %1 ) )
        
        #if !defined charsmax 
            #define charsmax(%1)           ( sizeof ( %1 ) - 1 )
        #endif


    public plugin_precache()
    {
        // -- Weapon models.
        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );
        precache_model ( gs_Model_W );

        // -- Bolt model.
        precache_model ( gs_BoltModel );

        // -- Weapon sounds.
        precache_sound ( gs_FireSound );
        precache_sound ( gs_ReloadSound );

        // -- Bolt sounds
        precache_sound ( gs_Hitbody1Sound );
        precache_sound ( gs_Hitbody2Sound );
        precache_sound ( gs_HitSound );

        // -- Sprites
        gi_Bubbles    = precache_model ( "sprites/bubble.spr" );
        gi_WExplosion = precache_model ( "sprites/WXplo1.spr" );
        gi_Fireball   = precache_model ( "sprites/zerogxplode.spr" );
        
        #if BOLT_SHOW_TRACERS == 1
            gi_Laser      = precache_model ( "sprites/laserbeam.spr" );
            gi_SmokeTrail = precache_model ( "sprites/smoke.spr" );
        #endif
    }


    public plugin_init ()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_cb_version", Version, FCVAR_FLAGS );

        register_forward ( FM_Think, "fwd_Think" );
        register_forward ( FM_Touch, "fwd_Touch" );
        register_forward ( FM_PlayerPreThink, "fwd_PlayerPreThink" );
    }


    public plugin_cfg ()
    {
        gi_BoltClass  = engfunc ( EngFunc_AllocString, "info_target" );
        gi_MaxClients = global_get ( glb_maxClients );

        CreateWeapon ();
    }
    
    
    public client_putinserver ( id )
    {
        gi_InZoom  [ id ] = DEFAULT_ZOOM;
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

        wpn_register_event ( i_Weapon_id, event_attack1       , "Crossbow_PrimaryAttack"   );
        wpn_register_event ( i_Weapon_id, event_attack2       , "Crossbow_SecondaryAttack" );
        wpn_register_event ( i_Weapon_id, event_draw          , "Crossbow_Deploy"  );
        wpn_register_event ( i_Weapon_id, event_hide          , "Crossbow_Holster" );
        wpn_register_event ( i_Weapon_id, event_reload        , "Crossbow_Reload"  );
        wpn_register_event ( i_Weapon_id, event_weapondrop_pre, "Crossbow_Drop"    );
        
        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, 0.75 );
        wpn_set_float ( i_Weapon_id, wpn_refire_rate2, 0.75 );
        wpn_set_float ( i_Weapon_id, wpn_reload_time , 4.5 );
        wpn_set_float ( i_Weapon_id, wpn_recoil1  , CROSSBOW_RECOIL );
        wpn_set_float ( i_Weapon_id, wpn_recoil2  , 0.0 );
        wpn_set_float ( i_Weapon_id, wpn_run_speed, CROSSBOW_RUN_SPEED );

        wpn_set_integer ( i_Weapon_id, wpn_ammo1, CROSSBOW_AMMO1 );
        wpn_set_integer ( i_Weapon_id, wpn_ammo2, CROSSBOW_AMMO2 );
        wpn_set_integer ( i_Weapon_id, wpn_bullets_per_shot1, 1 );
        wpn_set_integer ( i_Weapon_id, wpn_bullets_per_shot2, 1 );
        wpn_set_integer ( i_Weapon_id, wpn_cost, CROSSBOW_COST );

        gi_Weaponid = i_Weapon_id;
    }


    public Crossbow_PrimaryAttack( const id )
    {
        wpn_set_float ( gi_Weaponid, wpn_refire_rate2 , 0.75 );
        
        if ( InZoom ( id ) )
        {
            FireSniperBolt ( id );
            return;
        }

        FireBolt ( id );
    }


    public Crossbow_SecondaryAttack( const id )
    {
        switch ( gi_InZoom[ id ] )
        {
            case DEFAULT_ZOOM : SetZoom ( id, ZOOM1_WANTED );
            case ZOOM1_WANTED : SetZoom ( id, ZOOM2_WANTED );
            case ZOOM2_WANTED : SetZoom ( id, DEFAULT_ZOOM );
        }
        
        wpn_set_float ( gi_Weaponid, wpn_refire_rate2 , 1.0 );
    }


    public Crossbow_Deploy ( const id )
    {
        wpn_playanim ( id, !IsAmmoEmpty ( id, usr_wpn_ammo1 ) ? crossbow_draw1 : crossbow_draw2 );
    }


    public Crossbow_Holster ( const id )
    {
        ResetZoom ( id );
        wpn_playanim ( id, !IsAmmoEmpty ( id, usr_wpn_ammo1 ) ? crossbow_holster1 : crossbow_holster2 );
    }


    public Crossbow_Reload ( const id )
    {
        ResetZoom ( id );
        
        wpn_playanim ( id, crossbow_reload );
        emit_sound ( id, CHAN_AUTO, gs_ReloadSound, random_float ( 0.95, VOL_NORM ), ATTN_NORM, 0, 93 + random_num ( 0, 15 ) );
        
        gf_TimeWeaponIdle[ id ] = get_gametime () + 6.0;
        
        return PLUGIN_CONTINUE;
    }


    public Crossbow_Drop ( const id )
    {
        ResetZoom ( id );
    }
    
    
    FireBolt ( const id )
    {
        FireBolt_Effect ( id );

        if ( !BoltCreate ( id ) )
        {
            return;
        }

        GetBoltStartOrigin ( id );
        
        static vf_Forward[ e_Coord ]; global_get ( glb_v_forward, vf_Forward );
        set_pev ( gi_LastBoltIndex[ id ], CB_DIRECTION, vf_Forward );

        set_pev ( gi_LastBoltIndex[ id ], pev_origin, gvf_LastBoltOrigin[ id ] );
        set_pev ( gi_LastBoltIndex[ id ], pev_owner, id );

        if ( IsInWater_Flag ( id ) )
        {
            velocity_by_aim ( id, BOLT_WATER_VELOCITY, Float:gvf_LastBoltVelocity[ id ] );
            set_pev ( gi_LastBoltIndex[ id ], pev_speed, BOLT_WATER_VELOCITY );
        }
        else
        {
            velocity_by_aim ( id, BOLT_AIR_VELOCITY, Float:gvf_LastBoltVelocity[ id ] );
            set_pev ( gi_LastBoltIndex[ id ], pev_speed, BOLT_AIR_VELOCITY );
        }

        set_pev ( gi_LastBoltIndex[ id ], pev_velocity , gvf_LastBoltVelocity[ id ] );
        pev     ( gi_LastBoltIndex[ id ], pev_avelocity, gvf_LastBoltAvelocity[ id ] ); gvf_LastBoltAvelocity[ id ][ z ] = _:10.0;
        set_pev ( gi_LastBoltIndex[ id ], pev_avelocity, gvf_LastBoltAvelocity[ id ] );

        engfunc ( EngFunc_VecToAngles, gvf_LastBoltVelocity[ id ], gvf_LastBoltAngles[ id ] );
        set_pev ( gi_LastBoltIndex[ id ], pev_angles, gvf_LastBoltAngles[ id ] );
        
        #if BOLT_SHOW_TRACERS == 1
            message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
            write_byte ( TE_BEAMFOLLOW );
            write_short ( gi_LastBoltIndex[ id ] );
            write_short ( gi_SmokeTrail );
            write_byte ( 5 );   // life
            write_byte ( 1 );   // width
            write_byte ( BOLT_TRACER_RED );          // red
            write_byte ( BOLT_TRACER_GREEN );        // green
            write_byte ( BOLT_TRACER_BLUE );         // blue
            write_byte ( BOLT8TRACER_BBRIGHTNESS );  // brightness
            message_end ();
        #endif
 
        wpn_set_float ( gi_Weaponid, wpn_refire_rate1 , 0.75 );
        wpn_set_float ( gi_Weaponid, wpn_refire_rate2 , 0.75 );

        gf_TimeWeaponIdle[ id ] = get_gametime () + ( !IsAmmoEmpty ( id, usr_wpn_ammo1 ) ? 5.0 : 0.75 );
    }
    
    
    FireSniperBolt ( const id )
    {
        static i_Hit;
        FireBolt_Effect ( id );

        if ( IsBoltTouching ( id, i_Hit ) )
        {
            static Float:vf_EndPos[ e_Coord ]; get_tr2 ( 0, TR_vecEndPos, vf_EndPos );

            #if BOLT_SHOW_TRACERS == 1
                message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
                write_byte ( TE_BEAMPOINTS );
                write_coord_f ( gvf_LastBoltOrigin[ id ][ x ] );
                write_coord_f ( gvf_LastBoltOrigin[ id ][ y ] );
                write_coord_f ( gvf_LastBoltOrigin[ id ][ z ] );
                write_coord_f ( vf_EndPos[ x ] );
                write_coord_f ( vf_EndPos[ y ] );
                write_coord_f ( vf_EndPos[ z ] );
                write_short ( gi_Laser );
                write_byte ( 0 );   // framestart?
                write_byte ( 0 );   // framerate?
                write_byte ( 1 );   // life
                write_byte ( 2 );   // width
                write_byte ( 0 );   // noise
                write_byte ( BOLT_TRACER_RED ); // red
                write_byte ( BOLT_TRACER_GREEN ); // green
                write_byte ( BOLT_TRACER_BLUE ); // blue
                write_byte ( BOLT8TRACER_BBRIGHTNESS ); // brightness
                write_byte ( 0 );   // speed?
                message_end (); 
            #endif
  
            if ( i_Hit > 0 )
            {
                static s_Classname[ 32 ]; pev ( i_Hit, pev_classname, s_Classname, charsmax ( s_Classname ) );

                if ( ShouldBreak ( i_Hit, s_Classname ) )
                {
                    emit_sound ( i_Hit, CHAN_BODY, gs_HitSound, random_float ( 0.95, VOL_NORM ), ATTN_NORM, 0, PITCH_NORM );
                    dllfunc ( DLLFunc_Use, i_Hit, id );
                }
                else if ( pev ( i_Hit, pev_solid ) != SOLID_BSP )
                {
                    emit_sound ( i_Hit, CHAN_BODY, random_num ( 0, 1 ) ? gs_Hitbody2Sound : gs_Hitbody1Sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

                    if ( CanTakeDamage ( i_Hit ) )
                    {
                        pev ( i_Hit, pev_origin, gvf_LastBoltOrigin[ id ] );
                        static i_Dmg; i_Dmg = random_num ( BOLT_SNIPER_DAMAGE_MIN, BOLT_SNIPER_DAMAGE_MAX );
                        
                        wpn_damage_user( gi_Weaponid, i_Hit, id, 0, i_Dmg, DMG_BULLET | DMG_NEVERGIB );
                        wpn_create_blood ( Float:gvf_LastBoltOrigin[ id ], i_Hit, clamp ( i_Dmg / 10, 3, 16 ) );
                    }
                } 
            }
            else
            {
                if ( !IsInWater_Origin ( vf_EndPos ) )
                {
                    FX_Sparks ( vf_EndPos );
                }

                if ( BoltCreate ( id ) )
                {
                    static Float:vf_End[ e_Coord ]; global_get ( glb_v_forward, vf_End );
                    set_pev ( gi_LastBoltIndex[ id ], pev_classname, gs_BoltExplodeClassname );

                    #if !defined ALTERNATIVE_MODEL
                        VectorMS ( vf_EndPos, 12.0, vf_End, Float:gvf_LastBoltOrigin[ id ] );
                    #else
                        VectorMS ( vf_EndPos, 8.0 , vf_End, Float:gvf_LastBoltOrigin[ id ] );
                    #endif

                    set_pev ( gi_LastBoltIndex[ id ], pev_origin, gvf_LastBoltOrigin[ id ] );
                    emit_sound ( gi_LastBoltIndex[ id ], CHAN_BODY, gs_HitSound, random_float ( 0.95, VOL_NORM ), ATTN_NORM, 0, PITCH_NORM );

                    engfunc ( EngFunc_VecToAngles, vf_End, gvf_LastBoltAngles[ id ] );
                    set_pev ( gi_LastBoltIndex[ id ], pev_angles, gvf_LastBoltAngles[ id ] );
                    
                    set_task ( BOLT_SNIPER_LIFE, "RemoveBolt", gi_LastBoltIndex[ id ] );
                }
            }
        }
    }


    FireBolt_Effect ( const id )
    {
        wpn_playanim ( id, !IsAmmoEmpty ( id, usr_wpn_ammo1 ) ? crossbow_fire1 : crossbow_fire3 );

        emit_sound ( id, CHAN_WEAPON, gs_FireSound, VOL_NORM, ATTN_NORM, 0, 93 + random_num ( 0, 15 ) );
        emit_sound ( id, CHAN_ITEM, gs_ReloadSound, random_float ( 0.95, VOL_NORM ), ATTN_NORM, 0, 93 + random_num ( 0, 15 ) );
    }
    

    public fwd_Think ( const i_Ent )
    {
        if ( !IsBolt ( i_Ent ) )
        {
            return FMRES_IGNORED;
        }
        
        switch ( pev ( i_Ent, CB_THINK_STEP ) )
        {
            case ExplosionThink :
            {
                BoltExplode ( i_Ent );
            }
            case BubbleThink :
            {
                if ( IsInWater_Flag ( i_Ent ) )
                {
                    static Float:vf_Origin[ e_Coord ], Float:vf_Velocity[ e_Coord ], Float:vf_End[ e_Coord ];
                    
                    pev ( i_Ent, pev_origin, vf_End );
                    pev ( i_Ent, pev_velocity, vf_Velocity );

                    VectorMS ( vf_End, 0.1, vf_Velocity, vf_Origin );
                    FX_BubbleTrail( vf_Origin, vf_End, 1 );
                }
            }
        }
        
        set_pev ( i_Ent, pev_nextthink, get_gametime () + 0.1 );
        return FMRES_IGNORED;
    }

    
    public fwd_Touch ( i_Ent, i_Other )
    {
        if ( !IsBolt ( i_Ent ) )
        {
            return FMRES_IGNORED;
        }
        
        static Float:vf_Origin[ e_Coord ];

        if ( CanTakeDamage ( i_Other ) )
        {
            if ( IsPlayer ( i_Other ) )
            {
                static i_Dmg; i_Dmg = random_num ( BOLT_DAMAGE_MIN, BOLT_DAMAGE_MAX );
                
                if ( wpn_damage_user ( gi_Weaponid, i_Other, pev ( i_Ent , pev_owner ), 0, i_Dmg, DMG_NEVERGIB ) )
                {
                    pev ( i_Other, pev_origin, vf_Origin );
                    wpn_create_blood ( vf_Origin, i_Other, clamp ( ( i_Dmg * 2 ) / 10, 3, 16 ) );
                }
            }
            else if ( IsMonster ( i_Other ) )
            {
                wpn_damage_user ( gi_Weaponid, i_Other, pev ( i_Ent, pev_owner ), 0, BOLT_DAMAGE_MONSTER, DMG_BULLET | DMG_NEVERGIB );
            } 

            emit_sound ( i_Other, CHAN_BODY,  random_num ( 0, 1 ) ? gs_Hitbody2Sound : gs_Hitbody1Sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        }
        else
        {
            emit_sound ( i_Ent, CHAN_BODY, gs_HitSound, random_float ( 0.95, VOL_NORM ), ATTN_NORM, 0, 98 + random_num ( 0, 7 ) );
            pev ( i_Ent, pev_origin, vf_Origin );

            if ( !IsInWater_Origin ( vf_Origin ) )
            {
                FX_Sparks ( vf_Origin );
            }
        }

        StopThinking ( i_Ent );

        set_pev ( i_Ent, CB_THINK_STEP, ExplosionThink );
        set_pev ( i_Ent, pev_nextthink, get_gametime () + 0.1 );

        return FMRES_IGNORED;
    }

    
    public fwd_PlayerPreThink ( const id )
    {
        if ( is_user_alive ( id ) )
        {
            if ( wpn_uses_weapon( id, gi_Weaponid ) )
            {
                WeaponIdle ( id );
            }
            else 
            {
                if ( InZoom ( id ) )
                {
                    SetZoom ( id, DEFAULT_ZOOM );
                }
            }
        }
    }
    

    BoltCreate ( const id )
    {
        gi_LastBoltIndex[ id ] = engfunc ( EngFunc_CreateNamedEntity, gi_BoltClass );

        if ( gi_LastBoltIndex[ id ] )
        {
            set_pev ( gi_LastBoltIndex[ id ], pev_classname, gs_BoltClassname );
            BoltSpawn ( gi_LastBoltIndex[ id ] );

            set_pev ( gi_LastBoltIndex[ id ], CB_THINK_STEP, BubbleThink );
            set_pev ( gi_LastBoltIndex[ id ], pev_nextthink, get_gametime () + 0.2 );
            
            return gi_LastBoltIndex[ id ];
        }

        return FM_NULLENT;
    }


    BoltSpawn ( const i_Bolt )
    {
        engfunc ( EngFunc_SetModel, i_Bolt, gs_BoltModel );

        set_pev ( i_Bolt, pev_movetype, MOVETYPE_FLY );
        set_pev ( i_Bolt, pev_solid, SOLID_BBOX );
        set_pev ( i_Bolt, pev_gravity, 0.5 );
    }


    BoltExplode ( const i_Bolt )
    {
        static i_Owner; i_Owner = pev ( i_Bolt, pev_owner );
        pev ( i_Bolt, pev_origin, gvf_LastBoltOrigin[ i_Owner ] );
        
        StopThinking ( i_Bolt );
        PullOutExplosionFromWall ( i_Bolt, i_Owner );

        FX_Explosion ( Float:gvf_LastBoltOrigin[ i_Owner ] );

        wpn_radius_damage( gi_Weaponid, i_Owner, i_Bolt, BOLT_EXPLOSION_RANGE, BOLT_EXPLOSION_DAMAGE_MAX, DMG_BLAST | DMG_ALWAYSGIB );
        wpn_entity_radius_damage ( i_Owner, BOLT_EXPLOSION_DAMAGE_MAX, Float:gvf_LastBoltOrigin[ i_Owner ], BOLT_EXPLOSION_RANGE );

        RemoveBolt ( i_Bolt );
    }

    
    PullOutExplosionFromWall ( const i_Bolt, const i_Owner )
    {
        static Float:vf_Start[ e_Coord ], Float:vf_End[ e_Coord ], Float:vf_Dir[ e_Coord ];
        static Float:vf_PlaneNormal[ e_Coord ], Float:vf_EndPos[ e_Coord ], Float:f_Fraction;
        
        pev ( i_Bolt, CB_DIRECTION, vf_Dir );
        
        VectorMA ( Float:gvf_LastBoltOrigin[ i_Owner ], 8.0 , vf_Dir, vf_Start );
        VectorMS ( Float:gvf_LastBoltOrigin[ i_Owner ], 64.0, vf_Dir, vf_End );

        engfunc ( EngFunc_TraceLine, vf_Start, vf_End, DONT_IGNORE_MONSTERS, i_Bolt, 0 );
        get_tr2 ( 0, TR_flFraction, f_Fraction );

        if ( f_Fraction != 0 )
        {
            get_tr2 ( 0, TR_vecEndPos, vf_EndPos );
            get_tr2 ( 0, TR_vecPlaneNormal, vf_PlaneNormal );
        
            VectorMA ( vf_EndPos, ( BOLT_EXPLOSION_DAMAGE_MAX - 24.0 ) * 0.6, vf_PlaneNormal, Float:gvf_LastBoltOrigin[ i_Owner ] );
            set_pev ( i_Bolt, pev_origin, gvf_LastBoltOrigin[ i_Owner ] );
        }
    }
    
    
    WeaponIdle ( const id )
    {
        static Float:f_Time; f_Time = get_gametime ();
        static Float:f_Rand, b_HasClip;

        if ( gf_TimeWeaponIdle[ id ] >= f_Time )
        {
            return;
        }

        b_HasClip = !IsAmmoEmpty ( id, usr_wpn_ammo1 ) ? true : false;
        f_Rand = random_float ( 0.0, 1.0 );
        
        if ( f_Rand < 0.75 )
        {
            wpn_playanim ( id, b_HasClip ? crossbow_idle1 : crossbow_idle2 );
            gf_TimeWeaponIdle[ id ] = get_gametime () + random_float ( 10.0, 15.0 );
        }
        else
        {
            if ( b_HasClip )
            {
                wpn_playanim ( id, crossbow_fidget1 );
                gf_TimeWeaponIdle[ id ] = get_gametime () + 90.0 / 30.0;
            }
            else
            {
                wpn_playanim ( id, crossbow_fidget2 );
                gf_TimeWeaponIdle[ id ] = get_gametime () + 80.0 / 30.0;
            }
        }
    }
    

    /*
        + - - -
        |  Explosion effect.
        |  Dynamic lights, flickering particles, explosion sound. 
        
           @param vf_BoltOrigin         Current bolt origin ( float )  |
                                                                 - - - +
    */
    FX_Explosion ( const Float:vf_BoltOrigin[] )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_BoltOrigin, 0 );
        write_byte ( TE_EXPLOSION );
        write_coord_f ( vf_BoltOrigin[ x ] );
        write_coord_f ( vf_BoltOrigin[ y ] );
        write_coord_f ( vf_BoltOrigin[ z ] );
        write_short ( IsInWater_Origin ( vf_BoltOrigin ) ? gi_WExplosion : gi_Fireball );
        write_byte ( 10 );               // scale * 10
        write_byte ( 15 );               // framerate
        write_byte ( TE_EXPLFLAG_NONE ); // All flags clear makes default Half-Life explosion
    }
    

    FX_BubbleTrail( const Float:vf_From[], const Float:vf_To[], i_Count )
    {
        new Float:f_Height = GetWaterLevel ( vf_From,  vf_From[ z ], vf_From[ z ] + 256.0 );
        f_Height = f_Height - vf_From[ z ];

        if ( f_Height < 8.0 )
        {
            f_Height = GetWaterLevel ( vf_To,  vf_To[ z ], vf_To[ z ] + 256.0 );
            f_Height = f_Height - vf_To[ z ];

            if ( f_Height < 8.0 )
            {
                return;
            }

            f_Height = f_Height + vf_To[ z ] - vf_From[ z ];
        }

        if ( i_Count > 255 )
        {
            i_Count = 255;
        }

        message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte ( TE_BUBBLETRAIL );
        write_coord_f ( vf_From[ x ] );    // mins
        write_coord_f ( vf_From[ y ] );
        write_coord_f ( vf_From[ z ] );
        write_coord_f ( vf_To[ x ] );      // maxz
        write_coord_f ( vf_To[ y ] );
        write_coord_f ( vf_To[ z ] );
        write_coord_f ( f_Height );        // height
        write_short ( gi_Bubbles );
        write_byte ( i_Count );            // count
        write_coord ( 8 );                 // speed
        message_end ();
    }
    
    
    /*
        + - - -
        |  Create random sparks.
        |  8 random tracers with gravity, ricochet sprite
        
           @param vf_BoltOrigin         Current bolt origin ( float )  |
                                                                 - - - +
    */
    FX_Sparks ( const Float:vf_BoltOrigin[] )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_BoltOrigin, 0 );
        write_byte ( TE_SPARKS );
        write_coord_f ( vf_BoltOrigin[ x ] );
        write_coord_f ( vf_BoltOrigin[ y ] );
        write_coord_f ( vf_BoltOrigin[ z ] );
        message_end();
    }
    
    
    GetBoltStartOrigin ( id )
    {
        static Float:vf_vAngles[ e_Coord ], Float:vf_PunchAngles[ e_Coord ], Float:vf_AnglesAim[ e_Coord ];

        pev ( id, pev_v_angle, vf_vAngles );
        pev ( id, pev_punchangle, vf_PunchAngles );

        vf_AnglesAim[ x ] = vf_vAngles[ x ] + vf_PunchAngles[ x ];
        vf_AnglesAim[ y ] = vf_vAngles[ y ] + vf_PunchAngles[ y ];
        vf_AnglesAim[ z ] = vf_vAngles[ z ] + vf_PunchAngles[ z ];

        engfunc ( EngFunc_MakeVectors, vf_AnglesAim );

        static Float:vf_ViewOfs[ e_Coord ], Float:vf_Up[ e_Coord ];

        pev ( id, pev_origin, Float:gvf_LastBoltOrigin[ id ] );
        pev ( id, pev_view_ofs, vf_ViewOfs );

        global_get ( glb_v_up, vf_Up );

        gvf_LastBoltOrigin[ id ][ x ] = _:( ( gvf_LastBoltOrigin[ id ][ x ] + vf_ViewOfs[ x ] ) - vf_Up[ x ] * 2.0 );
        gvf_LastBoltOrigin[ id ][ y ] = _:( ( gvf_LastBoltOrigin[ id ][ y ] + vf_ViewOfs[ y ] ) - vf_Up[ y ] * 2.0 );
        gvf_LastBoltOrigin[ id ][ z ] = _:( ( gvf_LastBoltOrigin[ id ][ z ] + vf_ViewOfs[ z ] ) - vf_Up[ z ] * 2.0 );
    }
  
  
    SetZoom ( const id, const i_Value )
    {
        wpn_set_user_zoom ( id, i_Value );
        gi_InZoom[ id ] = i_Value;
    }
    
    
    ResetZoom ( id )
    {
        if ( InZoom ( id ) )
        {
            SetZoom ( id, DEFAULT_ZOOM );
        }
    }
    
    
    public RemoveBolt ( i_Bolt )
    {
        set_pev ( i_Bolt, pev_flags, FL_KILLME );
    }
    
    
    /*
        + - - -
        |  Compare two strings.
        |
           @param s_Source          First string                       
           @param s_What            Second string                     
           @param i_Wlen            Length of the second string        |
           @return                  true on success, false on failure  |
                                                                 - - - +
    */
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
    
    
    bool:IsBolt ( const i_Ent )
    {
        if ( !pev_valid ( i_Ent ) )
        {
            return false;
        }

        static s_Classname[ sizeof gs_BoltClassname + 2 ];
        pev ( i_Ent, pev_classname, s_Classname, charsmax ( s_Classname ) );

        if ( !FastCompare ( s_Classname, gs_BoltClassname, sizeof gs_BoltClassname ) )
        {
            return false;
        }
        
        return true;
    }
    
    
    bool:IsBoltTouching ( const id, &i_Hit )
    {
        static Float:f_Fraction, Float:vf_End[ e_Coord ];
        GetBoltStartOrigin ( id );
        
        global_get ( glb_v_forward, vf_End );
        VectorMA ( Float:gvf_LastBoltOrigin[ id ], 9999.0, vf_End, vf_End );
        
        engfunc( EngFunc_TraceLine, gvf_LastBoltOrigin[ id ], vf_End, DONT_IGNORE_MONSTERS, id, 0 );
        
        i_Hit = get_tr2 ( 0, TR_pHit );
        get_tr2 ( 0, TR_flFraction, f_Fraction );
        
        return f_Fraction < 1.0 ? true : false;
    }
    
    
    bool:CanTakeDamage ( const i_Ent )
    {
        static Float:f_TakeDamage; pev ( i_Ent, pev_takedamage, f_TakeDamage );
        
        if ( f_TakeDamage != DAMAGE_NO )
        {
            return true;
        }
        
        return false;
    }
    

    bool:IsAmmoEmpty ( const id, const wpn_usr_info:i_AmmoType )
    {
        static i_Weapon; i_Weapon = wpn_has_weapon ( id, gi_Weaponid );
        return wpn_get_userinfo ( id, i_AmmoType, i_Weapon ) - 1 <= 0 ? true : false;
    }
    
    
    bool:ShouldBreak ( i_Ent, const s_Classname[] )
    {
        if ( FastCompare ( s_Classname, "func_breakable", 14 ) || FastCompare ( s_Classname, "func_pushable", 13 ) && pev( i_Ent, pev_spawnflags ) & SF_PUSH_BREAKABLE )
        {
            return true;
        }
        
        return false;
    }
   

    Float:GetWaterLevel ( const Float:vf_Position[], Float:f_Minz, Float:f_Maxz )
    {
        new Float:vf_MidUp[ e_Coord ];

        vf_MidUp[ x ] = vf_Position[ x ];
        vf_MidUp[ y ] = vf_Position[ y ];
        vf_MidUp[ z ] = f_Minz;

        if ( !IsInWater_Origin ( vf_MidUp ) )
        {
            return f_Minz;
        }

        vf_MidUp[ z ] = f_Maxz;

        if ( IsInWater_Origin ( vf_MidUp ) )
        {
            return f_Maxz;
        }

        new Float:f_Diff = f_Maxz - f_Minz;

        while ( f_Diff > 1.0 )
        {
            vf_MidUp[ z ] =  f_Minz + f_Diff / 2.0;

            if ( IsInWater_Origin ( vf_MidUp ) )
            {
                f_Minz = vf_MidUp[ z ];
            }
            else
            {
                f_Maxz = vf_MidUp[ z ];
            }

            f_Diff = f_Maxz - f_Minz;
        }

        return vf_MidUp[ z ];
    }
    
    
    VectorMA ( const Float:vf_Add[], const Float:f_Scale, const Float:vf_Mult[], Float:vf_Output[] )
    {
        vf_Output[ x ] = vf_Add[ x ] + vf_Mult[ x ] * f_Scale;
        vf_Output[ y ] = vf_Add[ y ] + vf_Mult[ y ] * f_Scale;
        vf_Output[ z ] = vf_Add[ z ] + vf_Mult[ z ] * f_Scale;
    }
    
    
    VectorMS ( const Float:vf_Add[], const Float:f_Scale, const Float:vf_Mult[], Float:vf_Output[] )
    {
        vf_Output[ x ] = vf_Add[ x ] - vf_Mult[ x ] * f_Scale;
        vf_Output[ y ] = vf_Add[ y ] - vf_Mult[ y ] * f_Scale;
        vf_Output[ z ] = vf_Add[ z ] - vf_Mult[ z ] * f_Scale;
    }
    