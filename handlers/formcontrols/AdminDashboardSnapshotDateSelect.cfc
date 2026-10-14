component {
	property name="presideObjectService" inject="presideObjectService";

	public string function index( event, rc, prc, args={} ) {
		var schemaId     = args.schemaId     ?: "";
		var recordObject = args.recordObject ?: "";
		var recordId     = args.recordId     ?: "";

		args.values = [ "" ];
		args.labels = [ translateResource( "admin.admindashboards.widget.snapshotConfig:field.snapshot_date.placeholder" ) ];

		if ( Len( Trim( schemaId ) ) && Len( Trim( recordId ) ) ) {
			var filter = { schema_id=schemaId, record_object=recordObject, record_id=recordId, status="complete" };

			var dates = presideObjectService.selectData(
				  objectName   = "admin_dashboard_snapshot"
				, selectFields = [ "snapshot_date" ]
				, filter       = filter
				, orderBy      = "snapshot_date desc"
				, distinct     = true
			);

			for ( var row in dates ) {
				ArrayAppend( args.values, DateTimeFormat( row.snapshot_date, "yyyy-mm-dd HH:nn:ss" ) );
				ArrayAppend( args.labels, DateTimeFormat( row.snapshot_date, "dd mmm yyyy HH:nn" ) );
			}
		}

		args.class                   = "form-control";
		args.removeObjectPickerClass = true;

		return renderView( view="formcontrols/select/index", args=args );
	}
}