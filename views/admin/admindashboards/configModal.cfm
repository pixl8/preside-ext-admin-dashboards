<cfscript>
	configForm = prc.configForm ?: "";
</cfscript>
<cfoutput>
	<form id="admin-dashboard-widget-config-form" action="" method="post" class="form-horizontal">
		#configForm#
	</form>
</cfoutput>