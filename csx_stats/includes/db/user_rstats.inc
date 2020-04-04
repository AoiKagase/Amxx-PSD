<?php
require_once("includes/db/_table.inc");
class T_USER_RSTATS extends T_CORE
{
	function __construct(&$dbh)
	{
		parent::__construct($dbh);

		$this->table = 'user_rstats';

		$this->key = [
			'server_id',
			'date',
			'round',
			'auth_id',
		];

		$this->field = [
			'server_id',
			'date',
			'round',
			'auth_id',
			'csx_kills',
			'csx_tks',
			'csx_deaths',
			'csx_hits',
			'csx_dmg',
			'csx_shots',
			'csx_hs',
			'h_head',
			'h_chest',
			'h_stomach',
			'h_larm',
			'h_rarm',
			'h_lleg',
			'h_rleg',
			'created_at',
			'updated_at',
		];
	}	
}