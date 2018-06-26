/**
 * @versioned false
 * @nolabel   true
 */
component  {
	property name="user"         relationship="many-to-one" relatedto="security_user" required=true uniqueindexes="dashboardconfig|1" ondelete="cascade";
	property name="dashboard_id" type="string" dbtype="varchar"  maxlength=100        required=true uniqueindexes="dashboardconfig|2";
	property name="widget_id"    type="string" dbtype="varchar"  maxlength=100        required=true uniqueindexes="dashboardconfig|3";
	property name="config"       type="string" dbtype="text";
}