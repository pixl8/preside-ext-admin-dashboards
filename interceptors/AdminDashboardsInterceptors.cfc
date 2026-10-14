component extends="coldbox.system.Interceptor" {

	property name="adminDashboardWidgetService"   inject="delayedInjector:adminDashboardWidgetService";
	property name="adminDashboardSnapshotService" inject="delayedInjector:adminDashboardSnapshotService";
	property name="formsService"                  inject="delayedInjector:formsService";

// PUBLIC
	public void function configure() {}

	public void function onApplicationStart( event, interceptData ) {
		adminDashboardWidgetService.syncDashboardWidgetTemplates();

		if ( isFeatureEnabled( "adminDashboardSnapshots" ) ) {
			adminDashboardSnapshotService.syncSchemaRegistrations();
		}
	}

	public void function postDeleteObjectData( event, interceptData ) {
		if ( !isFeatureEnabled( "adminDashboardSnapshots" ) ) {
			return;
		}

		var objectName = arguments.interceptData.objectName ?: "";
		var id         = arguments.interceptData.id         ?: "";

		if ( !Len( objectName ) || !Len( id ) ) {
			return;
		}

		if ( !ArrayLen( adminDashboardSnapshotService.getSchemasForObject( objectName ) ) ) {
			return;
		}

		for ( var recordId in ListToArray( id ) ) {
			adminDashboardSnapshotService.deleteRegistrationsForRecord(
				  recordObject = objectName
				, recordId     = recordId
			);
		}
	}

	public void function postInsertObjectData( event, interceptData ) {
		if ( !isFeatureEnabled( "adminDashboardSnapshots" ) ) {
			return;
		}

		var objectName = arguments.interceptData.objectName ?: "";
		var recordId   = arguments.interceptData.newId      ?: "";

		if ( !Len( objectName ) || !Len( recordId ) ) {
			return;
		}

		if ( !ArrayLen( adminDashboardSnapshotService.getSchemasForObject( objectName ) ) ) {
			return;
		}

		adminDashboardSnapshotService.syncSchemaRegistrationsForRecord(
			  recordObject = objectName
			, recordId     = recordId
		);
	}

	public void function onGetWidgetConfigFormName( event, interceptData ) {
		if ( !isFeatureEnabled( "adminDashboardSnapshots" ) ) {
			return;
		}

		if ( !_widgetConfigHasPersistedInstance( interceptData ) ) {
			return;
		}

		var widgetId = interceptData.widget.widgetId ?: "";

		if ( !Len( widgetId ) ) {
			return;
		}

		var snapshotConfig   = adminDashboardSnapshotService.getWidgetSnapshotConfig( widgetId );
		var isSingleMode     = StructIsEmpty( snapshotConfig ) || adminDashboardSnapshotService.isSchemaDefinitionSingleMode( snapshotConfig.schemaId ?: "" );
		var snapshotFormName = isSingleMode ? "admin.admindashboards.widget._snapshotConfigSingleMode" : "admin.admindashboards.widget._snapshotConfig";

		if ( formsService.formExists( snapshotFormName ) ) {
			interceptData.formName = formsService.getMergedFormName( formName=interceptData.formName, mergeWithFormName=snapshotFormName );
		}
	}

	public void function onRenderWidgetConfigForm( event, interceptData ) {
		if ( !isFeatureEnabled( "adminDashboardSnapshots" ) ) {
			return;
		}

		if ( !_widgetConfigHasPersistedInstance( interceptData ) ) {
			return;
		}

		var widgetId = interceptData.widget.widgetId ?: "";

		if ( !Len( widgetId ) ) {
			return;
		}

		var snapshotConfig = adminDashboardSnapshotService.getWidgetSnapshotConfig( widgetId );

		if ( StructIsEmpty( snapshotConfig ) ) {
			return;
		}

		var contextData = interceptData.contextData ?: {};
		var recordKey   = Len( snapshotConfig.widgetContextKey ?: "" ) ? snapshotConfig.widgetContextKey : ( snapshotConfig.recordObjectField ?: "" );
		var recordId    = Len( recordKey ) ? ( contextData[ recordKey ] ?: ( contextData.dashboard.widget.data[ recordKey ] ?: "" ) ) : "";

		interceptData.additionalArgs                                   = interceptData.additionalArgs                      ?: {};
		interceptData.additionalArgs.fields                            = interceptData.additionalArgs.fields               ?: {};
		interceptData.additionalArgs.fields.snapshot_date              = interceptData.additionalArgs.fields.snapshot_date ?: {};
		interceptData.additionalArgs.fields.snapshot_date.schemaId     = snapshotConfig.schemaId     ?: "";
		interceptData.additionalArgs.fields.snapshot_date.recordObject = snapshotConfig.recordObject ?: "";
		interceptData.additionalArgs.fields.snapshot_date.recordId     = recordId;
	}

	private boolean function _widgetConfigHasPersistedInstance( required struct interceptData ) {
		var widget = arguments.interceptData.widget ?: {};

		return Len( Trim( widget.instanceId ?: "" ) );
	}
}