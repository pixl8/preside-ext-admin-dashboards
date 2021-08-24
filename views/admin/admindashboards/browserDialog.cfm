<cfscript>
	widgets     = prc.widgets  ?: QueryNew('');
	dashboardId = rc.dashboard ?: "";
	column      = rc.column    ?: 1;
	linkQs      = "dashboard=#dashboardId#&column=#column#";
	baseLink    = event.buildAdminLink( linkTo="AdminDashboards.addWidget", queryString="#linkQs#&widget={widgetid}" );
</cfscript>

<cfoutput>

	<ul class="list-unstyled admin-dashboard-widget-picker">
		<cfloop query="widgets">
			<cfset widgetLink = baseLink.replace( "{widgetid}", widgets.id ) />
			<cfset widgetIcon = findNoCase(" ", widgets.icon) gt 0 ? widgets.icon : "#widgets.icon#">

			<li>
				<a href="#widgetLink#">
					<i class="fa fa-lg #widgetIcon#"></i>
					<h4>#widgets.title#</h4>
					<p>#widgets.description#</p>
				</a>
			</li>
		</cfloop>
	</ul>

</cfoutput>