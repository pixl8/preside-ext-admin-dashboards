( function( $ ){
	var $dashboardWidgetContainer  = $( ".admin-dashboard-widgets-container" )
	  , $dashboardWidgetLink       = $dashboardWidgetContainer.find( ".widget-group-link" )
	  , $dashboardWidgetSeachField = $dashboardWidgetContainer.find( ".dialog-search-input" )
	  , toggleGroupSection;

	toggleGroupSection = function( animated=false ) {
		$dashboardWidgetContainer.find( ".admin-dashboard-widget-item" ).hide( animated ? "fast" : null );

		var selectedGroup = $dashboardWidgetContainer.find( ".selected .widget-group-link" ).data( "widgetGroup" );
		if ( selectedGroup && ( selectedGroup.length > 0 ) ) {
			$dashboardWidgetContainer.find( ".admin-dashboard-widget-item[data-widget-group='" + selectedGroup + "']" ).show( animated ? "fast" : null );
		} else {
			$dashboardWidgetContainer.find( ".admin-dashboard-widget-item" ).show( animated ? "fast" : null );
		}
	};

	toggleGroupSection();

	$dashboardWidgetLink.on( "click", function(event) {
		event.preventDefault();

		$dashboardWidgetContainer.find( ".widget-group-list .selected" ).removeClass( "selected" );
		$(this).closest( "li.widget-group" ).addClass( "selected" );
		toggleGroupSection( true );
	});

	$dashboardWidgetSeachField.on( "keyup", function(event) {
		var searchText = $(this).val();

		if ( searchText ) {
			$(this).data( "isLoading", true );

			if ( searchText.length > 1 ) {
				$.ajax( {
					  url    : buildAdminLink( "adminDashboards", "widgetDialogSearchWidgets" )
					, data   : { q: searchText }
					, method : "GET"
				} ).done( function( data ) {
					if ( data ) {
						var curWidgets = [];

						$dashboardWidgetContainer.find( ".admin-dashboard-widget-item:visible" ).each(function(index, el) {
							curWidgets.push( $(this).data( "widgetId" ) );
						});

						$.each( curWidgets, function(index, val) {
							if ( $.inArray( val, data ) > -1 ) {
								$dashboardWidgetContainer.find( ".admin-dashboard-widget-item[data-widget-id='" + val + "']" ).show( "fast" );
							} else {
								$dashboardWidgetContainer.find( ".admin-dashboard-widget-item[data-widget-id='" + val + "']" ).hide( "fast" );
							}
						});

						$.each( data, function(index, val) {
							$dashboardWidgetContainer.find( ".admin-dashboard-widget-item[data-widget-id='" + val + "']" ).show( "fast" );
						} );
					}
				} );
			} else {
				toggleGroupSection( true );
			}
		}
	});
} )( presideJQuery );