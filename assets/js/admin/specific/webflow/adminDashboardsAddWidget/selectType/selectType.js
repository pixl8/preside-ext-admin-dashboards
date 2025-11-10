( function( $ ){
	var widgetImportItem = ".widget-type-import-item"
	  , toggleImportItem, autoSubmitForm;

	toggleImportItem = function( $el, animated=false ) {
		var selectedType = $( ".widget-type-input:checked" ).val()
		  , $importItem  = $( widgetImportItem );

		if ( selectedType == "import" ) {
			$importItem.removeClass( "hide" );
			$importItem.show( animated ? "fast" : null );
		} else {
			$importItem.hide( animated ? "fast" : null, function() {
				$(this).addClass( "hide" );
			} );
		}
	};

	autoSubmitForm = function( $el ) {
		var selectedType = $el.val();

		if ( ( selectedType == "gallery" ) || ( selectedType == "scratch" ) ) {
			$el.closest( "form" ).submit();
		}
	};

	toggleImportItem( $( ".widget-type-input" ) );

	$( ".widget-type-input" ).on( "change click", function(event) {
		toggleImportItem( $(this), true );
		autoSubmitForm( $(this) );
	});
} )( presideJQuery );