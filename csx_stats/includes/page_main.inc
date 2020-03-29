<?php
require_once("vendor/autoload.php");
require_once("includes/db/_db_h.inc");
class PageMain
{
	protected $loader;
	protected $twig;
	protected $dbh;

	function __construct()
	{
		$this->dbh		= DBHandler::CreateConnection();

		$this->loader	= new \Twig\Loader\FilesystemLoader('templates');
		$this->twig		= new \Twig\Environment($this->loader, ['cache' => 'templates/compiled',]);
	}

	function main()
	{
		$this->end();
	}

	function end()
	{
		DBHandler::Close($dbh);
	}
}
