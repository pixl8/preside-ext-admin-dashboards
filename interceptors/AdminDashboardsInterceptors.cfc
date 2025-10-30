component extends="coldbox.system.Interceptor" {
	property name="adminDashboardWidgetService" inject="delayedInjector:adminDashboardWidgetService";

// PUBLIC
	public void function configure() {}

	public void function onApplicationStart( event, interceptData ) {
		adminDashboardWidgetService.syncDashboardWidgetTemplates();
	}
}