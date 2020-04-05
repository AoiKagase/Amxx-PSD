	<div id="WeaponDetail{{ loop.index0 }}" class="modal fade" role="dialog" aria-labelledby="WeaponDetail{{ loop.index0 }}" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
		<div class="modal-header">
			<h3 class="modal-title"><img src="images/weapons/{{ record.wpn_name }}.png" height="64"/>{{ record.wpn_name }}</h3>
			<button type="button" class="close" data-dismiss="modal" aria-label="Close">
			<span aria-hidden="true">&times;</span>
			</button>		
		</div>
		<div class="row">
		<div class="modal-body">
			<table>
				<tbody>
				<tr>
					<th scope="row">HEAD</th>
					<td>{{ record.h_head }}</td>
				</tr>
				<tr>
					<th scope="row">CHEST</th>
					<td>{{ record.h_chest }}</td>
				</tr>
				<tr>
					<th scope="row">STOMACH</th>
					<td>{{ record.h_stomach }}</td>
				</tr>
				<tr>
					<th scope="col">LEFT ARM</th>
					<td>{{ record.h_larm }}</td>
				</tr>
				<tr>
					<th scope="col">RIGHT ARM</th>
					<td>{{ record.h_rarm }}</td>
				</tr>
				<tr>
					<th scope="col">LEFT LEG</th>
					<td>{{ record.h_lleg }}</td>
				</tr>
				<tr>
					<th scope="col">RIGHT LEG</th>
					<td>{{ record.h_rleg }}</td>
				</tr>
		<!--			<th scope="col">SHILED (NOT WORKING)</th>-->
		<!--			<td>{{ record.h_shield }}</td>-->
				</tbody>
			</table>
		</div>
		<div class="modal-body">
			<img src="data:image/png;base64,{{ attribute(hitimg, record.wpn_name) }}"/>
		</div>
		</div>
		<div class="modal-footer">
			<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
		</div>
		</div>
	</div>
	</div>

