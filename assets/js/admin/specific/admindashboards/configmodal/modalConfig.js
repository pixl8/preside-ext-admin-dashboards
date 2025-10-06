( function( $ ){
	window.getAdminDashboardWidgetConfig = function() {
		return $( "#admin-dashboard-widget-config-form" ).serializeObject();
	};

	window.clearAllFormErrors = function() {
		$( ".form-group .clearfix .help-block.error-message" ).remove();
		$( ".form-group .has-error" ).removeClass( "has-error" );
	};

	window.getModalElements = function( fieldName ) {
		return $( '[name="' + fieldName + '"]' );
	};

	// Derived from preside/system/handlers/rules/fieldtypes/TimePeriod.cfc$renderConfiguredField
	function renderTimePeriodLabel( timePeriod={ type:"alltime" } ) {
		let i18nArgs = { data:[] };
		let type     = "alltime"
		let timeUnit = timePeriod.unit || "d";

		switch( timePeriod.type || "alltime" ) {
			case "between":
				type          = timePeriod.type;
				i18nArgs.data = [ timePeriod.date1 || "", timePeriod.date2 || "" ];
			break;
			case "since":
			case "before":
			case "until":
			case "after":
			case "equal":
				type          = timePeriod.type;
				i18nArgs.data = [ timePeriod.date1 || "" ];
			break;
			case "recent":
			case "upcoming":
			case "pastminus":
			case "futureplus":
				type          = timePeriod.type;
				i18nArgs.data = [
					  parseInt( timePeriod.measure || 0 )
					, i18n.translateResource( `cms:time.period.unit.${timeUnit}` )
				];
			break;
			case "pastequal":
			case "futureequal":
				type          = timePeriod.type;
				i18nArgs.data = [
					  parseInt( timePeriod.measure || 0 )
					, i18n.translateResource( "cms:time.period.unit.d" )
				];
			break;
			case "future":
			case "past":
			case "yesterday":
			case "today":
			case "tomorrow":
			case "lastweek":
			case "thisweek":
			case "nextweek":
			case "lastmonth":
			case "thismonth":
			case "nextmonth":
				type = timePeriod.type;
			break;
			default:
				type = "alltime";
		}

		return i18n.translateResource( `cms:rulesEngine.time.period.type.${type}.configured`, i18nArgs );
	}

	var $titleField  = $( "input.admin-dashboards-widget-title" )
	  , titleBasedOn = $titleField.data( "basedon" )
	  , $form        = $titleField.closest( "form" );

	if ( titleBasedOn && ( titleBasedOn.length > 0 ) ) {
		var basedOnFields    = titleBasedOn.split( "|" )
		  , fieldLabelValues = {}
		  , regenerateTitle;

		regenerateTitle = function( fields ) {

			for ( var i = 0; i < fields.length; i++ ) {
				const uberSelect = $( `#${fields[i]}` ).data( "uberSelect" );

				if( uberSelect != undefined ) {
					// If both selected, and current value is empty, then it is indeed empty.
					if( !uberSelect.getSelected().length && !uberSelect.value.length ) {
						fieldLabelValues[ fields[i] ] = "";
					} else if( uberSelect.getSelected().length ) {
						// Sometimes hidden field is empty due to being programatically reset, if so, there is really no selected value.
						if( uberSelect.hidden_field.val().length ) {
							fieldLabelValues[ fields[i] ] = uberSelect.getSelected()[0].text;
						} else {
							fieldLabelValues[ fields[i] ] = "";
						}
					} else if( uberSelect.value.length ) {
						fieldLabelValues[ fields[i] ] = uberSelect.selected_item.text();
					}
				} else {
					if ( $( `[name="${fields[i]}"]` ).length ) {
						fieldLabelValues[ fields[i] ] = $( '[name="' + fields[i] + '"]' ).val();
					}
				}
			}

			let   metricTitle     = ""
			    , metricLabel     = ( fieldLabelValues[ "metric" ] || "" ).trim()
			    , groupBy1        = ( fieldLabelValues[ "group_by_1" ] || "" ).trim()
			    , groupBy2        = ( fieldLabelValues[ "group_by_2" ] || "" ).trim()
			    , timePeriodLabel = "";

			if( metricLabel.length ) {
				metricLabel = metricLabel.replace( /\([^()]*\)(?=[^()]*$)/, "" ).trim(); // remove object's name inside paretheses
			}

			if( ( fieldLabelValues[ "time_period" ] || "" ).length ) {
				timePeriodLabel = renderTimePeriodLabel( JSON.parse( fieldLabelValues[ "time_period" ] ) );
			}

			if( groupBy1.length && groupBy2.length ) {
				metricTitle = i18n.translateResource( "preside-objects.admin_dashboard:dataviz.metric.default.two_groups.title", { data:[ metricLabel, groupBy1, groupBy2 ] } );
			} else if( groupBy1.length || groupBy2.length ) {
				metricTitle = i18n.translateResource( "preside-objects.admin_dashboard:dataviz.metric.default.one_group.title", { data:[ metricLabel, groupBy1.length ? groupBy1 : groupBy2 ] } );
			} else {
				metricTitle = i18n.translateResource( "preside-objects.admin_dashboard:dataviz.metric.default.title", { data:[ metricLabel ] } );
			}

			$titleField.val( `${metricTitle} ${timePeriodLabel}` );
		}

		// Title started empty (ie. new widget added), allow auto-title generation
		if( !$titleField.val().trim().length ) {
			$titleField.addClass( "is-empty-start" )
		}

		$titleField.on( "change", function( event ) {
			// If user customized the title, keep it and do not auto-generate the title further
			if( $titleField.val().trim().length ) {
				$titleField.addClass( "has-user-custom-title" );
			} else {
				$titleField.removeClass( "has-user-custom-title" ).addClass( "is-empty-start" );
			}
		} );

		$form.on( "change dp.change", function( event ) {
			const thisElName = event.target.getAttribute( "name" ) || event.target.getAttribute( "id" ) || "";

			if( ( !$titleField.val().trim().length || $titleField.hasClass( "is-empty-start" ) ) && !$titleField.hasClass( "has-user-custom-title" ) ) {
				if( basedOnFields.includes( thisElName ) || ( basedOnFields.includes( "time_period" ) && thisElName.indexOf( "time_period" ) == 0 ) ) {
					regenerateTitle( basedOnFields );
				}
			}
		} );
	}

} )( presideJQuery );