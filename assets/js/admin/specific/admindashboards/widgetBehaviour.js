( function( $ ){

	var $dashBoardContainer = $( ".admin-dashboard-container" )
	  , $widgets            = $( ".admin-dashboard-container .admin-dashboard-widget" )
	  , openWidgetConfigDialog, loadContent, getWidgetDetails
	  , onWidgetContentFetchSuccess, onWidgetContentFetchError;

	openWidgetConfigDialog = function( $widgetEl ){
		var iframeSrc       = buildAdminLink( "admindashboards", "configModal", getWidgetDetails( $widgetEl ) )
		  , modalOptions    = {
				title      : $widgetEl.data( "configModalTitle" ),
				className  : "full-screen-dialog",
				buttonList : [ "ok", "cancel" ]
			}
		  , callbacks = {
				onLoad : function( iframe ) { dialogIframe = iframe; },
				onok : function(){
					var config = $.extend( {}, dialogIframe.getAdminDashboardWidgetConfig(), getWidgetDetails( $widgetEl ), getWidgetContextData( $widgetEl ) );

					$.ajax( buildAdminLink( "admindashboards", "saveWidgetConfig" ), {
						  data     : config
						, complete : function() { loadContent( $widgetEl ); }
					} );
				}
			}
		  , browserIframeModal = new PresideIframeModal( iframeSrc, "100%", "100%", callbacks, modalOptions )
		  , dialogIframe;

		browserIframeModal.open();
	};

	loadContent = function( $widgetEl ){
		$widgetEl.find( ".widget-dynamic-content" ).presideLoadingSheen( true );

		$.ajax( buildAdminLink( "admindashboards", "renderWidgetContent" ), {
			  data     : $.extend( {}, getWidgetDetails( $widgetEl ), getWidgetContextData( $widgetEl ) )
			, success  : function( data ) { onWidgetContentFetchSuccess( $widgetEl, data ); }
			, error    : function() { onWidgetContentFetchError( $widgetEl ); }
			, complete : function() { $widgetEl.find( ".widget-dynamic-content" ).presideLoadingSheen( false ); }
		} );
	};

	onWidgetContentFetchSuccess = function( $widgetEl, data ){
		$widgetEl.find( ".widget-dynamic-content" ).html( data );
	};

	onWidgetContentFetchError = function( $widgetEl ){
		$widgetEl.find( ".widget-dynamic-content" ).html( $widgetEl.closest( ".admin-dashboard-container" ).find( ".error-template").html() );
	};

	getWidgetDetails = function( $widgetEl ){
		return {
			  widgetId : $widgetEl.data( "widgetId" )
			, instanceId : $widgetEl.data( "instanceId" )
			, configInstanceId : $widgetEl.data( "configInstanceId" )
			, dashboardId : $widgetEl.closest( ".admin-dashboard-container" ).data( "dashboardId" )
		};
	};
	getWidgetContextData = function( $widgetEl ){
		var widgetInstanceId = $widgetEl.data( "instanceId" );
		if ( typeof widgetInstanceId !== "undefined" && typeof cfrequest[ widgetInstanceId ] !== "undefined" ) {
			return cfrequest[ widgetInstanceId ];
		}
		return {};
	};

	$dashBoardContainer.on( "click", ".admin-dashboard-widget .widget-configuration-link", function(){
		openWidgetConfigDialog( $( this ).closest( ".admin-dashboard-widget" ) );

		return false;
	} );
	$widgets.each( function(){ loadContent( $( this ) ); } );

} )( presideJQuery );