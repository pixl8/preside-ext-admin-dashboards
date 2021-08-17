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
						, method   : "POST"
						, complete : function() {
							loadContent( $widgetEl, true );
							if ( config.widget_title ) {
								$( ".widget-title span", $widgetEl ).text( config.widget_title );
							}
						  }
					} );
				}
			}
		  , browserIframeModal = new PresideIframeModal( iframeSrc, "100%", "100%", callbacks, modalOptions )
		  , dialogIframe;

		browserIframeModal.open();
	};

	loadContent = function( $widgetEl, refresh ){
		if ( $widgetEl.data( "ajax" ) ) {
			$widgetEl.find( ".widget-dynamic-content" ).presideLoadingSheen( true );

			$.ajax( buildAdminLink( "admindashboards", "renderWidgetContent" ), {
				  data     : $.extend( {}, getWidgetDetails( $widgetEl ), getWidgetContextData( $widgetEl ) )
				, success  : function( data ) { onWidgetContentFetchSuccess( $widgetEl, data ); }
				, error    : function() { onWidgetContentFetchError( $widgetEl ); }
				, complete : function() { $widgetEl.find( ".widget-dynamic-content" ).presideLoadingSheen( false ); }
			} );
		} else if ( refresh ) {
			location.reload();
		}
	};

	onWidgetContentFetchSuccess = function( $widgetEl, data ){
		$widgetEl.find( ".widget-dynamic-content" ).html( data );

		var callback = $widgetEl.data( "ajaxCallback" );
		if ( callback.length ) {
			window[ callback ]();
		}
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

	$dashBoardContainer.on( "click", ".admin-dashboard-widget .widget-delete-link", function( e ){
		e.preventDefault();

		var $link = $( this )
		  , title = ""
		  , $widgetEl = $link.closest( ".admin-dashboard-widget" );

		if ( !$link.data( "confirmationPrompt" ) ) {
			title = $link.data( "title" ) || $link.attr( "title" );
			title = title.charAt( 0 ).toLowerCase() + title.slice( 1 );
			$link.data( "confirmationPrompt", i18n.translateResource( "cms:confirmation.prompt", { data:[ title ] } ) );
		}

		var $message = $( "<div class=\"form-group\"><label>" + $link.data( "confirmationPrompt" ) + "</label></div>" )
		  , $input   = $( "<input class=\"bootbox-input form-control\" autocomplete=\"off\" type=\"text\" />" );

		var confirmationDialog = presideBootbox.dialog( {
			  title   : "Confirmation"
			, message : $message
			, buttons : {
				  cancel  : {
					  label: i18n.translateResource( "cms:confirmation.prompt.cancel.button" )
				  }
				, confirm : {
					  label: i18n.translateResource( "cms:confirmation.prompt.confirm.button" )
					, callback: function() {
						$widgetEl.find( ".widget-dynamic-content" ).presideLoadingSheen( true );
						$.ajax( $link.attr( "href" ), {
							  success  : function() { $widgetEl.remove(); }
							, error    : function() { $widgetEl.find( ".widget-dynamic-content" ).presideLoadingSheen( false ); }
							, complete : function() { confirmationDialog.modal( "hide" ); }
						} );
					  }
				}
			}
		} );
	} );

	$widgets.each( function(){ loadContent( $( this ), false ); } );

} )( presideJQuery );