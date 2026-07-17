/**
 * @presideService    true
 * @singleton         true
 */
component {

// CONSTRUCTOR
	/**
	 * @autoDiscoverDirectories.inject    presidecms:directories
	 */
	public any function init(
		  required array  autoDiscoverDirectories
	) {
		_setAutoDiscoverDirectories( arguments.autoDiscoverDirectories );
		reload();

		return this;
	}

// PUBLIC APIs
	public void function reload() {
		_autoDiscoverSchemas();
	}

	public struct function getSchemas() {
		return Duplicate( _getSchemas() );
	}

	public struct function getRegistration(
		  required string registrationId
		,          array  selectFields = []
	) {
		return $getPresideObject( "admin_dashboard_snapshot_schema" ).selectData(
			  id           = arguments.registrationId
			, selectFields = arguments.selectFields
			, returntype   = "singleRecordStruct"
		);
	}

	public struct function getSnapshot(
		  required string snapshotId
		,          array  selectFields = []
	) {
		return $getPresideObject( "admin_dashboard_snapshot" ).selectData(
			  id           = arguments.snapshotId
			, returntype   = "singleRecordStruct"
			, selectFields = arguments.selectFields
		);
	}

	public struct function getSchema( required string schemaId ) {
		return _resolveSchemaDefinition( arguments.schemaId );
	}

	public struct function getWidgetSnapshotConfig( required string widgetId ) {
		var viewlet = "admin.admindashboards.widget.#arguments.widgetId#.snapshotConfig";

		if ( !$getColdbox().viewletExists( viewlet ) ) {
			return {};
		}

		try {
			var config = $getColdbox().runEvent(
				  event          = viewlet
				, private        = true
				, prePostExempt  = true
				, eventArguments = { args={} }
			);

			return IsStruct( config ?: "" ) ? config : {};
		} catch ( any e ) {
			$raiseError( e );
			return {};
		}
	}

	public boolean function isSchemaDefinitionSingleMode( required string schemaId ) {
		if ( !Len( arguments.schemaId ) ) {
			return true;
		}

		var definition = getSchema( arguments.schemaId );

		return ( definition.defaultSnapshotMode ?: "single" ) == "single";
	}

	public array function getSchemasForObject( required string objectName ) {
		var schemas = _getSchemas();
		var result  = [];

		for ( var id in schemas ) {
			var resolved = _resolveSchemaDefinition( id );
			if ( ( resolved.recordObject ?: "" ) == arguments.objectName ) {
				ArrayAppend( result, resolved );
			}
		}

		return result;
	}

	public string function registerSchema(
		  required string schemaId
		, required string recordObject
		, required string recordId
		,          string snapshotMode  = "single"
		,          string autoStopDate  = ""
	) {
		var dao    = $getPresideObject( "admin_dashboard_snapshot_schema" );
		var exists = dao.selectData(
			  filter       = { schema_id=arguments.schemaId, record_object=arguments.recordObject, record_id=arguments.recordId }
			, selectFields = [ "id" ]
		);

		if ( exists.recordCount ) {
			dao.updateData(
				  id   = exists.id
				, data = {
					  snapshot_mode  = arguments.snapshotMode
					, auto_stop_date = arguments.autoStopDate
					, is_active      = true
				  }
			);
			return exists.id;
		}

		return dao.insertData( data={
			  schema_id      = arguments.schemaId
			, record_object  = arguments.recordObject
			, record_id      = arguments.recordId
			, snapshot_mode  = arguments.snapshotMode
			, auto_stop_date = arguments.autoStopDate
			, is_active      = true
		} );
	}

	public void function syncSchemaRegistrations() {
		var schemas        = getSchemas();
		var validSchemaIds = StructKeyArray( schemas );
		var regDao         = $getPresideObject( "admin_dashboard_snapshot_schema" );

		for ( var schemaId in schemas ) {
			var definition   = _resolveSchemaDefinition( schemaId );
			var recordObject = definition.recordObject ?: "";

			if ( !Len( recordObject ) ) {
				continue;
			}

			var existingRegs              = regDao.selectData(
				  filter       = { schema_id=schemaId, record_object=recordObject }
				, selectFields = [ "id", "record_id" ]
			);
			var registeredIds             = ValueList( existingRegs.record_id );
			var baseDefaultConfig         = _getSchemaDefaultConfig( definition );
			var defaultConfigSelectFields = _getSchemaDefaultConfigSelectFields( definition );
			var allRecords                = $getPresideObject( recordObject ).selectData( selectFields=defaultConfigSelectFields );
			var currentIdList             = ValueList( allRecords.id );

			for ( var existingReg in existingRegs ) {
				if ( !ListFindNoCase( currentIdList, existingReg.record_id ) ) {
					deleteRegistration( existingReg.id );
				}
			}

			for ( var rec in allRecords ) {
				if ( !ListFindNoCase( registeredIds, rec.id ) ) {
					var recordDefaultConfig = _getSchemaDefaultConfigForRecord( schemaId, rec, baseDefaultConfig );
					regDao.insertData( data={
						  schema_id     = schemaId
						, record_object = recordObject
						, record_id     = rec.id
						, snapshot_mode = recordDefaultConfig.snapshot_mode
						, is_active     = recordDefaultConfig.is_active
					} );
				}
			}
		}

		if ( ArrayLen( validSchemaIds ) ) {
			regDao.updateData(
				  filter       = { is_active=true }
				, extraFilters = [ { filter="schema_id NOT IN (:schema_ids)", filterParams={ schema_ids={ value=ArrayToList( validSchemaIds ), type="cf_sql_varchar", list=true } } } ]
				, data         = { is_active=false }
			);
		}
	}

	public void function syncSchemaRegistrationsForRecord(
		  required string recordObject
		, required string recordId
	) {
		var schemas = getSchemas();
		var regDao  = $getPresideObject( "admin_dashboard_snapshot_schema" );

		for ( var schemaId in schemas ) {
			var definition    = _resolveSchemaDefinition( schemaId );
			var schemaObjName = definition.recordObject ?: "";

			if ( schemaObjName != arguments.recordObject ) {
				continue;
			}

			var exists = regDao.selectData(
				  filter       = { schema_id=schemaId, record_object=arguments.recordObject, record_id=arguments.recordId }
				, selectFields = [ "id" ]
			);

			if ( !exists.recordCount ) {
				var baseDefaultConfig         = _getSchemaDefaultConfig( definition );
				var defaultConfigSelectFields = _getSchemaDefaultConfigSelectFields( definition );
				var recordData                = $getPresideObject( arguments.recordObject ).selectData(
					  id           = arguments.recordId
					, selectFields = defaultConfigSelectFields
					, returntype   = "singleRecordStruct"
				);
				var defaultConfig = _getSchemaDefaultConfigForRecord( schemaId, recordData, baseDefaultConfig );

				regDao.insertData( data={
					  schema_id     = schemaId
					, record_object = arguments.recordObject
					, record_id     = arguments.recordId
					, snapshot_mode = defaultConfig.snapshot_mode
					, is_active     = defaultConfig.is_active
				} );
			}
		}
	}

	public void function deleteRegistration( required string registrationId ) {
		$getPresideObject( "admin_dashboard_snapshot" ).deleteData(
			filter = { schema_registration=arguments.registrationId }
		);
		$getPresideObject( "admin_dashboard_snapshot_schema" ).deleteData(
			id = arguments.registrationId
		);
	}

	public void function deleteRegistrationsForRecord(
		  required string recordObject
		, required string recordId
	) {
		var registrations = $getPresideObject( "admin_dashboard_snapshot_schema" ).selectData(
			  filter       = { record_object=arguments.recordObject, record_id=arguments.recordId }
			, selectFields = [ "id" ]
		);

		for ( var reg in registrations ) {
			deleteRegistration( reg.id );
		}
	}

	public void function unregisterSchema( required string registrationId ) {
		$getPresideObject( "admin_dashboard_snapshot_schema" ).updateData(
			  id   = arguments.registrationId
			, data = { is_active=false }
		);
	}

	public void function activateRegistrationsForRecord(
		  required string recordObject
		, required string recordId
	) {
		$getPresideObject( "admin_dashboard_snapshot_schema" ).updateData(
			  filter = { record_object=arguments.recordObject, record_id=arguments.recordId }
			, data   = { is_active=true }
		);
	}

	public void function deactivateRegistrationsForRecord(
		  required string recordObject
		, required string recordId
	) {
		$getPresideObject( "admin_dashboard_snapshot_schema" ).updateData(
			  filter = { record_object=arguments.recordObject, record_id=arguments.recordId }
			, data   = { is_active=false }
		);
	}

	public query function getRegistrationsForRecord( required string recordObject, required string recordId ) {
		return $getPresideObject( "admin_dashboard_snapshot_schema" ).selectData(
			  filter = { record_object=arguments.recordObject, record_id=arguments.recordId, is_active=true }
			, orderBy = "schema_id"
		);
	}

	public string function captureSnapshot(
		  required string registrationId
		,          string triggeredBy     = "manual"
		,          string triggeredByUser = ""
		,          date   snapshotDate    = Now()
	) {
		var snapDao      = $getPresideObject( "admin_dashboard_snapshot" );
		var registration = getRegistration( arguments.registrationId );

		if ( StructIsEmpty( registration ) ) {
			throw( type="AdminDashboardSnapshotService.registrationNotFound", message="Registration [#arguments.registrationId#] not found." );
		}

		var schemaId     = registration.schema_id;
		var recordObject = registration.record_object;
		var recordId     = registration.record_id;
		var schema       = getSchema( schemaId );

		if ( structIsEmpty( schema ) ) {
			throw( type="AdminDashboardSnapshotService.schemaNotFound", message="Snapshot schema [#schemaId#] not found." );
		}

		var snapshotId = _initSnapshotRecord(
			  registrationId  = arguments.registrationId
			, registration    = registration
			, triggeredBy     = arguments.triggeredBy
			, triggeredByUser = arguments.triggeredByUser
			, snapshotDate    = arguments.snapshotDate
		);

		try {
			snapDao.updateData( id=snapshotId, data={ status="running" } );

			var startTick    = getTickCount();
			var sourceObject = schema.sourceObject;
			var filterField  = schema.filterField;
			var selectFields = schema.selectFields ?: [];
			var filter       = { "#sourceObject#.#filterField#"=recordId };

			var extraFilters = _getSchemaExtraFilters( schemaId, recordId );
			var rawData      = $getPresideObject( sourceObject ).selectData(
				  filter       = filter
				, extraFilters = extraFilters
				, selectFields = selectFields
			);

			var data = _transformSchemaData( schemaId, rawData );
			var json = serializeJson( data );

			snapDao.updateData( id=snapshotId, data={
				  status        = "complete"
				, snapshot_data = json
				, record_count  = rawData.recordCount
				, time_taken    = getTickCount() - startTick
			} );
		} catch( any e ) {
			snapDao.updateData( id=snapshotId, data={
				  status        = "failed"
				, error_message = e.message & " " & e.detail
				, time_taken    = getTickCount() - ( startTick ?: getTickCount() )
			} );

			rethrow;
		}

		return snapshotId;
	}

	public string function captureSnapshotAsync(
		  required string registrationId
		,          string triggeredBy     = "manual"
		,          string triggeredByUser = ""
		,          date   snapshotDate    = Now()
	) {
		var registration = getRegistration( arguments.registrationId );

		if ( StructIsEmpty( registration ) ) {
			throw( type="AdminDashboardSnapshotService.registrationNotFound", message="Registration [#arguments.registrationId#] not found." );
		}

		var snapshotId = _initSnapshotRecord(
			  registrationId  = arguments.registrationId
			, registration    = registration
			, triggeredBy     = arguments.triggeredBy
			, triggeredByUser = arguments.triggeredByUser
			, snapshotDate    = arguments.snapshotDate
		);

		var threadId = "snapshotCapture_#snapshotId#";

		thread name="#threadId#" snapshotId=snapshotId registrationId=arguments.registrationId triggeredBy=arguments.triggeredBy triggeredByUser=arguments.triggeredByUser {
			try {
				_executeCaptureInThread(
					  snapshotId      = attributes.snapshotId
					, registrationId  = attributes.registrationId
					, triggeredBy     = attributes.triggeredBy
					, triggeredByUser = attributes.triggeredByUser
				);
			} catch ( any e ) {
				$raiseError(e);
			}
		}

		return snapshotId;
	}

	private string function _initSnapshotRecord(
		  required string registrationId
		, required struct registration
		,          string triggeredBy     = "manual"
		,          string triggeredByUser = ""
		,          date   snapshotDate    = Now()
	) {
		var snapDao    = $getPresideObject( "admin_dashboard_snapshot" );
		var singleMode = ( arguments.registration.snapshot_mode ?: "single" ) == "single";

		if ( singleMode ) {
			var existing = snapDao.selectData(
				  filter       = { schema_registration=arguments.registrationId }
				, selectFields = [ "id" ]
				, maxRows      = 1
			);

			if ( existing.recordCount ) {
				snapDao.updateData( id=existing.id, data={
					  snapshot_date     = arguments.snapshotDate
					, status            = "pending"
					, triggered_by      = arguments.triggeredBy
					, triggered_by_user = arguments.triggeredByUser
					, snapshot_data     = ""
					, error_message     = ""
				} );
				return existing.id;
			}
		}

		return snapDao.insertData( data={
			  schema_registration = arguments.registrationId
			, schema_id           = arguments.registration.schema_id
			, record_object       = arguments.registration.record_object
			, record_id           = arguments.registration.record_id
			, snapshot_date       = arguments.snapshotDate
			, status              = "pending"
			, triggered_by        = arguments.triggeredBy
			, triggered_by_user   = arguments.triggeredByUser
		} );
	}

	private void function _executeCaptureInThread(
		  required string snapshotId
		, required string registrationId
		, required string triggeredBy
		, required string triggeredByUser
	) {
		var snapDao      = $getPresideObject( "admin_dashboard_snapshot" );
		var registration = getRegistration( arguments.registrationId );

		if ( StructIsEmpty( registration ) ) {
			snapDao.updateData( id=arguments.snapshotId, data={
				  status        = "failed"
				, error_message = "Registration not found"
			} );

			return;
		}

		var schemaId = registration.schema_id;
		var schema   = getSchema( schemaId );

		if ( structIsEmpty( schema ) ) {
			snapDao.updateData( id=arguments.snapshotId, data={
				  status        = "failed"
				, error_message = "Schema [#schemaId#] not found"
			} );
			return;
		}

		try {
			snapDao.updateData( id=arguments.snapshotId, data={ status="running" } );

			var startTick    = getTickCount();
			var sourceObject = schema.sourceObject;
			var filterField  = schema.filterField;
			var selectFields = schema.selectFields ?: [];
			var recordId     = registration.record_id;
			var filter       = { "#sourceObject#.#filterField#"=recordId };

			var extraFilters = _getSchemaExtraFilters( schemaId, recordId );
			var rawData      = $getPresideObject( sourceObject ).selectData(
				  filter       = filter
				, extraFilters = extraFilters
				, selectFields = selectFields
			);

			var data = _transformSchemaData( schemaId, rawData );
			var json = serializeJson( data );

			snapDao.updateData( id=arguments.snapshotId, data={
				  status        = "complete"
				, snapshot_data = json
				, record_count  = rawData.recordCount
				, time_taken    = getTickCount() - startTick
			} );
		} catch ( any e ) {
			snapDao.updateData( id=arguments.snapshotId, data={
				  status        = "failed"
				, error_message = e.message & " " & e.detail
			} );
		}
	}

	public struct function getSnapshotAtDate(
		  required string schemaId
		, required string recordObject
		, required string recordId
		,          date   date = Now()
	) {
		var snapDao = $getPresideObject( "admin_dashboard_snapshot" );
		var result  = snapDao.selectData(
			  filter       = {
				  schema_id      = arguments.schemaId
				, record_object  = arguments.recordObject
				, record_id      = arguments.recordId
				, status         = "complete"
			  }
			, extraFilters = [ { filter="snapshot_date <= :snapshot_date", filterParams={ snapshot_date={ value=arguments.date, type="cf_sql_timestamp" } } } ]
			, orderBy      = "snapshot_date desc"
			, maxRows      = 1
		);

		if ( !result.recordCount ) {
			return {};
		}

		return _queryRowToStruct( result );
	}

	public any function getSnapshotData(
		  required string schemaId
		, required string recordObject
		, required string recordId
		,          date   date = Now()
	) {
		var snapshot = getSnapshotAtDate(
			  schemaId     = arguments.schemaId
			, recordObject = arguments.recordObject
			, recordId     = arguments.recordId
			, date         = arguments.date
		);

		if ( structIsEmpty( snapshot ) ) {
			return [];
		}

		var rawJson = snapshot.snapshot_data ?: "";
		if ( !len( rawJson ) ) {
			return [];
		}

		return deserializeJson( rawJson );
	}

	public struct function aggregateSnapshotData(
		  required string snapshotId
		, required string groupBy
		,          string countField = ""
	) {
		var snapshot = getSnapshot( snapshotId=arguments.snapshotId, selectFields=[ "snapshot_data" ] );

		if ( StructIsEmpty( snapshot ) || !Len( snapshot.snapshot_data ?: "" ) ) {
			return {};
		}

		var data   = deserializeJson( snapshot.snapshot_data );
		var result = {};

		if ( !isArray( data ) ) {
			return result;
		}

		for ( var row in data ) {
			var key = row[ arguments.groupBy ] ?: "unknown";
			if ( !structKeyExists( result, key ) ) {
				result[ key ] = 0;
			}
			result[ key ]++;
		}

		return result;
	}

	public query function getSnapshotHistory(
		  required string recordObject
		, required string recordId
		,          string schemaId = ""
	) {
		var filter = {
			  record_object = arguments.recordObject
			, record_id     = arguments.recordId
		};

		if ( len( arguments.schemaId ) ) {
			filter.schema_id = arguments.schemaId;
		}

		return $getPresideObject( "admin_dashboard_snapshot" ).selectData(
			  filter       = filter
			, selectFields = [ "id", "schema_id", "snapshot_date", "status", "record_count", "time_taken", "triggered_by", "error_message", "datecreated" ]
			, orderBy      = "snapshot_date desc"
		);
	}

	public boolean function processScheduledSnapshots( any logger ) {
		var success       = true;
		var regDao        = $getPresideObject( "admin_dashboard_snapshot_schema" );
		var registrations = regDao.selectData(
			  filter       = { is_active=true }
		);

		if ( !registrations.recordCount ) {
			arguments.logger?.info( "No active snapshot registrations found. Nothing to process." );
			return success;
		}

		for ( var reg in registrations ) {
			if ( isDate( reg.auto_stop_date ) && reg.auto_stop_date < Now() ) {
				regDao.updateData( id=reg.id, data={ is_active=false } );

				arguments.logger?.info( "Deactivated registration [#reg.schema_id#] for [#reg.record_object#:#reg.record_id#] — auto-stop date passed." );
				continue;
			}

			if ( !_isSnapshotDue( reg.id ) ) {
				arguments.logger?.info( "Snapshot not yet due for schema [#reg.schema_id#], record [#reg.record_object#:#reg.record_id#] — skipping." );
				continue;
			}

			try {
				arguments.logger?.info( "Capturing snapshot for schema [#reg.schema_id#], record [#reg.record_object#:#reg.record_id#]..." );

				captureSnapshotAsync(
					  registrationId  = reg.id
					, triggeredBy     = "scheduled"
				);

				arguments.logger?.info( "Snapshot captured successfully." );
			} catch ( any e ) {
				$raiseError(e);
				arguments.logger?.error( "Failed to capture snapshot for [#reg.schema_id#]: #e.message#" );
				success = false;
			}
		}

		return success;
	}

	public array function backfillSnapshots(
		  required string registrationId
		, required date   startDate
		, required date   endDate
		,          string triggeredByUser = ""
		,          any    logger
	) {
		if ( !isNull( arguments.logger ) ) {
			arguments.logger.warn( "BACKFILL WARNING: Backfill snapshots capture the current state of CRM data stamped with historical dates. This is NOT true historical data — it reflects how records look today, not how they looked on those past dates." );
		}

		var snapshotIds = [];
		var currentDate = arguments.startDate;

		while ( currentDate <= arguments.endDate ) {
			var snapshotId = captureSnapshot(
				  registrationId  = arguments.registrationId
				, triggeredBy     = "backfill"
				, triggeredByUser = arguments.triggeredByUser
				, snapshotDate    = currentDate
			);
			snapshotIds.append( snapshotId );
			currentDate = dateAdd( "d", 1, currentDate );
		}

		return snapshotIds;
	}

	private void function _autoDiscoverSchemas() {
		var schemas                 = {};
		var handlersPath            = "/handlers/admin/adminDashboards/snapshotSchema";
		var autoDiscoverDirectories = _getAutoDiscoverDirectories();

		for ( var dir in autoDiscoverDirectories ) {
			dir = ReReplace( dir, "/$", "" );
			var fullPath = dir & handlersPath;

			if ( !DirectoryExists( fullPath ) ) {
				continue;
			}

			var handlers = DirectoryList( fullPath, false, "query", "*.cfc" );

			for ( var handler in handlers ) {
				if ( handlers.type == "File" ) {
					var id = LCase( ReReplace( handlers.name, "\.cfc$", "" ) );
					var viewlet = "admin.admindashboards.snapshotSchema.#id#.definition";

					schemas[ id ] = {
						  id      = id
						, viewlet = viewlet
					};
				}
			}
		}

		_setSchemas( schemas );
		_validateDiscoveredSchemas();
	}

	private void function _validateDiscoveredSchemas() {
		var schemas = _getSchemas();

		for ( var id in schemas ) {
			var definition = _resolveSchemaDefinition( id );

			if ( !Len( definition.sourceObject ?: "" ) ) {
				throw(
					  type    = "AdminDashboardSnapshotService.invalidSchema"
					, message = "Snapshot schema [#id#] is missing required property [sourceObject]."
				);
			}
			if ( !Len( definition.filterField ?: "" ) ) {
				throw(
					  type    = "AdminDashboardSnapshotService.invalidSchema"
					, message = "Snapshot schema [#id#] is missing required property [filterField]."
				);
			}
		}
	}

	private struct function _resolveSchemaDefinition( required string schemaId ) {
		var schemas = _getSchemas();
		var schema  = schemas[ arguments.schemaId ] ?: {};

		if ( structIsEmpty( schema ) ) {
			return {};
		}

		if ( structKeyExists( schema, "sourceObject" ) ) {
			return schema;
		}

		try {
			var definition = $getColdbox().runEvent(
				  event          = schema.viewlet
				, private        = true
				, prePostExempt  = true
				, eventArguments = { args={} }
			);

			if ( isStruct( definition ) ) {
				structAppend( schema, definition );
				schemas[ arguments.schemaId ] = schema;
			}
		} catch ( any e ) {
			$raiseError( e );
		}

		return schema;
	}

	private array function _getSchemaExtraFilters( required string schemaId, required string recordId ) {
		var viewlet = "admin.admindashboards.snapshotSchema.#arguments.schemaId#.extraFilters";

		if ( $getColdbox().viewletExists( viewlet ) ) {
			try {
				var result = $getColdbox().runEvent(
					  event          = viewlet
					, private        = true
					, prePostExempt  = true
					, eventArguments = { args={ recordId=arguments.recordId } }
				);
				if ( isArray( result ) ) {
					return result;
				}
			} catch ( any e ) {
				$raiseError( e );
			}
		}

		return [];
	}

	private any function _transformSchemaData( required string schemaId, required query rawData ) {
		var viewlet = "admin.admindashboards.snapshotSchema.#arguments.schemaId#.transformData";

		if ( $getColdbox().viewletExists( viewlet ) ) {
			try {
				var result = $getColdbox().runEvent(
					  event          = viewlet
					, private        = true
					, prePostExempt  = true
					, eventArguments = { args={ rawData=arguments.rawData } }
				);
				if ( !isNull( result ) ) {
					return result;
				}
			} catch ( any e ) {
				$raiseError( e );
			}
		}

		return _queryToArray( arguments.rawData );
	}

	private struct function _getSchemaDefaultConfig( required struct definition ) {
		var explicit = arguments.definition.defaultConfig ?: {};

		return {
			  snapshot_mode = explicit.snapshot_mode ?: ( arguments.definition.defaultSnapshotMode ?: "single" )
			, is_active     = IsBoolean( explicit.is_active ?: "" ) ? explicit.is_active : true
		};
	}

	private array function _getSchemaDefaultConfigSelectFields( required struct definition ) {
		var fields = Duplicate( arguments.definition.defaultConfigSelectFields ?: [] );
		if ( !ArrayFindNoCase( fields, "id" ) ) {
			ArrayAppend( fields, "id" );
		}
		return fields;
	}

	private struct function _getSchemaDefaultConfigForRecord(
		  required string schemaId
		, required struct record
		, required struct defaultConfig
	) {
		var viewlet = "admin.admindashboards.snapshotSchema.#arguments.schemaId#.defaultConfigForRecord";

		if ( $getColdbox().viewletExists( viewlet ) ) {
			try {
				var result = $getColdbox().runEvent(
					  event          = viewlet
					, private        = true
					, prePostExempt  = true
					, eventArguments = { args={ record=arguments.record } }
				);
				if ( ( IsStruct( result ?: "" ) ) && !StructIsEmpty( result ) ) {
					return {
						  snapshot_mode = result.snapshot_mode ?: arguments.defaultConfig.snapshot_mode
						, is_active     = IsBoolean( result.is_active ?: "" ) ? result.is_active : arguments.defaultConfig.is_active
					};
				}
			} catch ( any e ) {
				$raiseError( e );
			}
		}

		return arguments.defaultConfig;
	}

	private boolean function _isSnapshotDue( required string registrationId ) {
		var snapDao      = $getPresideObject( "admin_dashboard_snapshot" );
		var lastSnapshot = snapDao.selectData(
			  filter       = { schema_registration=arguments.registrationId, status="complete" }
			, selectFields = [ "snapshot_date" ]
			, orderBy      = "snapshot_date desc"
			, maxRows      = 1
		);

		if ( !lastSnapshot.recordCount ) {
			return true;
		}

		return DateDiff( "d", lastSnapshot.snapshot_date, Now() ) > 0;
	}

	private array function _queryToArray( required query q ) {
		var result  = [];
		var columns = arguments.q.getColumnNames();

		for ( var row in arguments.q ) {
			var item = {};
			for ( var col in columns ) {
				item[ lCase( col ) ] = row[ col ] ?: "";
			}
			result.append( item );
		}

		return result;
	}

	private struct function _queryRowToStruct( required query q, numeric row=1 ) {
		var result  = {};
		var columns = arguments.q.getColumnNames();

		for ( var col in columns ) {
			result[ lCase( col ) ] = arguments.q[ col ][ arguments.row ] ?: "";
		}

		return result;
	}

// GETTERS AND SETTERS
	private struct function _getSchemas() {
		return _schemas ?: {};
	}
	private void function _setSchemas( required struct schemas ) {
		_schemas = arguments.schemas;
	}

	private array function _getAutoDiscoverDirectories() {
		return _autoDiscoverDirectories ?: [];
	}
	private void function _setAutoDiscoverDirectories( required array autoDiscoverDirectories ) {
		_autoDiscoverDirectories = arguments.autoDiscoverDirectories;
	}


}