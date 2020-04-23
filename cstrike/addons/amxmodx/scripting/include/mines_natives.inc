#if defined _mines_natives_included
    #endinput
#endif

#define _mines_natives_included 



native lm_progress_deploy(id, minesId);

native lm_progress_pickup(id, minesId);

native lm_progress_stop(id);

native lm_mines_explosion(id, minesId, iEnt);

forward lm_entity_spawn_settings();
forward lm_client_putinserver();
forward	lm_client_disconnected();
forward	lm_plugin_end();

forward	PickupMines();
forward	CheckForDeploy();
forward	CheckForPickup();
forward	CheckForBuy();
forward	MinesThink();
