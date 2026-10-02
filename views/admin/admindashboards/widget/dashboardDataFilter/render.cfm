<cfscript>
	autoCtaLinkUrl = Trim( args.autoCtaLinkUrl ?: "" );
	tableHtml      = args.tableHtml            ?: "";
</cfscript>

<cfoutput>
	<cfif Len( autoCtaLinkUrl )>
		<a href="#autoCtaLinkUrl#" class="dataviz-single-metric-cta">
			<i class="fa #translateResource( uri='admin.admindashboards.widget.dashboardDataFilter:widget.cta_link.icon' )#"></i>
		</a>
	</cfif>

	#tableHtml#
</cfoutput>