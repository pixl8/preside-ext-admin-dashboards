( function( $ ){
	var $dashboardWidgetContainer = $( ".admin-dashboard-widgets-container" )
	  , $dashboardWidgetLink      = $dashboardWidgetContainer.find( ".widget-group-link" )
	  , toggleGroupSection;

	toggleGroupSection = function( animated=false ) {
		$dashboardWidgetContainer.find( ".admin-dashboard-widget-picker" ).hide( animated ? "fast" : null );

		var selectedGroup = $dashboardWidgetContainer.find( ".selected .widget-group-link" ).data( "widgetGroup" );
		if ( selectedGroup.length > 0 ) {
			$dashboardWidgetContainer.find( ".admin-dashboard-widget-picker#group-" + selectedGroup ).show( animated ? "fast" : null );
		}
	};

	toggleGroupSection();

	$dashboardWidgetLink.on( "click", function(event) {
		event.preventDefault();

		$dashboardWidgetContainer.find( ".widget-group-list .selected" ).removeClass( "selected" );
		$(this).closest( "li.widget-group" ).addClass( "selected" );
		toggleGroupSection( true );
	});
} )( presideJQuery );