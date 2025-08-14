( function( $ ){
	window.getAdminDashboardWidgetConfig = function() {
		return $( "#admin-dashboard-widget-config-form" ).serializeObject();
	};

	window.clearAllFormErrors = function() {
		$( ".form-group .clearfix .help-block.error-message" ).remove();
		$( ".form-group .has-error" ).removeClass( "has-error" );
	};

	window.getModalElements = function( fieldName ) {
		return $( '[name="' + fieldName + '"]' );
	};
} )( presideJQuery );