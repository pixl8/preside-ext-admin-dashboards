( function( $ ){

	$( ".dashboard-column-content" ).sortable( {
		  connectWith          : ".dashboard-column-content"
		, handle               : ".widget-header"
		, placeholder          : "widget-placeholder"
		, forcePlaceholderSize : true
		, tolerance            : "pointer"
		, update               : function( event, ui ) {
			if ( ui.sender ) return;
			var element     = ui.sender || ui.item
			  , dashboardId = element.closest( ".admin-dashboard-container" ).data( "dashboardId" )
			  , column      = element.closest( ".dashboard-column" ).data( "column" )
			  , widgets     = element.closest( ".ui-sortable" ).sortable( "toArray", { attribute: "data-config-instance-id" } );

			if ( widgets.length ) {
				$.ajax( buildAdminLink( "admindashboards", "updateWidgetOrder" ), {
					  data   : { dashboardId:dashboardId, column:column, widgets:widgets }
					, method : "POST"
				} );
			}
		  }
	} );

} )( presideJQuery );