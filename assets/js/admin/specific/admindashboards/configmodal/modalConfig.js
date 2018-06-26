( function( $ ){
	window.getAdminDashboardWidgetConfig = function(){
		return $( "#admin-dashboard-widget-config-form" ).serializeObject();
	};
} )( presideJQuery );