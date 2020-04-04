#pragma semicolon 1
//20.03.2020 v0.8
//29.05.2008 v0.7 add batch process.
//28.05.2008 v0.6 any fix.
//25.04.2008 v0.5 fix connecting bug for windows.
//23.04.2008 v0.4 add cvar and errcode.
//22.04.2008 v0.3 cut some "public"
//20.04.2008 v0.2 single quotation in name no write bug fix.
//19.04.2008 v0.1 first release
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <csx>
#include <sqlx>

#define PLUGIN					"Player Status in DB"
#define VERSION					"0.8"
#define AUTHOR					"Aoi.Kagase"
#define MAX_ERR_LENGTH			512
#define MAX_QUERY_LENGTH		2048
#define MAX_LENGTH				128
#define DEFAULT_SERVER_ID		1

#define SQL_FIELD_COMMON_STATS	"`csx_kills`,`csx_tks`,`csx_deaths`,`csx_hits`,`csx_dmg`,`csx_shots`,`csx_hs`,`h_head`,`h_chest`,`h_stomach`,`h_larm`,`h_rarm`,`h_lleg`,`h_rleg`"
#define SQL_PARAM_COMMON_STATS	"'%i','%i','%i','%i','%i','%i','%i','%i','%i','%i','%i','%i','%i','%i'"

// #define SQL_FIELD_TOTAL_OBJECT	"`server_id`,`date`, `auth_id`,`t_defusions`,`b_defused`,`b_plants`,`b_explosions`"
// #define SQL_PARAM_TOTAL_OBJECT	"'%s','%s','%s','%i','%i','%i','%i'"

#define SQL_FIELD_USER_OBJECT	"`server_id`,`date`, `auth_id`,`t_defusions`,`b_defused`,`b_plants`,`b_explosions`"
#define SQL_PARAM_USER_OBJECT	"'%i','%s','%s','%i','%i','%i','%i'"

#define SQL_FIELD_SERVER_MAP	"`server_id`,`date`,`map_name`,`total_round`,`total_time`,`total_win_t`,`total_win_t_score`,`total_win_ct`,`total_win_ct_score`"
#define SQL_PARAM_SERVER_MAP    "'%i','%s','%s','%i','%i','%i','%i','%i','%i'"

#define SQL_FIELD_SERVER_ROUND	"`server_id`,`date`,`round`,`round_time`,`win_team`,`win_score`"
#define SQL_PARAM_SERVER_ROUND  "'%i','%s','%i','%i','%i','%i'"

#define SQL_FIELD_USER			"`auth_id`,`name`,`latest_ip`, `online_time`"
#define SQL_PARAM_USER          "'%s','%s','%s','%i'"

#define SQL_FIELD_TOTAL_STATS	"`server_id`,`auth_id`,`csx_rank`,`csx_score`,"
#define SQL_PARAM_TOTAL_STATS   "'%i','%s','%i','%i',"

#define SQL_FIELD_USER_STATS	"`server_id`,`date`, `auth_id`,`csx_rank`,`csx_score`," 
#define SQL_PARAM_USER_STATS    "'%i','%s','%s','%i','%i',"

#define SQL_FIELD_USER_RSTATS	"`server_id`,`date`,`round`,`auth_id`," 
#define SQL_PARAM_USER_RSTATS   "'%i','%s','%i','%s'," 

#define SQL_FIELD_WSTATS		"`server_id`,`date`,`auth_id`,`wpn_name`,"
#define SQL_PARAM_WSTATS		"'%i','%s','%s','%s',"

#define SQL_FIELD_WRSTATS		"`server_id`,`date`,`round`,`auth_id`,`wpn_name`,"
#define SQL_PARAM_WRSTATS		"'%i','%s','%i','%s','%s',"

#define SQL_REPLACE_INTO		"REPLACE INTO `%s`.`%s`"
#define SQL_START				"("
#define SQL_VALUES				") VALUES ("
#define SQL_END					");"

#define SQL_SELECT_USER_TIME	"SELECT SUM(`online_time`) AS online_time FROM `%s`.`%s` WHERE `auth_id` = '%s' GROUP BY `auth_id`;"
#define SQL_SELECT_USER_INFO	"SELECT `auth_id`, `latest_ip`, SUM(`online_time`) as online_time FROM `%s`.`%s` WHERE `auth_id` = '%s' GROUP BY `auth_id`, `latest_ip` ORDER BY `created_at` desc LIMIT 1;"

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
	TBL_DATA_MAP			[MAX_NAME_LENGTH] = 0,
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

//Database setting
new g_dbConfig[DB_CONFIG];
new g_tblNames[TBL_DATA] = 
{
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
new g_user_name				[MAX_PLAYERS][MAX_NAME_LENGTH];
new g_playtime				[MAX_PLAYERS];

new g_initialize;
new g_csstats_reset;

//Create Table
init_database()
{
	new sql[MAX_QUERY_LENGTH + 1];
	new Handle:queries[10];
	new len = 0, i = 0;
/*
	// CREATE TABLE info_server.
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`,`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_SERVER]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`  		 INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `server_name`     	 VARCHAR(%d)     NOT NULL DEFAULT 0,", MAX_NAME_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 		 	 DATETIME        NOT NULL,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 		 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 		 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " INDEX PRIMARY_INDEX (`server_id`, `date`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " INDEX IDX_1 (`server_name`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);
*/
	// CREATE TABLE server_map.		Map infomation.
	//
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_MAP]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`		  INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 			  DATETIME        NOT NULL,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `map_name`     	  VARCHAR(%d)     NOT NULL DEFAULT  '',", 	MAX_NAME_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_round`     	  INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_time`     	  BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_win_t`   	  INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_win_t_score`  INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_win_ct`  	  INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `total_win_ct_score` INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 		  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 		  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`,`date`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE server_round.	Round infomation.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_ROUND]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`		 INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 			 DATETIME    	 NOT NULL,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `round`     	 	 INT UNSIGNED    NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `round_time`     	 INT UNSIGNED 	 NOT NULL DEFAULT 0,"); // roundtime 0 is danger!!
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `win_team`   	 	 TINYINT    	 NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `win_score`   	 	 TINYINT    	 NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 		 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 		 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`,`date`,`round`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_info.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`auth_id`     	 VARCHAR(%d)       NOT NULL,", MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `name`        	 VARCHAR(%d)       NOT NULL,", MAX_NAME_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `latest_ip`   	 VARCHAR(%d)   	   NOT NULL,", MAX_IP_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `online_time` 	 BIGINT	  UNSIGNED DEFAULT  0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at`  	 DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at`  	 DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
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
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `auth_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_stats.		User Status Per Game.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_STATS]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    DEFAULT  '0000-00-00 00:00:00',");
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
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`, `auth_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_OBJECTIVE]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    DEFAULT  '0000-00-00 00:00:00',");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `t_defusions`  BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `b_defused`   	BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `b_plants`   	BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `b_explosions` BIGINT UNSIGNED NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`, `auth_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_rstats.	User Status Per Round.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_ROUND]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    DEFAULT  '0000-00-00 00:00:00',");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `round`   	  	INT UNSIGNED    DEFAULT  0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
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
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`, `round`, `auth_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_wstats.	Weapon Status Per Game.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_WEAPON]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    DEFAULT  '0000-00-00 00:00:00',");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `wpn_name`  	VARCHAR(%d)     DEFAULT  '',", 	MAX_NAME_LENGTH);
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
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`server_id`, `date`, `auth_id`, `wpn_name`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);

	// CREATE TABLE user_wrstats.	Weapon Status Per Round.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER_RWEAPON]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`server_id`	INT UNSIGNED    NOT NULL DEFAULT 1,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `date` 	  	DATETIME	    DEFAULT  '0000-00-00 00:00:00',");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `round`   	  	INT UNSIGNED    DEFAULT  0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `auth_id`    	VARCHAR(%d)     NOT NULL,", 	MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `wpn_name`  	VARCHAR(%d)     DEFAULT  '',", 	MAX_NAME_LENGTH);
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
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 	DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
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
	g_server_info[SERVER_ID]			= DEFAULT_SERVER_ID;
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
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_srvcmd("amx_psd_update",		"insert_batch",		-1,	" - Batch processing update in DB.");
	register_srvcmd("amx_psd_reset",		"reset_database",	-1,	" - Reset in DB.");
	register_srvcmd("amx_psd_initialize",	"init_status",		-1,	" - initializing all player status and database.");

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
	register_logevent("Event_CTWin", 6, "3=CTs_Win", 		"3=VIP_Escaped", 		"3=Bomb_Defused",  "3=All_Hostages_Rescued", "3=CTs_PreventEscape", "3=Escaping_Terrorists_Neutralized");
	register_logevent("Event_TRWin", 6, "3=Terrorists_Win", "3=VIP_Assassinated",	"3=Target_Bombed", "3=Hostages_Not_Rescued", "3=Terrorists_Escaped");
	// register_event("TeamScore", "Event_TRWin", "a", "1=TERRORIST");
	// register_event("TeamScore", "Event_CTWin", "a", "1=CT");
	init_server_info();
	set_task(1.0, "plugin_core");
	g_initialize = false;

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
	get_cvar_string("amx_sql_host", g_dbConfig[DB_HOST], charsmax(g_dbConfig[DB_HOST]));
	get_cvar_string("amx_sql_user", g_dbConfig[DB_USER], charsmax(g_dbConfig[DB_USER]));
	get_cvar_string("amx_sql_pass", g_dbConfig[DB_PASS], charsmax(g_dbConfig[DB_PASS]));
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
		, sAuthId);
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

	for (new i = 0; i < MAX_NAME_LENGTH*2; i+= MAX_NAME_LENGTH)
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
	if (!is_user_bot(id))
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
	if(is_user_connected(id))
	{
		new sAuthid			[MAX_AUTHID_LENGTH];
		g_playtime[id] = get_systime();
		get_user_name(id, g_user_name[id], MAX_NAME_LENGTH);
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
	if (!is_user_bot(id))
	{
		new sAuthid	[MAX_AUTHID_LENGTH];
		new sName	[MAX_NAME_LENGTH];

		get_user_authid(id, sAuthid, charsmax(sAuthid));
		get_user_name(id, sName, charsmax(sName));
		if (!equali(sName, g_user_name[id])) 
		{
			insert_user_info(id, sAuthid);
			server_print("[PSD] [%s] User name changed.", sAuthid);
		}
	}
	return PLUGIN_CONTINUE;
}

insert_user_info(id, sAuthId[MAX_AUTHID_LENGTH] = "", sName[MAX_NAME_LENGTH] = "")
{
	new sIp[MAX_IP_LENGTH]			= "";
	new sql[MAX_QUERY_LENGTH + 1]	= "";
	new len = 0;
	if (equali(sName,""))
		get_user_name(id, sName, charsmax(sName));

	if (equali(sAuthId, "BOT"))
		formatex(sName, charsmax(sName), "BOT");

	get_user_ip(id, sIp, charsmax(sIp), 1);

	new playtime = select_user_info(sAuthId) + (get_systime() - g_playtime[id]);
	g_playtime[id] = get_systime();

	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_USER);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_USER, sAuthId, sName, sIp, playtime);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

	execute_insert_sql(sql);
}

insert_user_info_batch(sql[], sAuthId[MAX_AUTHID_LENGTH] = "", sName[MAX_NAME_LENGTH] = "")
{
	new len = 0;
	new sIp[MAX_AUTHID_LENGTH];
	new playtime = select_user_info_record(sAuthId, sIp[0], charsmax(sIp));

	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_REPLACE_INTO, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_START);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_FIELD_USER);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_VALUES);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_PARAM_USER, sAuthId, sName, sIp, playtime);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, SQL_END);

	execute_insert_sql(sql);
}

select_user_info(sAuthId[])
{
	new Handle:query = SQL_PrepareQuery(g_dbConnect, SQL_SELECT_USER_TIME, g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER], sAuthId);
	
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

select_user_info_record(sAuthId[MAX_AUTHID_LENGTH], &ip, iplen)
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
		SQL_ReadResult(query, 1, ip, iplen);	// ip
		online_time = SQL_ReadResult(query, 2);		// time
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
	new Handle:result[1];
	result[0] = SQL_PrepareQuery(g_dbConnect, sql);
	execute_insert_multi_query(result, 1);
}

execute_insert_multi_query(Handle:query[], count)
{
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