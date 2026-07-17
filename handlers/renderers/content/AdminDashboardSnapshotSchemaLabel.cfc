/**
 * @feature adminDashboardSnapshots
 */
component {

	property name="adminDashboardSnapshotService" inject="adminDashboardSnapshotService";

	private string function default( event, rc, prc, args={} ) {
		var schemaId   = args.data ?: "";
		var definition = adminDashboardSnapshotService.getSchema( schemaId );

		return HtmlEditFormat( definition.label ?: schemaId );
	}

}