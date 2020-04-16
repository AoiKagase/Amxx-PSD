
    #include <amxmodx>
    #include <fakemeta>
    #include <weaponmod_stocks>
    #include <xs>

    #define Plugin  "WPN Claymore"
    #define Version "1.0.0"
    #define Author  "Arkshine"


    /* - - -
     |  Weapon information   |
                       - - - */
        new
            gs_WpnName [] = "Claymore",
            gs_WpnShort[] = "claymore";
            
            
    /* - - -
     |  Weapon models  |
                 - - - */
        new
            gs_Model_P[] = "models/p_claymore.mdl",
            gs_Model_V[] = "models/v_claymore.mdl",
            gs_Model_W[] = "models/w_claymore.mdl";
            
    /* - - -
     |    Sequence   |
               - - - */
        enum
        {
            claymore_idle,
            claymore_draw,
            claymore_plant,
        };

    /* - - -
     |    Others stuffs   |
                    - - - */
        #define MAX_CLIENTS 32

        enum e_Coord
        {
            Float:x,
            Float:y,
            Float:z
        };
        
        new gi_Weaponid;
        new gi_MaxClients;

        
    public plugin_precache ()
    {
        // -- Weapon models
        precache_model ( gs_Model_P );
        precache_model ( gs_Model_V );
        precache_model ( gs_Model_W );
    }
    

    public plugin_init ()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_cl_version", Version, FCVAR_SERVER | FCVAR_SPONLY );
    }
    
    
    public plugin_cfg ()
    {
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

        wpn_register_event ( i_Weapon_id, event_attack1, "Claymore_PrimaryAttack" );
        wpn_register_event ( i_Weapon_id, event_draw   , "Claymore_Deploy"  );

        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, 0.25 );
        wpn_set_float ( i_Weapon_id, wpn_run_speed, 250.0 );

        wpn_set_integer ( i_Weapon_id, wpn_ammo1, 10 );
        wpn_set_integer ( i_Weapon_id, wpn_cost, 1250 );

        gi_Weaponid = i_Weapon_id;
    }
    
    
    public Claymore_PrimaryAttack ( id )
    {
        wpn_playanim ( id, claymore_plant );
    }
    
    
    public Claymore_Deploy ( id )
    {
        wpn_playanim ( id, claymore_draw );
    }
    

    
    
    