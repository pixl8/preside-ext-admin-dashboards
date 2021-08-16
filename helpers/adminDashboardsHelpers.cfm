<cffunction name="renderAdminDashboard" access="public" returntype="string" output="false">
	<cfscript>
		var userGenerated = isTrue( arguments.userGenerated ?: "" );

		if ( userGenerated ) {
			return getController().renderViewlet( event="admin.admindashboards.renderUserGeneratedDashboard", args=arguments );
		} else {
			return getController().renderViewlet( event="admin.admindashboards.renderDashboard", args=arguments );
		}
	</cfscript>
</cffunction>