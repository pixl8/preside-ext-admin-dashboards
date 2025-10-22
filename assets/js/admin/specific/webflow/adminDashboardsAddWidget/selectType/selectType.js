( function( $ ){
	var widgetImportItem = ".widget-type-import-item"
	  , toggleImportItem, autoSubmitForm;

	toggleImportItem = function( $el, animated=false ) {
		var selectedType = $el.find( ".widget-type-input:checked" ).val()
		  , $importItem  = $el.find( widgetImportItem );

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

	toggleImportItem( $( ".webflow-form-ajax-submit" ) );

	$( ".webflow-form-ajax-submit" ).on( "change click", ".widget-type-input", function(event) {
		toggleImportItem( $(this).closest( ".webflow-form-ajax-submit" ), true );
		autoSubmitForm( $(this) );
	});
} )( presideJQuery );