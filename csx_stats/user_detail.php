<?php
require_once("includes/page_main.inc");
require_once("includes/db/user_info.inc");
require_once("includes/db/server_round.inc");
require_once("includes/db/total_stats.inc");
require_once("includes/db/user_wstats.inc");
class UserDetail extends PageMain
{
	function __construct()
	{
		parent::__construct();
		$this->server_id = 1;
	}

	function select()
	{
		if (isset($_POST['auth_id']))
		{
			$auth_id = $_POST['auth_id'];

			// Get User Info;
			$info_rec	= $this->get_user($auth_id);
			// Get Total;
			$total_sc	= $this->get_total_score($auth_id);
			// Get Team Info;
			$team_sc	= $this->get_server_round($auth_id);
			// Get WpnStats;
			$wstats_sc 	= $this->get_user_wstats($auth_id);

			echo $this->twig->render('user_detail.tpl',  
				[
					'info'		=> $info_rec,
					'total' 	=> $total_sc,
					'team' 		=> $team_sc,
					'wstats'	=> $wstats_sc,
				]
			);
		} else
		{
			redirect("./");
		}
	}

	function get_user($auth_id)
	{
		$where = [
			'auth_id' => $auth_id
		];
		// Get User Info;
		$info 		= new T_USER_INFO($this->dbh);

		return $info->GetUser($where);
	}

	function get_total_score($auth_id)
	{
		$where = [
			'server_id' => $this->server_id,
			'auth_id'	=> $auth_id,
		];
		// Get Total Score;
		$total_stats = new T_TOTAL_STATS($this->dbh);
		$total		 = $total_stats->GetList($where);
		return $this->calculate_rate($total)[0];
	}

	function get_server_round($auth_id)
	{
		$where = [
			'server_id' => $this->server_id,
			'auth_id'	=> $auth_id,
		];
		// Get Total Score;
		$server_round = new T_SERVER_ROUND($this->dbh);
		return $server_round->GetTeamWonCount($where)[0];
	}

	function get_user_wstats($auth_id)
	{
		$stats		= new T_USER_WSTATS($this->dbh);
		$where = [
			'server_id' => $this->server_id,
			'auth_id'	=> $auth_id,
		];

		$stats_rec	= $stats->GetWeaponRankForUser($where);
		$stats_rec	= $this->calculate_rate($stats_rec);

		return $stats_rec;
	}
}
$user_detail = new UserDetail();
$user_detail->main();