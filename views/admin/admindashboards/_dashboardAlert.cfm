<cfscript>
	alertType    = args.alertType    ?: "";
	headingIcon  = args.headingIcon  ?: "";
	heading      = args.heading      ?: translateResource( "admindashboards:actions-list.heading" );
	alertContent = args.alertContent ?: "";
</cfscript>
<cfoutput>
	<cfif !isEmptyString( alertContent )>
		<div class="alert #alertType# alert-dashboard">
			<cfif !isEmptyString( heading )>
				<h5>
					<cfif !isEmptyString( headingIcon ) ><i class="fa fa-fw fa-lg #headingIcon# alert-dashboard-icon"></i></cfif>
					#heading#
				</h5>
			</cfif>

			#alertContent#
		</div>
	</cfif>
</cfoutput>