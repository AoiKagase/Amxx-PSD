<?php
abstract class T_CORE
{
	protected $key;
	protected $field;
	protected $dbh;
	protected $table;

	function __construct(&$dbh)
	{
		$this->table	= '';
		$this->key 		= [];
		$this->field 	= [];
		$this->dbh 		= $dbh;
	}

	function GetList($where = [])
	{
		$result = [];
		$sql = 'SELECT '. implode(", ", $this->field)
				.' FROM '.$this->table
				.' WHERE 1 = 1';

		foreach($where as $key => $value)
		{
			$sql .= " AND (${key} = :${key})";
		}

		$sql .= " ORDER BY ".implode(", ", $this->key);
	
		try
		{
			$prepare = $this->dbh->prepare($sql);
			foreach($where as $key => $value)
			{
				$prepare->bindValue(':'.$key, $value);
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