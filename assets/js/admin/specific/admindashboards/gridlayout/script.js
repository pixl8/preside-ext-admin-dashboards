( function( $ ){

	var grid = GridStack.init( {
		  column      : 4
		, cellHeight  : 160
		, margin      : 16
		, float       : true
		, handleClass : "widget-draggable-handle"
	} );

	grid.on( "change", function( event, items ) {

		const dashboardId = $( event.target ).closest( ".admin-dashboard-container" ).data( "dashboardId" ),
			  widgets     = [];

		items.forEach( function( item ) {
			widgets.push( {
				  id         = $( item.el ).find( ".admin-dashboard-widget" ).data( "config-instance-id" )
				, gridConfig = {
					  x = item.x
					, y = item.y
					, w = item.w
					, h = item.h
				}
			} );
		});

		$.ajax( buildAdminLink( "admindashboards", "updateGridWidgetOrderAndSize" ), {
			  data     : { dashboardId:dashboardId, widgets: JSON.stringify( widgets ) }
			, method   : "POST"
		} );
	} );

} )( presideJQuery );