component extends="preside.system.base.AdminHandler" {

	property name="datamanagerService" inject="datamanagerService";

	private string function render( event, rc, prc, args={} ) {
		var objectName  = args.config.applies_to ?: "";
		var savedFilter = args.config.filter     ?: "";

		if ( isEmptyString( objectName ) ) {
			return "";
		}

		var gridFields = listToArray( args.config.grid_fields ?: "" );

		if ( !len( gridFields ) ) {
			gridFields = datamanagerService.defaultGridFields( objectName );
		}

		gridFields = arrayFilter( gridFields, function( item ) {
			return !isEmptyString( item );
		});

		return renderView( view="/admin/datamanager/_objectDataTable", args={
			  objectName      = objectName
			, useMultiActions = false
			, allowSearch     = false
			, allowFilter     = false
			, datasourceUrl   = event.buildAdminLink( linkTo="ajaxProxy", queryString="action=admindashboards.widget.DashboardDataFilter.getFilterResultsForAjaxDatatables&objectName=#objectName#&gridFields=#arrayToList( gridFields )#&sSavedFilterExpressions=#savedFilter#" )
			, gridFields      = gridFields
		} );
	}

	private boolean function isUserDashboardWidget( event, rc, prc, args={} ) {
		return true;
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

		runEvent(
			  event          = "admin.DataManager._getObjectRecordsForAjaxDataTables"
			, prePostExempt  = true
			, private        = true
			, includeActions = false
			, eventArguments = {
				  object      = rc.objectName
				, actionsView = "/admin/admindashboards/widget/dashboardDataFilter/_gridActions"
				, gridFields  = rc.gridFields
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