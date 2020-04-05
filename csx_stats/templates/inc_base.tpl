<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
		<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js" integrity="sha384-wHAiFfRlMFy6i5SRaxvfOCifBUQy1xHdJ/yoi7FRNXMRBu5WHdZYu1hA6ZOblgut" crossorigin="anonymous"></script>
		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js" integrity="sha384-B0UglyR+jN6CkvvICOB2joaf5I4l3gm9GU6Hc1og6Ls7i6U/mkkaduKaBhlAXv9k" crossorigin="anonymous"></script>		<title>Player Status in DB - {% block title %}{% endblock %}</title>
		<script type="text/javascript">
		{% block javascript %}{% endblock %}
		</script>
	</head>
	<body topmargin="0" leftmargin="-2">
	<div class="container">
		<h1>Player Status in DB</h1>

<div class="alert alert-dismissible alert-primary">
		<h6>
		Testing the PSD plugin.<br />
		Score may be initialized. Please cooperate with the score tally.<br />
		<br />
		PSDプラグインのテスト中につきスコア履歴が初期化される事があります。<br />
		集計ロジックの精度を高めるため、プレイのご協力をお願いします。<br />
		</h6>
</div>
		{% block content %}{% endblock %}
	</div>
	</body>
</html>