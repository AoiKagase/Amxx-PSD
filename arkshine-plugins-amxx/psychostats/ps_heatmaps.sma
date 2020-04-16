
   /* - - - - - - - - - - -

        AMX Mod X script.

          | Author  : Arkshine
          | Plugin  : PsychoStats 3.1+ Spatial Plugin
          | Version : v1.2.0

        (!) Adapted/converted on HL1 mods from SourceMod plugin.
        (!) Original idea and SourceMod plugin : Stormtrooper.
        
        (!) Pyschostats site : http://www.psychostats.com/
        (!) Plugin support   : http://forums.alliedmods.net/showthread.php?t=70392   

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
        - - - - - - - -
            Spatial statistics logging plugin.

            This plugin will add extra logging information to player death events.
            With the extra information it is possible to generate heatmaps of where players die,
            where players get kills, what weapons were used and lots of more finer details.

            (!) Requires Psychostats 3.1+.


        Requires :
        - - - - - -
            * All Mods.
            * Psychostats 3.1 or higher.
            * AMX Mod X 1.7x or higher.


        Modules :
        - - - - -
            * fakemeta


        How to add support for custom messages ?
        - - - - - - - - - - - - - - - - - - - - -
            If you want to add spatial stats for your plugin which uses either log_message() or engfunc( FM_AlertMessage, _ ),
            you must follow that :

                In this plugin :

                    - Uncomment this define ( // #define SUPPORT_CUSTOM_MESSAGES ) by removing '//' to enable the support.

                In your custom plugin :

                    - Above plugin_init() function, add : native elog_message( const logmessage[], ... );
                    - Replace all log_message() or/and engfunc( FM_AlertMessage, _ ) by elog_message()


        Additional notes :
        - - - - - - - - - -
            * Psychostats.com forum is the best source of information regarding the heatmap concept in general.
            * Instructions how you can setup custom maps for heatmap generation : http://www.psychostats.com/doc/Heatmap_Setup .
            * To get coordinates for heatmap, you can use this plugin : http://forums.alliedmods.net/showthread.php?p=497942 .


        Changelog :
        - - - - - -
            v1.2.0 : [ 4 nov 2008 ]

                    (*) Changed method to detect event name. Less code / more efficient.
                    (*) Changed plugin name to 'PsychoStats 3.1+ Spatial Plugin'.
                    (-) Regex module was removed.

            v1.1.2 : [ 3 sep 2008 ]

                    (!) Fixed invalid player error.

            v1.1.1 : [ 25 Aug 2008 ]

                    (+) Added native 'elog_message()' to support custom messages.
                        For more informations, see the provided explanation.

            v1.1.0 : [ 24 Aug 2008 ]

                    (~) Plugin rewritten.
                    (+) Using regular expression so it should be more efficient.
                    (!) Fixed a bug with suicide.
                    (*) Minor changements / optimizations.

            v1.0.0 : [ 24 Apr 2008 ]

                    (+) Initial release.


    - - - - - - - - - - - */

    #include <amxmodx>
    #include <fakemeta>

    #pragma ctrlchar '\'
    
    
    /* - - - - - - - -
     |  SUPPORT FOR CUSTOM DEATH/SUICIDE MESSAGES
     |  (!) Uncomment to enable it.                |
        (!) Read above for more informations.      |
                                   - - - - - - - - */
    // #define SUPPORT_CUSTOM_MESSAGES


    /* - - -
     |  PLAYER  |
          - - - */
        enum Event_e  { Killed  , Suicide };
        enum Player_e { Attacker, Victim  };

        new const gs_PlayerTag[ Player_e ][] = 
        {
            "attacker_position",
            "victim_position" 
        };

    /* - - -
     |  LOG MESSAGES  |
                - - - */
        new const gs_MsgFormat[ Player_e ][] = 
        { 
            "%s (%s \"%i %i %i\") (%s \"%i %i %i\")\n", 
            "%s (%s \"%i %i %i\")\n" 
        };

    /* - - -
     |  OTHERS STUFFS  |
                 - - - */
        enum _:Coord_e { x, y, z };
        new gs_NewMessage[ 256 ];

    /* - - -
     |  MACRO  |
         - - - */
        #if !defined charsmax
           #define charsmax(%1)  sizeof ( %1 ) - 1
        #endif


    public plugin_init ()
    {
        register_plugin ( "PsychoStats 3.1+ Spatial Plugin", "1.2.0", "Arkshine" );

        register_logevent ( "EnableLogFunction", 5 );
        register_forward ( FM_AlertMessage, "fwd_AlertMessage" );
    }


    #if defined SUPPORT_CUSTOM_MESSAGES
    
        public plugin_natives ()
        {
            register_native ( "elog_message", "native_elogmessage" );
        }

        public native_elogmessage ()
        {
            vdformat ( gs_NewMessage, charsmax ( gs_NewMessage ), 1, 2 );
            fwd_AlertMessage ( at_logged, gs_NewMessage );
        }
        
    #endif


    // --| Just a trick so read_logarg[c|v]() are working through FM_AlerMessage.
    public EnableLogFunction () {}

    
    public fwd_AlertMessage ( const AlertType:i_Type, s_Message[] )
    {
        if ( i_Type != at_logged )
        {
            // --| Not a log message, we ignore.
            return FMRES_IGNORED;
        }

        // --| Initiliaze variables.
        static s_Arg[ 26 ], vi_OriginVictim[ Coord_e ], vi_OriginKiller[ Coord_e ];

        // --| Search by number of args.
        switch ( read_logargc () )
        {
            case 3, 4 :  // --| Suicide
            {
                // --| 'committed suicide with' : Arg {1} ; 22 letters.
                if ( ( read_logargv ( 1, s_Arg, charsmax ( s_Arg ) ) == 22 ) && s_Arg[ 0 ] == 'c' && s_Arg[ 10 ] == 's' )
                {
                    // --| Attacker's current origin.
                    get_user_origin ( GetLoguserIndex ( 0 ) /* Arg {0} */, vi_OriginKiller );

                    // --| Remove uneccesary space/new line before formating.
                    trim ( s_Message );

                    // --| Add the coordinates.
                    formatex ( gs_NewMessage, charsmax ( gs_NewMessage ), gs_MsgFormat[ Victim ], s_Message,
                    gs_PlayerTag[ Attacker ], vi_OriginKiller[ x ], vi_OriginKiller[ y ], vi_OriginKiller[ z ] );

                    // --| Send our new message.
                    engfunc ( EngFunc_AlertMessage, AlertType:at_logged, gs_NewMessage );

                    // --| Block the original message.
                    return FMRES_SUPERCEDE;
                }
            }
            case 5 :  // --| Killed
            {
                // --| 'killed' : Arg {1} ; 6 letters.
                if ( ( read_logargv ( 1, s_Arg, charsmax ( s_Arg ) ) == 6 ) && s_Arg[ 0 ] == 'k' && s_Arg[ 5 ] == 'd' )
                {
                    // --| Victim & Attacker's current origin.
                    get_user_origin ( GetLoguserIndex ( 0 ) /* Arg {0} */, vi_OriginKiller );
                    get_user_origin ( GetLoguserIndex ( 2 ) /* Arg {2} */, vi_OriginVictim );

                    // --| Remove uneccesary space/new line before formating.
                    trim ( s_Message );

                    // --| Add the coordinates.
                    formatex ( gs_NewMessage, charsmax ( gs_NewMessage ), gs_MsgFormat[ Attacker ], s_Message,
                    gs_PlayerTag[ Attacker ], vi_OriginKiller[ x ], vi_OriginKiller[ y ], vi_OriginKiller[ z ],
                    gs_PlayerTag[ Victim ]  , vi_OriginVictim[ x ], vi_OriginVictim[ y ], vi_OriginVictim[ z ] );

                    // --| Send our new message.
                    engfunc ( EngFunc_AlertMessage, AlertType:at_logged, gs_NewMessage );

                    // --| Block the original message.
                    return FMRES_SUPERCEDE;
                }
            }
        }

        return FMRES_IGNORED;
    }


    GetLoguserIndex ( const i_ArgIndex )
    {
        // --| Initiliaze variables.
        static s_LogUser[ 80 ], i_Len, i_FoundCnt;
        s_LogUser[ 0 ] = '\0'; i_FoundCnt = 0;

        // --| Get the arg {0}.
        i_Len = read_logargv ( i_ArgIndex, s_LogUser, charsmax ( s_LogUser ) );
        
        // --| Search the third '<' from end to grab the player's userid.
        // --| I don't use parse_loguser() since it's a lot more code when I can do it in one line.
        while ( --i_Len && !( s_LogUser[ i_Len ] == '<' && ++i_FoundCnt == 3 ) ) {}

        // --| Return the player's index from its userid.
        return find_player ( "k", str_to_num ( s_LogUser[ i_Len + 1 ] ) );
    }


    /* --| INFORMATION : LOG MESSAGE EXAMPLE --| */

    /* 
        [ Suicide ]
        Arg = "Arkshine<1><STEAM_0:0:123456><TERRORIST>" committed suicide with "worldspawn" (world)

                Arg {0} = Arkshine<1><STEAM_0:0:123456><TERRORIST>
                Arg {1} = committed suicide with
                Arg {2} = worldspawn
              [ Arg {3} = world ]

        Arg num   = 3 or 4.
        Event len = 22. ( arg {1} )


        [ Killed ]
        Arg = "Arkshine<1><STEAM_0:0:123456><TERRORIST>" killed "Fragnatic<3><BOT><TERRORIST>" with "mp5navy"

                Arg {0} = Arkshine<1><STEAM_0:0:123456><TERRORIST>
                Arg {1} = killed
                Arg {2} = Fragnatic<3><BOT><TERRORIST>
                Arg {3} = with
                Arg {4} = mp5navy

        Arg num = 5.
        Event len = 6. ( arg {1} )
    */