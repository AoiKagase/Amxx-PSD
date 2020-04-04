<?php
require_once("includes/db/_table.inc");
class T_USER_OBJECTIVE extends T_CORE
{
	function __construct(&$dbh)
	{
		parent::__construct($dbh);

		$this->table = 'user_objective';

		$this->key = [
			'server_id',
			'date',
			'auth_id',
		];

		$this->field = [
			'server_id',
			'date',
			'auth_id',
			't_defusions',
			'b_defused',
			'b_plants',
			'b_explosions',
			'created_at',
			'updated_at',
		];
	}
}