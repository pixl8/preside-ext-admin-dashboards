/**
 * @presideService true
 * @singleton      true
 */
component {

// CONSTRUCTOR
	/**
	 *
	 */
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public boolean function userCanViewDashboard( required string adminUserId, required string dashboardId ) {
		var adminUserGroups = _getAdminUserGroups( arguments.adminUserId );

		return $getPresideObject( "admin_dashboard" ).dataExists(
			  filter       = { "admin_dashboard.id"=arguments.dashboardId }
			, extraFilters = [ {
				  filter       = "view_access = 'public'
						or admin_dashboard.owner = :adminUserId
						or ( view_access = 'specific' and ( view_users.id = :adminUserId or view_groups.id in ( :adminUserGroups ) ) )
						or ( edit_access = 'specific' and ( edit_users.id = :adminUserId or edit_groups.id in ( :adminUserGroups ) ) )"
				, filterParams = {
					  adminUserId     = { type="varchar", value=adminUserId }
					, adminUserGroups = { type="varchar", value=adminUserGroups, list=true }
				  }
			  } ]
		);
	}

	public boolean function userCanEditDashboard( required string adminUserId, required string dashboardId ) {
		return $getPresideObject( "admin_dashboard" ).dataExists(
			  filter       = { "admin_dashboard.id"=arguments.dashboardId }
			, extraFilters = [ {
				  filter       = "admin_dashboard.owner = :adminUserId
						or ( edit_access = 'specific' and ( edit_users.id = :adminUserId or edit_groups$users.id = :adminUserId ) )"
				, filterParams = { adminUserId={ type="varchar", value=arguments.adminUserId } }
			} ]
		);
	}

	public boolean function userCanDeleteDashboard( required string adminUserId, required string dashboardId ) {
		return $getPresideObject( "admin_dashboard" ).dataExists(
			filter = { id=arguments.dashboardId, owner=arguments.adminUserId }
		);
	}

// PRIVATE HELPERS
	private string function _getAdminUserGroups( required string adminUserId ) {
		return $getPresideObject( "security_group" ).selectData(
			  filter       = { "users.id"=arguments.adminUserId }
			, selectFields = [ "id" ]
		).valueList( "id" );
	}


// GETTERS AND SETTERS

}