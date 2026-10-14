/**
 * @feature                         adminDashboardSnapshots
 * @nolabel                         true
 * @labelRenderer                   admin_dashboard_snapshot
 * @versioned                       false
 * @dataManagerEnabled              true
 * @dataManagerGridFields           schema_id,record_object,record_id,snapshot_date,status,record_count,time_taken,triggered_by
 * @dataManagerDefaultSortOrder     snapshot_date desc
 * @dataManagerAllowedOperations    navigate,read,delete
 */
component {
	property name="schema_registration" relationship="many-to-one" relatedTo="admin_dashboard_snapshot_schema" required=true ondelete="cascade" indexes="regLookup";

	property name="schema_id"      type="string"  dbtype="varchar"  maxlength=100 required=true indexes="snapshotDateLookup|1";
	property name="record_object"  type="string"  dbtype="varchar"  maxlength=100 required=true indexes="snapshotDateLookup|2";
	property name="record_id"      type="string"  dbtype="varchar"  maxlength=35  required=true indexes="snapshotDateLookup|3";
	property name="snapshot_date"  type="date"    dbtype="datetime"               required=true indexes="snapshotDateLookup|4";

	property name="status"         type="string"  dbtype="varchar"  maxlength=20  required=true default="pending" enum="adminDashboardSnapshotStatus";
	property name="snapshot_data"  type="string"  dbtype="longtext"               required=false;
	property name="record_count"   type="numeric" dbtype="int"                    required=false;
	property name="time_taken"     type="numeric" dbtype="int"                    required=false renderer="TaskTimeTaken";
	property name="error_message"  type="string"  dbtype="text"                   required=false;

	property name="triggered_by"      type="string" dbtype="varchar" maxlength=20 required=true default="scheduled" enum="adminDashboardSnapshotTrigger";
	property name="triggered_by_user" relationship="many-to-one" relatedTo="security_user" required=false;
}
