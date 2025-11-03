( function( $ ){

	$( ".admin-dashbboard-widget-confirmation" ).on( "click", function( event ) {
		event.preventDefault();

		window.parent.location.reload();
	});

} )( presideJQuery );