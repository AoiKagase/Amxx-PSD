#include <amxmodx>
#include <fakemeta>
#include <weaponmod>
#include <weaponmod_stocks>
#include <xs>
#include <cstrike>
#include <amxmisc> 
// Plugin information
new const PLUGIN[]	= "WPN C-24 EM Sniper Rifle ( DC )";
new const VERSION[]	= "0.1";
new const AUTHOR[]	= "SandStriker";

// Weapon information
new
	g_WPN_NAME[]	= "C-24 EM Sniper Rifle",
	g_WPN_SHORT[]	= "emsniper";

// Models
new
	g_P_MODEL[]	= "models/p_emsniper.mdl",
	g_V_MODEL[]	= "models/v_emsniper.mdl",
	g_W_MODEL[]	= "models/w_emsniper.mdl";
	
// Sounds
new g_SOUND[][] = 
{
	"weapons/prldi.wav",
	"weapons/prlprl.wav"
};

new g_SPRITE[][] = 
{
	"sprites/prlend.spr",
	"sprites/prltrail.spr"
};

enum {
	ems_idle1,
	ems_idle2,
	ems_idle3,
	ems_holster,
	ems_draw,
	ems_fire,
	ems_reload
};

#define EMS_SHAKEFORCE		3.5
#define EMS_REFIRERATE		1.8
#define EMS_RUNSPEED		180.0
#define EMS_CLIPAMMO		1
#define EMS_MAXMAMMO		24
#define EMS_COST		6400
#define EMS_DMGMAX		120
#define EMS_DMGMIN		60

//---------------------------------
#define EMS_RELOADTIME		3.18
#define EMS_BULLETPERSHOT	1

new
	g_wpnid,// g_MaxPlayers,
        	
	g_beam,g_glow;

public plugin_precache() 
{
	precache_model(g_P_MODEL);
	precache_model(g_V_MODEL);
	precache_model(g_W_MODEL);
	g_glow = precache_model(g_SPRITE[0]);
	g_beam = precache_model(g_SPRITE[1]);
	precache_sound(g_SOUND[0]);
	precache_sound(g_SOUND[1]);
	return PLUGIN_CONTINUE;
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	return PLUGIN_CONTINUE;
}

public plugin_cfg()
{
	create_weapon();
	return PLUGIN_CONTINUE;
}

create_weapon() {
	new wpnid = wpn_register_weapon(g_WPN_NAME, g_WPN_SHORT);
	if(wpnid == -1) return PLUGIN_CONTINUE;
	
	// Strings
	wpn_set_string(wpnid,wpn_viewmodel,	g_V_MODEL);
	wpn_set_string(wpnid,wpn_weaponmodel,	g_P_MODEL);
	wpn_set_string(wpnid,wpn_worldmodel,	g_W_MODEL);
	
	// Event handlers
	wpn_register_event(wpnid,event_attack1,		"ev_attack1");
	wpn_register_event(wpnid,event_attack2,		"ev_attack2");
	wpn_register_event(wpnid,event_draw,		"ev_draw");
	wpn_register_event(wpnid,event_reload,		"ev_reload");
	wpn_register_event(wpnid,event_hide,		"ev_holsdrop");
	

	// Floats
	wpn_set_float(wpnid,wpn_refire_rate1,		EMS_REFIRERATE);
	wpn_set_float(wpnid,wpn_run_speed,		EMS_RUNSPEED);
	wpn_set_float(wpnid,wpn_reload_time,		EMS_RELOADTIME);
	//wpn_set_float(wpnid,wpn_recoil1,		EMS_RECOIL);
	
	// Integers
	wpn_set_integer(wpnid,wpn_ammo1,		EMS_CLIPAMMO);
	wpn_set_integer(wpnid,wpn_ammo2,		EMS_MAXMAMMO);
	wpn_set_integer(wpnid,wpn_bullets_per_shot1,	EMS_BULLETPERSHOT);
	wpn_set_integer(wpnid,wpn_cost,			EMS_COST);
	
	g_wpnid = wpnid;
	return PLUGIN_CONTINUE;
}

public ev_attack1(id)
{
	wpn_playanim(id, ems_fire);
	emit_sound(id, CHAN_WEAPON, g_SOUND[0], 1.0, ATTN_NORM, 0, PITCH_NORM);
	RecoilControl(id);

	new Float:origin[3],Float:target[3],Float:TraceBEnd[3];
	pev(id,pev_origin,origin);
	wpn_projectile_startpos(id,50,8,10,origin);
	velocity_by_aim( id, 128, target );
	xs_vec_add( target, origin, target );


	TraceEnd(id,origin,target,TraceBEnd);

	DrawLaser(origin,TraceBEnd);
	wpn_bullet_shot(g_wpnid,id,0,random_num(EMS_DMGMIN,EMS_DMGMAX));
	
	return PLUGIN_CONTINUE;
}


public client_connect(id) { 
     cs_get_user_zoom(id,CS_SET_NO_ZOOM,1); 
} 


public ev_attack2(id)
{
	switch(cs_get_user_zoom(id)) {
    case 0: return PLUGIN_HANDLED;
    case CS_SET_NO_ZOOM: cs_set_user_zoom(id, CS_SET_FIRST_ZOOM, 1); //see excerpt from cstrike below for info on this native
    case CS_SET_FIRST_ZOOM: cs_set_user_zoom(id, CS_SET_SECOND_ZOOM, 1);
    case CS_SET_SECOND_ZOOM: cs_set_user_zoom(id, CS_SET_NO_ZOOM, 1);
    default: return PLUGIN_HANDLED;
}

	return PLUGIN_CONTINUE;
}
RecoilControl(id)
{
	static Float:RecoilShake[3];

	RecoilShake[0] = random_float(EMS_SHAKEFORCE, 0.0);
	RecoilShake[1] = random_float(EMS_SHAKEFORCE, 0.0);
	RecoilShake[2] = 0.0
	set_pev(id, pev_punchangle, RecoilShake);
}






public ev_reload (id) {
	wpn_playanim (id ,ems_reload)
	emit_sound(id, CHAN_ITEM,g_SOUND[1],1.0,ATTN_NORM,0,PITCH_NORM);
	return PLUGIN_CONTINUE;
}

public ev_holsdrop(id)
{
	wpn_playanim(id,ems_holster);
	cs_get_user_zoom(id,CS_SET_NO_ZOOM,1);
	return PLUGIN_CONTINUE;
}

public ev_draw(id)
{
	wpn_playanim(id,ems_draw);
	cs_get_user_zoom(id,CS_SET_NO_ZOOM,1);
	return PLUGIN_CONTINUE;
}

DrawLaser(const Float:v_Origin[3], const Float:v_EndOrigin[3])
{

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord, v_Origin[0]);
	engfunc(EngFunc_WriteCoord, v_Origin[1]);
	engfunc(EngFunc_WriteCoord, v_Origin[2]);
	engfunc(EngFunc_WriteCoord, v_EndOrigin[0]);
	engfunc(EngFunc_WriteCoord, v_EndOrigin[1]);
	engfunc(EngFunc_WriteCoord, v_EndOrigin[2]);
	write_short(g_beam);
	write_byte(1);
	write_byte(0);
	write_byte(1);
	write_byte(30); 
	write_byte(1);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(200);
	write_byte(0);
	message_end();
	
	message_begin(MSG_PVS, SVC_TEMPENTITY);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, v_EndOrigin[0]);
	engfunc(EngFunc_WriteCoord, v_EndOrigin[1]);
	engfunc(EngFunc_WriteCoord, v_EndOrigin[2]);
	write_short(g_glow); 
	write_byte(5);
	write_byte(200);
	message_end();

}

TraceEnd(id,const Float:origin[3],const Float:target[3],Float:TraceEndPos[3])
{
	engfunc(EngFunc_TraceLine, origin, target, DONT_IGNORE_MONSTERS, id, 0);
	get_tr2( 0, TR_vecEndPos, TraceEndPos);
}