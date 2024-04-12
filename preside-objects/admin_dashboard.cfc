/**
 * @labelField                   name
 * @versioned                    false
 * @dataManagerEnabled           true
 * @dataManagerGridFields        name,owner,view_access,edit_access,datecreated
 * @dataManagerDefaultSortOrder  name
 * @dataManagerHiddenGridFields  owner_id,view_groups_list,view_users_list,edit_groups_list,edit_users_list
 * @dataManagerAllowedOperations navigate,read,add,edit,clone,delete
 * @dataManagerSearchFields      name,description,owner
 */

component  {
	property name="name"         type="string"  dbtype="varchar" maxlength="50" required=true uniqueIndexes="dashboardName";
	property name="description"  type="string"  dbtype="varchar" maxlength="300";
	property name="column_count" type="numeric" dbtype="int"     default=2;

	property name="owner"        relationship="many-to-one" relatedTo="security_user" required=true generate="insert" generator="adminDashboard.owner" cloneable=false;
	property name="widgets"      relationship="one-to-many" relatedto="admin_dashboard_widget" relationshipKey="dashboard" cloneable=true;

	property name="view_access" type="string" dbtype="varchar" maxlength=10 enum="adminDashboardViewAccess" default="private";
	property name="view_groups" adminRenderer="ObjectRelatedRecordsList" relationship="many-to-many" relatedTo="security_group" relatedVia="admin_dashboard_view_group" cloneable=false;
	property name="view_users"  adminRenderer="ObjectRelatedRecordsList" relationship="many-to-many" relatedTo="security_user"  relatedVia="admin_dashboard_view_user"  cloneable=false;

	property name="edit_access" type="string" dbtype="varchar" maxlength=10 enum="adminDashboardEditAccess" default="private";
	property name="edit_groups" adminRenderer="ObjectRelatedRecordsList" relationship="many-to-many" relatedTo="security_group" relatedVia="admin_dashboard_edit_group" cloneable=false;
	property name="edit_users"  adminRenderer="ObjectRelatedRecordsList" relationship="many-to-many" relatedTo="security_user"  relatedVia="admin_dashboard_edit_user"  cloneable=false;

	property name="owner_id"         adminRenderer="none" type="string" formula="${prefix}owner.id";
	property name="view_groups_list" adminRenderer="none" type="string" formula="group_concat( distinct ${prefix}view_groups.id )";
	property name="view_users_list"  adminRenderer="none" type="string" formula="group_concat( distinct ${prefix}view_users.id )";
	property name="edit_groups_list" adminRenderer="none" type="string" formula="group_concat( distinct ${prefix}edit_groups.id )";
	property name="edit_users_list"  adminRenderer="none" type="string" formula="group_concat( distinct ${prefix}edit_users.id )";
}