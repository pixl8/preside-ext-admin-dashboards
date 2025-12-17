/**
 * @versioned                          false
 * @dataManagerEnabled                 true
 * @dataManagerGridFields              is_system,label,description,datemodified
 * @datamanagerDisallowedOperations    clone,batchedit,batchdelete
 */
component  {
	property name="label" formula="CONCAT_WS( '', ${prefix}title, ' ', '(', ${prefix}widget_id , ')' )" control="none";

	property name="widget_id"   type="string"  dbtype="varchar" maxlength=100  required=true indexes="widgetid" uniqueindexes="templateconfig|1";
	property name="title"       type="string"  dbtype="varchar" maxlength=250;
	property name="description" type="string"  dbtype="varchar" maxlength=2000;
	property name="group"       type="string"  dbtype="varchar" maxlength=100;
	property name="config_hash" type="string"  dbtype="varchar" maxlength=80   required=true                    uniqueindexes="templateconfig|2";
	property name="config"      type="string"  dbtype="text";
	property name="is_system"   type="boolean" dbtype="boolean" default=false indexes="issystem" batcheditable=false control="none";
}