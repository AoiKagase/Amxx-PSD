
   /* - - - - - - - - - - -

        AMX Mod X script.

          | Author  : Arkshine
          | Plugin  : PsychoStats 3.2+ PsychoLive Plugin
          | Version : v1.0.0

        (!) Support : http://forums.alliedmods.net/showthread.php?t=81379
        (!) Converted/adapted from the SourceMod plugin by Stormtrooper.

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
            "PsychoLive" AMX Mod X plugin for Psychostats 3.2+ .

            This plugin records a game into the PsychoStats database for real-time
            viewing or playback at any other time. 
            
            That's mainly just a bunch of event handlers that track and record certain events directly 
            to the PsychoStats database. 
            
            If you want to know more about Pyscholive, read this : http://www.psychostats.com/forums/index.php?showtopic=18155


        Requirement :
        - - - - - - -
            * CS 1.6 / CZ / DoD / TFC / NS / HLDM.
            * AMX Mod X 1.8.1 or higher.
            * PyschoStats 3.2 or higher.


        Modules :
        - - - - -
            * Fakemeta
            * Hamsandwich
            * Sqlx


        Changelog :
        - - - - - -
            v1.0.0 : [ 2008, dec 3 ]

                (+) Initial release.

    - - - - - - - - - - - */

    #include <amxmodx>
    #include <amxmisc>
    #include <fakemeta>
    #include <hamsandwich>
    #include <sqlx>

    // --| Change the default control char '^' by '\'.
    #pragma ctrlchar '\'

    // --| Force dodx module to be loaded.
    #pragma defclasslib xstats dodx

    // --| Native/forward shared with dod. It needs otherwise it won't compile.
    native  xmod_get_wpnlogname ( wpnindex, name[], len );
    forward client_damage ( attacker, victim, damage, wpnindex, hitplace, TA );


    // --| Debug log messages.
    // --|  0 - Disable.
    // --|  1 - Enable.
    #define DEBUG 0


    /* - - -
     |  PLAYER DATA   |
                - - - */
        #define MAX_CLIENTS       32
        #define MAX_NAME_LENGTH   32
        #define WEAPON_MAX_LENGTH 24

        new gs_PlayerName [ MAX_CLIENTS + 1 ][ MAX_NAME_LENGTH ];
        new gb_IsConnected[ MAX_CLIENTS + 1 ];  // --| Optimisation against is_user_connected().
        new gb_IsAlive    [ MAX_CLIENTS + 1 ];  // --| Optimisation against is_user_alive().

        // --| Psycholive support only 2 teams atm.
        enum { Spectator_Team = 1, Red_Team, Blue_Team };

        enum
        {
            Ent_Null,
            Ent_Unknown,
            Ent_Player,
            Ent_Bot
        };

        enum PlayerStats_e
        {
            GameID,
            UserID,
            Type,
            Kills,
            Deaths,
            Suicides,
            Health,
            Team
        };

        new gi_PlrStats[ MAX_CLIENTS + 1 ][ PlayerStats_e ];

    /* - - - - -
     |  QUEUE SYSTEM / QUERY  |
                    - - - - - */
        #define QUERY_MAX_LENGTH  255
        #define TASK_TIMERECORD   2541451

        enum Pending_e
        {
            PendingEvents,      // --| Events.
            PendingEnts,        // --| New entities.
            PendingEntUpdates   // --| Entities update.
        }

        new gs_Query[ Pending_e ][ QUERY_MAX_LENGTH ];

        // --| Handle for DB information/connection.
        new Handle:gh_DBTuple;
        new Handle:gh_DBConnect;

        // --| Dynamic array for queries.
        new Array:ga_QueryEvents;
        new Array:ga_QueryEnts;
        new Array:ga_QueryEntUpdates;

    /* - - -
     |  MAIN COMMAND DATA  |
                     - - - */
        new const gs_MsgPsliveRestart[] = "(!) [PSLIVE] The server will restart in 3 seconds.";
        new const gs_MsgPsliveStop   [] = "(!) [PSLIVE] Psycholive 3.2+ Psycholive Plugin was stopped.";

        enum CommandData_t
        {
            SQL_Host   [ 64 ],  // --| Hostname or IP of the DB server (localhost for the same machine).
            SQL_User   [ 32 ],  // --| Username to connect as.
            SQL_Pass   [ 32 ],  // --| Password for authentication.
            SQL_Db     [ 32 ],  // --| Name of the database to use.
            SQL_Tprefix[ 32 ],  // --| Prefix to use for all tables related to PsychoStats. ps_ is a good default.
            Attack,             // --| Should attack damage be recorded by PsychoLive ?
            Float:Interval,     // --| Specifies the update interval in seconds for PsychoLive recordings.
            Active              // --| Enable or disable PsychoLive game recordings.
        }

        new gt_CmdData[ CommandData_t ];

    /* - - -
     |  OTHERS STUFFS  |
                 - - - */
        new const gs_ConfigFileName[] = "pslive_databases.cfg";

        #define SetTimer        set_task
        #define RemoveTimer     remove_task
        #define LoopInfinitely  "b"

        #define Event_PlayerDiconnect    client_disconnect
        #define Event_PlayerPutInServer  client_putinserver
        #define DoD_Event_PlayerDamage   client_damage

        #define Fakemeta     0
        #define Hamsandwich  1

        #define Disabled     0
        #define Enabled      1

        new gi_MaxClients;      // --| Max server slots.
        new gi_GameID;          // --| Unique game id.
        new gi_EventIDX = -1;   // --| Unique id for queries.

        // --| Events used for forwards.
        enum
        {
            NewRound,
            RoundStart,
            RoundEnd,
            PlayerSpawn,
            PlayerHealth,
            PlayerDamage,
            PlayerDeath,
            PlayerName,
            LogMsg,
            /* = */
            All_Events
        };

        new gh_Forwards[ All_Events ];

        // --| Mod supported.
        enum ( <<= 1 ) { cstrike = 1, czero, dod, tfc, ns, valve };

        new HamHook:gh_BotCzHam;
        new gi_CurrMod;

        new bool:gb_MapActive;
        new bool:gb_RoundActive;
        new bool:gb_NewRound;           // --| Only CS1.6/CZ.
        new bool:gb_CZBotRegisterHam;   // --| Fix for CZ stupid bot because of Ham.

        // --| For readabiliy.
        enum _:Coord_e { x, y, z };
        enum _:Angle_e { Float:Pitch, Float:Yaw, Float:Roll };

        // --| Pointer for cvars.
        new gp_HostName;
        new gp_HostIp;
        new gp_HostPort;
        new gp_C4Timer;
        new gp_BotQuota;
        new gp_FriendlyFire;

        new gs_MapName[ 48 ];
        new gs_GameName[ 16 ];


    /* - -
     |  MACRO  |
           - - */
        #define IsValidTeam(%1)    ( Red_Team <= %1 <= Blue_Team )
        #define IsValidPlayer(%1)  ( is_user_alive ( %1 ) && IsValidTeam ( gi_PlrStats[ %1 ][ Team ] ) )
        #define IsPlayer(%1)       ( 1 <= %1 <= gi_MaxClients )
        #define IsBot(%1)          ( pev ( %1, pev_flags ) & FL_FAKECLIENT )
        #define IsPlugin(%1)       ( gt_CmdData[ %1 ] )


    public plugin_precache ()
    {
        // --| Plugin infos.
        register_plugin ( "PsychoStats 3.2+ (PsychoLive) Plugin", "1.0.0", "Arkshine" );
        register_cvar ( "ps_live_version", "1.0.0", FCVAR_SERVER | FCVAR_SPONLY );

        // --| Register our main console command.
        register_concmd ( "amx_ps", "Command_Config", ADMIN_CFG, "- <command> <value>" );

        // --| Execute the Psychostats config file.
        ExecuteConfigFile ();

        // --| Plugin is enabled, we can continue.
        if ( IsPlugin ( Active ) )
        {
            // --| Attempt a DB connection. Plugin will be stopped if connection fails.
            SQL_Init ();

            // --| Get the current mod played.
            UTIL_DetermineGame ();

            // --| Get the cvars pointer related to the game server.
            gp_HostName  = get_cvar_pointer ( "hostname" );
            gp_HostIp    = get_cvar_pointer ( "ip" );
            gp_HostPort  = get_cvar_pointer ( "port" );

            // --| Start a new recording for the game.
            StartMap ();

            // --| We want to send our querys considering a timer.
            SetTimer ( gt_CmdData[ Interval ], "TimeRecord", TASK_TIMERECORD, _, _, LoopInfinitely );
        }
    }


    public plugin_init ()
    {
        // --| Plugin is enabled, we can continue.
        if ( IsPlugin ( Active ) )
        {
            // --| Dynamic array used as a queue system to store the query.
            CreateDynamicArrays ();

            // --| Register all necesaary forwards.
            UpdateForwards ( Enabled );

            // --| Enable log natives through FM_AlertMessage.
            register_logevent ( "EnableLogFunction", 6 );

            // --| FF state.
            gp_FriendlyFire = get_cvar_pointer ( "mp_friendlyfire" );

            // --| C4 timer / Cz bots quota.
            if ( gi_CurrMod & ( cstrike | czero ) )
            {
                gp_BotQuota = get_cvar_pointer ( "bot_quota" );
                gp_C4Timer  = get_cvar_pointer ( "mp_C4Timer" );
            }

            // --| Get the server max slots.
            gi_MaxClients = get_maxplayers ();
        }
    }


    public plugin_end ()
    {
        if ( gb_MapActive && gt_CmdData[ Active ] )
        {
            EndMap ();
        }
    }


    public plugin_natives ()
    {
        // --| It will generate an error saying plugin uses an unknown function, if we don't filter.
        set_native_filter ( "native_filter" );
    }


    public native_filter ( const s_Name[], const i_Index, const i_Trap )
    {
        if ( !i_Trap && equal ( s_Name, "xmod_get_wpnlogname" ) )
        {
            // --| Native cound not found. No Problems.
            return PLUGIN_HANDLED;
        }

        return PLUGIN_CONTINUE;
    }


    UpdateForwards ( const i_State )
    {
        switch ( gi_CurrMod )
        {
            case cstrike, czero :
            {
                UTIL_ToggleForward ( get_user_msgid ( "HLTV" ), NewRound, "CS_Event_NewRound", _, i_State );
            }
            case dod :
            {
                UTIL_ToggleForward ( get_user_msgid ( "TextMsg" )   , RoundStart, "DoD_Event_RoundStart", _, i_State );
                UTIL_ToggleForward ( get_user_msgid ( "RoundState" ), RoundEnd  , "DoD_Event_RoundEnd"  , _, i_State );
            }
            case ns :
            {
                UTIL_ToggleForward ( get_user_msgid ( "Countdown" ) , RoundStart, "NS_Event_RoundStart", _, i_State );
                UTIL_ToggleForward ( get_user_msgid ( "GameStatus" ), RoundEnd  , "NS_Event_RoundEnd"  , _, i_State );
            }
            case tfc :
            {
                // --| Too bad, Ham_Killed crashes under TFC. It's still well called, but crashes right now after. :/
            }
        }

        // --| Should work under all mods.
        UTIL_ToggleForward ( Ham_Spawn                    , PlayerSpawn , "Event_PlayerSpawn" , "player", i_State, Hamsandwich, 1 );
        UTIL_ToggleForward ( FM_ClientUserInfoChanged     , PlayerName  , "Event_NameChange"  , _       , i_State, Fakemeta );
        UTIL_ToggleForward ( FM_AlertMessage              , LogMsg      , "Event_LogMessage"  , _       , i_State, Fakemeta );
        UTIL_ToggleForward ( get_user_msgid ( "Health" )  , PlayerHealth, "Event_PlayerHealth", _       , i_State );
        UTIL_ToggleForward ( get_user_msgid ( "DeathMsg" ), PlayerDeath , "Event_PlayerKilled", _       , i_State );

        if ( !( gi_CurrMod & dod ) && gt_CmdData[ Attack ] )
        {
            UTIL_ToggleForward ( get_user_msgid ( "Damage" ), PlayerDamage, "Event_PlayerDamage", _ , i_State );
        }

        // --| Bot Cz fix. We do manually.
        if ( gh_BotCzHam )  i_State == Enabled ? EnableHamForward ( gh_BotCzHam ) : DisableHamForward ( gh_BotCzHam );
    }


    ResumePlugin ()
    {
        // --| To avoid errors/problems in the frontend, it's better
        // --| to restart so, psycholive can be initialized properly.

        // --| Tell people about the restart.
        client_print ( 0, print_chat, gs_MsgPsliveRestart );
        server_print ( gs_MsgPsliveRestart );

        // --| Start the timer.
        set_task ( 3.0, "GoRestart" );
    }


    StopPlugin ()
    {
        // --| Tell people the plugin is now stopped.
        console_print ( 0, gs_MsgPsliveStop );
        server_print ( gs_MsgPsliveStop );

        // --| Remove the time record task.
        RemoveTimer ( TASK_TIMERECORD );

        // --| Send all queries already saved one last time.
        SQL_Dump ();

        // --| We unregister all forward so plugin will do absolutely nothing when disabled.
        UpdateForwards ( Disabled );

        // --| Close DB connection.
        SQL_Close ();
    }


    public GoRestart ()
    {
        server_cmd ( "restart" );
    }


    public Command_Config ( id, level, cid )
    {
        if ( !cmd_access ( id, level, cid, 3 ) )
        {
            console_print ( id, "(?) Available commands: enable, interval, attack" );
            return PLUGIN_HANDLED;
        }
        
        // --| Initiliaze variables.
        new s_Command[ 6 ], s_Value[ 64 ];
        static i_OldStatus = -1;

        // --| Retrieve data from the command.
        read_argv ( 1, s_Command, charsmax ( s_Command ) );
        read_argv ( 2, s_Value, charsmax ( s_Value ) );

        // --| Check the first letter.
        switch ( s_Command[ 0 ] )
        {
            case 'A', 'a' /* [A]ttack   */ :
            {
                gt_CmdData[ Attack ] = clamp ( str_to_num ( s_Value ), 0, 1 );

                if ( !( gi_CurrMod & dod ) )
                {
                    UTIL_ToggleForward ( get_user_msgid ( "Damage" ), PlayerDamage, "Event_PlayerDamage", _ , gt_CmdData[ Attack ] ? Enabled : Disabled );
                }
            }
            case 'E', 'e' /* [E]nabled  */ :
            {
                gt_CmdData[ Active ] = clamp ( str_to_num ( s_Value ), 0, 1 );

                switch ( i_OldStatus )
                {
                    case -1 : // --| Map change.
                    {
                        if ( !gt_CmdData[ Active ] )
                        {
                            // --| Let's try to figure out if this plugin should be enabled or not.
                            // --| set_localinfo() is useful here. If plugin is disabled by default,
                            // --| and you enable it, server will restart and to ignore the value from
                            // --| the config file, we use localinfo to store that we want to enable this plugin.
                            get_localinfo ( "pslive_active", s_Value, charsmax ( s_Value ) );

                            if ( s_Value[ 0 ] == '1' )
                            {
                                gt_CmdData[ Active ] = 1;
                                set_localinfo ( "pslive_active", "0" );

                                return PLUGIN_HANDLED;
                            }
                        }
                    }
                    case  0 : { if (  gt_CmdData[ Active ] )  ResumePlugin (); set_localinfo ( "pslive_active", "1" ); }
                    case  1 : { if ( !gt_CmdData[ Active ] )  StopPlugin ();   set_localinfo ( "pslive_active", "0" ); }
                }

                // --| Save the current status.
                i_OldStatus = gt_CmdData[ Active ];
            }
            case 'I', 'i' /* [I]nterval */ :
            {
                gt_CmdData[ Interval ] = _:floatclamp ( str_to_float ( s_Value ), 0.5, 2.0 );

                if ( task_exists ( TASK_TIMERECORD ) )
                {
                    change_task ( TASK_TIMERECORD, gt_CmdData[ Interval ] );
                }
            }
            case 'S', 's' /* [S]QL_* */ :
            {
                switch ( s_Command[ 4 ] )
                {
                    case 'D', 'd' /* Db     */ : copy ( gt_CmdData[ SQL_Db ]     , charsmax ( gt_CmdData[ SQL_Db ] )     , s_Value );
                    case 'H', 'h' /* Host   */ : copy ( gt_CmdData[ SQL_Host ]   , charsmax ( gt_CmdData[ SQL_Host ] )   , s_Value );
                    case 'P', 'p' /* Pass   */ : copy ( gt_CmdData[ SQL_Pass ]   , charsmax ( gt_CmdData[ SQL_Pass ] )   , s_Value );
                    case 'T', 't' /* Prefix */ : copy ( gt_CmdData[ SQL_Tprefix ], charsmax ( gt_CmdData[ SQL_Tprefix ] ), s_Value );
                    case 'U', 'u' /* User   */ : copy ( gt_CmdData[ SQL_User ]   , charsmax ( gt_CmdData[ SQL_User ] )   , s_Value );
                }
            }
        }

        return PLUGIN_HANDLED;
    }



    public EnableLogFunction ()
    {
        // --| Just a trick so read_logarg*() is working through FM_AlerMessage.
        // --| I want to use this forward, so I can unregister it if needs.
    }


    public Event_LogMessage ( const AlertType:i_Type, const s_Message[] )
    {
        if ( i_Type != at_logged )
        {
            // --| Not a log message, we ignore.
            return FMRES_IGNORED;
        }

        // --| CS related events.
        /*
           [  Event name            Total args  Event arg  Event length  ]

              Round_Start               2          1          11
              Round_End                 2          1          9
              Dropped_The_Bomb          3          2          16
              Planted_The_Bomb          3          2          16
              Defused_The_Bomb          3          2          16
              Target_Bombed             6          3          13
              Spawned_With_The_Bomb     3          2          21
              Got_The_Bomb              3          2          12
        */

        // --| All mods related events.
        /*
              joined team               3          1          11
        */

        // --| Initialise variables.
        static s_Arg[ 128 ], i_ArgLen;

        // --| Search by number of args.
        switch ( read_logargc() )
        {
            case 2 :
            {
                i_ArgLen = read_logargv ( 1, s_Arg, charsmax ( s_Arg ) );

                switch ( s_Arg[ 6 ] )
                {
                    case 'S' : if ( i_ArgLen == 11 ) CS_Event_RoundStart ();  // --| Round_[S]tart.
                    case 'E' : if ( i_ArgLen == 9  ) CS_Event_RoundEnd ();    // --| Round_[E]nd.
                }
            }
            case 3 :
            {
                if ( ( read_logargv ( 1, s_Arg, charsmax ( s_Arg ) ) ) == 11 && s_Arg[ 0 ] == 'j' && s_Arg [ 7 ] == 't' )
                {
                    Event_TeamChange ( UTIL_GetLoguserIndex (), UTIL_GetTeamId () );  // --| [j]oined [t]eam.
                }

                switch ( read_logargv ( 2, s_Arg, charsmax ( s_Arg ) ) )
                {
                    case 12 : if ( s_Arg[ 0 ] == 'G' && s_Arg [ 8 ] == 'B' ) CS_Event_BombPickup ();   // --| [G]ot_The_[B]omb.
                    case 21 : if ( s_Arg[ 0 ] == 'S' && s_Arg[ 17 ] == 'B' ) CS_Event_BombPickup ();   // --| [S]pawned_With_The_[B]omb.
                    case 16 :
                    {
                        if ( s_Arg[ 12 ] != 'B' ) return FMRES_IGNORED;

                        switch ( s_Arg[ 1 ] )
                        {
                            case 'r' : CS_Event_BombDropped ();  // --| D[r]opped_The_Bomb.
                            case 'l' : CS_Event_BombPlanted ();  // --| P[l]anted_The_Bomb.
                            case 'e' : CS_Event_BombDefused ();  // --| D[e]fused_The_Bomb.
                        }
                    }

                }
            }
            case 6 :
            {
                if ( ( read_logargv ( 3, s_Arg, charsmax ( s_Arg ) ) ) == 13 && s_Arg[ 7 ] == 'B' )
                {
                    CS_Event_BombExploded ();  // --| Target_[B]ombed.
                }
            }
        }

        return FMRES_IGNORED;
    }


    public Event_PlayerPutInServer ( id )
    {
        // --| Plugin disabled.
        if ( !IsPlugin ( Active ) )
        {
            return;
        }

        // --| Optimization against is_user_connected().
        gb_IsConnected[ id ] = true;

        // --| Fix for Cz bots + Ham.
        if ( ( gi_CurrMod & czero ) && IsBot ( id ) && get_pcvar_num ( gp_BotQuota ) > 0 && !gb_CZBotRegisterHam )
        {
            // --| Delay for private data to initialize.
            SetTimer ( 0.1, "Task_CzBotHookHam", id );
        }

        // --| Retrieve and cache important informations.
        gi_PlrStats[ id ][ GameID   ] = gi_GameID;
        gi_PlrStats[ id ][ UserID   ] = get_user_userid ( id );
        gi_PlrStats[ id ][ Type     ] = is_user_bot ( id ) ? Ent_Bot : Ent_Player;
        gi_PlrStats[ id ][ Kills    ] = 0;
        gi_PlrStats[ id ][ Deaths   ] = 0;
        gi_PlrStats[ id ][ Suicides ] = 0;
        gi_PlrStats[ id ][ Health   ] = get_user_health ( id );
        gi_PlrStats[ id ][ Team     ] = 0;

        // --| Tell psycholive a new player.
        CreatePlayerEntity ( id );

        // --| Initialize variables.
        static s_Ip[ 17 ], s_Json[ 100 ];

        // --| Clear arrays to avoid possible problems.
        s_Json[ 0 ] = gs_Query[ PendingEvents ][ 0 ] = '\0';

        // --| Get the player's IP address, without port.
        get_user_ip ( id, s_Ip, charsmax ( s_Ip ), true );

        // --| Escape '\' character in player's name.
        replace_all ( gs_PlayerName[ id ], MAX_NAME_LENGTH - 1, "\\", "\\\\" );
        replace_all ( gs_PlayerName[ id ], MAX_NAME_LENGTH - 1, "\"", "\\\"" );

        // --| Build a json structure for the player info so this player can be
        // --| initialized in the front-end w/o having to do a separate request.
        formatex ( s_Json, charsmax ( s_Json ), "{\"ent_type\":%d,\"ent_name\":\"%s\",\"ent_ip\":\"%s\"}", gi_PlrStats[ id ][ Type ], gs_PlayerName[ id ], s_Ip );

        // --| Back-quotes characters in a string for database querying.
        // --| Note : The buffer's maximum size should be 2*strlen(string) to catch all scenarios.
        const i_JsonLen = 2 * sizeof ( s_Json ) + 1; static s_QJson[ i_JsonLen ];
        SQL_QuoteString ( gh_DBConnect, s_QJson, i_JsonLen, s_Json );

        // --| Build our player query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_CONNECT',%d,NULL,NULL,NULL,NULL,'%s')",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   gi_PlrStats[ id ][ UserID ],
                   s_QJson );

        #if DEBUG
            log_amx ( "OnClientPutInServer : '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );

        // --| Fix for valve. Force an unique team for all players.
        if ( gi_CurrMod & valve )
        {
            Event_TeamChange ( id, Blue_Team );
        }
    }


    public Event_PlayerDisconnect ( id )
    {
        // --| Plugin disabled.
        if ( !IsPlugin ( Active ) )
        {
            return;
        }

        // --| Optimization against is_user_connected() / is_user_alive().
        gb_IsConnected[ id ] = false;
        gb_IsAlive    [ id ] = false;

        // --| Save player's data.
        SavePlayerEntity ( id );

        // --| Build our player query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_DISCONNECT',%d,NULL,NULL,NULL,NULL,NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   gi_PlrStats[ id ][ UserID ] );

        #if DEBUG
            log_amx ( "OnClientDisconnect: '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );

        // --| Clear cached player data.
        gi_PlrStats[ id ][ GameID   ] = 0;
        gi_PlrStats[ id ][ UserID   ] = 0;
        gi_PlrStats[ id ][ Type     ] = Ent_Unknown;
        gi_PlrStats[ id ][ Kills    ] = 0;
        gi_PlrStats[ id ][ Deaths   ] = 0;
        gi_PlrStats[ id ][ Suicides ] = 0;
        gi_PlrStats[ id ][ Health   ] = 0;
    }


    public Task_CzBotHookHam ( const id )
    {
        // --| Already registered or disconnected, we ignore.
        if ( gb_CZBotRegisterHam || !gb_IsConnected[ id ] )
        {
            return;
        }

        // --| Recheck for safety.
        if ( IsBot ( id ) && get_pcvar_num ( gp_BotQuota ) > 0 )
        {
            // --| Post spawn fix for cz bots, since RegisterHam does not work for them.
            gh_BotCzHam = RegisterHamFromEntity ( Ham_Spawn, id, "Forward_Spawn", 1 );

            // --| Only needs to run once after ham is registed ignore.
            gb_CZBotRegisterHam = true;

            // --| In case this bot has spawned alive into a game that already has
            // --| started we must manually call a Ham_Spawn because the ham will
            // --| not register early enough.
            if ( is_user_alive(  id ) )
            {
                Event_PlayerSpawn ( id );
            }
        }
    }


    /*
        register_event ( "HLTV", "CS_Event_NewRound", "a", "1=0", "2=0" );
    */
    public CS_Event_NewRound ( const i_MsgId, const i_MsgType, const id )
    {
        if ( i_MsgType == MSG_SPEC && get_msg_arg_int ( 1 ) == 0 && get_msg_arg_int ( 2 ) == 0 )
        {
            gb_NewRound = true;
        }
    }


    /*
        register_logevent ( "CS_Event_RoundStart", 2, "1=Round_End" );
    */
    public CS_Event_RoundStart ()
    {
        if ( gi_GameID && gb_NewRound )
        {
            gb_RoundActive = true;
            gb_NewRound = false;

            // --| Delayed a bit.
            set_task ( 0.1, "Shared_RoundStart" );
        }
    }


    /*
        register_logevent ( "CS_Event_RoundEnd", 2, "1=Round_Start" );
    */
    public CS_Event_RoundEnd ()
    {
        if ( !gb_RoundActive )
        {
            return;
        }

        Shared_RoundEnd ();
    }


    /*
        register_event ( "TextMsg", "DoD_Event_RoundStart", "bc", "2&#game_roundstart" );
    */
    public DoD_Event_RoundStart ( const i_MsgId, const i_MsgType, const id )
    {
        if ( gi_GameID && !gb_RoundActive && i_MsgType == MSG_ONE && get_msg_arg_int ( 1 ) == 3 )
        {
            new s_Message[ 17 ];
            get_msg_arg_string ( 2, s_Message, charsmax ( s_Message ) );

            if ( equal ( s_Message, "#game_roundstart" ) )
            {
                Shared_RoundStart ();
            }
        }
    }


    /*
        register_event ( "RoundState", "DoD_Event_RoundEnd", "a", "1=3", "1=4", "1=5" );
    */
    public DoD_Event_RoundEnd ( const i_MsgId, const i_MsgType, const id )
    {
        if ( i_MsgType == MSG_ALL && ( get_msg_arg_int ( 1 ) == 3 || get_msg_arg_int ( 1 ) == 4 || get_msg_arg_int ( 1 ) == 5 ) )
        {
            Shared_RoundEnd ();
        }
    }


    /*
        register_event ( "Countdown", "NS_Event_RoundStart", "a" );
    */
    public NS_Event_RoundStart ( const i_MsgId, const i_MsgType, const id )
    {
        if ( gi_GameID && !gb_RoundActive && i_MsgType == MSG_ALL )
        {
            Shared_RoundStart ();
        }
    }


    /*
        register_event ( "GameStatus", "NS_Event_RoundEnd", "a", "1=2" );
    */
    public NS_Event_RoundEnd ( const i_MsgId, const i_MsgType, const id )
    {
        if ( i_MsgType == MSG_ALL && gb_RoundActive && get_msg_arg_int ( 1 ) == 2 )
        {
            Shared_RoundEnd ();
        }
    }


    public Shared_RoundStart ()
    {
        gb_RoundActive = true;

        // --| Update the health of all players,
        for ( new id = 1; id <= gi_MaxClients; id++ )
        {
            gi_PlrStats[ id ][ Health ] = get_user_health ( id );
        }

        // --| Build our query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'ROUND_START',NULL,NULL,NULL,NULL,'%d',NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   get_timeleft () );

        #if DEBUG
            log_amx ( "RoundStart : '%s' | %timeleft = %d", gs_Query[ PendingEvents ], get_timeleft () );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );
    }


    public Shared_RoundEnd ()
    {
        gb_RoundActive = false;

        // --| Build our query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'ROUND_END',NULL,NULL,NULL,NULL,NULL,NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime () );

        #if DEBUG
            log_amx ( "EndRound : '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );
    }


    public Event_PlayerSpawn ( const id )
    {
        // --| Must be alive and in a team. ( +fix for TFC )
        if ( IsValidPlayer ( id ) || ( ( gi_CurrMod & tfc ) && IsValidTeam ( gi_PlrStats[ id ][ Team ] ) ) )
        {
            // --| Initialize variables.
            static vi_Origin[ Coord_e ], s_Origin[ 21 ];

            // --| Optimization against is_user_alive().
            gb_IsAlive[ id ] = true;

            // --| Get player location coordinates.
            get_user_origin ( id, vi_Origin );

            // --| Store theses coordinates into a string.
            formatex ( s_Origin, charsmax ( s_Origin ), "%d %d %d", vi_Origin[ x ], vi_Origin[ y ], vi_Origin[ z ] );

            // --| Build our player query.
            formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_SPAWN',%d,NULL,'%s',NULL,NULL,NULL)",
                       gi_GameID,
                       ++gi_EventIDX,
                       get_systime (),
                       gi_PlrStats[ id ][ UserID ],
                       s_Origin );

            #if DEBUG
                log_amx ( "player_spawn: '%s'", gs_Query[ PendingEvents ] );
            #endif

            // --| Save our query to the queue to be send the right time.
            SendQueryToQueue ( PendingEvents );

            // --| Fix for TFC / HLDM. Since there is no 'round start' event, we consider
            // --| a round is starting when there is at least one player.
            if ( ( gi_CurrMod & ( tfc | valve ) ) && !gb_RoundActive && get_playersnum () )
            {
                Shared_RoundStart ();
            }
        }
    }


    /*
        Damage doesn't exist for DoD. So we have to use client_damage() forward.
    */
    public DoD_Event_PlayerDamage ( i_Killer, i_Victim, i_Damage, i_WpnIndex, i_Hitplace, TA )
    {
        // --| Plugin should be active, attack enabled, used only for dod, and damage should not be null.
        if ( gt_CmdData[ Active ] && gt_CmdData[ Attack ] && ( gi_CurrMod & dod ) && i_Damage > 0 )
        {
            Shared_PlayerDamage ( i_Killer, i_Victim, i_Damage );
        }
    }


    public Event_PlayerDamage ( const i_MsgId, const i_MsgType, const i_Victim )
    {
        static i_Damage, i_Killer;

        // --| Damage should be not null.
        if ( i_Victim && ( i_Damage = get_msg_arg_int ( 2 ) ) )
        {
            // --| Retrieve attacker. If not a player, we considerate the killer as victim.
            if ( !IsPlayer ( ( i_Killer = get_user_attacker ( i_Victim ) ) ) ) i_Killer = i_Victim;

            // --| Send our query.
            Shared_PlayerDamage ( i_Killer, i_Victim, i_Damage );
        }
    }


    Shared_PlayerDamage ( const i_Killer, const i_Victim, const i_Damage )
    {
        // --| Build our query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_HURT',%d,%d,NULL,NULL,'%d',NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   gi_PlrStats[ i_Killer ][ UserID ],
                   gi_PlrStats[ i_Victim ][ UserID ],
                   i_Damage );

        #if DEBUG
            // log_amx ( "player_hurt : '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );
    }


    /*
        + - - - - - - - - - - - - - -
        |  Player is killed by someone/entiy. Use DeathMsg event.
        |
        |  All supported mods has 'DeathMsg' message but there are some differences.
           At the start I was using 'Ham_Killed' forward but I had to use get_user_attacker()
           to retrieve the weapon id, then getting the weapon name. Without speaking I had to
           filter victim/attacker as player/entity (which is a pain), I was not getting the             |
           weapon name for custom weapons. That's why it's better to use DeathMsg here (more safe too)  |
           which provide the weapon name (except dod) and for custom weapons too.                       |
                                                                            - - - - - - - - - - - - - - +
    */
    public Event_PlayerKilled ( const i_MsgId, const i_MsgType, const id )
    {
        // --| Get players index, Victim and Attacker.
        new i_Killer = get_msg_arg_int ( 1 );
        new i_Victim = get_msg_arg_int ( 2 );

        // --| Probably rare case, but I've seen both null under a mod.
        if ( !i_Killer || !i_Victim )  return;

        static bool:b_HeadShot, bool:b_Suicide; b_HeadShot = false;
        static s_WeaponName[ 32 ];

        switch ( gi_CurrMod )
        {
            case cstrike, czero :
            {
                // --| Is a headshot ?
                b_HeadShot = bool:( get_msg_arg_int ( 3 ) );

                // --| Get the weapon log name.
                get_msg_arg_string ( 4, s_WeaponName, charsmax ( s_WeaponName ) );
            }
            case dod :
            {
                // --| Get the weapon log name. DeathMsg in DoD provides only the weapon id.
                xmod_get_wpnlogname ( get_msg_arg_int ( 3 ), s_WeaponName, charsmax ( s_WeaponName ) );
            }
            case tfc, ns, valve :
            {
                  // --| Get the weapon log name.
                get_msg_arg_string ( 3, s_WeaponName, charsmax ( s_WeaponName ) );
            }
        }

        // --| Is a suicide ?
        b_Suicide = bool:( i_Killer == i_Victim );

        // --| Killer is null. It's a suicide but for some reason killer is not the same than victim.
        if ( !i_Killer )  i_Killer = i_Victim;

        // --| Weapon name is null. It's a suicide but killer is null. ( probably because of custom weapon ).
        // --| So we considerate as suicide and "world" as generic weapon.
        if ( !s_WeaponName[ 0 ] )
        {
            b_Suicide = true;
            s_WeaponName = "world";
        }

        // --| Increase deaths.
        ++gi_PlrStats[ i_Victim ][ Deaths ];
        if ( b_Suicide ) ++gi_PlrStats[ i_Victim ][ Suicides ];

        // --| If victim killed by teammate, mod are cs/tfc and ff to 1...
        ( gi_CurrMod & ( cstrike | czero | tfc ) && gi_PlrStats[ i_Victim ][ Team ] == gi_PlrStats[ i_Killer ][ Team ]
                                                 && gp_FriendlyFire && get_pcvar_num ( gp_FriendlyFire ) ) ?

            --gi_PlrStats[ i_Killer ][ Kills ] : // --| Then we subtract -1 to its frags.
            ++gi_PlrStats[ i_Killer ][ Kills ];  // --| Otherwise, add +1.

        // --| Back-quotes characters in a string for database querying.
        // --| Note : The buffer's maximum size should be 2*strlen(string) to catch all scenarios.
        const i_WeaponLen = 2 * WEAPON_MAX_LENGTH + 1; static s_QWeapon[ i_WeaponLen ];
        SQL_QuoteString ( gh_DBConnect, s_QWeapon, i_WeaponLen, s_WeaponName );

        // --| Build our query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_KILL',%d,%d,NULL,'%s',%s,NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   gi_PlrStats[ i_Killer ][ UserID ],
                   gi_PlrStats[ i_Victim ][ UserID ],
                   s_QWeapon,
                   b_HeadShot ? "'1'" : "NULL" );

        #if DEBUG
            log_amx ( "player_death: '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );
    }


    Event_TeamChange ( const id, const i_Team )
    {
        // --| Same saved value.
        if ( gi_PlrStats[ id ][ Team ] == i_Team )
        {
            // --| No need to send query again.
            return;
        }

        // --| Save the new player's team.
        gi_PlrStats[ id ][ Team ] = i_Team;

        // --| Build our player query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_TEAM',%d,NULL,NULL,NULL,'%d',NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   gi_PlrStats[ id ][ UserID ],
                   gi_PlrStats[ id ][ Team ] );

        #if DEBUG
            log_amx ( "Team change: '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );

        // --| Fix. In TFC, player spawns before choosing a team... -_-
        if ( ( gi_CurrMod & tfc ) && i_Team != Spectator_Team )
        {
            Event_PlayerSpawn ( id );
        }
    }


    public Event_PlayerHealth ( const i_MsgId, const i_MsgType, const id )
    {
        // --| Be sure id is > 0. / And Save current player's health.
        if ( id )  { gi_PlrStats[ id ][ Health ] = get_msg_arg_int ( 1 ); }
    }


    public Event_NameChange ( const id )
    {
        // --| Get the new name.
        static s_NewName[ MAX_NAME_LENGTH ];
        get_user_info ( id, "name", s_NewName, charsmax ( s_NewName ) );

        // --| Detect player's name change.
        if ( !equal ( gs_PlayerName[ id ], s_NewName ) )
        {
            // --| The new name is now stored as reference.
            gs_PlayerName[ id ][ 0 ] = '\0'; gs_PlayerName[ id ] = s_NewName;

            // --| Back-quotes characters in a string for database querying.
            // --| Note : The buffer's maximum size should be 2*strlen(string) to catch all scenarios.
            const i_NameLen = 2 * MAX_NAME_LENGTH + 1; static s_QNewName[ i_NameLen ];
            SQL_QuoteString ( gh_DBConnect, s_QNewName, i_NameLen, s_NewName );

            // --| Build our query.
            formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_NAME',%d,NULL,NULL,NULL,'%s',NULL)",
                       gi_GameID,
                       ++gi_EventIDX,
                       get_systime (),
                       gi_PlrStats[ id ][ UserID ],
                       s_QNewName );

            #if DEBUG
                log_amx ( "player_changename: '%s'", gs_Query[ PendingEvents ] );
            #endif

            // --| Save our query to the queue to be send the right time.
            SendQueryToQueue ( PendingEvents );
        }
    }


    /*
        + - - - - - - - - - - - - - - - -
        |  Bomb pick up.
        |
        |  (?) Log message, i.e : "Arkshine<1><STEAM_0:0:12345><TERRORIST>" triggered "Spawned_With_The_Bomb"  // --| 3 args.
        |
               Arg {0} = Arkshine<1><STEAM_0:0:12345><TERRORIST>
               Arg {1} = triggered                                  // --| Len = 9
               Arg {2} = Spawned_With_The_Bomb                      // --| Len = 21

           (?) Log message, i.e : "Arkshine<1><STEAM_0:0:12345><TERRORIST>" triggered "Got_The_Bomb"  // --| 3 args.

               Arg {0} = Arkshine<1><STEAM_0:0:12345><TERRORIST>                                                             |
               Arg {1} = triggered                                  // --| Len = 9                                           |
               Arg {2} = Got_The_Bomb                               // --| Len = 12                                          |
                                                                                             - - - - - - - - - - - - - - - - +
    */
    public CS_Event_BombPickup ()
    {
        // --| Get the player's id.
        new id = UTIL_GetLoguserIndex ();

        // --| Build our player query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_BOMB_PICKUP',%d,NULL,NULL,NULL,NULL,NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   gi_PlrStats[ id ][ UserID ] );

        #if DEBUG
            log_amx ( "Bomb Pickup : '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );
    }


    /*
        + - - - - - - - - - - - - - - - -
        |  Bomb dropped.
        |
        |  (?) Log message, i.e : "Arkshine<1><STEAM_0:0:12345><TERRORIST>" triggered "Dropped_The_Bomb"  // --| 3 args.

               Arg {0} = Arkshine<1><STEAM_0:0:12345><TERRORIST>
               Arg {1} = triggered                                  // --| Len = 9                                         |
               Arg {2} = Dropped_The_Bomb                           // --| Len = 16                                        |
                                                                                           - - - - - - - - - - - - - - - - +
    */
    public CS_Event_BombDropped ()
    {
        // --| Get the player's id.
        new id = UTIL_GetLoguserIndex ();

        // --| Get the player's origin.
        new vi_Origin[ Coord_e ]; get_user_origin ( id, vi_Origin );

        // --| Store theses coordinates into a string.
        new s_Origin[ 23 ]; formatex ( s_Origin, charsmax ( s_Origin ), "'%d %d %d'", vi_Origin[ x ], vi_Origin[ y ], vi_Origin[ z ] );

        // --| Build our player query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_BOMB_DROPPED',%d,NULL,%s,NULL,NULL,NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   gi_PlrStats[ id ][ UserID ],
                   s_Origin );

        #if DEBUG
            log_amx ( "Bomb Dropped : '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );
    }


    /*
        + - - - - - - - - - - - - - - - -
        |  Bomb planted.
        |
        |  (?) Log message, i.e : "Arkshine<1><STEAM_0:0:12345><TERRORIST>" triggered "Planted_The_Bomb"  // --| 3 args.

               Arg {0} = Arkshine<1><STEAM_0:0:12345><TERRORIST>
               Arg {1} = triggered                                  // --| Len = 9                                         |
               Arg {2} = Planted_The_Bomb                           // --| Len = 16                                        |
                                                                                           - - - - - - - - - - - - - - - - +
    */
    public CS_Event_BombPlanted ()
    {
        // --| Get the player's id.
        new id = UTIL_GetLoguserIndex ();

        // --| Get the bomb origin.
        new Float:vf_Origin[ Coord_e ]; pev ( UTIL_FindEntByModel ( -1, "grenade", "models/w_c4.mdl" ), pev_origin, vf_Origin );

        // --| String conversion. Bomb origin / Timer value.
        new s_Origin[ 23 ]; formatex ( s_Origin, charsmax ( s_Origin ), "'%d %d 0'", floatround ( vf_Origin[ 0 ] ), floatround ( vf_Origin[ 1 ] ) );
        new s_Value [ 10 ]; formatex ( s_Value, charsmax ( s_Value ), "'%d'", get_pcvar_num ( gp_C4Timer ) );

        // --| Build our player query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_BOMB_PLANTED',%d,NULL,%s,NULL,%s,NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   gi_PlrStats[ id ][ UserID ],
                   s_Origin,
                   s_Value );

        #if DEBUG
            log_amx ( "Bomb Planted : '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );
    }


    /*
        + - - - - - - - - - - - - - - - -
        |  Bomb defused.
        |
        |  (?) Log message, i.e : "Arkshine<1><STEAM_0:0:12345><TERRORIST>" triggered "Defused_The_Bomb"  // --| 3 args.

               Arg {0} = Arkshine<1><STEAM_0:0:12345><TERRORIST>
               Arg {1} = triggered                                  // --| Len = 9                                         |
               Arg {2} = Defused_The_Bomb                           // --| Len = 16                                        |
                                                                                           - - - - - - - - - - - - - - - - +
    */
    public CS_Event_BombDefused ()
    {
        // --| Get the player's id.
        new id = UTIL_GetLoguserIndex ();

        // --| Build our player query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_BOMB_DEFUSED',%d,NULL,NULL,NULL,NULL,NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime (),
                   gi_PlrStats[ id ][ UserID ] );

        #if DEBUG
            log_amx ( "Bomb Defused : '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );
    }


    /*
        + - - - - - - - - - - - - - - - -
        |  Bomb exploded.
        |
        |  (?) Log message, i.e : Team "TERRORIST" triggered "Target_Bombed" (CT "0") (T "0")  // --| 6 args.
        |
               Arg {0} = Team               // --| Len = 4
               Arg {1} = TERRORIST          // --| Len = 9
               Arg {2} = triggered          // --| Len = 9                                                     |
               Arg {3} = Target_Bombed      // --| Len = 13                                                    |
               Arg {4} = CT "0"             // --| Len = 6                                                     |
               Arg {5} = T "0"              // --| Len = 5                                                     |
                                                                               - - - - - - - - - - - - - - - - +
    */
    public CS_Event_BombExploded ()
    {
        // --| Build our player query.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_BOMB_EXPLODED',NULL,NULL,NULL,NULL,NULL,NULL)",
                   gi_GameID,
                   ++gi_EventIDX,
                   get_systime () );

        #if DEBUG
            log_amx ( "Bomb Exploded : '%s'", gs_Query[ PendingEvents ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEvents );
    }


    /*
        + - - - - - - - - - - - -
        |  Executed each 'Interval' seconds to retrieve the player's origin
           and to send at once the saved queries for this period.            |
                                                     - - - - - - - - - - - - +
    */
    public TimeRecord ()
    {
        // --| Nothing to do if we don't have a gameID yet, no round active or no players connected.
        if ( !gi_GameID && !gb_RoundActive && !get_playersnum () )
        {
            // --| Let's see if there are some events to send yet.
            SQL_Dump ();
            return;
        }

        // --| Initialize variables.
        static vi_Origin[ Coord_e ], s_Origin[ 21 ], s_Angle[ 21 ], i_Time, id;

        // --| Get system time as a unix timestamp. ( in seconds )
        i_Time = get_systime ();

        // --| Loop through all players.
        for ( id = 1; id <= gi_MaxClients; id++ )
        {
            // --| Ignore non-connected/alive player.
            if ( !gb_IsConnected[ id ] && !gb_IsAlive[ id ] ) continue;

            // --| If the player has not been created yet we do so here.
            // --| This assures that our asyncronous inserts and updates are
            // --| properly maintained from player connections.
            if ( !gi_PlrStats[ id ][ GameID ] )  CreatePlayerEntity ( id );

            // --| Get player location coordinates.
            get_user_origin ( id, vi_Origin );

            // --| Store theses coordinates/angle into a string.
            formatex ( s_Origin, charsmax ( s_Origin ), "%d %d %d", vi_Origin[ x ], vi_Origin[ y ], vi_Origin[ z ] );
            formatex ( s_Angle, charsmax ( s_Angle ), "%d", UTIL_GetPlayerAngle ( id, Yaw ) ); // --| Get player direction.

            // --| Add player movement to query.
            formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'PLR_MOVE',%d,NULL,'%s',NULL,'%s',NULL)",
                       gi_GameID,
                       ++gi_EventIDX,
                       i_Time,
                       gi_PlrStats[ id ][ UserID ],
                       s_Origin,
                       s_Angle );

            #if DEBUG
                // log_amx ( "TimerRecord: %s", gs_Query[ PendingEvents ] );
            #endif

            // --| Save our query to the queue to be send the right time.
            SendQueryToQueue ( PendingEvents );
        }

        // --| Time to send the queries in queue.
        SQL_Dump ();
    }


    /*
        + - - - - - - - - - - - -
        |  Tell psycholive to create a new player.  |
                            - - - - - - - - - - - - +
    */
    CreatePlayerEntity ( const id )
    {
        // --| Do not try and save the player if we have no gameID since all
        // --| entities must have a game associated.
        if ( !gi_GameID )  return;

        // --| Make sure the player is assigned to this game.
        gi_PlrStats[ id ][ GameID ] = gi_GameID;

        // --| Get the player's name.
        get_user_name ( id, gs_PlayerName[ id ], MAX_NAME_LENGTH - 1 );

        // --| Back-quotes characters in a string for database querying.
        // --| Note : The buffer's maximum size should be 2*strlen(string) to catch all scenarios.
        const i_NameLen = 2 * MAX_NAME_LENGTH + 1; static s_QName[ i_NameLen ];
        SQL_QuoteString ( gh_DBConnect, s_QName, i_NameLen, gs_PlayerName[ id ] );

        // --| Build our player query.
        formatex ( gs_Query[ PendingEnts ], QUERY_MAX_LENGTH - 1, "(%d,%d,%d,'%s',%d)",
                   gi_GameID,
                   gi_PlrStats[ id ][ UserID ],
                   gi_PlrStats[ id ][ Type ],
                   s_QName,
                   gi_PlrStats[ id ][ Team ] );

        #if DEBUG
            log_amx ( "createPlayerEntity: '%s'", gs_Query[ PendingEnts ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEnts );
    }


    /*
        + - - - - - - - - -
        |  Tell psycholive that player has disconnected.  |
                                        - - - - - - - - - +
    */
    SavePlayerEntity ( const id )
    {
        // --| Do not try and save the player if we have no gameID since all.
        // --| entities must have a game associated.
        if ( !gi_GameID )  return;

        // --| make sure this player is assigned to this game.
        gi_PlrStats[ id ][ GameID ] = gi_GameID;

        // --| Back-quotes characters in a string for database querying.
        // --| Note : The buffer's maximum size should be 2*strlen(string) to catch all scenarios.
        const i_NameLen = 2 * MAX_NAME_LENGTH + 1; static s_QName[ i_NameLen ];
        SQL_QuoteString ( gh_DBConnect, s_QName, i_NameLen, gs_PlayerName[ id ] );

        // --| Build our player query.
        formatex ( gs_Query[ PendingEntUpdates ], QUERY_MAX_LENGTH - 1, "onlinetime=%d,kills=%d,deaths=%d,suicides=%d,ent_team=%d,ent_name='%s' WHERE game_id=%d AND ent_id=%d AND ent_type=%d",
                   get_user_time ( id ),
                   gi_PlrStats[ id ][ Kills ],
                   gi_PlrStats[ id ][ Deaths ],
                   gi_PlrStats[ id ][ Suicides ],
                   gi_PlrStats[ id ][ Team ],
                   s_QName,
                   gi_PlrStats[ id ][ GameID ],
                   gi_PlrStats[ id ][ UserID ],
                   gi_PlrStats[ id ][ Type ] );

        #if DEBUG
            log_amx ( "savePlayerEntity: %s", gs_Query[ PendingEntUpdates ] );
        #endif

        // --| Save our query to the queue to be send the right time.
        SendQueryToQueue ( PendingEntUpdates );
    }


    StartMap ()
    {
        gb_MapActive = true;

        // --| Reset the event index counter and get our current map.
        gi_EventIDX = -1;

        // --| Get the current map name.
        get_mapname ( gs_MapName, charsmax ( gs_MapName ) );

        // --| Get server ip:port.
        new i_QHostIp   = GetIpDecimal  ( gp_HostIp );
        new i_QHostPort = get_pcvar_num ( gp_HostPort );

        // --| Get server name.
        new s_HostName[ 255 ];
        get_pcvar_string ( gp_HostName, s_HostName, charsmax ( s_HostName ) );

        // --| Back-quotes characters in a string for database querying.
        // --| Note : The buffer's maximum size should be 2*strlen(string) to catch all scenarios.

        // --| Server Name.
        const i_HostNameLen = 2 * sizeof ( s_HostName ) + 1; new s_QHostName[ i_HostNameLen ];
        SQL_QuoteString ( gh_DBConnect, s_QHostName, i_HostNameLen, s_HostName );

        // --| Game Name.
        const i_GameNameLen = 2 * sizeof ( gs_GameName ) + 1; new s_QGameName[ i_GameNameLen ];
        SQL_QuoteString ( gh_DBConnect, s_QGameName, i_GameNameLen, gs_GameName );

        // --| Current Map.
        const i_CurrentMapLen = 2 * sizeof ( gs_MapName ) + 1; new s_QCurrentMap[ i_CurrentMapLen ];
        SQL_QuoteString ( gh_DBConnect, s_QCurrentMap, i_CurrentMapLen, gs_MapName );

        // --| Start a new recording for the game.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "INSERT INTO %slive_games (start_time,server_ip,server_port,server_name,gametype,modtype,map) VALUES (%d,%d,%d,'%s','halflife','%s','%s')",
                   gt_CmdData[ SQL_Tprefix ],
                   get_systime(),
                   i_QHostIp,
                   i_QHostPort,
                   s_QHostName,
                   s_QGameName,
                   s_QCurrentMap );

        new s_Error[ 255 ];
        new Handle:h_Query = SQL_PrepareQuery ( gh_DBConnect, "%s", gs_Query[ PendingEvents ] );

        #if DEBUG
            log_amx( "[PSLIVE] Starting new recording : '%s'", gs_Query[ PendingEvents ] );
        #endif

        if ( !SQL_Execute ( h_Query ) )
        {
            // --| For some reason, query was not sent.
            SQL_QueryError ( h_Query, s_Error, charsmax ( s_Error ) );
            SQL_FreeHandle ( h_Query );

            // --| We stop here. Tell the problem.
            log_amx ( "[PSLIVE] Error starting recording : '%s'", s_Error );
            set_fail_state ( "[PSLIVE] Please check your Psychostats DB configuration and restart." );
        }
        else
        {
            // --| Get a game id.
            if ( ( gi_GameID = SQL_GetInsertId ( h_Query ) ) )
            {
                gb_MapActive = true;
                log_amx ( "[PSLIVE] This game is being recorded by PsychoLive ! ( GameID %d )", gi_GameID );
            }
            else
            {
                log_amx ( "[PSLIVE] Error fetching GameID from database !" );
            }
        }

        SQL_FreeHandle ( h_Query );
    }


    EndMap ()
    {
        // --| Get server name.
        new s_HostName[ 255 ];
        get_pcvar_string ( gp_HostName, s_HostName, charsmax ( s_HostName ) );

        // --| Back-quotes characters in a string for database querying.
        // --| Note : The buffer's maximum size should be 2*strlen(string) to catch all scenarios.
        const i_HostNameLen = 2 * sizeof ( s_HostName ) + 1; new s_QHostName[ i_HostNameLen ];
        SQL_QuoteString ( gh_DBConnect, s_QHostName, i_HostNameLen, s_HostName );

        // --| Update the ending time of the game.
        formatex ( gs_Query[ PendingEvents ], QUERY_MAX_LENGTH - 1, "UPDATE %slive_games SET end_time=%d, server_name='%s' WHERE game_id=%d",
                   gt_CmdData[ SQL_Tprefix ],
                   get_systime(),
                   s_QHostName,
                   gi_GameID );

        // --| Send our query.
        SQL_ThreadQuery ( gh_DBTuple, "Handle_Generic", gs_Query[ PendingEvents ] );

        // --| Clear vars.
        gb_MapActive = false;
        gi_GameID = 0;
        gs_MapName[ 0 ] = '\0';

        // --| Remove dynamic array / Close the DB connection.
        DestroyDynamicArrays ();
        SQL_Close ();
    }


    SendQueryToQueue ( const Pending_e:i_Type )
    {
        // --| Save queries array dynamic.
        switch ( i_Type )
        {
            case PendingEvents     : ArrayPushString ( ga_QueryEvents    , gs_Query[ PendingEvents ] );
            case PendingEnts       : ArrayPushString ( ga_QueryEnts      , gs_Query[ PendingEnts ] );
            case PendingEntUpdates : ArrayPushString ( ga_QueryEntUpdates, gs_Query[ PendingEntUpdates ] );
        }
    }


    SQL_Dump ()
    {
        // --| We can't concatenate directly a string into a dynamic array item.
        // --| So we have to set a large array which can hold queries up to 32 players max.
        static s_Query[ 3072 ], i_Len;

        // --| Reset string/var.
        s_Query[ 0 ] = '\0'; i_Len = 0;

        // --| Events queue not empty.
        if ( ArraySize ( ga_QueryEvents ) )
        {
            // --| Build the query header.
            i_Len = formatex ( s_Query, charsmax ( s_Query ), "INSERT INTO %slive_events VALUES ", gt_CmdData[ SQL_Tprefix ] );

            // --| Loop until there are no queries anymore in the array.
            while ( ArraySize ( ga_QueryEvents ) )
            {
                // --| Concatenate all queries. ArrayGetStringHandle() is faster and is perfectly appropriate here.
                i_Len += formatex ( s_Query[ i_Len ], charsmax ( s_Query ) - i_Len, "%a,", ArrayGetStringHandle ( ga_QueryEvents, 0 ) );
                ArrayDeleteItem ( ga_QueryEvents, 0 );
            }

            // --| Remove the last ','.
            s_Query[ i_Len - 1 ] = '\0';

            // --| Send our extended insert.
            SQL_ThreadQuery ( gh_DBTuple, "Handle_Generic", s_Query );
        }

        // --| Reset string/var.
        s_Query[ 0 ] = '\0'; i_Len = 0;

        // --| Ents queue not empty.
        if ( ArraySize ( ga_QueryEnts ) )
        {
            // --| Build the query header.
            i_Len = formatex ( s_Query, charsmax ( s_Query ), "INSERT INTO %slive_entities (game_id,ent_id,ent_type,ent_name,ent_team) VALUES ", gt_CmdData[ SQL_Tprefix ] );

            // --| Loop until there are no queries anymore in the array.
            while ( ArraySize ( ga_QueryEnts ) )
            {
                // --| Concatenate all queries. ArrayGetStringHandle() is faster and is perfectly appropriate here.
                i_Len += formatex ( s_Query[ i_Len ], charsmax ( s_Query ) - i_Len, "%a,", ArrayGetStringHandle ( ga_QueryEnts, 0 ) );
                ArrayDeleteItem ( ga_QueryEnts, 0 );
            }

            // --| Remove the last ','.
            s_Query[ i_Len - 1 ] = '\0';

            // --| Send our extended insert.
            SQL_ThreadQuery ( gh_DBTuple, "Handle_Generic", s_Query );
        }

        // --| Reset string/var.
        s_Query[ 0 ] = '\0'; i_Len = 0;

        // --| Ent updates queue not empty.
        if ( ArraySize ( ga_QueryEntUpdates ) )
        {
            // --| Loop until there are no queries anymore in the array.
            while ( ArraySize ( ga_QueryEntUpdates ) )
            {
                formatex ( s_Query, charsmax ( s_Query ), "UPDATE %slive_entities SET %a", gt_CmdData[ SQL_Tprefix ], ArrayGetStringHandle ( ga_QueryEntUpdates, 0 ) );
                ArrayDeleteItem ( ga_QueryEntUpdates, 0 );

                // --| Send our update.
                SQL_ThreadQuery ( gh_DBTuple, "Handle_Generic", s_Query ); s_Query[ 0 ] = '\0';
            }
        }
    }



    /*
        + - - - - - - - - - - -
        |  Transform Ip adresse to decimal number.
        |
        |  (?) Ip : www.xxx.yyy.zzz
        |
                IpDecimal = 16777216 * w + 65536 * x + 256 * y + z ; or
                IpDecimal = ( 256 << 16 ) * w + ( 256 << 8 ) * x + 256 * y + z

           (?) Reversely :

                w = ( IpDecimal / ( 256 << 16 ) ) % 256                            |
                x = ( IpDecimal / ( 256 << 8 ) ) % 256                             |
                y = ( IpDecimal / 256 ) % 256                                      |
                z = ( IpDecimal ) % 256                                            |
                                                             - - - - - - - - - - - +
    */
    GetIpDecimal ( const p_HostIp )
    {
        // --| Retrieve the current server ip.
        new s_HostIp[ 17 ]; get_pcvar_string ( p_HostIp, s_HostIp, charsmax ( s_HostIp ) );

        new i = charsmax ( s_HostIp ), j = 4, r[ 4 ];

        // --| Searh all dots from the end.
        while ( --i >= 3 )
        {
            // --| Found one!
            if ( s_HostIp[ i ] == '.' )
            {
                // --| Save the found number.
                r[ --j ] = str_to_num ( s_HostIp[ i + 1 ] );

                // --| Clear from this position.
                s_HostIp[ i ] = '\0';
            }
        }

        // --| Calculate the decimal number.
        r[ 0 ] = str_to_num ( s_HostIp );
        return r[ 0 ] * ( 256 << 16 ) + r[ 1 ] * ( 256 << 8 ) + r[ 2 ] * 256 + r[ 3 ];
    }


    SQL_Init ()
    {
        // --| Initiliaze  variables.
        new s_Error[ 256 ], i_ErrNum;

        // --| Set up the tuple that will be used for threading.
        gh_DBTuple = SQL_MakeDbTuple ( gt_CmdData[ SQL_Host ], gt_CmdData[ SQL_User ], gt_CmdData[ SQL_Pass ], gt_CmdData[ SQL_Db ] );

        // --| Connection failed.
        if ( ( gh_DBConnect = SQL_Connect ( gh_DBTuple, i_ErrNum, s_Error, charsmax ( s_Error ) ) ) == Empty_Handle )
        {
            // --| Force to stop and tell the problem.
            log_amx ( "[PSLIVE] Database Connection Failed: [%d] %s", i_ErrNum, s_Error );
            set_fail_state ( "[PSLIVE] Please check your Psychostats DB configuration and restart." );
        }
    }


    SQL_Close ()
    {
        if ( gh_DBTuple )
        {
            SQL_FreeHandle ( gh_DBTuple );
        }

        if ( gh_DBConnect )
        {
            SQL_FreeHandle ( gh_DBConnect );
        }
    }


    /*
        + - - - - - - - -
        |  Generate the config file.
        |
           It means also we have to force to stop the plugin   |
           since the DB informations are empty.                |
                                               - - - - - - - - +
    */
    ExecuteConfigFile ()
    {
        // --| Initiliaze variables.
        new s_ConfigsDir[ 64 ], s_File[ 96 ];

        // --| Build patch to the config file.
        get_configsdir ( s_ConfigsDir, charsmax ( s_ConfigsDir ) );
        formatex ( s_File, charsmax ( s_File ), "%s/%s", s_ConfigsDir, gs_ConfigFileName );

        // --| File doesn't exist.
        if ( !file_exists ( s_File ) )
        {
            // --| We generate it.
            GenerateConfigFile ( s_File );
        }

        // --| File exists. Time to execute it.
        server_cmd ( "exec %s", s_File );
        server_exec ();

        #if DEBUG
            log_amx ( "Database Configuration :" );
            log_amx ( "\t Host   = %s", gt_CmdData[ SQL_Host ] );
            log_amx ( "\t User   = %s", gt_CmdData[ SQL_User ] );
            log_amx ( "\t Pass   = %s", gt_CmdData[ SQL_Pass ] );
            log_amx ( "\t Db     = %s", gt_CmdData[ SQL_Db ] );
            log_amx ( "\t Prefix = %s", gt_CmdData[ SQL_Tprefix ] );
            log_amx ( "Plugin Configuration :" );
            log_amx ( "\t Enabled  = %d"  , gt_CmdData[ Active ] );
            log_amx ( "\t Interval = %.1f", gt_CmdData[ Interval ] );
            log_amx ( "\t Attack   = %d"  , gt_CmdData[ Attack ] );
        #endif
    }


    GenerateConfigFile ( const s_File[] )
    {
        log_amx ( "[PSLIVE] Psychostats config file was not found : '%s'", s_File );
        new h_File;

        // --| Create a new file.
        if ( ( h_File = fopen ( s_File, "w+" ) ) )
        {
            fprintf ( h_File,
                "\n\n//  [ DATABASE CONFIGURATION ]\n\n \
                amx_ps sql_host   \"SQL server adress\"\n \
                amx_ps sql_user   \"User's name\"\n \
                amx_ps sql_pass   \"User's password\"\n \
                amx_ps sql_db     \"Database Name\"\n \
                amx_ps sql_tprefix \"Table Prefix ( usually ps_ )\"\n" );

            fprintf ( h_File,
                "\n\n//  [ PLUGIN CONFIGURATION ]\n\n \
                // --| Enable or disable PsychoLive game recordings.( 1 to enable; 0 to disable )\n \
                amx_ps enabled    \"1\"\n \
                // --| Specifies the update interval in seconds for PsychoLive recordings. ( 0.5 to 2.0 )\n \
                amx_ps interval   \"1.0\"\n \
                // --| Should attack damage be recorded by PsychoLive ? ( 1 to enable; 0 to disable ) \n \
                amx_ps attack     \"1\" " );

            // --| Close the open file.
            fclose ( h_File );

            // --| Force to stop the plugin because no DB information is written.
            log_amx ( "[PSLIVE] Psychostats config file was generated successful." );
            set_fail_state ( "[PSLIVE] Database Connection not configured. Please modify and restart your server." );
        }

        // --| For some reason file generation has failed.
        set_fail_state ( "[PSLIVE] Coudn't generate the Psychostats config file. Please upload it on your server." );
    }


    CreateDynamicArrays ()
    {
        ga_QueryEvents     = ArrayCreate ( QUERY_MAX_LENGTH );
        ga_QueryEnts       = ArrayCreate ( QUERY_MAX_LENGTH );
        ga_QueryEntUpdates = ArrayCreate ( QUERY_MAX_LENGTH );
    }


    DestroyDynamicArrays ()
    {
        ArrayDestroy ( ga_QueryEvents );
        ArrayDestroy ( ga_QueryEnts );
        ArrayDestroy ( ga_QueryEntUpdates );
    }


    public Handle_Generic ( failstate, Handle:h_Query, s_Error[], errnum, data[], size, Float:queuetime )
    {
        if ( h_Query == Empty_Handle )
        {
            log_amx ( "[PSLIVE] SQL Error: %s", s_Error );
        }

    }


    /*
        + - - - - - - - - - -
        |  Get and save the current game name played.
        |
        |  (?) Psychostats 3.2+ supports the following HL1 mod :
        |
                - Counter-Strike 1.6 ;              ( cstrike )
                - Counter-Strike: Condition Zero ;  ( czero )
                - Day of Defeat ;                   ( dod )         |
                - Team Fortress Classic ;           ( tfc )         |
                - Natural Selection ;               ( ns )          |
                - Half-Life Deathmatch.             ( valve )       |
                                                - - - - - - - - - - +
    */
    UTIL_DetermineGame ()
    {
        // --| Get the current game name.
        get_modname ( gs_GameName, charsmax ( gs_GameName ) );
        log_amx ( "[PSLIVE] Game name = '%s'", gs_GameName );

        // --| Cache the result.
        if      ( equal ( gs_GameName, "cstrike" ) )  gi_CurrMod = cstrike;
        else if ( equal ( gs_GameName, "czero"   ) )  gi_CurrMod = czero;
        else if ( equal ( gs_GameName, "dod"     ) )  gi_CurrMod = dod;
        else if ( equal ( gs_GameName, "tfc"     ) )  gi_CurrMod = tfc;
        else if ( equal ( gs_GameName, "ns"      ) )  gi_CurrMod = ns;
        else if ( equal ( gs_GameName, "valve"   ) )  gi_CurrMod = valve;
    }


    /*
        + - - - - - - - - - - - - -
        |  Get the player's team index from log message.
        |  It should work under : CS 1.6, CZ, DoD, TFC and NS.
        |  It's called each time a player change team.
        |
           (?) I.e : "Arkshine<1><STEAM_0:0:123456><>" joined team "TERRORIST"  // --| 3 args.

               Arg {0} = Arkshine<1><STEAM_0:0:172726><>
               Arg {1} = joined team                      // --| Len = 11                       |
               Arg {2} = TERRORIST                        // --| Len = 9                        |
                                                                                                |
           @return      Player's team found. If not found, Spectator will be the default        |
                                                                      - - - - - - - - - - - - - +
    */
    UTIL_GetTeamId ()
    {
        // --| Get the team name.
        static s_TeamName[ 3 ], i_Team;
        read_logargv ( 2, s_TeamName, charsmax ( s_TeamName ) );

        // --| Default team.
        i_Team = Spectator_Team;

        // --| Check the first letter.
        switch ( s_TeamName[ 0 ] )
        {
            case 'm', 'C', 'B' /* [m]arine*, [C]T       , [B]lue */ : i_Team = Blue_Team;
            case 'a', 'T', 'R' /* [a]lien* , [T]ERRORIST, [R]ed  */ : i_Team = Red_Team;
            case 'A' :
            {
                switch ( s_TeamName[ 1 ] )
                {
                    case 'l' /* A[l]lies. */ : i_Team = Blue_Team;
                    case 'x' /* A[x]is.   */ : i_Team = Red_Team;
                }
            }
        }

        return i_Team;
    }


    /*
        + - - - - - - - - - -
        |  Return a specific player's angle.
        |
           @id          Player's index.
           @i_Type      Specific angle : Pitch, Yaw or Roll.  |
           @return      Player's angle ( integer output )     |
                                          - - - - - - - - - - +
    */
    UTIL_GetPlayerAngle ( const id, const i_Type )
    {
        static Float:vf_Angles[ Angle_e ];
        pev ( id, pev_angles, vf_Angles );

        return floatround ( vf_Angles[ i_Type ] );
    }


    /*
        + - - - - - - - - - -
        |  Return player's index from a log message.
        |  Since 'id' is not passed or provided directly,
           we have to get it from the player's name
           provided in the log. (Arg 0)
                                                          |
           @return          Player's index.               |
                                      - - - - - - - - - - +
    */
    UTIL_GetLoguserIndex ()
    {
        static s_LogUser[ 80 ], s_Name[ 32 ];

        // --| Retrieve the content from argument 0.
        read_logargv ( 0, s_LogUser, charsmax ( s_LogUser ) );

        // --| Parse the content to get the player's name.
        parse_loguser ( s_LogUser, s_Name, charsmax ( s_Name ) );

        // --| Return player's index from its name.
        return get_user_index ( s_Name );
    }


    /*
        + - - - - - - - - - -
        |  Try to find an entity by classname and by provided model name.
        |  (?) Stolen from fakemeta_util by VEN.
        |
            @param index            Start index.
            @param s_Classname      Entity class name to search.            |
            @param s_Model          Entity model name to search.            |
            @return                 Entity index on success, 0 on failure.  |
                                                        - - - - - - - - - - +
    */
    UTIL_FindEntByModel ( const index, const s_Classname[], const s_Model[] )
    {
        new i_Ent = index, s_ModelFound[ 16 ];

        while ( ( i_Ent = engfunc ( EngFunc_FindEntityByString, i_Ent, "classname", s_Classname ) ) )
        {
            // --| Get the entity current model.
            pev( i_Ent, pev_model, s_ModelFound, charsmax ( s_ModelFound ) );

            // --| If it matches to the provided mode.
            if ( equal ( s_ModelFound, s_Model ) )
            {
                // --| we found our entity.
                return i_Ent;
            }
        }

        // --| Could not find the entity.
        return 0;
    }


    /*
        + - - - - - - - - - -
        |  Toggle forward state.
        |
        |  (?) It supports :

              - register_message()  ( core )
              - register_forward()  ( fakemeta )     |
              - RegisterHam()       ( hamsandwich )  |
                                                     |
                                 - - - - - - - - - - +
    */
    UTIL_ToggleForward ( { Ham, _ }:i_FwdType, i_FwdIndex, const s_FwdCallback[], const s_HamEntity[] = "", i_State, i_Module = -1, i_Post = 0 )
    {
        switch ( i_State )
        {
            case Enabled :
            {
                if ( i_Module != Hamsandwich && gh_Forwards[ i_FwdIndex ] )  return;
                if ( gh_Forwards[ i_FwdIndex ] ) { EnableHamForward ( HamHook:gh_Forwards[ i_FwdIndex ] ); return; }

                switch ( i_Module )
                {
                    case Fakemeta    : gh_Forwards[ i_FwdIndex ] = register_forward ( _:i_FwdType, s_FwdCallback, i_Post );
                    case Hamsandwich : gh_Forwards[ i_FwdIndex ] = _:RegisterHam ( i_FwdType, s_HamEntity, s_FwdCallback, i_Post );
                    default          : gh_Forwards[ i_FwdIndex ] = register_message ( _:i_FwdType, s_FwdCallback );
                }
            }
            case Disabled :
            {
                if ( !gh_Forwards[ i_FwdIndex ] ) return;

                switch ( i_Module )
                {
                    case Fakemeta    : { unregister_forward ( _:i_FwdType, gh_Forwards[ i_FwdIndex ] ); gh_Forwards[ i_FwdIndex ] = 0; }
                    case Hamsandwich : { DisableHamForward  ( HamHook:gh_Forwards[ i_FwdIndex ] ); }
                    default          : { unregister_message ( _:i_FwdType, gh_Forwards[ i_FwdIndex ] ); gh_Forwards[ i_FwdIndex ] = 0; }
                }
            }
        }
    }

    /*
        CS1.6/CZ : Damage, DeathMsg, TeamInfo,          , Health
        HLDM     : Damage, DeathMsg, TeamInfo, TeamNames, Health
        TFC      : Damage, DeathMsg, TeamInfo, TeamNames, Health
        NS       : Damage, DeathMsg, TeamInfo, TeamNames, Health
        DOD      :       , DeathMsg,                    , Health

    */