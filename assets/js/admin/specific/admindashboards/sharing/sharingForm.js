( function( $ ){

	var $viewAccess = $( "[name=view_access]" )
	  , $editAccess = $( "[name=edit_access]" );

	if ( $viewAccess.length ) {
		var $viewAccessRelated = $viewAccess.closest( ".form-group" ).siblings( ".form-group" );

		$viewAccess.on( "change", function(){
			$viewAccessRelated.toggle( $viewAccess.filter( ":checked" ).val() == "specific" );
		} ).trigger( "change" );
	}

	if ( $editAccess.length ) {
		var $editAccessRelated = $editAccess.closest( ".form-group" ).siblings( ".form-group" );

		$editAccess.on( "change", function(){
			$editAccessRelated.toggle( $editAccess.filter( ":checked" ).val() == "specific" );
		} ).trigger( "change" );
	}

} )( presideJQuery );