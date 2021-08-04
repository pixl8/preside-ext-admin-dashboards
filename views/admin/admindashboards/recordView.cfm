<cfscript>
	dashboardId      = args.recordId ?: "";
	canEditDashboard = isTrue( args.canEditDashboard ?: "" );
</cfscript>

<cfoutput>
	#renderAdminDashboard(
	      dashboardId = dashboardId
	    , widgets     = args.widgets
	    , columnCount = 2
		, contextData = { canEditDashboard=canEditDashboard }
	)#
</cfoutput>