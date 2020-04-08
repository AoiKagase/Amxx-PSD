{% extends 'inc_base.tpl' %}
{% block title   	%}User Status{% endblock %}
{% block javascript %}
<script type="text/javascript">
$(function() {
	$('.chart').easyPieChart({
		// your configuration goes here
		// easing:'easeOutQuart',
		barColor:'rgba(0,255,0,1.0)',
		trackColor:'rgba(255,0,0,1.0)',
		lineCap:'square',
		lineWidth: 12,
		trackWidth: 12,
		scaleLength:0,
		scaleColor:false,
		size:100,
		animate:{ duration: 1000, enabled: true },
		rotate:30,
		onStep: function(from, to, percent) {
			$(this.el).find('.percent').text(Math.round(percent));
		}
	});
});
</script>
{% endblock %}
{% block stylesheet %}
{% endblock %}
{% block content 	%}

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
						<h4 class="card-title">{{ total.csx_shots }}</h4>
						<p class="card-text">Shots</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.csx_hs }}</h4>
						<p class="card-text">HeadShots</p>
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
						<h4 class="card-title">{{ total.efficiency }}%</h4>
						<p class="card-text">Efficiency</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.accuracy }}%</h4>
						<p class="card-text">Accuracy</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<h4 class="card-title">{{ total.accuracyHS }}%</h4>
						<p class="card-text">Accuracy<br />HeadShots</p>
					</div>
				</div>				   
				<div class="card border-light mb-3" style="min-width:10rem; max-width: 10rem;">
					<div class="card-body">
						<div class="chart" data-percent="{{ team.win_percent }}">
						<h4 class="percent">
							{{ team.win_percent }}
						</h4>
						</div>
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
				<td scope="col" colspan="2">Weapon</td>
				<td scope="col">Kills</td>
<!--			<td scope="col">Deaths</td>-->
				<td scope="col">TeamKills</td>
				<td scope="col">Hits</td>
				<td scope="col">Damages</td>
				<td scope="col">Shots</td>
				<td scope="col">HeadShots</td>
<!--
				<td scope="col">Efficiency.</td>
				<td scope="col">Accuracy.</td>
				<td scope="col">Accuracy<br />HeadShots.</td>
				<td scope="col">K/D Rate.</td>
-->
			</tr>
			</thead>
			<tbody>
			{% for record in wstats %}
			<tr class="table-dark" 
				data-toggle="modal"
				data-id="1"
				data-target="#WeaponDetail{{loop.index0}}">
				<th scope="row"><img src="images/weapons/{{ record.wpn_name }}.png" height="32"/></th>
				<td>{{ record.wpn_name }}</td>
				<td>{{ record.csx_kills }}</td>
<!--			<td>{{ record.csx_deaths }}</td>-->
				<td>{{ record.csx_tks }}</td>
				<td>{{ record.csx_hits }}</td>
				<td>{{ record.csx_dmg }}</td>
				<td>{{ record.csx_shots }}</td>
				<td>{{ record.csx_hs }}{% include 'inc_wpn_detail.tpl' %}</td>
				
<!--
				<td>{{ record.efficiency }}</td>
				<td>{{ record.accuracy }}</td>
				<td>{{ record.accuracyHS }}</td>
				<td>{{ record.kdrate }}</td>
-->
			</tr>
			{% endfor %}
		</table>
{% endblock %}