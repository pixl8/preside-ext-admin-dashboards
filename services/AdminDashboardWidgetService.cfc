/**
 * @presideService true
 * @singleton      true
 */
component {
// CONSTRUCTOR
	/**
	 * @configuredWidgets.inject       coldbox:setting:widgets
	 * @formsService.inject            FormsService
	 * @autoDiscoverDirectories.inject presidecms:directories
	 */
	public any function init(
		  required struct configuredWidgets
		, required any    formsService
		, required array  autoDiscoverDirectories
	) {
		_setAutoDicoverDirectories( arguments.autoDiscoverDirectories );
		_setConfiguredWidgets( arguments.configuredWidgets );
		_setFormsService( arguments.formsService );

		reload();

		return this;
	}

// PUBLIC API METHODS
	public struct function getWidgets() {
		var widgets = Duplicate( _getWidgets() );

		return widgets;
	}

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
					, title            = widget.title ?: ""
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
		,          string  title            = ""
		,          boolean ajax             = true
	) {
		var instanceId       = "dashboard-widget-" & LCase( Hash( arguments.dashboardId & arguments.widgetId & SerializeJson( arguments.contextData ) ) );
		var menuViewlet      = "admin.admindashboards.widget.#arguments.widgetId#.additionalMenu";
		var additionalMenu   = "";
		var content          = "";
		var isAdminDashboard = _isAdminDashboard( arguments.dashboardId );
		var canEditDashboard = $helpers.isTrue( arguments.contextData[ "dashboard.widget.data.canEditDashboard" ] ?: "" );

		if ( $getColdbox().viewletExists( menuViewlet ) ) {
			var args         = StructCopy( arguments );
			args.contextData = _getContextDataFromRequest( arguments.contextData );
			additionalMenu  &= $renderViewlet( event=menuViewlet, args=args );
		}

		if ( !arguments.ajax ) {
			content = renderWidgetContent(
				  dashboardId      = arguments.dashboardId
				, widgetId         = arguments.widgetId
				, instanceId       = instanceId
				, configInstanceId = configInstanceId
				, requestData      = arguments.contextData
			);
		}

		return $renderViewlet( event="admin.admindashboards.widgetContainer", args={
			  title            = !isEmpty( arguments.title ) ? arguments.title : $translateResource( uri="admin.admindashboards.widget.#widgetId#:title", defaultValue=widgetId )
			, icon             = $translateResource( uri="admin.admindashboards.widget.#widgetId#:iconClass"  , defaultValue="" )
			, description      = $translateResource( uri="admin.admindashboards.widget.#widgetId#:description", defaultValue="" )
			, widgetId         = arguments.widgetId
			, columnSize       = arguments.columnSize
			, contextData      = arguments.contextData
			, ajax             = arguments.ajax
			, instanceId       = instanceId
			, configInstanceId = arguments.configInstanceId
			, dashboardId      = arguments.dashboardId
			, hasConfig        = widgetHasConfigForm( arguments.widgetId ) && ( !isAdminDashboard || canEditDashboard )
			, canDeleteWidget  = isAdminDashboard && canEditDashboard
			, additionalMenu   = additionalMenu
			, content          = content
		} );
	}

	public string function renderWidgetContent( required string dashboardId, required string widgetId, required string instanceId, required string configInstanceId, required struct requestData ) {
		return $renderViewlet( event="admin.admindashboards.widget.#widgetId#.render", args={
			  dashboardId = arguments.dashboardId
			, config      = getWidgetConfiguration( arguments.dashboardId, arguments.widgetId, arguments.configInstanceId )
			, contextData = _getContextDataFromRequest( arguments.requestData )
		} );
	}

	public string function renderWidgetConfigForm( required string dashboardId, required string widgetId, required string instanceId ) {
		var formName = "admin.admindashboards.widget.#widgetId#";
		if ( _isAdminDashboard( dashboardId ) ) {
			formName = _getFormsService().getMergedFormName( formName, "admin.admindashboards.config" );
		}

		return _getFormsService().renderForm(
			  formName  = formName
			, savedData = getWidgetConfiguration( arguments.dashboardId, arguments.widgetId, arguments.instanceId )
		);
	}

	public boolean function widgetHasConfigForm( required string widgetId ) {
		return _getFormsService().formExists( "admin.admindashboards.widget.#widgetId#" );
	}

	public void function saveWidgetConfiguration( required string dashboardId, required string widgetId, required string instanceId, required struct requestData ) {
		var fields = _getFormsService().listFields( formName="admin.admindashboards.widget.#widgetId#" );
		var config = {};

		for( var field in fields ) {
			config[ field ] = arguments.requestData[ field ] ?: "";
		}

		if ( _isAdminDashboard( dashboardId ) ) {
			var data = { config=SerializeJson( config ) };
			if ( structKeyExists( arguments.requestData, "widget_title" ) && len( arguments.requestData.widget_title ) ) {
				data.title = arguments.requestData.widget_title;
			}

			$getPresideObject( "admin_dashboard_widget" ).updateData(
				  filter = { dashboard=arguments.dashboardId, widget_id=arguments.widgetId, instance_id=arguments.instanceId }
				, data   = data
			);
			return;
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
		var configRecord     = "";
		var result           = {};
		var isAdminDashboard = _isAdminDashboard( dashboardId );

		if ( isAdminDashboard ) {
			configRecord = $getPresideObject( "admin_dashboard_widget" ).selectData( filter={
				  dashboard   = arguments.dashboardId
				, widget_id   = arguments.widgetId
				, instance_id = arguments.instanceId
			} );
		} else {
			configRecord = $getPresideObject( "admin_dashboard_widget_configuration" ).selectData( filter={
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
		}

		try {
			result = DeserializeJson( configRecord.config ?: "" );

			if ( isAdminDashboard ) {
				result.widget_title = configRecord.title ?: "";
			}
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

		return $helpers.isTrue( result ?: "" );
	}

	public boolean function isUserDashboardWidget( required string widgetId ) {
		var coldbox                    = $getColdbox();
		var isUserDashboardWidgetEvent = "admin.admindashboards.widget.#widgetId#.isUserDashboardWidget";
		var result                     = false;

		if ( coldbox.handlerExists( isUserDashboardWidgetEvent ) ) {
			result = coldbox.runEvent(
				  event         = isUserDashboardWidgetEvent
				, private       = true
				, prePostExempt = true
			);
		}

		return $helpers.isTrue( result ?: "" );
	}

	public string function addWidget(
		  required string dashboardId
		, required string widgetId
		, required string instanceId
		, required string title
		,          struct config = {}
	) {
		return $getPresideObject( "admin_dashboard_widget" ).insertData( data={
			  dashboard   = arguments.dashboardId
			, widget_id   = arguments.widgetId
			, instance_id = arguments.instanceId
			, title       = arguments.title
			, config      = serializeJson( arguments.config )
		} );
	}

	public void function deleteWidget(
		  required string dashboardId
		, required string instanceId
	) {
		$getPresideObject( "admin_dashboard_widget" ).deleteData( filter={
			  dashboard    = arguments.dashboardId
			, instance_id  = arguments.instanceId
		} );
	}

	public void function reload() {
		_autoDiscoverWidgets();
		_loadWidgetsFromConfig();
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

	private boolean function _isAdminDashboard( required string dashboardId ) {
		return $getPresideObject( "admin_dashboard" ).dataExists( id=arguments.dashboardId );
	}


	private void function _loadWidgetsFromConfig() {
		var widgets       = _getWidgets();
		var configuration = _getConfiguredWidgets();

		for( var widgetId in configuration ){
			widgets[ widgetId ] = Duplicate( configuration[ widgetId ] );

			widgets[ widgetId ].id          = widgetId;
			widgets[ widgetId ].configForm  = widgets[ widgetId ].configForm  ?: _getFormNameByConvention( widgetId );
			widgets[ widgetId ].viewlet     = widgets[ widgetId ].viewlet     ?: _getViewletEventByConvention( widgetId );
			widgets[ widgetId ].icon        = widgets[ widgetId ].icon        ?: _getIconByConvention( widgetId );
			widgets[ widgetId ].title       = widgets[ widgetId ].title       ?: _getTitleByConvention( widgetId );
			widgets[ widgetId ].description = widgets[ widgetId ].description ?: _getDescriptionByConvention( widgetId );
		}

		_setWidgets( widgets );
	}

	private void function _autoDiscoverWidgets() {
		var widgets                 = {};
		var viewsPath               = "/views/admin/adminDashboards/widget";
		var handlersPath            = "/handlers/admin/adminDashboards/widget";
		var ids                     = {};
		var autoDiscoverDirectories = _getAutoDicoverDirectories();
		var siteTemplateMap         = {};

		for( var dir in autoDiscoverDirectories ) {
			dir              = ReReplace( dir, "/$", "" );
			var views        = DirectoryList( dir & viewsPath   , false, "query" );
			var handlers     = DirectoryList( dir & handlersPath, false, "query", "*.cfc" );
			var siteTemplate = _getSiteTemplateFromPath( dir );

			for ( var view in views ) {
				var id = "";
				if ( views.type eq "Dir" ) {
					id = views.name;
				} else if ( views.type == "File" && ReFindNoCase( "\.cfm$", views.name ) && !views.name.reFind( "^_" ) ) {
					id = ReReplaceNoCase( views.name, "\.cfm$", "" );
				} else {
					continue;
				}

				ids[ id ] = 1;
				siteTemplateMap[ id ] = siteTemplateMap[ id ] ?: [];
				siteTemplateMap[ id ].append( siteTemplate );
			}

			for ( var handler in handlers ) {
				if ( handlers.type eq "File" ) {
					var id = ReReplace( handlers.name, "\.cfc$", "" );
					ids[ id ] = 1;

					siteTemplateMap[ id ] = siteTemplateMap[ id ] ?: [];
					siteTemplateMap[ id ].append( siteTemplate );
				}
			}
		}

		for( var id in ids ) {
			//if ( _isWidgetEnabled( id ) ) {
				widgets[ id ] = {
					  id                 = id
					, configForm         = _getFormNameByConvention( id )
					, viewlet            = _getViewletEventByConvention( id )
					, placeholderViewlet = _getPlaceholderViewletEventByConvention( id )
					, icon               = _getIconByConvention( id )
					, title              = _getTitleByConvention( id )
					, description        = _getDescriptionByConvention( id )
					, siteTemplates      = _mergeSiteTemplates( siteTemplateMap[id] )
					, categories         = _getWidgetCategoriesFromForm( id )
				};
			//}
		}

		_setWidgets( widgets );
	}

	private array function _getWidgetCategoriesFromForm( required string widgetId ) {
		var formName = _getFormNameByConvention( arguments.widgetId );

		if ( _getFormsService().formExists( formName ) ) {
			var theForm = _getFormsService().getForm( formName );

			return ListToArray( theForm.categories ?: "" );
		}

		return [];
	}

	private string function _getSiteTemplateFromPath( required string path ) {
		var regex = "^.*[\\/]site-templates[\\/]([^\\/]+)$";

		if ( !ReFindNoCase( regex, arguments.path ) ) {
			return "*";
		}

		return ReReplaceNoCase( arguments.path, regex, "\1" );
	}

	private string function _getViewletEventByConvention( required string widgetId ) {
		return "admin.admindashboards.widget." & widgetId;
	}

	private string function _getPlaceholderViewletEventByConvention( required string widgetId ) {
		return "admin.admindashboards.widget." & widgetId & ".placeholder";
	}

	private string function _getIconByConvention( required string widgetId ) {
		return "admin.admindashboards.widget.#widgetId#:iconclass";
	}

	private string function _getTitleByConvention( required string widgetId ) {
		return "admin.admindashboards.widget.#widgetId#:title";
	}

	private string function _getDescriptionByConvention( required string widgetId ) {
		return "admin.admindashboards.widget.#widgetId#:description";
	}
	private string function _getFormNameByConvention( required string widgetId ) {
		return "admin.admindashboards.widget." & widgetId;
	}
	private string function _mergeSiteTemplates( required array templates ) ouptut=false {
		var merged = "";

		for( var template in arguments.templates ) {
			if ( template == "*" ) {
				return "*";
			}
			merged = ListAppend( merged, template );
		}

		return merged;
	}



// GETTERS AND SETTERS
	private any function _getFormsService() {
		return _formsService;
	}
	private void function _setFormsService( required any formsService ) {
		_formsService = arguments.formsService;
	}
	private struct function _getWidgets() {
		return _widgets;
	}
	private void function _setWidgets( required struct widgets ) {
		_widgets = arguments.widgets;
	}
	private struct function _getConfiguredWidgets() {
		return _configuredWidgets;
	}
	private void function _setConfiguredWidgets( required struct configuredWidgets ) {
		_configuredWidgets = arguments.configuredWidgets;
	}
	private array function _getAutoDicoverDirectories() {
		return _autoDicoverDirectories;
	}
	private void function _setAutoDicoverDirectories( required array autoDicoverDirectories ) {
		_autoDicoverDirectories = arguments.autoDicoverDirectories;
	}

}