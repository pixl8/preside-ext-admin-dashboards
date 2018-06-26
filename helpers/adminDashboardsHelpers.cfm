<cffunction name="renderAdminDashboard" access="public" returntype="string" output="false">
	<cfscript>
		return getController().renderViewlet( event="admin.admindashboards.renderDashboard", args=arguments );
	</cfscript>
</cffunction>