( function( $ ){

	const action = cfrequest.dashboard_action || "";

	const grid = GridStack.init( {
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
			  data   : { isTemporary: true, dashboardId: dashboardId, widgets: JSON.stringify( widgets ) }
			, method : "POST"
		} );
	} );

	$( ".js-save-layout" ).click( function( e ) {
		e.preventDefault();

		const dashboardId = grid.el.parentElement.dataset[ "dashboardId" ]
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
			  data   : { dashboardId: dashboardId, widgets: JSON.stringify( widgets ) }
			, method : "POST"
		} ).always( function( data ) {
			window.location = thisAnchor.href;
		} );
	} );

} )( presideJQuery );