component extends="preside.system.base.AdminHandler" {

	property name="datamanagerService"   inject="datamanagerService";
	property name="presideObjectService" inject="presideObjectService";

	private string function render( event, rc, prc, args={} ) {
		var objectName  = args.config.applies_to ?: "";
		var savedFilter = args.config.filter     ?: "";

		if ( isEmptyString( objectName ) ) {
			return "";
		}

		var gridFields     = listToArray( args.config.grid_fields ?: "" );
		var sortableFields = presideObjectService.getObjectAttribute(
			  objectName    = objectName
			, attributeName = "datamanagerSortableFields"
			, defaultValue  = ""
		);

		if ( !len( gridFields ) ) {
			gridFields = datamanagerService.defaultGridFields( objectName );
		}

		gridFields = arrayFilter( gridFields, function( item ) {
			return !isEmptyString( item );
		});

		var datasourceQueryString = "action=admindashboards.widget.DashboardDataFilter.getFilterResultsForAjaxDatatables&objectName=#objectName#&gridFields=#arrayToList( gridFields )#&sSavedFilterExpressions=#savedFilter#";

		if ( isWidgetSupportContext( argumentCollection=arguments ) ) {
			var prepareViewlet = "admin.admindashboards.context.#objectName#.dashboardDataFilter.prepareContextFilter";
			var coldbox        = getController();

			if ( coldbox.viewletExists( prepareViewlet ) ) {
				var preparedFilters = coldbox.renderViewlet(
					  event          = prepareViewlet
					, args           = args
					, throwOnMissing = false
				);

				if ( IsArray( preparedFilters ) && ArrayLen( preparedFilters ) ) {
					datasourceQueryString &= "&sContextExtraFilters=#URLEncodedFormat( SerializeJson( preparedFilters ) )#";
				}
			}
		}

		args.autoCtaLinkUrl = _buildAutoCtaLink( event=event, args=args );
		args.tableHtml      = renderView( view="/admin/datamanager/_objectDataTable", args={
			  objectName        = objectName
			, useMultiActions   = false
			, allowSearch       = false
			, allowFilter       = false
			, datasourceUrl     = event.buildAdminLink( linkTo="ajaxProxy", queryString=datasourceQueryString )
			, gridFields        = gridFields
			, sortableFields    = listToArray( sortableFields )
			, filterContextData = { widgetInstanceId=args.instanceId ?: "" }
		} );

		return renderView( view="/admin/admindashboards/widget/dashboardDataFilter/render", args=args );
	}

	private boolean function isUserDashboardWidget( event, rc, prc, args={} ) {
		return true;
	}

	private boolean function isWidgetSupportContext( event, rc, prc, args={} ) {
		var displayMode = Trim( args.config.display_mode ?: ( args.contextData.display_mode ?: "standard" ) );

		if ( Len( displayMode ) && displayMode != "contextual" ) {
			return false;
		}

		var targetObject = Trim( args.config.applies_to ?: ( args.contextData.applies_to ?: "" ) );

		if ( isEmptyString( targetObject ) ) {
			return false;
		}

		return _objectSupportsContextualDisplay( targetObject );
	}

	private string function ajaxCallback( event, rc, prc, args={} ) {
		return "widget_#replace( args.configInstanceId, "-", "", "all"  )#_init";
	}
	private void function ajaxIncludes( event, rc, prc, args={} ) {
		event.include( "/js/admin/specific/datamanager/object/");
		event.include( "/css/admin/specific/datamanager/object/");
		event.include( "/css/admin/specific/admindashboards/dataviz/", false );
		event.includeData( data={ defaultPageLength=5 } );

		event.includeInlineJs( "( function( $ ){ widget_#replace( args.configInstanceId, "-", "", "all" )#_init = function() { $( 'div[data-config-instance-id=#args.configInstanceId#].admin-dashboard-widget .object-listing-table' ).dataListingTable(); }; } )( presideJQuery );" );
	}

	public void function getFilterResultsForAjaxDatatables( event, rc, prc ) {
		if ( isEmptyString( rc.objectName ?: "" ) ) {
			return "";
		}

		var extraFilters = [];

		if ( Len( Trim( rc.sContextExtraFilters ?: "" ) ) ) {
			try {
				var decoded = DeserializeJSON( rc.sContextExtraFilters );

				if ( IsArray( decoded ) ) {
					extraFilters = decoded;
				}
			} catch ( any e ) {}
		}

		runEvent(
			  event          = "admin.DataManager._getObjectRecordsForAjaxDataTables"
			, prePostExempt  = true
			, private        = true
			, includeActions = false
			, eventArguments = {
				  object       = rc.objectName
				, actionsView  = "/admin/admindashboards/widget/dashboardDataFilter/_gridActions"
				, gridFields   = rc.gridFields
				, extraFilters = extraFilters
			}
		);
	}

// PRIVATE HELPERs
	private string function _buildAutoCtaLink( event, args={} ) {
		var objectName  = Trim( args.config.applies_to ?: "" );
		var savedFilter = Trim( args.config.filter     ?: "" );

		if ( !Len( objectName ) ) {
			return "";
		}

		if ( isWidgetSupportContext( argumentCollection=arguments ) ) {
			var ctaViewlet = "admin.admindashboards.context.#objectName#.dashboardDataFilter.buildCtaLink";
			var coldbox    = getController();

			if ( coldbox.viewletExists( ctaViewlet ) ) {
				var ctaResult = coldbox.renderViewlet(
					  event          = ctaViewlet
					, args           = args
					, throwOnMissing = false
				);

				if ( Len( Trim( ctaResult ?: "" ) ) ) {
					return ctaResult;
				}
			}
		}

		if ( !( dataManagerService.objectIsIndexedInDatamanagerUi( objectName=objectName ) ) ||
		     !( dataManagerService.isOperationAllowed( objectName=objectName, operation="read" ) ) ||
		     !( hasCmsPermission( permissionKey="datamanager.navigate", context="datamanager", contextKeys=[ objectName ] ) )
		) {
			return "";
		}

		if ( Len( savedFilter ) ) {
			var filterExpressions = getPresideObject( "rules_engine_condition" ).selectData(
				  id           = savedFilter
				, selectFields = [ "expressions" ]
				, returntype   = "singleValue"
				, columnKey    = "expressions"
			);

			if ( Len( filterExpressions ) ) {
				return event.buildAdminLink(
					  objectName  = objectName
					, queryString = "filter=#UrlEncode( ToBase64( filterExpressions ) )#"
				);
			}
		}

		return event.buildAdminLink( objectName=objectName );
	}

	public void function getObjectGridFieldsForAjaxControl( event, rc, prc ) {
		var result = [];

		if ( !isEmptyString( rc.object ?: "" ) ) {
			var fields = datamanagerService.listGridFields( rc.object );

			for( var field in fields ){
				ArrayAppend( result, {
					  value = field
					, text  = translatePropertyName( rc.object, field )
				} );
			}
		}

		event.renderData( type="json", data=result );;
	}

	public void function getObjectsForAjaxControl( event, rc, prc ) {
		var displayMode = rc.displayMode ?: "";
		var result      = [];
		var objects     = presideObjectService.listObjects();

		for( var object in objects ) {
			if ( presideObjectService.isPageType( object ) ) {
				continue;
			}

			if ( displayMode == "contextual" && !_objectSupportsContextualDisplay( object ) ) {
				continue;
			}

			ArrayAppend( result, {
				  value = object
				, text  = translateObjectName( object )
			} );
		}

		event.renderData( type="json", data=result );
	}

	private boolean function _objectSupportsContextualDisplay( required string objectName ) {
		var supportViewlet = "admin.admindashboards.context.#arguments.objectName#.dashboardDataFilter.supportContext";
		var coldbox        = getController();

		if ( !coldbox.viewletExists( supportViewlet ) ) {
			return false;
		}

		var viewletResult = coldbox.renderViewlet( event=supportViewlet, throwOnMissing=false );

		return isTrue( viewletResult ?: "" );
	}
}