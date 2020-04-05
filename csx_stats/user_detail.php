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

			$hit_mk		= $this->get_hit_marker($wstats_sc);

			echo $this->twig->render('user_detail.tpl',  
				[
					'info'		=> $info_rec,
					'total' 	=> $total_sc,
					'team' 		=> $team_sc,
					'wstats'	=> $wstats_sc,
					'hitimg'	=> $hit_mk,
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

	function get_hit_marker($wstats)
	{
		// 画像ファイル名群
		$imgFns = array(
			'main' 		=> './images/hit_main.png',
			'h_head' 	=> './images/hit_head.png',
			'h_chest'	=> './images/hit_chest.png',
			'h_stomach'	=> './images/hit_stomach.png',
			'h_rarm'	=> './images/hit_rarm.png',
			'h_larm'	=> './images/hit_larm.png',
			'h_rleg'	=> './images/hit_rleg.png',
			'h_lleg'	=> './images/hit_lleg.png',
		);
		$resource = [];
		foreach($wstats as $stats)
		{
			// 空の画像を作成する
			$img = imagecreatefrompng($imgFns['main']); // 合成する画像を取り込む
			// 背景を透明にする
			imagecolortransparent($img, imagecolorallocate($img, 0, 0, 0));
			imagefilter($img, IMG_FILTER_NEGATE);
			imagefilter($img, IMG_FILTER_COLORIZE, 0, 255, 0);
			// シンプルな画像合成
			foreach($imgFns as $key => $fn)
			{
				$blue = 0;
				if ($key == 'main')
				{
					continue;
				}
				else
				{
					$hit	= floatval($stats['csx_hits']) > 0 ? floatval($stats['csx_hits']) : 1;
					$acc	= (floatval($stats[$key]) / $hit * 100);
					$red	= 255;
					$green	= 255;
					if ($acc > 50)
						$green = 255 - $acc * (255.0 / 50.0);
					else
					if ($acc < 50)
						$red   = $acc * (255.0 / 50.0);
				}
				$img2 = imagecreatefrompng($fn); // 合成する画像を取り込む
				imagefilter($img2, IMG_FILTER_NEGATE);
				imagefilter($img2, IMG_FILTER_COLORIZE, $red, $green, $blue);

				// 合成する画像のサイズを取得
				$sx = imagesx($img2);
				$sy = imagesy($img2);
			
				imageLayerEffect($img, IMG_EFFECT_ALPHABLEND);// 合成する際、透過を考慮する
				imagecopy($img, $img2, 0, 0, 0, 0, $sx, $sy); // 合成する
			
				imagedestroy($img2); // 破棄
			}
			ob_start();
				imagepng($img);
				$result = ob_get_contents();
			ob_end_clean();
			// 別名で保存
			$resource[$stats['wpn_name']] = base64_encode($result);
			imagedestroy($img);		

		}
		return $resource;
	}
}
$user_detail = new UserDetail();
$user_detail->main();