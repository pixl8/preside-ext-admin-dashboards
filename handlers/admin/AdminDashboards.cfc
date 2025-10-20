component extends="preside.system.base.AdminHandler" {

	property name="widgetService"    inject="adminDashboardWidgetService";
	property name="dashboardService" inject="adminDashboardService";
	property name="siteService"      inject="delayedInjector:siteService";

	public void function renderWidgetContent( event, rc, prc ) {
		var widgetId         = rc.widgetId         ?: "";
		var dashboardId      = rc.dashboardId      ?: "";
		var instanceId       = rc.instanceId       ?: "";
		var configInstanceId = rc.configInstanceId ?: "";

		if ( !widgetService.userCanViewWidget( widgetId ) ) {
			event.adminAccessDenied();
		}

		event.renderData( type="html", data=widgetService.renderWidgetContent(
			  dashboardId      = dashboardId
			, widgetId         = widgetId
			, instanceId       = instanceId
			, configInstanceId = configInstanceId
			, requestData      = rc
		) );
	}

	public void function configModal( event, rc, prc ) {
		var widgetId    = rc.widgetId    ?: "";
		var dashboardId = rc.dashboardId ?: "";
		var instanceId  = rc.configInstanceId  ?: "";

		if ( !widgetService.userCanViewWidget( widgetId ) ) {
			event.adminAccessDenied();
		}
		if ( !widgetService.widgetHasConfigForm( widgetId ) ) {
			event.notFound();
		}

		prc.configForm = widgetService.renderWidgetConfigForm(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
		);

		event.include( "/js/admin/specific/admindashboards/configmodal/" );

		event.setLayout( "adminModalDialog" );
	}

	public void function saveWidgetConfig( event, rc, prc ) {
		var widgetId    = rc.widgetId ?: "";
		var dashboardId = rc.dashboardId ?: "";
		var instanceId  = rc.configInstanceId ?: "";

		if ( !widgetService.userCanViewWidget( widgetId ) ) {
			event.adminAccessDenied();
		}
		if ( !widgetService.widgetHasConfigForm( widgetId ) ) {
			event.notFound();
		}

		var formData = event.getCollectionWithoutSystemVars();
		var formName = widgetService.getWidgetConfigFormName(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
		);

		var validationResult = validateForm( formName=formName, formData=formData );
		var interceptData    = {
			  widgetId         = widgetId
			, dashboardId      = dashboardId
			, instanceId       = instanceId
			, formData         = formData
			, validationResult = validationResult
		};

		event.announceInterception( "onValidateWidgetConfigForm", interceptData );

		var validated     = interceptData.validationResult.validated();
		var errorMessages = validated ? {} : interceptData.validationResult.getMessages();
		var success       = true && validated;

		try {
			if ( validated ) {
				widgetService.saveWidgetConfiguration(
					  dashboardId = dashboardId
					, widgetId    = widgetId
					, instanceId  = instanceId
					, requestData = interceptData.formData
					, formName    = formName
				);
			}
		} catch (any e) {
			logError(e);
			success = false;
		}

		event.renderData( data={ success=success, errorMessages=errorMessages }, type="json" );
	}

	private string function renderDashboard( event, rc, prc, args={} ) {
		var renderedWidgets = widgetService.renderDashboard( argumentCollection=args );

		event.include( "/js/admin/specific/admindashboards/" )
		     .include( "/css/admin/specific/admindashboards/" );

		return renderView( view="/admin/admindashboards/_dashboard", args={ widgets=renderedWidgets, dashboardId=args.dashboardId ?: "" } );
	}

	private string function renderUserGeneratedDashboard( event, rc, prc, args={} ) {
		var dashboardId  = args.dashboardId ?: "";
		var allowEditing = isTrue( args.allowEditing ?: "" );
		var action       = ListLast( rc.event ?: "", "." );
		var dashboard    = widgetService.renderUserGeneratedGridDashboard( dashboardId=dashboardId, allowEditing=allowEditing, showTempWidgets=( action == "editdashboardlayout" ) );

		event.include( "/js/admin/specific/admindashboards/" )
		     .include( "/css/admin/specific/admindashboards/" );

		if ( isTrue( dashboard.canEdit ?: "" ) ) {
			event.include( "/js/admin/specific/admindashboards/editing/" );
		}

		StructAppend( args, dashboard );

		return renderView( view="/admin/admindashboards/layoutGrid/_userGenerated", args=args );
	}

	public void function widgetDialog( event, rc, prc ) {
		event.setLayout( "adminModalDialog" );
		prc.widgets = _getSortedAndTranslatedAdminWidgets();

		event.setView( view="admin/admindashboards/browserDialog", nolayout=true );
	}

	public function addWidget( event, rc, prc, args={} ) {
		var dashboardId = rc.dashboard ?: "";
		var widgetId    = rc.widget    ?: "";
		var column      = rc.column    ?: 1;
		var instanceId  = createUUID();
		var nextSlot    = widgetService.nextWidgetSlot( dashboardId, column );
		var title       = "";

		widgetService.addWidget(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
			, column      = column
			, slot        = nextSlot
			, title       = title
			, config      = {}
		);

		setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard", operation="editdashboardlayout", recordId=dashboardId ) );
	}

	public function deleteWidget( event, rc, prc, args={} ) {
		var dashboardId = args.dashboardId ?: ( rc.dashboardId ?: "" );
		var instanceId  = args.instanceId  ?: ( rc.instanceId  ?: "" );

		widgetService.deleteWidget(
			  dashboardId = dashboardId
			, instanceId  = instanceId
		);

		setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard", recordId=dashboardId ) );
	}

	public function saveEditDashboardLayout( event, rc, prc, args={} ) {
		var dashboardId = args.dashboardId ?: ( rc.dashboardId ?: "" );

		widgetService.saveEditDashboardWidgets( dashboardId=dashboardId );

		setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard", recordId=dashboardId ) );
	}

	public function cancelEditDashboardLayout( event, rc, prc, args={} ) {
		var dashboardId = args.dashboardId ?: ( rc.dashboardId ?: "" );

		widgetService.cancelEditDashboardWidgets( dashboardId=dashboardId );

		setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard", recordId=dashboardId ) );
	}

	public string function updateWidgetOrder( event, rc, prc, args={} ) {
		var dashboardId = rc.dashboardId ?: "";
		var column      = rc.column      ?: 1;
		var widgets     = rc.widgets     ?: [];
		var dao         = getPresideObject( "admin_dashboard_widget" );

		widgets.each( function( widget, slot ) {
			dao.updateData(
				  filter = { dashboard=dashboardId, instance_id=widget }
				, data   = { column=column, slot=slot }
			);
		} );

		return "OK";
	}

	public string function updateGridWidgetOrderAndSize( event, rc, prc, args={} ) {
		var dashboardId = rc.dashboardId ?: "";
		var widgets     = rc.widgets     ?: "";
		var isTemporary = rc.isTemporary ?: false;
		var dao         = getPresideObject( "admin_dashboard_widget" );
		var dataField   = isTrue( isTemporary ) ? "dashboard_edit_temp_grid_config" : "grid_config";

		widgets = deserializeJSON( widgets );

		widgets.each( function( widget, i ) {
			dao.updateData(
				  filter = { dashboard=dashboardId, instance_id=widget.id }
				, data   = { "#dataField#" = serializeJSON( widget.gridConfig ) }
			);
		} );

		return "OK";
	}


// private helpers

	private query function _getSortedAndTranslatedAdminWidgets() {
		// todo, cache this operation (per locale)
		var unsortedOrTranslated         = widgetService.getWidgets();
		var tempArray                    = [];
		var activeSiteTemplate           = isFeatureEnabled( "sites" ) ? siteService.getActiveSiteTemplate() : "";
		var isUserDashboardWidgetHandler = "";
		var isUserDashboardWidget        = false;

		for( var id in unsortedOrTranslated ) {
			var widget = Duplicate( unsortedOrTranslated[ id ] );

			if ( widget.siteTemplates == "*" || ListFindNoCase( widget.siteTemplates, activeSiteTemplate ) ) {
				if ( !widgetService.isEnabled( widget.id ) || !widgetService.isUserDashboardWidget( widget.id ) ) {
					continue;
				}

				widget.title       = translateResource( uri=widget.title      , defaultValue=widget.title );
				widget.description = translateResource( uri=widget.description, defaultValue="" );
				widget.icon        = translateResource( uri=widget.icon       , defaultValue="fa-magic" );

				tempArray.append( widget );
			}
		}

		tempArray.sort( function( widget1, widget2 ){
			return widget1.title == widget2.title ? 0 : ( widget1.title > widget2.title ? 1 : -1 );
		} );

		return arrayOfStructsToQuery( "id,title,description,icon", tempArray );
	}
}