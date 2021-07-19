/**
 * @labelField         name
 * @dataManagerEnabled true
 */

component  {
	property name="name"        type="string" dbtype="varchar" maxlength="50" required=true uniqueIndexes="dashboardName";
	property name="description" type="string" dbtype="text"    control="textarea";
	property name="owner"       relationship="many-to-one" relatedTo="security_user" required=true generate="insert" generator="adminDashboard.owner";

}