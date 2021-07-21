<cfscript>
	objectName = "admin_dashboard";

	WriteOutput( renderView(
		  view = "/admin/layout/sidebar/_menuItem"
		, args = {
			  active = event.getCurrentEvent().reFindNoCase( "^admin\.datamanager\." ) && ( prc.objectName ?: "" ) == "#objectName#"
			, link   = event.buildAdminLink( objectName="#objectName#" )
			, icon   = translateResource( "preside-objects.#objectName#:iconClass" )
			, title  = translateResource( "preside-objects.#objectName#:menuTitle" )
			}
	) );
</cfscript>