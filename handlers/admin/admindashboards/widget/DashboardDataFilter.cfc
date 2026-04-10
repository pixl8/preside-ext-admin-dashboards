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

		return renderView( view="/admin/datamanager/_objectDataTable", args={
			  objectName        = objectName
			, useMultiActions   = false
			, allowSearch       = false
			, allowFilter       = false
			, datasourceUrl     = event.buildAdminLink( linkTo="ajaxProxy", queryString=datasourceQueryString )
			, gridFields        = gridFields
			, sortableFields    = listToArray( sortableFields )
			, filterContextData = { widgetInstanceId=args.instanceId ?: "" }
		} );
	}

	private boolean function isUserDashboardWidget( event, rc, prc, args={} ) {
		return true;
	}

	private boolean function isWidgetSupportContext( event, rc, prc, args={} ) {
		var targetObject = Trim( args.config.applies_to ?: args.contextData.applies_to ?: "" );

		if ( isEmptyString( targetObject ) ) {
			return false;
		}

		var supportViewlet = "admin.admindashboards.context.#targetObject#.dashboardDataFilter.supportContext";
		var coldbox        = getController();

		if ( !coldbox.viewletExists( supportViewlet ) ) {
			return false;
		}

		var viewletResult = coldbox.renderViewlet(
			  event          = supportViewlet
			, args           = args
			, throwOnMissing = false
		);

		return isTrue( viewletResult ?: "" );
	}

	private string function ajaxCallback( event, rc, prc, args={} ) {
		return "widget_#replace( args.configInstanceId, "-", "", "all"  )#_init";
	}
	private void function ajaxIncludes( event, rc, prc, args={} ) {
		event.include( "/js/admin/specific/datamanager/object/");
		event.include( "/css/admin/specific/datamanager/object/");
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

	public void function getObjectGridFieldsForAjaxControl( event, rc, prc ) {
		var result = [];

		if ( !isEmptyString( rc.object ?: "" ) ) {
			var fields = datamanagerService.listGridFields( rc.object );

			for( var field in fields ){
				arrayAppend( result, {
					  value = field
					, text  = translatePropertyName( rc.object, field )
				} );
			}
		}

		event.renderData( type="json", data=result );;
	}
}