<?php
require_once("includes/db/_table.inc");
class T_USER_INFO extends T_CORE
{
	function GetList($where = array())
	{
		$result = array();
		$sql = 'SELECT '
			.'	A.auth_id'
			.',	A.name'
			.',	A.online_time'
			.' FROM user_info AS A'
			.' WHERE created_at = (SELECT MAX(created_at) FROM user_info AS B WHERE B.auth_id = A.auth_id)'
			.' ORDER BY A.auth_id';
		try
		{
			$prp = $this->dbh->prepare($sql);
			$prp->execute();
			$result = $prp->fetchAll(PDO::FETCH_ASSOC);
		}
		catch (PDOException $e)
		{
			echo $e->getMessage() . "\n";
		}
		return $result;

	}

	function GetUser($where = array())
	{
		if (isset($where['auth_id']))
			return array();

		$result = array();
		$sql = 'SELECT '
			.'	A.auth_id'
			.',	A.name'
			.',	A.online_time'
			.' FROM user_info AS A'
			.' WHERE auth_id = :auth_id'
			.' ORDER BY A.auth_id, A.created_at DESC';
		try
		{
			$prp = $this->dbh->prepare($sql);
			$prp->bindParam(':auto_id', $where['auth_id']);
			$prp->execute();
			$result = $prp->fetchAll(PDO::FETCH_ASSOC);
		}
		catch (PDOException $e)
		{
			echo $e->getMessage() . "\n";
		}
		return $result;

	}


}