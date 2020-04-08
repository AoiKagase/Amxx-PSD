#pragma semicolon 1
//=============================================
//	Plugin Writed by Visual Studio Code.
//=============================================

// Supported BIOHAZARD.
// #define BIOHAZARD_SUPPORT

/*=====================================*/
/*  INCLUDE AREA				       */
/*=====================================*/
#include <amxmodx>
#include <amxmisc>

/*
What i want in the menu:
- Choise between blue, green, red, white laser...
- A "bind p +setlaser" button, so it is bind when you push that button
- A "bind j +delllaser" button, so it is bind when you push that button
- A help button (So you will be redirected to the "lasermine" help menu
- An admin menu

Some things for in the admin menu:
- Give peoples lasers
- Delete lasers from peoples
*/

/*=====================================*/
/*  MACRO AREA					       */
/*=====================================*/
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"0.1"

#if defined BIOHAZARD_SUPPORT
	#define PLUGIN 					"Lasermine Menu for BIOHAZARD"

	#define CHAT_TAG 				"[BioLaser]"
	#define CVAR_TAG				"bio_ltm"
#else
	#define PLUGIN 					"Laser/Tripmine Menu"

	#define CHAT_TAG 				"[Lasermine]"
	#define CVAR_TAG				"amx_ltm"
#endif

#define LMM_ADMIN_COMMON			"LMM_ADMIN_COMMON"
#define LMM_ADMIN_AMMO				"LMM_ADMIN_AMMO"
#define LMM_ADMIN_BUY				"LMM_ADMIN_BUY"
#define LMM_ADMIN_LASER				"LMM_ADMIN_LASER"
#define LMM_ADMIN_MINE				"LMM_ADMIN_MINE"
#define LMM_ADMIN_MISC				"LMM_ADMIN_MISC"
#define LMM_ADMIN_CVAR_ENABLE		"LMM_ADMIN_CVAR_ENABLE"
#define LMM_ADMIN_CVAR_ACCESS		"LMM_ADMIN_CVAR_ACCESS"
#define LMM_ADMIN_CVAR_MODE			"LMM_ADMIN_CVAR_MODE"
#define LMM_ADMIN_CVAR_FF			"LMM_ADMIN_CVAR_FF"
#define LMM_ADMIN_CVAR_ROUND_DELAY	"LMM_ADMIN_CVAR_ROUND_DELAY"
#define LMM_ADMIN_CVAR_CMD_MODE		"LMM_ADMIN_CVAR_CMD_MODE"
#define LMM_ADMIN_CVAR_ON			"LMM_ADMIN_CVAR_ON"
#define LMM_ADMIN_CVAR_OFF			"LMM_ADMIN_CVAR_OFF"
#define LMM_ADMIN_CVAR_ALL			"LMM_ADMIN_CVAR_ALL"
#define LMM_ADMIN_CVAR_ADMIN		"LMM_ADMIN_CVAR_ADMIN"
#define LMM_ADMIN_CVAR_LASERMINE	"LMM_ADMIN_CVAR_LASERMINE"
#define LMM_ADMIN_CVAR_TRIPMINE		"LMM_ADMIN_CVAR_TRIPMINE"
#define LMM_ADMIN_CVAR_USE			"LMM_ADMIN_CVAR_USE"
#define LMM_ADMIN_CVAR_BIND			"LMM_ADMIN_CVAR_BIND"
#define LMM_ADMIN_CVAR_EACH			"LMM_ADMIN_CVAR_EACH"
//
// CVAR SETTINGS
//
enum CVAR_SETTING
{
	// Common.
	CVAR_ENABLE				= 0,    // Plugin Enable.
	CVAR_ACCESS_LEVEL		,		// Access level for 0 = ADMIN or 1 = ALL.
	CVAR_MODE				,    	// 0 = Lasermine, 1 = Tripmine.
	CVAR_FRIENDLY_FIRE      ,   	// Friendly Fire.
	CVAR_START_DELAY        ,   	// Round start delay time.
	CVAR_CMD_MODE			,    	// 0 = +USE key, 1 = bind, 2 = each.

	// Ammo.
	CVAR_START_HAVE			,    	// Start having ammo.
	CVAR_MAX_HAVE			,    	// Max having ammo.
	CVAR_TEAM_MAX           ,    	// Max deployed in team.

	// Buy system.
	CVAR_BUY_MODE           ,   	// Buy mode. 0 = off, 1 = on.
	CVAR_CBT                ,   	// Can buy team. TR/CT/ALL
	CVAR_COST               ,    	// Buy cost.
	CVAR_BUY_ZONE           ,    	// Stay in buy zone can buy.
	CVAR_FRAG_MONEY         ,    	// Get money per kill.

	// Laser design.
	CVAR_LASER_VISIBLE      ,   	// Laser line Visiblity. 0 = off, 1 = on.
	CVAR_LASER_COLOR        ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_TR     ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_CT     ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_BRIGHT       ,   	// Laser line brightness.
	CVAR_LASER_DMG          ,    	// Laser hit Damage.
	CVAR_LASER_DMG_MODE     ,   	// Laser line damage mode. 0 = frame rate dmg, 1 = once dmg, 2 = 1second dmg.
	CVAR_LASER_DMG_DPS      ,   	// Laser line damage mode 2 only, damage/seconds. default 1 (sec)
	CVAR_LASER_RANGE		,		// Laserbeam range.

	// Mine design.
	CVAR_MINE_HEALTH        ,   	// Lasermine health. (Can break.)
	CVAR_MINE_GLOW          ,   	// Glowing tripmine.
	CVAR_MINE_GLOW_MODE     ,   	// Glowing color mode.
	CVAR_MINE_GLOW_TR    	,   	// Glowing color for T.
	CVAR_MINE_GLOW_CT     	,   	// Glowing color for CT.

	CVAR_EXPLODE_RADIUS     ,   	// Explosion Radius.
	CVAR_EXPLODE_DMG        ,   	// Explosion Damage.

	// Misc Setting.
	CVAR_DEATH_REMOVE		,		// Dead Player Remove Lasermine.
	CVAR_LASER_ACTIVATE		,		// Waiting for put lasermine. (0 = no progress bar.)
	CVAR_ALLOW_PICKUP		,		// allow pickup.
	CVAR_DIFENCE_SHIELD		,		// Shield hit.
};
new gCvar[CVAR_SETTING];
new gCvarString[CVAR_SETTING][] = 
{
	"_enable",
	"_access",
	"_mode",
	"_friendly_fire",
	"_round_delay",
	"_cmd_mode",
	"_amount",
	"_max_amount",
	"_team_max",
	"_buy_mode",
	"_buy_team",
	"_buy_price",
	"_buy_zone",
	"_frag_money",
	"_laser_visible",
	"_laser_color_mode",
	"_laser_color_t",
	"_laser_color_ct",
	"_laser_brightness",
	"_laser_damage",
	"_laser_damage_mode",
	"_laser_dps",
	"_laser_range",
	"_mine_health",
	"_mine_glow",
	"_mine_glow_color_mode",
	"_mine_glow_color_t",
	"_mine_glow_color_ct",
	"_explode_radius",
	"_explode_damage",
	"_death_remove",
	"_activate_time",
	"_allow_pickup",
	"_shield_difence",
};


public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	// Add your code here...
	register_clcmd("say", "say_lm", ADMIN_LEVEL_H);

	register_clcmd("lm_admin", "cmd_lasermine_admin_menu",  -1, " - shows a menu of a Lasermine Admin commands");
	register_clcmd("lm_menu" , "cmd_lasermine_client_menu", -1, " - shows a menu of a Lasermine Client commands");

	new cvar_command[64] = "^0";
	new cvar_length = charsmax(cvar_command);
	// CVar settings.
	for (new int:i = int:0; i < int:CVAR_SETTING; i++)
	{
		format(cvar_command, cvar_length, "%s%s", CVAR_TAG, gCvarString[CVAR_SETTING:i]);
		gCvar[CVAR_SETTING:i]	= get_cvar_pointer(cvar_command);
	}




}

public plugin_cfg()
{
}

//====================================================
// Chat command.
//====================================================
public say_lm_admin(id, level, cid)
{

	new said[32];
	read_argv(1, said, charsmax(said));
	
	if (equali(said,"/lmadmin")
	||  equali(said,"/lm_admin"))
	{
		if (!cmd_access(id, level, cid, 1))
			return PLUGIN_CONTINUE;

		show_lasermine_admin_menu(id);
		return PLUGIN_HANDLED;
	}
	else
	if (equali(said, "/lmmenu")
	||	equali(said, "/lm_menu"))
	{
		show_lasermine_client_menu(id);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public cmd_lasermine_admin_menu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;

	show_lasermine_admin_menu(id);
	return PLUGIN_HANDLED;
}

//====================================================
// Main menu.
//====================================================
show_lasermine_admin_menu(id)
{
    // Create a variable to hold the menu
	new menu = menu_create("\rLasermine Admin Menu", "lm_admin_menu_handler");
	new sMenuItem	[MAX_MENU_LENGTH];
	new sInfoParam	[MAX_MENU_LENGTH];
	formatex(sMenuItem,  charsmax(sMenuItem) , 	"\w%L", id, LMM_ADMIN_COMMON);
	formatex(sInfoParam, charsmax(sInfoParam), 	"admin_common");
	menu_additem(menu, sMenuItem, sInfoParam);

	formatex(sMenuItem, charsmax(sMenuItem), 	"\w%L", id, LMM_ADMIN_AMMO);
	formatex(sInfoParam, charsmax(sInfoParam), 	"admin_ammo");
	menu_additem(menu, sMenuItem, sInfoParam);

	formatex(sMenuItem, charsmax(sMenuItem), 	"\w%L", id, LMM_ADMIN_BUY);
	formatex(sInfoParam, charsmax(sInfoParam), 	"admin_buy");
	menu_additem(menu, sMenuItem, sInfoParam);

	formatex(sMenuItem, charsmax(sMenuItem), 	"\w%L", id, LMM_ADMIN_LASER);
	formatex(sInfoParam, charsmax(sInfoParam), 	"admin_laser");
	menu_additem(menu, sMenuItem, sInfoParam);

	formatex(sMenuItem, charsmax(sMenuItem), 	"\w%L", id, LMM_ADMIN_MINE);
	formatex(sInfoParam, charsmax(sInfoParam), 	"admin_mine");
	menu_additem(menu, sMenuItem, sInfoParam);

	formatex(sMenuItem, charsmax(sMenuItem), 	"\w%L", id, LMM_ADMIN_MISC);
	formatex(sInfoParam, charsmax(sInfoParam),	"admin_misc");
	menu_additem(menu, sMenuItem, sInfoParam);

    // We now have all players in the menu, lets display the menu
	menu_display(id, menu, 0);
}

public lm_admin_menu_handler(id, menu, item)
{
	new sInfoParam	[MAX_MENU_LENGTH];
	new sName		[MAX_MENU_LENGTH];
	new sInfoPrefix [6];
	new _access, item_callback;
	menu_item_getinfo(menu, item, _access, sInfoParam, charsmax(sInfoParam), sName, charsmax(sName), item_callback);
	strcat(sInfoPrefix, sInfoParam, charsmax(sInfoPrefix));
	if (equali(sInfoPrefix, "admin_"))
	{
		show_lasermine_admin_sub_menu(id, sInfoParam);
	}
	if (equali(sInfoPrefix, "asub_1"))
	{
		switch(item)
		{
			case 0:
				show_lasermine_admin_sub_menu(id, sInfoParam);
		}
	}
}

show_lasermine_admin_sub_menu(id, sInfoParam[MAX_MENU_LENGTH])
{
	new menu;
	new sMenuItem	[MAX_MENU_LENGTH];

	if (equali(sInfoParam, "admin_common"))
	{
 		// Create a variable to hold the menu
		menu = menu_create("\rLasermine Admin Common Menu", "lm_admin_menu_handler");
		formatex(sMenuItem, charsmax(sMenuItem), "\w%L\R\r%L", id, LMM_ADMIN_CVAR_ENABLE, get_pcvar_num(gCvar[CVAR_ENABLE]) ? LMM_ADMIN_CVAR_ON : LMM_ADMIN_CVAR_OFF);
		formatex(sInfoParam, charsmax(sInfoParam), "asub_1_%i", sInfoParam, get_pcvar_num(gCvar[CVAR_ENABLE]));
		menu_additem(menu, sMenuItem, sInfoParam);

		formatex(sMenuItem, charsmax(sMenuItem), "\w%L\R\r%L", id, LMM_ADMIN_CVAR_ACCESS, get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]) ? LMM_ADMIN_CVAR_ALL : LMM_ADMIN_CVAR_ADMIN);
		formatex(sInfoParam, charsmax(sInfoParam), "asub_1_%i", sInfoParam, get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]));
		menu_additem(menu, sMenuItem, sInfoParam);

		formatex(sMenuItem, charsmax(sMenuItem), "\w%L\R\r%L", id, LMM_ADMIN_CVAR_ACCESS, get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]) ? LMM_ADMIN_CVAR_ALL : LMM_ADMIN_CVAR_ADMIN);
		formatex(sInfoParam, charsmax(sInfoParam), "asub_1_%i", sInfoParam, get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]));
		menu_additem(menu, sMenuItem, sInfoParam);

		formatex(sMenuItem, charsmax(sMenuItem), "\w%L\R\r%L", id, LMM_ADMIN_CVAR_MODE, get_pcvar_num(gCvar[CVAR_MODE]) ? LMM_ADMIN_CVAR_TRIPMINE : LMM_ADMIN_CVAR_LASERMINE);
		formatex(sInfoParam, charsmax(sInfoParam), "asub_1_%i", sInfoParam, get_pcvar_num(gCvar[CVAR_MODE]));
		menu_additem(menu, sMenuItem, sInfoParam);

		formatex(sMenuItem, charsmax(sMenuItem), "\w%L\R\r%L", id, LMM_ADMIN_CVAR_FF, get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]) ? LMM_ADMIN_CVAR_ON : LMM_ADMIN_CVAR_OFF);
		formatex(sInfoParam, charsmax(sInfoParam), "asub_1_%i", sInfoParam, get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]));
		menu_additem(menu, sMenuItem, sInfoParam);

		formatex(sMenuItem, charsmax(sMenuItem), "\w%L\R\r%L", id, LMM_ADMIN_CVAR_ROUND_DELAY, (get_pcvar_num(gCvar[CVAR_START_DELAY]) % 6));
		formatex(sInfoParam, charsmax(sInfoParam), "asub_1_%i", sInfoParam, get_pcvar_num(gCvar[CVAR_START_DELAY]));
		menu_additem(menu, sMenuItem, sInfoParam);

		switch(get_pcvar_num(gCvar[CVAR_CMD_MODE]) % 3)
		{
			case 0://+USE key
				formatex(sMenuItem, charsmax(sMenuItem), "\w%L\R\r%L", id, LMM_ADMIN_CVAR_CMD_MODE, LMM_ADMIN_CVAR_USE);
			case 1:
				formatex(sMenuItem, charsmax(sMenuItem), "\w%L\R\r%L", id, LMM_ADMIN_CVAR_CMD_MODE, LMM_ADMIN_CVAR_BIND);
			case 2:
				formatex(sMenuItem, charsmax(sMenuItem), "\w%L\R\r%L", id, LMM_ADMIN_CVAR_CMD_MODE, LMM_ADMIN_CVAR_EACH);
		}

		formatex(sInfoParam, charsmax(sInfoParam), "asub_1_%i", sInfoParam, (get_pcvar_num(gCvar[CVAR_CMD_MODE]) % 3));
		menu_additem(menu, sMenuItem, sInfoParam);

		// We now have all players in the menu, lets display the menu
		menu_display(id, menu, 0);
	}
}

//====================================================
// Client Main menu.
//====================================================
show_lasermine_client_menu(id)
{
    // Create a variable to hold the menu
	new menu = menu_create("Lasermine Client Menu", "music_menu_handler");

    // We now have all players in the menu, lets display the menu
	menu_display(id, menu, 0);
}


public music_menu_handler(id, menu, item)
{
	// Do a check to see if they exited because menu_item_getinfo ( see below ) will give an error if the item is MENU_EXIT
	if (item == MENU_EXIT)
	{
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }
		
	// now lets create some variables that will give us information about the menu and the item that was pressed/chosen
	new szData[MAX_RESOURCE_PATH_LENGTH], szName[MAX_NAME_LENGTH];
	new _access, item_callback;
	// heres the function that will give us that information ( since it doesnt magicaly appear )
	menu_item_getinfo(menu, item, _access, szData, charsmax(szData), szName, charsmax(szName), item_callback);

	client_cmd(id, "mp3 %s", szData);

	if (equali("stop", szData))
		client_print_color(id, print_chat, "^4[MMA] ^1BGM Stopped.");
	else
		client_print_color(id, print_chat, "^4[MMA] ^1BGM Start!:^3[%s]", szName);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
