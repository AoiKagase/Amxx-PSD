<?php
require_once("includes/db/_table.inc");
class T_TOTAL_STATS extends T_CORE
{
	function __construct(&$dbh)
	{
		parent::__construct($dbh);

		$this->table = 'total_stats';

		$this->key = [
			'server_id',
			'auth_id',
		];

		$this->field = [
			'server_id',
			'auth_id',
			'csx_rank',
			'csx_score',
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

	// get_stats
	function GetTopRanker($where = [])
	{
		$result = [];
		$sql = 'SELECT '
			.'  A.server_id'
			.', A.auth_id'
			.',	SUM(A.csx_rank)  	AS csx_rank'
			.',	SUM(A.csx_score)	AS csx_score'
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
			.' FROM '. $this->table.' AS A'
			.' GROUP BY A.server_id, A.auth_id'
			.' ORDER BY A.csx_rank, A.csx_score desc';
	
		try
		{
			$prp = $this->dbh->prepare($sql);
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