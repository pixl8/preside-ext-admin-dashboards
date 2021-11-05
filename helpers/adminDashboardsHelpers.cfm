<cffunction name="renderAdminDashboard" access="public" returntype="string" output="false">
<cfargument name="userGenerated" type="boolean" required="false" default="false" />
	<cfscript>
		if ( arguments.userGenerated ) {
			return getController().renderViewlet( event="admin.admindashboards.renderUserGeneratedDashboard", args=arguments );
		} else {
			return getController().renderViewlet( event="admin.admindashboards.renderDashboard", args=arguments );
		}
	</cfscript>
</cffunction>