component extends="preside.system.base.AdminHandler" {

	property name="widgetService" inject="adminDashboardWidgetService";

	public void function renderWidgetContent( event, rc, prc ) {
		var widgetId    = rc.widgetId    ?: "";
		var dashboardId = rc.dashboardId ?: "";
		var instanceId  = rc.instanceId  ?: "";

		if ( !widgetService.userCanViewWidget( widgetId ) ) {
			event.adminAccessDenied();
		}

		event.renderData( type="html", data=widgetService.renderWidgetContent(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
			, requestData = rc
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


}