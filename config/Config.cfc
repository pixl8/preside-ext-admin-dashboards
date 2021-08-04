component {

	public void function configure( required struct config ) {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		_setupEnums( settings );
		_setupPermissionsAndRoles( settings );

		settings.adminConfigurationMenuItems.append( "adminDashboards" );
	}

	private void function _setupEnums( settings ) {
		settings.enum.adminDashboardViewAccess = [ "private", "public", "specific" ];
		settings.enum.adminDashboardEditAccess = [ "private", "specific" ];
	}

	private void function _setupPermissionsAndRoles( required struct settings ) {
		settings.adminPermissions.adminDashboards = [ "navigate", "read", "add", "edit", "clone", "delete" ];

		settings.adminRoles.sysadmin.append( "adminDashboards.*" );
		settings.adminRoles.contentadmin.append( "adminDashboards.*" );
		settings.adminRoles.contenteditor.append( "adminDashboards.*" );
	}
}