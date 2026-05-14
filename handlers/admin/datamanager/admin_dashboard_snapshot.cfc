component extends="preside.system.base.EnhancedDataManagerBase" {

	property name="adminDashboardSnapshotService" inject="adminDashboardSnapshotService";

	private void function rootBreadcrumb( event, rc, prc, args={} ) {
		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard:menuTitle" )
			, link  = event.buildAdminLink( objectName="admin_dashboard" )
		);
		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard_snapshot_schema:title" )
			, link  = event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" )
		);
	}

	private boolean function checkPermission( event, rc, prc, args={} ) {
		var hasPerms = super.checkPermission( argumentCollection=arguments );

		return hasPerms && hasCmsPermission( "adminDashboards.manageSnapshots" );
	}

	private string function getAdditionalQueryStringForBuildAjaxListingLink( event, rc, prc, args={} ) {
		if ( ( prc.objectName ?: "" ) == "admin_dashboard_snapshot_schema" && Len( Trim( prc.recordId ?: "" ) ) ) {
			return "schemaRegistration=#prc.recordId#";
		}

		return "";
	}

	private void function preFetchRecordsForGridListing( event, rc, prc, args={} ) {
		args.extraFilters = args.extraFilters ?: [];

		var schemaRegistration = Trim( rc.schemaRegistration ?: "" );
		var schemaId           = Trim( rc.schemaId           ?: "" );
		var recordObject       = Trim( rc.recordObject       ?: "" );
		var recordId           = Trim( rc.recordId           ?: "" );

		if ( Len( schemaRegistration ) ) {
			ArrayAppend( args.extraFilters, { filter={ schema_registration=schemaRegistration } } );
		}
		if ( Len( schemaId ) ) {
			ArrayAppend( args.extraFilters, { filter={ schema_id=schemaId } } );
		}
		if ( Len( recordObject ) ) {
			ArrayAppend( args.extraFilters, { filter={ record_object=recordObject } } );
		}
		if ( Len( recordId ) ) {
			ArrayAppend( args.extraFilters, { filter={ record_id=recordId } } );
		}
	}

	private string function buildListingLink( event, rc, prc, args={} ) {
		var id = rc.id ?: "";

		if ( Len( Trim( id ) ) ) {
			var record = adminDashboardSnapshotService.getSnapshot(
				  snapshotId   = ListFirst( id )
				, selectFields = [ "schema_registration" ]
			);

			if ( !StructIsEmpty( record ) && Len( record.schema_registration ?: "" ) ) {
				return event.buildAdminLink( objectName="admin_dashboard_snapshot_schema", recordId=record.schema_registration );
			}
		}

		return event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" );
	}

	public void function viewRecord( event, rc, prc ) {
		var recordId = rc.id ?: "";
		var snapshot = adminDashboardSnapshotService.getSnapshot(
			  snapshotId   = recordId
			, selectFields = [ "id", "schema_registration", "schema_id", "record_object", "record_id", "snapshot_date", "status", "record_count", "time_taken", "triggered_by", "error_message", "snapshot_data", "datecreated" ]
		);

		if ( StructIsEmpty( snapshot ) ) {
			messageBox.error( translateResource( uri="cms:datamanager.recordNotFound.error" ) );
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot" ) );
		}

		prc.snapshotRecord = snapshot;

		if ( Len( prc.snapshotRecord.snapshot_data ?: "" ) ) {
			try {
				prc.snapshotData = deserializeJson( prc.snapshotRecord.snapshot_data );
			} catch ( any e ) {
				prc.snapshotData = [];
			}
		} else {
			prc.snapshotData = [];
		}

		prc.pageTitle = renderLabel( objectName="admin_dashboard_snapshot", recordId=recordId, labelRenderer="admin_dashboard_snapshot" );
		prc.pageIcon  = translateResource( uri="preside-objects.admin_dashboard_snapshot:iconClass", defaultValue="fa-database" );

		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard:menuTitle" )
			, link  = event.buildAdminLink( objectName="admin_dashboard" )
		);
		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard_snapshot_schema:title" )
			, link  = event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" )
		);
		event.addAdminBreadCrumb(
			  title = renderLabel( "admin_dashboard_snapshot_schema", prc.snapshotRecord.schema_registration )
			, link  = event.buildAdminLink( objectName="admin_dashboard_snapshot_schema", recordId=prc.snapshotRecord.schema_registration )
		);
		event.addAdminBreadCrumb(
			  title = prc.snapshotRecord.schema_id
			, link  = ""
		);

		event.setView( "/admin/datamanager/admin_dashboard_snapshot/viewRecord" );
	}

}
