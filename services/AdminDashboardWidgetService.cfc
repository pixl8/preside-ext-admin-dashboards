/**
 * @presideService true
 * @singleton      true
 */
component {

// CONSTRUCTOR
	/**
	 * @formsService.inject formsService
	 *
	 */
	public any function init( required any formsService ) {
		_setFormsService( arguments.formsService );

		return this;
	}

// PUBLIC API METHODS
	public string function renderDashboard( required string dashboardId, required array widgets ) {
		var rendered = "";

		for( var widgetId in widgets ) {
			if ( userCanViewWidget( widgetId ) ) {
				rendered &= renderWidgetContainer( arguments.dashboardId, widgetId );
			}
		}

		return rendered;
	}

	public string function renderWidgetContainer( required string dashboardId, required string widgetId ) {
		return $renderViewlet( event="admin.admindashboards.widgetContainer", args={
			  title       = $translateResource( uri="admin.admindashboards.widget.#widgetId#:title"      , defaultValue=widgetId )
			, icon        = $translateResource( uri="admin.admindashboards.widget.#widgetId#:iconClass"  , defaultValue="" )
			, description = $translateResource( uri="admin.admindashboards.widget.#widgetId#:description", defaultValue="" )
			, widgetId    = arguments.widgetId
			, hasConfig   = widgetHasConfigForm( arguments.widgetId )
		} );
	}

	public string function renderWidgetContent( required string dashboardId, required string widgetId ) {
		return $renderViewlet( event="admin.admindashboards.widget.#widgetId#.render", args={
			  dashboardId = arguments.dashboardId
			, config      = getWidgetConfiguration( arguments.dashboardId, arguments.widgetId )
		} );
	}

	public string function renderWidgetConfigForm( required string dashboardId, required string widgetId ) {
		return _getFormsService().renderForm(
			  formName  = "admin.admindashboards.widget.#widgetId#"
			, savedData = getWidgetConfiguration( arguments.dashboardId, arguments.widgetId )
		);
	}

	public boolean function widgetHasConfigForm( required string widgetId ) {
		return _getFormsService().formExists( "admin.admindashboards.widget.#widgetId#" );
	}

	public void function saveWidgetConfiguration( required string dashboardId, required string widgetId, required struct requestData ) {
		var fields  = _getFormsService().listFields( formName="admin.admindashboards.widget.#widgetId#" );
		var config  = {};

		for( var field in fields ) {
			config[ field ] = arguments.requestData[ field ] ?: "";
		}

		var existed = $getPresideObject( "admin_dashboard_widget_configuration" ).updateData(
			  filter = { dashboard_id=arguments.dashboardId, widget_id=arguments.widgetId, user=$getAdminLoggedInUserId() }
			, data   = { config = SerializeJson( config ) }
		);

		if ( !existed ) {
			$getPresideObject( "admin_dashboard_widget_configuration" ).insertData( {
				  dashboard_id = arguments.dashboardId
				, widget_id    = arguments.widgetId
				, user         = $getAdminLoggedInUserId()
				, config       = SerializeJson( config )
			} );
		}
	}

	public struct function getWidgetConfiguration( required string dashboardId, required string widgetId ) {
		var configRecord = $getPresideObject( "admin_dashboard_widget_configuration" ).selectData( filter={
			    dashboard_id = arguments.dashboardId
			  , widget_id    = arguments.widgetId
			  , user         = $getAdminLoggedInUserId()
		} );
		var result = {};

		try {
			result = DeserializeJson( configRecord.config ?: "" );
		} catch( any e ) {
			result = {};
		}

		return IsStruct( result ) ? result : {};
	}

	public boolean function userCanViewWidget( required string widgetId ) {
		var coldbox         = $getColdbox();
		var permissionEvent = "admin.admindashboards.widget.#widgetId#.hasPermission";
		var result          = true;

		if ( coldbox.handlerExists( permissionEvent ) ) {
			result = coldbox.runEvent(
				  event         = permissionEvent
				, private       = true
				, prePostExempt = true
			);
		}

		return IsBoolean( result ?: "" ) && result;
	}

// GETTERS AND SETTERS
	private any function _getFormsService() {
		return _formsService;
	}
	private void function _setFormsService( required any formsService ) {
		_formsService = arguments.formsService;
	}

}