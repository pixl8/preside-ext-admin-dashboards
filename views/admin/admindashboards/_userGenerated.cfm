<cfscript>
	dashboardId      = args.id           ?: "";
	widgets          = args.widgets      ?: [];
	columns          = args.column_count ?: 1;
	columns          = val( columns ) ? columns : 1;
	columnWidth      = int( 12 / columns );
	canEditDashboard = isTrue( args.canEdit ?: "" );

	addTitle         = translateResource( "preside-objects.admin_dashboard:widget.add.btn" );
	addLink          = event.buildAdminLink( linkTo="adminDashboards.widgetDialog", queryString="dashboard=#dashboardId#&column={column}" );
</cfscript>

<cfoutput>
	<div class="admin-dashboard-container" data-dashboard-id="#dashboardId#">
		<div class="row">
			<cfloop from="1" to="#columns#" index="c">
				<div class="dashboard-column col-md-#columnWidth#" data-column="#c#">
					<div class="dashboard-column-content">
						#ArrayToList( widgets[ c ], "" )#
					</div>

					<cfif canEditDashboard>
						<div class="dashboard-column-add">
							<a href="#replace( addLink, "{column}", c )#" data-toggle="bootbox-modal" data-target="##add-widget-modal" data-buttons="cancel" data-modal-class="page-type-picker" title="#addTitle#">
								<button class="btn btn-success btn-sm">
									<i class="fa fa-fw fa-plus"></i>
									#addTitle#
								</button>
							</a>
						</div>
					</cfif>
				</div>
			</cfloop>
		</div>

		<script type="text/template" class="error-template">
			<p class="alert alert-error">
				<i class="fa fa-fw fa-exclamation-triangle"></i>
				#translateResource( "admindashboards:widget.failed.to.load.message" )#
			</p>
		</script>
	</div>
</cfoutput>