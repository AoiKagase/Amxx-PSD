{% extends 'inc_base.tpl' %}
{% block title   %}User Status{% endblock %}
{% block content %}
		<table>
			<thead>
			<tr>
				<td>
					<span class="genmed"><b>{{ data.info['name'] }}</b></span>
					<span class="genmed"><b>{{ data.info['online_time'] }}</b></span>
					<span class="genmed"><b>User Rank</b></span>
				</td>
			</tr>
			</thead>
		</table>
		<table width="100%" cellpadding="0" cellspacing="0" class="table table-hover">
			<thead>
			<tr>
				<td scope="col" rowspan="2" colspan="2">Weapon</td>
				<td scope="col" rowspan="2">Kills</td>
<!--			<td scope="col" rowspan="2">Deaths</td>-->
				<td scope="col" rowspan="2">TeamKills</td>
				<td scope="col" rowspan="2">Hits</td>
				<td scope="col" rowspan="2">Damages</td>
				<td scope="col" rowspan="2">Shots</td>
				<td scope="col" rowspan="2">HeadShots</td>
				<td scope="col" rowspan="2">Efficiency.</td>
				<td scope="col" rowspan="2">Accuracy.</td>
				<td scope="col" rowspan="2">Accuracy<br />HeadShots.</td>
				<td scope="col" rowspan="2">K/D Rate.</td>
				<td scope="col" colspan="7">HIT POSITION.</td>
			</tr>
			<tr>
				<td scope="col">HEAD</td>
				<td scope="col">CHEST</td>
				<td scope="col">STOMACH</td>
				<td scope="col">LEFT ARM</td>
				<td scope="col">RIGHT ARM</td>
				<td scope="col">LEFT LEG</td>
				<td scope="col">RIGHT LEG</td>
<!--			<td scope="col">SHILED (NOT WORKING)</td>-->
			</tr>
			</thead>
			<tbody>
			{% for record in data.stats %}
			<tr class="table-dark">
				<th scope="row"><img src="images/weapons/{{ record.wpn_name }}.png" height="32"/></th>
				<td>{{ record.wpn_name }}</td>
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
{% endblock %}