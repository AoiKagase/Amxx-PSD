<?php
abstract class T_CORE
{
	protected $field;
	protected $dbh;
	protected $table;

	function __construct(&$dbh)
	{
		$this->dbh = $dbh;
	}
}