<cfscript>
	groupId     = args.groupId ?: "";
	widgets     = args.widgets    ?: QueryNew('');
	dashboardId = rc.dashboard    ?: "";
	column      = rc.column       ?: 1;
	linkQs      = "dashboard=#dashboardId#&column=#column#";
	baseLink    = event.buildAdminLink( linkTo="adminDashboards.addWidget", queryString="#linkQs#&widget={widgetid}" );
</cfscript>

<cfoutput>
	<cfif widgets.recordcount>
		<ul class="list-unstyled admin-dashboard-widget-picker" id="group-#groupId#">
			<cfloop query="widgets">
				<cfscript>
					widgetLink = baseLink.replace( "{widgetid}", widgets.id );
					widgetIcon = findNoCase(" ", widgets.icon) gt 0 ? widgets.icon : "#widgets.icon#";

					if ( IsStruct( widgets.config ?: "" ) ) {
						for ( var key in widgets.config ) {
							widgetLink &= "&config-#key#=#widgets.config[ key ]#";
						}
					}

					isTemplate = isTrue( widgets.isTemplate ?: "" );
				</cfscript>

				<li>
					<a href="#widgetLink#">
						<i class="fa fa-lg #widgetIcon#"></i>
						<h4>
							#widgets.title#
							<cfif isTemplate>
								<code>(template)</code>
							</cfif>
						</h4>
						<p>#widgets.description#</p>
					</a>
				</li>
			</cfloop>
		</ul>
	</cfif>
</cfoutput>