<cfscript>
	objectName = args.objectName ?: "admin_dashboard_snapshot";
	gridFields = args.gridFields ?: [];
</cfscript>

<cfoutput>
	#objectDataTable(
		  objectName = objectName
		, args       = { gridFields=gridFields }
	)#
</cfoutput>