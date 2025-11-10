( function( $ ){
	var widgetWrapper    = ".admin-dashboards-widgets-wrapper"
	  , $widgetWrapper   = $( widgetWrapper )
	  , searchField      = ".widgets-search-bar"
	  , groupField       = ".widgets-filter-select"
	  , resultContainer  = ".admin-dashboards-widgets-container"
	  , messageContainer = ".admin-dashboards-widgets-message-container"
	  , searchResultUrl  = cfrequest.resultUrl || ""
	  , updateSearchResult;

	if ( searchResultUrl.length > 0 ) {
		updateSearchResult = function( $el ) {
			var queryText = $el.find( searchField ).val()
			  , groupVal  = $el.find( groupField ).val();

			$.ajax( {
				  url  : searchResultUrl
				, type : "GET"
				, data : {
					  isGallery      : $el.find( '[name="is_gallery"]' ).val()
					, group          : groupVal
					, q              : queryText
					, selectedWidget : $el.find( '[name="selected_widget"]' ).val()
				}
			} )
			.done( function( result ) {
				var $messageContainer = $el.find( messageContainer );

				$el.find( resultContainer ).html( result );

				if ( result.length > 0 ) {
					$messageContainer.hide( "fast", function() {
						$(this).addClass( "hide" );
					} );
				} else {
					$messageContainer.removeClass( "hide" );
					$messageContainer.show( "fast" );
				}
			} );
		};

		$widgetWrapper.find( messageContainer ).hide();

		$widgetWrapper.on( "keyup", searchField, function(event) {
			updateSearchResult( $(this).closest( widgetWrapper ) );
		} );

		$widgetWrapper.on( "change", groupField, function(event) {
			updateSearchResult( $(this).closest( widgetWrapper ) );
		} );
	}
} )( presideJQuery );