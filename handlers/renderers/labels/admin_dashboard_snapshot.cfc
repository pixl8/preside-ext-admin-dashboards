/**
 * @feature adminDashboardSnapshots
 */
component {

	property name="adminDashboardSnapshotService" inject="adminDashboardSnapshotService";

	private array function _selectFields( event, rc, prc, args={} ) {
		return [ "schema_id", "record_object", "record_id", "snapshot_date" ];
	}

	private string function _renderLabel( event, rc, prc, args={} ) {
		var schemaId     = arguments.schema_id     ?: "";
		var recordObject = arguments.record_object ?: "";
		var recordId     = arguments.record_id     ?: "";
		var snapshotDate = arguments.snapshot_date ?: "";
		var definition   = adminDashboardSnapshotService.getSchema( schemaId );
		var label        = definition.label ?: schemaId;

		if ( Len( recordObject ) && Len( recordId ) ) {
			var objectLabel = translateResource( uri="preside-objects.#recordObject#:title.singular", defaultValue=recordObject );
			var recordLabel = renderLabel( objectName=recordObject, recordId=recordId );

			label &= " — " & objectLabel & ": " & recordLabel;
		}

		if ( IsDate( snapshotDate ) ) {
			label &= " (" & dateFormat( snapshotDate, "yyyy-mm-dd" ) & " " & timeFormat( snapshotDate, "HH:mm" ) & ")";
		}

		return label;
	}

}
