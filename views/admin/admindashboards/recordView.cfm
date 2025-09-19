<cfscript>
	dashboardId      = args.recordId       ?: "";
	dashboardAlert   = args.dashboardAlert ?: "";
	canEditDashboard = isTrue( args.canEditDashboard ?: "" );
</cfscript>

<cfoutput>

	<cfif !isEmptyString( dashboardAlert )>
		#dashboardAlert#
	</cfif>

	#renderAdminDashboard(
	      dashboardId   = dashboardId
		, userGenerated = true
		, allowEditing  = true
	)#
</cfoutput>