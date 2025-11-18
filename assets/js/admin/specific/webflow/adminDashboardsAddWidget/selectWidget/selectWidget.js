( function( $ ){
	let widgetWrapper      = ".admin-dashboards-widgets-wrapper"
	  , $widgetWrapper     = $( widgetWrapper )
	  , searchField        = ".widgets-search-bar"
	  , selectItemField    = ".widgets-filter-selected-item"
	  , $selectedContainer = $( ".widgets-filter-selected" )
	  , resultContainer    = ".admin-dashboards-widgets-container"
	  , messageContainer   = ".admin-dashboards-widgets-message-container"
	  , groupFieldName     = cfrequest.groupFieldName || "group"
	  , searchResultUrl    = cfrequest.resultUrl      || ""
	  , updateSearchResult;

	if ( searchResultUrl.length > 0 ) {
		updateSearchResult = function( $el ) {
			var queryText      = $el.find( searchField ).val()
			  , selectedGroups = []
			  , $checkedGroups = $el.find( '[name="' + groupFieldName + '"]:checked' );

			$selectedContainer.empty();
			$checkedGroups.each( function( ind, el ) {
				var groupVal = $( el ).val();

				$selectedContainer.append( '<a href="#" class="widgets-filter-selected-item" data-value="' + groupVal + '">' + $( el ).data( "label" ) + '</a>' );
				selectedGroups.push( groupVal );
			} );

			$.ajax( {
				  url  : searchResultUrl
				, type : "GET"
				, data : {
					  isGallery      : $el.find( '[name="is_gallery"]' ).val()
					, groups         : selectedGroups.toString()
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

		$widgetWrapper.on( "change", '[name="' + groupFieldName + '"]', function(event) {
			updateSearchResult( $(this).closest( widgetWrapper ) );
		} );

		$widgetWrapper.on( "click", selectItemField, function(event) {
			event.preventDefault();

			$( 'input[name="' + groupFieldName + '"][value="' + $(this).data( "value" ) + '"]' ).prop( "checked", false );

			updateSearchResult( $(this).closest( widgetWrapper ) );
		});
	}
} )( presideJQuery );