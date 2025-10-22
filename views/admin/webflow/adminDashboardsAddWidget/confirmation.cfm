<cfscript>
	introText   = Trim( args.stepConfig.intro ?: "" );
	dashboardId = Trim( rc.dashboard          ?: "" );
	buttonUrl   = Len( dashboardId ) ? event.buildAdminLink( objectName="admin_dashboard", operation="editdashboardlayout", recordId=dashboardId ) : ( cgi.http_referer ?: "" );
</cfscript>

<cfoutput>
	<cfif isEmptyString( introText )>
		<div class="alert alert-success">
			<i class="fa fa-fw fa-info-circle"></i>
			#translateResource( uri="webflow.adminDashboardsAddWidget:step.confirmation.default.intro" )#
		</div>
	</cfif>

	<a class="btn btn-info" href="#buttonUrl#">
		#translateResource( uri="webflow.adminDashboardsAddWidget:step.confirmation.btn" )#
	</a>
</cfoutput>