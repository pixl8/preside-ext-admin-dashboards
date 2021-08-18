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

		if ( IsArray( settings.adminRoles.sysadmin ?: "" ) ) {
			ArrayAppend( settings.adminRoles.sysadmin, "adminDashboards.*" );
		}
		if ( IsArray( settings.adminRoles.contentadmin ?: "" ) ) {
			ArrayAppend( settings.adminRoles.contentadmin, "adminDashboards.*" );
		}
		if ( IsArray( settings.adminRoles.contenteditor ?: "" ) ) {
			ArrayAppend( settings.adminRoles.contenteditor, "adminDashboards.*" );
		}
	}
}