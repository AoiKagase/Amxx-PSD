<?php
require_once("vendor/autoload.php");
require_once("includes/db/_db_h.inc");
class PageMain
{
	protected $loader;
	protected $twig;
	protected $dbh;
	protected $server_id;

	public function __construct()
	{
		$this->dbh			= DBHandler::CreateConnection();
		$this->server_id	= 1;
		$this->loader		= new \Twig\Loader\FilesystemLoader('templates');
		$this->twig			= new \Twig\Environment($this->loader, ['cache' => 'templates/compiled',]);
	}

	public function main()
	{
		$this->select();

		$this->end();
	}

	protected function select()
	{
	}

	protected function end()
	{
		DBHandler::Close($dbh);
	}

	protected function calculate_rate($dataset, $info = null)
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
			else
				$dataset[$i]['kdrate']		= $dataset[$i]['csx_kills'];
		}
		return $dataset;
	}
}
