<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" href="css/cs.css" type="text/css">
		<title>Player Status in DB</title>
	</head>
	<body topmargin="0" leftmargin="-2">
		<basefont size="-1" face="MS GOTHIC">
		<b>Player Status in DB</b>
		
		<table width="100%" cellpadding="0" cellspacing="0" class="genmed">
			<tr>
				<td colspan="22" class="catHead">
					<span class="genmed"><b>{{ data.info.name }}</b></span>
					<span class="genmed"><b>{{ data.info.online_time }}</b></span>
					<span class="genmed"><b>User Rank</b></span>
				</td>
			</tr>
			<tr>
				<td class="row1" align="center" rowspan="2" colspan="2">Weapon</td>
				<td class="row1" align="center" rowspan="2">Score</td>
				<td class="row1" align="center" rowspan="2">Kills</td>
<!--			<td class="row1" align="center" rowspan="2">Deaths</td>-->
				<td class="row1" align="center" rowspan="2">TeamKills</td>
				<td class="row1" align="center" rowspan="2">Hits</td>
				<td class="row1" align="center" rowspan="2">Damages</td>
				<td class="row1" align="center" rowspan="2">Shots</td>
				<td class="row1" align="center" rowspan="2">HeadShots</td>
				<td class="row1" align="center" rowspan="2">Efficiency.</td>
				<td class="row1" align="center" rowspan="2">Accuracy.</td>
				<td class="row1" align="center" rowspan="2">Accuracy<br />HeadShots.</td>
				<td class="row1" align="center" rowspan="2">K/D Rate.</td>
				<td class="row1" align="left"   colspan="7">HIT POSITION.</td>
			</tr>
			<tr>
				<td class="row1" align="center">HEAD</td>
				<td class="row1" align="center">CHEST</td>
				<td class="row1" align="center">STOMACH</td>
				<td class="row1" align="center">LEFT ARM</td>
				<td class="row1" align="center">RIGHT ARM</td>
				<td class="row1" align="center">LEFT LEG</td>
				<td class="row1" align="center">RIGHT LEG</td>
<!--			<td class="row1" align="center">SHILED (NOT WORKING)</td>-->
			</tr>
			{% for record in data.stats %}
			<tr>
				<td><img src="images/weapons/{{ record.wpn_name }}.png" height="32"/></td>
				<td>{{ record.wpn_name }}</td>
				<td>{{ record.csx_score }}</td>
				<td>{{ record.csx_kills }}</td>
<!--			<td>{{ record.csx_deaths }}</td>-->
				<td>{{ record.csx_tks }}</td>
				<td>{{ record.csx_hits }}</td>
				<td>{{ record.csx_dmg }}</td>
				<td>{{ record.csx_shots }}</td>
				<td>{{ record.csx_hs }}</td>
				<td>{{ record.efficiency }}</td>
				<td>{{ record.accuracy }}</td>
				<td>{{ record.accuracyHS }}</td>
				<td>{{ record.kdrate }}</td>
				<td>{{ record.h_head }}</td>
				<td>{{ record.h_chest }}</td>
				<td>{{ record.h_stomach }}</td>
				<td>{{ record.h_larm }}</td>
				<td>{{ record.h_rarm }}</td>
				<td>{{ record.h_lleg }}</td>
				<td>{{ record.h_rleg }}</td>
<!--			<td>{{ record.h_shield }}</td>-->
			</tr>
			{% endfor %}
		</table>
	</body>
</html>