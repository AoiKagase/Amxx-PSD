<?php
require_once("includes/page_main.inc");
require_once("includes/db/user_info.inc");
require_once("includes/db/total_stats.inc");
class Index extends PageMain
{
	public function __construct()
	{
		parent::__construct();
	}

	protected function select()
	{
		$data = $this->get_ranking_top();
		echo $this->twig->render('index.tpl', ['ranking' => $data]);
	}

	protected function get_ranking_top()
	{
		$info		= new T_USER_INFO($this->dbh);
		$info_rec	= $info->GetNewerList();

		$stats		= new T_TOTAL_STATS($this->dbh);
		$stats_rec 	= $stats->GetTopRanker();

		$info_array = array_column($info_rec, null, "auth_id");
		$result 	= $this->calculate_rate($stats_rec, $info_array);

		return $result;
	}
}
$index = new Index();
$index->main();