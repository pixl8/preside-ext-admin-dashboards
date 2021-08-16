/**
 * @versioned false
 * @nolabel
 */
component {
	property name="dashboard"     relationship="many-to-one" relatedto="admin_dashboard" required=true indexes="adminDashboardWidgetDashboard";
	property name="widget_id"     type="string"  dbtype="varchar" maxlength=100          required=true;
	property name="instance_id"   type="string"  dbtype="varchar" maxlength=100          required=true indexes="adminDashboardWidgetInstance";
	property name="title"         type="string"  dbtype="varchar" maxlength=50           required=true;
	property name="column"        type="numeric" dbtype="int";
	property name="row"           type="numeric" dbtype="int";
	property name="config"        type="string"  dbtype="text";
}
