component {
	property name="adminDashboardService" inject="adminDashboardService";

	private void function prepare( event, rc, prc, args={} ) {
		args.subMenuItems  = args.subMenuItems ?: [];
		var userDashboards = adminDashboardService.getUserDashboards( orderBy="datemodified desc", maxRows=5 );

		if ( userDashboards.recordcount ) {
			for ( var dashboard in userDashboards ) {
				var dashboardId = dashboard.id;

				ArrayAppend( args.subMenuItems, {
					  id    = dashboardId
					, title = dashboard.name
					, icon  = "fa-tachometer"
					, active = ( rc.id ?: "" ) == dashboardId
					, link = event.buildAdminLink( objectName="admin_dashboard", recordId=dashboardId )
				} );
			}

			ArrayAppend( args.subMenuItems, "<li class='divider'></li>" )
			ArrayAppend( args.subMenuItems, {
				  title  = translateResource( uri="preside-objects.admin_dashboard:sidenav.all.label" )
				, icon   = "fa-tachometer"
				, active = ( rc.id ?: "" ) == dashboardId
				, link   = event.buildAdminLink( objectName="admin_dashboard" )
			} );
		}
	}
}