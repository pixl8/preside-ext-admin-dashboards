<cfscript>
	objectLabel = translateResource( uri="preside-objects.admin_dashboard:title.singular" );
	objectIcon  = translateResource( uri="preside-objects.admin_dashboard:iconClass", defaultValue="" );
</cfscript>

<cfoutput>
	<h2>
		<cfif Len( Trim( objectIcon ) )>
			<i class="fa fa-fw #objectIcon#"></i>
		</cfif>
		#objectLabel#
	</h2>
</cfoutput>