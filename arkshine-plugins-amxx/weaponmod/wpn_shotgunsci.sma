    
    #include <amxmodx>
    #include <fakemeta>
    #include <weaponmod>
    #include <xs>

        new const
    // __________________________________________________

            Plugin [] = "WPN Shotgun Scientist",
            Version[] = "1.0.0",
            Author [] = "Arkshine";
    // __________________________________________________
    
    
    /* - - - 
     |  Weapon information   |
                       - - - */
        new
            g_sWpnName [] = "Shotgun Scientist",
            g_sWpnShort[] = "shotgunsci";

    /* - - -
     |  Weapon model   |
                 - - - */
        new
            g_sModel_P[] = "models/p_shotgun.mdl",
            g_sModel_V[] = "models/v_shotgun.mdl",
            g_sModel_W[] = "models/w_shotgun.mdl";
        
        /* new const
            g_sScientist [] = "models/shotgunsci.mdl",
            g_sScientistt[] = "models/shotgunscit.mdl"; */

    /* - - -
     |  Weapon sound   |
                 - - - */
        new const
            g_sDoubleShootSound [] = "weapons/dbarrel1.wav",
            g_sSimpleChargeSound[] = "weapons/sbarrel1.wav",
            
            g_sReloadSound1[] = "weapons/reload1.wav",
            g_sReloadSound2[] = "weapons/reload3.wav";

    /* - - -
     |  Entity data   |
                - - - */
        new const
            g_sEntityName[]  = "wpn_shotgunsci";

    /* - - -
     |    Sequence   |
               - - - */
        enum 
        {
            shotgun_idle,
            shotgun_fire,
            shotgun_fire2,
            shotgun_reload,
            shotgun_pump,
            shotgun_start_reload,
            shotgun_draw,
            shotgun_holster,
            shotgun_idle4,
            shotgun_idle_deep
        };
        
        
    new g_iWeapon_id;
    

    public plugin_precache()
    {
        // -- Weapon models
        precache_model( g_sModel_P );
        precache_model( g_sModel_V );
        precache_model( g_sModel_W );
        
        // -- Scientist model
        precache_model( "models/scientist.mdl" );
       // precache_model( g_sScientistt );

        // -- Weapon sounds ( shoot )
        precache_sound( g_sDoubleShootSound );
        precache_sound( g_sSimpleChargeSound );
        
        // -- Weapon sounds ( reload )
        precache_sound( g_sReloadSound1 );
        precache_sound( g_sReloadSound2 );
    }
    
    
    public plugin_init()
    {
        register_plugin( Plugin, Version, Author );
    }
    
    
    public plugin_cfg()
    {
        CreateWeapon();
    }
    
    
    CreateWeapon()
    {
        new iWeapon_id = wpn_register_weapon( g_sWpnName, g_sWpnShort );

        if( iWeapon_id == -1 )
            return;

        // -- Weapon models.
        wpn_set_string( iWeapon_id, wpn_weaponmodel, g_sModel_P );
        wpn_set_string( iWeapon_id, wpn_viewmodel  , g_sModel_V );
        wpn_set_string( iWeapon_id, wpn_weaponmodel, g_sModel_W );

        // -- Events.
        wpn_register_event( iWeapon_id, event_attack1, "EV_Attack1" );
        wpn_register_event( iWeapon_id, event_reload , "EV_Reload"  );
        wpn_register_event( iWeapon_id, event_draw   , "EV_Draw"    );

        // -- Float.
        wpn_set_float( iWeapon_id, wpn_refire_rate1, 0.75 );
        wpn_set_float( iWeapon_id, wpn_reload_time , 0.50 );
        wpn_set_float( iWeapon_id ,wpn_recoil1, 5.0 );

        // -- Integer.
        wpn_set_integer( iWeapon_id, wpn_ammo1, 5 );
        wpn_set_integer( iWeapon_id, wpn_ammo2, 10 );
        wpn_set_integer( iWeapon_id, wpn_bullets_per_shot1, 1 );
        wpn_set_integer( iWeapon_id, wpn_bullets_per_shot2, 0 );
        wpn_set_integer( iWeapon_id, wpn_cost, 1000 );

        g_iWeapon_id = iWeapon_id;
    }
    
    
    public EV_Attack1( id )
    {
        wpn_playanim( id, shotgun_fire );
        ShootScientist( id );
    }
    
    
    public EV_Reload( id )
    {
        wpn_playanim( id, shotgun_reload );
    }
    
    
    public EV_Draw( id )
    {
        wpn_playanim( id, shotgun_draw );
    }
    
    
    ShootScientist( id )
    {
        new iScientist = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
        
        if( !iScientist )
            return;
        
        // -- Strings
        set_pev( iScientist, pev_classname, g_sEntityName );
        engfunc( EngFunc_SetModel, iScientist, "models/scientist.mdl" );
        
        // -- Integer
        set_pev( iScientist, pev_owner, id );
        set_pev( iScientist, pev_movetype, MOVETYPE_FLY );
        set_pev( iScientist, pev_solid, SOLID_BBOX );
        
        // -- Floats
        set_pev( iScientist, pev_mins, Float:{ -36.0, -36.0, -36.0 } );
        set_pev( iScientist, pev_maxs, Float:{ 36.0, 36.0, 36.0 } );
        
        // -- Calculate start position...
        new Float:fAim[3], Float:fAngles[3];
        velocity_by_aim( id, 64, fAim );
        vector_to_angle( fAim, fAngles );
        
        // -- ... And view of the scientist
        new Float:fOrigin[3];
        pev( id, pev_origin, fOrigin );
        xs_vec_add( fOrigin, fAim, fOrigin );
    
        // -- Set the origin and view
        set_pev( iScientist, pev_origin, fOrigin );
        set_pev( iScientist, pev_angles, fAngles );
        
        // -- Calculate scientist flight speed
        new Float:fVel[3];
        velocity_by_aim( id, 800, fVel )
        set_pev( iScientist, pev_velocity, fVel );
        
         // -- Set scientist gravity
        set_pev ( iScientist, pev_gravity, 0.75 );
        set_pev ( iScientist, pev_sequence, 97 );
        set_pev ( iScientist, pev_animtime, get_gametime () );
        set_pev ( iScientist, pev_framerate, 1.0 );
    }
    
    
    