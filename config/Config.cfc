component {

	public void function configure( required struct config ) {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		_setupEnums( settings );
		_setupPermissionsAndRoles( settings );
		_setupInterceptors( conf );
		_setupFeatures( settings );

		settings.adminConfigurationMenuItems.append( "adminDashboards" );
	}

	private void function _setupEnums( settings ) {
		settings.enum.adminDashboardViewAccess = [ "private", "public", "specific" ];
		settings.enum.adminDashboardEditAccess = [ "private", "specific" ];
		settings.enum.adminDashboardLayout     = [ "column" , "grid" ];
	}

	private void function _setupPermissionsAndRoles( required struct settings ) {
		settings.adminPermissions.adminDashboards = [ "navigate", "read", "add", "edit", "clone", "delete", "fullaccess" ];

		settings.adminRoles.dashBoardSuperAdmin = [ "adminDashboards.*" ];
		settings.adminRoles.dashBoardAdmin      = [ "adminDashboards.*", "!adminDashboards.fullaccess" ];
		settings.adminRoles.dashBoardUser       = [ "adminDashboards.navigate", "adminDashboards.read" ];
	}

	private void function _setupFeatures( settings ) {
		settings.features.adminDashboardsGridLayout = { enabled=false };
	}

// PRIVATE HELPERS
	private void function _setupInterceptors( conf ) {
		conf.interceptorSettings.customInterceptionPoints = conf.interceptorSettings.customInterceptionPoints ?: [];
		conf.interceptorSettings.customInterceptionPoints.append( "onRenderAdminWidgetContainer" );
	}
}