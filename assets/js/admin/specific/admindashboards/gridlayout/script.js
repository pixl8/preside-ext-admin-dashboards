( function( $ ){

	const action = cfrequest.dashboard_action || "";

	var grid = GridStack.init( {
		  column        : 4
		, cellHeight    : 210
		, margin        : 16
		, float         : true
		, handleClass   : "widget-draggable-handle"
		, staticGrid    : ( action == "viewrecord" )
	} );

	$( ".js-grid-auto-layout" ).click( function( e ) {
		e.preventDefault();
		grid.compact();
	} );

	$( ".js-save-layout" ).click( function( e ) {
		e.preventDefault();

		const dashboardId = grid.el.parentElement.dataset["dashboardId"]
			  gridItems   = grid.getGridItems(),
			  thisAnchor  = this,
			  widgets     = [];

		gridItems.forEach( function( item ) {
			widgets.push( {
				  id         = $( item ).find( ".admin-dashboard-widget" ).data( "config-instance-id" )
				, gridConfig = {
					  x = item.gridstackNode.x
					, y = item.gridstackNode.y
					, w = item.gridstackNode.w
					, h = item.gridstackNode.h
				}
			} );
		});

		$.ajax( buildAdminLink( "admindashboards", "updateGridWidgetOrderAndSize" ), {
			  data     : { dashboardId:dashboardId, widgets: JSON.stringify( widgets ) }
			, method   : "POST"
		} ).always( function( data ) {
			window.location = thisAnchor.href;
		} );
	} );

} )( presideJQuery );