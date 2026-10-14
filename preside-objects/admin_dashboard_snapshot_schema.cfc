/**
 * @feature                         adminDashboardSnapshots
 * @labelField                      schema_id
 * @labelRenderer                   admin_dashboard_snapshot_schema
 * @versioned                       false
 * @dataManagerEnabled              true
 * @dataManagerGridFields           is_active,schema_id,record_object,record_id,snapshot_count,snapshot_mode,auto_stop_date,datecreated
 * @dataManagerDefaultSortOrder     datecreated desc
 * @dataManagerAllowedOperations    navigate,read,edit,batchedit
 */
component {
	property name="schema_id"      type="string"  dbtype="varchar" maxlength=100 required=true batcheditable=false indexes="schemaLookup|1" renderer="AdminDashboardSnapshotSchemaLabel";
	property name="record_object"  type="string"  dbtype="varchar" maxlength=100 required=true batcheditable=false indexes="schemaLookup|2,recordLookup|1" renderer="AdminDashboardSnapshotRecordObject";
	property name="record_id"      type="string"  dbtype="varchar" maxlength=35  required=true batcheditable=false indexes="schemaLookup|3,recordLookup|2" renderer="AdminDashboardSnapshotRecordLabel";
	property name="snapshot_mode"  type="string"  dbtype="varchar" maxlength=20  required=false default="single" enum="adminDashboardSnapshotMode";
	property name="auto_stop_date" type="date"    dbtype="datetime"              required=false control="datepicker";
	property name="is_active"      type="boolean" dbtype="boolean"               default=true batcheditable=false;

	property name="snapshot_count" type="numeric" dbtype="int" formula="Count( ${prefix}snapshots.id )" required=false;

	property name="created_by" relationship="many-to-one" relatedTo="security_user" required=false generate="insert" generator="loggedInUserId" batcheditable=false;
	property name="snapshots" relationship="one-to-many" relatedTo="admin_dashboard_snapshot" relationshipKey="schema_registration"             batcheditable=false;
}
