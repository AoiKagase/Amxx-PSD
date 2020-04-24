#if defined _mines_natives_included
    #endinput
#endif

#include <mines_const>
#define _mines_natives_included 


native register_mines(classname[MAX_NAME_LENGTH], minesData[COMMON_MINES_DATA]);
native mines_progress_deploy(id, minesId);

native mines_progress_pickup(id, minesId);

native mines_progress_stop(id);

native mines_explosion(id, minesId, iEnt);

forward mines_entity_spawn_settings(iEnt, uID);
forward mines_client_putinserver();
forward	mines_client_disconnected();
forward	mines_plugin_end();

forward	PickupMines(id, target);
forward	bool:CheckForDeploy();
forward	bool:CheckForPickup();
forward	bool:CheckForBuy();
forward	MinesThink(iEnt, iMinesId);
