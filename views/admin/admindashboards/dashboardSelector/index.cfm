<cfscript>
	i18nDashboardSelectorLabel = "Dashboard:";

	// Static example, please update accordingly in the proper BE implementation
	activeDashboard = { title="Conference", subTitle="Description goes here" }

	staticDashboardList   = [
		{
			  icon    = "fa-chart-pie"
			, heading = "Templates"
			, items   = [
				  { title="Conference"  , subTitle="Description goes here", active=true }
				, { title="Zoom webinar", subTitle="Description goes here" }
				, { title="Post event"  , subTitle="Description goes here" }
			]
		}
		, {
			  icon    = "fa-user"
			, heading = "Created by me"
			, items   = [
				  { title="Dashboard name", subTitle="Description goes here" }
				, { title="Dashboard name", subTitle="Description goes here" }
				, { title="Dashboard name", subTitle="Description goes here" }
			]
		}
		, {
			  icon    = "fa-eye"
			, heading = "View access only"
			, items   = [
				  { title="Dashboard name", subTitle="Description goes here" }
				, { title="Dashboard name", subTitle="Description goes here" }
				, { title="Dashboard name", subTitle="Description goes here" }
			]
		}
	]
</cfscript>

<cfoutput>
	<div class="dashboard-selector">
		<span class="dashboard-selector-label">#i18nDashboardSelectorLabel#</span>
		<div class="dropdown">
			<button id="dashboard-selector" type="button" class="btn btn-light" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
				#activeDashboard.title# <span class="caret"></span>
			</button>
			<ul class="dropdown-menu dropdown-menu-dashboard" aria-labelledby="dashboard-selector">
				<cfloop array="#staticDashboardList#" item="dashboardList">
					<li>
						#renderView( view="/admin/admindashboards/dashboardSelector/_itemList", args=dashboardList )#
					</li>
				</cfloop>
			</ul>
		</div>
	</div>
</cfoutput>