component {
	property name="adminDashboardService" inject="adminDashboardService";

	private void function prepare( event, rc, prc, args={} ) {
		args.subMenuItems  = args.subMenuItems ?: [];
		var userDashboards       = adminDashboardService.getUserDashboards(           orderBy="datemodified desc", maxRows=5 );
		var accessibleDashboards = adminDashboardService.getUserAccessibleDashboards( orderBy="datemodified desc", maxRows=5, extraFilters=[ {
			  filter       = "admin_dashboard.id NOT IN (:excludedDashboardIds)"
			, filterParams = { excludedDashboardIds={
				  type  = "cf_sql_varchar"
				, value = userDashboards.recordcount ? ValueList( userDashboards.id ) : ""
				, list  = true
			} }
		} ] );

		if ( userDashboards.recordcount || accessibleDashboards.recordcount ) {
			for ( var dashboard in userDashboards ) {
				ArrayAppend( args.subMenuItems, {
					  title  = dashboard.name
					, icon   = "fa-tachometer"
					, link   = event.buildAdminLink( objectName="admin_dashboard", recordId=dashboard.id )
					, active = ( rc.id ?: "" ) == dashboard.id
				} );
			}

			for ( var dashboard in accessibleDashboards ) {
				ArrayAppend( args.subMenuItems, {
					  title  = dashboard.name
					, icon   = "fa-tachometer"
					, link   = event.buildAdminLink( objectName="admin_dashboard", recordId=dashboard.id )
					, active = ( rc.id ?: "" ) == dashboard.id
				} );
			}

			ArrayAppend( args.subMenuItems, "<li class='divider'></li>" )
			ArrayAppend( args.subMenuItems, {
				  title = translateResource( uri="preside-objects.admin_dashboard:sidenav.all.label" )
				, icon  = "fa-tachometer"
				, link  = event.buildAdminLink( objectName="admin_dashboard" )
			} );
		}
	}

	private boolean function isActive( event, rc, prc, args={} ) {
		var objName  = prc.objectName ?: "";
		var recordId = prc.recordId   ?: "";

		return ( objName == "admin_dashboard" ) && isEmptyString( recordId );
	}
}