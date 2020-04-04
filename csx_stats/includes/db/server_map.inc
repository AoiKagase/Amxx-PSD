<?php

require_once("includes/db/_table.inc");

class T_SERVER_MAP extends T_CORE
{
	function __construct(&$dbh)
	{
		parent::__construct($dbh);

		$this->table = 'server_map';

		$this->key = [
			'server_id',
			'date',			
		];

		$this->field = [
			'server_id',
			'date',			
			'map_name',
			'total_round',
			'total_time',
			'total_win_t',
			'total_win_t_score',
			'total_win_ct',
			'total_win_ct_score',
			'created_at',
			'updated_at',
		];
	}
}