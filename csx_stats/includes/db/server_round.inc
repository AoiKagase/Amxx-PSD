<?php
require_once("includes/db/_table.inc");
class T_SERVER_ROUND extends T_CORE
{
	function __construct(&$dbh)
	{
		parent::__construct($dbh);

		$this->table = 'server_round';

		$this->key = [
			'server_id',
			'date',
			'round',
		];

		$this->field = [
			'server_id',
			'date',
			'round',
			'round_time',
			'win_team',
			'win_score',
			'created_at',
			'updated_at',
		];
	}

	function GetTeamWonCount($where=[])
	{
		$sql = 'SELECT'
				.' COUNT(B.round) AS total_round,'
				.' SUM(CASE WHEN A.win_team = B.team AND win_team != 0 THEN 1 ELSE 0 END) AS WIN,'
				.' SUM(CASE WHEN A.win_team = 1 THEN 1 ELSE 0 END) AS  T_WIN,'
				.' SUM(CASE WHEN A.win_team = 2 THEN 1 ELSE 0 END) AS CT_WIN,'
				.' SUM(CASE WHEN B.team = 1 THEN 1 ELSE 0 END) AS  T_COUNT,'
				.' SUM(CASE WHEN B.team = 2 THEN 1 ELSE 0 END) AS CT_COUNT'
				.' FROM server_round AS A'
				.' INNER JOIN user_rstats AS B'
				.' ON  A.server_id = B.server_id'
				.' AND A.date	   = B.date'
				.' AND A.round	   = B.round'
				.' WHERE'
				.' 1 = 1';

		foreach($where as $key => $value)
		{
			$sql .= " AND B.`${key}` = :${key}";
		}

		try
		{
			$prepare = $this->dbh->prepare($sql);
			foreach($where as $key => $value)
			{
				$prepare->bindValue(":${key}", $where[$key]);
			}

			$prepare->execute();
			$result = $prepare->fetchAll(PDO::FETCH_ASSOC);
		}
		catch (PDOException $e)
		{
			echo $e->getMessage() . "\n";
		}
		return $result;
	}
}