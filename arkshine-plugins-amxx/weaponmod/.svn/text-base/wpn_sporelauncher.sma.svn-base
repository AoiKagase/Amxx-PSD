
   /* - - - - - - - - - - -

        AMX Mod X script.

          | Author  : Arkshine
          | Plugin  : WPN Spore Launcher ( OP4 )
          | Version : v1.0.0

        (!) Support : http://forums.space-headed.net/viewtopic.php?t=

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
            Basically, it's almost the same weapon that you can see in Opposing Force.

            The Spore Launcher is an improvised biological weapon seen in Opposing Force.
            Used by Corporal Adrian Shephard during the Black Mesa Incident, it consists
            of a large amphibious alien specimen which is fed spore clusters and then
            manipulated into forcefully expelling the spore clusters.

            A full description can be found here : http://half-life.wikia.com/wiki/Spore_Launcher .


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
            v1.0.0 : [ 7 jul 2008 ]

                (+) Initial release.


        Credits :
        - - - - -
            * HLSDK
            * DevconeS
            * VEN
            * H4wk / Gearbox ( models )

    - - - - - - - - - - - */

    #include <amxmodx>
    #include <fakemeta>
    #include <weaponmod_stocks>
    #include <xs>


    #define Plugin  "WPN Spore Launcher"
    #define Version "1.0.0"
    #define Author  "Arkshine"

    /* - - -
     |  Weapon information   |
                       - - - */
        new
            gs_WpnName [] = "Spore Launcher",
            gs_WpnShort[] = "snark";

    /* - - -
     |  Weapon models  |
                 - - - */
        new
            gs_Model_P[] = "models/p_spore_launcher.mdl",
            gs_Model_V[] = "models/v_spore_launcher.mdl",
            gs_Model_W[] = "models/w_spore_launcher.mdl";

    /* - - -
     |  Weapon sounds  |
                 - - - */
        new const
            gs_SplauncherFire   [] = "weapons/splauncher_fire.wav",
            gs_SplauncherAltfire[] = "weapons/splauncher_altfire.wav",
            gs_SplauncherPet    [] = "weapons/splauncher_pet.wav",
            gs_SplauncherReload [] = "weapons/splauncher_reload.wav";

    /* - - -
     |  Spore models  |
                - - - */
        new
            gs_SporeModel[] = "models/spore.mdl";

    /* - - -
     |  Spore sounds  |
                - - - */
        new const
            gs_SporeImpact[] = "weapons/splauncher_impact.wav",
            gs_SporeHit1  [] = "weapons/spore_hit1.wav",
            gs_SporeHit2  [] = "weapons/spore_hit2.wav",
            gs_SporeHit3  [] = "weapons/spore_hit3.wav";

    /* - - -
     |    Sequence   |
               - - - */
        enum
        {
            sporelauncher_idle,
            sporelauncher_fidget,
            sporelauncher_reload_reach,  // reload prepare
            sporelauncher_reload_load,   // reload in progress
            sporelauncher_reload_aim,    // reload end
            sporelauncher_fire,          // fire rocket
            sporelauncher_holster,       // holster
            sporelauncher_draw,          // draw
            sporelauncher_fire2,         // grenadefire
        };
   
   /* - - -
     |    Custom fields   |
                    - - - */
        #define SL_TOUCH_STEP  pev_iuser3
        #define SL_THINK_STEP  pev_iuser4

    /* - - -
     |    Others stuffs   |
                    - - - */
        #define MAX_CLIENTS 32
        #define NULL        0

        #define FCVAR_FLAGS ( FCVAR_SERVER | FCVAR_SPONLY | FCVAR_EXTDLL | FCVAR_UNLOGGED )

        enum e_Coord
        {
            Float:x,
            Float:y,
            Float:z
        };
        
        enum e_SporeType
        {
            Rocket, 
            Grenade
        }
    
        enum
        {
            FlyThink = 1,
            BounceThink,
            ExplodeThink
        }
        
        enum
        {
            Fire, 
            Reload
        }

        new Float:gf_TimeWeaponIdle[ MAX_CLIENTS + 1 ];
        new bool:gb_InSpecialReload[ MAX_CLIENTS + 1 ];
        new gi_Spore[ MAX_CLIENTS + 1 ];
        
        new const gs_SporeClass [] = "wpn_spore";

        new gi_Drips;
        new gi_Glow;
        new gi_Explode;
        
        new gi_SporeClass;
        new gi_SporeSprite;
        new gi_MaxEntities;
        new gi_Weaponid;

    /* - - -
     |    Macro   |
            - - - */
        #if !defined charsmax
            #define charsmax(%1)  ( sizeof ( %1 ) - 1 )
        #endif

        #define message_begin_f(%1,%2,%3) ( engfunc ( EngFunc_MessageBegin, %1, %2, %3 ) )
        #define write_coord_f(%1)         ( engfunc ( EngFunc_WriteCoord, %1 ) )


    public plugin_precache ()
    {
        // -- Weapon models
        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );
        precache_model ( gs_Model_W );

        // -- Weapon sounds
        precache_sound ( gs_SplauncherFire );    // main fire sound
        precache_sound ( gs_SplauncherAltfire ); // alternative fire sound
        precache_sound ( gs_SplauncherPet );     // idle weapon sound
        precache_sound ( gs_SplauncherReload );  // reload weapon sound

        // -- Spore model
        precache_model ( gs_SporeModel );

        // -- Spore sounds
        precache_sound ( gs_SporeImpact );
        precache_sound ( gs_SporeHit1 );
        precache_sound ( gs_SporeHit2 );
        precache_sound ( gs_SporeHit3 );

        // -- Sprites
        gi_Drips   = precache_model ( "sprites/tinyspit.spr" );
        gi_Glow    = precache_model ( "sprites/glow02.spr" );
        gi_Explode = precache_model ( "sprites/spore_exp_01.spr" );
    }
    
    
    public plugin_init ()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_sl_version", Version, FCVAR_FLAGS );

        register_forward ( FM_Think, "fwd_Think" );
        register_forward ( FM_Touch, "fwd_Touch" );
        register_forward ( FM_PlayerPreThink, "fwd_PlayerPreThink" );
    }

    
    public plugin_cfg ()
    {
        gi_SporeClass  = engfunc ( EngFunc_AllocString, "info_target" );
        gi_SporeSprite = engfunc ( EngFunc_AllocString, "env_sprite" );
        
        gi_MaxEntities  = global_get ( glb_maxEntities );
        
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

        wpn_register_event ( i_Weapon_id, event_attack1, "SporeLauncher_PrimaryAttack" );
        wpn_register_event ( i_Weapon_id, event_attack2, "SporeLauncher_SecondaryAttack" );
        wpn_register_event ( i_Weapon_id, event_draw   , "SporeLauncher_Deploy"  );
        wpn_register_event ( i_Weapon_id, event_hide   , "SporeLauncher_Holster" );
        wpn_register_event ( i_Weapon_id, event_reload , "SporeLauncher_Reload"  );
        
        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, 1.5 );
        wpn_set_float ( i_Weapon_id, wpn_refire_rate2, 1.5 );
        wpn_set_float ( i_Weapon_id, wpn_run_speed, 250.0 );

        wpn_set_integer ( i_Weapon_id, wpn_ammo1, 5 );
        wpn_set_integer ( i_Weapon_id, wpn_ammo2, 15 );
        wpn_set_integer ( i_Weapon_id, wpn_bullets_per_shot1, 1 );
        wpn_set_integer ( i_Weapon_id, wpn_bullets_per_shot2, 1 );
        wpn_set_integer ( i_Weapon_id, wpn_cost, 6410 );

        gi_Weaponid = i_Weapon_id;
    }
    
    
    public SporeLauncher_PrimaryAttack ( id )
    {
        SporeFire ( id, e_SporeType:Rocket );
    }
    
    
    public SporeLauncher_SecondaryAttack ( id )
    {
        SporeFire ( id, e_SporeType:Grenade );
    }
    
    
    SporeFire ( const id, const e_SporeType:i_Type )
    {
        static Float:vf_AnglesAim[ e_Coord ], Float:vf_Source[ e_Coord ], Float:vf_SLPosition[ e_Coord ];
        static Float:vf_Forward  [ e_Coord ], Float:vf_Right [ e_Coord ], Float:vf_Up[ e_Coord ];
        static Float:vf_PlayerAngles[ e_Coord ], Float:vf_PlayerPunchangle[ e_Coord ], Float:vf_SporeVelocity[ e_Coord ];
        
        pev ( id, pev_v_angle, vf_PlayerAngles );
        pev ( id, pev_punchangle, vf_PlayerPunchangle );
        
        xs_vec_add ( vf_PlayerAngles, vf_PlayerPunchangle, vf_AnglesAim );
        engfunc ( EngFunc_MakeVectors, vf_AnglesAim );
        vf_AnglesAim[ x ] = - vf_AnglesAim[ x ];
        
        EyePosition ( id, vf_SLPosition );
        
        global_get ( glb_v_forward, vf_Forward );
        global_get ( glb_v_right, vf_Right );
        global_get ( glb_v_up, vf_Up );
        
        vf_Source[ x ] = vf_SLPosition[ x ] + vf_Forward[ x ] * 16.0 + vf_Right[ x ] * 8.0 + vf_Up[ x ] * -8.0;
        vf_Source[ y ] = vf_SLPosition[ y ] + vf_Forward[ y ] * 16.0 + vf_Right[ y ] * 8.0 + vf_Up[ y ] * -8.0;
        vf_Source[ z ] = vf_SLPosition[ z ] + vf_Forward[ z ] * 16.0 + vf_Right[ z ] * 8.0 + vf_Up[ z ] * -8.0;
        
        if ( SporeRocket_Create ( id, vf_Source, vf_AnglesAim ) )
        {
            SetAnimation ( id, sporelauncher_fire, 1 );
            SetRecoil ( id, -5.0 );
            
            SporeRocket_Spawn ( id, i_Type );
            
            xs_vec_add ( vf_PlayerAngles, vf_PlayerPunchangle, vf_AnglesAim );
            engfunc ( EngFunc_MakeVectors, vf_AnglesAim );
            
            pev ( gi_Spore[ id ], pev_velocity, vf_SporeVelocity );
            global_get ( glb_v_forward, vf_Forward );
            
            VectorMA ( vf_SporeVelocity, i_Type == Rocket ? 1000.0 : 700.0, vf_Forward, vf_SporeVelocity );
            set_pev ( gi_Spore[ id ], pev_velocity, vf_SporeVelocity );
            
            PlaySound ( id, Fire );
            PlaySound ( id, Reload );

            UpdateAmmo ( id );
            
            gf_TimeWeaponIdle[ id ] = get_gametime () + 1.5;
            gb_InSpecialReload[ id ] = false;
        }
    }
    
    
    public SporeLauncher_Deploy ( id )
    {
         wpn_playanim ( id, sporelauncher_draw );
    }
    
    
    public SporeLauncher_Holster ( id )
    {
        wpn_playanim ( id, sporelauncher_holster );
    }   
    
    
    public SporeLauncher_Reload ( id )
    {
    
    }

    
    public fwd_Think ( i_Ent )
    {
        if ( IsSpore ( i_Ent ) )
        {
            switch ( pev ( i_Ent, SL_THINK_STEP ) )
            {
                case FlyThink    : SporeRocket_Fly ( i_Ent );
                /* case BounceThink : SporeGrenade_Bounce ( i_Ent ); */
            }
        }
    }
    
    
    public fwd_Touch ( i_Ent )
    {
        if ( IsSpore ( i_Ent ) )
        {
            switch ( pev ( i_Ent, SL_TOUCH_STEP ) )
            {
                case ExplodeThink : SporeRocket_Explode ( i_Ent );
            }
        }
    }
    
    
    SporeRocket_Explode ( const i_Ent )
    {
        set_pev ( i_Ent, SL_THINK_STEP, NULL );
        set_pev ( i_Ent, SL_TOUCH_STEP, NULL );

        emit_sound ( i_Ent, CHAN_ITEM, gs_SporeImpact, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        set_pev ( i_Ent, pev_takedamage, DAMAGE_NO );
        
        static Float:vf_SporeOrigin[ e_Coord ]; pev ( i_Ent, pev_origin, vf_SporeOrigin );
        
        message_begin_f ( MSG_PAS, SVC_TEMPENTITY, vf_SporeOrigin, 0 );
        write_byte ( TE_EXPLOSION );        // This makes a dynamic light and the explosion sprites/sound
        write_coord_f ( vf_SporeOrigin[ x ] );    // send to pas because of the sound
        write_coord_f ( vf_SporeOrigin[ y ] );
        write_coord_f ( vf_SporeOrigin[ z ] );
        write_short( gi_Explode );
        write_byte ( 25  ); // scale * 10
        write_byte ( 12  ); // framerate
        write_byte( TE_EXPLFLAG_NOSOUND );
        message_end();
        
        set_pev ( i_Ent, pev_flags, FL_KILLME );

    }
    
    
    SporeRocket_Fly ( const i_Ent )
    {
        set_pev ( i_Ent, pev_nextthink, get_gametime () + 0.01 );
        
        static Float:vf_SporeOrigin[ e_Coord ], Float:vf_SporeVelocity[ e_Coord ], Float:vf_PlaneNormal[ e_Coord ];
        
        pev ( i_Ent, pev_origin, vf_SporeOrigin );
        pev ( i_Ent, pev_velocity, vf_SporeVelocity );
        
        VectorMA ( vf_SporeOrigin, 10.0, vf_SporeVelocity, vf_SporeVelocity );
        engfunc ( EngFunc_TraceLine, vf_SporeOrigin, vf_SporeVelocity, DONT_IGNORE_MONSTERS, i_Ent, 0 );
        
        get_tr2 ( 0, TR_vecPlaneNormal, vf_PlaneNormal );
        // set_pev ( i_Ent, pev_rendermode, kRenderTransAlpha );

        message_begin_f ( MSG_PAS, SVC_TEMPENTITY, vf_SporeOrigin, 0 );
        write_byte( TE_SPRAY );
        write_coord_f ( vf_SporeOrigin[ x ] + float ( random_num ( -10, 10 ) ) );
        write_coord_f ( vf_SporeOrigin[ y ] + float ( random_num ( -10, 10 ) ) );
        write_coord_f ( vf_SporeOrigin[ z ] + float ( random_num ( -10, 10 ) ) );
        write_coord_f ( vf_PlaneNormal[ x ] );
        write_coord_f ( vf_PlaneNormal[ y ] );
        write_coord_f ( vf_PlaneNormal[ z ] );
        write_short( gi_Drips );
        write_byte ( 3 );                 // count
        write_byte ( 8  );                // speed
        write_byte ( 20 );                 // freq
        write_byte ( kRenderTransAlpha );  // render
        message_end();
    }
    
    
    SporeRocket_Create ( const id, const Float:vf_Source[], const Float:vf_Angles[] )
    {
        gi_Spore[ id ] = engfunc ( EngFunc_CreateNamedEntity, gi_SporeClass );

        if ( !gi_Spore[ id ] )
        {
            return NULL;
        }
        
        set_pev ( gi_Spore[ id ], pev_classname, gs_SporeClass );
        set_pev ( gi_Spore[ id ], pev_origin, vf_Source );
        set_pev ( gi_Spore[ id ], pev_angles, vf_Angles );
        set_pev ( gi_Spore[ id ], pev_owner, id );
        
        return gi_Spore[ id ];
    }
    
    
    SporeRocket_Spawn ( const id, const e_SporeType:i_Type )
    {
        set_pev ( gi_Spore[ id ], pev_movetype, i_Type == Rocket ? MOVETYPE_FLY : MOVETYPE_BOUNCE );
        set_pev ( gi_Spore[ id ], pev_solid, SOLID_BBOX );
        set_pev ( gi_Spore[ id ], pev_health, 1.0 );
        
        static Float:vf_SporeOrigin[ e_Coord ]; pev ( gi_Spore[ id ], pev_origin, vf_SporeOrigin );
        
        engfunc ( EngFunc_SetModel , gi_Spore[ id ], gs_SporeModel );
        engfunc ( EngFunc_SetSize  , gi_Spore[ id ], Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 8.0 } );
        engfunc ( EngFunc_SetOrigin, gi_Spore[ id ], vf_SporeOrigin );
        
        static Float:vf_SporeAngles[ e_Coord ]; pev ( gi_Spore[ id ], pev_angles, vf_SporeAngles );
        
        engfunc ( EngFunc_MakeVectors, vf_SporeAngles );
        set_pev ( gi_Spore[ id ], pev_gravity, 0.5 );
        
        /* set_pev ( gi_Spore[ id ], pev_effects, pev ( gi_Spore[ id ], pev_effects ) | EF_BRIGHTLIGHT );
        set_pev ( gi_Spore[ id ], pev_rendermode, kRenderTransTexture );
        set_pev ( gi_Spore[ id ], pev_renderfx, kRenderFxFullBright );*/

        SporeRocket_SetGlow ( id );
        
        set_pev ( gi_Spore[ id ], SL_THINK_STEP, FlyThink );
        
        switch ( i_Type )
        {
            case Rocket :
            {
                set_pev ( gi_Spore[ id ], SL_TOUCH_STEP, ExplodeThink );
                
                static Float:vf_Forward[ e_Coord ]; 
                global_get ( glb_v_forward, vf_Forward );
                
                xs_vec_mul_scalar ( vf_Forward, 250.0, vf_Forward );
                set_pev ( gi_Spore[ id ], pev_velocity, vf_Forward );
            }
            case Grenade :
            {
                set_pev ( gi_Spore[ id ], SL_TOUCH_STEP, BounceThink );
            }
        }
        
        static Float:f_Time; f_Time = get_gametime ();
        
        set_pev ( gi_Spore[ id ], pev_dmg, 50.0 );
        set_pev ( gi_Spore[ id ], pev_dmgtime  , f_Time + 2.0 );
        set_pev ( gi_Spore[ id ], pev_nextthink, f_Time + 0.1 );
    }
    
    
    SporeRocket_SetGlow ( id )
    {
        static i_Sprite; i_Sprite = engfunc ( EngFunc_CreateNamedEntity, gi_SporeClass );
        
        if ( i_Sprite )
        {
            set_pev ( i_Sprite, pev_classname, "wpn_glow_effect" );
            
            set_pev ( i_Sprite, pev_model, engfunc ( EngFunc_AllocString, "sprites/glow02.spr" ) );
            // set_pev ( i_Sprite, pev_modelindex, gi_Glow );
            
            static Float:vf_SporeOrigin[ e_Coord ]; pev ( gi_Spore[ id ], pev_origin, vf_SporeOrigin );
            
            set_pev ( i_Sprite, pev_origin, vf_SporeOrigin );
            set_pev ( i_Sprite, pev_solid, SOLID_NOT );
            
            engfunc ( EngFunc_SetModel , i_Sprite, gs_SporeModel );
            
            set_pev ( i_Sprite, pev_skin, gi_Spore[ id ] );
            set_pev ( i_Sprite, pev_body, 0 );
            set_pev ( i_Sprite, pev_aiment, gi_Spore[ id ] );
            set_pev ( i_Sprite, pev_movetype, MOVETYPE_FOLLOW );
            
            set_pev ( i_Sprite, pev_scale, 10 );
            
            set_pev ( i_Sprite, pev_rendermode, kRenderTransAdd );
            set_pev ( i_Sprite, pev_rendercolor, Float:{ 150.0, 158.0, 19.0 } );
            set_pev ( i_Sprite, pev_renderamt, 255 );
            set_pev ( i_Sprite, pev_renderfx, kRenderFxNoDissipation );

            set_pev ( i_Sprite, pev_spawnflags, pev ( i_Sprite, pev_flags ) | SF_SPRITE_TEMPORARY );
            set_pev ( i_Sprite, pev_flags, pev ( i_Sprite, pev_flags ) | FL_SKIPLOCALHOST );
            
            dllfunc ( DLLFunc_Spawn, i_Sprite );
        }
    }
    
    
    bool:IsSpore ( const i_Ent )
    {
        if ( !pev_valid ( i_Ent ) )
        {
            return false;
        }
    
        static s_Classname[ sizeof gs_SporeClass + 1 ];
        pev ( i_Ent, pev_classname, s_Classname, charsmax ( s_Classname ) );
        
        if ( FastCompare ( s_Classname, gs_SporeClass, sizeof gs_SporeClass ) )
        {
            return true;
        }
        
        return false;
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
    
    
    UpdateAmmo ( id )
    {
    
    }
    
    
    PlaySound ( const index, const i_Event )
    {
        switch ( i_Event )
        {
            case Fire   : emit_sound ( index, CHAN_WEAPON, gs_SplauncherFire, 0.9, ATTN_NORM, 0, PITCH_NORM );
            case Reload : emit_sound ( index, CHAN_ITEM, gs_SplauncherReload, 0.7, ATTN_NORM, 0, PITCH_NORM );
        }
    }
    
    
    SetAnimation ( id, i_Anim, i_Body = -1 )
    {
        if ( i_Body != -1 )
        {
            set_pev ( id, pev_body, i_Body );
        }
        
        wpn_playanim ( id, i_Anim );
    }
    
    
    SetRecoil ( id, Float:f_Value )
    {
        static Float:vf_Recoil[ e_Coord ]; 
        
        vf_Recoil[ x ] = f_Value;
        vf_Recoil[ y ] = vf_Recoil[ z ] = 0.0;
        
        set_pev ( id, pev_punchangle, vf_Recoil );
    }
    
    
    /*
        + - - -
        |  Get player's eye position.
        |
           @param id                Player id who is holding the SporeLauncher  |
           @param vf_Source         Output of the player's eye position         |
                                                                          - - - +
    */
    EyePosition ( const id, Float:vf_Source[] )
    {
        static Float:vf_ViewOfs[ e_Coord ];

        pev ( id, pev_origin, vf_Source );
        pev ( id, pev_view_ofs, vf_ViewOfs );

        xs_vec_add ( vf_Source, vf_ViewOfs, vf_Source );
    }
    
    
    VectorMA ( const Float:vf_Add[], const Float:f_Scale, const Float:vf_Mult[], Float:vf_Output[] )
    {
        vf_Output[ x ] = vf_Add[ x ] + vf_Mult[ x ] * f_Scale;
        vf_Output[ y ] = vf_Add[ y ] + vf_Mult[ y ] * f_Scale;
        vf_Output[ z ] = vf_Add[ z ] + vf_Mult[ z ] * f_Scale;
    }
    