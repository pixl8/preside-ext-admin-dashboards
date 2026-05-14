/**
 * @feature adminDashboardSnapshots
 */
component {

	private string function default( event, rc, prc, args={} ) {
		var recordId     = args.data ?: "";
		var recordObject = args.record.record_object ?: "";

		if ( !Len( recordId ) || !Len( recordObject ) ) {
			return recordId;
		}

		return renderLabel( objectName=recordObject, recordId=recordId );
	}

}