component {
	property name="widgetService" inject="adminDashboardWidgetService";
	property name="enumService"   inject="EnumService";

	private struct function initState( event, rc, prc, args={}, instanceRef, webflowId, webflow ) {
		return {};
	}

	private string function selectType( event, rc, prc, webflowId, wfInstance, args={} ) {
		var savedState = args.state ?: {};

		args.availableTypes = enumService.listItems( enum="adminDashboardWidgetType" );
		args.selectedType   = rc.widget_type ?: ( savedState.widget_type ?: "" );
		args.importCode     = rc.import_code ?: ( savedState.import_code ?: "" );

		event.include( "/css/admin/specific/webflow/adminDashboardsAddWidget/selectType/" )
		     .include( "/js/admin/specific/webflow/adminDashboardsAddWidget/selectType/"  );

		return renderView( view="/admin/webflow/adminDashboardsAddWidget/selectType", args=args );
	}
	private void function selectTypeAction( event, rc, prc, webflowId, wfInstance, validationResult, args={} ) {
		var submittedData = event.getCollectionWithoutSystemVars();
		var widgetType    = Trim( submittedData.widget_type ?: "" );
		var importCode    = Trim( submittedData.import_code ?: "" );

		if ( isEmptyString( widgetType ) ) {
			arguments.validationResult.addError(
				  fieldName = "widget_type"
				, message   = translateResource( uri="cms:validation.required.default", data=[ translateResource( uri="webflow.adminDashboardsAddWidget:step.selectType.field.widget_type.label" ) ] )
			);
		}

		if ( ( widgetType == "import" ) ) {
			if ( !Len( importCode ) ) {
				arguments.validationResult.addError(
					  fieldName = "import_code"
					, message   = translateResource( uri="cms:validation.required.default", data=[ translateResource( uri="webflow.adminDashboardsAddWidget:step.selectType.field.import_code.label" ) ] )
				);
			} else {
				if ( !IsJSON( importCode ) ) {
					arguments.validationResult.addError(
						  fieldName = "import_code"
						, message   = translateResource( uri="webflow.adminDashboardsAddWidget:step.selectType.field.import_code.error.invalid_code" )
					);
				} else {
					var deserializeCode = DeserializeJSON( importCode );

					if ( !Len( Trim( deserializeCode.widgetId ?: "" ) ) ) {
						arguments.validationResult.addError(
							  fieldName = "import_code"
							, message   = translateResource( uri="webflow.adminDashboardsAddWidget:step.selectType.field.import_code.error.missing_widget_id" )
						);
					}
				}
			}
		}
	}

	private boolean function showSelectWidget( event, rc, prc, args={}, wfInstance ) {
		var savedState = arguments.wfInstance.getState();
		var widgetType = Trim( savedState.widget_type ?: "" );

		return widgetType != "import";
	}
	private string function selectWidget( event, rc, prc, webflowId, wfInstance, args={} ) {
		var savedState = args.state ?: {};

		args.isGallery = ( ( savedState.widget_type ?: "" ) == "gallery" ) ? true : false;
		args.widgets   = renderViewlet( event="admin.adminDashboards._getSortedAndTranslatedAdminWidgets" );
		args.widgets   = QueryFilter( args.widgets, function( _widget ) {
			return args.isGallery ? isTrue( _widget.isTemplate ?: "" ) : isFalse( _widget.isTemplate ?: "" );
		} );

		event.include( "/css/admin/specific/webflow/adminDashboardsAddWidget/selectWidget/" )
		     .include( "/js/admin/specific/webflow/adminDashboardsAddWidget/selectWidget/"  )
		     .includeData( { resultUrl=event.buildAdminLink( linkto="webflow.adminDashboardsAddWidget.getAvailableWidgets" ) } );

		return renderView( view="/admin/webflow/adminDashboardsAddWidget/selectWidget", args=args );
	}
	private void function selectWidgetAction( event, rc, prc, webflowId, wfInstance, validationResult, args={} ) {
		var submittedData  = event.getCollectionWithoutSystemVars();
		var selectedWidget = submittedData.widget ?: "";

		if ( isEmptyString( selectedWidget ) ) {
			arguments.validationResult.addError(
				  fieldName = "widget"
				, message   = translateResource(
					  uri  = "cms:validation.required.default"
					, data = [ translateResource( uri="webflow.adminDashboardsAddWidget:step.selectWidget.field.widget.label" ) ]
				)
			);
		}
	}

	public string function getAvailableWidgets( event, rc, prc, args={} ) {
		var isGallery   = isTrue( rc.isGallery ?: ( args.isGallery ?: "" ) );
		var groupsVal   = ListToArray( Trim( rc.groups ?: "" ) );
		var searchQuery = Trim( rc.q ?: "" );

		args.widgets = renderViewlet( event="admin.adminDashboards._getSortedAndTranslatedAdminWidgets" );
		args.widgets = QueryFilter( args.widgets, function( _widget ) {
			return isGallery ? isTrue( _widget.isTemplate ?: "" ) : isFalse( _widget.isTemplate ?: "" );
		} );

		if ( ArrayLen( groupsVal ) ) {
			args.widgets = QueryFilter( args.widgets, function( _widget ) {
				return ArrayFindNoCase( groupsVal, _widget.group );
			} );
		}

		if ( Len( searchQuery ) ) {
			args.widgets = QueryFilter( args.widgets, function( _widget ) {
				return ReFindNoCase( searchQuery, _widget.title ) || ReFindNoCase( searchQuery, _widget.description );
			} );
		}

		return renderView( view="/admin/webflow/adminDashboardsAddWidget/_selectWidgetItems", args=args );
	}

	private string function configWidget( event, rc, prc, webflowId, wfInstance, args={} ) {
		var savedState      = args.state ?: {};
		var preconfigConfig = IsJSON( savedState.import_code ?: "" ) ? DeserializeJSON( savedState.import_code ) : {};

		args.dashboardId = rc.dashboard ?: ( prc.recordId ?: "" );
		args.widgetId    = preconfigConfig.widgetId ?: ( savedState.widget ?: "" );
		args.templateId  = "";

		if ( ListLen( args.widgetId, "_" ) > 1 ) {
			args.templateId = ListLast(  args.widgetId, "_" );
			args.widgetId   = ListFirst( args.widgetId, "_" );
		}

		if ( Len( args.templateId ) ) {
			StructAppend( preconfigConfig, widgetService.getSystemWidgetTemplateConfig( templateId=args.templateId ) );
		}

		args.configForm = widgetService.renderWidgetConfigForm(
			  dashboardId = args.dashboardId
			, widgetId    = args.widgetId
			, instanceId  = ""
			, configData  = preconfigConfig
		);

		event.include( "/js/admin/specific/webflow/adminDashboardsAddWidget/configWidget/" );

		return renderView( view="/admin/webflow/adminDashboardsAddWidget/configWidget", args=args );
	}
	private void function configWidgetAction( event, rc, prc, webflowId, wfInstance, validationResult, args={} ) {
		var wfInstanceArgs   = arguments.wfInstance.getInstanceArgs();
		var wfInstanceSubRef = Trim( wfInstanceArgs.subreference ?: "" );
		var submittedData    = event.getCollectionWithoutSystemVars();

		StructDelete( submittedData, "$presideform" );
		StructDelete( submittedData, "_sid" );
		StructDelete( submittedData, "_wid" );

		var dashboardId = ( ListLen( wfInstanceSubRef, "_" ) > 1 ) ? ListLast( wfInstanceSubRef, "_" ) : ( submittedData.dashboardId ?: "" );
		var widgetId    = submittedData.widgetId    ?: "";
		var column      = rc.column ?: 1;
		var instanceId  = CreateUUID();
		var nextSlot    = widgetService.nextWidgetSlot( dashboardId, column );

		widgetService.addWidget(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
			, column      = column
			, slot        = nextSlot
			, title       = submittedData.widget_title ?: widgetService.getInstanceTitle( dashboardId, widgetId )
			, config      = submittedData
		);
	}

	private string function confirmation( event, rc, prc, webflowId, wfInstance, args={} ) {
		event.include( "/js/admin/specific/webflow/adminDashboardsAddWidget/confirmation/" );

		var savedState       = args.state ?: arguments.wfInstance.getState();
		var wfInstanceArgs   = arguments.wfInstance.getInstanceArgs();
		var wfInstanceSubRef = Trim( wfInstanceArgs.subreference ?: "" );

		args.dashboardId = ( ListLen( wfInstanceSubRef, "_" ) > 1 ) ? ListLast( wfInstanceSubRef, "_" ) : ( savedState.dashboardId ?: "" );

		return renderView( view="/admin/webflow/adminDashboardsAddWidget/confirmation", args=args );
	}
}