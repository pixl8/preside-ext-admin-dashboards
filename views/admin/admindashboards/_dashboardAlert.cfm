<cfscript>
	alertType         = args.alertType         ?: "";
	headingIcon       = args.headingIcon       ?: "";
	heading           = args.heading           ?: translateResource( "admindashboards:actions-list.heading" );
	alertContent      = args.alertContent      ?: "";
	isCollapsibleOpen = args.isCollapsibleOpen ?: true;
</cfscript>
<cfoutput>
	<cfif !isEmptyString( alertContent )>
		<div class="alert #alertType# alert-dashboard">
			<h5>
				<cfif !isEmptyString( headingIcon ) ><i class="fa fa-lg #headingIcon# alert-dashboard-icon"></i></cfif>
				#heading#

				<button class="alert-dashboard-toggle" type="button" data-toggle="collapse" data-target="##dashboard-alert" aria-expanded="#isCollapsibleOpen#" aria-controls="dashboard-alert"><i class="fa fa-chevron-up"></i></button>
			</h5>

			<div class="alert-dashboard-collapsible <cfif isCollapsibleOpen>in<cfelse>collapse</cfif>" id="dashboard-alert">
				<div class="alert-dashboard-collapsible-content">
					#alertContent#
				</div>
			</div>
		</div>
	</cfif>
</cfoutput>