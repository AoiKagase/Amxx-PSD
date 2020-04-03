<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
		<title>Player Status in DB - {% block title %}{% endblock %}</title>
	</head>
	<body topmargin="0" leftmargin="-2">
		<b>Player Status in DB</b>

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

	</body>
</html>