<cfscript>
	activeDashboard     = args.activeDashboard     ?: {};
	availableDashboards = args.availableDashboards ?: [];
</cfscript>

<cfoutput>
	<div class="dashboard-selector">
		<span class="dashboard-selector-label">#translateResource( uri="admindashboards:selector.label" )#</span>

		<div class="dropdown">
			<button id="dashboard-selector" type="button" class="btn btn-light" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
				#activeDashboard.title ?: translateResource( uri="admindashboards:selector.current.default.label" )# <span class="caret"></span>
			</button>

			<cfif ArrayLen( availableDashboards )>
				<ul class="dropdown-menu dropdown-menu-dashboard" aria-labelledby="dashboard-selector">
					<cfloop array="#availableDashboards#" item="dashboard">
						<li>
							#renderView( view="/admin/admindashboards/dashboardSelector/_itemList", args=dashboard )#
						</li>
					</cfloop>
				</ul>
			</cfif>
		</div>
	</div>
</cfoutput>