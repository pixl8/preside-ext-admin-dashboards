component extends="preside.system.base.AdminHandler" {

	property name="widgetService" inject="adminDashboardWidgetService";
	property name="siteService"   inject="delayedInjector:siteService";

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

	public void function exportModal( event, rc, prc ) {
		var widgetId    = rc.widgetId         ?: "";
		var dashboardId = rc.dashboardId      ?: "";
		var instanceId  = rc.configInstanceId ?: "";

		if ( !widgetService.userCanViewWidget( widgetId ) ) {
			event.adminAccessDenied();
		}
		if ( !widgetService.widgetHasConfigForm( widgetId ) ) {
			event.notFound();
		}

		prc.config = widgetService.getWidgetConfiguration(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
		);

		prc.config.widgetId = prc.config.widgetId ?: widgetId;

		if ( StructIsEmpty( prc.config ) ) {
			event.notFound();
		}

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

		widgetService.saveWidgetConfiguration(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
			, requestData = event.getCollectionWithoutSystemVars()
		);

		event.renderData( data={ success=true }, type="json" );
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
		var dashboard    = widgetService.renderUserGeneratedDashboard( dashboardId=dashboardId, allowEditing=allowEditing );

		event.include( "/js/admin/specific/admindashboards/" )
		     .include( "/css/admin/specific/admindashboards/" );

		if ( isTrue( dashboard.canEdit ?: "" ) ) {
			event.include( "/js/admin/specific/admindashboards/editing/" );
		}

		return renderView( view="/admin/admindashboards/_userGenerated", args=dashboard );
	}

	public void function importDialog( event, rc, prc ) {
		event.setLayout( "adminModalDialog" );
		event.include( "/js/admin/specific/admindashboards/importDialog/" );
		event.setView( view="admin/admindashboards/importDialog" );
	}

	public void function widgetDialog( event, rc, prc ) {
		event.setLayout( "adminModalDialog" );
		prc.widgets = _getSortedAndTranslatedAdminWidgets();
		prc.grouped = {};

		for ( var widget in prc.widgets ) {
			var groupId = Len( widget.group ?: "" ) ? widget.group : "uncategorised";

			prc.grouped[ groupId ] = prc.grouped[ groupId ] ?: [];
			ArrayAppend( prc.grouped[ groupId ], widget );
		}

		prc.groups = StructKeyArray( prc.grouped );
		ArrayDelete( prc.groups, "uncategorised" );
		ArraySort(   prc.groups, "textnocase" );

		if ( ArrayLen( prc.groups ) ) {
			event.include( "/js/admin/specific/admindashboards/widgetDialog/"  )
			     .include( "/css/admin/specific/admindashboards/widgetDialog/" );
		}

		event.setView( view="admin/admindashboards/browserDialog" );
	}

	public array function widgetDialogSearchWidgets( event, rc, prc, args={} ) {
		var searchQuery = Trim( rc.q ?: "" );

		if ( Len( searchQuery ) ) {
			var widgets  = _getSortedAndTranslatedAdminWidgets();
			var filtered = QueryFilter( widgets, function( _widget ) {
				return ( Len( _widget.title ?: "" ) && ReFindNoCase( searchQuery, _widget.title ) )
					|| ( Len( _widget.description ?: "" ) && ReFindNoCase( searchQuery, _widget.description ) );
			} );

			if ( filtered.recordcount ) {
				return ValueArray( filtered, "id" );
			}
		}

		return [];
	}

	public function addWidget( event, rc, prc, args={} ) {
		var templateId  = Trim( rc.templateId ?: "" );
		var dashboardId = Trim( rc.dashboard  ?: "" );
		var widgetId    = Trim( rc.widget     ?: "" );
		var column      = rc.column ?: 1;
		var instanceId  = createUUID();
		var nextSlot    = widgetService.nextWidgetSlot( dashboardId, column );
		var title       = widgetService.getInstanceTitle( dashboardId, widgetId );
		var config      = {};

		if ( Len( templateId ) ) {
			config = widgetService.getSystemWidgetTemplateConfig( templateId=templateId );
		}

		widgetService.addWidget(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
			, column      = column
			, slot        = nextSlot
			, title       = title
			, config      = config
		);

		setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard", recordId=dashboardId ) );
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
				widget.group       = translateResource( uri="admin.admindashboards.widget.#id#:group", defaultValue="" );
				widget.previewImg  = "";
				widget.isTemplate  = false;
				widget.isSystem    = true;

				ArrayAppend( tempArray, widget );

				var widgetTemplates = widgetService.getDashboardWidgetTemplates( widgetId=widget.id, widgetConfig=widget );
				if ( ArrayLen( widgetTemplates ) ) {
					ArrayAppend( tempArray, widgetTemplates, true );
				}
			}
		}

		ArraySort( tempArray, function( widget1, widget2 ){
			return widget1.title == widget2.title ? 0 : ( widget1.title > widget2.title ? 1 : -1 );
		} );

		return arrayOfStructsToQuery( "id,title,group,description,icon,previewImg,isTemplate,recordId,config", tempArray );
	}
}