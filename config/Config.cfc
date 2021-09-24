component {

	public void function configure( required struct config ) {
		var conf = arguments.config;

		_setupInterceptors( conf );
	}

// PRIVATE HELPERS
	private void function _setupInterceptors( conf ) {
		conf.interceptorSettings.customInterceptionPoints = conf.interceptorSettings.customInterceptionPoints ?: [];
		conf.interceptorSettings.customInterceptionPoints.append( "onRenderAdminWidgetContainer" );
	}
}