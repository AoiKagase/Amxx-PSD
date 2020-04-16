

    #include <amxmodx>
    #include <fakemeta>
    #include <weaponmod_stocks>
    #include <xs>

    #define Plugin  "WPN Crowbar"
    #define Version "1.0.0"
    #define Author  "Arkshine"


    #define MAX_DISTANCE 32
    
    
    /* - - -
     |  Weapon information   |
                       - - - */
        new
            gs_WpnName [] = "Crowbar",
            gs_WpnShort[] = "crowbar";

    /* - - -
     |  Weapon models  |
                 - - - */
        new
            gs_Model_P[] = "models/p_crowbar.mdl",
            gs_Model_V[] = "models/v_crowbar.mdl",
            gs_Model_W[] = "models/w_crowbar.mdl";

    /* - - -
     |  Crowbar sounds  |
                 - - - */
            new const
                gs_CrowbarHit1[]    = "weapons/cbar_hit1.wav",
                gs_CrowbarHit2[]    = "weapons/cbar_hit2.wav",
                gs_CrowbarHitbod1[] = "weapons/cbar_hitbod1.wav",
                gs_CrowbarHitbod2[] = "weapons/cbar_hitbod2.wav",
                gs_CrowbarHitbod3[] = "weapons/cbar_hitbod3.wav",
                gs_CrowbarMiss1[]   = "weapons/cbar_miss1.wav";

    /* - - -
     |    Sequence   |
               - - - */
        enum
        {
            crowbar_idle,
            crowbar_draw,
            crowbar_holster,
            crowbar_attack1hit,
            crowbar_attack1miss,
            crowbar_attack2miss,
            crowbar_attack2hit,
            crowbar_attack3miss,
            crowbar_attack3hit,
            crowbar_idle2,
            crowbar_idle3
        };
        
    /* - - -
     |  Custom fields  |
                 - - - */
        #define CB_TOUCH_STEP pev_iuser4
        #define CB_THINK_STEP pev_iuser3
        #define CB_OWNER      pev_iuser2
    
    /* - - -
     |    Others stuffs   |
                    - - - */
        #define MAX_CLIENTS   32
        #define HEAD_IN_WATER 3

        enum e_Coord
        {
            Float:x,
            Float:y,
            Float:z
        };

        enum
        {
            Swing = 1,
            Smack
        }

        enum
        {
            BubbleThink = 1,
            SpinTouch,
            RemoveCrowbar
        }
        
        enum e_Trace
        {
            Line,
            Hull
        };
        
        enum t_LastTrace
        {
            Hit,
            EndPos[ e_Coord ]
        }

        new gt_LastTrace[ MAX_CLIENTS + 1 ][ t_LastTrace ];
        
        new const Float:gvf_DuckHullMin[ e_Coord ] = { -16.0, -16.0, -18.0 };
        new const Float:gvf_DuckHullMax[ e_Coord ] = {  16.0,  16.0,  18.0 };

        new Float:gf_NextAttack    [ MAX_CLIENTS + 1 ];
        new Float:gf_NextThink     [ MAX_CLIENTS + 1 ];
        new Float:gf_TimeWeaponIdle[ MAX_CLIENTS + 1 ];
        
        new bool:gb_IsConnected[ MAX_CLIENTS + 1 ];
        
        new gi_StepThink           [ MAX_CLIENTS + 1 ];
        new gi_Swing               [ MAX_CLIENTS + 1 ];
        new gi_CrowbarLastIndex    [ MAX_CLIENTS + 1 ];

        new gi_Weaponid;
        new gi_MaxClients;
        new gi_CrowbarClass;
        new gi_Bubbles;
        
        new const gs_CrowbarClassname[] = "wpn_crowbar";


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
        precache_sound ( gs_CrowbarHit1 );
        precache_sound ( gs_CrowbarHit2 );
        precache_sound ( gs_CrowbarHitbod1 );
        precache_sound ( gs_CrowbarHitbod2 );
        precache_sound ( gs_CrowbarHitbod3 );
        precache_sound ( gs_CrowbarMiss1 );
        
        // -- Sprite
        gi_Bubbles  = precache_model ( "sprites/bubble.spr" );
    }
    

    public plugin_init ()
    {
        register_plugin ( Plugin, Version, Author );
        register_cvar ( "wpn_cbar_version", Version, FCVAR_SERVER | FCVAR_SPONLY );
        
        register_forward ( FM_Think, "fwd_Think" );
        register_forward ( FM_Touch, "fwd_Touch" );
        register_forward ( FM_PlayerPreThink, "fwd_PlayerPreThink" );
    }


    public plugin_cfg ()
    {
        gi_CrowbarClass = engfunc ( EngFunc_AllocString, "info_target" );
        gi_MaxClients   = global_get ( glb_maxClients );
        
        CreateWeapon ();
    }


    public client_putinserver ( id )
    {
        gb_IsConnected[ id ] = true;
        gf_NextAttack [ id ] = 0.0;
        gf_NextThink  [ id ] = -1.0;
        gi_StepThink  [ id ] = 0;
        gi_Swing      [ id ] = 0;
    }

    
    public client_disconnect ( id )
    {
        gb_IsConnected[ id ] = false;
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

        wpn_register_event ( i_Weapon_id, event_attack1, "Crowbar_PrimaryAttack" );
        wpn_register_event ( i_Weapon_id, event_attack2, "Crowbar_SecondaryAttack" );
        wpn_register_event ( i_Weapon_id, event_draw   , "Crowbar_Deploy"  );
        wpn_register_event ( i_Weapon_id, event_hide   , "Crowbar_Holster" );

        wpn_set_float ( i_Weapon_id, wpn_refire_rate1, 0.25 );
        wpn_set_float ( i_Weapon_id, wpn_run_speed, 250.0 );

        wpn_set_integer ( i_Weapon_id, wpn_cost, 1250 );

        gi_Weaponid = i_Weapon_id;
    }


    public Crowbar_PrimaryAttack ( id )
    {
        static Float:f_Time; f_Time = get_gametime ();
    
        if ( gf_NextAttack[ id ] > f_Time )
        {
            return PLUGIN_HANDLED;
        }

        if ( !Crowbar_Swing ( id, true ) )
        {
            gi_StepThink[ id ] = Swing;
            gf_NextThink[ id ] = f_Time + 0.2;
        }
        
        gf_TimeWeaponIdle[ id ] = f_Time + 1.0;

        return PLUGIN_CONTINUE;
    }
   
   
    public Crowbar_SecondaryAttack ( id )
    {
        static Float:f_Time; f_Time = get_gametime ();
    
        if ( gf_NextAttack[ id ] > f_Time )
        {
            return PLUGIN_HANDLED;
        }
        
        if ( pev ( id, pev_waterlevel ) == HEAD_IN_WATER )
        {
            return PLUGIN_HANDLED;
        }

        static Float:vf_Source[ e_Coord ], Float:vf_Right[ e_Coord ];
        static Float:vf_Dir[ e_Coord ], Float:vf_Ang[ e_Coord ];
        
        GetGunPosition ( id, vf_Source );
        
        global_get ( glb_v_right  , vf_Right );
        global_get ( glb_v_forward, vf_Dir );
        
        vf_Source[ x ] = vf_Source[ x ] + vf_Right[ x ] * 8 + vf_Dir[ y ] * 16;
        vf_Source[ y ] = vf_Source[ y ] + vf_Right[ y ] * 8 + vf_Dir[ y ] * 16;
        vf_Source[ z ] = vf_Source[ z ] + vf_Right[ z ] * 8 + vf_Dir[ z ] * 16;
        
        engfunc ( EngFunc_VecToAngles, vf_Dir, vf_Ang );
        vf_Ang[ z ] = vf_Dir[ z ] - 90;
        
        if ( FlyingCrowbar_Create ( id, vf_Source ) )
        {
            FlyingCrowbar_Spawn ( id, vf_Dir, vf_Ang );
        }
        
        return PLUGIN_CONTINUE;
    }

    
    public fwd_Think ( i_Ent )
    {
        if ( pev_valid ( i_Ent ) && pev ( i_Ent, CB_THINK_STEP ) )
        {
            switch ( pev ( i_Ent, CB_THINK_STEP ) )
            {
                case BubbleThink   : FlyingCrowbar_BubbleThink ( i_Ent );
                case RemoveCrowbar : FlyingCrowbar_Removing ( i_Ent );
            }
            
        }
    }
    
    
    public fwd_Touch ( i_Ent, i_Other )
    {
        if ( pev_valid ( i_Ent ) && pev ( i_Ent, CB_TOUCH_STEP ) )
        {
            FlyingCrowbar_SpinTouch ( i_Ent, i_Other );
        }
    }
    
    
    FlyingCrowbar_Removing ( i_Ent )
    {
        set_pev ( i_Ent, pev_flags, FL_KILLME );
    }
    
    
    FlyingCrowbar_BubbleThink ( i_Ent )
    {
        client_print ( 0, print_chat, "HOUBA" );
        
        set_pev ( i_Ent, pev_owner, FM_NULLENT );
        set_pev ( i_Ent, pev_nextthink, get_gametime () + 0.25 );
    
        emit_sound ( i_Ent, CHAN_VOICE, gs_CrowbarMiss1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM + 20 );
        
        if ( pev ( i_Ent, pev_waterlevel ) )
        {
            static Float:vf_Origin[ e_Coord ]; pev ( i_Ent, pev_origin, vf_Origin );
            static Float:vf_Velocity[ e_Coord ]; pev ( i_Ent, pev_velocity, vf_Velocity );
        
            VectorMS ( vf_Origin, 0.1, vf_Velocity, vf_Velocity );
            FX_BubbleTrail ( vf_Velocity, vf_Origin, 1 );
        }
    }
    
    
    FlyingCrowbar_SpinTouch ( i_Ent, i_Other )
    {
        static Float:f_TakeDamage; pev ( i_Other, pev_takedamage, f_TakeDamage );
    
        if ( f_TakeDamage != DAMAGE_NO )
        {
            new i_Owner = pev ( i_Ent, CB_OWNER );
            wpn_damage_user ( gi_Weaponid, i_Other, gb_IsConnected[ i_Owner ] ? i_Owner : i_Other, 0, 90, DMG_NEVERGIB );
        }
        
        static Float:vf_Origin[ e_Coord ]; 
        pev ( i_Ent, pev_origin, vf_Origin );
            
        if ( IsPlayer ( i_Other ) )
        {
            emit_sound ( i_Ent, CHAN_WEAPON, gs_CrowbarHitbod1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        }
        else
        {
            emit_sound ( i_Ent, CHAN_WEAPON, gs_CrowbarHit1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
            
            if ( engfunc ( EngFunc_PointContents, vf_Origin ) != CONTENTS_WATER )
            {
                FX_Sparks ( vf_Origin );
                FX_Sparks ( vf_Origin );
                FX_Sparks ( vf_Origin );
            }
        }
        
        static Float:vf_Angles[ e_Coord ], Float:vf_Velocity[ e_Coord ];
        
        pev ( i_Ent, pev_angles, vf_Angles );
        pev ( i_Ent, pev_velocity, vf_Velocity );
        
        vf_Angles[ x ] = vf_Angles[ z ] = 0.0;
        set_pev ( i_Ent, pev_angles, vf_Angles );
        
        xs_vec_normalize ( vf_Velocity, vf_Velocity );
        VectorMA ( vf_Origin, 100.0, vf_Velocity, vf_Velocity );
        
        engfunc ( EngFunc_TraceLine, vf_Origin, vf_Velocity, DONT_IGNORE_MONSTERS, i_Ent, 0 );
        
        static Float:vf_PlaneNormal[ e_Coord ]; get_tr2 ( 0, TR_vecPlaneNormal, vf_PlaneNormal );
        xs_vec_mul_scalar ( vf_PlaneNormal, 300.0, vf_PlaneNormal );
        
        set_pev ( i_Ent, pev_velocity, vf_PlaneNormal );
        
        set_pev ( i_Ent, pev_nextthink, get_gametime () + 3.0 );
        
    }
    
    
    FX_Sparks ( const Float:vf_Origin[] )
    {
        message_begin_f ( MSG_PVS, SVC_TEMPENTITY, vf_Origin );
        write_byte ( TE_SPARKS );
        write_coord_f ( vf_Origin[ x ] );
        write_coord_f ( vf_Origin[ y ] );
        write_coord_f ( vf_Origin[ z ] );
        message_end ();
    }
    
    
    Float:GetWaterLevel ( const Float:vf_Position[], Float:f_Minz, Float:f_Maxz )
    {
        new Float:vf_MidUp[ e_Coord ];

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
    
    
    FlyingCrowbar_Create ( id, const Float:vf_Origin[] )
    {
        gi_CrowbarLastIndex[ id ] = engfunc ( EngFunc_CreateNamedEntity, gi_CrowbarClass );

        if ( !gi_CrowbarLastIndex[ id ] )
        {
            return FM_NULLENT;
        }
        
        set_pev ( gi_CrowbarLastIndex[ id ], pev_classname, gs_CrowbarClassname );
        set_pev ( gi_CrowbarLastIndex[ id ], pev_origin, vf_Origin );
        set_pev ( gi_CrowbarLastIndex[ id ], pev_angles, Float:{ 0.0, 0.0, 0.0 } );
        set_pev ( gi_CrowbarLastIndex[ id ], pev_owner, id );
        
        set_pev ( gi_CrowbarLastIndex[ id ], pev_movetype, MOVETYPE_TOSS );
        set_pev ( gi_CrowbarLastIndex[ id ], pev_solid, SOLID_BBOX );
        
        engfunc ( EngFunc_SetModel, gi_CrowbarLastIndex[ id ], gs_Model_W );
        
        engfunc ( EngFunc_SetSize, gi_CrowbarLastIndex[ id ], Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );
        engfunc ( EngFunc_SetOrigin, gi_CrowbarLastIndex[ id ], vf_Origin );
        
        set_pev ( gi_CrowbarLastIndex[ id ], CB_OWNER, id );
        set_pev ( gi_CrowbarLastIndex[ id ], CB_THINK_STEP, BubbleThink );
        set_pev ( gi_CrowbarLastIndex[ id ], pev_nextthink, get_gametime () + 0.25 );
        set_pev ( gi_CrowbarLastIndex[ id ], CB_TOUCH_STEP, SpinTouch );
        
        return gi_CrowbarLastIndex[ id ];
    }
    
    
    FlyingCrowbar_Spawn ( id, const Float:vf_Dir[], const Float:vf_Ang[] )
    {
        static Float:vf_Velocity[ e_Coord ];
        
        pev ( id, pev_velocity, vf_Velocity );
        VectorMA ( vf_Velocity, 500.0, vf_Dir, vf_Velocity );
    
        set_pev ( gi_CrowbarLastIndex[ id ], pev_velocity, vf_Velocity );
        set_pev ( gi_CrowbarLastIndex[ id ], pev_angles, vf_Ang );
        set_pev ( gi_CrowbarLastIndex[ id ], pev_avelocity, Float:{ -1000.0, 0.0 ,0.0 } );
        set_pev ( gi_CrowbarLastIndex[ id ], pev_gravity, 0.5 );
        
        emit_sound ( gi_CrowbarLastIndex[ id ], CHAN_WEAPON, gs_CrowbarMiss1, VOL_NORM, ATTN_NORM, 0, 94 + random_num ( 0, 15 ) );
        
        gf_NextAttack[ id ] = get_gametime () + 0.5;
        
        switch ( ( ( gi_Swing[ id ]++ ) % 2 ) + 1 )
        {
            case 0 : Crowbar_SetAnimation ( id, crowbar_attack1hit );
            case 1 : Crowbar_SetAnimation ( id, crowbar_attack1hit );
            case 2 : Crowbar_SetAnimation ( id, crowbar_draw );
        }
    }
    

    public Crowbar_Deploy ( id )
    {
        Crowbar_SetAnimation ( id, crowbar_draw );
    }


    public Crowbar_Holster ( id )
    {
        gf_NextAttack[ id ] = get_gametime () + 0.5;
        Crowbar_SetAnimation ( id, crowbar_holster );
    }


    public fwd_PlayerPreThink ( id )
    {
        if ( !is_user_alive ( id ) )
        {
            return FMRES_IGNORED;
        }
        
        if ( wpn_uses_weapon( id, gi_Weaponid ) )
        {
            WeaponIdle ( id );
        }
    
        if ( gf_NextThink[ id ] != -1.0 && is_user_alive ( id ) && gf_NextThink[ id ] < get_gametime () )
        {   
            gf_NextThink[ id ] = -1.0;
                
            switch ( gi_StepThink[ id ] )
            {
                case Swing : Crowbar_Swing ( id, false );
                case Smack : Crossbow_DecalTrace ( id );
            }
        }
        
        return FMRES_IGNORED;
    }

    
    Crowbar_Swing ( id, bool:b_First )
    {
        static Float:vf_Source[ e_Coord ], Float:vf_End[ e_Coord ];
        static Float:f_Fraction, bool:b_DidHit, tr, i_Hit;
       
        b_DidHit = false;

        if ( !IsCrowbarTouching ( id, e_Trace:Line, MAX_DISTANCE, vf_Source, vf_End, tr ) )
        {
            if ( IsCrowbarTouching ( id, e_Trace:Hull, HULL_HEAD, vf_Source, vf_End, tr ) )
            {
                if ( !Instance ( get_tr2 ( tr, TR_pHit ) ) || IsBSPModel ( id ) )
                {
                    Crowbar_FindHullIntersection ( vf_Source, tr, gvf_DuckHullMin, gvf_DuckHullMax, id );
                }

                get_tr2 ( tr, TR_vecEndPos, vf_End );
            }
        }
        
        get_tr2 ( tr, TR_flFraction, f_Fraction );
        
        emit_sound ( id, CHAN_WEAPON, gs_CrowbarMiss1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        Crowbar_SetAnimation ( id, crowbar_attack1miss, 1 );

        switch ( ( gi_Swing[ id ]++ ) % 3 )
        {
            case 0 : Crowbar_SetAnimation ( id, crowbar_attack1miss, 1 );
            case 1 : Crowbar_SetAnimation ( id, crowbar_attack2miss, 1 );
            case 2 : Crowbar_SetAnimation ( id, crowbar_attack3miss, 1 );
        }
            
        if ( f_Fraction >= 1.0 )
        {
            if ( b_First )
            {
                gf_NextAttack[ id ] = get_gametime () + 0.5;
                // -- Player shoot animation
            }
        }
        else
        {
            switch ( ( ( gi_Swing[ id ]++ ) % 2 ) + 1 )
            {
                case 0 : Crowbar_SetAnimation ( id, crowbar_attack1hit );
                case 1 : Crowbar_SetAnimation ( id, crowbar_attack2hit );
                case 2 : Crowbar_SetAnimation ( id, crowbar_attack3hit );
            }

            // -- Player shoot animation

            static Float:vf_Origin[ e_Coord ], bool:b_HitPlayer, bool:b_FirstSwing;
            
            b_DidHit = true;
            i_Hit = Instance ( get_tr2 ( tr, TR_pHit ) );
            
            b_HitPlayer  = IsPlayer ( i_Hit ) ? true : false;
            b_FirstSwing = gf_NextAttack[ id ] + 1.0 < get_gametime () ? true : false;

            if ( b_HitPlayer ) 
            {
                pev ( i_Hit, pev_origin, vf_Origin );
                
                wpn_damage_user ( gi_Weaponid, i_Hit, id, 0, b_FirstSwing ? 10 : 10 / 2, DMG_CLUB );
                wpn_create_blood ( vf_Origin, i_Hit, b_FirstSwing ? 10 * 2 : ( 10 / 2 ) * 2 );
                
                switch ( random_num ( 0, 2 ) )
                {
                    case 0 : emit_sound ( id, CHAN_ITEM, gs_CrowbarHitbod1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                    case 1 : emit_sound ( id, CHAN_ITEM, gs_CrowbarHitbod2, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                    case 2 : emit_sound ( id, CHAN_ITEM, gs_CrowbarHitbod3, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                if ( !is_user_alive ( i_Hit ) )
                {
                    return true;
                }
            }
            else
            {
                if ( i_Hit != FM_NULLENT )
                {
                    static s_Classname[ 8 ];
                    pev ( i_Hit, pev_classname, s_Classname, charsmax ( s_Classname ) );
                    
                    if ( s_Classname[ 0 ] == 'f' && s_Classname[ 5 ] == 'b' && s_Classname[ 6 ] == 'r' )
                    {
                        dllfunc ( DLLFunc_Use, i_Hit, id );
                    }
                }
   
                switch ( random_num ( 0, 1 ) )
                {
                    case 0 : emit_sound ( id, CHAN_ITEM, gs_CrowbarHit1, VOL_NORM, ATTN_NORM, 0, 98 + random_num ( 0, 3 ) );
                    case 1 : emit_sound ( id, CHAN_ITEM, gs_CrowbarHit2, VOL_NORM, ATTN_NORM, 0, 98 + random_num ( 0, 3 ) );
                }

                gt_LastTrace[ id ][ Hit ] = i_Hit;
            }

            gi_StepThink[ id ] = Smack;
            gf_NextThink[ id ] = get_gametime () + 0.2;
        }

        return b_DidHit;
    }


    Crowbar_FindHullIntersection ( const Float:vf_Source[], &tr, const Float:vf_Min[],  const Float:vf_Max[], index )
    {
        static Float:vf_HullEnd[ e_Coord ], Float:vf_End[ e_Coord ], Float:vf_MinMaxs[ 2 ][ e_Coord ];
        static Float:f_Distance, Float:f_Fraction;
        static i, j, k, i_TmpTrace;

        get_tr2 ( tr, TR_vecEndPos, vf_HullEnd );
        f_Distance = 1000000.0;

        xs_vec_copy ( vf_Min, vf_MinMaxs[ 0 ] );
        xs_vec_copy ( vf_Max, vf_MinMaxs[ 1 ] );
        
        xs_vec_sub ( vf_HullEnd, vf_Source, vf_HullEnd );
        VectorMA ( vf_Source, 2.0, vf_HullEnd, vf_HullEnd );

        engfunc( EngFunc_TraceLine, vf_Source, vf_End, DONT_IGNORE_MONSTERS, index, i_TmpTrace );
        get_tr2 ( i_TmpTrace, TR_flFraction, f_Fraction );

        if ( f_Fraction < 1.0 )
        {
            tr = i_TmpTrace;
            return;
        }

        for ( i = 0; i < 2; i++ )
        {
            for ( j = 0; j < 2; j++ )
            {
                for ( k = 0; k < 2; k++ )
                {
                    vf_End[ x ] = vf_HullEnd[ x ] + vf_MinMaxs[ i ][ x ];
                    vf_End[ y ] = vf_HullEnd[ y ] + vf_MinMaxs[ j ][ y ];
                    vf_End[ z ] = vf_HullEnd[ z ] + vf_MinMaxs[ k ][ z ];

                    engfunc( EngFunc_TraceLine, vf_Source, vf_End, DONT_IGNORE_MONSTERS, index, i_TmpTrace );
                    get_tr2 ( i_TmpTrace, TR_flFraction, f_Fraction );

                    if ( f_Fraction < 1.0 )
                    {
                        static Float:f_ThisDistance, Float:vf_EndPos[ e_Coord ];

                        get_tr2 ( i_TmpTrace, TR_vecEndPos, vf_EndPos );
                        xs_vec_sub ( vf_EndPos, vf_Source, vf_EndPos );

                        f_ThisDistance = xs_vec_len ( vf_EndPos );

                        if ( f_ThisDistance > f_Distance )
                        {
                            tr = i_TmpTrace;
                            return;
                        }
                    }
                }
            }
        }
    }

    
    Crossbow_DecalTrace ( id )
    {
        if ( IsValidEntity ( gt_LastTrace[ id ][ Hit ] ) )
        {
            message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
            write_byte ( TE_WORLDDECAL );
            write_coord_f ( gt_LastTrace[ id ][ EndPos ][ x ] );
            write_coord_f ( gt_LastTrace[ id ][ EndPos ][ y ] );
            write_coord_f ( gt_LastTrace[ id ][ EndPos ][ z ] );
            write_byte ( wpn_gi_get_gunshot_decal() );
            message_end ();
        }
    }
    
    
    WeaponIdle ( id )
    {
        static Float:f_Time; f_Time = get_gametime ();
        static Float:f_Rand;

        if ( gf_TimeWeaponIdle[ id ] > f_Time )
        {
            return;
        }

        f_Rand = random_float ( 0.0, 1.0 );
        
        if ( f_Rand <= 0.25 )
        {
            wpn_playanim ( id, crowbar_idle );
            gf_TimeWeaponIdle[ id ] = f_Time + random_float ( 10.0, 15.0 );
        }
        else if ( f_Rand <= 0.75 )
        {
            wpn_playanim ( id, crowbar_idle2 );
            gf_TimeWeaponIdle[ id ] = f_Time + random_float ( 10.0, 15.0 );
        }
        else
        {
            wpn_playanim ( id, crowbar_idle3 );
            gf_TimeWeaponIdle[ id ] = f_Time + random_float ( 10.0, 15.0 );
        }
    }
    
    
    bool:IsValidEntity ( i_Ent )
    {
        return !( pev ( i_Ent, pev_flags ) & FL_KILLME ) && ( pev ( i_Ent, pev_solid ) == SOLID_BSP || pev ( i_Ent, pev_movetype ) == MOVETYPE_PUSHSTEP ) ? true : false;
    }
    
    
    bool:IsCrowbarTouching ( id, e_Trace:i_Type, i_Distance, Float:vf_Source[], Float:vf_End[], &tr )
    {
        static Float:f_Fraction;
        
        switch ( i_Type )
        {
            case Line :
            {
                GetAimOrigin ( id, vf_Source, float ( i_Distance ), vf_End );
                engfunc( EngFunc_TraceLine, vf_Source, vf_End, DONT_IGNORE_MONSTERS, id, tr );
            }
            case Hull :
            {
                engfunc ( EngFunc_TraceHull, vf_Source, vf_End, DONT_IGNORE_MONSTERS, i_Distance, id, tr );
            }
        }
        
        get_tr2 ( tr, TR_flFraction, f_Fraction );
       
        if ( f_Fraction >= 1.0 )
        {
            return false;
        }
        
        get_tr2 ( tr, TR_vecEndPos, gt_LastTrace[ id ][ EndPos ] );

        return true;
    }
    
    
    Crowbar_SetAnimation ( id, i_Anim, i_Body = -1 )
    {
        if ( i_Body != -1 )
        {
            set_pev ( id, pev_body, i_Body );
        }
        
        wpn_playanim ( id, i_Anim );
    }
    
    
    GetAimOrigin ( id, Float:vf_Origin[], const Float:f_Distance, Float:vf_End[] )
    {
        GetGunPosition ( id, vf_Origin );
        pev ( id, pev_v_angle, vf_End );

        engfunc ( EngFunc_MakeVectors, vf_End );
        global_get ( glb_v_forward, vf_End );
        
        xs_vec_mul_scalar ( vf_End, f_Distance, vf_End );
        xs_vec_add ( vf_Origin, vf_End, vf_End );
    }
    

    GetGunPosition ( id, Float:vf_Origin[] )
    {
        static Float:vf_ViewOfs[3];

        pev ( id, pev_origin, vf_Origin );
        pev ( id, pev_view_ofs, vf_ViewOfs );

        xs_vec_add ( vf_Origin, vf_ViewOfs, vf_Origin );
    }


    IsBSPModel ( index )
    {
        return pev ( index, pev_solid ) == SOLID_BSP || pev ( index, pev_movetype ) == MOVETYPE_PUSHSTEP;
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


    Instance ( i_Target )
    {
        if ( i_Target == -1 )
        {
            return 0;
        }

        return i_Target;
    }
    

    bool:IsPlayer ( id )
    {
        if ( 1 <= id <= gi_MaxClients )
        {
            return true;
        }

        return false;
    }