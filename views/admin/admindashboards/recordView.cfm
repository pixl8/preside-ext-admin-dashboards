<cfscript>
	dashboardId      = args.recordId ?: "";
	canEditDashboard = isTrue( args.canEditDashboard ?: "" );
</cfscript>

<cfoutput>
	#renderAdminDashboard(
	      dashboardId   = dashboardId
		, userGenerated = true
		, allowEditing  = true
	)#
</cfoutput>