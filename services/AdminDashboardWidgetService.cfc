/**
 * @presideService true
 * @singleton      true
 */
component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public string function renderDashboard( required string dashboardId, required array widgets ) {
		return "// TODO";
	}

	public string function renderWidgetContainer( required string dashboardId, required string widgetId ) {
		return "// TODO"
	}

	public string function renderWidgetContent( required string dashboardId, required string widgetId ) {
		return "// TODO"
	}

	public string function renderWidgetConfigForm( required string dashboardId, required string widgetId ) {
		return "// TODO"
	}

	public boolean function widgetHasConfigForm( required string widgetId ) {
		return true; // TODO
	}

	public void function saveWidgetConfiguration( required string dashboardId, required string widgetId, required struct requestData ) {
		return; // TODO
	}

	public boolean function userCanViewWidget( required string widgetId ) {
		return true; // TODO
	}

}