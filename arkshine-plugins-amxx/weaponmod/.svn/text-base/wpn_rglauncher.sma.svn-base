
   /* - - - - - - - - - - -

        AMX Mod X script.

          | Author  : Arkshine
          | Plugin  : WPN Rocket/Grenade Launcher
          | Version : v1.0.0

        (!) Support : http://forums.space-headed.net/viewtopic.php?t=524

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
            Basically, it's almost the same weapon that you can see in Quake1 or Deathmatch Classic.

            Primary attack fires a powerful straighforward rocket.
            Secondary attack throws grenades which can bounce and explode after x seconds.


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
            v1.0.0 : [ 2008, Dec 17 ]

                (+) Initial release.


        Credits :
        - - - - -
            * HLSDK
            * DevconeS
            * XDM ( weapon models )

    - - - - - - - - - - - */

    #include <amxmodx>
    #include <fakemeta>
    #include <weaponmod_stocks>


    #define Plugin  "WPN Rocket/Grenade Launcher"
    #define Version "1.0.0"
    #define Author  "Arkshine"


    /* - - -
     |  CUSTOMIZATION  |
                 - - - */
        // --| GENERAL.
        #define GL_REFIRE_RATE_PRI       0.8     // --| Rate Of Fire : Primary attack. (float)
        #define GL_REFIRE_RATE_SEC       0.8     // --| Rate Of Fire : Primary attack. (float)
        #define GL_RELOAD_TIME           1.3     // --| Reload time. (float)
        #define GL_RECOIL                -10.0   // --| Recoil. (float)
        #define GL_RUN_SPEED             260.0   // --| Player's speed when holding this weapon. (float)
        #define GL_AMMO_AMOUNT_PRI       1       // --| Weapons clip.
        #define GL_AMMO_AMOUNT_SEC       10      // --| Weapon bp ammo.
        #define GL_WEAPON_COST           12000   // --| Weapon cost at buying.

        // --| ROCKET ; PRIMARY ATTACK.
        #define ROCKET_VELOCITY          1000.0  // --| Rocket speed. (float)
        #define ROCKET_DAMAGE            195.0   // --| Max damage that rocket can be do. (float)
        #define ROCKET_LIFE              5.0     // --| Rocket life before exploding. (float)
        #define ROCKET_PARTICULE_COLOR   125.0   // --| Trail of particle : unique color. (float)
        #define ROCKET_PARTICULE_COUNT   2.0     // --| Particle amount. (float)

        // --| GRENADE ; SECONDARY ATTACK.
        #define GRENADE_VELOCITY         1000.0  // --| Grenade speed. (float)
        #define GRENADE_DAMAGE           195.0   // --| Max damage that rocket can be do. (float)
        #define GRENADE_LIFE             2.5     // --| Rocket life before exploding. (float)
        #define GRENADE_PARTICULE_COLOR  8.0     // --| Trail of particle : unique color. (float)
        #define GRENADE_PARTICULE_COUNT  3.0     // --| Particle amount. (float)

        // --| ROCKET TRAIL.
        #define BEAMFOLLOW_LIFE          20      // --| Beam life.
        #define BEAMFOLLOW_WIDTH         4       // --| Beam width.
        #define BEAMFOLLOW_RED           224     // --| Beam red color.
        #define BEAMFOLLOW_GREEN         224     // --| Beam green color.
        #define BEAMFOLLOW_BLUE          255     // --| Beam blue color.
        #define BEAMFOLLOW_BRIGHTNESS    255     // --| Beam brightness color.


    /* - - -
     |  WEAPON INFORMATION   |
                       - - - */
        new
            gs_WpnName [] = "Rocket/Grenade Laucher",
            gs_WpnShort[] = "rglaucher";

    /* - - -
     |  WEAPON MODELS  |
                 - - - */
        new
            gs_Model_P[] = "models/p_glauncher.mdl",
            gs_Model_V[] = "models/v_glauncher.mdl";

    /* - - -
     |  WEAPON SOUNDS  |
                 - - - */
        new const
            gs_GlauncherGrenade[] = "weapons/gl_grenade.wav",
            gs_GlauncherRocket [] = "weapons/gl_sgun1.wav",
            gs_GlauncherSelect [] = "weapons/glauncher_select.wav";

    /* - - - - -
     |  ROCKET/GRENADE MODELS  |
                     - - - - - */
        new const
            gs_GrenadeModel[] = "models/gl_grenade.mdl",
            gs_RocketModel [] = "models/gl_rocket.mdl";

    /* - - - - -
     |  ROCKET/GRENADE SOUNDS  |
                     - - - - - */
        new const
            gs_RocketExplode1 [] = "weapons/rocket_explode1.wav",
            gs_RocketExplode2 [] = "weapons/rocket_explode2.wav",
            gs_RocketExplode3 [] = "weapons/rocket_explode3.wav",
            gs_RocketFire     [] = "weapons/rocket1.wav";

        new const
            gs_GrenadeExplode1[] = "weapons/explode3.wav",
            gs_GrenadeExplode2[] = "weapons/explode4.wav",
            gs_GrenadeExplode3[] = "weapons/explode5.wav",
            gs_GrenadeBounce  [] = "weapons/gl_bounce.wav";

        new const
            gs_ExplodeUW      [] = "weapons/explode_uw.wav",
            gs_RocketSound    [] = "weapons/rocket1.wav";

    /* - - -
     |    SEQUENCE   |
               - - - */
        enum
        {
            glauncher_idle,
            glauncher_fidget,
            glauncher_reload,
            glauncher_fire,
            glauncher_holster,
            glauncher_draw
        };

    /* - - -
     |    OTHERS STUFFS   |
                    - - - */
        #define MAX_CLIENTS 32
        #define FCVAR_FLAGS ( FCVAR_SERVER | FCVAR_SPONLY )

        #define HEAD_IN_WATER 3
        #define GL_STEP_TOUCH pev_iuser1
        #define GL_STEP_THINK pev_iuser2
        #define GL_UNIQUE_ID  pev_iuser3
        #define NULL 0

        // --| Used fo readability.
        enum _:Coord_e { Float:x, Float:y, Float:z };
        enum _:Angle_e { Float:pitch, Float:yaw, Float:roll };

        enum ( <<= 1 ) { angles = 1, v_angle, punchangle };

        enum { ShootRocket = 1, ShootGrenade };
        enum { IgniteThink = 1, TrailThink  , CreateSmoke, CreateSpark };
        enum { RocketTouch = 1, GrenadeTouch, SparkTouch };

        new Float:gf_TimeWeaponIdle[ MAX_CLIENTS + 1 ];
        new bool:gb_UsesWeapon     [ MAX_CLIENTS + 1 ];

        new gi_WeaponId;
        new gi_GrenadeClass;
        new gi_MaxClients;
        new gi_MsgShake;
        new gi_SparkClass;

        new gi_Bubbles;
        new gi_WExplosion;
        new gi_Fireball;
        new gi_Smoke;
        new gi_Trail;


    /* - - -
     |    MACROS   |
             - - - */
        #define VectorSubtract(%1,%2,%3) ( %3[ x ] = %1[ x ] - %2[ x ], %3[ y ] = %1[ y ] - %2[ y ], %3[ z ] = %1[ z ] - %2[ z ] )
        #define VectorAdd(%1,%2,%3)      ( %3[ x ] = %1[ x ] + %2[ x ], %3[ y ] = %1[ y ] + %2[ y ], %3[ z ] = %1[ z ] + %2[ z ] )
        #define VectorScale(%1,%2,%3)    ( %3[ x ] = %2 * %1[ x ], %3[ y ] = %2 * %1[ y ], %3[ z ] = %2 * %1[ z ] )
        #define VectorLength(%1)         ( floatsqroot ( %1[ x ] * %1[ x ] + %1[ y ] * %1[ y ] + %1[ z ] * %1[ z ] ) )
        #define VectorMA(%1,%2,%3,%4)    ( %4[ x ] = %1[ x ] + %2 * %3[ x ], %4[ y ] = %1[ y ] + %2 * %3[ y ], %4[ z ] = %1[ z ] + %2 * %3[ z ] )
        #define VectorMS(%1,%2,%3,%4)    ( %4[ x ] = %1[ x ] - %2 * %3[ x ], %4[ y ] = %1[ y ] - %2 * %3[ y ], %4[ z ] = %1[ z ] - %2 * %3[ z ] )

        #if !defined charsmax
            #define charsmax(%1)  ( sizeof ( %1 ) - 1 )
        #endif

        #define message_begin_f(%1,%2,%3) ( engfunc ( EngFunc_MessageBegin, %1, %2, %3 ) )
        #define write_coord_f(%1)         ( engfunc ( EngFunc_WriteCoord, %1 ) )


    public plugin_precache ()
    {
        // --| Weapon models.
        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );

        // --| Weapon sounds.
        precache_sound ( gs_GlauncherGrenade );
        precache_sound ( gs_GlauncherRocket );
        precache_sound ( gs_GlauncherSelect );

        // --| Rocket/Grenade model.
        precache_model ( gs_RocketModel );
        precache_model ( gs_GrenadeModel );

        // --| Rocket souns.
        precache_sound ( gs_RocketFire );
        precache_sound ( gs_RocketExplode1 );
        precache_sound ( gs_RocketExplode2 );
        precache_sound ( gs_RocketExplode3 );

        // --| Grenade sounds.
        precache_sound ( gs_GrenadeBounce );
        precache_sound ( gs_GrenadeExplode1 );
        precache_sound ( gs_GrenadeExplode2 );
        precache_sound ( gs_GrenadeExplode3 );

        // --| Explosion sound under water.
        precache_sound ( gs_ExplodeUW );

        // --| Explosion sprites.
        gi_Bubbles    = precache_model ( "sprites/bubble.spr" );
        gi_WExplosion = precache_model ( "sprites/WXplo1.spr" );
        gi_Fireball   = precache_model ( "sprites/zerogxplode.spr" );
        gi_Smoke      = precache_model ( "sprites/steam1.spr" );
        gi_Trail      = precache_model ( "sprites/smoke.spr" );
    }


    public plugin_init ()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_gl_version", Version, FCVAR_FLAGS );

        register_forward ( FM_PlayerPreThink, "Forward_PreThink" );
        register_forward ( FM_Touch, "Forward_Touch" );
        register_forward ( FM_Think, "Forward_Think" );
    }

    
    public plugin_cfg ()
    {
        gi_GrenadeClass  = gi_SparkClass = engfunc ( EngFunc_AllocString, "info_target" );
        gi_MsgShake   = get_user_msgid ( "ScreenShake" );
        gi_MaxClients = get_maxplayers ();

        CreateWeapon ();
    }


    public client_putinserver ( id )
    {
        gf_TimeWeaponIdle[ id ] = 0.0;
        gb_UsesWeapon    [ id ] = false;
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

        wpn_register_event ( i_Weapon_id, event_attack1, "GLauncher_PrimaryAttack" );
        wpn_register_event ( i_Weapon_id, event_attack2, "GLauncher_SecondaryAttack" );
        wpn_register_event ( i_Weapon_id, event_draw   , "GLauncher_Deploy"  );
        wpn_register_event ( i_Weapon_id, event_hide   , "GLauncher_Holster" );
        wpn_register_event ( i_Weapon_id, event_reload , "GLauncher_Reload" );
        wpn_register_event ( i_Weapon_id, event_weapondrop_post, "GLauncher_Drop" );

        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, GL_REFIRE_RATE_PRI );
        wpn_set_float ( i_Weapon_id, wpn_refire_rate2, GL_REFIRE_RATE_SEC );
        wpn_set_float ( i_Weapon_id, wpn_reload_time , GL_RELOAD_TIME );
        wpn_set_float ( i_Weapon_id, wpn_run_speed   , GL_RUN_SPEED );

        wpn_set_integer ( i_Weapon_id, wpn_ammo1, GL_AMMO_AMOUNT_PRI );
        wpn_set_integer ( i_Weapon_id, wpn_ammo2, GL_AMMO_AMOUNT_SEC );
        wpn_set_integer ( i_Weapon_id, wpn_bullets_per_shot1, 1 );
        wpn_set_integer ( i_Weapon_id, wpn_bullets_per_shot2, 1 );
        wpn_set_integer ( i_Weapon_id, wpn_cost, GL_WEAPON_COST );

        gi_WeaponId = i_Weapon_id;
    }


    public GLauncher_PrimaryAttack ( const id )
    {
        GLauncher_Fire ( id, ShootRocket );
    }


    public GLauncher_SecondaryAttack ( const id )
    {
        GLauncher_Fire ( id, ShootGrenade );
    }


    public GLauncher_Deploy ( const id )
    {
        emit_sound ( id, CHAN_WEAPON, gs_GlauncherSelect, VOL_NORM, ATTN_NORM, NULL, PITCH_NORM );
        UTIL_PlayAnimation ( id, glauncher_draw );
    }


    public GLauncher_Holster ( const id )
    {
        UTIL_PlayAnimation ( id, glauncher_holster );
    }


    public GLauncher_Reload ( const id )
    {
        UTIL_PlayAnimation ( id, glauncher_reload, 2 );
        gf_TimeWeaponIdle[ id ] = get_gametime () + random_float ( 3.0, 5.0 );
    }


    public GLauncher_Drop( const id, const i_Ent )
    {
        // --| Set the world model.
        engfunc ( EngFunc_SetModel, i_Ent, gs_Model_P );
        set_pev ( i_Ent, pev_sequence, 1 );
        
        // --| Up a bit from ground.
        engfunc( EngFunc_SetSize, i_Ent, Float:{ -16.0, -16.0, 0.0 }, Float:{ 16.0, 16.0, 16.0 } );
    }


    public Forward_PreThink ( const id )
    {
        if ( is_user_alive ( id ) && wpn_uses_weapon ( id, gi_WeaponId ) )
        {
            GLauncher_Idle ( id );
        }
    }


    public Forward_Touch ( const i_Ent, const i_Other )
    {
        if ( UTIL_IsValid ( i_Ent ) )
        {
            switch ( UTIL_GetTouch ( i_Ent ) )
            {
                case RocketTouch  : GLauncher_RocketTouch  ( i_Ent, i_Other );
                case GrenadeTouch : GLauncher_GrenadeTouch ( i_Ent, i_Other );
                case SparkTouch   : GLauncher_SparkTouch ( i_Ent );
            }
        }
    }


    public Forward_Think ( const i_Ent )
    {
        if ( UTIL_IsValid ( i_Ent ) )
        {
            switch ( UTIL_GetThink ( i_Ent ) )
            {
                case TrailThink  : GLauncher_Trail ( i_Ent );
                case IgniteThink : GLauncher_IgniteThink ( i_Ent );
                case CreateSmoke : GLauncher_SmokeExplosion ( i_Ent );
                case CreateSpark : GLauncher_SparksExplosion2 ( i_Ent );
            }
        }
    }
    

    GLauncher_Fire ( const id, const i_ShootType )
    {
        static Float:vf_Forward[ Coord_e ], Float:vf_vAngle[ Angle_e ];
        static Float:vf_Source [ Coord_e ], Float:vf_Temp  [ Coord_e ];

        UTIL_PlayAnimation ( id, glauncher_fire );
        UTIL_GetStartPosition ( id, 20.0, 2.0, _, vf_Source );
        
        global_get ( glb_v_forward, vf_Forward );
        pev ( id, pev_v_angle, vf_vAngle );

        static Float:vf_VelocitySR[ Coord_e ], Float:vf_VelocitySG[ Coord_e ];

        switch ( i_ShootType )
        {
            case ShootRocket  :
            {
                emit_sound ( id, CHAN_WEAPON, gs_GlauncherRocket, VOL_NORM, ATTN_NORM, NULL, PITCH_NORM );

                VectorScale ( vf_Forward, ROCKET_VELOCITY, vf_VelocitySR );
                GLauncher_ShootRocket ( vf_Source, vf_VelocitySR, id, ROCKET_LIFE );
            }
            case ShootGrenade :
            {
                emit_sound ( id, CHAN_WEAPON, gs_GlauncherGrenade, VOL_NORM, ATTN_NORM, NULL, PITCH_NORM );

                if ( vf_vAngle[ x ] )
                {
                    VectorScale ( vf_Forward, GRENADE_VELOCITY, vf_VelocitySG );

                    global_get ( glb_v_up, vf_Temp );
                    VectorScale ( vf_Temp, 200.0, vf_Temp );
                    VectorAdd   ( vf_VelocitySG, vf_Temp, vf_VelocitySG );

                    global_get ( glb_v_right, vf_Temp );
                    VectorScale ( vf_Temp, 10.0 * random_float ( -1.0, 1.0 ), vf_Temp );
                    VectorAdd   ( vf_VelocitySG, vf_Temp, vf_VelocitySG );

                    global_get ( glb_v_up, vf_Temp );
                    VectorScale ( vf_Temp, 10.0 * random_float ( -1.0, 1.0 ), vf_Temp );
                    VectorAdd   ( vf_VelocitySG, vf_Temp, vf_VelocitySG );
                }
                else
                {
                    VectorScale ( vf_Forward, GRENADE_VELOCITY, vf_VelocitySG );
                    vf_VelocitySG[ z ] = GRENADE_VELOCITY / 3;
                }

                GLauncher_ShootGrenade ( vf_Source, vf_VelocitySG, id, GRENADE_LIFE );
            }
        }

        UTIL_SetRecoil ( id, -10.0 );
        gf_TimeWeaponIdle[ id ] = get_gametime () + 0.8;
    }


    GLauncher_ShootRocket ( const Float:vf_Origin[], const Float:vf_Velocity[], const i_Owner, const Float:f_Time )
    {
        static i_Rocket;

        if ( ( i_Rocket = engfunc ( EngFunc_CreateNamedEntity, gi_GrenadeClass ) ) )
        {
            static vf_Temp[ Angle_e ], Float:f_CurrentTime; f_CurrentTime = get_gametime ();

            set_pev ( i_Rocket, pev_classname, "wpn_gl_rocket" );
            set_pev ( i_Rocket, pev_origin, vf_Origin );
            set_pev ( i_Rocket, pev_owner, i_Owner );

            set_pev ( i_Rocket, pev_movetype, MOVETYPE_FLYMISSILE );
            set_pev ( i_Rocket, pev_solid, SOLID_BBOX );
            set_pev ( i_Rocket, pev_takedamage, DAMAGE_NO );
            set_pev ( i_Rocket, pev_gravity, 0.5 );
            set_pev ( i_Rocket, pev_health, 4.0 );

            engfunc ( EngFunc_VecToAngles, vf_Velocity, vf_Temp );
            set_pev ( i_Rocket, pev_angles, vf_Temp );

            engfunc ( EngFunc_SetModel , i_Rocket, gs_RocketModel );
            engfunc ( EngFunc_SetSize  , i_Rocket, Float:{ 0.0, 0.0, 0.0 }, Float:{ 0.0, 0.0, 0.0 } );
            engfunc ( EngFunc_SetOrigin, i_Rocket, vf_Origin );

            set_pev ( i_Rocket, pev_velocity, vf_Velocity );
            set_pev ( i_Rocket, pev_skin, 0 );
            set_pev ( i_Rocket, pev_dmg, ROCKET_DAMAGE );

            UTIL_SetThink ( i_Rocket, IgniteThink, f_CurrentTime + 0.2 );
            UTIL_SetTouch ( i_Rocket, RocketTouch );

            set_pev ( i_Rocket, pev_dmgtime, f_CurrentTime + f_Time );
        }
    }


    GLauncher_ShootGrenade ( const Float:vf_Origin[], const Float:vf_Velocity[], const i_Owner, Float:f_Time )
    {
        static i_Grenade;

        if ( ( i_Grenade = engfunc ( EngFunc_CreateNamedEntity, gi_GrenadeClass ) ) )
        {
            static vf_Temp[ Angle_e ], Float:f_CurrentTime; f_CurrentTime = get_gametime ();

            set_pev ( i_Grenade, pev_classname, "wpn_gl_grenade" );
            set_pev ( i_Grenade, pev_origin, vf_Origin );
            set_pev ( i_Grenade, pev_owner, i_Owner );

            set_pev ( i_Grenade, pev_movetype, MOVETYPE_BOUNCE );
            set_pev ( i_Grenade, pev_solid, SOLID_BBOX );
            set_pev ( i_Grenade, pev_takedamage, DAMAGE_YES );
            set_pev ( i_Grenade, pev_health, 4.0 );

            engfunc ( EngFunc_VecToAngles, vf_Velocity, vf_Temp );
            set_pev ( i_Grenade, pev_angles, vf_Temp );

            engfunc ( EngFunc_SetModel , i_Grenade, gs_GrenadeModel );
            engfunc ( EngFunc_SetSize  , i_Grenade, Float:{ 0.0, 0.0, 0.0 }, Float:{ 0.0, 0.0, 0.0 } );
            engfunc ( EngFunc_SetOrigin, i_Grenade, vf_Origin );

            set_pev ( i_Grenade, pev_avelocity, Float:{ 300.0, 300.0, 300.0 } );
            set_pev ( i_Grenade, pev_velocity, vf_Velocity );
            set_pev ( i_Grenade, pev_friction, 0.5 );

            set_pev ( i_Grenade, pev_nextthink, f_CurrentTime );
            set_pev ( i_Grenade, pev_skin, 1 );
            set_pev ( i_Grenade, pev_dmg, GRENADE_DAMAGE );

            UTIL_SetThink ( i_Grenade, TrailThink, f_CurrentTime + 0.1 );
            UTIL_SetTouch ( i_Grenade, GrenadeTouch );

            set_pev ( i_Grenade, pev_dmgtime, f_CurrentTime + f_Time );
        }
    }


    GLauncher_IgniteThink ( const i_Rocket )
    {
        UTIL_SetThink ( i_Rocket, TrailThink, get_gametime () + 0.1 );
                
        set_pev ( i_Rocket, pev_effects, pev ( i_Rocket, pev_effects ) | EF_LIGHT );
        set_pev ( i_Rocket, pev_takedamage, DAMAGE_YES );
        set_pev ( i_Rocket, pev_avelocity, Float:{ 0.0, 0.0, 300.0 } );

        engfunc ( EngFunc_SetSize, i_Rocket, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );

        emit_sound ( i_Rocket, CHAN_WEAPON, gs_RocketSound, VOL_NORM, ATTN_NORM, NULL, PITCH_NORM );
        FX_BeamFollow ( i_Rocket, gi_Trail, BEAMFOLLOW_LIFE, BEAMFOLLOW_WIDTH, BEAMFOLLOW_RED, BEAMFOLLOW_GREEN, BEAMFOLLOW_BLUE, BEAMFOLLOW_BRIGHTNESS );
    }


    GLauncher_Trail ( const i_Ent )
    {
        static Float:f_CurrTime; f_CurrTime = get_gametime ();
        static Float:f_DmgTime; pev ( i_Ent, pev_dmgtime, f_DmgTime );

        if ( f_DmgTime <= f_CurrTime )
        {
            UTIL_SetThink ( i_Ent, NULL, 0.0 );
            UTIL_SetTouch ( i_Ent, NULL );

            FX_KillBeam ( i_Ent );
            UTIL_StopGrenadeSound ( i_Ent );

            GLauncher_Detonate ( i_Ent );
            return;
        }

        static Float:vf_Origin[ Coord_e ], Float:vf_Velocity[ Coord_e ];

        pev ( i_Ent, pev_origin, vf_Origin );
        pev ( i_Ent, pev_velocity, vf_Velocity );

        UTIL_VectorNormalize ( vf_Velocity );
        VectorMS ( vf_Origin, pev ( i_Ent, pev_dmg ) * 0.30, vf_Velocity, vf_Origin );

        switch ( pev ( i_Ent, pev_skin ) )
        {
            case 0 : engfunc ( EngFunc_ParticleEffect, vf_Origin, vf_Velocity, ROCKET_PARTICULE_COLOR, ROCKET_PARTICULE_COUNT );
            case 1 : engfunc ( EngFunc_ParticleEffect, vf_Origin, vf_Velocity, GRENADE_PARTICULE_COLOR, GRENADE_PARTICULE_COUNT );
        }

        set_pev ( i_Ent, pev_nextthink, f_CurrTime + 0.01 );
    }


    GLauncher_RocketTouch ( const i_Rocket, const i_Other )
    {
        // --| Get the current rocket origin.
        static Float:vf_Origin[ Coord_e ]; pev ( i_Rocket, pev_origin, vf_Origin );

        // --| Rocket hits entity ( player or not ).
        if ( i_Other )
        {
            // --| Do some direct damage.
            wpn_damage_user ( gi_WeaponId, i_Other, pev ( i_Rocket, pev_owner ), 0, random_num ( 100, 200 ), DMG_BULLET | DMG_ALWAYSGIB );
        }

        // --| Kill the attached beam.
        FX_KillBeam ( i_Rocket );

        // --| Don't think anymore.
        UTIL_SetThink ( i_Rocket, NULL, 0.0 );
        UTIL_SetTouch ( i_Rocket, NULL );

        // --| Stop the rocket sound.
        UTIL_StopGrenadeSound ( i_Rocket );

        // --| Rocket can explode now.
        GLauncher_Detonate ( i_Rocket );
    }


    GLauncher_GrenadeTouch ( const i_Grenade, const i_Other )
    {
        static Float:f_TakeDamage; pev ( i_Other, pev_takedamage, f_TakeDamage );

        // --| We touch an entity which can take damage. ( mostyl player )
        if ( f_TakeDamage == DAMAGE_AIM )
        {
            // --| Grenade should detonate right now.
            GLauncher_Detonate ( i_Grenade );
            return;
        }

        // --| Get the current grenade velocity.
        static Float:vf_Velocity[ Coord_e ]; pev ( i_Grenade, pev_velocity, vf_Velocity );

        // --| Grenade is on the ground.
        if ( pev ( i_Grenade, pev_flags ) & FL_ONGROUND )
        {
            // --| Add some friction.
            VectorScale ( vf_Velocity, 0.75, vf_Velocity );
            set_pev ( i_Grenade, pev_velocity, vf_Velocity );

            // --| No more enough velocity.
            if ( VectorLength ( vf_Velocity ) <= 20.0 )
            {
                // --| Grenade should stop to spin.
                set_pev ( i_Grenade, pev_avelocity, Float:{ 0.0, 0.0, 0.0 } );
            }
        }

        // --| Bounce sound.
        emit_sound ( i_Grenade, CHAN_BODY, gs_GrenadeBounce, VOL_NORM / 2, ATTN_NORM, 0, PITCH_NORM );

        // --| No more velocity.
        if ( UTIL_IsVectorNull ( vf_Velocity ) )
        {
            // --| No grenade should stop to spin.
            set_pev ( i_Grenade, pev_avelocity, Float:{ 0.0, 0.0, 0.0 } );
        }
    }


    GLauncher_SparkTouch ( const i_Ent )
    {
        // --| Retrieve the current spark velocity.
        static Float:vf_Velocity[ Coord_e ]; pev ( i_Ent, pev_velocity, vf_Velocity );

        // --| Decrease its velocity a bit.
        VectorScale ( vf_Velocity, pev ( i_Ent, pev_flags ) & FL_ONGROUND ? 0.1 : 0.6, vf_Velocity );
        set_pev ( i_Ent, pev_velocity, vf_Velocity );

        // --| If velocity is now too low, we stop the spark movement.
        if ( vf_Velocity[ x ] * vf_Velocity[ x ] + vf_Velocity[ y ] * vf_Velocity[ y ] < 10.0 )
        {
            set_pev ( i_Ent, pev_speed, 0.0 );
        }
    }


    GLauncher_Detonate ( const i_Ent )
    {
        // --| Initialize variables. We want to get 2 points to trace a line.
        static Float:vf_Spot[ Coord_e ], Float:vf_End[ Coord_e ], tr;
        static Float:vf_Velocity[ Coord_e ], Float:vf_Origin[ Coord_e ];

        // --| Get the current entity origin.
        pev ( i_Ent, pev_origin, vf_Origin );

        // --| If the entity is grenade, using this method.
        if ( pev ( i_Ent, pev_skin ) )
        {
            // --| Trace start from entity origin.
            vf_End[ x ] = vf_Spot[ x ] = vf_Origin[ x ];
            vf_End[ y ] = vf_Spot[ y ] = vf_Origin[ y ];
            vf_End[ z ] = vf_Spot[ z ] = vf_Origin[ z ];

            // --| A bit above and below.
            vf_Spot[ z ] += 8.0;
            vf_End [ z ] -= 48.0;
        }
        // --| Entity is a rocket, another method.
        else
        {
            // --| We get the points from the current rocket velocity.
            pev ( i_Ent, pev_velocity, vf_Velocity );
            UTIL_VectorNormalize ( vf_Velocity );

            // --| A bit left/right considering the current direction.
            VectorMS ( vf_Origin, 16.0, vf_Velocity , vf_Spot );
            VectorMA ( vf_Origin, 16.0, vf_Velocity, vf_End );
        }

        // --| We have our 2 points, we trace a line.
        engfunc ( EngFunc_TraceLine, vf_Spot, vf_End, IGNORE_MONSTERS, i_Ent, tr );

        // --| Entity ( rocket/grenade ) can explode now!
        GLauncher_Explode ( i_Ent, tr, DMG_BLAST | DMG_ALWAYSGIB );
    }


    GLauncher_Explode ( const i_Grenade, const i_Tr, const i_DamageBits )
    {
        static Float:vf_EndPos[ Coord_e ], Float:vf_NormalPlane[ Coord_e ], Float:vf_Origin[ Coord_e ];
        static Float:f_Fraction, bool:b_InWater, i_Hit;

        set_pev ( i_Grenade, pev_model, 0 );
        set_pev ( i_Grenade, pev_solid, SOLID_NOT );
        set_pev ( i_Grenade, pev_takedamage, DAMAGE_NO );

        get_tr2 ( i_Tr, TR_flFraction, f_Fraction );
        get_tr2 ( i_Tr, TR_vecEndPos, vf_EndPos );
        get_tr2 ( i_Tr, TR_vecPlaneNormal, vf_NormalPlane );

        i_Hit = UTIL_Instance ( get_tr2 ( i_Tr, TR_pHit ) );

        if ( f_Fraction != 1.0 )
        {
            // --| Pull out a bit the explosion.
            VectorMA ( vf_EndPos, pev ( i_Grenade, pev_dmg ) * 0.4, vf_NormalPlane, vf_Origin );
            set_pev ( i_Grenade, pev_origin, vf_Origin );
        }

        pev ( i_Grenade, pev_origin, vf_Origin );
        b_InWater = bool:( UTIL_LiquidContents ( vf_Origin ) );

        FX_Explosion ( i_Grenade, b_InWater, vf_Origin );
        FX_Explosion2 ( vf_Origin );

        if ( pev ( i_Grenade, pev_flags ) & FL_ONGROUND )
        {
            vf_Origin[ z ] += 1.0;
            set_pev ( i_Grenade, pev_origin, vf_Origin );
        }

        static i_Owner; i_Owner = pev ( i_Grenade, pev_owner );
        static Float:f_MaxDmg; pev ( i_Grenade, pev_dmg, f_MaxDmg );
        
        set_pev ( i_Grenade, pev_owner, NULL );

        if ( b_InWater )
        {
            wpn_radius_damage ( gi_WeaponId, i_Owner, i_Grenade, f_MaxDmg * 2.0, f_MaxDmg, i_DamageBits );
            wpn_entity_radius_damage ( i_Grenade, f_MaxDmg, vf_Origin, f_MaxDmg * 2.0 );
            FX_ScreenShake ( vf_Origin, f_MaxDmg * 0.2, 0.5, 2.0, f_MaxDmg * 2.0 );
        }
        else
        {
            wpn_radius_damage ( gi_WeaponId, i_Owner, i_Grenade, f_MaxDmg * 3.0, f_MaxDmg, i_DamageBits );
            wpn_entity_radius_damage ( i_Grenade, f_MaxDmg, vf_Origin, f_MaxDmg * 2.0 );
            FX_ScreenShake ( vf_Origin, f_MaxDmg * 0.2, 0.7, 1.0, f_MaxDmg * 3.0 );

            switch ( random_num ( 0, 2 ) )
            {
                case 0 : emit_sound ( i_Grenade, CHAN_VOICE, "weapons/debris1.wav", 0.55, ATTN_NORM, NULL, PITCH_NORM );
                case 1 : emit_sound ( i_Grenade, CHAN_VOICE, "weapons/debris2.wav", 0.55, ATTN_NORM, NULL, PITCH_NORM );
                case 2 : emit_sound ( i_Grenade, CHAN_VOICE, "weapons/debris3.wav", 0.55, ATTN_NORM, NULL, PITCH_NORM );
            }
        }

        set_pev ( i_Grenade, pev_effects, pev ( i_Grenade, pev_effects ) | EF_NODRAW );
        set_pev ( i_Grenade, pev_velocity, Float:{ 0.0, 0.0, 0.0 } );
        set_pev ( i_Grenade, pev_movetype, MOVETYPE_NONE );

        if ( f_Fraction == 1.0 )
        {
            UTIL_Remove ( i_Grenade );
            return;
        }

        // --| Show some burn decals.
        FX_Decals ( i_Hit, vf_EndPos );

        // --| Prepare to create some smoke.
        UTIL_SetThink ( i_Grenade, CreateSmoke, 0.3 );

        // --| If not in water, make sparks.
        if ( !b_InWater )
        {
            // --| Random amount.
            static i_Sparkcount, i; i_Sparkcount = random_num ( 0, 3 );

            for ( i = 0; i < i_Sparkcount; ++i )
            {
                GLauncher_SparksExplosion ( vf_Origin, vf_NormalPlane, i_Owner );
            }
        }
    }


    GLauncher_SmokeExplosion ( const i_Ent )
    {
        // --| Get the current entity origin.
        static Float:vf_Origin[ Coord_e ]; pev ( i_Ent, pev_origin, vf_Origin );

        if ( engfunc ( EngFunc_PointContents, vf_Origin ) == CONTENTS_WATER )
        {
            static Float:vf_Mins[ Coord_e ], Float:vf_Maxs[ Coord_e ];
            static const Float:vf_Temp[ Coord_e ] = { 64.0, 64.0, 64.0 };

            VectorSubtract ( vf_Origin, vf_Temp, vf_Mins );
            VectorAdd ( vf_Origin, vf_Temp, vf_Maxs );

            GLauncher_BubblesExplosion ( vf_Mins, vf_Maxs, 100 );
        }
        else
        {
            FX_Smoke ( i_Ent, vf_Origin );
        }

        UTIL_Remove ( i_Ent );
    }


    GLauncher_BubblesExplosion ( const Float:vf_Mins[], const Float:vf_Maxs[], i_Count )
    {
        static Float:vf_Mid[ Coord_e ], Float:f_Height;

        VectorAdd ( vf_Mins, vf_Maxs, vf_Mid );
        VectorScale ( vf_Mid, 0.5, vf_Mid );

        f_Height = UTIL_GetWaterLevel ( vf_Mid,  vf_Mid[ z ], vf_Mid[ z ] + 1024.0 );
        f_Height = f_Height - vf_Mins[ z ];

        FX_Bubbles ( vf_Mid, vf_Mins, vf_Maxs, f_Height, i_Count );
    }


    GLauncher_SparksExplosion ( const Float:vf_Origin[], const Float:vf_PlaneNormal[], const i_Owner )
    {
        static i_Spark; i_Spark = engfunc ( EngFunc_CreateNamedEntity, gi_SparkClass );

        set_pev ( i_Spark, pev_classname, "wpn_gl_sparks" );
        set_pev ( i_Spark, pev_origin, vf_Origin );
        set_pev ( i_Spark, pev_angles, vf_PlaneNormal );
        set_pev ( i_Spark, pev_owner, i_Owner );

        static Float:vf_Velocity[ Coord_e ], Float:vf_Angles[ Coord_e ];

        pev ( i_Spark, pev_angles, vf_Angles );
        VectorScale ( vf_Angles, random_float ( 200.0, 300.0 ), vf_Velocity );

        vf_Velocity[ x ] += random_float ( -100.0, 100.0 );
        vf_Velocity[ y ] += random_float ( -100.0, 100.0 );
        vf_Velocity[ z ] = ( vf_Velocity[ z ] >= 0.0 ) ? vf_Velocity[ z ] + 200.0 : vf_Velocity[ z ] - 200.0;

        set_pev ( i_Spark, pev_velocity, vf_Velocity );
        set_pev ( i_Spark, pev_movetype, MOVETYPE_BOUNCE );
        set_pev ( i_Spark, pev_gravity, 0.5 );
        set_pev ( i_Spark, pev_solid, SOLID_NOT );

        engfunc ( EngFunc_SetModel, i_Spark, gs_Model_P );
        engfunc ( EngFunc_SetSize , i_Spark, Float:{ 0.0, 0.0, 0.0 }, Float:{ 0.0, 0.0, 0.0 } );

        set_pev ( i_Spark, pev_effects, pev ( i_Spark, pev_effects ) | EF_NODRAW );
        set_pev ( i_Spark, pev_speed, random_float ( 0.5, 1.5 ) );
        set_pev ( i_Spark, pev_angles, Float:{ 0.0, 0.0, 0.0 } );

        UTIL_SetThink ( i_Spark, CreateSpark, get_gametime () + 0.1 );
        UTIL_SetTouch ( i_Spark, SparkTouch );
    }


    GLauncher_SparksExplosion2 ( const i_Spark )
    {
        static Float:vf_Origin[ Coord_e ], Float:f_Speed;

        pev ( i_Spark, pev_origin, vf_Origin );
        pev ( i_Spark, pev_speed, f_Speed );

        FX_Sparks ( vf_Origin );

        f_Speed -= 0.1;
        set_pev ( i_Spark, pev_speed, f_Speed );

        f_Speed > 0 ?  set_pev ( i_Spark, pev_nextthink, get_gametime () + 0.1 ) : UTIL_Remove ( i_Spark );
        set_pev ( i_Spark, pev_flags, pev ( i_Spark, pev_flags ) & ~FL_ONGROUND );
    }


    GLauncher_Idle ( const id )
    {
        static Float:f_Time; f_Time = get_gametime ();

        if ( gf_TimeWeaponIdle[ id ] > f_Time )
        {
            return;
        }

        UTIL_PlayAnimation ( id, random_num ( 0, 1 ) ? glauncher_idle : glauncher_fidget );
        gf_TimeWeaponIdle[ id ] = f_Time + random_float ( 8.0, 12.0 );
    }


    FX_Explosion ( const i_Ent, const bool:b_InWater, const Float:vf_Origin[] )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte ( TE_EXPLOSION );
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        if ( b_InWater )
        {
            write_short ( gi_WExplosion );
            write_byte ( floatround ( pev ( i_Ent, pev_dmg ) * 0.25 ) );  // --| Scale
            write_byte ( 24 );  // --| Framerate
            write_byte ( TE_EXPLFLAG_NOSOUND );
        }
        else
        {
            write_short ( gi_Fireball );
            write_byte ( floatround ( pev ( i_Ent, pev_dmg ) * 0.25 ) );
            write_byte ( 24 );
            write_byte ( TE_EXPLFLAG_NOSOUND );
        }
        message_end ();

        if ( b_InWater )
        {
            emit_sound ( i_Ent, CHAN_BODY, gs_ExplodeUW, VOL_NORM, 0.3, NULL, random_num ( PITCH_LOW, PITCH_NORM + 5 ) );
        }
        else
        {
            if ( pev ( i_Ent, pev_skin ) )
            {
                switch ( random_num ( 0, 2 ) )
                {
                    case 0 : emit_sound ( i_Ent, CHAN_BODY, gs_RocketExplode1, VOL_NORM, 0.3, NULL, random_num ( PITCH_LOW, PITCH_NORM + 5 ) );
                    case 1 : emit_sound ( i_Ent, CHAN_BODY, gs_RocketExplode2, VOL_NORM, 0.3, NULL, random_num ( PITCH_LOW, PITCH_NORM + 5 ) );
                    case 2 : emit_sound ( i_Ent, CHAN_BODY, gs_RocketExplode3, VOL_NORM, 0.3, NULL, random_num ( PITCH_LOW, PITCH_NORM + 5 ) );
                }
            }
            else
            {
                switch ( random_num ( 0, 2 ) )
                {
                    case 0 : emit_sound ( i_Ent, CHAN_BODY, gs_GrenadeExplode1, VOL_NORM, 0.3, NULL, random_num ( PITCH_LOW, PITCH_NORM + 5 ) );
                    case 1 : emit_sound ( i_Ent, CHAN_BODY, gs_GrenadeExplode2, VOL_NORM, 0.3, NULL, random_num ( PITCH_LOW, PITCH_NORM + 5 ) );
                    case 2 : emit_sound ( i_Ent, CHAN_BODY, gs_GrenadeExplode3, VOL_NORM, 0.3, NULL, random_num ( PITCH_LOW, PITCH_NORM + 5 ) );
                }
            }
        }
    }


    FX_Explosion2 ( const Float:vf_Origin[] )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte ( TE_EXPLOSION2 );
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        write_byte ( 111 );  // --| Start color.
        write_byte ( 8 );    // --| Num color.
        message_end ();
    }


    FX_ScreenShake ( const Float:vf_Center[], const Float:f_Amplitude, const Float:f_Frequency, const Float:f_Duration, const Float:f_Radius )
    {
        static Float:vf_Origin[ Coord_e ];
        new Float:f_LocalAmplitude;

        new i_Amplitude;
        new i_Duration  = UTIL_FixedUnsigned16 ( f_Duration  , 1 << 12 );
        new i_Frequency = UTIL_FixedUnsigned16 ( f_Frequency , 1 << 8  );

        for ( new id = 1; id <= gi_MaxClients; id++ )
        {
            if ( !is_user_alive ( id ) )  { continue; }

            f_LocalAmplitude = 0.0;

            if ( f_Radius <= 0 )
            {
                f_LocalAmplitude = f_Amplitude;
            }
            else
            {
                pev ( id, pev_origin, vf_Origin );
                VectorSubtract ( vf_Origin, vf_Center, vf_Origin );

                if ( VectorLength ( vf_Origin ) < f_Radius )
                {
                    f_LocalAmplitude = f_Amplitude;
                }
            }

            if ( f_LocalAmplitude )
            {
                if ( !( pev ( id, pev_flags ) & FL_ONGROUND ) )
                {
                    f_LocalAmplitude *= 0.5;
                }
            }

            i_Amplitude = UTIL_FixedUnsigned16 ( f_LocalAmplitude, 1 << 12 );

            message_begin ( MSG_ONE_UNRELIABLE, gi_MsgShake, _, id );
            write_short ( i_Amplitude );  // --| Shake amount.
            write_short ( i_Duration );   // --| Shake lasts this long.
            write_short ( i_Frequency );  // --| Shake noise frequency.
            message_end ();
        }
    }


    FX_Decals ( const i_Hit, const Float:vf_EndPos[] )
    {
        message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte ( i_Hit > 0 ? TE_DECAL : TE_WORLDDECAL );
        write_coord_f ( vf_EndPos[ x ] );
        write_coord_f ( vf_EndPos[ y ] );
        write_coord_f ( vf_EndPos[ z ] );
        write_byte ( wpn_gi_get_explosion_decal() );
        if ( i_Hit > 0 ) write_short ( i_Hit );
        message_end();
    }


    FX_Bubbles ( const Float:vf_Origin[], const Float:vf_Mins[], const Float:vf_Maxs[], const Float:f_Height, const i_Count )
    {
        message_begin_f ( MSG_PAS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte ( TE_BUBBLES );
        write_coord_f ( vf_Mins[ x ] );
        write_coord_f ( vf_Mins[ y ] );
        write_coord_f ( vf_Mins[ z ] );
        write_coord_f ( vf_Maxs[ x ] );
        write_coord_f ( vf_Maxs[ y ] );
        write_coord_f ( vf_Maxs[ z ] );
        write_coord_f ( f_Height );
        write_short ( gi_Bubbles );
        write_byte ( i_Count );
        write_coord ( 8 ); // -- speed
        message_end ();
    }


    FX_Sparks ( const Float:vf_Origin[] )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte ( TE_SPARKS );
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        message_end ();
    }


    FX_Smoke ( const i_Ent, const Float:vf_Origin[] )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin, 0 );
        write_byte ( TE_SMOKE );
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        write_short ( gi_Smoke );
        write_byte ( floatround ( ( pev ( i_Ent, pev_dmg ) - 100.0 ) * 0.80 ) ); // -- scale * 10
        write_byte ( 12 );                                                      // -- framerate
        message_end ();
    }


    FX_BeamFollow ( const i_Ent, const i_Trail, const i_Life, const i_Width, const i_Red, const i_Green, const i_Blue, const i_Brightness )
    {
        message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte ( TE_BEAMFOLLOW );
        write_short ( i_Ent );          // --| Enntity.
        write_short ( i_Trail );        // --| Model.
        write_byte ( i_Life );          // --| Life.
        write_byte ( i_Width );         // --| Width.
        write_byte ( i_Red );           // --| Red color.
        write_byte ( i_Green );         // --| Green color.
        write_byte ( i_Blue );          // --| Blue color.
        write_byte ( i_Brightness );    // --| Brightness.
        message_end ();
    }


    FX_KillBeam ( const i_Ent )
    {
        message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte ( TE_KILLBEAM );
        write_short ( i_Ent );
        message_end ();
    }


    Float:UTIL_GetWaterLevel ( const Float:vf_Position[], Float:f_Minz, Float:f_Maxz )
    {
        new Float:vf_MidUp[ Coord_e ];

        vf_MidUp[ x ] = vf_Position[ x ];
        vf_MidUp[ y ] = vf_Position[ y ];
        vf_MidUp[ z ] = f_Minz;

        if ( engfunc ( EngFunc_PointContents, vf_MidUp ) != CONTENTS_WATER )
        {
            return f_Minz;
        }

        vf_MidUp[ z ] = f_Maxz;

        if ( engfunc ( EngFunc_PointContents, vf_MidUp ) == CONTENTS_WATER )
        {
            return f_Maxz;
        }

        new Float:f_Diff = f_Maxz - f_Minz;

        while ( f_Diff > 1.0 )
        {
            vf_MidUp[ z ] =  f_Minz + f_Diff / 2.0;

            if ( engfunc ( EngFunc_PointContents, vf_MidUp ) == CONTENTS_WATER )
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


    bool:UTIL_LiquidContents ( const Float:vf_Source[] )
    {
        return bool:( CONTENTS_WATER <= engfunc ( EngFunc_PointContents, vf_Source ) <= CONTENTS_LAVA );
    }


    bool:UTIL_IsVectorNull ( const Float:vf_Source[] )
    {
        return bool:( vf_Source[ x ] == 0.0 && vf_Source[ y ] == 0.0 && vf_Source[ z ] == 0.0 );
    }


    UTIL_VectorNormalize ( Float:vf_Source[] )
    {
        static Float:f_Invlen; f_Invlen = 1 / VectorLength ( vf_Source );

        vf_Source[ x ] *= f_Invlen
        vf_Source[ y ] *= f_Invlen;
        vf_Source[ z ] *= f_Invlen;
    }


    UTIL_GetStartPosition ( const id, const Float:i_Forward = 0.0, const Float:i_Right = 0.0, const Float:i_Up = 0.0, Float:vf_Source[] )
    {
        UTIL_MakeVector ( id, v_angle + punchangle );
        UTIL_GetGunPosition ( id, vf_Source );

        static Float:vf_Forward[ Coord_e ], Float:vf_Right[ Coord_e ], Float:vf_Up[ Coord_e ];

        if ( i_Forward > 0.0 ) global_get ( glb_v_forward, vf_Forward );
        if ( i_Right   > 0.0 ) global_get ( glb_v_right, vf_Right );
        if ( i_Up      > 0.0 ) global_get ( glb_v_up, vf_Up );

        vf_Source[ x ] += vf_Forward[ x ] * i_Forward + vf_Right[ x ] * i_Right + vf_Up[ x ] * i_Up;
        vf_Source[ y ] += vf_Forward[ y ] * i_Forward + vf_Right[ y ] * i_Right + vf_Up[ y ] * i_Up;
        vf_Source[ z ] += vf_Forward[ z ] * i_Forward + vf_Right[ z ] * i_Right + vf_Up[ z ] * i_Up;
    }


    UTIL_MakeVector ( const id, const i_Bits )
    {
        static Float:vf_Punchangles[ Angle_e ], Float:vf_Angles [ Angle_e ];

        if ( i_Bits & v_angle )    pev ( id, pev_v_angle, vf_Angles );
        if ( i_Bits & punchangle ) pev ( id, pev_punchangle, vf_Punchangles );

        VectorAdd ( vf_Angles, vf_Punchangles, vf_Angles );
        engfunc ( EngFunc_MakeVectors, vf_Angles );
    }


    UTIL_GetGunPosition ( const id, Float:vf_Source[] )
    {
        static Float:vf_ViewOfs[ Coord_e ];

        pev ( id, pev_origin, vf_Source );
        pev ( id, pev_view_ofs, vf_ViewOfs );
        
        VectorAdd ( vf_Source, vf_ViewOfs, vf_Source );
    }


    UTIL_SetRecoil ( const id, const Float:f_Force )
    {
        static Float:vf_Recoil[ Angle_e ];

        vf_Recoil[ pitch ] = f_Force;
        set_pev ( id, pev_punchangle, vf_Recoil );
    }


    UTIL_PlayAnimation ( const id, const i_Animation, const i_Body = 0 )
    {
        set_pev ( id, pev_weaponanim, i_Animation );

        if ( i_Body )
        {
            set_pev ( id, pev_body, i_Body );
        }

        message_begin ( MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id );
        write_byte ( i_Animation );
        write_byte ( pev ( id, pev_body ) );
        message_end ();
    }
 
    
    UTIL_GetThink ( const i_Ent )
    {
        return pev ( i_Ent, GL_STEP_THINK );
    }
    

    UTIL_GetTouch ( const i_Ent )
    {
        return pev ( i_Ent, GL_STEP_TOUCH );
    }
    
    
    UTIL_SetThink ( const i_Grenade, const i_StepThink, const Float:f_Time = -1.0 )
    {
        set_pev ( i_Grenade, GL_STEP_THINK, i_StepThink );

        if ( f_Time >= 0.0 )
        {
            set_pev ( i_Grenade, pev_nextthink, f_Time );
        }
    }
    

    UTIL_SetTouch ( const i_Ent, const i_StepTouch )
    {
        set_pev ( i_Ent, GL_STEP_TOUCH, i_StepTouch );
    }
    

    UTIL_Instance ( const i_Target )
    {
        return i_Target == -1 ? 0 : i_Target;
    }

    
    UTIL_Remove ( const i_Ent )
    {
        // --| Don't think anymore.
        UTIL_SetThink ( i_Ent, NULL, 0.0 );
        UTIL_SetTouch ( i_Ent, NULL );
        
        // --| Stop the rocket sounds and remove the beam.
        UTIL_StopGrenadeSound ( i_Ent );
        FX_KillBeam ( i_Ent );
        
        // --| Let engine kill our entity.
        set_pev ( i_Ent, pev_flags, pev ( i_Ent, pev_flags ) | FL_KILLME );
    }

    
    UTIL_StopGrenadeSound ( const i_Ent )
    {
        emit_sound ( i_Ent, CHAN_WEAPON, gs_RocketSound     , 0.0, 0.0, SND_STOP, PITCH_NORM );
        emit_sound ( i_Ent, CHAN_WEAPON, gs_GlauncherRocket , 0.0, 0.0, SND_STOP, PITCH_NORM );
        emit_sound ( i_Ent, CHAN_WEAPON, gs_GlauncherGrenade, 0.0, 0.0, SND_STOP, PITCH_NORM );
    }
    

    bool:UTIL_IsValid ( const i_Ent )
    {
        // --| Must a valid entity.
        if ( pev_valid ( i_Ent ) )
        {
            static s_Classname[ 16 ];
            pev ( i_Ent, pev_classname, s_Classname, charsmax ( s_Classname ) );
            
            // --| [wpn]_gl_grenade, [wpn]_gl_rocket, [wpn]_gl_sparks. 
            if ( s_Classname[ 0 ] == 'w' && s_Classname[ 1 ] == 'p'  && s_Classname[ 2 ] == 'n' )
            {
                // --| wpn_[gl]_grenade, wpn_[gl]_rocket, wpn_[gl]_sparks. 
                if ( s_Classname[ 4 ] == 'g' && s_Classname[ 5 ] == 'l' )
                {
                    // --| wpn_gl_[grenade], wpn_gl_[rocket], wpn_gl_[sparks]. 
                    return bool:( equal ( s_Classname[ 7 ], "grenade", 7 ) || equal ( s_Classname[ 7 ], "rocket", 6 ) || equal ( s_Classname[ 7 ], "sparks", 6 ) );
                }
            }   
        }
        
        return false;
    }

    
    UTIL_FixedUnsigned16 ( const Float:f_Value, const i_Scale )
    {
        return clamp ( floatround ( f_Value * i_Scale ), 0, 0xFFFF );
    }



