<cfscript>
	objectName = "admin_dashboard";
	iconClass  = translateResource( "preside-objects.#objectName#:iconClass" );
	linkTitle  = translateResource( "preside-objects.#objectName#:menuTitle" );
</cfscript>

<cfoutput>
	<cfif hasCmsPermission( "adminDashboards.navigate" )>
		<li>
			<a href="#event.buildAdminLink( objectName=objectName )#">
				<i class="fa fa-fw #iconClass#"></i>
				#linkTitle#
			</a>
		</li>
	</cfif>
</cfoutput>