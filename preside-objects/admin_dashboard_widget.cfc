/**
 * @versioned false
 * @nolabel
 */
component {
	property name="dashboard"     relationship="many-to-one" relatedto="admin_dashboard" required=true;
	property name="widget_id"     type="string" dbtype="varchar" maxlength=100           required=true;
	property name="instance_id"   type="string" dbtype="varchar" maxlength=100           required=true;
	property name="title"         type="string" bdtype="varchar" maxlength=50            required=true;
	property name="display_order" type="numeric";
	property name="config"        type="string" dbtype="text";
}
