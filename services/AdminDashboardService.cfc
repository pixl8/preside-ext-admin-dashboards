/**
 * @presideService true
 * @singleton      true
 */
component {
	property name="permissionService" inject="PermissionService";

// CONSTRUCTOR
	/**
	 *
	 */
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public query function getUserDashboards(
		  string  adminUserId  = $getAdminLoggedInUserId()
		, array   extraFilters = []
		, string  orderBy      = "name"
		, numeric maxRows      = 0
	) {
		return $getPresideObject( "admin_dashboard" ).selectData(
			  filter       = { owner=arguments.adminUserId }
			, extraFilters = arguments.extraFilters
			, orderBy      = arguments.orderBy
			, maxRows      = arguments.maxRows
		);
	}

	public query function getUserAccessibleDashboards(
		  string  adminUserId  = $getAdminLoggedInUserId()
		, array   extraFilters = []
		, string  orderBy      = "name"
		, numeric maxRows      = 0
		, string  groupBy      = "admin_dashboard.id"
	) {
		var adminUserGroups = _getAdminUserGroups( adminUserId=arguments.adminUserId );

		return $getPresideObject( "admin_dashboard" ).selectData(
			  filter = "view_access = 'public'
						OR admin_dashboard.owner = :adminUserId
						OR ( view_access = 'specific' AND ( view_users.id = :adminUserId OR view_groups.id in ( :adminUserGroups ) ) )
						OR ( edit_access = 'specific' AND ( edit_users.id = :adminUserId OR edit_groups.id in ( :adminUserGroups ) ) )"
			, filterParams = {
				  adminUserId     = { type="varchar", value=arguments.adminUserId }
				, adminUserGroups = { type="varchar", value=adminUserGroups, list=true }
			}
			, extraFilters = arguments.extraFilters
			, orderBy      = arguments.orderBy
			, maxRows      = arguments.maxRows
			, groupBy      = arguments.groupBy
		);
	}

	public boolean function userCanViewDashboard( required string dashboardId, string adminUserId=$getAdminLoggedInUserId() ) {
		if ( hasFullAccess( arguments.adminUserId ) ) {
			return true;
		}

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

	public boolean function userCanEditDashboard( required string dashboardId, string adminUserId=$getAdminLoggedInUserId() ) {
		if ( hasFullAccess( arguments.adminUserId ) ) {
			return true;
		}

		return $getPresideObject( "admin_dashboard" ).dataExists(
			  filter       = { "admin_dashboard.id"=arguments.dashboardId }
			, extraFilters = [ {
				  filter       = "admin_dashboard.owner = :adminUserId
						or ( edit_access = 'specific' and ( edit_users.id = :adminUserId or edit_groups$users.id = :adminUserId ) )"
				, filterParams = { adminUserId={ type="varchar", value=arguments.adminUserId } }
			} ]
		);
	}

	public boolean function userCanShareDashboard( required string dashboardId, string adminUserId=$getAdminLoggedInUserId() ) {
		if ( hasFullAccess( arguments.adminUserId ) ) {
			return true;
		}

		return $getPresideObject( "admin_dashboard" ).dataExists(
			filter = { id=arguments.dashboardId, owner=arguments.adminUserId }
		);
	}

	public boolean function userCanDeleteDashboard( required string dashboardId, string adminUserId=$getAdminLoggedInUserId() ) {
		if ( hasFullAccess( arguments.adminUserId ) ) {
			return true;
		}

		return $getPresideObject( "admin_dashboard" ).dataExists(
			filter = { id=arguments.dashboardId, owner=arguments.adminUserId }
		);
	}

	public boolean function hasFullAccess( required string adminUserId ) {
		return permissionService.hasPermission( permissionKey="adminDashboards.fullaccess", userId=arguments.adminUserId );
	}

	public boolean function isDashboardUsingGridLayout( required string dashboardId ) {
		return $getPresideObject( "admin_dashboard" ).dataExists(
			filter = { id=arguments.dashboardId, dashboard_layout="grid" }
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