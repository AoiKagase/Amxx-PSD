<?php
require_once("includes/page_main.inc");
require_once("includes/db/user_info.inc");
require_once("includes/db/user_stats.inc");
class Index extends PageMain
{
	function __construct()
	{
		parent::__construct();
	}

	function main()
	{
		if (isset($_POST['auth_id']))
		{
			$auth_id = $_POST['auth_id'];
			$user = $this->get_user_rank($auth_id);
			echo $this->twig->render('user_rank.tpl',  ['data' => $user]);
		} else
		{
			$data = $this->get_ranking_top15();
			echo $this->twig->render('index.tpl', ['ranking' => $data]);
		}
		parent::main();
	}

	function get_user_rank($auth_id)
	{
		$info		= new T_USER_INFO($this->dbh);
		$stats		= new T_USER_STATS($this->dbh);

		$where['auth_id'] = $auth_id;

		$info_rec	= $info->GetUser($where);
		$stats_rec	= $stats->GetWeaponRankForUser($where);
		$stats_rec	= $this->calculate_rate($stats_rec);

		$result = [
			'info'	=> $info_rec,
			'stats'	=> $stats_rec,
		];
		return $result;
	}

	function get_ranking_top15()
	{
		$where		= array();
		$info		= new T_USER_INFO($this->dbh);
		$info_rec	= $info->GetList($where);

		$stats		= new T_USER_STATS($this->dbh);
		$stats_rec 	= $stats->GetTop15();
		$info_array = array_column($info_rec, null, "auth_id");
		$result 	= $this->calculate_rate($stats_rec, $info_array);

		return $result;
	}

	function calculate_rate($dataset, $info = null)
	{
		for($i = 0; $i < count($dataset); $i++)
		{
			if (isset($info))
			{
				$dataset[$i]['name']		= $info[$dataset[$i]['auth_id']]['name'];
				$dataset[$i]['online_time']	= $info[$dataset[$i]['auth_id']]['online_time'];
			}
			$dataset[$i]['efficiency'] 	= 0;
			$dataset[$i]['accuracy']	= 0;
			$dataset[$i]['accuracyHS']	= 0;
			$dataset[$i]['kdrate']		= 0;
			if (($dataset[$i]['csx_kills'] + $dataset[$i]['csx_deaths']) > 0)
				$dataset[$i]['efficiency'] 	= round((floatval($dataset[$i]['csx_kills']) / floatval($dataset[$i]['csx_kills'] + $dataset[$i]['csx_deaths'])) * 100.0, 2, PHP_ROUND_HALF_DOWN);

			if ($dataset[$i]['csx_shots'] > 0)
			{
				$dataset[$i]['accuracy']	= round((floatval($dataset[$i]['csx_hits'])  / floatval($dataset[$i]['csx_shots']))  * 100.0, 2, PHP_ROUND_HALF_DOWN);
				$dataset[$i]['accuracyHS']	= round((floatval($dataset[$i]['csx_hs'])    / floatval($dataset[$i]['csx_shots']))  * 100.0, 2, PHP_ROUND_HALF_DOWN);
			}

			if ($dataset[$i]['csx_deaths'] > 0)
				$dataset[$i]['kdrate']		= round((floatval($dataset[$i]['csx_kills']) / floatval($dataset[$i]['csx_deaths'])), 2, PHP_ROUND_HALF_DOWN);
		}
		return $dataset;
	}
}
$index = new Index();
$index->main();