<cfscript>
	var snapshotRecord = prc.snapshotRecord ?: {};
	var snapshotData   = prc.snapshotData   ?: [];
	var status         = snapshotRecord.status ?: "";
	var hasData        = IsArray( snapshotData ) && ArrayLen( snapshotData );
	var columns        = hasData ? StructKeyArray( snapshotData[ 1 ] ) : [];
</cfscript>

<cfoutput>
	<div class="row">
		<div class="col-sm-12">
			<div class="well">
				<div class="row">
					<div class="col-sm-3">
						<strong>#translateResource( "preside-objects.admin_dashboard_snapshot:field.schema_id.title" )#</strong><br>
						<code>#snapshotRecord.schema_id#</code>
					</div>
					<div class="col-sm-3">
						<strong>#translateResource( "preside-objects.admin_dashboard_snapshot:field.snapshot_date.title" )#</strong><br>
						#DateTimeFormat( snapshotRecord.snapshot_date, "dd mmm yyyy HH:mm" )#
					</div>
					<div class="col-sm-2">
						<strong>#translateResource( "preside-objects.admin_dashboard_snapshot:field.status.title" )#</strong><br>

						<cfswitch expression="#status#">
							<cfcase value="complete"><span class="label label-success">#translateResource( "enum.adminDashboardSnapshotStatus:complete.label" )#</span></cfcase>
							<cfcase value="failed"><span class="label label-danger">#translateResource( "enum.adminDashboardSnapshotStatus:failed.label" )#</span></cfcase>
							<cfcase value="running"><span class="label label-warning">#translateResource( "enum.adminDashboardSnapshotStatus:running.label" )#</span></cfcase>
							<cfdefaultcase><span class="label label-default">#translateResource( "enum.adminDashboardSnapshotStatus:pending.label" )#</span></cfdefaultcase>
						</cfswitch>

					</div>
					<div class="col-sm-2">
						<strong>#translateResource( "preside-objects.admin_dashboard_snapshot:field.record_count.title" )#</strong><br>
						#NumberFormat( snapshotRecord.record_count )#
					</div>
					<div class="col-sm-2">
						<strong>#translateResource( "preside-objects.admin_dashboard_snapshot:field.triggered_by.title" )#</strong><br>
						#translateResource( uri="enum.adminDashboardSnapshotTrigger:#snapshotRecord.triggered_by#.label", defaultValue=snapshotRecord.triggered_by )#
					</div>
				</div>

				<cfif Len( snapshotRecord.error_message ?: "" )>
					<div class="row" style="margin-top:10px">
						<div class="col-sm-12">
							<div class="alert alert-danger">
								<strong>#translateResource( "preside-objects.admin_dashboard_snapshot:field.error_message.title" )#:</strong>
								#HtmlEditFormat( snapshotRecord.error_message )#
							</div>
						</div>
					</div>
				</cfif>
			</div>
		</div>
	</div>

	<cfif hasData>
		<h3>#translateResource( "preside-objects.admin_dashboard_snapshot:viewRecord.data.heading" )#</h3>
		<div class="table-responsive">
			<table class="table table-hover table-condensed table-bordered">
				<thead>
					<tr>

						<cfloop array="#columns#" item="col">
							<th>#HtmlEditFormat( col )#</th>
						</cfloop>

					</tr>
				</thead>
				<tbody>

					<cfloop array="#snapshotData#" item="row">
						<tr>
							<cfloop array="#columns#" item="col">
								<td>#HtmlEditFormat( row[ col ] ?: "" )#</td>
							</cfloop>
						</tr>
					</cfloop>

				</tbody>
			</table>
		</div>
	<cfelse>
		<p class="alert alert-info">
			<cfif status == "failed">
				#translateResource( "preside-objects.admin_dashboard_snapshot:viewRecord.data.failed" )#
			<cfelse>
				#translateResource( "preside-objects.admin_dashboard_snapshot:viewRecord.data.empty" )#
			</cfif>
		</p>
	</cfif>
</cfoutput>