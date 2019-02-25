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
	public string function renderDashboard(
		  required string  dashboardId
		, required array   widgets
		,          numeric columnCount = 2
		,          struct  contextData = {}
	) {
		var rendered = "";
		var colsize = 6;

		switch( arguments.columnCount ) {
			case 4:
				colsize = 3;
			break;
			case 3:
				colsize = 4;
			break;
			case 1:
				colsize = 12
			break;
			default:
				colsize = 6;
		}

		for( var widget in widgets ) {
			if ( isSimpleValue( widget ) ) {
				widget = {
					  id          = widget
					, contextData = arguments.contextData
				};
			} else {
				widget.id          = widget.id ?: "";
				widget.contextData = widget.contextData ?: {};
				widget.contextData.append( arguments.contextData, false );
			}

			widget.configInstanceId = widget.configInstanceId ?: LCase( Hash( SerializeJson( widget.contextData ) ) );
			widget.ajax             = !IsBoolean( widget.ajax ?: "" ) || widget.ajax;

			if ( userCanViewWidget( widget.id ) ) {
				rendered &= renderWidgetContainer(
					  dashboardId      = arguments.dashboardId
					, widgetId         = widget.id
					, columnSize       = colsize
					, contextData      = _namespaceContextData( widget.contextData )
					, configInstanceId = widget.configInstanceId
					, ajax             = widget.ajax
				);
			}
		}

		return rendered;
	}

	public string function renderWidgetContainer(
		  required string  dashboardId
		, required string  widgetId
		,          numeric columnSize       = 6
		,          struct  contextData      = {}
		,          string  configInstanceId = ""
		,          boolean ajax             = true
	) {
		var instanceId     = "dashboard-widget-" & LCase( Hash( arguments.dashboardId & arguments.widgetId & SerializeJson( arguments.contextData ) ) );
		var menuViewlet    = "admin.admindashboards.widget.#arguments.widgetId#.additionalMenu";
		var additionalMenu = "";
		var content        = "";

		if ( $getColdbox().viewletExists( menuViewlet ) ) {
			additionalMenu = $renderViewlet( event=menuViewlet, args=arguments );
		}

		if ( !arguments.ajax ) {
			content = renderWidgetContent(
				  dashboardId = arguments.dashboardId
				, widgetId    = arguments.widgetId
				, instanceId  = instanceId
				, requestData = contextData
			);
		}

		return $renderViewlet( event="admin.admindashboards.widgetContainer", args={
			  title            = $translateResource( uri="admin.admindashboards.widget.#widgetId#:title"      , defaultValue=widgetId )
			, icon             = $translateResource( uri="admin.admindashboards.widget.#widgetId#:iconClass"  , defaultValue="" )
			, description      = $translateResource( uri="admin.admindashboards.widget.#widgetId#:description", defaultValue="" )
			, widgetId         = arguments.widgetId
			, columnSize       = arguments.columnSize
			, contextData      = arguments.contextData
			, ajax             = arguments.ajax
			, instanceId       = instanceId
			, configInstanceId = arguments.configInstanceId
			, hasConfig        = widgetHasConfigForm( arguments.widgetId )
			, additionalMenu   = additionalMenu
			, content          = content
		} );
	}

	public string function renderWidgetContent( required string dashboardId, required string widgetId, required string instanceId, required struct requestData ) {
		return $renderViewlet( event="admin.admindashboards.widget.#widgetId#.render", args={
			  dashboardId = arguments.dashboardId
			, config      = getWidgetConfiguration( arguments.dashboardId, arguments.widgetId, arguments.instanceId )
			, contextData = _getContextDataFromRequest( arguments.requestData )
		} );
	}

	public string function renderWidgetConfigForm( required string dashboardId, required string widgetId, required string instanceId ) {
		return _getFormsService().renderForm(
			  formName  = "admin.admindashboards.widget.#widgetId#"
			, savedData = getWidgetConfiguration( arguments.dashboardId, arguments.widgetId, arguments.instanceId )
		);
	}

	public boolean function widgetHasConfigForm( required string widgetId ) {
		return _getFormsService().formExists( "admin.admindashboards.widget.#widgetId#" );
	}

	public void function saveWidgetConfiguration( required string dashboardId, required string widgetId, required string instanceId, required struct requestData ) {
		var fields  = _getFormsService().listFields( formName="admin.admindashboards.widget.#widgetId#" );
		var config  = {};

		for( var field in fields ) {
			config[ field ] = arguments.requestData[ field ] ?: "";
		}

		var existed = $getPresideObject( "admin_dashboard_widget_configuration" ).updateData(
			  filter = { dashboard_id=arguments.dashboardId, widget_id=arguments.widgetId, instance_id=arguments.instanceId, user=$getAdminLoggedInUserId() }
			, data   = { config = SerializeJson( config ) }
		);

		if ( !existed ) {
			$getPresideObject( "admin_dashboard_widget_configuration" ).insertData( {
				  dashboard_id = arguments.dashboardId
				, widget_id    = arguments.widgetId
				, instance_id  = arguments.instanceId
				, user         = $getAdminLoggedInUserId()
				, config       = SerializeJson( config )
			} );
		}
	}

	public struct function getWidgetConfiguration( required string dashboardId, required string widgetId, required string instanceId ) {
		var configRecord = $getPresideObject( "admin_dashboard_widget_configuration" ).selectData( filter={
			    dashboard_id = arguments.dashboardId
			  , widget_id    = arguments.widgetId
			  , instance_id  = arguments.instanceId
			  , user         = $getAdminLoggedInUserId()
		} );

		// backwards compat: attempt to get config
		// record where instance ID is null if nothing found for
		// specific instance
		if ( !configRecord.recordCount ) {
			configRecord = $getPresideObject( "admin_dashboard_widget_configuration" ).selectData( filter={
				    dashboard_id = arguments.dashboardId
				  , widget_id    = arguments.widgetId
				  , instance_id  = ""
				  , user         = $getAdminLoggedInUserId()
			} );
		}

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

// PRVIATE HELPERS
	private struct function _namespaceContextData( required struct data ) {
		var namespaced = {};

		for( var key in arguments.data ){
			namespaced[ "dashboard.widget.data.#key#" ] = arguments.data[ key ];
		}

		return namespaced;
	}

	private struct function _getContextDataFromRequest( required struct requestData ) {
		var contextData = {};

		for( var key in arguments.requestData ) {
			if ( key.startsWith( "dashboard.widget.data." ) ) {
				contextData[ key.reReplace( "^dashboard\.widget\.data.", "" ) ] = arguments.requestData[ key ];
			}
		}

		return contextData;
	}


// GETTERS AND SETTERS
	private any function _getFormsService() {
		return _formsService;
	}
	private void function _setFormsService( required any formsService ) {
		_formsService = arguments.formsService;
	}

}