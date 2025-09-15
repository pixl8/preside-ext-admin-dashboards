<cfscript>
	canEditDashboard = isTrue( args.canEditDashboard ?: "" );
</cfscript>
<cfoutput>
	<cfif canEditDashboard>
		<div class="text-center">
			<a class="btn btn-primary btn-sm" href="#event.buildAdminLink( objectName="admin_dashboard", operation="addRecord" )#">
				#translateResource( uri="preside-objects.admin_dashboard:create.btn" )#
			</a>
		</div>
	</cfif>
</cfoutput>