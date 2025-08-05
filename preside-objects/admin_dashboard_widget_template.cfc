/**
 * @versioned    false
 * @nolabel      true
 */
component  {
	property name="widget_id"   type="string" dbtype="varchar" maxlength=100  required=true indexes="widgetid" uniqueindexes="templateconfig|1";
	property name="title"       type="string" dbtype="varchar" maxlength=250;
	property name="description" type="string" dbtype="varchar" maxlength=2000;
	property name="group"       type="string" dbtype="varchar" maxlength=100;
	property name="config_hash" type="string" dbtype="varchar" maxlength=80   required=true                    uniqueindexes="templateconfig|1";
	property name="config"      type="string" dbtype="text";
}