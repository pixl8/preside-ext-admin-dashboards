component extends="coldbox.system.Interceptor" {
	property name="adminDashboardService"       inject="delayedInjector:adminDashboardService";
	property name="adminDashboardWidgetService" inject="delayedInjector:adminDashboardWidgetService";

// PUBLIC
	public void function configure() {}

	public void function onApplicationStart( event, interceptData ) {
		adminDashboardWidgetService.syncDashboardWidgetTemplates();
		adminDashboardService.syncSystemDashboards();
	}
}