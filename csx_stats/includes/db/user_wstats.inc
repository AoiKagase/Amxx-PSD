<?php
require_once("includes/db/_table.inc");
class T_USER_WSTATS extends T_CORE
{
	function __construct(&$dbh)
	{
		parent::__construct($dbh);

		$this->table = 'user_wstats';

		$this->key = [
			'server_id',
			'date',
			'round',
			'auth_id',
			'wpn_name',
		];

		$this->field = [
			'server_id',
			'date',
			'round',
			'auth_id',
			'wpn_name',
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

	// get_user_wstats
	function GetWeaponRankForUser($where = array())
	{
		if (!isset($where['auth_id']))
			return array();

		$sql = 'SELECT '
			.'	A.server_id'
			.', A.auth_id'
			.', A.wpn_name'
			.',	SUM(A.csx_kills)	AS csx_kills'
			.',	SUM(A.csx_tks)		AS csx_tks'
			.',	SUM(A.csx_deaths)	AS csx_deaths'
			.',	SUM(A.csx_hits)		AS csx_hits'
			.',	SUM(A.csx_dmg)		AS csx_dmg'
			.',	SUM(A.csx_shots)	AS csx_shots'
			.',	SUM(A.csx_hs)		AS csx_hs'
			.',	SUM(A.h_head)		AS h_head'
			.',	SUM(A.h_chest)		AS h_chest'
			.',	SUM(A.h_stomach)	AS h_stomach'
			.',	SUM(A.h_larm)		AS h_larm'
			.',	SUM(A.h_rarm)		AS h_rarm'
			.',	SUM(A.h_lleg)		AS h_lleg'
			.',	SUM(A.h_rleg)		AS h_rleg'
			.' FROM  user_wstats AS A'
			.' WHERE auth_id = :auth_id'
			.' GROUP BY A.server_id, A.auth_id, A.wpn_name'
			.' ORDER BY csx_kills desc, csx_hits desc';

		try
		{
			$prp = $this->dbh->prepare($sql);
			$prp->bindValue(':auth_id', $where['auth_id']);
			$prp->execute();
			$result = $prp->fetchAll(PDO::FETCH_ASSOC);
		}
		catch (PDOException $e)
		{
			echo $e->getMessage() . "\n";
		}
		return $result;
	}

}