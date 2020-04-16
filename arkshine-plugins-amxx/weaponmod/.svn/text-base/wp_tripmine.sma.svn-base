
   /* - - - - - - - - - - -

        AMX Mod X script.

          | Author  : Arkshine
          | Plugin  : WPN Trip Mine
          | Version : v1.1.0

        (!) Support : http://forums.space-headed.net/viewtopic.php?t=288

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
            Basically, it's almost the same weapon that you can see in Half-life with few more features and customization.
            A better description on what does the tripmine exactly can be found here : http://half-life.wikia.com/wiki/Laser_Tripmine .


        Requirement :
        - - - - - - -
            * CS 1.6 / CZ / DoD / TFC / TS
            * AMX Mod X 1.7x or higher.
            * WeaponMod / GameInfo


        Modules :
        - - - - -
            * fakemeta


        Installation :
        - - - - - - -

            [ Alternative model ]

                Another model is provided. Its look seems to be a bit better. You might want to use them. If so :

                    - Put theses models on your server in the '$MODDIR/models/' directory.
                    - Edit the *.sma file and uncomment '// #define ALTERNATIVE_MODEL' by removing the '//'


            [ Configuration file ]

                A file named 'wpn_tripmine.cfg' is provided to be used as reference.
                This file is optionnal. If you want install it :

                    - You have to put this file in the '/amxmodx/configs/weaponmod/' directory.


        Console command :
        - - - - - - - - -
            There is only one [server|client] console command. Setting list :

            [ GENERAL ]

            wpn_tm <setting> <value>

                * gl_cost <iMoney>
                    Cost of buying. ( default : 2000 )

                * gl_ammo <iAmmo>
                    How many mines can be planted per player. ( default : 3 )

                * gl_refire <fSeconds>
                    Delay before being able to place the next tripmine. ( default : 0.3 )

                * gl_speed <fSpeed>
                    Player's speed when holding the tripmine. ( default : 300 )

            [ EXPLOSION ]

                * ex_max <iMaxDamage>
                    Maximum damage that a tripmine can be done. ( default : 150 )

                * ex_radius <[iMin] iMax>
                    Maximum blast damage radius. ( default : "384" )

                    'iMin' is optionnal.
                    If 'iMin' is defined, radius will be a random number between 'iMin' and 'iMax'.

                * ex_flag <iFlags>
                    Damage entity flags. What happens in the radius range. ( default : 7 )
                    Flags are additives.

                    0 - No damage.
                    1 - Tripmine explosion destroys others tripmines.
                    2 - Break all func_breakable entity.
                    4 - Break all func_pushable entity with SF_PUSH_BREAKABLE spawnflag.

                    [ LASER ]

                * lr_flag <iFlags>
                    Laser damage flags. ( default : 1 )

                    0 - No damage.
                    1 - Laser does some energy beam damage.
                    2 - Laser is mortal. Player will explode into gibs. Only under CS 1.6 / CZ.

                * lr_dmg <[iMinDmg] iMaxDmg>
                    Laser damage if 'laser_flag' is set to 1. ( default : "1 10" )

                    'iMinDmg' is optionnal.
                    If 'iMinDmg' is defined, damage will be a random number between 'iMinDmg' and 'iMaxDmg'.

                * lr_color <RRR GGG BBB>
                    Laser color. ( default : "0 214 198" )

                    Range : 1 ~ 255

                * lr_brightness <iValue>
                    Laser brightness. ( default : 10 )

                    Range : 1 ~ 255
                    The lowest is the value, the more it's brighter.
                    A value of "0" mean invisible.

                * lr_width <iWidth>
                    Laser width. ( default : 10 )

            [ MISCELLANEOUS ]

                * ms_shoot <iValue>
                    Is the tripmine shootable ? ( default : 1 )

                    0 - Not shootable
                    1 - One shoot
                    2 - Depending of its health value

                * ms_health <iHealth>
                    Specify tripmine health. ( default : 100 )
                    Only available if 'misc_shootable' is set to 2.

                * ms_instant <iValue>
                    Allow you to power up quickly a tripmine. ( default : 0 )

                    0 - Default ( ~3s )
                    1 - Quickly ( ~1s )

                * ms_ground <iValue>
                    How is the dropped tripmine put down on the floor ? ( default : 0 )

                    0 - Lieing on the ground
                    1 - WeaponMod behaviour ( a bit elevated )

                * ms_keep <iValue>
                    Specify whether tripmines stay for the next round. ( default : 0 )
                    Only avaible for CS 1.6 / CZ.

                    0 - Do nothing
                    1 - Remove all tripmines

                * ms_disco <iValue>
                    Specify whether a player disconnects, its tripmines should be removed. ( default : 0 )

                    0 - Do nothing
                    1 - Remove all its tripmines


        Known issues :
        - - - - - -
            * If you're a spectator and that you're looking at a player who is holding a tripmine, you will see a big mine in its hands. I don't know if it's fixable.


        To do :
        - - - -

            * Enhance realism adding the 'arm' animation + its sound
            * Enhance realism adding the 'place' animation
            * See if the plugin can be optimized.


        Changelog :
        - - - - - -
            v1.1.0 : [ ]

                (~) Plugin rewritten. ( more in HLSDK way )
                (+) Added weapon idle system.
                (+) Added radius damage on entity.
                (+) Enhanced the explosion effect. ( env_explosion is not used anymore )
                (+) Added support for explosion in water. ( different sprite explosion + bubbles )
                (*) The beam is now drawed one time only. ( instead of being (re)drawed each 0.3 sec )
                (*) Changed the way to fix the tripmine size.

            v1.0.3 : [ 2 mar 2008 ]

                (!) Fixed some strange behaviour under TFC/TS by replacing all pev_iuser* on player's id by global variables.
                (!) Fixed tripmine owner who was not set properly if original owner is no longer connected.
                (*) Changed way to deal laser damage using the wpn_damage_user() native provided by WeaponMod.

            v1.0.2 : [ 28 feb 2008 ]

                (+) Added new setting 'ms_instant' which allow you to power up quickly a tripmine. ( ~1s instead of ~3s )
                (!) Fixed. The player was not detected if he crossed the laser at high speed.
                (-) Removed the define TM_VICTIM to be replaced by pev_enemy.

            v1.0.1 : [ 28 feb 2008 ]

                (!) Fixed. Setting 'ms_disco' works properly now.

            v1.0.0 : [ 28 feb 2008 ]

                (~) Initial release.


        Credits :
        - - - - -
            * HLSDK
            * Orangutanz
            * DevconeS
            * VEN

    - - - - - - - - - - - */

    #include <amxmodx>
    #include <amxmisc>
    #include <fakemeta_util>
    #include <weaponmod_stocks>


    #define Plugin  "WPN Laser Tripmine"
    #define Version "1.1.0"
    #define Author  "Arkshine"


    /* - - - - - - -
     |  Uncomment if you want to use the alternative model.  |
                                               - - - - - - - */
    // #define ALTERNATIVE_MODEL


    /* - - - - - - -
     |  If you have some problems with the laser, like
     |   if you are running some speed plugins, you may want to test with : 0.01 |
                                               - - - - - - - */
    #define BEAM_BREAK_SPEED 0.1


    /* - - -
     |  WEAPON INFORMATION  |
                      - - - */
        new
            gs_WpnName [] = "Laser Tripmine",
            gs_WpnShort[] = "tripmine";

    /* - - -
     |  WEAPON MODEL   |
                 - - - */
        new
        #if defined ALTERNATIVE_MODEL
            gs_Model_P[] = "models/p_tripmine_alt.mdl",
            gs_Model_V[] = "models/v_tripmine_alt.mdl";
        #else
            gs_Model_P[] = "models/p_tripmine.mdl",
            gs_Model_V[] = "models/v_tripmine.mdl";
        #endif

    /* - - -
     |  WEAPON SOUNDS  |
                 - - - */
        new const
            gs_DeploySound  [] = "weapons/mine_deploy.wav",
            gs_ChargeSound  [] = "weapons/mine_charge.wav",
            gs_ActivateSound[] = "weapons/mine_activate.wav";

    /* - - -
     |  SEQUENCE  |
            - - - */
        enum
        {
            tripmine_idle1,
            tripmine_idle2,
            tripmine_arm1,
            tripmine_place,
            tripmine_fidget,
            tripmine_holster,
            tripmine_draw,
            tripmine_world,
            tripmine_ground
        };

    /* - - -
     |  CUSTOM FIELDS  |
                 - - - */
        #define TG_THINK_STEP   pev_iuser1
        #define TG_REAL_OWNER   pev_iuser2
        #define TG_BEAM_INDEX   pev_iuser3
        #define TG_ENTITY_TYPE  pev_iuser4
        #define TG_ATTACK_TYPE  pev_oldbuttons
        #define TG_POWER_UP     pev_fuser1
        #define TG_BEAM_LENGTH  pev_fuser2
        #define TG_DIRECTION    pev_vuser1
        #define TG_END_POSITION pev_vuser2

    /* - - -
     |  COMMAND VALUES  |
                  - - - */
        // --| Primary attack / Secondary attack.
        enum _:Attack_e { NormalAttack = 1, InstantAttack };

        // --| Color : RRR GGG BB format.
        enum Color_t
        {
            Green[ Attack_e ],
            Red  [ Attack_e ],
            Blue [ Attack_e ]
        };

        enum General_t
        {
            Cost,
            Ammo,
            Float:Speed
        };

        enum Explosion_t
        {
            ExEntFlags       [ Attack_e ],
            Float:ExMinRadius[ Attack_e ],
            Float:ExMaxRadius[ Attack_e ],
            Float:ExDmg      [ Attack_e ]
        };

        enum Laser_t
        {
            LrDmgFlags    [ Attack_e ],
            LrColor       [ Color_t ],
            LrBrightness  [ Attack_e ],
            LrWidth       [ Attack_e ],
            Float:LrMinDmg[ Attack_e ],
            Float:LrMaxDmg[ Attack_e ]
        };

        enum Misc_t
        {
            Shoot,
            Place,
            Ground,
            Float:Health,
        };

        enum t_Cvar
        {
            General  [ General_t   ],
            Laser    [ Laser_t     ],
            Explosion[ Explosion_t ],
            Misc     [ Misc_t      ]
        };

        new gt_CmdData[ t_Cvar ];

    /* - - -
     |  OTHERS STUFFS  |
                 - - - */
        #define MAX_CLIENTS  32
        #define FCVAR_FLAGS  ( FCVAR_SERVER | FCVAR_SPONLY )

        #define REMOVE_HANDS 3
        #define VOL_NONE     0.0
        #define NULL         0

        // --| For readabiliy.
        enum _:Coord_e  { Float:x, Float:y, Float:z };
        enum _:Angle_e  { Float:pitch, Float:yaw, Float:roll };

        enum ( <<= 1 )  { angles = 1, v_angle, punchangle };
        enum { Quick = 1, Normal, Real };
        enum { Tripmine = 1, Spark };

        // --| Entity think step.
        enum _:Think_e
        {
            Warning = 1,
            PrePowerUp,
            PowerUp,
            BeamBreak,
            Explode,
            DelayDeath,
            CreateSpark,
            CreateSmoke,
            Remove
        };

        enum TripmineData_t
        {
            LastTrace,
            LastIndex,
            Float:LastOrigin[ Coord_e ]
        };

        new Float:gf_TimeWeaponIdle[ MAX_CLIENTS + 1 ];

        new gi_UsrWeapon           [ MAX_CLIENTS + 1 ];
        new gt_Tripmine            [ MAX_CLIENTS + 1 ][ TripmineData_t ];

        new Float:gf_HealthReference;

        new gi_TripmineClass;
        new gi_SparkClass;
        new gi_BeamClass;
        new gi_LaserClass;
        new gi_Weaponid;

        new gi_Beam;
        new gi_Bubbles;
        new gi_WExplosion;
        new gi_Fireball;
        new gi_Smoke;

    /* - - -
     |    Macro   |
            - - - */
        #define VectorSubtract(%1,%2,%3) ( %3[ x ] = %1[ x ] - %2[ x ], %3[ y ] = %1[ y ] - %2[ y ], %3[ z ] = %1[ z ] - %2[ z ] )
        #define VectorAdd(%1,%2,%3)      ( %3[ x ] = %1[ x ] + %2[ x ], %3[ y ] = %1[ y ] + %2[ y ], %3[ z ] = %1[ z ] + %2[ z ] )
        #define VectorCopy(%1,%2)        ( %2[ x ] = %1[ x ],  %2[ y ] = %1[ y ], %2[ z ] = %1[ z ] )
        #define VectorScale(%1,%2,%3)    ( %3[ x ] = %2 * %1[ x ], %3[ y ] = %2 * %1[ y ], %3[ z ] = %2 * %1[ z ] )
        #define VectorMA(%1,%2,%3,%4)    ( %4[ x ] = %1[ x ] + %2 * %3[ x ], %4[ y ] = %1[ y ] + %2 * %3[ y ], %4[ z ] = %1[ z ] + %2 * %3[ z ] )
        #define VectorMS(%1,%2,%3,%4)    ( %4[ x ] = %1[ x ] - %2 * %3[ x ], %4[ y ] = %1[ y ] - %2 * %3[ y ], %4[ z ] = %1[ z ] - %2 * %3[ z ] )

        #define message_begin_f(%1,%2,%3)   ( engfunc ( EngFunc_MessageBegin, %1, %2, %3 ) )
        #define write_coord_f(%1)           ( engfunc ( EngFunc_WriteCoord, %1 ) )

        #define IsTripmine(%1)              ( pev_valid ( %1 ) && pev ( i_Ent, TG_ENTITY_TYPE ) == Tripmine )
        #define IsSpark(%1)                 ( pev_valid ( %1 ) && pev ( i_Ent, TG_ENTITY_TYPE ) == Spark )
        #define GetTripmineHealth(%1)       ( pev ( %1, pev_health ) )
        #define GetTripmineAmmo(%1,%2)      ( wpn_get_userinfo ( %1, %2, gi_UsrWeapon[ %1 ] ) )
        #define IsWeaponEmpty(%1)           ( gi_UsrWeapon[ id ] = wpn_has_weapon ( %1, gi_Weaponid ), GetTripmineAmmo ( %1, usr_wpn_ammo1 ) <= 0 )
        #define GetNextThinkStep(%1)        ( pev ( %1, TG_THINK_STEP ) )
        #define SetNextThinkStep(%1,%2,%3)  ( set_pev ( %1, TG_THINK_STEP, %2 ), set_pev ( %1, pev_nextthink, %3 ) )


    public plugin_precache()
    {
        // --| Tripmine models.
        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );

        // --| Tripmine sounds.
        precache_sound ( gs_DeploySound );
        precache_sound ( gs_ChargeSound );
        precache_sound ( gs_ActivateSound );

        // --| Laser sprite.
        gi_Beam = precache_model ( "sprites/laserbeam.spr" );

        // --| Explosion sprites.
        gi_Bubbles    = precache_model ( "sprites/bubble.spr" );
        gi_WExplosion = precache_model ( "sprites/WXplo1.spr" );
        gi_Fireball   = precache_model ( "sprites/zerogxplode.spr" );
        gi_Smoke      = precache_model ( "sprites/steam1.spr" );
    }


    public plugin_init()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_tm_version", Version, FCVAR_FLAGS );

        register_concmd ( "wpn_tm", "cmd_WpnTripmine", ADMIN_RCON, "- wpn_tm <command> <value>" );

        register_forward ( FM_Think, "Forward_Think" );
        register_forward ( FM_Touch, "Forward_Touch" );
        register_forward ( FM_PlayerPreThink, "Forward_PlayerPreThink" );

        // --| Be sure that all commands have correct values.
        InitializeValue();

        // --| Time to register our weapon.
        CreateWeapon ();
    }


    public plugin_cfg ()
    {
        // --| Used for tripmine and spark.
        gi_TripmineClass = gi_SparkClass = engfunc ( EngFunc_AllocString, "info_target" );

        // --| Used for beam laser.
        gi_BeamClass  = engfunc ( EngFunc_AllocString, "beam" );
        gi_LaserClass = engfunc ( EngFunc_AllocString, "sprites/laserbeam.spr" );

        // --| Execute config file provided, if existing.
        ExecuteConfigFile ();
    }


    /*
        + - - - - - - - - -
        |  To be sure that all variables have a correct value
           we initialize them with the default value.          |
                                             - - - - - - - - - +
    */
    InitializeValue()
    {
        // --| General.
        gt_CmdData[ General ][ Cost ]  = 900;
        gt_CmdData[ General ][ Ammo ]  = 3;
        gt_CmdData[ General ][ Speed ] = _:250.0;

         // --| Misc.
        gt_CmdData[ Misc ][ Shoot  ] = 1;
        gt_CmdData[ Misc ][ Health ] = _:100.0;
        gt_CmdData[ Misc ][ Place  ] = Normal;
        gt_CmdData[ Misc ][ Ground ] = 0;

        // --| PRIMARY ATTACK

        // -- Explosion.
        gt_CmdData[ Explosion ][ ExDmg       ][ NormalAttack ] = _:150.0;
        gt_CmdData[ Explosion ][ ExMinRadius ][ NormalAttack ] = _:0.0;
        gt_CmdData[ Explosion ][ ExMaxRadius ][ NormalAttack ] = _:384.0;
        gt_CmdData[ Explosion ][ ExEntFlags  ][ NormalAttack ] = 7;

        // --| Laser.
        gt_CmdData[ Laser ][ LrMinDmg         ][ NormalAttack ] = _:0.0;
        gt_CmdData[ Laser ][ LrMaxDmg         ][ NormalAttack ] = _:0.0;
        gt_CmdData[ Laser ][ LrColor ][ Red   ][ NormalAttack ] = 0
        gt_CmdData[ Laser ][ LrColor ][ Green ][ NormalAttack ] = 214;
        gt_CmdData[ Laser ][ LrColor ][ Blue  ][ NormalAttack ] = 198;
        gt_CmdData[ Laser ][ LrBrightness     ][ NormalAttack ] = 64;
        gt_CmdData[ Laser ][ LrWidth          ][ NormalAttack ] = 8;

        // --| SECONDARY ATTACK

        // -- Explosion.
        gt_CmdData[ Explosion ][ ExDmg       ][ InstantAttack ] = _:5.0;
        gt_CmdData[ Explosion ][ ExMinRadius ][ InstantAttack ] = _:0.0;
        gt_CmdData[ Explosion ][ ExMaxRadius ][ InstantAttack ] = _:20.0;
        gt_CmdData[ Explosion ][ ExEntFlags  ][ InstantAttack ] = 7;

        // -- Laser.
        gt_CmdData[ Laser ][ LrMinDmg         ][ InstantAttack ] = _:0.0;
        gt_CmdData[ Laser ][ LrMaxDmg         ][ InstantAttack ] = _:0.0;
        gt_CmdData[ Laser ][ LrColor ][ Red   ][ InstantAttack ] = 255
        gt_CmdData[ Laser ][ LrColor ][ Green ][ InstantAttack ] = 0;
        gt_CmdData[ Laser ][ LrColor ][ Blue  ][ InstantAttack ] = 0;
        gt_CmdData[ Laser ][ LrBrightness     ][ InstantAttack ] = 50;
        gt_CmdData[ Laser ][ LrWidth          ][ InstantAttack ] = 4;

        gf_HealthReference = 10000.0;
    }


    /*
        + - - -
        |  If the optional provided config file exists,
           we execute it.                                |
                                                   - - - +
    */
    ExecuteConfigFile ()
    {
        // --| Define the config file name.
        new const CommandConfigFile[] = "wpn_tripmine.cfg";

        // --| Get the config directory path.
        new s_ConfigsDir[ 64 ];
        get_configsdir ( s_ConfigsDir, charsmax ( s_ConfigsDir ) );

        // --| Get the full path to the config file.
        new s_File[ 128 ];
        formatex ( s_File, charsmax ( s_File ), "%s/weaponmod/%s", s_ConfigsDir, CommandConfigFile );

        // --| If file exists...
        if ( file_exists ( s_File ) )
        {
            // --| We execute it.
            server_cmd ( "exec %s", s_File );
        }
    }


    CreateWeapon ()
    {
        // --| Register our awesome weapon.
        new i_Weapon_id = wpn_register_weapon ( gs_WpnName, gs_WpnShort );

        // --| Too many weapons registered ?
        if ( i_Weapon_id == -1 )
        {
            return;
        }

        // --| Set the weapons models.
        wpn_set_string ( i_Weapon_id, wpn_viewmodel  , gs_Model_V );
        wpn_set_string ( i_Weapon_id, wpn_weaponmodel, gs_Model_P );

        // --| Define our events.
        wpn_register_event ( i_Weapon_id, event_attack1        , "Tripmine_PrimaryAtttack" );
        wpn_register_event ( i_Weapon_id, event_attack2        , "Tripmine_SecondaryAtttack" );
        wpn_register_event ( i_Weapon_id, event_draw           , "Tripmine_Deploy" );
        wpn_register_event ( i_Weapon_id, event_hide           , "Tripmine_Holster" );
        wpn_register_event ( i_Weapon_id, event_weapondrop_post, "Tripmine_Drop" );

        // --| Float.
        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, 0.3 );
        wpn_set_float ( i_Weapon_id, wpn_refire_rate2, 0.3 );
        wpn_set_float ( i_Weapon_id, wpn_run_speed, gt_CmdData[ General ][ Speed ] );

        // --| Integer.
        wpn_set_integer ( i_Weapon_id, wpn_ammo1, gt_CmdData[ General ][ Ammo ] );
        wpn_set_integer ( i_Weapon_id, wpn_cost , gt_CmdData[ General ][ Cost ] );

        // --| Copy the id so it can be used later.
        gi_Weaponid = i_Weapon_id;
    }


    /*
        + - - - - - - - -
        |  Player fires the primary attack.
        |  ( Attempt to place a tripmine )
        |
           (?) Notes :

              - No / Small laser damage
              - Big explosion / damage       |
                                             |
           @param id        Player's index   |
                             - - - - - - - - +
    */
    public Tripmine_PrimaryAtttack ( const id )
    {
        PlaceTripmine ( id, NormalAttack );
    }


    /*
        + - - - - - - - -
        |  Player fires the secondary attack.
        |  ( Attempt to place a tripmine )
        |
           (?) Notes :

              - Instant gibs on laser
              - Small explosion / damage     |
                                             |
           @param id        Player's index   |
                             - - - - - - - - +
    */
    public Tripmine_SecondaryAtttack ( const id )
    {
        PlaceTripmine ( id, InstantAttack );
    }


    PlaceTripmine ( const id, const i_Type )
    {
        // --| Tripmine empty, not placable.
        if ( IsWeaponEmpty ( id ) || !IsTripminePlacable ( id ) )
        {
            // --| We stop there. Event is blocked.
            return PLUGIN_HANDLED;
        }

        // --| We create/spawn our tripmine.
        Tripmine_Create ( id );
        Tripmine_Spawn  ( id );

        // --| Save the attack type.
        set_pev ( gt_Tripmine[ id ][ LastIndex ], TG_ATTACK_TYPE, i_Type );

        // --| One tripmine is planted, need to update ammos.
        UpdateAmmo ( id, 1 );

        // --| Check if we are out of Ammos.
        if ( IsWeaponEmpty ( id ) )
        {
            // --| If so, we retire the weapon immediately.
            RetireWeapon ( id );
            return PLUGIN_CONTINUE;
        }

        // --| Set the next time for the idle animation.
        gf_TimeWeaponIdle[ id ] = get_gametime () + random_float ( 10.0, 15.0 );

        return PLUGIN_CONTINUE;
    }


    RetireWeapon( const id )
    {
        switch ( gt_CmdData[ Misc ][ Place ] )
        {
            case Real : gf_TimeWeaponIdle[ id ] = get_gametime () + 2.1;
            default   : gf_TimeWeaponIdle[ id ] = get_gametime () + 0.1;
        }
    }


    /*
        + - - - - - - - -
        |  Players draws weapon.

           @param id        Player's index  |
                            - - - - - - - - +
    */
    public Tripmine_Deploy ( const id )
    {
        // --| Save the weapon index.
        gi_UsrWeapon[ id ] = wpn_has_weapon ( id, gi_Weaponid );

        // --| Need to fix a visual problem ( big mine ).
        FixModel ( id );

        // --| Play the draw animation.
        Tripmine_Draw ( id );
    }


    /*
        + - - - - - - - -
        |  Play draw animation.

           @param id        Player's index  |
                            - - - - - - - - +
    */
    public Tripmine_Draw ( const id )
    {
        wpn_playanim ( id, tripmine_draw );
    }


    /*
        + - - - - - - - -
        |  Players changes weapon.

           @param id        Player's index  |
                            - - - - - - - - +
    */
    public Tripmine_Holster ( const id )
    {
        // --| Out of mines.
        if ( IsWeaponEmpty ( id ) )
        {
            // --| We remove the weapon.
            wpn_remove_weapon ( id, gi_UsrWeapon[ id ] );
        }

        // --| Play the holster animation.
        wpn_playanim ( id, tripmine_holster );

        // --| Play a null sound to stop any previous sound.
        emit_sound ( id, CHAN_WEAPON, "common/null.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
    }


    /*
        + - - - - - - - -
        |  Tripmine is dropped by player.
        |
        |  World model is implemented into view model.
           So, we have to set the model manually.
                                                        |
           @param id        Player's index              |
           @param i_Ent     Wepaon index                |
                                        - - - - - - - - +
    */
    public Tripmine_Drop( const id, const i_Ent )
    {
        // --| Set the world model.
        engfunc ( EngFunc_SetModel, i_Ent, gs_Model_V );

        // --| Necessary to remove hands and selecting the right sequence.
        set_pev ( i_Ent, pev_frame, 0 );
        set_pev ( i_Ent, pev_body, REMOVE_HANDS );
        set_pev ( i_Ent, pev_sequence, tripmine_ground );
        set_pev ( i_Ent, pev_framerate, 0.0 );

        // --| Set the correct size.
        new Float:f_Min[ Coord_e ] = { -16.0, -16.0, 0.0  };
        new Float:f_Max[ Coord_e ] = {  16.0,  16.0, 28.0 };

        f_Min[ z ] = -16.0;
        engfunc( EngFunc_SetSize, i_Ent, f_Min, f_Max );
    }


    /*
        +  - - - - - - - - - - -
        |  Tricky way to force the tripmine normal size.
        |
        |  Model is buggy when you get a weapon and that the current
           player's hold weapon is not the default weapon or a WeaponMod weapon.
           A way is to force another animation just before the draw animation.

           Note : It will still buggy while spectating player who's holding tripmine.   |
                                                                                        |
           @param id            Player's index                                          |
                                                                  - - - - - - - - - - - +
    */
    FixModel ( const id )
    {
        // --| Sometimes, pev_body is set to 1 and then removing hands. so, resetting...
        set_pev ( id, pev_body, 0 );

        // --| Little fix.
        wpn_playanim ( id, tripmine_arm1 );
    }


    /*
        + - - - - - - -
        |  Use to manage the weapon idle system.

           @param id                Player's index  |
                                      - - - - - - - +
    */
    public Forward_PlayerPreThink ( const id )
    {
        if ( is_user_alive ( id ) && wpn_uses_weapon( id, gi_Weaponid ) )
        {
            // --| Be sure that player is alive and that he's holding a special weapon.
            WeaponIdle ( id );
        }
    }


    public Forward_Think ( const i_Ent )
    {
        // --| Only tripmine or spark allowed.
        if ( IsTripmine ( i_Ent ) || IsSpark ( i_Ent ) )
        {
            // --| Get the next step to do.
            switch ( GetNextThinkStep ( i_Ent ) )
            {
                case Warning        : Tripmine_WarningThink     ( i_Ent );
                case PrePowerUp     : Tripmine_PrePowerupThink  ( i_Ent );
                case PowerUp        : Tripmine_PowerupThink     ( i_Ent );
                case BeamBreak      : Tripmine_BeamBreakThink   ( i_Ent );
                case DelayDeath     : Tripmine_DelayDeathThink  ( i_Ent );
                case CreateSpark    : Tripmine_SparksExplosion2 ( i_Ent );
                case CreateSmoke    : Tripmine_SmokeExplosion   ( i_Ent );
                case Remove         : Tripmine_Removing         ( i_Ent );
            }
        }
    }


    public Forward_Touch ( const i_Ent, const i_Other )
    {
        // --| Entity should be only spark created and it touches something.
        if ( IsSpark ( i_Ent ) && GetNextThinkStep ( i_Ent ) == CreateSpark )
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
    }


    Tripmine_Create ( const id )
    {
        // --| Initialize variables.
        static Float:vf_PlaneNormal[ Coord_e ], Float:vf_Angles[ Coord_e ];
        static Float:vf_EndPos[ Coord_e ], Float:vf_NewOrigin[ Coord_e ], tr;

        // --| Create a new entity.
        static i_Tripmine; i_Tripmine = engfunc ( EngFunc_CreateNamedEntity, gi_TripmineClass );
        set_pev ( i_Tripmine, TG_ENTITY_TYPE, Tripmine );

        // --| Get our last trace result.
        tr = gt_Tripmine[ id ][ LastTrace ];

        // --| Save the entity index to be used later.
        gt_Tripmine[ id ][ LastIndex ] = i_Tripmine;

        // --| Get the plane normal and end position vector.
        get_tr2 ( tr, TR_vecPlaneNormal, vf_PlaneNormal );
        get_tr2 ( tr, TR_vecEndPos, vf_EndPos );

        // --| Reverse tripmine angle so the face is in the right direction.
        engfunc ( EngFunc_VecToAngles, vf_PlaneNormal, vf_Angles );
        VectorMA ( vf_EndPos, 8.0, vf_PlaneNormal, vf_NewOrigin );

        // --| Save the current tripmine origin to be used later.
        VectorCopy ( _:vf_NewOrigin, _:gt_Tripmine[ id ][ LastOrigin ] );

        // --| Set the new origin and new angle. It's ready to spawn.
        set_pev ( i_Tripmine, pev_origin, vf_NewOrigin );
        set_pev ( i_Tripmine, pev_angles, vf_Angles );

        // --| Set the tripmine owner.
        set_pev ( i_Tripmine, pev_owner, id );
    }


    Tripmine_Spawn ( const id )
    {
        // --| Get the last tripmine index.
        static i_Tripmine; i_Tripmine = gt_Tripmine[ id ][ LastIndex ];

        // --| Get the current game time.
        static Float:f_CurrTime; f_CurrTime = get_gametime ();

        if ( gt_CmdData[ Misc ][ Place ] == Real && GetNextThinkStep ( i_Tripmine ) != PrePowerUp )
        {
            // --| First step is the warning.
            SetNextThinkStep ( i_Tripmine, Think_e:Warning, f_CurrTime + 0.1 );

            // --| Need to fix a bug animation.
            set_task ( 2.0, "Tripmine_Draw", id );
            return;
        }

        // --| Intialize variables.
        static Float:vf_Dir[ Coord_e ], Float:vf_End[ Coord_e ];

        // --| Motor.
        set_pev ( i_Tripmine, pev_movetype, MOVETYPE_FLY );
        set_pev ( i_Tripmine, pev_solid, SOLID_NOT );

        // --| Set the tripmine model. ( world model is integrated into view model )
        engfunc ( EngFunc_SetModel, i_Tripmine, gs_Model_V );

        // --| Necessary to remove hands and selecting the right sequence.
        set_pev ( i_Tripmine, pev_frame, 0 );
        set_pev ( i_Tripmine, pev_body, REMOVE_HANDS );
        set_pev ( i_Tripmine, pev_sequence, tripmine_world );
        set_pev ( i_Tripmine, pev_animtime, f_CurrTime );
        set_pev ( i_Tripmine, pev_framerate, 0.0 );

        // --| Set the tripmine size and origin.
        engfunc ( EngFunc_SetSize, i_Tripmine, Float:{ -8.0, -8.0, -8.0 }, Float:{ 8.0, 8.0, 8.0 } );
        engfunc ( EngFunc_SetOrigin, i_Tripmine, gt_Tripmine[ id ][ LastOrigin ] );

        // --| Play the deploy sound.
        emit_sound ( i_Tripmine, CHAN_VOICE, gs_DeploySound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

        // --| Power up is more or less fast depending the configuration.
        switch ( gt_CmdData[ Misc ][ Place ] )
        {
            case Quick  :
            {
                set_pev ( i_Tripmine, TG_POWER_UP, f_CurrTime + 1.0 );
            }
            case Normal, Real :
            {
                set_pev ( i_Tripmine, TG_POWER_UP, f_CurrTime + 2.5 );
                emit_sound ( i_Tripmine, CHAN_BODY , gs_ChargeSound, 0.2, ATTN_NORM, 0, PITCH_NORM );
            }
        }

        // --| Next step, ready to power up.
        SetNextThinkStep ( i_Tripmine, Think_e:PowerUp, f_CurrTime + 0.2 );

        // --| Tripmine can take damage.
        set_pev ( i_Tripmine, pev_takedamage, !gt_CmdData[ Misc ][ Shoot ] ? DAMAGE_NO : DAMAGE_YES );
        set_pev ( i_Tripmine, pev_dmg, gt_CmdData[ Explosion ][ ExDmg ][ pev ( i_Tripmine, TG_ATTACK_TYPE ) ] );
        set_pev ( i_Tripmine, pev_health, gf_HealthReference );

        // --| Save the real owner in another var because an entity's tracelines don't strike it's pev->owner
        // --| which meant that a player couldn't trigger his own tripmine.
        set_pev ( i_Tripmine, TG_REAL_OWNER, id );
        set_pev ( i_Tripmine, pev_owner, NULL );

        UTIL_MakeAimVectors ( i_Tripmine, angles );

        // --| Get the tripmine direction / end position vector.
        global_get ( glb_v_forward, vf_Dir );
        VectorMA ( gt_Tripmine[ id ][ LastOrigin ], 2048.0, vf_Dir, vf_End );

        // --| Save the direction / end position to be used later.
        set_pev ( i_Tripmine, TG_DIRECTION, vf_Dir );
        set_pev ( i_Tripmine, TG_END_POSITION, vf_End );
    }


    Tripmine_WarningThink ( const i_Ent )
    {
        // --| Retrieve the current tripmine's owner.
        static id; id = pev ( i_Ent, pev_owner );

        // --| Play the arm animation.
        wpn_playanim ( id, tripmine_arm1 );

        // --| Play the warning sound at the end of the previous animation.
        set_task ( 0.4, "Tripmine_WarningSound", i_Ent );

        // --| Ready to run the next step.
        SetNextThinkStep ( i_Ent, PrePowerUp, get_gametime () + 1.0 );
    }


    Tripmine_PrePowerupThink ( const i_Ent )
    {
        // --| Retrieve the current tripmine's owner.
        static id; id = pev ( i_Ent, pev_owner );

        // --| Play the place animation.
        wpn_playanim ( id, tripmine_place );

        // --| Ready to spawn the tripmine.
        Tripmine_Spawn ( id );
    }


    Tripmine_PowerupThink ( const i_Ent )
    {
        // --| Retrieve the current game time.
        static Float:f_Time; f_Time = get_gametime ();

        // --| Get the power up time value.
        static Float:f_PowerUp; pev ( i_Ent, TG_POWER_UP, f_PowerUp );

        // --| We want to wait some seconds before activate the tripmine.
        if ( f_Time > f_PowerUp )
        {
            // --| Get the current tripmine origin.
            static Float:vf_Origin[ Coord_e ]; pev ( i_Ent, pev_origin, vf_Origin );

            // --| Make tripmine solid.
            set_pev ( i_Ent, pev_solid, SOLID_BBOX );
            engfunc ( EngFunc_SetOrigin, i_Ent, vf_Origin );

            // --| Make and show the laser.
            Tripmine_MakeBeam ( i_Ent );

            // --| Play the activate sound. Now our tripmine is fully installed.
            emit_sound ( i_Ent, CHAN_VOICE, gs_ActivateSound, 0.5, ATTN_NORM, 1, 75 );
        }

        // --| Need to think until tripmine is powered up.
        set_pev ( i_Ent, pev_nextthink, f_Time + 0.1 );
    }


    Tripmine_BeamBreakThink ( const i_Ent )
    {
        // --| Tripmine got some damages.
        if ( GetTripmineHealth ( i_Ent ) + gt_CmdData[ Misc ][ Health ] < gf_HealthReference )
        {
            // --| Tripmine should exploded.
            Tripmine_Killed ( i_Ent );
            return;
        }

        // --| Initialize variables.
        static Float:f_BeamLength, Float:f_Fraction;
        static Float:vf_Origin[ Coord_e ], Float:vf_End[ Coord_e ];

        // --| Retrieve start/end origin, and beam length.
        pev ( i_Ent, pev_origin, vf_Origin );
        pev ( i_Ent, TG_END_POSITION, vf_End );
        pev ( i_Ent, TG_BEAM_LENGTH, f_BeamLength );

        // --| Trace a line to see if we touch something.
        engfunc ( EngFunc_TraceLine, vf_Origin, vf_End, DONT_IGNORE_MONSTERS, i_Ent, 0 );
        get_tr2 ( 0, TR_flFraction, f_Fraction );

        // --| Respawn detect.
        if ( !pev ( i_Ent, TG_BEAM_INDEX ) )
        {
            // --| Need to redraw the beam.
            Tripmine_MakeBeam ( i_Ent );
        }

        // --| Someone has passed the line. The original trace and this are different.
        if ( floatabs ( f_BeamLength - f_Fraction ) > 0.001 )
        {
            // --| Tripmine should exploded now.
            Tripmine_Killed ( i_Ent, get_tr2 ( 0, TR_pHit ) );
            return;
        }

        // --| Loop until someone touches the laser.
        set_pev ( i_Ent, pev_nextthink, get_gametime () + BEAM_BREAK_SPEED );
    }


    Tripmine_DelayDeathThink ( const i_Ent )
    {
        static Float:vf_Origin[ Coord_e ], Float:vf_Dir[ Coord_e ];
        static Float:vf_Start[ Coord_e ], Float:vf_End[ Coord_e ], tr;

        pev ( i_Ent, pev_origin, vf_Origin );
        pev ( i_Ent, TG_DIRECTION, vf_Dir );
        pev ( i_Ent, TG_END_POSITION, vf_End );

        VectorMA ( vf_Origin, 8.0, vf_Dir, vf_Start );
        VectorMS ( vf_Origin, 64.0, vf_Dir, vf_End );

        engfunc ( EngFunc_TraceLine, vf_Start, vf_End, DONT_IGNORE_MONSTERS, i_Ent, tr );

        // --| Remove the beam.
        Tripmine_KillBeam ( i_Ent );

        // --| Prepare to remove tripmine after the explosion.
        SetNextThinkStep ( i_Ent, Think_e:Remove, get_gametime () + 0.5 );

        // --| Boom !
        Tripmine_Explode ( i_Ent, tr, DMG_BLAST );
    }


    Tripmine_Killed ( const i_Ent, const i_Victim = 0 )
    {
        // --| Can't take damage.
        set_pev ( i_Ent, pev_takedamage, DAMAGE_NO );

        // --| Tripmine explodes with a delay between 0.1 ~ 0.3.
        SetNextThinkStep ( i_Ent, Think_e:DelayDeath, get_gametime () + random_float ( 0.1, 0.3 ) );

        // --| Shut off charge up sound.
        emit_sound ( i_Ent, CHAN_BODY, "common/null.wav", 0.5, ATTN_NORM, 0, PITCH_NORM );

        // --| If the type of attack is Instant,
        if ( pev ( i_Ent, TG_ATTACK_TYPE ) == InstantAttack )
        {
            // --| Immediately kill the victim.
            wpn_kill_user ( gi_Weaponid, i_Victim, pev ( i_Ent, TG_REAL_OWNER ), 0, DMG_ENERGYBEAM | DMG_ALWAYSGIB );
        }
    }


    Tripmine_Explode ( i_Ent, tr, i_DamageBit )
    {
        static Float:vf_EndPos[ Coord_e ], Float:vf_NormalPlane[ Coord_e ], Float:vf_Origin[ Coord_e ];
        static Float:f_Fraction, i_Contents, i_Hit, Float:f_MaxDmg;

        f_MaxDmg = gt_CmdData[ Explosion ][ ExDmg ][ pev ( i_Ent, TG_ATTACK_TYPE ) ];

        set_pev ( i_Ent, pev_model, NULL );
        set_pev ( i_Ent, pev_solid, SOLID_NOT );
        set_pev ( i_Ent, pev_takedamage, DAMAGE_NO );

        get_tr2 ( tr, TR_flFraction, f_Fraction );
        get_tr2 ( tr, TR_vecEndPos, vf_EndPos );
        get_tr2 ( tr, TR_vecPlaneNormal, vf_NormalPlane );

        i_Hit = UTIL_Instance ( get_tr2 ( tr, TR_pHit ) );

        // --| Pull out the explosion a bit.
        if ( f_Fraction != 1.0 )
        {
            VectorMA ( vf_EndPos, ( f_MaxDmg - 24.0 ) * 0.7, vf_NormalPlane, vf_Origin );
            set_pev ( i_Ent, pev_origin, vf_Origin );
        }

        pev ( i_Ent, pev_origin, vf_Origin );
        i_Contents = engfunc ( EngFunc_PointContents, vf_Origin );

        // --| Time to explode now.
        FX_Explosion ( i_Ent, i_Contents, vf_Origin );

        // --| Do some damage.
        wpn_radius_damage ( gi_Weaponid, pev ( i_Ent, TG_REAL_OWNER ), i_Ent, f_MaxDmg, f_MaxDmg * 2.5, i_DamageBit );
        wpn_entity_radius_damage ( i_Ent, f_MaxDmg, vf_Origin, f_MaxDmg * 2.5 );

        // --|
        if ( f_Fraction == 1.0 )
        {
            return;
        }

        // --| Show some burn decals.
        FX_Decals ( i_Hit, vf_EndPos );

        // --| Make some debris noise.
        switch ( random_num ( 0, 2 ) )
        {
            case 0 : emit_sound ( i_Ent, CHAN_VOICE, "weapons/debris1.wav", 0.55, ATTN_NORM, NULL, PITCH_NORM );
            case 1 : emit_sound ( i_Ent, CHAN_VOICE, "weapons/debris2.wav", 0.55, ATTN_NORM, NULL, PITCH_NORM );
            case 2 : emit_sound ( i_Ent, CHAN_VOICE, "weapons/debris3.wav", 0.55, ATTN_NORM, NULL, PITCH_NORM );
        }

        // --| Don't draw entity.
        set_pev ( i_Ent, pev_effects, pev ( i_Ent, pev_effects ) | EF_NODRAW );

        // --| Make some smoke.
        SetNextThinkStep ( i_Ent, CreateSmoke, get_gametime () + 0.3 );

        // --| If not in water, make sparks.
        if ( i_Contents != CONTENTS_WATER )
        {
            static i_Sparkcount, i; i_Sparkcount = random_num ( 0, 3 );

            for ( i = 0; i < i_Sparkcount; ++i )
            {
                Tripmine_SparksExplosion ( vf_Origin, vf_NormalPlane, NULL );
            }
        }
    }


    Tripmine_MakeBeam ( const i_Ent )
    {
        static Float:vf_Origin[ Coord_e ], Float:vf_End[ Coord_e ];
        static Float:vf_Dir[ Coord_e ], Float:f_Fraction, tr, i_AttackType;
        static Float:vf_Color[ Coord_e ];

        pev ( i_Ent, pev_origin, vf_Origin );
        pev ( i_Ent, TG_END_POSITION, vf_End );
        pev ( i_Ent, TG_DIRECTION, vf_Dir );

        engfunc ( EngFunc_TraceLine, vf_Origin, vf_End, DONT_IGNORE_MONSTERS, i_Ent, tr );

        get_tr2 ( tr, TR_flFraction, f_Fraction );
        set_pev ( i_Ent, TG_BEAM_LENGTH, f_Fraction );

        SetNextThinkStep ( i_Ent, Think_e:BeamBreak, get_gametime () + 0.1 );

        i_AttackType = pev ( i_Ent, TG_ATTACK_TYPE );

        vf_Color[ x ] = gt_CmdData[ Laser ][ LrColor ][ Red   ][ i_AttackType ] * 1.0;
        vf_Color[ y ] = gt_CmdData[ Laser ][ LrColor ][ Green ][ i_AttackType ] * 1.0;
        vf_Color[ z ] = gt_CmdData[ Laser ][ LrColor ][ Blue  ][ i_AttackType ] * 1.0;

        client_print ( 0, print_chat, "i_AttackType = %d | %.0f %.0f %.0f", i_AttackType, vf_Color[ x ], vf_Color[ y ], vf_Color[ z ] );

        switch ( i_AttackType )
        {
            case NormalAttack  : FX_BeamEntPoint ( i_Ent, vf_Origin, vf_End, gt_CmdData[ Laser ][ LrWidth ][ NormalAttack ]  * 1.0 , 255.0, gt_CmdData[ Laser ][ LrBrightness ][ NormalAttack ]  * 1.0, vf_Color );
            case InstantAttack : FX_BeamEntPoint ( i_Ent, vf_Origin, vf_End, gt_CmdData[ Laser ][ LrWidth ][ InstantAttack ] * 1.0 , 255.0, gt_CmdData[ Laser ][ LrBrightness ][ InstantAttack ] * 1.0, vf_Color );
        }
    }


    Tripmine_SmokeExplosion ( const i_Ent )
    {
        static Float:vf_Origin[ Coord_e ];
        pev ( i_Ent, pev_origin, vf_Origin );

        if ( engfunc ( EngFunc_PointContents, vf_Origin ) == CONTENTS_WATER )
        {
            static Float:vf_Mins[ Coord_e ], Float:vf_Maxs[ Coord_e ];
            static const Float:vf_Temp[ Coord_e ] = { 64.0, 64.0, 64.0 };

            VectorSubtract ( vf_Origin, vf_Temp, vf_Mins );
            VectorAdd ( vf_Origin, vf_Temp, vf_Maxs );

            Tripmine_BubblesExplosion ( vf_Mins, vf_Maxs, 100 );
        }
        else
        {
            FX_Smoke ( vf_Origin );
        }
    }


    Tripmine_BubblesExplosion ( const Float:vf_Mins[], const Float:vf_Maxs[], i_Count )
    {
        static Float:vf_Mid[ Coord_e ], Float:f_Height;

        VectorAdd ( vf_Mins, vf_Maxs, vf_Mid );
        VectorScale ( vf_Mid, 0.5, vf_Mid );

        f_Height = UTIL_GetWaterLevel ( vf_Mid,  vf_Mid[ z ], vf_Mid[ z ] + 1024.0 );
        f_Height = f_Height - vf_Mins[ z ];

        FX_Bubbles ( vf_Mid, vf_Mins, vf_Maxs, f_Height, i_Count );
    }


    Tripmine_SparksExplosion ( const Float:vf_Origin[], const Float:vf_PlaneNormal[], const i_Owner )
    {
        static i_Spark; i_Spark = engfunc ( EngFunc_CreateNamedEntity, gi_SparkClass );

        set_pev ( i_Spark, TG_ENTITY_TYPE, Spark );
        set_pev ( i_Spark, TG_THINK_STEP, CreateSpark );

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
        set_pev ( i_Spark, pev_nextthink, get_gametime () + 0.1 );

        engfunc ( EngFunc_SetModel, i_Spark, gs_Model_P );
        engfunc ( EngFunc_SetSize , i_Spark, Float:{ 0.0, 0.0, 0.0 }, Float:{ 0.0, 0.0, 0.0 } );

        set_pev ( i_Spark, pev_effects, pev ( i_Spark, pev_effects ) | EF_NODRAW );
        set_pev ( i_Spark, pev_speed, random_float ( 0.5, 1.5 ) );
        set_pev ( i_Spark, pev_angles, Float:{ 0.0, 0.0, 0.0 } );
    }


    Tripmine_SparksExplosion2 ( const i_Spark )
    {
        static Float:vf_Origin[ Coord_e ], Float:f_Speed;

        pev ( i_Spark, pev_origin, vf_Origin );
        pev ( i_Spark, pev_speed, f_Speed );

        FX_Sparks ( vf_Origin );

        f_Speed -= 0.1;
        set_pev ( i_Spark, pev_speed, f_Speed );

        f_Speed > 0 ?  set_pev ( i_Spark, pev_nextthink, get_gametime () + 0.1 ) : UTIL_RemoveEntity ( i_Spark );
        set_pev ( i_Spark, pev_flags, pev ( i_Spark, pev_flags ) & ~FL_ONGROUND );
    }


    public Tripmine_WarningSound ( const i_Tripmine )
    {
        emit_sound ( i_Tripmine, CHAN_VOICE, "buttons/blip2.wav", VOL_NORM, ATTN_NORM, NULL, PITCH_NORM );
    }


    Tripmine_KillBeam ( const i_Ent )
    {
        static i_Beam;

        if ( ( i_Beam = pev ( i_Ent, TG_BEAM_INDEX ) ) )
        {
            UTIL_RemoveEntity ( i_Beam );
            set_pev ( i_Ent, TG_BEAM_INDEX, NULL );
        }
    }


    Tripmine_Removing ( const i_Ent )
    {
        Tripmine_KillBeam ( i_Ent );
        UTIL_RemoveEntity ( i_Ent );
    }


    bool:IsTripminePlacable ( const id )
    {
        // --| Initiliaze variables.
        static Float:vf_Source[ Coord_e ], Float:vf_Aiming[ Coord_e ];
        static Float:f_Fraction, tr;

        // --| Get gun position.
        UTIL_MakeVector( id, v_angle + punchangle );
        UTIL_GetGunPosition ( id, vf_Source );

        // --| Get end origin. ( aiming )
        global_get ( glb_v_forward, vf_Aiming );
        VectorMA ( vf_Source, 128.0, vf_Aiming, vf_Aiming );

        // --| Trace a line to see if we touch something.
        engfunc( EngFunc_TraceLine, vf_Source, vf_Aiming, DONT_IGNORE_MONSTERS, id, tr );

        // --| Save the trace result to be used later.
        gt_Tripmine[ id ][ LastTrace ] = tr;

        // --| Get the fraction value.
        get_tr2 ( tr, TR_flFraction, f_Fraction );

        // --| We touch something.
        if ( f_Fraction < 1.0 )
        {
            // --| Play the draw animation to correct the tripmine size.
            wpn_playanim ( id, tripmine_draw );

            // --| We don't want to place tripmine on movable entity.
            if ( !( pev ( UTIL_Instance ( get_tr2 ( tr, TR_pHit ) ), pev_flags ) & FL_CONVEYOR ) )
            {
                return true;
            }
        }

        return false;
    }


    UpdateAmmo ( const id, const AmmoToRemove )
    {
        gi_UsrWeapon[ id ] = wpn_has_weapon ( id, gi_Weaponid );
        wpn_set_userinfo ( id, usr_wpn_ammo1, gi_UsrWeapon[ id ], wpn_get_userinfo ( id, usr_wpn_ammo1, gi_UsrWeapon[ id ] ) - AmmoToRemove );
    }


    WeaponIdle ( id )
    {
        static Float:f_Time; f_Time = get_gametime ();

        if ( gf_TimeWeaponIdle[ id ] > f_Time )
        {
            return;
        }

        gi_UsrWeapon[ id ] = wpn_has_weapon ( id, gi_Weaponid );

        if ( wpn_get_userinfo ( id, usr_wpn_ammo1, gi_UsrWeapon[ id ] ) > 0 )
        {
            wpn_playanim ( id, tripmine_draw );
        }
        else
        {
            wpn_remove_weapon ( id, gi_UsrWeapon[ id ] );
            return;
        }

        switch ( random_num ( 0, 2 ) )
        {
            case 0 :
            {
                wpn_playanim ( id, tripmine_idle1 );
                gf_TimeWeaponIdle[ id ] = f_Time + 90.0 / 30.0;
            }
            case 1 :
            {
                wpn_playanim ( id, tripmine_idle2 );
                gf_TimeWeaponIdle[ id ] = f_Time + 60.0 / 30.0;
            }
            case 2 :
            {
                wpn_playanim ( id, tripmine_fidget );
                gf_TimeWeaponIdle[ id ] = f_Time + 100.0 / 30.0;
            }
        }
    }


    FX_Explosion ( const i_Ent, const i_Contents, const Float:vf_Origin[] )
    {
        message_begin_f ( MSG_PAS, SVC_TEMPENTITY, vf_Origin );
        write_byte ( TE_EXPLOSION );
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        write_short ( i_Contents != CONTENTS_WATER ? gi_Fireball : gi_WExplosion );
        write_byte ( floatround ( gt_CmdData[ Explosion ][ ExMaxRadius ][ pev ( i_Ent, TG_ATTACK_TYPE ) ] ) );
        write_byte ( 15 )
        write_byte ( TE_EXPLFLAG_NONE );
        message_end ();
    }


    FX_BeamEntPoint ( const i_Ent, const Float:vf_Origin[], const Float:vf_End[], const Float:f_Width, const Float:f_Scrollrate, const Float:f_Brightness, const Float:vf_Color[] )
    {
        static i_Beam; i_Beam = engfunc ( EngFunc_CreateNamedEntity, gi_BeamClass );

        set_pev ( i_Beam, pev_flags, pev ( i_Beam, pev_flags ) | FL_CUSTOMENTITY );
        set_pev ( i_Ent, TG_BEAM_INDEX, i_Beam );

        set_pev ( i_Beam, pev_model, gi_LaserClass );
        set_pev ( i_Beam, pev_modelindex, gi_Beam );

        set_pev ( i_Beam, pev_body, 0 );                  // --| Amplitude.
        set_pev ( i_Beam, pev_scale, f_Width );           // --| Width.
        set_pev ( i_Beam, pev_animtime, f_Scrollrate );   // --| Scroll rate.
        set_pev ( i_Beam, pev_rendercolor, vf_Color );    // --| Color.
        set_pev ( i_Beam, pev_renderamt, f_Brightness );  // --| Brightness.

        set_pev ( i_Beam, pev_rendermode, TE_BEAMENTPOINT & 0x0F ); // --| Type

        set_pev ( i_Beam, pev_skin, ( i_Ent & 0x0FFF ) | ( 1 & 0xF000 ) << 12 ); // --| Start attachment
        set_pev ( i_Beam, pev_aiment, i_Ent );                                   // --| Start point

        UTIL_RelinkBeam ( i_Beam, vf_Origin, vf_End );
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


    FX_Smoke ( const Float:vf_Origin[] )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin );
        write_byte ( TE_SMOKE );
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        write_short ( gi_Smoke );
        write_byte ( floatround ( ( 150.0 - 50.0 ) * 0.80 ) ); // -- scale * 10
        write_byte ( 12 );                                     // -- framerate
        message_end ();
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


    UTIL_RelinkBeam ( const i_Beam, const Float:vf_Origin[], const Float:vf_End[] )
    {
        static Float:vf_Mins[ Coord_e ], Float:vf_Maxs[ Coord_e ];

        vf_Mins[ x ] = floatmin ( vf_End[ x ], vf_Origin[ x ] ) - vf_End[ x ];
        vf_Mins[ y ] = floatmin ( vf_End[ y ], vf_Origin[ y ] ) - vf_End[ y ];
        vf_Mins[ z ] = floatmin ( vf_End[ z ], vf_Origin[ z ] ) - vf_End[ z ];

        vf_Maxs[ x ] = floatmax ( vf_End[ x ], vf_Origin[ x ] ) - vf_End[ x ];
        vf_Maxs[ y ] = floatmax ( vf_End[ y ], vf_Origin[ y ] ) - vf_End[ y ];
        vf_Maxs[ z ] = floatmax ( vf_End[ z ], vf_Origin[ z ] ) - vf_End[ z ];

        engfunc ( EngFunc_SetSize, i_Beam, vf_Mins, vf_Maxs );
        engfunc ( EngFunc_SetOrigin, i_Beam, vf_End );
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


    /*
        + - - -
        |  Get gun position.
        |
           @param id                Player id who is holding the tripmine  |
           @param vf_Source         Output of the player's gun position    |
                                                                     - - - +
    */
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


    UTIL_MakeAimVectors ( const id, const i_Type )
    {
        static Float:vf_Angle[ Angle_e ];

        if ( i_Type & angles )     pev ( id, pev_angles, vf_Angle );
        if ( i_Type & punchangle ) pev ( id, pev_punchangle, vf_Angle );
        if ( i_Type & v_angle    ) pev ( id, pev_v_angle, vf_Angle );

        vf_Angle[ pitch ] = -vf_Angle[ pitch ];
        engfunc ( EngFunc_MakeVectors, vf_Angle );
    }


    UTIL_Instance ( const i_Target )
    {
        return i_Target == -1 ? 0 : i_Target;
    }


    UTIL_RemoveEntity ( const i_Ent )
    {
        set_pev ( i_Ent, pev_flags, FL_KILLME );
    }


    public cmd_WpnTripmine( id, level, cid )
    {
        if ( !cmd_access ( id, level, cid, 3 ) )
        {
            goto usage;
        }

        new s_Cmd[ 16 ];
        read_argv ( 1, s_Cmd, charsmax ( s_Cmd ) );

        // -- reloading config file
        if ( s_Cmd[ 0 ] == 'r' )
        {
            ExecuteConfigFile ();
            return PLUGIN_HANDLED;
        }

        new s_Value[ 16 ];
        read_argv ( 2, s_Value, charsmax ( s_Value ) );

        new bool:b_NoFound;

        switch ( s_Cmd[ 0 ] )
        {
            case 'g' :  // --| General commands.
            {
                switch ( s_Cmd[ 3 ] )
                {
                    case 'c' :  // --| gl_[c]ost
                    {
                        gt_CmdData[ General ][ Cost ] = max ( 1, str_to_num ( s_Value ) );
                        wpn_set_integer( gi_Weaponid, wpn_cost, gt_CmdData[ General ][ Cost ] );
                    }
                    case 'a' :  // --| gl_[a]mmo
                    {
                        gt_CmdData[ General ][ Ammo ] = max ( 1, str_to_num ( s_Value ) );
                        wpn_set_integer( gi_Weaponid, wpn_ammo1, gt_CmdData[ General ][ Ammo ] );
                    }
                    case 's' :  // --| gl_[s]peed.
                    {
                        gt_CmdData[ General ][ Speed ] = _:floatmax ( 2.0, str_to_float ( s_Value ) );
                        wpn_set_float( gi_Weaponid, wpn_run_speed, gt_CmdData[ General ][ Speed ] );
                    }

                    default : b_NoFound = true;
                }
            }
            case 'e' :  // --| Explosion commands.
            {
                // --| Initiliaze variables.
                new i_Attack;

                // --| Determine first the attack type.
                switch ( s_Cmd[ 2 ] )
                {
                    case 'p' : i_Attack = NormalAttack;   // --| ex[p]_*.
                    case 's' : i_Attack = InstantAttack;  // --| ex[s]_*.
                }

                // --| Could not determine the attadck type, we ignore.
                if ( !i_Attack )
                {
                    return PLUGIN_HANDLED;
                }

                switch( s_Cmd[ 4 ] )
                {
                    case 'e' :  // --| ex*_[e]ntflag.
                    {
                        gt_CmdData[ Explosion ][ ExEntFlags ] = clamp ( str_to_num ( s_Value ), 0, 4 );
                    }
                    case 'd' :  // --| ex*_[d]mg.
                    {
                        gt_CmdData[ Explosion ][ ExDmg ][ i_Attack ] = _:floatmax ( 1.0, str_to_float ( s_Value ) );
                    }
                    case 'r' :  // --| ex*_[r]adius.
                    {
                        new s_MinRadius[ 4 ], s_MaxRadius[ 4 ];
                        parse ( s_Value, s_MinRadius, charsmax ( s_MinRadius ), s_MaxRadius, charsmax ( s_MaxRadius ) );

                        gt_CmdData[ Explosion ][ ExMinRadius ][ i_Attack ] = _:floatmax ( 0.0, str_to_float ( s_MinRadius ) );
                        gt_CmdData[ Explosion ][ ExMaxRadius ][ i_Attack ] = _:floatmax ( 0.0, str_to_float ( s_MaxRadius ) );

                        if ( !s_MaxRadius[ 0 ] )
                        {
                            gt_CmdData[ Explosion ][ ExMaxRadius ][ i_Attack ] = _:gt_CmdData[ Explosion ][ ExMinRadius ][ i_Attack ]
                            gt_CmdData[ Explosion ][ ExMinRadius ] = 0;
                        }
                    }

                    default : b_NoFound = true;
                }
            }
            case 'l' :  // --| Laser commands.
            {
                // --| Initiliaze variables.
                new i_Attack;

                // --| Determine first the attack type.
                switch ( s_Cmd[ 2 ] )
                {
                    case 'p' : i_Attack = NormalAttack;   // --| lr[p]_*.
                    case 's' : i_Attack = InstantAttack;  // --| lr[s]_*.
                }

                // --| Could not determine the attadck type, we ignore.
                if ( !i_Attack )
                {
                    return PLUGIN_HANDLED;
                }

                switch( s_Cmd[ 4 ] )
                {
                    case 'd' :  // --| lr*_[d]mg.
                    {
                        // --| Laser damage is only available for primary attack.
                        if ( i_Attack == NormalAttack )
                        {
                            new s_MinDmg[ 4 ], s_MaxDmg[ 4 ];
                            parse ( s_Value, s_MinDmg, charsmax ( s_MinDmg ), s_MaxDmg, charsmax ( s_MaxDmg ) );

                            gt_CmdData[ Laser ][ LrMinDmg ][ i_Attack ] = _:floatmax ( 0.0, str_to_float ( s_MinDmg ) );
                            gt_CmdData[ Laser ][ LrMaxDmg ][ i_Attack ] = _:floatmax ( 0.0, str_to_float ( s_MaxDmg ) );

                            if( !s_MaxDmg[ 0 ] )
                            {
                                gt_CmdData[ Laser ][ LrMaxDmg ][ i_Attack ] = _:gt_CmdData[ Laser ][ LrMinDmg ][ i_Attack ];
                                gt_CmdData[ Laser ][ LrMinDmg ][ i_Attack ] = 0;
                            }
                        }
                        else
                        {
                            // --| Otherwise be sure that both are null.
                            gt_CmdData[ Laser ][ LrMaxDmg ][ i_Attack ] = _:gt_CmdData[ Laser ][ LrMinDmg ][ i_Attack ] = _:0.0;
                        }
                    }
                    case 'c' :  // --| lr*_[c]olor.
                    {
                        new s_Red[ 4 ], s_Green[ 4 ], s_Blue[ 4 ];
                        parse ( s_Value, s_Red, charsmax( s_Red ), s_Green, charsmax( s_Green ), s_Blue, charsmax( s_Blue ) );

                        gt_CmdData[ Laser ][ LrColor ][ Red ]  [ i_Attack ] = clamp ( str_to_num ( s_Red )  , 1, 255 );
                        gt_CmdData[ Laser ][ LrColor ][ Green ][ i_Attack ] = clamp ( str_to_num ( s_Green ), 1, 255 );
                        gt_CmdData[ Laser ][ LrColor ][ Blue ] [ i_Attack ] = clamp ( str_to_num ( s_Blue ) , 1, 255 );
                    }
                    case 'b' :  // --| lr*_[b]rightness.
                    {
                        gt_CmdData[ Laser ][ LrBrightness ][ i_Attack ] = clamp ( str_to_num ( s_Value ), 1, 255 );
                    }
                    case 'w' : // --| lr*_[w]idth.
                    {
                        gt_CmdData[ Laser ][ LrWidth ][ i_Attack ] = clamp ( str_to_num ( s_Value ), 1, 100 );
                    }

                    default  : b_NoFound = true;
                }
            }
            case 'm' :  // --| Misc commands.
            {
                switch( s_Cmd[ 3 ] )
                {
                    case 's' :  // --| ms_[s]hoot.
                    {
                        gt_CmdData[ Misc ][ Shoot  ] = clamp ( str_to_num ( s_Value ), 0, 2 );
                    }
                    case 'h' :  // --| ms_[h]ealth.
                    {
                        gt_CmdData[ Misc ][ Health ] = _:( ( gt_CmdData[ Misc ][ Shoot ] < 2 ) ? 0.0 : floatmax ( 0.0, str_to_float ( s_Value ) ) );
                    }
                    case 'p' :  // --| ms_[p]lace.
                    {
                        switch ( ( gt_CmdData[ Misc ][ Place ] = clamp ( str_to_num ( s_Value ), 0, 2 ) + 1 ) )
                        {
                            case Normal, Quick : wpn_set_float( gi_Weaponid, wpn_refire_rate1 , 0.3 );
                            case Real          : wpn_set_float( gi_Weaponid, wpn_refire_rate1 , 2.5 );
                        }
                    }
                    case 'g' :  // --| ms_[g]round.
                    {
                        gt_CmdData[ Misc ][ Ground ] = clamp ( str_to_num ( s_Value ), 0, 1 );
                    }

                    default : b_NoFound = true;
                }
            }

            default : b_NoFound = true;
        }

        if ( b_NoFound )
        {
            usage:
            console_print ( id, "Invalid command : %s", s_Cmd );
            ConsolePrintUsage ( id );
        }

        return PLUGIN_HANDLED;

    }


    ConsolePrintUsage( const id )
    {
        console_print( id, "Usage : wpn_tm <command> <value>" );
        console_print( id, " " );
        console_print( id, "* General :" );
        console_print( id, "  - - - - -" );
        console_print( id, "    gl_cost^t^t- Cost of buying. (^"%d^")"                          , gt_CmdData[ General ][ Cost ] );
        console_print( id, "    gl_ammo^t- How many mines can be planted per player. (^"%d^")"  , gt_CmdData[ General ][ Ammo ] );
        console_print( id, "    gl_speed^t- Player's speed when holding the tripmine. (^"%.1f^")", gt_CmdData[ General ][ Speed ] );
        console_print( id, " " );
        console_print( id, "* Explosion : ( primary attack | secondary attack )" );
        console_print( id, "  - - - - - -" );
        console_print( id, "    exp_dmgflag | exs_dmgflag - Maximum damage that a tripmine can be done. (^"%.1f^" | ^"%.1f^")"        , gt_CmdData[ Explosion ][ ExDmg ][ NormalAttack ]      , gt_CmdData[ Explosion ][ ExDmg ][ InstantAttack ] );
        console_print( id, "    exp_radius^t| exs_radius - Maximum blast damage radius ; <[min] max> ;(^"%.1f %.1f^" | ^"%.1f %.1f^")", gt_CmdData[ Explosion ][ ExMinRadius ][ NormalAttack ], gt_CmdData[ Explosion ][ ExMaxRadius ][ NormalAttack ], gt_CmdData[ Explosion ][ ExMinRadius ][ InstantAttack ], gt_CmdData[ Explosion ][ ExMaxRadius ][ InstantAttack ] );
        console_print( id, "    exp_flag^t^t| exs_flag - Damage entity flags. (^"%d^" | ^"%d^")"                              , gt_CmdData[ Explosion ][ ExEntFlags ] [ NormalAttack ], gt_CmdData[ Explosion ][ ExEntFlags ][ InstantAttack ] );
        console_print( id, "        0 - Do nothing." );
        console_print( id, "        1 - Tripmine explosion destroys others tripmines." );
        console_print( id, "        2 - Break all func_breakable entity." );
        console_print( id, "        4 - Break all func_pushable entity with SF_PUSH_BREAKABLE spawnflag." );
        console_print( id, " " );
        console_print( id, "* Laser : ( primary attack | secondary attack )" );
        console_print( id, "  - - - -" );
        console_print( id, "    lrp_dmgflag                     - Laser damage ; <[min] max> ;(^"%.1f %.1f^")", gt_CmdData[ Laser ][ LrMinDmg ][ NormalAttack ], gt_CmdData[ Laser ][ LrMaxDmg ][ NormalAttack ] );
        console_print( id, "    lrp_dmg        | lrs_dmg        - Laser color ; <RRR GGG BBB> ; 1 ~ 255 ; (^"%d %d %d^" | ^"%d %d %d^")", gt_CmdData[ Laser ][ LrColor ][ Green ][ NormalAttack ], gt_CmdData[ Laser ][ LrColor ][ Red ][ NormalAttack ], gt_CmdData[ Laser ][ LrColor ][ Blue ][ NormalAttack ], gt_CmdData[ Laser ][ LrColor ][ Green ][ InstantAttack ], gt_CmdData[ Laser ][ LrColor ][ Red ][ InstantAttack ], gt_CmdData[ Laser ][ LrColor ][ Blue ][ InstantAttack ] );
        console_print( id, "    lrp_brightness | lrs_brightness - Laser brightness ; <0 ~ 255> ; 0 = invisible (^"%d^" | ^"%d^")" , gt_CmdData[ Laser ][ LrBrightness ][ NormalAttack ], gt_CmdData[ Laser ][ LrBrightness ][ InstantAttack ] );
        console_print( id, "    lrp_width      | lrs_width      - Laser width. (^"%d^")", gt_CmdData[ Laser ][ LrWidth ][ NormalAttack ], gt_CmdData[ Laser ][ LrWidth ][ InstantAttack ] );
        console_print( id, " " );
        console_print( id, "* Misc :" );
        console_print( id, "  - - -" );
        console_print( id, "    ms_shoot  - Is the tripmine shootable ? (^"%d^")", gt_CmdData[ Misc ][ Shoot ] );
        console_print( id, "        0 - Not shootable" );
        console_print( id, "        1 - One shoot" );
        console_print( id, "        2 - Depending of its health value" );
        console_print( id, "    ms_health - Specify tripmine health. (^"%.0f^")", gt_CmdData[ Misc ][ Health ] );
        console_print( id, "    ms_place  - Allow you to power up quickly a tripmine (^"%d^")", gt_CmdData[ Misc ][ Place ] );
        console_print( id, "        0 - Quick  ( ~1.2s )" );
        console_print( id, "        1 - Normal ( ~2.7s )" );
        console_print( id, "        2 - Real   ( ~3.8s )" );
        console_print( id, "    ms_ground -  Dropped tripmine behaviour. (^"%d^")", gt_CmdData[ Misc ][ Ground ] );
        console_print( id, "        0 - Lieing on the ground" );
        console_print( id, "        1 - WeaponMod behaviour (a bit elevated)" );
    }
