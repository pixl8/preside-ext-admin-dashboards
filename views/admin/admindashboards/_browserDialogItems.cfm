<cfscript>
	groupId     = args.groupId ?: "";
	widgets     = args.widgets ?: QueryNew('');
	dashboardId = rc.dashboard ?: "";
	column      = rc.column    ?: 1;
	linkQs      = "dashboard=#dashboardId#&column=#column#";
	baseLink    = event.buildAdminLink( linkTo="adminDashboards.addWidget", queryString="#linkQs#&widget={widgetid}" );
</cfscript>

<cfoutput>
	<cfif widgets.recordcount>
		<cfloop query="widgets">
			<cfscript>
				widgetId   = widgets.id;
				widgetLink = baseLink.replace( "{widgetid}", widgetId );
				widgetIcon = findNoCase(" ", widgets.icon) gt 0 ? widgets.icon : "#widgets.icon#";

				if ( Len( Trim( widgets.recordId ?: "" ) ) ) {
					widgetLink &= "&templateId=#widgets.recordId#";
				}

				isTemplate = isTrue( widgets.isTemplate ?: "" );
			</cfscript>

			<li class="admin-dashboard-widget-item" data-widget-group="#groupId#" data-widget-id="#widgetId#">
				<a class="admin-dashboard-widget-item-link" href="#widgetLink#">
					<h4 class="admin-dashboard-widget-item-title">
						#widgets.title#
					</h4>

					<cfif !isTemplate>
						<div class="admin-dashboard-widget-tags">
							<span class="admin-dashboard-widget-tag-item">
								#translateResource( uri="admindashboards:item.tag.uncategorised.label" )#
							</span>
						</div>
					</cfif>

					<cfif Len( Trim( widgets.description ?: "" ) )>
						<p class="admin-dashboard-widget-item-desc">
							#widgets.description#
						</p>
					</cfif>

					<cfif Len( Trim( widgets.previewImg ?: "" ) )>
						<img class="admin-dashboard-widget-item-image" src="#widgets.previewImg#" />
					</cfif>
				</a>
			</li>
		</cfloop>
	</cfif>
</cfoutput>