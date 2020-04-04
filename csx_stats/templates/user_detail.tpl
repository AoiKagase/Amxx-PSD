{% extends 'inc_base.tpl' %}
{% block title   %}User Status{% endblock %}
{% block content %}

		<div class="card border-dark mb-3">
			<div class="card-header">Player Infomation.</div>
			<div class="card-body">
				<h4 class="card-title">{{ info.name }}</h4>
				<div class="row">
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.csx_rank }}</h4>
						<p class="card-text">Rank</p>
					</div>
				</div>
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.csx_score }}</h4>
						<p class="card-text">Score</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.csx_kills }}</h4>
						<p class="card-text">Kills</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.csx_deaths }}</h4>
						<p class="card-text">Deaths</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.kdrate }}</h4>
						<p class="card-text">K/D</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.efficiency }}</h4>
						<p class="card-text">Efficiency</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.accuracy }}</h4>
						<p class="card-text">Accuracy</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.accuracyHS }}</h4>
						<p class="card-text">Accuracy<br />HeadShots</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ team.WIN }}</h4>
						<p class="card-text">Win</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ info.online_time }}</h4>
						<p class="card-text">Play Time</p>
					</div>
				</div>				   
				</div>
			</div>
		</div>
		<table class="table table-hover">
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
			{% for record in wstats %}
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