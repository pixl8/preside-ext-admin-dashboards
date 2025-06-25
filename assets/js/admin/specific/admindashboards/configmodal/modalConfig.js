( function( $ ){
	window.getAdminDashboardWidgetConfig = function(){
		return $( "#admin-dashboard-widget-config-form" ).serializeObject();
	};

	var $titleField            = $( "input.admin-dashboards-widget-title" )
	  , titleBasedOn           = $titleField.data( "basedon" )
	  , titleGeneratorEndpoint = cfrequest.titleGeneratorEndpoint || "";

	if ( titleBasedOn && ( titleBasedOn.length > 0 ) && ( titleGeneratorEndpoint.length > 0 ) ) {
		var basedOnFields    = titleBasedOn.split( "|" )
		  , fieldLabelValues = {}
		  , regenerateTitle;

		regenerateTitle = function( fields ) {
			for ( var i = 0; i < fields.length; i++ ) {
				if ( $( '[name="' + fields[i] + '"]' ) ) {
					fieldLabelValues[ fields[i] ] = $( '[name="' + fields[i] + '"]' ).val();
				}
			}

			$.ajax({
				  url  : titleGeneratorEndpoint
				, type : 'POST'
				, data : fieldLabelValues
			}).done(function(rendered) {
				if ( rendered.length > 0 ) {
					$titleField.val( rendered );
				}
			});
		}

		$titleField.closest( "form" ).on( "change dp.change", function(event) {
			regenerateTitle( basedOnFields );
		});
	}
} )( presideJQuery );