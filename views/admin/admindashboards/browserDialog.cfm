<cfscript>
	widgets     = prc.widgets  ?: QueryNew('');
	dashboardId = rc.dashboard ?: "";
	column      = rc.column    ?: 1;
	linkQs      = "dashboard=#dashboardId#&column=#column#";
	baseLink    = event.buildAdminLink( linkTo="AdminDashboards.addWidget", queryString="#linkQs#&widget={widgetid}" );
</cfscript>

<cfoutput>

	<ul class="list-unstyled page-type-list">
		<cfloop query="widgets">
			<cfset widgetLink = baseLink.replace( "{widgetid}", widgets.id ) />
			<cfset widgetIcon = findNoCase(" ", widgets.icon) gt 0 ? widgets.icon : "fa #widgets.icon#">

			<li class="page-type">
				<h3 class="page-type-title">
					<a href="#widgetLink#">
						<i class="#widgetIcon# fa fa-lg"></i>
						#widgets.title#
					</a>
				</h3>
				<p>#widgets.description#</p>
			</li>
		</cfloop>
	</ul>

</cfoutput>