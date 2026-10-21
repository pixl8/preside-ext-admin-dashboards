<cfscript>
	availableWidgets = args.widgets      ?: QueryNew( "" );
	selectedWidget   = rc.selectedWidget ?: ( args.state.widget ?: "" );
</cfscript>

<cfoutput>
	<cfloop query="#availableWidgets#">
		<cfset widgetId = availableWidgets.id & #Len( availableWidgets.recordId ) ? "_#availableWidgets.recordId#" : ""# />

		<div class="widget-item">
			<input class="widget-item-input"
			       type="radio"
			       name="widget"
			       id="#widgetId#"
			       value="#widgetId#"
			       <cfif selectedWidget == widgetId>checked</cfif>
			/>

			<label class="widget-item-wrapper" for="#widgetId#">
				<cfif Len( availableWidgets.icon ?: "" )>
					<div class="widget-item-icon">
						<i class="fa fa-fw #availableWidgets.icon#"></i>
					</div>

					<div class="widget-item-content">
						<cfif isTrue( availableWidgets.supportContext ?: "" )>
							<div class="widget-item-precontent">
								<span class="badge badge-success radius-5">
									#translateResource( uri="webflow.adminDashboardsAddWidget:step.selectWidget.tag.contextual.label" )#
								</span>
							</div>
						</cfif>

						<p class="widget-item-title">#availableWidgets.title#</p>

						<cfif Len( availableWidgets.description ?: "" )>
							<p class="widget-item-desc">
								#availableWidgets.description#
							</p>
						</cfif>

						<cfif Len( Trim( availableWidgets.group ?: "" ) )>
							<div class="widget-item-tags">
								<cfloop list="#availableWidgets.group#" item="group">
									<span class="widget-item-tag">
										#translateResource( uri="admindashboards:group.#group#.label", defaultValue=UcFirst( group ) )#
									</span>
								</cfloop>
							</div>
						</cfif>
					</div>
				</cfif>
			</label>
		</div>
	</cfloop>
</cfoutput>